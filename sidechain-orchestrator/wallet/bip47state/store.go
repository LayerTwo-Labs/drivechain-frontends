// Package bip47state persists the per-recipient BIP47 send state (notification
// txid, next per-payment derivation index) used by the orchestrator's send
// path. State is keyed on (walletID, recipientCode) and survives restarts.
//
// This duplicates the schema defined by bitwindow's
// migrations/034_bip47_send_state.sql and the contract of
// bitwindow/server/models/bip47/store.go. The orchestrator runs in its own
// binary with no SQLite dependency (see CLAUDE.md "no new external deps"
// constraint), so this store backs the same shape with a JSON file in the
// orchestrator's bitwindow dir.
package bip47state

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"
)

const fileName = "bip47_send_state.json"

type State struct {
	WalletID                string     `json:"wallet_id"`
	RecipientCode           string     `json:"recipient_payment_code"`
	NotificationTxID        *string    `json:"notification_txid,omitempty"`
	NotificationBroadcastAt *time.Time `json:"notification_broadcast_at,omitempty"`
	NextSendIndex           uint32     `json:"next_send_index"`
	LastUsedAt              time.Time  `json:"last_used_at"`
}

type Store struct {
	path string

	mu     sync.Mutex
	loaded bool
	rows   map[string]*State // key = walletID + "\x00" + recipientCode
}

func NewStore(dir string) *Store {
	return &Store{
		path: filepath.Join(dir, fileName),
		rows: make(map[string]*State),
	}
}

func key(walletID, recipientCode string) string {
	return walletID + "\x00" + recipientCode
}

func (s *Store) ensureLoadedLocked() error {
	if s.loaded {
		return nil
	}
	data, err := os.ReadFile(s.path)
	switch {
	case errors.Is(err, os.ErrNotExist):
		s.loaded = true
		return nil
	case err != nil:
		return fmt.Errorf("read bip47 state: %w", err)
	}
	var rows []*State
	if err := json.Unmarshal(data, &rows); err != nil {
		return fmt.Errorf("decode bip47 state: %w", err)
	}
	for _, r := range rows {
		s.rows[key(r.WalletID, r.RecipientCode)] = r
	}
	s.loaded = true
	return nil
}

func (s *Store) flushLocked() error {
	rows := make([]*State, 0, len(s.rows))
	for _, r := range s.rows {
		rows = append(rows, r)
	}
	data, err := json.MarshalIndent(rows, "", "  ")
	if err != nil {
		return fmt.Errorf("encode bip47 state: %w", err)
	}
	tmp := s.path + ".tmp"
	if err := os.WriteFile(tmp, data, 0600); err != nil {
		return fmt.Errorf("write bip47 state tmp: %w", err)
	}
	if err := os.Rename(tmp, s.path); err != nil {
		return fmt.Errorf("rename bip47 state: %w", err)
	}
	return nil
}

func (s *Store) GetState(walletID, recipientCode string) (*State, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return nil, err
	}
	r, ok := s.rows[key(walletID, recipientCode)]
	if !ok {
		return nil, nil
	}
	cp := *r
	if r.NotificationTxID != nil {
		v := *r.NotificationTxID
		cp.NotificationTxID = &v
	}
	if r.NotificationBroadcastAt != nil {
		v := *r.NotificationBroadcastAt
		cp.NotificationBroadcastAt = &v
	}
	return &cp, nil
}

func (s *Store) MarkNotified(walletID, recipientCode, txid string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return err
	}
	now := time.Now()
	k := key(walletID, recipientCode)
	r, ok := s.rows[k]
	if !ok {
		r = &State{
			WalletID:      walletID,
			RecipientCode: recipientCode,
		}
		s.rows[k] = r
	}
	r.NotificationTxID = &txid
	r.NotificationBroadcastAt = &now
	r.LastUsedAt = now
	return s.flushLocked()
}

// ReserveNextIndex atomically returns the next send index for this
// (walletID, recipientCode) and advances the counter. Concurrent callers see
// distinct indices.
func (s *Store) ReserveNextIndex(walletID, recipientCode string) (uint32, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return 0, err
	}
	k := key(walletID, recipientCode)
	r, ok := s.rows[k]
	if !ok {
		r = &State{
			WalletID:      walletID,
			RecipientCode: recipientCode,
		}
		s.rows[k] = r
	}
	idx := r.NextSendIndex
	r.NextSendIndex = idx + 1
	r.LastUsedAt = time.Now()
	if err := s.flushLocked(); err != nil {
		// Roll back the in-memory bump so the disk and memory views stay in
		// sync after a flush failure.
		r.NextSendIndex = idx
		return 0, err
	}
	return idx, nil
}
