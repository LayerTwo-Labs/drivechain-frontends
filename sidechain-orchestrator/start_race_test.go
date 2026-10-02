package orchestrator

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A boot that loses the start of its binary to another caller waits for that
// start, and leaves no error on the monitor the two share.
func TestStartTargetOnly_WaitsForAStartAnotherCallerOwns(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	cfg := BinaryConfig{Name: "sleep-test", DisplayName: "sleep", BinaryName: "sleep"}

	checker := &mockChecker{}
	mon := o.getOrCreateMonitor(cfg.Name, checker, nil)

	o.process.mu.Lock()
	o.process.starting[cfg.Name] = true
	o.process.mu.Unlock()

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	prefetched := make(chan error)
	close(prefetched)
	ch := make(chan StartupProgress, 16)
	done := make(chan struct{})
	go func() {
		defer close(done)
		o.startTargetOnly(ctx, cfg, StartOpts{}, ch, prefetched)
	}()

	require.Never(t, func() bool {
		select {
		case <-done:
			return true
		default:
			return false
		}
	}, 500*time.Millisecond, 20*time.Millisecond, "the boot waits while the other start is in flight")

	checker.healthy.Store(true)
	<-done
	close(ch)

	var last StartupProgress
	for p := range ch {
		require.NoError(t, p.Error)
		last = p
	}
	assert.True(t, last.Done)
	assert.Empty(t, mon.ConnectionError())
}
