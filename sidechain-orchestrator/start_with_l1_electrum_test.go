package orchestrator

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// An electrum wallet serves chain data remotely, so StartWithL1 must boot
// neither Bitcoin Core nor the enforcer — it short-circuits to a skipped-l1
// completion and starts no processes.
func TestStartWithL1SkipsBackendsInLightMode(t *testing.T) {
	useTempHome(t)
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
	useTempHome(t)
	o := newTestOrchestrator(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	require.Equal(t, NodeModeFull, o.NodeMode())
}

func TestStartWithL1RejectsCoreSidechainInLightMode(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	ch, err := o.StartWithL1(context.Background(), "freebank", StartOpts{ForceBackend: true})
	require.NoError(t, err)
	var bootErr error
	for p := range ch {
		if p.Error != nil {
			bootErr = p.Error
		}
	}
	require.ErrorContains(t, bootErr, "does not support a remote enforcer")
	require.Empty(t, o.process.ListRunning())
}
