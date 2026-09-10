package config

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestSetHomeDirMovesEveryBinaryPath(t *testing.T) {
	realHome, err := os.UserHomeDir()
	require.NoError(t, err)

	fake := t.TempDir()
	SetHomeDir(fake)
	t.Cleanup(func() { SetHomeDir("") })

	require.Equal(t, fake, HomeDir())

	for _, dc := range AllDirConfigs() {
		require.True(t, strings.HasPrefix(dc.AppDir(), fake),
			"%s AppDir escaped the override: %s", dc.BinaryName, dc.AppDir())

		if frontend := dc.FlutterFrontendPath(); frontend != "" {
			require.True(t, strings.HasPrefix(frontend, fake),
				"%s FlutterFrontendPath escaped the override: %s", dc.BinaryName, frontend)
			require.False(t, strings.HasPrefix(frontend, filepath.Join(realHome, "Library")),
				"%s FlutterFrontendPath still points at the real home", dc.BinaryName)
		}
	}
}

func TestHomeDirFallsBackToTheUserHome(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	SetHomeDir(t.TempDir())
	SetHomeDir("")
	require.Equal(t, home, HomeDir())
}

func TestTestBinaryNeverResolvesTheStartHome(t *testing.T) {
	require.NotEqual(t, startHome, HomeDir())

	SetHomeDir(t.TempDir())
	SetHomeDir("")
	require.NotEqual(t, startHome, HomeDir())

	t.Run("setenv", func(t *testing.T) {
		home := t.TempDir()
		t.Setenv("HOME", home)
		t.Setenv("USERPROFILE", home)
	})
	require.NotEqual(t, startHome, HomeDir())
	require.Equal(t, testHome(), HomeDir())

	for _, dc := range AllDirConfigs() {
		require.True(t, strings.HasPrefix(dc.AppDir(), testHome()),
			"%s AppDir left the test home: %s", dc.BinaryName, dc.AppDir())
		for _, n := range []Network{NetworkSignet, NetworkECash, NetworkMainnet} {
			require.True(t, strings.HasPrefix(dc.DatadirNetwork(n, ""), testHome()),
				"%s %s datadir left the test home", dc.BinaryName, n)
		}
	}
}
