package engines

import (
	"context"
	"errors"
	"sort"

	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	cnstore "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinnews"
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
			if err := p.indexCoinNewsPayload(ctx, data, pos); err != nil {
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
func (p *Parser) indexCoinNewsPayload(ctx context.Context, data []byte, pos cnstore.BlockPos) error {
	tag, msg, err := codec.DecodeMessage(data)
	if err != nil {
		if errors.Is(err, codec.ErrNotCoinNews) || errors.Is(err, codec.ErrUnknownTypeTag) {
			return nil
		}
		// Magic matched but parsing failed — malformed CoinNews payload.
		// Drop with a debug log so test runs surface it.
		dropMsg(ctx, pos, "malformed payload", err)
		return nil
	}

	switch m := msg.(type) {
	case *codec.Comment:
		if err := codec.VerifyComment(m); err != nil {
			dropMsg(ctx, pos, "comment sig invalid", err)
			return nil
		}
	case *codec.Vote:
		if err := codec.VerifyVote(m); err != nil {
			dropMsg(ctx, pos, "vote sig invalid", err)
			return nil
		}
	}

	return cnstore.Index(ctx, p.db, cnstore.IndexEnv{Pos: pos, TypeTag: tag, Msg: msg})
}

// coinNewsPayload extracts the bytes pushed by a single-push OP_RETURN
// script. Returns ok=false for anything else (not OP_RETURN, multi-
// push, OP_DRIVECHAIN, coinbase carrier).
func coinNewsPayload(pkScript []byte) ([]byte, bool) {
	if len(pkScript) < 2 || pkScript[0] != txscript.OP_RETURN {
		return nil, false
	}
	if pkScript[1] == txscript.OP_DATA_36 {
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

// purgeCoinNewsAtOrAbove deletes every cn_* row originating from a
// block at or above `fromHeight`. Called when the engine detects a
// reorg and replays a height range — without it, `INSERT OR IGNORE`
// during the replay would silently keep orphaned rows from the
// pre-reorg chain, breaking the determinism budget.
func (p *Parser) purgeCoinNewsAtOrAbove(ctx context.Context, fromHeight uint32) error {
	tx, err := p.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck // committed on success

	stmts := []string{
		`DELETE FROM cn_stories       WHERE item_id IN (SELECT item_id FROM cn_items WHERE block_height >= ?)`,
		`DELETE FROM cn_comments      WHERE item_id IN (SELECT item_id FROM cn_items WHERE block_height >= ?)`,
		`DELETE FROM cn_votes         WHERE block_height >= ?`,
		`DELETE FROM cn_continuations WHERE block_height >= ?`,
		`DELETE FROM cn_topics        WHERE created_height >= ?`,
		`DELETE FROM cn_items         WHERE block_height >= ?`,
	}
	for _, q := range stmts {
		if _, err := tx.ExecContext(ctx, q, fromHeight); err != nil {
			return err
		}
	}
	return tx.Commit()
}
