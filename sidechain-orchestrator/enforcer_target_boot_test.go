package orchestrator

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A boot whose target is the enforcer keeps the restart the L1 boot set, so a
// crashed enforcer comes back with its own arguments.
func TestAwaitBootedEnforcer_KeepsTheEnforcerRestart(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	cfg := BinaryConfig{Name: "enforcer", DisplayName: "BIP300301 Enforcer"}

	checker := &mockChecker{}
	mon := o.getOrCreateMonitor("enforcer", checker, enforcerStartupPatterns)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	mon.StartConnectionTimer(ctx)
	defer mon.StopAllTimers()

	var restartArgs []string
	mon.StartRestartTimer(ctx,
		func(context.Context) error {
			restartArgs = []string{"--node-rpc-addr=127.0.0.1:18302"}
			return nil
		},
		func() (int, bool) { return 0, false },
	)

	ch := make(chan StartupProgress, 4)
	done := make(chan struct{})
	go func() {
		defer close(done)
		o.awaitBootedEnforcer(ctx, cfg, ch)
	}()
	checker.healthy.Store(true)
	<-done
	close(ch)

	var last StartupProgress
	for p := range ch {
		require.NoError(t, p.Error)
		last = p
	}
	assert.True(t, last.Done)

	mon.mu.Lock()
	restart := mon.restartFunc
	mon.mu.Unlock()
	require.NoError(t, restart(ctx))
	assert.Equal(t, []string{"--node-rpc-addr=127.0.0.1:18302"}, restartArgs)
}
