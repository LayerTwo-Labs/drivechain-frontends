package config

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// A user who clears the logs means every log, including the one an install from
// before the rename still holds.
func TestBitwindowRootLogsKeepsThePreRenameName(t *testing.T) {
	require.Contains(t, BitwindowRootLogs(), "orchestratord.log")
	require.Contains(t, BitwindowRootLogs(), "drivechaind.log")
}

func TestGetExistingFilesInDirReturnsBothDaemonLogs(t *testing.T) {
	dir := t.TempDir()
	for _, name := range []string{"drivechaind.log", "orchestratord.log"} {
		require.NoError(t, os.WriteFile(filepath.Join(dir, name), []byte("line\n"), 0o644))
	}

	found := GetExistingFilesInDir(dir, BitwindowRootLogs(), zerolog.Nop())

	require.Contains(t, found, filepath.Join(dir, "drivechaind.log"))
	require.Contains(t, found, filepath.Join(dir, "orchestratord.log"))
}
