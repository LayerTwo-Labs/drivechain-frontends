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
	realHome, err := os.UserHomeDir()
	require.NoError(t, err)

	SetHomeDir(t.TempDir())
	SetHomeDir("")
	require.Equal(t, realHome, HomeDir())
}
