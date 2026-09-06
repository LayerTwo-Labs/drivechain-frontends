// Package bmmstate persists finished BMM rounds. A losing bid never confirms
// and leaves the mempool, so competitors are only knowable from what we saw.
package bmmstate

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sync"
)

const fileName = "bmm_rounds.json"

const targetsFileName = "bmm_targets.json"

// Bid is one M8 broadcast for a round.
type Bid struct {
	Txid           string `json:"txid"`
	CriticalHash   string `json:"critical_hash"`
	BidSats        int64  `json:"bid_sats"`
	IsOurs         bool   `json:"is_ours"`
	ReplacedByTxid string `json:"replaced_by_txid,omitempty"`
	State          string `json:"state,omitempty"`
	PrevMainHash   string `json:"prev_main_hash,omitempty"`
	Error          string `json:"error,omitempty"`
	BlockJSON      string `json:"block_json,omitempty"`
	// WalletID funded the bid. A raise replaces its inputs, so it can only be
	// funded by the same wallet.
	WalletID string `json:"wallet_id,omitempty"`
}

// Round is one mainchain tip and everything that competed for it.
type Round struct {
	Sidechain          int32  `json:"sidechain"`
	PrevMainHash       string `json:"prev_main_hash"`
	PrevMainHeight     int32  `json:"prev_main_height"`
	Result             string `json:"result"`
	BlockWorthSats     int64  `json:"block_worth_sats"`
	OurBids            []Bid  `json:"our_bids,omitempty"`
	OtherBids          []Bid  `json:"other_bids,omitempty"`
	WinnerCriticalHash string `json:"winner_critical_hash,omitempty"`
	WinnerTxid         string `json:"winner_txid,omitempty"`
	WinnerBidSats      int64  `json:"winner_bid_sats,omitempty"`
	IncludedInBlock    string `json:"included_in_block,omitempty"`
	IncludedInHeight   int32  `json:"included_in_height,omitempty"`
	StartedAtUnix      int64  `json:"started_at_unix"`
	BlocksWaited       int    `json:"blocks_waited,omitempty"`
}

// Target is what the engine bids for on one sidechain. It outlives the
// process, so a restart resumes bidding rather than stopping it silently.
type Target struct {
	Sidechain       int32  `json:"sidechain"`
	WalletID        string `json:"wallet_id,omitempty"`
	MaxBidSats      int64  `json:"max_bid_sats"`
	CapToBlockWorth bool   `json:"cap_to_block_worth,omitempty"`
}

// Store keeps rounds in a JSON file, newest first, capped at limit. It keeps
// the bidding targets in a second file beside them.
type Store struct {
	path        string
	targetsPath string
	limit       int

	mu            sync.Mutex
	loaded        bool
	rounds        []Round
	targetsLoaded bool
	targets       []Target
}

func NewStore(dir string, limit int) *Store {
	if limit <= 0 {
		limit = 500
	}
	return &Store{
		path:        filepath.Join(dir, fileName),
		targetsPath: filepath.Join(dir, targetsFileName),
		limit:       limit,
	}
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
		return fmt.Errorf("read bmm rounds: %w", err)
	}
	if err := json.Unmarshal(data, &s.rounds); err != nil {
		return fmt.Errorf("decode bmm rounds: %w", err)
	}
	s.loaded = true
	return nil
}

func (s *Store) flushLocked() error {
	data, err := json.MarshalIndent(s.rounds, "", "  ")
	if err != nil {
		return fmt.Errorf("encode bmm rounds: %w", err)
	}
	tmp := s.path + ".tmp"
	if err := os.WriteFile(tmp, data, 0600); err != nil {
		return fmt.Errorf("write bmm rounds tmp: %w", err)
	}
	if err := os.Rename(tmp, s.path); err != nil {
		return fmt.Errorf("rename bmm rounds: %w", err)
	}
	return nil
}

// clone deep-copies a round, so a caller can never mutate stored slices.
func clone(r Round) Round {
	out := r
	out.OurBids = append([]Bid(nil), r.OurBids...)
	out.OtherBids = append([]Bid(nil), r.OtherBids...)
	return out
}

// Save inserts or replaces a round, keyed on sidechain and prev_main_hash.
func (s *Store) Save(round Round) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return err
	}

	stored := clone(round)
	for i, r := range s.rounds {
		if r.Sidechain == round.Sidechain && r.PrevMainHash == round.PrevMainHash {
			s.rounds[i] = stored
			return s.flushLocked()
		}
	}

	s.rounds = append([]Round{stored}, s.rounds...)
	if len(s.rounds) > s.limit {
		s.rounds = s.rounds[:s.limit]
	}
	return s.flushLocked()
}

// List returns a sidechain's rounds, newest first.
func (s *Store) List(sidechain int32) ([]Round, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return nil, err
	}

	out := make([]Round, 0, len(s.rounds))
	for _, r := range s.rounds {
		if r.Sidechain == sidechain {
			out = append(out, clone(r))
		}
	}
	return out, nil
}

// All returns every stored round, newest first.
func (s *Store) All() ([]Round, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return nil, err
	}
	out := make([]Round, 0, len(s.rounds))
	for _, r := range s.rounds {
		out = append(out, clone(r))
	}
	return out, nil
}

// Get returns one round, or nil when it is not stored.
func (s *Store) Get(sidechain int32, prevMainHash string) (*Round, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return nil, err
	}

	for _, r := range s.rounds {
		if r.Sidechain == sidechain && r.PrevMainHash == prevMainHash {
			round := clone(r)
			return &round, nil
		}
	}
	return nil, nil
}

// Clear drops a sidechain's rounds. A non-nil keep survives, stored in the
// same write, so a failure never leaves the disk without it.
func (s *Store) Clear(sidechain int32, keep *Round) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureLoadedLocked(); err != nil {
		return err
	}

	kept := make([]Round, 0, len(s.rounds))
	if keep != nil {
		kept = append(kept, clone(*keep))
	}
	for _, r := range s.rounds {
		if r.Sidechain != sidechain {
			kept = append(kept, r)
		}
	}
	s.rounds = kept
	return s.flushLocked()
}

// Rebind points the store at another network's directory, dropping rounds
// loaded from the previous one.
func (s *Store) Rebind(dir string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.path = filepath.Join(dir, fileName)
	s.targetsPath = filepath.Join(dir, targetsFileName)
	s.rounds = nil
	s.loaded = false
	s.targets = nil
	s.targetsLoaded = false
}

func (s *Store) ensureTargetsLoadedLocked() error {
	if s.targetsLoaded {
		return nil
	}
	data, err := os.ReadFile(s.targetsPath)
	switch {
	case errors.Is(err, os.ErrNotExist):
		s.targetsLoaded = true
		return nil
	case err != nil:
		return fmt.Errorf("read bmm targets: %w", err)
	}
	if err := json.Unmarshal(data, &s.targets); err != nil {
		return fmt.Errorf("decode bmm targets: %w", err)
	}
	s.targetsLoaded = true
	return nil
}

func (s *Store) flushTargetsLocked() error {
	data, err := json.MarshalIndent(s.targets, "", "  ")
	if err != nil {
		return fmt.Errorf("encode bmm targets: %w", err)
	}
	tmp := s.targetsPath + ".tmp"
	if err := os.WriteFile(tmp, data, 0600); err != nil {
		return fmt.Errorf("write bmm targets tmp: %w", err)
	}
	if err := os.Rename(tmp, s.targetsPath); err != nil {
		return fmt.Errorf("rename bmm targets: %w", err)
	}
	return nil
}

// SaveTarget inserts or replaces the target for one sidechain.
func (s *Store) SaveTarget(target Target) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureTargetsLoadedLocked(); err != nil {
		return err
	}
	for i := range s.targets {
		if s.targets[i].Sidechain == target.Sidechain {
			s.targets[i] = target
			return s.flushTargetsLocked()
		}
	}
	s.targets = append(s.targets, target)
	return s.flushTargetsLocked()
}

// DeleteTarget drops one sidechain's target, so a restart does not resume it.
func (s *Store) DeleteTarget(sidechain int32) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureTargetsLoadedLocked(); err != nil {
		return err
	}
	kept := make([]Target, 0, len(s.targets))
	for _, t := range s.targets {
		if t.Sidechain != sidechain {
			kept = append(kept, t)
		}
	}
	if len(kept) == len(s.targets) {
		return nil
	}
	s.targets = kept
	return s.flushTargetsLocked()
}

// Targets lists every sidechain the engine bids for.
func (s *Store) Targets() ([]Target, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if err := s.ensureTargetsLoadedLocked(); err != nil {
		return nil, err
	}
	return append([]Target(nil), s.targets...), nil
}
