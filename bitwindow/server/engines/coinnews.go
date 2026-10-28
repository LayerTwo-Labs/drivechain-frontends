package engines

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"sort"

	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	cnstore "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinnews"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
)

// indexCoinNewsBlocks runs the CoinNews indexing pass over a batch of
// already-fetched blocks. Blocks are processed in canonical scan order
// (`block_height ASC, tx_index ASC, vout_index ASC`) — that ordering is
// load-bearing for the spec's first-wins / last-wins semantics, so we
// run sequentially even though block fetching above us is parallel.
//
// Errors bubble — a failed cn_* insert MUST NOT mark its block as
// processed, otherwise resync can't heal the gap.
func (p *Parser) indexCoinNewsBlocks(ctx context.Context, blocks []lo.Tuple2[uint32, *wire.MsgBlock]) error {
	sorted := append([]lo.Tuple2[uint32, *wire.MsgBlock]{}, blocks...)
	sort.Slice(sorted, func(i, j int) bool { return sorted[i].A < sorted[j].A })

	for _, t := range sorted {
		height, block := t.Unpack()
		if err := p.indexCoinNewsForBlock(ctx, height, block); err != nil {
			return err
		}
	}
	return nil
}

// indexCoinNewsForBlock walks one block's transactions and OP_RETURN
// outputs in canonical order, dispatching each CoinNews payload to
// the persistence layer. Transactions that aren't CoinNews are
// skipped silently; signed messages whose sigs don't verify are
// dropped (logged at debug, never persisted).
func (p *Parser) indexCoinNewsForBlock(ctx context.Context, height uint32, block *wire.MsgBlock) error {
	for txIdx, tx := range block.Transactions {
		txid := tx.TxID()
		for vout, txout := range tx.TxOut {
			data, ok := coinNewsPayload(txout.PkScript)
			if !ok {
				continue
			}
			pos := cnstore.BlockPos{
				BlockHeight: height,
				TxIndex:     uint32(txIdx),
				VoutIndex:   uint32(vout),
				BlockTime:   block.Header.Timestamp,
				TxID:        txid,
			}
			if err := indexCoinNewsPayload(ctx, p.db, data, pos); err != nil {
				return err
			}
		}
	}
	return nil
}

// indexCoinNewsPayload classifies one OP_RETURN payload and persists
// it. Returns nil for non-CoinNews bytes (silent skip), nil for
// dropped messages (bad sig, malformed envelope), and a non-nil
// error only on persistence failure — the caller surfaces that.
func indexCoinNewsPayload(ctx context.Context, db *sql.DB, data []byte, pos cnstore.BlockPos) error {
	tag, msg, err := codec.DecodeMessage(data)
	if err != nil {
		if errors.Is(err, codec.ErrNotCoinNews) {
			return nil
		}
		if errors.Is(err, codec.ErrUnknownTypeTag) {
			return nil
		}
		// Magic matched but parsing failed — malformed CoinNews payload.
		// Drop with a debug log so test runs surface it.
		dropMsg(ctx, pos, "malformed payload", err)
		return nil
	}

	self := cnstore.ItemRef{BlockHeight: pos.BlockHeight, TxIndex: pos.TxIndex, VoutIndex: pos.VoutIndex}

	switch m := msg.(type) {
	case *codec.Comment:
		if err := codec.VerifyComment(m); err != nil {
			dropMsg(ctx, pos, "comment sig invalid", err)
			return nil
		}
		// §7: drop Comments whose parent is unresolvable. §4.2: the
		// parent must be earlier than the comment in scan order.
		parent, ok, err := cnstore.ResolveItem(ctx, db, m.Parent)
		if err != nil {
			return err
		}
		if !ok || !parent.Before(self) {
			dropMsg(ctx, pos, "comment parent unresolvable", nil)
			return nil
		}
	case *codec.Continuation:
		// §9: continuations live in the head's tx or a later tx in the
		// same block, after the head in scan order.
		head, ok, err := cnstore.ResolveItem(ctx, db, m.Head)
		if err != nil {
			return err
		}
		if !ok || head.BlockHeight != pos.BlockHeight || !head.Before(self) {
			dropMsg(ctx, pos, "continuation head unresolvable", nil)
			return nil
		}
	}

	if err := cnstore.Index(ctx, db, cnstore.IndexEnv{Pos: pos, TypeTag: tag, Msg: msg}); err != nil {
		return err
	}
	opreturns.InvalidateCoinNewsCache(db)
	return nil
}

// coinNewsPayload extracts the bytes pushed by a single-push OP_RETURN
// script. Returns ok=false for anything else (not OP_RETURN, multi-
// push, OP_DRIVECHAIN, coinbase witness commitment).
func coinNewsPayload(pkScript []byte) ([]byte, bool) {
	if len(pkScript) < 2 || pkScript[0] != txscript.OP_RETURN {
		return nil, false
	}
	if isWitnessCommitment(pkScript) {
		return nil, false
	}
	if shouldSkip(pkScript) {
		return nil, false
	}
	return parseOPReturnData(pkScript)
}

// dropMsg emits the "decoded but rejected" log line, used for both
// malformed payloads and failed-sig drops. Single helper keeps the
// log format consistent across decode-failure paths.
func dropMsg(ctx context.Context, pos cnstore.BlockPos, reason string, err error) {
	zerolog.Ctx(ctx).Debug().Err(err).
		Str("txid", pos.TxID).
		Uint32("vout", pos.VoutIndex).
		Uint32("height", pos.BlockHeight).
		Msg("coinnews: " + reason + ", dropping")
}

// inTx runs fn in one transaction and commits when it returns nil.
func inTx(ctx context.Context, db *sql.DB, fn func(*sql.Tx) error) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin transaction: %w", err)
	}
	defer tx.Rollback() //nolint:errcheck // committed on success
	if err := fn(tx); err != nil {
		return err
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit transaction: %w", err)
	}
	return nil
}

// purgeM4AtOrAboveTx deletes every M4/SCDB row originating from a block at or
// above `fromHeight`. Called on the same reorg replay as purgeCoinNewsAtOrAboveTx
// — without it, a bundle first seen in an orphaned block survives the replay
// (its insert is ON CONFLICT DO NOTHING) and keeps voting.
// It returns the height a replay has to start from to rebuild what survives.
// A bundle the orphan branch scored has a work_score, status and
// last_updated_height that no query rebuilds: the score is a running count with
// a floor. Only a replay of the blocks does. So the bundle goes, and the
// returned height takes the replay back to its first block.
func purgeM4AtOrAboveTx(ctx context.Context, tx *sql.Tx, fromHeight uint32) (uint32, error) {
	// Widening the window drags in more bundles, and each of those has to be
	// replayed from its own first block too. Repeat until it stops moving, or a
	// bundle ends up cleared with part of its history never replayed.
	replayFrom := fromHeight
	for {
		// A terminal bundle written before the transitions stamped their height
		// holds only its last vote, so last_updated_height cannot say whether
		// the branch that went away is what ended it.
		//
		// Only a legacy row is ambiguous, and a legacy row is one whose stamp
		// still sits at the vote that ended it — status_stamped marks the rest.
		// Without that guard every approved bundle would pull the window back
		// to the oldest one, so a one-block reorg rescans years of blocks.
		//
		// failed and expired both need blocks_left = 0, which cannot happen
		// before first_seen_height + max_age, so one that aged out below the
		// window stays. approved needs only a score, which any block can reach.
		lowest, err := database.Get[sql.NullInt64](ctx, tx, `
			SELECT MIN(COALESCE((
				SELECT MIN(m.block_height) FROM m3_messages m
				WHERE m.sidechain_slot = b.sidechain_slot AND m.bundle_hash = b.bundle_hash
			), first_seen_height)) FROM withdrawal_bundles b
			WHERE last_updated_height >= ?
			   OR (status_stamped = 0 AND status = 'approved' AND first_seen_height < ?)
			   OR (status_stamped = 0 AND status IN ('failed', 'expired')
			       AND first_seen_height + max_age >= ?)`,
			replayFrom, replayFrom, replayFrom,
		)
		if err != nil {
			return 0, err
		}
		if !lowest.Valid || lowest.Int64 < 0 || uint32(lowest.Int64) >= replayFrom {
			break
		}
		replayFrom = uint32(lowest.Int64)
	}

	stmts := []string{
		`DELETE FROM m4_votes           WHERE m4_message_id IN (SELECT id FROM m4_messages WHERE block_height >= ?)`,
		`DELETE FROM m4_messages        WHERE block_height >= ?`,
		`DELETE FROM m3_messages        WHERE block_height >= ?`,
		`DELETE FROM withdrawal_bundles WHERE first_seen_height >= ?`,
	}
	for i, q := range stmts {
		if _, err := tx.ExecContext(ctx, q, replayFrom); err != nil {
			return 0, fmt.Errorf("purge m4 statement %d: %w", i, err)
		}
	}

	// No reset is left to make: at the fixed point every bundle the replay
	// re-scores was first seen at or above replayFrom, so the delete took it.
	return replayFrom, nil
}

// purgeChainDerivedAtOrAboveTx drops the block-derived op_returns and
// file_timestamps state from blocks at or above `fromHeight`. Neither
// heals itself on replay: the op_returns upsert keeps the old height
// (`COALESCE(excluded.height, op_returns.height)`), and a confirmed
// timestamp is never re-examined. Mempool OP_RETURNs have a NULL height
// and are left alone; reset timestamps go back through the confirming
// loop, which re-confirms them against the new chain or fails them.
func purgeChainDerivedAtOrAboveTx(ctx context.Context, tx *sql.Tx, fromHeight uint32) error {

	if _, err := tx.ExecContext(ctx,
		`DELETE FROM op_returns WHERE height >= ?`, fromHeight,
	); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `
		UPDATE file_timestamps
		SET status = ?, block_height = NULL, confirmed_at = NULL
		WHERE block_height >= ?`,
		timestamps.StatusConfirming, fromHeight,
	); err != nil {
		return err
	}
	return nil
}

// purgeCoinNewsAtOrAboveTx deletes every cn_* row originating from a
// block at or above `fromHeight`. Called when the engine detects a
// reorg and replays a height range — without it, `INSERT OR IGNORE`
// during the replay would silently keep orphaned rows from the
// pre-reorg chain, breaking the determinism budget.
func purgeCoinNewsAtOrAboveTx(ctx context.Context, tx *sql.Tx, fromHeight uint32) error {

	stmts := []string{
		`DELETE FROM cn_stories       WHERE item_id IN (SELECT item_id FROM cn_items WHERE block_height >= ?)`,
		`DELETE FROM cn_comments      WHERE item_id IN (SELECT item_id FROM cn_items WHERE block_height >= ?)`,
		`DELETE FROM cn_continuations WHERE block_height >= ?`,
		// An empty txid marks a local bootstrap row, not a creation on chain.
		// No block replays it, so a delete here loses it for good.
		`DELETE FROM cn_topics        WHERE created_height >= ? AND txid != ''`,
		`DELETE FROM cn_items         WHERE block_height >= ?`,
	}
	for i, q := range stmts {
		if _, err := tx.ExecContext(ctx, q, fromHeight); err != nil {
			return fmt.Errorf("purge coinnews statement %d: %w", i, err)
		}
	}
	return nil
}
