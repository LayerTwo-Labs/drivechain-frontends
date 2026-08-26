package orchestrator

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

// One install at a time. A second one must not stop binaries the first owns.
func TestOwnerLockRefusesASecondHolder(t *testing.T) {
	dir := t.TempDir()

	first, held, err := TakeOwnerLock(dir)
	require.NoError(t, err)
	require.True(t, held)
	t.Cleanup(func() { _ = first.Release() })

	_, held, err = TakeOwnerLock(dir)
	require.NoError(t, err, "a busy lock is not an error")
	require.False(t, held)
}

// The kernel drops the lock when the holder dies, which is the whole point: a
// crashed install leaves its binaries reclaimable rather than immortal.
func TestOwnerLockFreesWhenTheHolderDies(t *testing.T) {
	dir := t.TempDir()

	holder := exec.Command(os.Args[0], "-test.run=TestOwnerLockHolderHelper")
	holder.Env = append(os.Environ(), "ORCHESTRATOR_LOCK_HELPER_DIR="+dir)
	out, err := holder.CombinedOutput()
	require.NoError(t, err, string(out))

	lock, held, err := TakeOwnerLock(dir)
	require.NoError(t, err)
	require.True(t, held, "the dead holder's lock must be free")
	require.NoError(t, lock.Release())
}

// TestOwnerLockHolderHelper runs in a child process: it takes the lock and
// exits, so the parent can prove the kernel released it.
func TestOwnerLockHolderHelper(t *testing.T) {
	dir := os.Getenv("ORCHESTRATOR_LOCK_HELPER_DIR")
	if dir == "" {
		t.Skip("helper for TestOwnerLockFreesWhenTheHolderDies")
	}
	_, held, err := TakeOwnerLock(dir)
	require.NoError(t, err)
	require.True(t, held)
}

// Release hands the install over without an exit, so a caller that keeps
// running can pass ownership on.
func TestOwnerLockReleaseLetsTheNextHolderIn(t *testing.T) {
	dir := t.TempDir()

	first, held, err := TakeOwnerLock(dir)
	require.NoError(t, err)
	require.True(t, held)
	require.NoError(t, first.Release())

	second, held, err := TakeOwnerLock(dir)
	require.NoError(t, err)
	require.True(t, held)
	require.NoError(t, second.Release())
}

// The lock lives beside the PID files it speaks for.
func TestOwnerLockSitsInThePidDir(t *testing.T) {
	dir := t.TempDir()

	lock, held, err := TakeOwnerLock(dir)
	require.NoError(t, err)
	require.True(t, held)
	t.Cleanup(func() { _ = lock.Release() })

	_, err = os.Stat(filepath.Join(PidDir(dir), ownerLockName))
	require.NoError(t, err)
}
