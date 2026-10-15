package transactions

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

type TransactionNote struct {
	TxID  string    `db:"txid"`
	Note  string    `db:"note"`
	SetAt time.Time `db:"set_at"`
}

func ListByWallet(ctx context.Context, db *sql.DB, walletID string) ([]TransactionNote, error) {
	return database.Select[TransactionNote](ctx, db, `SELECT txid, note, set_at FROM transaction_notes WHERE wallet_id = ?`, walletID)
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
