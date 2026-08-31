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

// A light install runs no enforcer, and no hosted one exists to read the
// mainchain from. A sidechain binary therefore cannot start, and the boot must
// say so rather than launch a daemon that can never sync.
func TestStartWithL1RefusesASidechainInLightMode(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	o.SidechainConfs = map[string]*config.SidechainConfManager{
		"thunder": {Spec: config.SidechainConfSpec{PortStyle: "grpc"}},
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	ch, err := o.StartWithL1(ctx, "thunder", StartOpts{})
	require.NoError(t, err)

	var failed bool
	for p := range ch {
		if p.Error != nil {
			failed = true
		}
	}
	require.True(t, failed, "a sidechain must not start with no mainchain to read")
	require.False(t, o.process.IsRunning("thunder"))
}
