package engines

import (
	"cmp"
	"context"
	"database/sql"
	"errors"
	"fmt"
	"slices"

	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
)

// M4Engine manages the SCDB state and M4 message processing
type M4Engine struct {
	db *sql.DB
	// bundleMaxAge is the number of blocks a new withdrawal bundle has for its votes.
	bundleMaxAge uint32
	// inclusionThreshold is the number of ACKs a bundle must exceed for approval.
	inclusionThreshold uint16
}

type m6Event struct {
	height uint32
	slot   uint8
	hash   string
}

// NewM4Engine returns an engine with the thresholds of network. ecashID is the
// catalog id of an eCash network.
func NewM4Engine(db *sql.DB, network config.Network, ecashID string) *M4Engine {
	return &M4Engine{
		db:                 db,
		bundleMaxAge:       m4.WithdrawalMaxAge(network, ecashID),
		inclusionThreshold: m4.WithdrawalInclusionThreshold(network, ecashID),
	}
}

// ProcessBlock stores the M3 and M4 messages of a block. ApplyPendingM4
// applies the M4 votes once the enforcer reaches the block.
func (e *M4Engine) ProcessBlock(ctx context.Context, height uint32, block *wire.MsgBlock) error {
	log := zerolog.Ctx(ctx).With().
		Uint32("height", height).
		Logger()

	// Extract M3 and M4 from coinbase (first transaction)
	if len(block.Transactions) == 0 {
		return errors.New("block has no transactions")
	}

	coinbase := block.Transactions[0]
	m4Msg, m4Err := e.extractM4FromCoinbase(coinbase)

	m3Msgs, err := e.extractM3FromCoinbase(coinbase)
	if err != nil {
		log.Warn().Err(err).Msg("skip malformed M3")
	}
	for _, m3Msg := range m3Msgs {
		m3Msg.BlockHeight = height
		m3Msg.BlockHash = block.BlockHash().String()
		m3Msg.BlockTime = block.Header.Timestamp
		m3Msg.VoteHeight = height
		if m4Msg != nil && m3Msg.OutputIndex > m4Msg.OutputIndex {
			m3Msg.VoteHeight++
		}

		if err := e.persistM3Message(ctx, m3Msg); err != nil {
			return fmt.Errorf("persist M3: %w", err)
		}
		log.Debug().
			Uint8("sidechain", m3Msg.SidechainSlot).
			Str("bundle", m3Msg.BundleHash[:16]+"...").
			Msg("processed M3 (bundle proposal)")
	}

	switch {
	case m4Err != nil:
		// The enforcer takes no votes from an M4 it cannot parse either.
		log.Warn().Err(m4Err).Msg("skip malformed M4")
	case m4Msg != nil:
		m4Msg.BlockHeight = height
		m4Msg.BlockHash = block.BlockHash().String()
		m4Msg.BlockTime = block.Header.Timestamp

		if err := e.persistM4Message(ctx, m4Msg); err != nil {
			return fmt.Errorf("persist M4: %w", err)
		}

		log.Debug().
			Uint8("version", m4Msg.Version).
			Msg("stored M4 message")
	}

	return nil
}

// ApplyPendingM4 applies the stored M4 votes up to height in height order, then
// ages the bundles to height. sidechains is the enforcer's active set at height or above.
func (e *M4Engine) ApplyPendingM4(
	ctx context.Context, height uint32, sidechains []*validatorpb.GetSidechainsResponse_SidechainInfo,
	payouts []m6Event,
) error {
	pending, err := e.pendingM4Messages(ctx, height)
	if err != nil {
		return fmt.Errorf("list pending M4: %w", err)
	}
	slices.SortFunc(payouts, func(a, b m6Event) int { return cmp.Compare(a.height, b.height) })
	payoutIndex := 0
	applyPayouts := func(until uint32) error {
		for payoutIndex < len(payouts) && payouts[payoutIndex].height <= until {
			payout := payouts[payoutIndex]
			_, err := e.db.ExecContext(ctx, `
				UPDATE withdrawal_bundles
				SET status = 'succeeded', last_updated_height = ?, status_stamped = 1
				WHERE sidechain_slot = ? AND bundle_hash = ?
				  AND first_seen_height <= ?
			`, payout.height, payout.slot, payout.hash, payout.height)
			if err != nil {
				return fmt.Errorf("apply M6 payout: %w", err)
			}
			payoutIndex++
		}
		return nil
	}

	for _, msg := range pending {
		if msg.BlockHeight > 0 {
			if err := applyPayouts(msg.BlockHeight - 1); err != nil {
				return err
			}
		}
		if err := e.applyM3Proposals(ctx, msg.BlockHeight); err != nil {
			return fmt.Errorf("apply M3 proposals: %w", err)
		}
		if msg.BlockHeight > 0 {
			if err := e.updateBundleStates(ctx, msg.BlockHeight-1); err != nil {
				return fmt.Errorf("update bundle states: %w", err)
			}
		}

		votes, parsed, err := e.m4Votes(ctx, msg, activeSlotsAt(sidechains, msg.BlockHeight))
		if err != nil {
			return fmt.Errorf("read M4 votes: %w", err)
		}
		if parsed {
			msg.Votes = votes
			if err := e.persistM4Votes(ctx, msg.ID, votes); err != nil {
				return fmt.Errorf("persist M4 votes: %w", err)
			}
			if err := e.applyM4Votes(ctx, msg.BlockHeight, &msg); err != nil {
				return fmt.Errorf("apply M4 votes: %w", err)
			}
		}

		if err := e.updateBundleStates(ctx, msg.BlockHeight); err != nil {
			return fmt.Errorf("update bundle states: %w", err)
		}
		if err := applyPayouts(msg.BlockHeight); err != nil {
			return err
		}
		if _, err := e.db.ExecContext(ctx, `UPDATE m4_messages SET applied = 1 WHERE id = ?`, msg.ID); err != nil {
			return fmt.Errorf("mark M4 applied: %w", err)
		}
	}

	if err := e.applyM3Proposals(ctx, height); err != nil {
		return fmt.Errorf("apply M3 proposals: %w", err)
	}
	if err := e.updateBundleStates(ctx, height); err != nil {
		return fmt.Errorf("update bundle states: %w", err)
	}
	return nil
}

func (e *M4Engine) applyM3Proposals(ctx context.Context, height uint32) error {
	type proposal struct {
		BlockHeight   uint32 `db:"block_height"`
		VoteHeight    uint32 `db:"vote_height"`
		SidechainSlot uint8  `db:"sidechain_slot"`
		BundleHash    string `db:"bundle_hash"`
	}
	proposals, err := database.Select[proposal](ctx, e.db, `
		SELECT m.block_height, m.vote_height, m.sidechain_slot, m.bundle_hash
		FROM m3_messages m
		JOIN withdrawal_bundles b USING (sidechain_slot, bundle_hash)
		WHERE (m.block_height > b.first_seen_height
		       OR (m.block_height = b.first_seen_height AND b.last_updated_height < m.vote_height - 1))
		  AND m.block_height <= ?
		ORDER BY m.block_height, m.id
	`, height)
	if err != nil {
		return fmt.Errorf("list M3 proposals: %w", err)
	}
	for _, msg := range proposals {
		_, err := e.db.ExecContext(ctx, `
			UPDATE withdrawal_bundles
			SET work_score = 1,
			    blocks_left = ?,
			    max_age = ?,
			    first_seen_height = ?,
			    last_updated_height = ?,
			    status = 'pending',
			    status_stamped = 0,
			    updated_at = CURRENT_TIMESTAMP
			WHERE sidechain_slot = ? AND bundle_hash = ?
		  AND (first_seen_height < ? OR last_updated_height < ?)
		`, e.bundleMaxAge, e.bundleMaxAge, msg.BlockHeight, int64(msg.VoteHeight)-1,
			msg.SidechainSlot, msg.BundleHash, msg.BlockHeight, int64(msg.VoteHeight)-1)
		if err != nil {
			return fmt.Errorf("apply M3 proposal: %w", err)
		}
	}
	return nil
}

func (e *M4Engine) pendingM4Messages(ctx context.Context, height uint32) ([]m4.M4Message, error) {
	return database.Select[m4.M4Message](ctx, e.db, `
		SELECT id, block_height, block_hash, raw_bytes, version
		FROM m4_messages
		WHERE applied = 0 AND block_height <= ?
		ORDER BY block_height
	`, height)
}

// M4 versions that carry no vote vector.
const (
	m4VersionRepeatPrevious = 0x00
	m4VersionLeadingBy50    = 0x03
)

// leadingBy50Margin is LEADING_BY_50_MARGIN of the enforcer.
const leadingBy50Margin = 50

// m4Votes returns the votes of msg, with the hash of each upvote target. It
// returns parsed false for an M4 that the enforcer takes no votes from.
func (e *M4Engine) m4Votes(ctx context.Context, msg m4.M4Message, activeSlots []uint8) ([]m4.M4Vote, bool, error) {
	var (
		votes []m4.M4Vote
		err   error
	)
	switch msg.Version {
	case m4VersionRepeatPrevious:
		votes, err = e.previousM4Votes(ctx, msg.BlockHeight)
	case m4VersionLeadingBy50:
		votes, err = e.leadingBy50Votes(ctx, msg.BlockHeight, activeSlots)
	default:
		votes, err = m4.ParseM4Votes(msg.RawBytes, activeSlots)
		if err != nil {
			zerolog.Ctx(ctx).Debug().Err(err).Uint32("height", msg.BlockHeight).Msg("skip malformed M4")
			return nil, false, nil
		}
	}
	if err != nil {
		return nil, false, err
	}

	for i, vote := range votes {
		if vote.VoteType != m4.VoteTypeUpvote || vote.BundleHash != nil || vote.BundleIndex == nil {
			continue
		}
		hash, err := database.Get[string](ctx, e.db, `
			SELECT bundle_hash FROM withdrawal_bundles
			WHERE sidechain_slot = ?
			  AND status IN ('pending', 'approved')
			  AND first_seen_height <= ?
			  AND last_updated_height < ?
			ORDER BY first_seen_height ASC, (
				SELECT m.id FROM m3_messages m
				WHERE m.sidechain_slot = withdrawal_bundles.sidechain_slot
				  AND m.bundle_hash = withdrawal_bundles.bundle_hash
				  AND m.block_height = withdrawal_bundles.first_seen_height
			)
			LIMIT 1 OFFSET ?
		`, vote.SidechainSlot, msg.BlockHeight, msg.BlockHeight, *vote.BundleIndex)
		switch {
		case errors.Is(err, sql.ErrNoRows):
			zerolog.Ctx(ctx).Warn().
				Uint32("height", msg.BlockHeight).
				Uint8("sidechain", vote.SidechainSlot).
				Uint16("index", *vote.BundleIndex).
				Msg("M4 upvotes a bundle index with no pending bundle, skip the upvote")
		case err != nil:
			return nil, false, fmt.Errorf("find upvoted bundle: %w", err)
		default:
			votes[i].BundleHash = &hash
		}
	}
	return votes, true, nil
}

// previousM4Votes returns the votes of the M4 one block below height, as the
// enforcer's handle_m4_repeat_previous does.
func (e *M4Engine) previousM4Votes(ctx context.Context, height uint32) ([]m4.M4Vote, error) {
	if height == 0 {
		return nil, nil
	}
	votes, err := database.Select[m4.M4Vote](ctx, e.db, `
		SELECT v.sidechain_slot, v.vote_type, v.bundle_hash, v.bundle_index
		FROM m4_votes v
		JOIN m4_messages m ON m.id = v.m4_message_id
		WHERE m.block_height = ? AND m.applied = 1
		ORDER BY v.sidechain_slot
	`, height-1)
	if err != nil {
		return nil, fmt.Errorf("list previous M4 votes: %w", err)
	}
	return votes, nil
}

// leadingBy50Votes upvotes, for each active sidechain, the pending bundle with
// leadingBy50Margin more work than the next one, as the enforcer's
// handle_m4_leading_by_50 does. A single bundle leads an implicit zero.
func (e *M4Engine) leadingBy50Votes(ctx context.Context, height uint32, activeSlots []uint8) ([]m4.M4Vote, error) {
	var votes []m4.M4Vote
	for _, slot := range activeSlots {
		bundles, err := database.Select[m4.WithdrawalBundle](ctx, e.db, `
			SELECT bundle_hash, work_score
			FROM withdrawal_bundles
			WHERE sidechain_slot = ?
			  AND status IN ('pending', 'approved')
			  AND first_seen_height <= ?
			  AND last_updated_height < ?
			ORDER BY work_score DESC
			LIMIT 2
		`, slot, height, height)
		if err != nil {
			return nil, fmt.Errorf("list pending bundles of sidechain %d: %w", slot, err)
		}
		if len(bundles) == 0 {
			continue
		}
		var second uint16
		if len(bundles) == 2 {
			second = bundles[1].WorkScore
		}
		if bundles[0].WorkScore < second+leadingBy50Margin {
			continue
		}
		votes = append(votes, m4.M4Vote{
			SidechainSlot: slot,
			VoteType:      m4.VoteTypeUpvote,
			BundleHash:    &bundles[0].BundleHash,
		})
	}
	return votes, nil
}

// activeSlotsAt lists the sidechain slots active at height, in ascending order.
func activeSlotsAt(sidechains []*validatorpb.GetSidechainsResponse_SidechainInfo, height uint32) []uint8 {
	var slots []uint8
	for _, sc := range sidechains {
		if sc.GetActivationHeight().GetValue() > height {
			continue
		}
		slots = append(slots, uint8(sc.GetSidechainNumber().GetValue()))
	}
	slices.Sort(slots)
	return slots
}

// extractM4FromCoinbase finds and parses M4 from coinbase OP_RETURNs
func (e *M4Engine) extractM4FromCoinbase(coinbase *wire.MsgTx) (*m4.M4Message, error) {
	// Check all outputs for M4 commitment
	for vout, txout := range coinbase.TxOut {
		script := txout.PkScript
		if !m4.IsM4Commitment(script) {
			continue
		}

		// Try to parse as M4
		msg, err := m4.ParseM4Bytes(script)
		if err != nil {
			return nil, fmt.Errorf("parse M4: %w", err)
		}

		msg.OutputIndex = uint32(vout)
		return msg, nil
	}

	return nil, nil
}

// persistM4Message stores an M4 message. Its votes wait for ApplyPendingM4.
func (e *M4Engine) persistM4Message(ctx context.Context, msg *m4.M4Message) error {
	_, err := e.db.ExecContext(ctx, `
		INSERT INTO m4_messages (
			block_height, block_hash, block_time, raw_bytes, version
		) VALUES (?, ?, ?, ?, ?)
		ON CONFLICT(block_height, block_hash) DO UPDATE SET
			raw_bytes = excluded.raw_bytes,
			version = excluded.version
	`, msg.BlockHeight, msg.BlockHash, msg.BlockTime, msg.RawBytes, msg.Version)
	if err != nil {
		return fmt.Errorf("insert M4 message: %w", err)
	}
	return nil
}

// persistM4Votes replaces the votes stored for an M4 message.
func (e *M4Engine) persistM4Votes(ctx context.Context, msgID int64, votes []m4.M4Vote) error {
	return inTx(ctx, e.db, func(tx *sql.Tx) error {
		if _, err := tx.ExecContext(ctx, `DELETE FROM m4_votes WHERE m4_message_id = ?`, msgID); err != nil {
			return fmt.Errorf("delete old votes: %w", err)
		}

		for _, vote := range votes {
			var bundleIndex *uint16
			if vote.VoteType == m4.VoteTypeUpvote {
				bundleIndex = vote.BundleIndex
			}

			_, err := tx.ExecContext(ctx, `
				INSERT INTO m4_votes (
					m4_message_id, sidechain_slot, vote_type, bundle_hash, bundle_index
				) VALUES (?, ?, ?, ?, ?)
			`, msgID, vote.SidechainSlot, vote.VoteType, vote.BundleHash, bundleIndex)
			if err != nil {
				return fmt.Errorf("insert vote: %w", err)
			}
		}
		return nil
	})
}

// GetM4History returns the last N M4 messages
func (e *M4Engine) GetM4History(ctx context.Context, limit int) ([]m4.M4Message, error) {
	messages, err := database.Select[m4.M4Message](ctx, e.db, `
		SELECT id, block_height, block_hash, block_time, raw_bytes, version, created_at
		FROM m4_messages
		ORDER BY block_height DESC
		LIMIT ?
	`, limit)
	if err != nil {
		return nil, fmt.Errorf("query M4 messages: %w", err)
	}

	for i := range messages {
		votes, err := e.getVotesForMessage(ctx, messages[i].ID)
		if err != nil {
			return nil, fmt.Errorf("get votes for message %d: %w", messages[i].ID, err)
		}
		messages[i].Votes = votes
	}
	return messages, nil
}

// getVotesForMessage retrieves all votes for a specific M4 message
func (e *M4Engine) getVotesForMessage(ctx context.Context, msgID int64) ([]m4.M4Vote, error) {
	return database.Select[m4.M4Vote](ctx, e.db, `
		SELECT id, m4_message_id, sidechain_slot, vote_type, bundle_hash, bundle_index
		FROM m4_votes
		WHERE m4_message_id = ?
		ORDER BY sidechain_slot
	`, msgID)
}

// extractM3FromCoinbase finds and parses M3 messages from coinbase OP_RETURNs
func (e *M4Engine) extractM3FromCoinbase(coinbase *wire.MsgTx) ([]*m4.M3Message, error) {
	var (
		messages []*m4.M3Message
		errs     []error
	)

	// Check all outputs for M3 commitments
	for vout, txout := range coinbase.TxOut {
		script := txout.PkScript
		if !m4.IsM3Commitment(script) {
			continue
		}

		msg, err := m4.ParseM3Bytes(script)
		if err != nil {
			errs = append(errs, fmt.Errorf("parse M3 at vout %d: %w", vout, err))
			continue
		}

		msg.OutputIndex = uint32(vout)
		messages = append(messages, msg)
	}

	return messages, errors.Join(errs...)
}

// persistM3Message stores an M3 message and creates the corresponding withdrawal bundle
func (e *M4Engine) persistM3Message(ctx context.Context, msg *m4.M3Message) error {
	return inTx(ctx, e.db, func(tx *sql.Tx) error {
		_, err := tx.ExecContext(ctx, `
			INSERT INTO m3_messages (
				block_height, block_hash, block_time, sidechain_slot, bundle_hash, vote_height
			) VALUES (?, ?, ?, ?, ?, ?)
			ON CONFLICT(block_height, sidechain_slot, bundle_hash) DO UPDATE
			SET vote_height = excluded.vote_height
		`, msg.BlockHeight, msg.BlockHash, msg.BlockTime, msg.SidechainSlot, msg.BundleHash, msg.VoteHeight)
		if err != nil {
			return fmt.Errorf("insert M3 message: %w", err)
		}

		// Create withdrawal bundle if it doesn't exist
		_, err = tx.ExecContext(ctx, `
			INSERT INTO withdrawal_bundles (
				sidechain_slot, bundle_hash, work_score, blocks_left, max_age,
				first_seen_height, last_updated_height, status
			) VALUES (?, ?, 1, ?, ?, ?, ?, 'pending')
			ON CONFLICT(sidechain_slot, bundle_hash) DO NOTHING
		`, msg.SidechainSlot, msg.BundleHash, e.bundleMaxAge, e.bundleMaxAge, msg.BlockHeight, int64(msg.VoteHeight)-1)
		if err != nil {
			return fmt.Errorf("insert withdrawal bundle: %w", err)
		}
		return nil
	})
}

// applyM4Votes applies M4 votes as the AckBundles diff of the enforcer does
// (bip300301_enforcer lib/validator/dbs/diff.rs). last_updated_height < height
// keeps a replayed block from scoring a bundle it already scored.
func (e *M4Engine) applyM4Votes(ctx context.Context, height uint32, msg *m4.M4Message) error {
	for _, vote := range msg.Votes {
		switch vote.VoteType {
		case m4.VoteTypeUpvote:
			if vote.BundleHash == nil {
				continue
			}
			if err := e.upvoteBundle(ctx, height, vote.SidechainSlot, *vote.BundleHash); err != nil {
				return fmt.Errorf("upvote bundle: %w", err)
			}

		case m4.VoteTypeAlarm:
			// Decrement work score for all bundles on this sidechain
			_, err := e.db.ExecContext(ctx, `
				UPDATE withdrawal_bundles
				SET work_score = MAX(0, work_score - 1),
				    last_updated_height = ?,
				    updated_at = CURRENT_TIMESTAMP
				WHERE sidechain_slot = ?
				  AND status IN ('pending', 'approved')
				  AND first_seen_height <= ?
				  AND last_updated_height < ?
			`, height, vote.SidechainSlot, height, height)
			if err != nil {
				return fmt.Errorf("alarm (downvote) bundles: %w", err)
			}

		case m4.VoteTypeAbstain:
			// No score change, but update last_updated_height
			_, err := e.db.ExecContext(ctx, `
				UPDATE withdrawal_bundles
				SET last_updated_height = ?
				WHERE sidechain_slot = ?
				  AND status IN ('pending', 'approved')
				  AND first_seen_height <= ?
				  AND last_updated_height < ?
			`, height, vote.SidechainSlot, height, height)
			if err != nil {
				return fmt.Errorf("abstain (no-op) on bundles: %w", err)
			}
		}
	}

	return nil
}

// upvoteBundle adds one to the work score of the bundle, and takes one from
// each other pending bundle of the sidechain.
func (e *M4Engine) upvoteBundle(ctx context.Context, height uint32, slot uint8, bundleHash string) error {
	return inTx(ctx, e.db, func(tx *sql.Tx) error {
		res, err := tx.ExecContext(ctx, `
			UPDATE withdrawal_bundles
			SET work_score = work_score + 1,
			    last_updated_height = ?,
			    updated_at = CURRENT_TIMESTAMP
			WHERE sidechain_slot = ?
			  AND bundle_hash = ?
			  AND status IN ('pending', 'approved')
			  AND first_seen_height <= ?
			  AND last_updated_height < ?
		`, height, slot, bundleHash, height, height)
		if err != nil {
			return err
		}
		upvoted, err := res.RowsAffected()
		if err != nil {
			return err
		}
		if upvoted == 0 {
			return nil
		}

		_, err = tx.ExecContext(ctx, `
			UPDATE withdrawal_bundles
			SET work_score = MAX(0, work_score - 1),
			    last_updated_height = ?,
			    updated_at = CURRENT_TIMESTAMP
			WHERE sidechain_slot = ?
			  AND bundle_hash != ?
			  AND status IN ('pending', 'approved')
			  AND first_seen_height <= ?
			  AND last_updated_height < ?
		`, height, slot, bundleHash, height, height)
		if err != nil {
			return fmt.Errorf("downvote other bundles: %w", err)
		}
		return nil
	})
}

// updateBundleStates recomputes blocks_left and updates status for all pending bundles
func (e *M4Engine) updateBundleStates(ctx context.Context, height uint32) error {
	// Derived from the height rather than decremented, so replaying a block
	// after a reorg lands on the same value instead of ageing the bundle twice.
	// max_age is set again, because rows from an older build hold the mainnet age.
	_, err := e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET max_age = ?,
		    blocks_left = MAX(0, ? - (? - first_seen_height)),
		    updated_at = CURRENT_TIMESTAMP
		WHERE status IN ('pending', 'approved')
		  AND first_seen_height <= ?
	`, e.bundleMaxAge, e.bundleMaxAge, height, height)
	if err != nil {
		return fmt.Errorf("recompute blocks_left: %w", err)
	}

	// Fork replay uses the height of each status change.
	_, err = e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET status = CASE WHEN work_score > ? THEN 'approved' ELSE 'pending' END,
		    last_updated_height = ?,
		    status_stamped = 1
		WHERE status IN ('pending', 'approved')
		  AND status != CASE WHEN work_score > ? THEN 'approved' ELSE 'pending' END
	`, e.inclusionThreshold, height, e.inclusionThreshold)
	if err != nil {
		return fmt.Errorf("mark approved bundles: %w", err)
	}

	// The node removes expired bundles after the votes, when age exceeds max_age.
	_, err = e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET status = 'failed',
		    last_updated_height = ?,
		    status_stamped = 1
		WHERE status IN ('pending', 'approved')
		  AND first_seen_height + max_age < ?
	`, height, height)
	if err != nil {
		return fmt.Errorf("mark failed bundles: %w", err)
	}

	return nil
}
