package orchestrator

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

// A daemon confined to one install must never list a wallet outside it. The
// wallet service moves every path this returns to wallet_backups/, so a path
// that escapes takes the user's own wallet.json with it.
func TestBinaryWalletPathsStayInsideTheAppHome(t *testing.T) {
	appHome := t.TempDir()
	config.SetHomeDir(appHome)
	t.Cleanup(func() { config.SetHomeDir("") })

	o := newResetTestOrchestrator(t)

	frontend := config.BitWindowDirs.FlutterFrontendPath()
	require.NotEmpty(t, frontend)
	seedFile(t, filepath.Join(frontend, "wallet.json"))

	paths := o.BinaryWalletPaths()
	require.Contains(t, paths, filepath.Join(frontend, "wallet.json"))

	for _, p := range paths {
		require.True(t, strings.HasPrefix(p, appHome) || strings.HasPrefix(p, o.BitwindowDir),
			"wallet path escaped the app home: %s", p)
	}
}

// The same containment holds for the reset gather, which feeds DeleteFiles.
func TestGatherWalletFilesStayInsideTheAppHome(t *testing.T) {
	appHome := t.TempDir()
	config.SetHomeDir(appHome)
	t.Cleanup(func() { config.SetHomeDir("") })

	o := newResetTestOrchestrator(t)

	frontend := config.BitWindowDirs.FlutterFrontendPath()
	seedFile(t, filepath.Join(frontend, "wallet.json"))

	files, err := o.GatherFilesToDelete([]GatherSpec{
		{Binary: ResetBinaryBitwindowd, Categories: allCategories()},
	})
	require.NoError(t, err)

	for _, f := range files {
		require.True(t, strings.HasPrefix(f.Path, appHome) || strings.HasPrefix(f.Path, o.BitwindowDir),
			"gathered path escaped the app home: %s", f.Path)
	}
}

// Without an override the real user home is still the base, so a normal
// install keeps working.
func TestAppHomeDefaultsToTheUserHome(t *testing.T) {
	home, err := os.UserHomeDir()
	require.NoError(t, err)
	require.True(t, strings.HasPrefix(config.BitWindowDirs.FlutterFrontendPath(), home))
}
