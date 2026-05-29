package config

import (
	"path/filepath"
	"testing"
)

func TestBitwindowDirSurvivesFinalize(t *testing.T) {
	base := t.TempDir()
	conf := Config{Datadir: base}

	if got := conf.BitwindowDir(); got != base {
		t.Fatalf("before Finalize: BitwindowDir() = %q, want %q", got, base)
	}
	if err := conf.Finalize(NetworkSignet); err != nil {
		t.Fatalf("Finalize: %v", err)
	}
	if got := conf.Datadir; got != filepath.Join(base, string(NetworkSignet)) {
		t.Fatalf("Datadir = %q", got)
	}
	if got := conf.BitwindowDir(); got != base {
		t.Fatalf("after Finalize: BitwindowDir() = %q, want %q", got, base)
	}
}
