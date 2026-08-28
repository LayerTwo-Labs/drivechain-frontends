//go:build windows

package walletfile

import (
	"fmt"
	"os"

	"golang.org/x/sys/windows"
)

// lock takes an exclusive lock on the wallet file and returns the release. Two
// processes that touch the same wallet file take it in turn.
func lock(path string) (func(), error) {
	file, err := os.OpenFile(path+LockSuffix, os.O_CREATE|os.O_RDWR, 0600)
	if err != nil {
		return nil, fmt.Errorf("open the wallet lock: %w", err)
	}
	handle := windows.Handle(file.Fd())
	if err := windows.LockFileEx(handle, windows.LOCKFILE_EXCLUSIVE_LOCK, 0, 1, 0, new(windows.Overlapped)); err != nil {
		_ = file.Close()
		return nil, fmt.Errorf("take the wallet lock: %w", err)
	}
	return func() {
		_ = windows.UnlockFileEx(handle, 0, 1, 0, new(windows.Overlapped))
		_ = file.Close()
	}, nil
}
