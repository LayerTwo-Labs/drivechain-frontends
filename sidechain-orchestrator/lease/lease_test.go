package lease

import (
	"net/http"
	"os"
	"sync"
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

// An app update replaces the frontend. The new one claims the daemon before
// the dead pid drains it.
func TestSetOwnerHoldsTheLeaseForTheNewFrontend(t *testing.T) {
	drained, drain := drainedFlag()
	l := New(deadPID, 0, drain)

	pollUntilOwnerGone(l)
	if !l.expired() {
		t.Fatal("lease did not expire after the owner died")
	}

	if !l.SetOwner(os.Getpid()) {
		t.Fatal("SetOwner reported a drain that never ran")
	}
	pollUntilOwnerGone(l)

	if l.expired() {
		t.Fatal("lease expired while the new frontend is alive")
	}
	if *drained {
		t.Fatal("drained a daemon a live frontend owns")
	}
}

// A claim that lands after the drain fired says so, and the daemon serves the
// new frontend from there on.
func TestSetOwnerAfterTheDrainReportsTheFire(t *testing.T) {
	_, drain := drainedFlag()
	l := New(deadPID, 0, drain)

	pollUntilOwnerGone(l)
	l.fire()

	if l.SetOwner(os.Getpid()) {
		t.Fatal("SetOwner missed the drain that already ran")
	}

	l.ConnState(nil, http.StateNew)
	l.ConnState(nil, http.StateClosed)
	pollUntilOwnerGone(l)
	if l.expired() {
		t.Fatal("lease expired while the new frontend is alive")
	}
}

// The daemon keeps watching after a drain, so the frontend that took it over
// reaps it in turn.
func TestLeaseFiresAgainForTheNewOwner(t *testing.T) {
	fires := 0
	l := New(deadPID, 0, func() { fires++ })

	pollUntilOwnerGone(l)
	if l.expired() {
		l.fire()
	}
	l.SetOwner(deadPID)
	pollUntilOwnerGone(l)
	if l.expired() {
		l.fire()
	}

	if fires != 2 {
		t.Fatalf("drain ran %d times, want 2", fires)
	}
}

// A handover that lands while the owner poll runs must not read the answer for
// the frontend the update replaced onto the one that replaced it.
func TestSetOwnerRacesThePoll(t *testing.T) {
	_, drain := drainedFlag()
	l := New(deadPID, 0, drain)

	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		for range 200 {
			l.pollOwner()
		}
	}()
	go func() {
		defer wg.Done()
		for range 200 {
			l.SetOwner(os.Getpid())
		}
	}()
	wg.Wait()

	l.mu.Lock()
	defer l.mu.Unlock()
	if l.ownerGone {
		t.Fatal("the poll marked a live owner gone")
	}
}

// A handover that lands between the expiry check and the drain must win. The
// tick that read the old owner cannot drain the daemon the claim just saved.
func TestFireIfExpiredHonoursALateHandover(t *testing.T) {
	drained, drain := drainedFlag()
	l := New(deadPID, 0, drain)

	pollUntilOwnerGone(l)
	if !l.expired() {
		t.Fatal("lease did not expire after the owner died")
	}

	// The tick already read expired. The claim lands before the drain.
	l.SetOwner(os.Getpid())
	l.fireIfExpired()

	if *drained {
		t.Fatal("drained a daemon the new frontend had already claimed")
	}
}

func TestHoldKeepsLeaseAfterClientExit(t *testing.T) {
	drained, drain := drainedFlag()
	l := New(deadPID, 0, drain)
	l.ConnState(nil, http.StateNew)
	release := l.Hold()
	l.Goodbye()
	l.ConnState(nil, http.StateClosed)
	pollUntilOwnerGone(l)
	l.fireIfExpired()
	if *drained {
		t.Fatal("lease drained with an active hold")
	}
	release()
	l.fireIfExpired()
	if !*drained {
		t.Fatal("lease did not drain after the hold ended")
	}
}

func TestHoldReleaseResetsGrace(t *testing.T) {
	_, drain := drainedFlag()
	l := New(deadPID, time.Hour, drain)
	pollUntilOwnerGone(l)
	l.idleFrom = time.Now().Add(-2 * time.Hour)
	release := l.Hold()
	before := time.Now()
	release()
	if l.idleFrom.Before(before) {
		t.Fatal("the last hold did not reset the idle time")
	}
	if l.expired() {
		t.Fatal("lease expired before the new grace period ended")
	}
	l.idleFrom = time.Now().Add(-2 * time.Hour)
	if !l.expired() {
		t.Fatal("lease did not expire after the new grace period")
	}
}

func TestHoldReleaseRunsOnce(t *testing.T) {
	drained, drain := drainedFlag()
	l := New(deadPID, 0, drain)
	pollUntilOwnerGone(l)
	idleFrom := l.idleFrom
	first := l.Hold()
	second := l.Hold()
	var group sync.WaitGroup
	for range 32 {
		group.Add(1)
		go func() {
			defer group.Done()
			first()
		}()
	}
	group.Wait()
	if l.holds != 1 {
		t.Fatalf("hold count = %d, want 1", l.holds)
	}
	if !l.idleFrom.Equal(idleFrom) {
		t.Fatal("the first hold reset the idle time")
	}
	l.fireIfExpired()
	if *drained {
		t.Fatal("lease drained before the second hold ended")
	}
	second()
	second()
	if l.holds != 0 {
		t.Fatalf("hold count = %d, want 0", l.holds)
	}
	l.fireIfExpired()
	if !*drained {
		t.Fatal("lease did not drain after both holds ended")
	}
}
