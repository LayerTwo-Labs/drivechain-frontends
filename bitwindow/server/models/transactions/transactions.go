package transactions

import (
	"context"
	"database/sql"
	"errors"
	"time"
)

type TransactionNote struct {
	TxID  string
	Note  string
	SetAt time.Time
}

func ListByWallet(ctx context.Context, db *sql.DB, walletID string) ([]TransactionNote, error) {
	rows, err := db.QueryContext(ctx, `SELECT txid, note, set_at FROM transaction_notes WHERE wallet_id = ?`, walletID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var notes []TransactionNote
	for rows.Next() {
		var note TransactionNote
		err := rows.Scan(&note.TxID, &note.Note, &note.SetAt)
		if err != nil {
			return nil, err
		}

		notes = append(notes, note)
	}
	return notes, rows.Err()
}

// ErrEmptyTxID is the SetNote error for an empty txid.
var ErrEmptyTxID = errors.New("txid cannot be empty")

func SetNote(ctx context.Context, db *sql.DB, walletID string, txid string, note string) error {
	if walletID == "" {
		panic("transactions: SetNote called with an empty wallet id")
	}
	if txid == "" {
		return ErrEmptyTxID
	}

	_, err := db.ExecContext(ctx, `
		INSERT INTO transaction_notes (wallet_id, txid, note)
		VALUES (?, ?, ?)
		ON CONFLICT(wallet_id, txid) DO UPDATE SET note = ?, set_at = CURRENT_TIMESTAMP`,
		walletID, txid, note, note)
	return err
}
