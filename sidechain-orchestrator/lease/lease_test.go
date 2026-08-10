package lease

import (
	"net/http"
	"os"
	"testing"
	"time"
)

const deadPID = 0x7FFFFFF0

func drainedFlag() (*bool, func()) {
	drained := false
	return &drained, func() { drained = true }
}

// The standalone case: no owner, so nothing ever reaps the daemon.
func TestNoOwnerNeverDrains(t *testing.T) {
	drained, drain := drainedFlag()
	l := New(0, 0, drain)

	l.ConnState(nil, http.StateNew)
	l.ConnState(nil, http.StateClosed)
	l.Goodbye()

	if l.expired() {
		t.Fatal("lease expired without an owner")
	}
	if *drained {
		t.Fatal("drained without an owner")
	}
}

// A live owner holds the lease however long the clients stay away.
func TestLiveOwnerHoldsLease(t *testing.T) {
	_, drain := drainedFlag()
	l := New(os.Getpid(), 0, drain)

	l.ConnState(nil, http.StateNew)
	l.ConnState(nil, http.StateClosed)

	for range deadStrikes + 1 {
		if l.expired() {
			t.Fatal("lease expired while the owner is alive")
		}
	}
}

// A client still attached holds the lease even though the owner is gone.
func TestAttachedClientHoldsLease(t *testing.T) {
	_, drain := drainedFlag()
	l := New(deadPID, 0, drain)

	l.ConnState(nil, http.StateNew)

	for range deadStrikes + 1 {
		if l.expired() {
			t.Fatal("lease expired with a client still connected")
		}
	}
}

// Owner gone and nobody left: drain, but only after the second strike.
func TestDeadOwnerAndNoClientsDrains(t *testing.T) {
	drained, drain := drainedFlag()
	l := New(deadPID, 0, drain)

	l.ConnState(nil, http.StateNew)
	l.ConnState(nil, http.StateClosed)

	if l.expired() {
		t.Fatal("expired on the first strike")
	}
	if !l.expired() {
		t.Fatal("did not expire on the second strike")
	}

	l.fire()
	l.fire()
	if !*drained {
		t.Fatal("drain never ran")
	}
}

func TestGraceHoldsUntilItElapses(t *testing.T) {
	_, drain := drainedFlag()
	l := New(deadPID, time.Hour, drain)

	l.ConnState(nil, http.StateNew)
	l.ConnState(nil, http.StateClosed)

	for range deadStrikes {
		if l.expired() {
			t.Fatal("expired inside the grace window")
		}
	}

	l.Goodbye()
	if l.expired() {
		t.Fatal("expired on the first strike after goodbye")
	}
	if !l.expired() {
		t.Fatal("goodbye did not drop the grace")
	}
}
