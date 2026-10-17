package walletpsbt

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

// Draft is an in-progress multisig spend. The PSBT blob holds the
// signatures; nothing else about signing state is stored.
type Draft struct {
	ID         string `db:"id"`
	WalletID   string `db:"wallet_id"`
	Label      string `db:"label"`
	PSBTBase64 string `db:"psbt_base64"`
	CreatedAt  int64  `db:"created_at"` // unix milliseconds
	UpdatedAt  int64  `db:"updated_at"`
	Txid       string `db:"txid"`
}

// Store provides DB access for wallet PSBT drafts.
type Store struct {
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db}
}

func (s *Store) List(ctx context.Context, walletID string) ([]Draft, error) {
	drafts, err := database.Select[Draft](ctx, s.db, `
		SELECT id, wallet_id, label, psbt_base64, created_at, updated_at, txid
		FROM wallet_psbt_drafts WHERE wallet_id = ? ORDER BY created_at ASC`, walletID)
	if err != nil {
		return nil, fmt.Errorf("list drafts: %w", err)
	}
	return drafts, nil
}

// ErrOtherWallet is returned when a save names the id of a draft of another wallet.
var ErrOtherWallet = errors.New("draft belongs to another wallet")

// Save inserts the draft, or replaces it when the id exists in the same
// wallet. An empty id gets a server-generated one. Timestamps are set here,
// never by the caller.
func (s *Store) Save(ctx context.Context, d Draft) (Draft, error) {
	if d.WalletID == "" {
		return Draft{}, errors.New("wallet id is required")
	}

	if d.ID == "" {
		id, err := newID()
		if err != nil {
			return Draft{}, err
		}
		d.ID = id
	}

	nowMs := time.Now().UnixMilli()
	err := database.CheckOne(s.db.ExecContext(ctx, `
		INSERT INTO wallet_psbt_drafts (id, wallet_id, label, psbt_base64, created_at, updated_at, txid)
		VALUES (?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT(id) DO UPDATE SET
		    label=excluded.label, psbt_base64=excluded.psbt_base64,
		    updated_at=excluded.updated_at, txid=excluded.txid
		WHERE wallet_psbt_drafts.wallet_id = excluded.wallet_id`,
		d.ID, d.WalletID, d.Label, d.PSBTBase64, nowMs, nowMs, d.Txid))
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return Draft{}, fmt.Errorf("save draft %s: %w", d.ID, ErrOtherWallet)
	case err != nil:
		return Draft{}, fmt.Errorf("save draft: %w", err)
	}

	saved, err := s.get(ctx, d.ID)
	if err != nil {
		return Draft{}, err
	}
	return *saved, nil
}

func (s *Store) Delete(ctx context.Context, id string) error {
	if _, err := s.db.ExecContext(ctx, `DELETE FROM wallet_psbt_drafts WHERE id = ?`, id); err != nil {
		return fmt.Errorf("delete draft: %w", err)
	}
	return nil
}

func (s *Store) get(ctx context.Context, id string) (*Draft, error) {
	d, err := database.Get[Draft](ctx, s.db, `
		SELECT id, wallet_id, label, psbt_base64, created_at, updated_at, txid
		FROM wallet_psbt_drafts WHERE id = ?`, id)
	if err != nil {
		return nil, fmt.Errorf("get draft %s: %w", id, err)
	}
	return &d, nil
}

func newID() (string, error) {
	buf := make([]byte, 8)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("generate draft id: %w", err)
	}
	return hex.EncodeToString(buf), nil
}
