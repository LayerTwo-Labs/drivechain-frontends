package daemon

import (
	"context"
	"errors"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
)

func inProcessConf(t *testing.T) config.Config {
	t.Helper()
	conf, err := config.ParseArgs([]string{
		"--datadir=" + filepath.Join(t.TempDir(), "bitwindow"),
		"--orchestrator.addr=http://127.0.0.1:41234",
		"--owner-pid=42",
	})
	require.NoError(t, err)
	return conf
}

func TestInProcessOrchestratorGetsTheBitwindowdSettings(t *testing.T) {
	conf := inProcessConf(t)
	got := make(chan OrchestratorParams, 1)
	ctx, cancel := context.WithCancel(t.Context())
	defer cancel()

	wait, err := startInProcessOrchestrator(ctx, cancel, conf, func(ctx context.Context, p OrchestratorParams) error {
		got <- p
		<-ctx.Done()
		return nil
	})
	require.NoError(t, err)
	require.Equal(t, OrchestratorParams{
		BitwindowDir: conf.BitwindowDir(),
		ListenAddr:   "127.0.0.1:41234",
		LogPath:      filepath.Join(conf.BitwindowDir(), "bitwindow.log"),
		OwnerPID:     42,
	}, <-got)
	require.NoError(t, wait())
	require.DirExists(t, conf.BitwindowDir())
}

func TestInProcessOrchestratorOutlivesTheBitwindowdContext(t *testing.T) {
	conf := inProcessConf(t)
	ctx, cancel := context.WithCancel(t.Context())
	stopped := make(chan struct{})

	wait, err := startInProcessOrchestrator(ctx, cancel, conf, func(ctx context.Context, _ OrchestratorParams) error {
		<-ctx.Done()
		close(stopped)
		return nil
	})
	require.NoError(t, err)

	cancel()
	select {
	case <-stopped:
		t.Fatal("drivechaind stopped before bitwindowd joined it")
	case <-time.After(100 * time.Millisecond):
	}
	require.NoError(t, wait())
	<-stopped
}

func TestInProcessOrchestratorExitStopsBitwindowd(t *testing.T) {
	conf := inProcessConf(t)
	ctx, cancel := context.WithCancel(t.Context())
	defer cancel()
	boom := errors.New("listen refused")

	wait, err := startInProcessOrchestrator(ctx, cancel, conf, func(context.Context, OrchestratorParams) error {
		return boom
	})
	require.NoError(t, err)

	select {
	case <-ctx.Done():
	case <-time.After(5 * time.Second):
		t.Fatal("bitwindowd kept running without drivechaind")
	}
	err = wait()
	require.ErrorIs(t, err, boom)
	require.ErrorContains(t, err, "drivechaind")
}

func TestInProcessOrchestratorRefusesABadAddress(t *testing.T) {
	conf := inProcessConf(t)
	conf.OrchestratorAddr = ""
	_, err := startInProcessOrchestrator(t.Context(), func() {}, conf, func(context.Context, OrchestratorParams) error {
		t.Fatal("drivechaind must not start")
		return nil
	})
	require.ErrorContains(t, err, "orchestrator.addr not configured")
}
