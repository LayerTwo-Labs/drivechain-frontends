package wallet

import (
	"fmt"
	"sync"
)

// SyncPhase is the coarse stage of an electrum wallet scan, for the GUI.
type SyncPhase string

const (
	SyncIdle     SyncPhase = "idle"     // no scan running
	SyncScanning SyncPhase = "scanning" // walking a derivation chain
	SyncDone     SyncPhase = "done"     // a scan just finished
)

// SyncProgress describes what a wallet's scan is doing right now, so the GUI can
// show a meaningful status instead of an opaque spinner.
type SyncProgress struct {
	Scanning bool      // a scan is in progress
	Phase    SyncPhase // coarse stage
	Chain    string    // "external" or "change" while scanning
	Scanned  int       // addresses checked so far this scan
	Found    int       // used addresses found so far this scan
	Message  string    // human-readable description of the current step
}

// syncReporter holds the latest scan progress per wallet and fans updates out to
// any subscribers (the WatchWalletSync stream). Publishes never block: a slow
// subscriber simply misses intermediate frames and catches up on the next one.
type syncReporter struct {
	mu     sync.Mutex
	latest map[string]SyncProgress
	subs   map[string]map[int]chan SyncProgress
	nextID int
}

func newSyncReporter() *syncReporter {
	return &syncReporter{
		latest: make(map[string]SyncProgress),
		subs:   make(map[string]map[int]chan SyncProgress),
	}
}

func (r *syncReporter) publish(walletID string, p SyncProgress) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.latest[walletID] = p
	for _, ch := range r.subs[walletID] {
		select {
		case ch <- p:
		default:
		}
	}
}

// snapshot returns the latest known progress for a wallet (idle if none yet).
func (r *syncReporter) snapshot(walletID string) SyncProgress {
	r.mu.Lock()
	defer r.mu.Unlock()
	if p, ok := r.latest[walletID]; ok {
		return p
	}
	return SyncProgress{Phase: SyncIdle, Message: "Idle"}
}

// subscribe registers a channel for a wallet's progress, seeded with the latest
// snapshot, and returns an unsubscribe func.
func (r *syncReporter) subscribe(walletID string) (<-chan SyncProgress, func()) {
	r.mu.Lock()
	defer r.mu.Unlock()
	id := r.nextID
	r.nextID++
	ch := make(chan SyncProgress, 32)
	if r.subs[walletID] == nil {
		r.subs[walletID] = make(map[int]chan SyncProgress)
	}
	r.subs[walletID][id] = ch
	if p, ok := r.latest[walletID]; ok {
		ch <- p
	}
	return ch, func() {
		r.mu.Lock()
		defer r.mu.Unlock()
		if m := r.subs[walletID]; m != nil {
			if c, ok := m[id]; ok {
				close(c)
				delete(m, id)
			}
		}
	}
}

// scanProgress builds the descriptive message for a mid-scan frame.
func scanProgress(chain string, scanned, found int) SyncProgress {
	return SyncProgress{
		Scanning: true,
		Phase:    SyncScanning,
		Chain:    chain,
		Scanned:  scanned,
		Found:    found,
		Message:  fmt.Sprintf("Scanning %s addresses — %d checked, %d used", chain, scanned, found),
	}
}
