//go:build windows

package orchestrator

import (
	"os"

	"golang.org/x/sys/windows"
)

// takeOwnerLock holds an exclusive lock on an open file until the process ends.
// The kernel releases it when the holder dies, which is what makes a leftover
// binary safe to reclaim without asking whether a recorded PID is still alive.
func takeOwnerLock(f *os.File) (bool, error) {
	const flags = windows.LOCKFILE_EXCLUSIVE_LOCK | windows.LOCKFILE_FAIL_IMMEDIATELY
	err := windows.LockFileEx(windows.Handle(f.Fd()), flags, 0, 1, 0, new(windows.Overlapped))
	if err == nil {
		return true, nil
	}
	if err == windows.ERROR_LOCK_VIOLATION || err == windows.ERROR_IO_PENDING {
		return false, nil
	}
	return false, err
}
