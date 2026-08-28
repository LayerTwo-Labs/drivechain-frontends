//go:build !windows

package walletfile

import (
	"fmt"
	"os"

	"golang.org/x/sys/unix"
)

// lock takes an exclusive lock on the wallet file and returns the release. Two
// processes that touch the same wallet file take it in turn.
func lock(path string) (func(), error) {
	file, err := os.OpenFile(path+LockSuffix, os.O_CREATE|os.O_RDWR, 0600)
	if err != nil {
		return nil, fmt.Errorf("open the wallet lock: %w", err)
	}
	if err := unix.Flock(int(file.Fd()), unix.LOCK_EX); err != nil {
		_ = file.Close()
		return nil, fmt.Errorf("take the wallet lock: %w", err)
	}
	return func() {
		_ = unix.Flock(int(file.Fd()), unix.LOCK_UN)
		_ = file.Close()
	}, nil
}
