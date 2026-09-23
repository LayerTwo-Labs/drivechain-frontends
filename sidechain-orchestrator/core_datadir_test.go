package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

// TestStartOrAdoptCore_ReportsADatadirWeCannotCreate is the regression guard
// for the disconnected disk: Core exited with "Specified data directory ...
// does not exist", which reads as a BitWindow fault. The start now stops on
// the create, and names the directory it cannot make.
func TestStartOrAdoptCore_ReportsADatadirWeCannotCreate(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)

	blocker := filepath.Join(t.TempDir(), "not-a-directory")
	require.NoError(t, os.WriteFile(blocker, nil, 0o600))
	dir := filepath.Join(blocker, "ecash")
	o.BitcoinConf.DetectedDataDir = dir

	err := o.startOrAdoptCore(context.Background(), []string{"-datadir=" + dir})
	require.ErrorContains(t, err, "data directory")
	require.ErrorContains(t, err, dir)
	require.False(t, o.process.IsRunning("bitcoind"))
}
