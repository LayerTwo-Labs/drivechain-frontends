// Package lease drains a daemon once its live client connections reach zero
// and its owner process is gone. Neither signal is sufficient alone.
package lease

import (
	"context"
	"net"
	"net/http"
	"sync"
	"time"
)

// DefaultGrace lets a frontend close and reopen onto the warm stack.
const DefaultGrace = 15 * time.Second

const (
	// The owner is polled; the connection count is event-driven.
	tick = 2 * time.Second

	// One failed lookup is not a dead process.
	deadStrikes = 2
)

type Lease struct {
	ownerPID int
	grace    time.Duration
	drain    func()

	mu        sync.Mutex
	live      int
	idleFrom  time.Time
	strikes   int
	drained   bool
	waived    bool
	ownerGone bool
}

// New builds a lease over ownerPID. An ownerPID of 0 or less never drains, so
// a daemon started by hand keeps serving whoever shows up.
func New(ownerPID int, grace time.Duration, drain func()) *Lease {
	return &Lease{
		ownerPID: ownerPID,
		grace:    grace,
		drain:    drain,
		idleFrom: time.Now(),
	}
}

// ConnState tracks live client connections. Hang it off http.Server.ConnState.
func (l *Lease) ConnState(_ net.Conn, state http.ConnState) {
	l.mu.Lock()
	switch state {
	case http.StateNew:
		l.live++
		// An arriving client is not covered by an earlier client's goodbye.
		l.waived = false
	case http.StateClosed, http.StateHijacked:
		l.live--
		if l.live <= 0 {
			l.live = 0
			l.idleFrom = time.Now()
		}
	}
	l.mu.Unlock()
}

// Goodbye drops the grace period. A client that says it is leaving is not one
// that might reconnect, so there is nothing left to wait for.
func (l *Lease) Goodbye() {
	l.mu.Lock()
	l.waived = true
	l.mu.Unlock()
}

// Run evaluates until ctx ends or the lease fires.
func (l *Lease) Run(ctx context.Context) {
	if l.ownerPID <= 0 {
		return
	}

	ticker := time.NewTicker(tick)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
		l.pollOwner()
		if l.expired() {
			l.fire()
			return
		}
	}
}

// pollOwner runs whether or not clients are connected, and latches the answer.
// Watching only while idle would read a recycled pid as the owner come back.
func (l *Lease) pollOwner() {
	l.mu.Lock()
	done := l.ownerGone || l.ownerPID <= 0
	l.mu.Unlock()
	if done {
		return
	}

	if alive(l.ownerPID) {
		l.mu.Lock()
		l.strikes = 0
		l.mu.Unlock()
		return
	}

	l.mu.Lock()
	defer l.mu.Unlock()
	l.strikes++
	l.ownerGone = l.strikes >= deadStrikes
}

func (l *Lease) expired() bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	if !l.ownerGone {
		return false
	}
	grace := l.grace
	if l.waived {
		grace = 0
	}
	return l.live == 0 && time.Since(l.idleFrom) >= grace
}

func (l *Lease) fire() {
	l.mu.Lock()
	if l.drained {
		l.mu.Unlock()
		return
	}
	l.drained = true
	l.mu.Unlock()

	l.drain()
}
