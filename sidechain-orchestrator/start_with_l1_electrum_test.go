package orchestrator

import (
	"context"
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

// A light install runs no enforcer, so a sidechain daemon has no mainchain to
// read. The boot skips the daemon and reports done, because a light wallet
// reads the chain from an index instead. ForceBackend is what a sidechain app
// sends when it boots its own daemon.
func TestStartWithL1StartsNoSidechainDaemonInLightMode(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	o.RegisterLightWallet("thunder", func() bool { return true })
	o.SidechainConfs = map[string]*config.SidechainConfManager{
		"thunder": {Spec: config.SidechainConfSpec{PortStyle: "grpc"}},
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	ch, err := o.StartWithL1(ctx, "thunder", StartOpts{ForceBackend: true})
	require.NoError(t, err)

	var stages []string
	for p := range ch {
		require.NoError(t, p.Error)
		stages = append(stages, p.Stage)
	}

	require.Equal(t, []string{"skipped-l1"}, stages)
	require.False(t, o.process.IsRunning("thunder"))
	require.False(t, o.process.IsRunning("thunder-gui"))
}

// A chain with no light backend is a plain proxy to a daemon that light mode
// never starts. A standalone app must read the refusal, not a false success.
func TestStartWithL1RefusesAChainThatReadsNoIndex(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	o.SidechainConfs = map[string]*config.SidechainConfManager{
		"bitnames": {Spec: config.SidechainConfSpec{PortStyle: "grpc"}},
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	ch, err := o.StartWithL1(ctx, "bitnames", StartOpts{ForceBackend: true})
	require.NoError(t, err)

	var failed bool
	for p := range ch {
		if p.Error != nil {
			failed = true
			require.Contains(t, p.Error.Error(), "full mode only")
		}
	}

	require.True(t, failed, "a chain that reads no index must refuse")
	require.False(t, o.process.IsRunning("bitnames"))
}
