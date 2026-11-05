package deniability

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

type PendingExecution struct {
	DenialID     int64     `db:"denial_id"`
	FromTxID     string    `db:"from_txid"`
	FromVout     int32     `db:"from_vout"`
	ToTxID       string    `db:"to_txid"`
	AddressJSON  string    `db:"destinations"`
	CreatedAt    time.Time `db:"created_at"`
	Destinations map[string]uint64
}

func GetPending(ctx context.Context, db database.Querier, denialID int64) (*PendingExecution, error) {
	pending, err := database.Get[PendingExecution](ctx, db, `
		SELECT denial_id, from_txid, from_vout, to_txid, destinations, created_at
		FROM denial_pending WHERE denial_id = ?
	`, denialID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("read pending denial: %w", err)
	}
	if err := json.Unmarshal([]byte(pending.AddressJSON), &pending.Destinations); err != nil {
		return nil, fmt.Errorf("read pending destinations: %w", err)
	}
	return &pending, nil
}

func SavePending(ctx context.Context, db *sql.DB, denialID int64, fromTxID string, fromVout int32, toTxID string, destinations map[string]uint64) error {
	data, err := json.Marshal(destinations)
	if err != nil {
		return fmt.Errorf("encode denial destinations: %w", err)
	}
	if _, err := db.ExecContext(ctx, `
		INSERT INTO denial_pending (denial_id, from_txid, from_vout, to_txid, destinations, created_at)
		VALUES (?, ?, ?, ?, ?, ?)
	`, denialID, fromTxID, fromVout, toTxID, string(data), time.Now()); err != nil {
		return fmt.Errorf("save pending denial: %w", err)
	}
	return nil
}

func CompletePending(ctx context.Context, db *sql.DB, denialID int64, vouts []uint32) error {
	if len(vouts) == 0 {
		return errors.New("pending denial has no output")
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin denial completion: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)
	pending, err := GetPending(ctx, tx, denialID)
	if err != nil {
		return err
	}
	if pending == nil {
		return ErrNotFound
	}
	for _, vout := range vouts {
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO executed_denials (denial_id, from_txid, from_vout, to_txid, to_vout, created_at)
			VALUES (?, ?, ?, ?, ?, ?)
		`, denialID, pending.FromTxID, pending.FromVout, pending.ToTxID, vout, pending.CreatedAt); err != nil {
			return fmt.Errorf("record denial output: %w", err)
		}
	}
	if _, err := tx.ExecContext(ctx, `DELETE FROM denial_pending WHERE denial_id = ?`, denialID); err != nil {
		return fmt.Errorf("delete pending denial: %w", err)
	}
	return tx.Commit()
}

// CancelPending cancels a denial and drops its pending hop in one transaction.
func CancelPending(ctx context.Context, db *sql.DB, denialID int64, reason string) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin pending denial cancel: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)
	if err := database.CheckOne(tx.ExecContext(ctx, `DELETE FROM denial_pending WHERE denial_id = ?`, denialID)); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNotFound
		}
		return fmt.Errorf("delete pending denial: %w", err)
	}
	if err := database.CheckOne(tx.ExecContext(ctx, `
		UPDATE denials SET cancelled_at = ?, cancelled_reason = ? WHERE id = ?
	`, time.Now(), reason, denialID)); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNotFound
		}
		return fmt.Errorf("cancel pending denial: %w", err)
	}
	return tx.Commit()
}
