//go:build !windows

package orchestrator

import (
	"os"
	"syscall"
)

// takeOwnerLock holds an exclusive lock on an open file until the process ends.
// The kernel releases it when the holder dies, which is what makes a leftover
// binary safe to reclaim without asking whether a recorded PID is still alive.
func takeOwnerLock(f *os.File) (bool, error) {
	err := syscall.Flock(int(f.Fd()), syscall.LOCK_EX|syscall.LOCK_NB)
	if err == nil {
		return true, nil
	}
	if err == syscall.EWOULDBLOCK || err == syscall.EAGAIN {
		return false, nil
	}
	return false, err
}
