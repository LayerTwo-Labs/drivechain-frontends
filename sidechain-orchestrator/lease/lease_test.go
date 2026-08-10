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

// pollUntilOwnerGone runs the strikes a live ticker would.
func pollUntilOwnerGone(l *Lease) {
	for range deadStrikes {
		l.pollOwner()
	}
}

// The standalone case: no owner, so nothing ever reaps the daemon.
func TestNoOwnerNeverDrains(t *testing.T) {
	drained, drain := drainedFlag()
	l := New(0, 0, drain)

	l.ConnState(nil, http.StateNew)
	l.ConnState(nil, http.StateClosed)
	l.Goodbye()
	pollUntilOwnerGone(l)

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
	pollUntilOwnerGone(l)

	if l.expired() {
		t.Fatal("lease expired while the owner is alive")
	}
}

// A client still attached holds the lease even though the owner is gone.
func TestAttachedClientHoldsLease(t *testing.T) {
	_, drain := drainedFlag()
	l := New(deadPID, 0, drain)

	l.ConnState(nil, http.StateNew)
	pollUntilOwnerGone(l)

	if l.expired() {
		t.Fatal("lease expired with a client still connected")
	}
}

// Owner gone and nobody left: drain, but only after the second strike.
func TestDeadOwnerAndNoClientsDrains(t *testing.T) {
	drained, drain := drainedFlag()
	l := New(deadPID, 0, drain)

	l.ConnState(nil, http.StateNew)
	l.ConnState(nil, http.StateClosed)

	l.pollOwner()
	if l.expired() {
		t.Fatal("expired on the first strike")
	}

	l.pollOwner()
	if !l.expired() {
		t.Fatal("did not expire on the second strike")
	}

	l.fire()
	l.fire()
	if !*drained {
		t.Fatal("drain never ran")
	}
}

// The owner is watched while a client is attached, so a pid recycled later
// cannot read as the owner coming back.
func TestOwnerDeathLatchesWhileClientAttached(t *testing.T) {
	_, drain := drainedFlag()
	l := New(deadPID, 0, drain)

	l.ConnState(nil, http.StateNew)
	pollUntilOwnerGone(l)

	// Stand in for the recycled pid: a live process under the same number.
	l.ownerPID = os.Getpid()
	l.pollOwner()

	l.ConnState(nil, http.StateClosed)
	if !l.expired() {
		t.Fatal("a recycled pid resurrected a dead owner")
	}
}

// One client's goodbye must not strip the reconnect grace from the next.
func TestArrivingClientRestoresTheGrace(t *testing.T) {
	_, drain := drainedFlag()
	l := New(deadPID, time.Hour, drain)

	l.ConnState(nil, http.StateNew)
	l.Goodbye()
	l.ConnState(nil, http.StateClosed)

	l.ConnState(nil, http.StateNew)
	l.ConnState(nil, http.StateClosed)
	pollUntilOwnerGone(l)

	if l.expired() {
		t.Fatal("an earlier goodbye waived the grace for a later client")
	}
}

func TestGraceHoldsUntilItElapses(t *testing.T) {
	_, drain := drainedFlag()
	l := New(deadPID, time.Hour, drain)

	l.ConnState(nil, http.StateNew)
	l.ConnState(nil, http.StateClosed)
	pollUntilOwnerGone(l)

	if l.expired() {
		t.Fatal("expired inside the grace window")
	}

	l.Goodbye()
	if !l.expired() {
		t.Fatal("goodbye did not drop the grace")
	}
}
