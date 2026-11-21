package orchestrator

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestWaitForConnectedOrExitWakesOnConnect(t *testing.T) {
	o := newTestOrchestrator(t)
	checker := &mockChecker{}
	mon := o.getOrCreateMonitor("wake-test", checker, nil)

	const rounds = 10
	start := time.Now()
	for range rounds {
		checker.healthy.Store(false)
		mon.testConnection(t.Context())
		require.False(t, mon.Connected())

		done := make(chan error, 1)
		go func() { done <- o.waitForConnectedOrExit(t.Context(), mon, nil) }()
		time.Sleep(10 * time.Millisecond)
		checker.healthy.Store(true)
		mon.testConnection(t.Context())
		select {
		case err := <-done:
			require.NoError(t, err)
		case <-time.After(5 * time.Second):
			t.Fatal("the wait did not see the connect")
		}
	}
	// A 100 ms poll takes at least 1 s for ten rounds.
	assert.Less(t, time.Since(start), 600*time.Millisecond)
}

func TestExitWatchedStartReturnsAtSpawn(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	writeTestScript(t, dir, "slow", "sleep 5", 0o755)

	start := time.Now()
	_, err := pm.StartWithOptions(t.Context(), BinaryConfig{Name: "slow", BinaryName: "slow"}, nil, nil, ProcessStartOptions{ExitWatched: true})
	require.NoError(t, err)
	assert.Less(t, time.Since(start), earlyExitWindow)
}

func TestAwaitStartReturnsAnExitInTheWindow(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	writeTestScript(t, dir, "crash", "echo boom >&2; exit 3", 0o755)
	o := &Orchestrator{process: pm}
	mon := NewConnectionMonitor("crash", &mockChecker{}, nil, testLogger(t))

	_, err := pm.StartWithOptions(t.Context(), BinaryConfig{Name: "crash", BinaryName: "crash"}, nil, nil, ProcessStartOptions{ExitWatched: true})
	require.NoError(t, err)
	proc := pm.LatestRun("crash")
	require.Eventually(t, proc.Exited, 20*time.Second, time.Millisecond)
	err = o.awaitStart(t.Context(), mon, proc)
	require.ErrorContains(t, err, "crash exited with code 3")
}

func TestAwaitStartAcceptsAProcessThatOutlivesTheWindow(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	writeTestScript(t, dir, "quiet", "sleep 5", 0o755)
	o := &Orchestrator{process: pm}
	mon := NewConnectionMonitor("quiet", &mockChecker{}, nil, testLogger(t))

	_, err := pm.StartWithOptions(t.Context(), BinaryConfig{Name: "quiet", BinaryName: "quiet"}, nil, nil, ProcessStartOptions{ExitWatched: true})
	require.NoError(t, err)
	require.NoError(t, o.awaitStart(t.Context(), mon, pm.LatestRun("quiet")))
}
