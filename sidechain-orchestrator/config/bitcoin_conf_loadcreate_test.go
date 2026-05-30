package config

import (
	"os"
	"strings"
	"testing"

	"github.com/rs/zerolog"
)

// newTestConfManager builds a manager pointed at a temp BitwindowDir without
// running LoadConfig (which would also copy downstream). Tests call the
// unexported loadOrCreateConfigContent directly.
func newTestConfManager(t *testing.T) *BitcoinConfManager {
	t.Helper()
	return &BitcoinConfManager{
		BitwindowDir: t.TempDir(),
		Network:      NetworkSignet,
		log:          zerolog.Nop(),
	}
}

// Missing file is a genuine first run: write defaults, no error.
func TestLoadOrCreate_MissingWritesDefault(t *testing.T) {
	m := newTestConfManager(t)

	content, err := m.loadOrCreateConfigContent()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(content, "chain=signet") {
		t.Errorf("default content missing chain=signet:\n%s", content)
	}
	if _, statErr := os.Stat(m.getBitWindowConfigPath()); statErr != nil {
		t.Errorf("default config not written: %v", statErr)
	}
}

// An existing valid file with a custom datadir must be returned verbatim — the
// round-trip must not drop user settings.
func TestLoadOrCreate_ExistingPreservesDatadir(t *testing.T) {
	m := newTestConfManager(t)
	confPath := m.getBitWindowConfigPath()

	custom := "# bitwindow-bitcoin-conf-version=9\n\ndatadir=/Volumes/LaCie/Bitcoin\nchain=main\n"
	if err := os.WriteFile(confPath, []byte(custom), 0644); err != nil {
		t.Fatal(err)
	}

	content, err := m.loadOrCreateConfigContent()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(content, "datadir=/Volumes/LaCie/Bitcoin") {
		t.Errorf("custom datadir lost:\n%s", content)
	}

	// File on disk must still carry the custom datadir (no clobber to default).
	onDisk, err := os.ReadFile(confPath)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(onDisk), "datadir=/Volumes/LaCie/Bitcoin") {
		t.Errorf("on-disk datadir clobbered:\n%s", onDisk)
	}
}

// A path that exists but is unreadable (here: a directory in place of the file)
// must fail closed — return an error and NOT overwrite with defaults.
func TestLoadOrCreate_UnreadableFailsClosed(t *testing.T) {
	m := newTestConfManager(t)
	confPath := m.getBitWindowConfigPath()

	// A directory at confPath makes os.ReadFile fail with a non-NotExist error.
	if err := os.MkdirAll(confPath, 0755); err != nil {
		t.Fatal(err)
	}

	_, err := m.loadOrCreateConfigContent()
	if err == nil {
		t.Fatal("expected error on unreadable config, got nil (would have clobbered user data)")
	}

	// The path must be untouched — still a directory, not overwritten by a
	// default file.
	info, statErr := os.Stat(confPath)
	if statErr != nil {
		t.Fatalf("confPath vanished: %v", statErr)
	}
	if !info.IsDir() {
		t.Error("confPath was overwritten with a default file instead of failing closed")
	}
}
