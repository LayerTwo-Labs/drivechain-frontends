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
	_, err := flags.NewParser(&conf, flags.Default).ParseArgs([]string{})
	require.NoError(t, err)
	require.Equal(t, dir, conf.Datadir)
}

func TestBitwindowDirSurvivesFinalize(t *testing.T) {
	base := t.TempDir()
	conf := Config{Datadir: base}

	require.Equal(t, base, conf.BitwindowDir())
	require.NoError(t, conf.Finalize(NetworkSignet))
	require.Equal(t, filepath.Join(base, string(NetworkSignet)), conf.Datadir)
	require.Equal(t, base, conf.BitwindowDir())
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
