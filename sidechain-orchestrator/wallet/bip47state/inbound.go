package bip47state

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"sync"
	"time"
)

const inboundFileName = "bip47_inbound_state.json"

// InboundNotification records that a remote sender has notified this wallet of
// its intent to make BIP47 payments. The engine derives per-payment addresses
// from this entry's SenderPaymentCode and imports them into Core; future scans
// extend the imported window as activity is observed.
type InboundNotification struct {
	WalletID              string `json:"wallet_id"`
	SenderPaymentCode     string `json:"sender_payment_code"`
	FirstNotificationTxID string `json:"first_notification_txid"`
	// FirstSeenHeight is 0 for unconfirmed notification txs.
	FirstSeenHeight int32 `json:"first_seen_height"`
	// FirstSeenBlockTime is unix seconds of the notification tx's block, or 0
	// when unconfirmed. Used to pick a sensible rescan timestamp when
	// importing per-payment descriptors so Core doesn't rescan further back
	// than necessary.
	FirstSeenBlockTime   int64     `json:"first_seen_block_time"`
	ImportedThroughIndex uint32    `json:"imported_through_index"`
	LastUpdatedAt        time.Time `json:"last_updated_at"`
}

// InboundStore persists per-wallet BIP47 receive state to a JSON file. Sits
// alongside the outbound Store (this package). Separate file so the two
// histories evolve independently and never collide on schema.
type InboundStore struct {
	path string

	mu      sync.Mutex
	loaded  bool
	rows    map[string]*InboundNotification
	cursors map[string]int
}

// inboundFile is the on-disk shape.
type inboundFile struct {
	Inbound     []*InboundNotification `json:"inbound"`
	ScanCursors map[string]int         `json:"scan_cursors"`
}

func NewInboundStore(dir string) *InboundStore {
	return &InboundStore{
		path:    filepath.Join(dir, inboundFileName),
		rows:    make(map[string]*InboundNotification),
		cursors: make(map[string]int),
	}
}

func inboundKey(walletID, senderCode string) string {
	return walletID + "\x00" + senderCode
}

func (s *InboundStore) ensureLoadedLocked() error {
	if s.loaded {
		return nil
	}
	data, err := os.ReadFile(s.path)
	switch {
	case errors.Is(err, os.ErrNotExist):
		s.loaded = true
		return nil
	case err != nil:
		return fmt.Errorf("read bip47 inbound state: %w", err)
	}
	var file inboundFile
	if err := json.Unmarshal(data, &file); err != nil {
		return fmt.Errorf("decode bip47 inbound state: %w", err)
	}
	for _, r := range file.Inbound {
		s.rows[inboundKey(r.WalletID, r.SenderPaymentCode)] = r
	}
	if file.ScanCursors != nil {
		s.cursors = file.ScanCursors
	}
	s.loaded = true
	return nil
}

func (s *InboundStore) flushLocked() error {
	rows := make([]*InboundNotification, 0, len(s.rows))
	for _, r := range s.rows {
		rows = append(rows, r)
	}
	// Stable ordering on disk — easier to inspect, no behavioural reason.
	sort.Slice(rows, func(i, j int) bool {
		if rows[i].WalletID != rows[j].WalletID {
			return rows[i].WalletID < rows[j].WalletID
		}
		return rows[i].SenderPaymentCode < rows[j].SenderPaymentCode
	})
	data, err := json.MarshalIndent(inboundFile{
		Inbound:     rows,
		ScanCursors: s.cursors,
	}, "", "  ")
	if err != nil {
		return fmt.Errorf("encode bip47 inbound state: %w", err)
	}
	tmp := s.path + ".tmp"
	if err := os.WriteFile(tmp, data, 0600); err != nil {
		return fmt.Errorf("write bip47 inbound state tmp: %w", err)
	}
	if err := os.Rename(tmp, s.path); err != nil {
		return fmt.Errorf("rename bip47 inbound state: %w", err)
	}
	return nil
}

// RecordInbound inserts a new inbound notification record if one doesn't
// already exist for (walletID, senderCode). If a record exists, leaves it
// untouched (the first notification is the load-bearing one).
func (s *InboundStore) RecordInbound(walletID, senderCode, txid string, height int32, blockTime int64) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return err
	}
	k := inboundKey(walletID, senderCode)
	if _, exists := s.rows[k]; exists {
		return nil
	}
	now := time.Now()
	s.rows[k] = &InboundNotification{
		WalletID:              walletID,
		SenderPaymentCode:     senderCode,
		FirstNotificationTxID: txid,
		FirstSeenHeight:       height,
		FirstSeenBlockTime:    blockTime,
		ImportedThroughIndex:  0,
		LastUpdatedAt:         now,
	}
	return s.flushLocked()
}

func (s *InboundStore) Get(walletID, senderCode string) (*InboundNotification, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return nil, err
	}
	r, ok := s.rows[inboundKey(walletID, senderCode)]
	if !ok {
		return nil, nil
	}
	cp := *r
	return &cp, nil
}

// BumpImportedIndex raises ImportedThroughIndex to newIdx if newIdx is greater
// than the current value. No-op when newIdx is not an advance.
func (s *InboundStore) BumpImportedIndex(walletID, senderCode string, newIdx uint32) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return err
	}
	r, ok := s.rows[inboundKey(walletID, senderCode)]
	if !ok {
		return fmt.Errorf("no inbound state for (%s,%s)", walletID, senderCode)
	}
	if newIdx <= r.ImportedThroughIndex {
		return nil
	}
	r.ImportedThroughIndex = newIdx
	r.LastUpdatedAt = time.Now()
	return s.flushLocked()
}

func (s *InboundStore) ListByWallet(walletID string) ([]*InboundNotification, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return nil, err
	}
	var out []*InboundNotification
	for _, r := range s.rows {
		if r.WalletID != walletID {
			continue
		}
		cp := *r
		out = append(out, &cp)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].SenderPaymentCode < out[j].SenderPaymentCode })
	return out, nil
}

// ScanCursor returns the listtransactions skip-count for this wallet.
func (s *InboundStore) ScanCursor(walletID string) (int, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return 0, err
	}
	return s.cursors[walletID], nil
}

func (s *InboundStore) SetScanCursor(walletID string, n int) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return err
	}
	if s.cursors[walletID] == n {
		return nil
	}
	s.cursors[walletID] = n
	return s.flushLocked()
}
