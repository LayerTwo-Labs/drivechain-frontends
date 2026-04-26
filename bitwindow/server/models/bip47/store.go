package bip47

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"
)

type State struct {
	WalletID                string
	RecipientCode           string
	NotificationTxID        *string
	NotificationBroadcastAt *time.Time
	NextSendIndex           uint32
}

// GetState returns the persisted send state for a (wallet, recipient) pair, or
// nil if no row exists.
func GetState(ctx context.Context, db *sql.DB, walletID, recipientCode string) (*State, error) {
	var s State
	var txid sql.NullString
	var broadcastAt sql.NullTime

	err := db.QueryRowContext(ctx, `
		SELECT wallet_id, recipient_payment_code, notification_txid, notification_broadcast_at, next_send_index
		FROM bip47_send_state
		WHERE wallet_id = ? AND recipient_payment_code = ?
	`, walletID, recipientCode).Scan(&s.WalletID, &s.RecipientCode, &txid, &broadcastAt, &s.NextSendIndex)

	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get bip47 send state: %w", err)
	}

	if txid.Valid {
		s.NotificationTxID = &txid.String
	}
	if broadcastAt.Valid {
		t := broadcastAt.Time
		s.NotificationBroadcastAt = &t
	}

	return &s, nil
}

// MarkNotified records that a notification transaction has been broadcast for
// (walletID, recipientCode). Inserts a row if none exists yet, preserving
// next_send_index from any earlier ReserveNextIndex calls.
func MarkNotified(ctx context.Context, db *sql.DB, walletID, recipientCode, txid string) error {
	now := time.Now()
	_, err := db.ExecContext(ctx, `
		INSERT INTO bip47_send_state (wallet_id, recipient_payment_code, notification_txid, notification_broadcast_at, next_send_index, last_used_at)
		VALUES (?, ?, ?, ?, 0, ?)
		ON CONFLICT(wallet_id, recipient_payment_code) DO UPDATE SET
			notification_txid = excluded.notification_txid,
			notification_broadcast_at = excluded.notification_broadcast_at,
			last_used_at = excluded.last_used_at
	`, walletID, recipientCode, txid, now, now)
	if err != nil {
		return fmt.Errorf("mark bip47 notified: %w", err)
	}
	return nil
}

// ReserveNextIndex atomically returns the next send index for
// (walletID, recipientCode) and advances the counter. Concurrent callers see
// distinct indices; the underlying SQL is a single UPDATE … RETURNING so the
// read-then-write race that would let two callers reuse the same index cannot
// happen.
func ReserveNextIndex(ctx context.Context, db *sql.DB, walletID, recipientCode string) (uint32, error) {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return 0, fmt.Errorf("begin tx: %w", err)
	}
	defer func() { _ = tx.Rollback() }()

	// Insert-if-missing then UPDATE … RETURNING. INSERT OR IGNORE is a no-op
	// when the row already exists, so the subsequent UPDATE is the single
	// authoritative mutation that returns the index claimed by THIS caller.
	if _, err := tx.ExecContext(ctx, `
		INSERT OR IGNORE INTO bip47_send_state (wallet_id, recipient_payment_code, next_send_index, last_used_at)
		VALUES (?, ?, 0, ?)
	`, walletID, recipientCode, time.Now()); err != nil {
		return 0, fmt.Errorf("ensure bip47 send state row: %w", err)
	}

	var reserved uint32
	err = tx.QueryRowContext(ctx, `
		UPDATE bip47_send_state
		SET next_send_index = next_send_index + 1, last_used_at = ?
		WHERE wallet_id = ? AND recipient_payment_code = ?
		RETURNING next_send_index - 1
	`, time.Now(), walletID, recipientCode).Scan(&reserved)
	if err != nil {
		return 0, fmt.Errorf("reserve bip47 send index: %w", err)
	}

	if err := tx.Commit(); err != nil {
		return 0, fmt.Errorf("commit bip47 reserve: %w", err)
	}
	return reserved, nil
}
