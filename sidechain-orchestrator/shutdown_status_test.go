package orchestrator

import (
	"context"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestStop_EmitsStoppingThenStopped guards the frontend-visible shutdown
// sequence: the daemon-status card relies on stoppingBinary flipping to
// true while the graceful-shutdown signal is in flight, and back to false
// once the process is actually gone. The frontend polls listBinaries on a
// 1s timer; this test pins the underlying onChange-edge contract that
// keeps the per-monitor state in sync, even though it's currently unwired.
func TestStop_EmitsStoppingThenStopped(t *testing.T) {
	o := newTestOrchestrator(t)

	// Use a short-lived system binary so process.Stop has something real
	// to terminate. sleep(60) is plenty of headroom.
	symlinkSystemBinary(t, o.DataDir, "sleep")
	cfg := BinaryConfig{
		Name:       "sleep-test",
		BinaryName: "sleep",
		ChainLayer: 1,
	}
	o.configs["sleep-test"] = cfg

	// Manually wire a monitor with a no-op checker so we can capture
	// onChange events. The orchestrator's Stop path looks up the monitor
	// by name in o.monitors — this seeds it.
	mon := o.getOrCreateMonitor("sleep-test", &fakeChecker{}, nil)

	var (
		mu              sync.Mutex
		stoppingHistory []bool
	)
	mon.SetOnChange(func() {
		mu.Lock()
		stoppingHistory = append(stoppingHistory, mon.StoppingBinary())
		mu.Unlock()
	})

	pid, err := o.process.Start(context.Background(), cfg, []string{"30"}, nil)
	require.NoError(t, err)
	require.Greater(t, pid, 0)

	// Verify Stop emits stopping=true at least once before the process
	// is fully reaped, then stopping=false (via MarkStopped) after.
	require.NoError(t, o.Stop(context.Background(), "sleep-test", false))

	// Give onChange callbacks a beat to flush.
	time.Sleep(150 * time.Millisecond)

	mu.Lock()
	defer mu.Unlock()
	assert.Contains(t, stoppingHistory, true, "monitor must emit stoppingBinary=true during graceful shutdown — UI badge depends on it")
	if len(stoppingHistory) > 0 {
		assert.False(t, stoppingHistory[len(stoppingHistory)-1], "final state must be stoppingBinary=false (MarkStopped) so the card doesn't stick on the stopping badge after the process exits")
	}
}

// TestStop_OnNonRunningStillTogglesStopping ensures Stop is idempotent on
// the monitor side: even if process.Stop returns "not running" or similar,
// the monitor still gets MarkStopped so the restart timer won't bring the
// binary back to life behind the user's back.
func TestStop_OnNonRunningStillTogglesStopping(t *testing.T) {
	o := newTestOrchestrator(t)

	cfg := BinaryConfig{Name: "ghost", BinaryName: "ghost"}
	o.configs["ghost"] = cfg
	mon := o.getOrCreateMonitor("ghost", &fakeChecker{}, nil)

	var changes int32
	mon.SetOnChange(func() { atomic.AddInt32(&changes, 1) })

	// process.Stop on a non-running binary returns an error; orch.Stop
	// surfaces it but must still finalize the monitor state.
	_ = o.Stop(context.Background(), "ghost", false)

	time.Sleep(50 * time.Millisecond)

	assert.GreaterOrEqual(t, atomic.LoadInt32(&changes), int32(1), "MarkStopped must fire onChange even when process wasn't running, so the watcher's restart timer is suppressed")
	assert.False(t, mon.StoppingBinary(), "stoppingBinary must clear after MarkStopped")
}

// TestMarkStopped_SuppressesRestartTimer is the orchestrator-architecture
// invariant: once the user has explicitly stopped a binary, the restart
// timer must not auto-respawn it. Otherwise the only way to keep a binary
// off would be to also kill the orchestrator.
func TestMarkStopped_SuppressesRestartTimer(t *testing.T) {
	o := newTestOrchestrator(t)
	mon := o.getOrCreateMonitor("noop", &fakeChecker{}, nil)

	var restarts int32
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	mon.StartRestartTimer(
		ctx,
		func(_ context.Context) error {
			atomic.AddInt32(&restarts, 1)
			return nil
		},
		func() (int, bool) { return 1, true }, // pretend the process always just exited
	)

	// Mark stopped immediately. The restart timer fires every 500ms — give
	// it a couple of ticks to misbehave if the suppression is broken.
	mon.MarkStopped()
	time.Sleep(1100 * time.Millisecond)

	assert.Equal(t, int32(0), atomic.LoadInt32(&restarts), "MarkStopped must short-circuit the restart timer; otherwise stopped-by-user binaries come back from the dead")
}
