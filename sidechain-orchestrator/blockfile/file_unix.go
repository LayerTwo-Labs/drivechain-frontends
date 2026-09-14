//go:build !windows

package blockfile

import (
	"errors"
	"os"
	"path/filepath"

	"golang.org/x/sys/unix"
)

func takeLock(file *os.File) error {
	lock := unix.Flock_t{Type: unix.F_WRLCK, Whence: 0, Start: 0, Len: 0}
	return unix.FcntlFlock(file.Fd(), unix.F_SETLK, &lock)
}

func moveJournal(from, to string) (err error) {
	if err := os.Rename(from, to); err != nil {
		return err
	}
	dir, err := os.Open(filepath.Dir(to))
	if err != nil {
		return err
	}
	defer func() { err = errors.Join(err, dir.Close()) }()
	return dir.Sync()
}
