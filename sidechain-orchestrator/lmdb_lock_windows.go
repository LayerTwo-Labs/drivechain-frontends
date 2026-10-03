//go:build windows

package orchestrator

import (
	"errors"
	"os"

	"golang.org/x/sys/windows"
)

// lmdbLockHeld reports whether a process holds a lock on the first byte of an
// LMDB lock file. LMDB keeps a shared lock there while the environment is open.
func lmdbLockHeld(lockPath string) (bool, error) {
	f, err := os.OpenFile(lockPath, os.O_RDWR, 0)
	if errors.Is(err, os.ErrNotExist) {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	defer f.Close() //nolint:errcheck // the probe only reads the lock state

	handle := windows.Handle(f.Fd())
	const flags = windows.LOCKFILE_EXCLUSIVE_LOCK | windows.LOCKFILE_FAIL_IMMEDIATELY
	err = windows.LockFileEx(handle, flags, 0, 1, 0, new(windows.Overlapped))
	if errors.Is(err, windows.ERROR_LOCK_VIOLATION) || errors.Is(err, windows.ERROR_IO_PENDING) {
		return true, nil
	}
	if err != nil {
		return false, err
	}
	return false, windows.UnlockFileEx(handle, 0, 1, 0, new(windows.Overlapped))
}
