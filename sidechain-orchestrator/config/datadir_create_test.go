package config

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

// TestCreateDataDir_CreatesTheMissingDir covers the plain case: the conf names
// a datadir under a folder the user picked, and nobody made it yet.
func TestCreateDataDir_CreatesTheMissingDir(t *testing.T) {
	picked := filepath.Join(t.TempDir(), "bitwindow folder")
	require.NoError(t, os.MkdirAll(picked, 0o755))
	dir := filepath.Join(picked, "ecash")
	m := &BitcoinConfManager{Network: NetworkECash, DetectedDataDir: dir}

	require.NoError(t, m.CreateDataDir())
	require.DirExists(t, dir)
}

// TestCreateDataDir_AcceptsADirThatExists keeps a second start quiet.
func TestCreateDataDir_AcceptsADirThatExists(t *testing.T) {
	dir := filepath.Join(t.TempDir(), "ecash")
	require.NoError(t, os.MkdirAll(dir, 0o755))
	m := &BitcoinConfManager{Network: NetworkECash, DetectedDataDir: dir}

	require.NoError(t, m.CreateDataDir())
	require.DirExists(t, dir)
}

// TestCreateDataDir_KeepsAGoneDiskGone is the guard for the worst outcome: a
// recursive create puts an empty datadir where the user's chain is, and Core
// downloads the chain a second time. A missing parent stands for the disk the
// user disconnected.
func TestCreateDataDir_KeepsAGoneDiskGone(t *testing.T) {
	volume := filepath.Join(t.TempDir(), "Volumes", "SSD")
	dir := filepath.Join(volume, "bitwindow folder", "ecash")
	m := &BitcoinConfManager{Network: NetworkECash, DetectedDataDir: dir}

	err := m.CreateDataDir()
	require.ErrorContains(t, err, dir)
	require.ErrorContains(t, err, "disk")
	require.NoDirExists(t, volume)
}

// TestCreateDataDir_ReportsAParentThatIsNotADir names the path Core refuses,
// in place of Core's own "does not exist".
func TestCreateDataDir_ReportsAParentThatIsNotADir(t *testing.T) {
	parent := filepath.Join(t.TempDir(), "not-a-directory")
	require.NoError(t, os.WriteFile(parent, nil, 0o600))
	dir := filepath.Join(parent, "ecash")
	m := &BitcoinConfManager{Network: NetworkECash, DetectedDataDir: dir}

	err := m.CreateDataDir()
	require.ErrorContains(t, err, "create the data directory")
	require.ErrorContains(t, err, dir)
}

// TestCreateDataDir_BuildsThePlatformDefault keeps a first start on a machine
// whose home holds no application folder yet.
func TestCreateDataDir_BuildsThePlatformDefault(t *testing.T) {
	t.Setenv("HOME", t.TempDir())
	t.Setenv("APPDATA", t.TempDir())
	t.Setenv("XDG_DATA_HOME", "")
	m := &BitcoinConfManager{Network: NetworkSignet}

	require.NoError(t, m.CreateDataDir())
	require.DirExists(t, m.RootDataDir())
}

// TestCreateDataDir_TakesAPathThatEndsInASeparator keeps a hand-edited conf
// line working: filepath.Dir gives back an unclean path itself, so the parent
// check reads the datadir and refuses a directory it can make.
func TestCreateDataDir_TakesAPathThatEndsInASeparator(t *testing.T) {
	picked := t.TempDir()
	dir := filepath.Join(picked, "bitcoin")
	m := &BitcoinConfManager{Network: NetworkMainnet, DetectedDataDir: dir + string(filepath.Separator)}

	require.NoError(t, m.CreateDataDir())
	require.DirExists(t, dir)
}
