package blockfile

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sync"
)

var directoryLocks = struct {
	sync.Mutex
	paths map[string]bool
}{paths: make(map[string]bool)}

type coreLock struct {
	paths []string
	files []*os.File
}

func lockDirectories(dataDir, blocksDir string) (*coreLock, error) {
	paths := []string{dataDir}
	if blocksDir != dataDir {
		paths = append(paths, blocksDir)
	}
	directoryLocks.Lock()
	for _, path := range paths {
		if directoryLocks.paths[path] {
			directoryLocks.Unlock()
			return nil, fmt.Errorf("conversion already owns directory %s", path)
		}
	}
	for _, path := range paths {
		directoryLocks.paths[path] = true
	}
	directoryLocks.Unlock()
	lock := &coreLock{paths: paths}
	for _, path := range paths {
		file, err := os.OpenFile(filepath.Join(path, ".lock"), os.O_RDWR|os.O_CREATE, 0600)
		if err != nil {
			return nil, errors.Join(err, lock.close())
		}
		lock.files = append(lock.files, file)
		if err := takeLock(file); err != nil {
			return nil, errors.Join(fmt.Errorf("cannot lock Core directory %s: %w", path, err), lock.close())
		}
	}
	return lock, nil
}

func (lock *coreLock) close() error {
	directoryLocks.Lock()
	defer directoryLocks.Unlock()
	var err error
	for _, file := range lock.files {
		err = errors.Join(err, file.Close())
	}
	for _, path := range lock.paths {
		delete(directoryLocks.paths, path)
	}
	return err
}
