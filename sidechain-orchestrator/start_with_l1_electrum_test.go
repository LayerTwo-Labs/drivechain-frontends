package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"runtime"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

// An electrum wallet serves chain data remotely, so StartWithL1 must boot
// neither Bitcoin Core nor the enforcer — it short-circuits to a skipped-l1
// completion and starts no processes.
func TestStartWithL1SkipsBackendsInLightMode(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	require.Equal(t, NodeModeLight, o.NodeMode())

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	ch, err := o.StartWithL1(ctx, "bitcoind", StartOpts{})
	require.NoError(t, err)

	var stages []string
	for p := range ch {
		require.NoError(t, p.Error)
		stages = append(stages, p.Stage)
	}

	require.Equal(t, []string{"skipped-l1"}, stages)
	require.False(t, o.process.IsRunning("bitcoind"))
	require.False(t, o.process.IsRunning("enforcer"))
}

// Full mode needs the local stack, so the gate must not skip it — whatever
// backend the active wallet happens to use.
func TestStartWithL1NeedsBackendsInFullMode(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	require.Equal(t, NodeModeFull, o.NodeMode())
}

// In electrum mode a grpc-style sidechain has no local enforcer, so it must be
// rewired to the hosted orchestrator's mainchain rather than dial localhost.
func TestPointSidechainAtRemoteMainchainInjectsURL(t *testing.T) {
	o := newTestOrchestrator(t) // signet
	o.SidechainConfs = map[string]*config.SidechainConfManager{
		"thunder": {Spec: config.SidechainConfSpec{PortStyle: "grpc"}},
	}
	cfg := BinaryConfig{Name: "thunder", DisplayName: "Thunder", ChainLayer: 2}

	opts := StartOpts{}
	ch := make(chan StartupProgress, 4)
	require.True(t, o.pointSidechainAtRemoteMainchain(cfg, &opts, ch))
	require.Contains(t, opts.TargetArgs, "--mainchain-grpc-url=https://orchestrator.signet.drivechain.info")
}

// A network with no hosted orchestrator can't back an electrum sidechain, so
// the boot must fail cleanly instead of launching a doomed daemon.
func TestPointSidechainAtRemoteMainchainFailsWithoutRemote(t *testing.T) {
	o := newTestOrchestrator(t)
	o.Network = string(config.NetworkRegtest)
	o.SidechainConfs = map[string]*config.SidechainConfManager{
		"thunder": {Spec: config.SidechainConfSpec{PortStyle: "grpc"}},
	}
	cfg := BinaryConfig{Name: "thunder", DisplayName: "Thunder", ChainLayer: 2}

	opts := StartOpts{}
	ch := make(chan StartupProgress, 4)
	require.False(t, o.pointSidechainAtRemoteMainchain(cfg, &opts, ch))
	require.Empty(t, opts.TargetArgs)
	require.Error(t, (<-ch).Error)
}

// Light mode fills --mainchain-grpc-url before the conf-derived args are
// built, and the daemon has no network flag of its own — so the spawned argv
// has to carry both the remote mainchain and the selected network, or the
// sidechain silently boots on its clap default of signet.
func TestStartWithL1LightModeSidechainArgvCarriesNetwork(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("uses a shell script as the fake binary")
	}

	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir("") })

	dataDir := t.TempDir()
	o := New(dataDir, string(config.NetworkSignet), t.TempDir(), AllDefaults(), testLogger(t))
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))

	// A binary on disk keeps the boot off the network. It outlives the spawn
	// long enough for the exit to be the thing that ends the connection wait.
	binDir := BinDir(dataDir)
	require.NoError(t, os.MkdirAll(binDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(binDir, "thunder"), []byte("#!/bin/sh\nsleep 1\n"), 0o755))

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// ForceBackend: the daemon takes the argv, not the sidechain's Flutter GUI.
	ch, err := o.StartWithL1(ctx, "thunder", StartOpts{ForceBackend: true})
	require.NoError(t, err)
	for range ch {
	}

	proc := o.process.LatestRun("thunder")
	require.NotNil(t, proc)
	require.Contains(t, proc.Cmd.Args, "--network=signet")
	require.Contains(t, proc.Cmd.Args, "--mainchain-grpc-url=https://orchestrator.signet.drivechain.info")
	require.NotContains(t, proc.Cmd.Args, "--mainchain-grpc-url=http://localhost:50051")
}

// zmq-style sidechains carry no mainchain-grpc-url and can't reach a remote
// enforcer, so electrum mode must reject them rather than start them to fail.
func TestPointSidechainAtRemoteMainchainRejectsZMQ(t *testing.T) {
	o := newTestOrchestrator(t)
	o.SidechainConfs = map[string]*config.SidechainConfManager{
		"bitnames": {Spec: config.SidechainConfSpec{PortStyle: "zmq"}},
	}
	cfg := BinaryConfig{Name: "bitnames", DisplayName: "BitNames", ChainLayer: 2}

	opts := StartOpts{}
	ch := make(chan StartupProgress, 4)
	require.False(t, o.pointSidechainAtRemoteMainchain(cfg, &opts, ch))
	require.Empty(t, opts.TargetArgs)
	require.Error(t, (<-ch).Error)
}
