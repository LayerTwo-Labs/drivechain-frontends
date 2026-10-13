package config

import (
	"path/filepath"
	"testing"

	"github.com/jessevdk/go-flags"
	"github.com/stretchr/testify/require"
)

// The GUI (and the e2e harness) isolate runs via the BITWINDOWD_DATADIR env
// var. bitwindowd must honor it so its datadir — and thus the .auth.cookie the
// orchestrator writes beside wallet.json — lands where the frontend reads it.
func TestDatadirFromEnv(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("BITWINDOWD_DATADIR", dir)

	var conf Config
	if _, err := flags.NewParser(&conf, flags.Default).ParseArgs([]string{}); err != nil {
		t.Fatalf("parse: %v", err)
	}
	if conf.Datadir != dir {
		t.Fatalf("Datadir = %q, want %q (from BITWINDOWD_DATADIR)", conf.Datadir, dir)
	}
}

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

func TestPprofAddr(t *testing.T) {
	t.Run("off by default", func(t *testing.T) {
		var conf Config
		_, err := flags.NewParser(&conf, flags.Default).ParseArgs([]string{})
		require.NoError(t, err)
		require.Empty(t, conf.PprofAddr)
	})

	t.Run("set by flag", func(t *testing.T) {
		var conf Config
		_, err := flags.NewParser(&conf, flags.Default).ParseArgs([]string{"--pprof.addr=localhost:6060"})
		require.NoError(t, err)
		require.Equal(t, "localhost:6060", conf.PprofAddr)
	})
}
