package engines

import (
	"context"
	"database/sql"
	"fmt"
	"slices"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
)

// M4Engine manages the SCDB state and M4 message processing
type M4Engine struct {
	db *sql.DB
}

func NewM4Engine(db *sql.DB) *M4Engine {
	return &M4Engine{db: db}
}

// ProcessBlock stores the M3 and M4 messages of a block. ApplyPendingM4
// applies the M4 votes once the enforcer reaches the block.
func (e *M4Engine) ProcessBlock(ctx context.Context, height uint32, block *wire.MsgBlock) error {
	log := zerolog.Ctx(ctx).With().
		Uint32("height", height).
		Logger()

	// Extract M3 and M4 from coinbase (first transaction)
	if len(block.Transactions) == 0 {
		return fmt.Errorf("block has no transactions")
	}

	coinbase := block.Transactions[0]

	// First, process M3 (withdrawal bundle proposals)
	m3Msgs, err := e.extractM3FromCoinbase(coinbase)
	if err == nil && len(m3Msgs) > 0 {
		for _, m3Msg := range m3Msgs {
			m3Msg.BlockHeight = height
			m3Msg.BlockHash = block.BlockHash().String()
			m3Msg.BlockTime = block.Header.Timestamp

			if err := e.persistM3Message(ctx, m3Msg); err != nil {
				log.Warn().Err(err).Msg("failed to persist M3 message")
			} else {
				log.Debug().
					Uint8("sidechain", m3Msg.SidechainSlot).
					Str("bundle", m3Msg.BundleHash[:16]+"...").
					Msg("processed M3 (bundle proposal)")
			}
		}
	}

	// Then, process M4 (withdrawal bundle votes)
	m4Msg, err := e.extractM4FromCoinbase(coinbase)
	if err != nil {
		// Not finding an M4 is OK - not all blocks have them
		log.Trace().Msg("no M4 found in coinbase")
	} else {
		// Store the M4 message
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
) error {
	pending, err := e.pendingM4Messages(ctx, height)
	if err != nil {
		return fmt.Errorf("list pending M4: %w", err)
	}

	for _, msg := range pending {
		if msg.BlockHeight > 0 {
			if err := e.updateBundleStates(ctx, msg.BlockHeight-1); err != nil {
				return fmt.Errorf("update bundle states: %w", err)
			}
		}

		votes, err := m4.ParseM4Votes(msg.RawBytes, activeSlotsAt(sidechains, msg.BlockHeight))
		if err != nil {
			// The enforcer takes no votes from an M4 it cannot place either.
			zerolog.Ctx(ctx).Debug().Err(err).Uint32("height", msg.BlockHeight).Msg("skip malformed M4")
		} else {
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
		if _, err := e.db.ExecContext(ctx, `UPDATE m4_messages SET applied = 1 WHERE id = ?`, msg.ID); err != nil {
			return fmt.Errorf("mark M4 applied: %w", err)
		}
	}

	if err := e.updateBundleStates(ctx, height); err != nil {
		return fmt.Errorf("update bundle states: %w", err)
	}
	return nil
}

func (e *M4Engine) pendingM4Messages(ctx context.Context, height uint32) ([]m4.M4Message, error) {
	rows, err := e.db.QueryContext(ctx, `
		SELECT id, block_height, raw_bytes
		FROM m4_messages
		WHERE applied = 0 AND block_height <= ?
		ORDER BY block_height
	`, height)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []m4.M4Message
	for rows.Next() {
		var msg m4.M4Message
		if err := rows.Scan(&msg.ID, &msg.BlockHeight, &msg.RawBytes); err != nil {
			return nil, err
		}
		messages = append(messages, msg)
	}
	return messages, rows.Err()
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
	for _, txout := range coinbase.TxOut {
		script := txout.PkScript
		if !m4.IsM4Commitment(script) {
			continue
		}

		// Try to parse as M4
		msg, err := m4.ParseM4Bytes(script)
		if err != nil {
			return nil, fmt.Errorf("parse M4: %w", err)
		}

		return msg, nil
	}

	return nil, fmt.Errorf("no M4 commitment found in coinbase")
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
	tx, err := e.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

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
			) VALUES (?, ?, ?, NULL, ?)
		`, msgID, vote.SidechainSlot, vote.VoteType, bundleIndex)
		if err != nil {
			return fmt.Errorf("insert vote: %w", err)
		}
	}

	return tx.Commit()
}

// GetM4History returns the last N M4 messages
func (e *M4Engine) GetM4History(ctx context.Context, limit int) ([]m4.M4Message, error) {
	rows, err := e.db.QueryContext(ctx, `
		SELECT id, block_height, block_hash, block_time, raw_bytes, version, created_at
		FROM m4_messages
		ORDER BY block_height DESC
		LIMIT ?
	`, limit)
	if err != nil {
		return nil, fmt.Errorf("query M4 messages: %w", err)
	}
	messages, err := scanM4Messages(rows)
	if err != nil {
		return nil, err
	}

	// The database has one connection, so the votes query waits until the rows above close.
	for i := range messages {
		votes, err := e.getVotesForMessage(ctx, messages[i].ID)
		if err != nil {
			return nil, fmt.Errorf("get votes for message %d: %w", messages[i].ID, err)
		}
		messages[i].Votes = votes
	}
	return messages, nil
}

func scanM4Messages(rows *sql.Rows) ([]m4.M4Message, error) {
	defer rows.Close()

	var messages []m4.M4Message
	for rows.Next() {
		var msg m4.M4Message
		err := rows.Scan(
			&msg.ID, &msg.BlockHeight, &msg.BlockHash, &msg.BlockTime,
			&msg.RawBytes, &msg.Version, &msg.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan M4 message: %w", err)
		}
		messages = append(messages, msg)
	}
	return messages, rows.Err()
}

// getVotesForMessage retrieves all votes for a specific M4 message
func (e *M4Engine) getVotesForMessage(ctx context.Context, msgID int64) ([]m4.M4Vote, error) {
	rows, err := e.db.QueryContext(ctx, `
		SELECT id, m4_message_id, sidechain_slot, vote_type, bundle_hash, bundle_index
		FROM m4_votes
		WHERE m4_message_id = ?
		ORDER BY sidechain_slot
	`, msgID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var votes []m4.M4Vote
	for rows.Next() {
		var vote m4.M4Vote
		err := rows.Scan(
			&vote.ID, &vote.M4MessageID, &vote.SidechainSlot,
			&vote.VoteType, &vote.BundleHash, &vote.BundleIndex,
		)
		if err != nil {
			return nil, err
		}
		votes = append(votes, vote)
	}

	return votes, rows.Err()
}

// ListSidechains returns all sidechains
func (e *M4Engine) ListSidechains(ctx context.Context) ([]m4.Sidechain, error) {
	rows, err := e.db.QueryContext(ctx, `
		SELECT slot, name, description, version, activated_height, created_at
		FROM sidechains
		ORDER BY slot
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sidechains []m4.Sidechain
	for rows.Next() {
		var sc m4.Sidechain
		err := rows.Scan(
			&sc.Slot, &sc.Name, &sc.Description,
			&sc.Version, &sc.ActivatedHeight, &sc.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		sidechains = append(sidechains, sc)
	}

	return sidechains, rows.Err()
}

// GetVotePreferences returns user's vote preferences
func (e *M4Engine) GetVotePreferences(ctx context.Context) ([]m4.VotePreference, error) {
	rows, err := e.db.QueryContext(ctx, `
		SELECT sidechain_slot, vote_type, bundle_hash, updated_at
		FROM m4_vote_preferences
		ORDER BY sidechain_slot
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var prefs []m4.VotePreference
	for rows.Next() {
		var pref m4.VotePreference
		err := rows.Scan(
			&pref.SidechainSlot, &pref.VoteType,
			&pref.BundleHash, &pref.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		prefs = append(prefs, pref)
	}

	return prefs, rows.Err()
}

// SetVotePreference sets user's vote preference for a sidechain
func (e *M4Engine) SetVotePreference(ctx context.Context, sidechainSlot uint8, voteType m4.VoteType, bundleHash *string) error {
	_, err := e.db.ExecContext(ctx, `
		INSERT INTO m4_vote_preferences (sidechain_slot, vote_type, bundle_hash, updated_at)
		VALUES (?, ?, ?, ?)
		ON CONFLICT(sidechain_slot) DO UPDATE SET
			vote_type = excluded.vote_type,
			bundle_hash = excluded.bundle_hash,
			updated_at = excluded.updated_at
	`, sidechainSlot, voteType, bundleHash, time.Now())
	return err
}

// extractM3FromCoinbase finds and parses M3 messages from coinbase OP_RETURNs
func (e *M4Engine) extractM3FromCoinbase(coinbase *wire.MsgTx) ([]*m4.M3Message, error) {
	var messages []*m4.M3Message

	// Check all outputs for M3 commitments
	for _, txout := range coinbase.TxOut {
		script := txout.PkScript
		if !m4.IsM3Commitment(script) {
			continue
		}

		// Try to parse as M3
		msg, err := m4.ParseM3Bytes(script)
		if err != nil {
			continue
		}

		messages = append(messages, msg)
	}

	if len(messages) == 0 {
		return nil, fmt.Errorf("no M3 commitment found in coinbase")
	}

	return messages, nil
}

// persistM3Message stores an M3 message and creates the corresponding withdrawal bundle
func (e *M4Engine) persistM3Message(ctx context.Context, msg *m4.M3Message) error {
	tx, err := e.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	// Insert M3 message
	_, err = tx.ExecContext(ctx, `
		INSERT INTO m3_messages (
			block_height, block_hash, block_time, sidechain_slot, bundle_hash
		) VALUES (?, ?, ?, ?, ?)
		ON CONFLICT(block_height, sidechain_slot, bundle_hash) DO NOTHING
	`, msg.BlockHeight, msg.BlockHash, msg.BlockTime, msg.SidechainSlot, msg.BundleHash)
	if err != nil {
		return fmt.Errorf("insert M3 message: %w", err)
	}

	// Create withdrawal bundle if it doesn't exist
	_, err = tx.ExecContext(ctx, `
		INSERT INTO withdrawal_bundles (
			sidechain_slot, bundle_hash, work_score, blocks_left,
			first_seen_height, last_updated_height, status
		) VALUES (?, ?, 1, ?, ?, ?, 'pending')
		ON CONFLICT(sidechain_slot, bundle_hash) DO NOTHING
	`, msg.SidechainSlot, msg.BundleHash, m4.WithdrawalMaxAge, msg.BlockHeight, msg.BlockHeight)
	if err != nil {
		return fmt.Errorf("insert withdrawal bundle: %w", err)
	}

	return tx.Commit()
}

// applyM4Votes applies M4 votes to update withdrawal bundle work scores
func (e *M4Engine) applyM4Votes(ctx context.Context, height uint32, msg *m4.M4Message) error {
	for _, vote := range msg.Votes {
		switch vote.VoteType {
		case m4.VoteTypeUpvote:
			// Increment work score for upvoted bundle
			// We need to find the bundle by sidechain slot and index
			if vote.BundleIndex != nil {
				// The bundle is picked by a subquery because SQLite only allows
				// ORDER BY/LIMIT directly on an UPDATE in builds this driver
				// does not use.
				// last_updated_height < height keeps a replayed block from
				// scoring a bundle it already scored. Heights only move forward
				// in a normal scan, so this is a no-op there.
				_, err := e.db.ExecContext(ctx, `
					UPDATE withdrawal_bundles
					SET work_score = work_score + 1,
					    last_updated_height = ?,
					    updated_at = CURRENT_TIMESTAMP
					WHERE id = (
					    SELECT id FROM withdrawal_bundles
					    WHERE sidechain_slot = ?
					      AND status = 'pending'
					      AND first_seen_height <= ?
					    ORDER BY first_seen_height ASC
					    LIMIT 1 OFFSET ?
					)
					  AND last_updated_height < ?
				`, height, vote.SidechainSlot, height, *vote.BundleIndex, height)
				if err != nil {
					return fmt.Errorf("upvote bundle: %w", err)
				}
			}

		case m4.VoteTypeAlarm:
			// Decrement work score for all bundles on this sidechain
			_, err := e.db.ExecContext(ctx, `
				UPDATE withdrawal_bundles
				SET work_score = MAX(0, work_score - 1),
				    last_updated_height = ?,
				    updated_at = CURRENT_TIMESTAMP
				WHERE sidechain_slot = ?
				  AND status = 'pending'
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
				  AND status = 'pending'
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

// updateBundleStates recomputes blocks_left and updates status for all pending bundles
func (e *M4Engine) updateBundleStates(ctx context.Context, height uint32) error {
	// Derived from the height rather than decremented, so replaying a block
	// after a reorg lands on the same value instead of ageing the bundle twice.
	_, err := e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET blocks_left = MAX(0, max_age - (? - first_seen_height)),
		    updated_at = CURRENT_TIMESTAMP
		WHERE status = 'pending'
		  AND first_seen_height <= ?
	`, height, height)
	if err != nil {
		return fmt.Errorf("recompute blocks_left: %w", err)
	}

	// Each transition stamps the height it happened at. A terminal bundle takes
	// no more votes, so this changes nothing for scoring — but a fork purge
	// keys on last_updated_height, and without it a bundle that went terminal
	// on the branch that went away keeps that state for good.
	//
	// Mark bundles as approved if work_score >= 13150
	_, err = e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET status = 'approved',
		    last_updated_height = ?,
		    status_stamped = 1
		WHERE status = 'pending'
		  AND work_score >= ?
	`, height, m4.MinWorkScore)
	if err != nil {
		return fmt.Errorf("mark approved bundles: %w", err)
	}

	// Mark bundles as failed if blocks_left = 0 and work_score < 13150
	_, err = e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET status = 'failed',
		    last_updated_height = ?,
		    status_stamped = 1
		WHERE status = 'pending'
		  AND blocks_left = 0
		  AND work_score < ?
	`, height, m4.MinWorkScore)
	if err != nil {
		return fmt.Errorf("mark failed bundles: %w", err)
	}

	// Mark bundles as expired if blocks_left = 0 (regardless of score)
	_, err = e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET status = 'expired',
		    last_updated_height = ?,
		    status_stamped = 1
		WHERE status = 'pending'
		  AND blocks_left = 0
	`, height)
	if err != nil {
		return fmt.Errorf("mark expired bundles: %w", err)
	}

	return nil
}

// GetWithdrawalBundles returns active withdrawal bundles for a sidechain
func (e *M4Engine) GetWithdrawalBundles(ctx context.Context, sidechainSlot *uint8) ([]m4.WithdrawalBundle, error) {
	query := `
		SELECT id, sidechain_slot, bundle_hash, work_score, blocks_left,
		       max_age, first_seen_height, last_updated_height, status,
		       created_at, updated_at
		FROM withdrawal_bundles
		WHERE 1=1
	`
	args := []interface{}{}

	if sidechainSlot != nil {
		query += " AND sidechain_slot = ?"
		args = append(args, *sidechainSlot)
	}

	query += " ORDER BY sidechain_slot, first_seen_height"

	rows, err := e.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bundles []m4.WithdrawalBundle
	for rows.Next() {
		var b m4.WithdrawalBundle
		err := rows.Scan(
			&b.ID, &b.SidechainSlot, &b.BundleHash, &b.WorkScore, &b.BlocksLeft,
			&b.MaxAge, &b.FirstSeenHeight, &b.LastUpdatedHeight, &b.Status,
			&b.CreatedAt, &b.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		bundles = append(bundles, b)
	}

	return bundles, rows.Err()
}
