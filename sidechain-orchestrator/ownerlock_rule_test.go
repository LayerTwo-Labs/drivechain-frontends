package orchestrator

import (
	"testing"

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
