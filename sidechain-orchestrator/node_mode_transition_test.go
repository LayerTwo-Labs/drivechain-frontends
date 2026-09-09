package orchestrator

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

func nodeModeECashFixture(t *testing.T, endpoint string) *Orchestrator {
	t.Helper()
	previous := config.ECashEndpoints()
	previousID := config.ECashNetworkID()
	entry := netcatalog.EmbeddedECash()
	entry.Services.Enforcer.URL = endpoint
	config.SetECashEndpoints(entry)
	config.SetECashNetworkID(entry.ID)
	t.Cleanup(func() {
		config.SetECashEndpoints(previous)
		config.SetECashNetworkID(previousID)
	})
	return planFixture(t, "ecash")
}

func TestNodeModeFullKeepsSidechainUntilDataDirSelection(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := nodeModeECashFixture(t, server.URL)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	t.Cleanup(func() {
		o.StopAllMonitors()
		require.NoError(t, o.closeRemoteEnforcer())
	})
	cfg, env, _ := installRemoteTestDaemon(t, o)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	ch, err := o.StartWithL1(ctx, cfg.Name, StartOpts{ForceBackend: true, TargetEnv: env})
	require.NoError(t, err)
	for progress := range ch {
		require.NoError(t, progress.Error)
	}
	proc := o.process.Get(cfg.Name)
	require.NotNil(t, proc)
	pid := proc.Pid
	endpoint, err := o.EnforcerURL()
	require.NoError(t, err)
	require.False(t, o.BitcoinConf.HasDatadirForNetwork(config.NetworkECash))

	require.ErrorContains(t, o.SetNodeMode(context.Background(), NodeModeFull), "data directory")
	require.Equal(t, NodeModeLight, o.NodeMode())
	proc = o.process.Get(cfg.Name)
	require.NotNil(t, proc)
	require.Equal(t, pid, proc.Pid)
	currentEndpoint, err := o.EnforcerURL()
	require.NoError(t, err)
	require.Equal(t, endpoint, currentEndpoint)
	require.True(t, o.Status("enforcer").Connected)
	require.False(t, o.process.IsRunning("bitcoind"))
	require.False(t, o.process.IsRunning("enforcer"))
}

func TestNodeModeFullAllowsInitialDataDirSelection(t *testing.T) {
	o := nodeModeECashFixture(t, "")
	require.False(t, o.BitcoinConf.HasDatadirForNetwork(config.NetworkECash))
	require.NoError(t, o.SetNodeMode(context.Background(), NodeModeFull))
	require.Equal(t, NodeModeFull, o.NodeMode())
	require.True(t, o.PlanNetworkChange(NetworkChangeRequest{}).MustSelectDatadir)
	require.Empty(t, o.process.ListRunning())
}

func TestNodeModeFullStopsSidechainAfterDataDirSelection(t *testing.T) {
	o := nodeModeECashFixture(t, "")
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	require.NoError(t, o.SetDatadirForCurrentNetwork(t.TempDir()))
	cfg := o.Configs()["thunder"]
	o.process.processes[cfg.Name] = &ManagedProcess{Config: cfg}
	var stopped []string
	o.stopBinary = func(_ context.Context, name string, _ bool, _ ...StopOptions) error {
		stopped = append(stopped, name)
		return fmt.Errorf("test stop error")
	}
	require.ErrorContains(t, o.SetNodeMode(context.Background(), NodeModeFull), "test stop error")
	require.NotEmpty(t, stopped)
	for _, name := range stopped {
		require.Equal(t, cfg.Name, name)
	}
	require.Equal(t, NodeModeLight, o.NodeMode())
	o.process.Remove(cfg.Name)
}
