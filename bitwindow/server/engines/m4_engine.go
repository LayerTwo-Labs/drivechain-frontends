package engines

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
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

// ProcessBlock processes a block for M3/M4 messages and updates SCDB state
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

		// Apply M4 votes to update bundle work scores
		if err := e.applyM4Votes(ctx, height, m4Msg); err != nil {
			log.Warn().Err(err).Msg("failed to apply M4 votes")
		}

		log.Debug().
			Int("votes", len(m4Msg.Votes)).
			Uint8("version", m4Msg.Version).
			Msg("processed M4 message")
	}

	// Update all bundle states (decrement blocks_left, check expiration)
	if err := e.updateBundleStates(ctx); err != nil {
		log.Warn().Err(err).Msg("failed to update bundle states")
	}

	return nil
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

// persistM4Message stores an M4 message and its votes in the database
func (e *M4Engine) persistM4Message(ctx context.Context, msg *m4.M4Message) error {
	tx, err := e.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	// Insert M4 message
	result, err := tx.ExecContext(ctx, `
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

	msgID, err := result.LastInsertId()
	if err != nil {
		// On conflict, we need to get the existing ID
		row := tx.QueryRowContext(ctx, `
			SELECT id FROM m4_messages WHERE block_height = ? AND block_hash = ?
		`, msg.BlockHeight, msg.BlockHash)
		if err := row.Scan(&msgID); err != nil {
			return fmt.Errorf("get M4 message ID: %w", err)
		}
	}

	// Delete old votes for this message (in case of reorg)
	_, err = tx.ExecContext(ctx, `DELETE FROM m4_votes WHERE m4_message_id = ?`, msgID)
	if err != nil {
		return fmt.Errorf("delete old votes: %w", err)
	}

	// Insert votes
	for _, vote := range msg.Votes {
		var bundleHash *string
		var bundleIndex *uint16

		if vote.VoteType == m4.VoteTypeUpvote {
			bundleIndex = vote.BundleIndex
		}

		_, err := tx.ExecContext(ctx, `
			INSERT INTO m4_votes (
				m4_message_id, sidechain_slot, vote_type, bundle_hash, bundle_index
			) VALUES (?, ?, ?, ?, ?)
		`, msgID, vote.SidechainSlot, vote.VoteType, bundleHash, bundleIndex)
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

		// Load votes for this message
		votes, err := e.getVotesForMessage(ctx, msg.ID)
		if err != nil {
			return nil, fmt.Errorf("get votes for message %d: %w", msg.ID, err)
		}
		msg.Votes = votes

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
				_, err := e.db.ExecContext(ctx, `
					UPDATE withdrawal_bundles
					SET work_score = work_score + 1,
					    last_updated_height = ?,
					    updated_at = CURRENT_TIMESTAMP
					WHERE sidechain_slot = ?
					  AND status = 'pending'
					ORDER BY first_seen_height ASC
					LIMIT 1 OFFSET ?
				`, height, vote.SidechainSlot, *vote.BundleIndex)
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
			`, height, vote.SidechainSlot)
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
			`, height, vote.SidechainSlot)
			if err != nil {
				return fmt.Errorf("abstain (no-op) on bundles: %w", err)
			}
		}
	}

	return nil
}

// updateBundleStates decrements blocks_left and updates status for all pending bundles
func (e *M4Engine) updateBundleStates(ctx context.Context) error {
	// Decrement blocks_left for all pending bundles
	_, err := e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET blocks_left = blocks_left - 1,
		    updated_at = CURRENT_TIMESTAMP
		WHERE status = 'pending'
		  AND blocks_left > 0
	`)
	if err != nil {
		return fmt.Errorf("decrement blocks_left: %w", err)
	}

	// Mark bundles as approved if work_score >= 13150
	_, err = e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET status = 'approved'
		WHERE status = 'pending'
		  AND work_score >= ?
	`, m4.MinWorkScore)
	if err != nil {
		return fmt.Errorf("mark approved bundles: %w", err)
	}

	// Mark bundles as failed if blocks_left = 0 and work_score < 13150
	_, err = e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET status = 'failed'
		WHERE status = 'pending'
		  AND blocks_left = 0
		  AND work_score < ?
	`, m4.MinWorkScore)
	if err != nil {
		return fmt.Errorf("mark failed bundles: %w", err)
	}

	// Mark bundles as expired if blocks_left = 0 (regardless of score)
	_, err = e.db.ExecContext(ctx, `
		UPDATE withdrawal_bundles
		SET status = 'expired'
		WHERE status = 'pending'
		  AND blocks_left = 0
	`)
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
