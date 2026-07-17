package transactions

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"connectrpc.com/connect"
)

type TransactionNote struct {
	TxID  string
	Note  string
	SetAt time.Time
}

func Get(ctx context.Context, db *sql.DB, walletID string, txid string) (TransactionNote, error) {
	var note TransactionNote
	err := db.QueryRowContext(ctx, `SELECT txid, note, set_at FROM transaction_notes WHERE wallet_id = ? AND txid = ?`, walletID, txid).
		Scan(&note.TxID, &note.Note, &note.SetAt)
	if err != nil {
		return TransactionNote{}, err
	}

	return note, nil
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

func SetNote(ctx context.Context, db *sql.DB, walletID string, txid string, note string) error {
	if walletID == "" {
		return connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("wallet id cannot be empty"))
	}
	if txid == "" {
		return connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("txid cannot be empty"))
	}

	_, err := db.ExecContext(ctx, `
		INSERT INTO transaction_notes (wallet_id, txid, note)
		VALUES (?, ?, ?)
		ON CONFLICT(wallet_id, txid) DO UPDATE SET note = ?, set_at = CURRENT_TIMESTAMP`,
		walletID, txid, note, note)
	return err
}
