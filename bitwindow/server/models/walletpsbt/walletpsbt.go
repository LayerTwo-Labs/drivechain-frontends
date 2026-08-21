package walletpsbt

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"fmt"
	"time"
)

// Draft is an in-progress multisig spend. The PSBT blob carries the
// signatures; nothing else about signing state is stored.
type Draft struct {
	ID         string
	WalletID   string
	Label      string
	PSBTBase64 string
	CreatedAt  int64 // unix milliseconds
	UpdatedAt  int64
	Txid       string
}

// Store provides DB access for wallet PSBT drafts.
type Store struct {
	db *sql.DB

	// now is replaceable in tests.
	now func() time.Time
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db, now: time.Now}
}

// SetClock replaces the store's clock. Test use only.
func (s *Store) SetClock(now func() time.Time) {
	s.now = now
}

func (s *Store) List(ctx context.Context, walletID string) ([]Draft, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT id, wallet_id, label, psbt_base64, created_at, updated_at, txid
		FROM wallet_psbt_drafts WHERE wallet_id = ? ORDER BY created_at ASC`, walletID)
	if err != nil {
		return nil, fmt.Errorf("list drafts: %w", err)
	}
	defer rows.Close()

	var drafts []Draft
	for rows.Next() {
		var d Draft
		if err := rows.Scan(&d.ID, &d.WalletID, &d.Label, &d.PSBTBase64,
			&d.CreatedAt, &d.UpdatedAt, &d.Txid); err != nil {
			return nil, fmt.Errorf("scan draft: %w", err)
		}
		drafts = append(drafts, d)
	}
	return drafts, rows.Err()
}

// Save inserts the draft, or replaces it when the id exists. An empty id
// gets a server-generated one. Timestamps are set here, never by the caller.
func (s *Store) Save(ctx context.Context, d Draft) (Draft, error) {
	if d.WalletID == "" {
		return Draft{}, fmt.Errorf("wallet id is required")
	}

	nowMs := s.now().UnixMilli()
	if d.ID == "" {
		id, err := newID()
		if err != nil {
			return Draft{}, err
		}
		d.ID = id
		d.CreatedAt = nowMs
	}
	d.UpdatedAt = nowMs

	_, err := s.db.ExecContext(ctx, `
		INSERT INTO wallet_psbt_drafts (id, wallet_id, label, psbt_base64, created_at, updated_at, txid)
		VALUES (?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT(id) DO UPDATE SET
		    wallet_id=excluded.wallet_id, label=excluded.label,
		    psbt_base64=excluded.psbt_base64, updated_at=excluded.updated_at,
		    txid=excluded.txid`,
		d.ID, d.WalletID, d.Label, d.PSBTBase64, d.CreatedAt, d.UpdatedAt, d.Txid)
	if err != nil {
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
	var d Draft
	err := s.db.QueryRowContext(ctx, `
		SELECT id, wallet_id, label, psbt_base64, created_at, updated_at, txid
		FROM wallet_psbt_drafts WHERE id = ?`, id).
		Scan(&d.ID, &d.WalletID, &d.Label, &d.PSBTBase64, &d.CreatedAt, &d.UpdatedAt, &d.Txid)
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
