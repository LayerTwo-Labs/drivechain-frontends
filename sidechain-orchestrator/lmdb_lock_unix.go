//go:build !windows

package orchestrator

import (
	"errors"
	"os"
	"syscall"
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

	probe := syscall.Flock_t{Type: syscall.F_WRLCK, Whence: 0, Start: 0, Len: 1}
	err = syscall.FcntlFlock(f.Fd(), syscall.F_SETLK, &probe)
	if errors.Is(err, syscall.EAGAIN) || errors.Is(err, syscall.EACCES) {
		return true, nil
	}
	if err != nil {
		return false, err
	}
	probe.Type = syscall.F_UNLCK
	return false, syscall.FcntlFlock(f.Fd(), syscall.F_SETLK, &probe)
}
