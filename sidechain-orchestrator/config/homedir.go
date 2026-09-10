package config

import (
	"os"
	"sync"
	"testing"
)

var (
	homeMu       sync.RWMutex
	homeOverride string
)

// SetHomeDir points every binary path at dir instead of the user's home
// directory. An empty dir restores the user's home.
//
// A process confined to one install must resolve every other binary's data
// directory inside that install. Without this a daemon told to use a temp
// directory still reaches the real home, and a wipe there moves the user's
// own wallet aside.
func SetHomeDir(dir string) {
	homeMu.Lock()
	homeOverride = dir
	homeMu.Unlock()
}

// HomeDir returns the directory every binary path resolves against.
func HomeDir() string {
	homeMu.RLock()
	dir := homeOverride
	homeMu.RUnlock()
	if dir != "" {
		return dir
	}
	return UserHomeDir()
}

var (
	startHome, _ = os.UserHomeDir()
	testHome     = sync.OnceValue(func() string {
		dir, err := os.MkdirTemp("", "orchestrator-test-home-")
		if err != nil {
			panic(err)
		}
		return dir
	})
)

// UserHomeDir returns the user's home directory. A test binary gets a temp
// directory in place of the home the process started with.
func UserHomeDir() string {
	home, _ := os.UserHomeDir()
	if testing.Testing() && home == startHome {
		return testHome()
	}
	return home
}
