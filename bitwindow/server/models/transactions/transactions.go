package transactions

import (
	"context"
	"database/sql"
	"time"
)

type TransactionNote struct {
	TxID  string
	Note  string
	SetAt time.Time
}

func Get(ctx context.Context, db *sql.DB, txid string) (TransactionNote, error) {
	var note TransactionNote
	err := db.QueryRowContext(ctx, `SELECT txid, note, set_at FROM transaction_notes WHERE txid = ?`, txid).
		Scan(&note.TxID, &note.Note, &note.SetAt)
	if err != nil {
		return TransactionNote{}, err
	}

	return note, nil
}

func List(ctx context.Context, db *sql.DB) ([]TransactionNote, error) {
	rows, err := db.QueryContext(ctx, `SELECT txid, note, set_at FROM transaction_notes`)
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

func SetNote(ctx context.Context, db *sql.DB, txid string, note string) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO transaction_notes (txid, note) 
		VALUES (?, ?)
		ON CONFLICT(txid) DO UPDATE SET note = ?, set_at = CURRENT_TIMESTAMP`,
		txid, note, note)
	return err
}
