package orchestrator

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// The bug this fixes: the drain skipped every adopted binary, so a daemon that
// survived one bad exit got adopted on the next boot and no drain ever stopped
// it again. It then held the ports and the datadir lock the fresh stack wants.
func TestOwnedInstallMayStopAnAdoptedBinary(t *testing.T) {
	dir := t.TempDir()

	lock, held, err := TakeOwnerLock(dir)
	require.NoError(t, err)
	require.True(t, held)
	t.Cleanup(func() { _ = lock.Release() })

	o := &Orchestrator{}
	require.False(t, o.OwnsInstall(), "a run with no lock owns nothing")

	o.SetOwnerLock(lock)
	require.True(t, o.OwnsInstall(), "the lock holder stops what it finds")
}

// Case 2: a restart races the previous session's exit. The lock is held for a
// moment, and the install must claim itself when it frees — without a second
// restart, and without holding up its own startup.
func TestClaimOwnerLockTakesOverWhenThePreviousSessionLetsGo(t *testing.T) {
	dir := t.TempDir()

	first, held, err := TakeOwnerLock(dir)
	require.NoError(t, err)
	require.True(t, held)

	o := newTestOrchestrator(t)
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	start := time.Now()
	o.ClaimOwnerLock(ctx, dir)
	require.Less(t, time.Since(start), time.Second, "a contested lock must not hold up startup")
	require.False(t, o.OwnsInstall(), "a live holder keeps the install")

	require.NoError(t, first.Release())
	require.Eventually(t, o.OwnsInstall, 5*time.Second, 50*time.Millisecond,
		"the install must claim itself once the previous session lets go")
}
