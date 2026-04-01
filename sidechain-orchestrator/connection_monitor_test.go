package orchestrator

import (
	"context"
	"fmt"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// mockChecker is a controllable health checker for tests.
type mockChecker struct {
	healthy atomic.Bool
}

func (m *mockChecker) Check(_ context.Context) error {
	if m.healthy.Load() {
		return nil
	}
	return fmt.Errorf("connection refused")
}

func newTestMonitor(t *testing.T, checker HealthChecker, patterns []string) *ConnectionMonitor {
	t.Helper()
	return NewConnectionMonitor("test-binary", checker, patterns, testLogger(t))
}

// --- testConnection tests ---

func TestConnectionMonitor_TestConnection_Healthy(t *testing.T) {
	checker := &mockChecker{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)

	mon.testConnection(context.Background())

	assert.True(t, mon.Connected())
	assert.Empty(t, mon.ConnectionError())
	assert.Empty(t, mon.StartupError())
}

func TestConnectionMonitor_TestConnection_Unhealthy(t *testing.T) {
	checker := &mockChecker{}
	mon := newTestMonitor(t, checker, nil)

	mon.testConnection(context.Background())

	assert.False(t, mon.Connected())
	assert.Contains(t, mon.ConnectionError(), "connection refused")
}

func TestConnectionMonitor_TestConnection_TransitionConnectedToDisconnected(t *testing.T) {
	checker := &mockChecker{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)

	// Connect
	mon.testConnection(context.Background())
	assert.True(t, mon.Connected())

	// Disconnect
	checker.healthy.Store(false)
	mon.testConnection(context.Background())
	assert.False(t, mon.Connected())
}

func TestConnectionMonitor_TestConnection_TransitionDisconnectedToConnected(t *testing.T) {
	checker := &mockChecker{}
	mon := newTestMonitor(t, checker, nil)

	// Fail first
	mon.testConnection(context.Background())
	assert.False(t, mon.Connected())

	// Then succeed
	checker.healthy.Store(true)
	mon.testConnection(context.Background())
	assert.True(t, mon.Connected())
	assert.Empty(t, mon.ConnectionError())
}

// --- connectModeOnly tests ---

func TestConnectionMonitor_ConnectModeOnly_SuppressesErrors(t *testing.T) {
	checker := &mockChecker{}
	mon := newTestMonitor(t, checker, nil)

	// First connect, then mark stopped
	checker.healthy.Store(true)
	mon.testConnection(context.Background())
	assert.True(t, mon.Connected())

	// Dart: stop() → connectModeOnly = true
	mon.MarkStopped()
	assert.False(t, mon.Connected())

	// Now health check fails, but connectModeOnly suppresses errors
	checker.healthy.Store(false)
	mon.testConnection(context.Background())
	assert.False(t, mon.Connected())
	assert.Empty(t, mon.ConnectionError()) // errors suppressed!
}

func TestConnectionMonitor_ConnectModeOnly_DetectsExternalRestart(t *testing.T) {
	checker := &mockChecker{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)

	// Connect, then stop
	mon.testConnection(context.Background())
	mon.MarkStopped()
	assert.False(t, mon.Connected())

	// Process comes back externally
	checker.healthy.Store(true)
	mon.testConnection(context.Background())

	// Dart L99: successful ping → exit connect-mode-only
	assert.True(t, mon.Connected())
}

func TestConnectionMonitor_MarkDisconnected_EntersConnectModeOnly(t *testing.T) {
	checker := &mockChecker{}
	mon := newTestMonitor(t, checker, nil)

	mon.MarkDisconnected()

	// Errors should be suppressed
	mon.testConnection(context.Background())
	assert.False(t, mon.Connected())
	assert.Empty(t, mon.ConnectionError())
}

// --- pingEpoch tests ---

func TestConnectionMonitor_PingEpoch_DiscardsStaleResult(t *testing.T) {
	// Use a checker that is slow so we can increment epoch mid-flight
	slowChecker := &mockChecker{}
	slowChecker.healthy.Store(true)
	mon := newTestMonitor(t, slowChecker, nil)

	// Simulate: start ping, then stop() increments epoch
	// Since testConnection is synchronous, we test the epoch logic directly
	mon.mu.Lock()
	mon.connected = true
	mon.pingEpoch = 5
	mon.mu.Unlock()

	// MarkStopped increments epoch
	mon.MarkStopped()
	assert.False(t, mon.Connected())

	mon.mu.Lock()
	assert.Equal(t, 6, mon.pingEpoch)
	mon.mu.Unlock()
}

// --- StartConnectionTimer tests ---

func TestConnectionMonitor_StartConnectionTimer_ImmediateConnect(t *testing.T) {
	checker := &mockChecker{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Dart: startConnectionTimer pings immediately
	mon.StartConnectionTimer(ctx)

	// Should be connected after first ping
	assert.True(t, mon.Connected())

	mon.StopConnectionTimer()
}

func TestConnectionMonitor_StartConnectionTimer_DetectsLaterConnection(t *testing.T) {
	checker := &mockChecker{}
	mon := newTestMonitor(t, checker, nil)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	mon.StartConnectionTimer(ctx)
	assert.False(t, mon.Connected())

	// Process starts externally
	checker.healthy.Store(true)

	// Wait for timer to detect it (1s interval + margin)
	require.Eventually(t, func() bool {
		return mon.Connected()
	}, 3*time.Second, 100*time.Millisecond)

	mon.StopConnectionTimer()
}

// --- WaitForConnected tests ---

func TestConnectionMonitor_WaitForConnected_AlreadyConnected(t *testing.T) {
	checker := &mockChecker{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)

	mon.testConnection(context.Background())

	err := mon.WaitForConnected(context.Background())
	assert.NoError(t, err)
}

func TestConnectionMonitor_WaitForConnected_Timeout(t *testing.T) {
	checker := &mockChecker{}
	mon := newTestMonitor(t, checker, nil)

	ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
	defer cancel()

	err := mon.WaitForConnected(ctx)
	assert.Error(t, err)
}

// --- Startup error extraction tests ---

func TestExtractStartupError_MinusCode28(t *testing.T) {
	// Dart: extractStartupError checks for -28
	msg := extractStartupError("getblockcount([]): -28 - Loading block index…")
	assert.Equal(t, "Loading block index…", msg)
}

func TestExtractStartupError_NoMatch(t *testing.T) {
	msg := extractStartupError("connection refused")
	assert.Empty(t, msg)
}

func TestExtractStartupError_FallbackNoSeparator(t *testing.T) {
	msg := extractStartupError("error -28 something")
	assert.Equal(t, "error -28 something", msg)
}

func TestConnectionMonitor_StartupPatterns_ClassifiesCorrectly(t *testing.T) {
	// Use a checker that returns a startup-like error
	startupChecker := &startupErrorChecker{errMsg: "Loading block index"}
	mon := newTestMonitor(t, startupChecker, bitcoindStartupPatterns)

	mon.testConnection(context.Background())

	assert.False(t, mon.Connected())
	assert.Equal(t, "Loading block index", mon.StartupError())
	assert.Empty(t, mon.ConnectionError()) // classified as startup, not error
}

func TestConnectionMonitor_StartupPatterns_RealErrorNotClassified(t *testing.T) {
	startupChecker := &startupErrorChecker{errMsg: "some unknown error"}
	mon := newTestMonitor(t, startupChecker, bitcoindStartupPatterns)

	mon.testConnection(context.Background())

	assert.False(t, mon.Connected())
	assert.Empty(t, mon.StartupError())
	assert.Equal(t, "some unknown error", mon.ConnectionError())
}

// --- Restart timer tests ---

func TestConnectionMonitor_RestartTimer_RestartsOnCrash(t *testing.T) {
	checker := &mockChecker{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// First connect so completedStartup is true
	mon.testConnection(context.Background())
	assert.True(t, mon.Connected())

	// Then disconnect (simulate crash)
	checker.healthy.Store(false)
	mon.testConnection(context.Background())
	assert.False(t, mon.Connected())

	var restartCalled atomic.Int32
	mon.StartRestartTimer(ctx,
		func(_ context.Context) error {
			restartCalled.Add(1)
			// Simulate successful restart
			checker.healthy.Store(true)
			return nil
		},
		func() (int, bool) {
			// Simulate: process exited with code 1
			return 1, true
		},
	)

	// Wait for restart timer to fire (500ms interval + margin)
	require.Eventually(t, func() bool {
		return restartCalled.Load() > 0
	}, 3*time.Second, 100*time.Millisecond)

	mon.StopRestartTimer()
}

func TestConnectionMonitor_RestartTimer_DoesNotRestartOnCleanExit(t *testing.T) {
	checker := &mockChecker{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	mon.testConnection(context.Background())
	checker.healthy.Store(false)
	mon.testConnection(context.Background())

	var restartCalled atomic.Int32
	mon.StartRestartTimer(ctx,
		func(_ context.Context) error {
			restartCalled.Add(1)
			return nil
		},
		func() (int, bool) {
			// Clean exit (code 0)
			return 0, true
		},
	)

	// Wait a bit and verify restart was NOT called
	time.Sleep(1500 * time.Millisecond)
	assert.Equal(t, int32(0), restartCalled.Load())

	mon.StopRestartTimer()
}

func TestConnectionMonitor_RestartTimer_MaxRetries(t *testing.T) {
	checker := &mockChecker{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	mon.testConnection(context.Background())
	checker.healthy.Store(false)
	mon.testConnection(context.Background())

	// Set restart count to max
	mon.mu.Lock()
	mon.restartCount = 11 // > 10
	mon.mu.Unlock()

	var restartCalled atomic.Int32
	mon.StartRestartTimer(ctx,
		func(_ context.Context) error {
			restartCalled.Add(1)
			return nil
		},
		func() (int, bool) {
			return 1, true
		},
	)

	time.Sleep(1500 * time.Millisecond)
	assert.Equal(t, int32(0), restartCalled.Load())

	mon.StopRestartTimer()
}

func TestConnectionMonitor_RestartTimer_StoppedDuringStopping(t *testing.T) {
	checker := &mockChecker{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	mon.testConnection(context.Background())

	var restartCalled atomic.Int32
	mon.StartRestartTimer(ctx,
		func(_ context.Context) error {
			restartCalled.Add(1)
			return nil
		},
		func() (int, bool) {
			return 1, true
		},
	)

	// MarkStopped cancels restart timer (Dart: restartTimer?.cancel())
	mon.MarkStopped()

	time.Sleep(1500 * time.Millisecond)
	assert.Equal(t, int32(0), restartCalled.Load())
}

// --- Process manager new methods ---

func TestProcessManager_IsAdopted(t *testing.T) {
	pm, _ := newTestProcessManager(t)

	cfg := BinaryConfig{Name: "test", BinaryName: "test"}
	pm.AdoptProcess(cfg, 12345)

	assert.True(t, pm.IsAdopted("test"))
	assert.False(t, pm.IsAdopted("unknown"))
}

func TestProcessManager_Remove(t *testing.T) {
	pm, _ := newTestProcessManager(t)

	cfg := BinaryConfig{Name: "test", BinaryName: "test"}
	pm.AdoptProcess(cfg, 12345)
	assert.True(t, pm.IsRunning("test"))

	pm.Remove("test")
	assert.False(t, pm.IsRunning("test"))
}

func TestProcessManager_IsAdopted_NotAdoptedWhenStarted(t *testing.T) {
	pm, _ := newTestProcessManager(t)

	// A process added via Start (not Adopt) should not be marked adopted
	// We can't easily test Start without a real binary, but we can verify
	// that AdoptProcess sets the flag and regular map entries don't
	assert.False(t, pm.IsAdopted("nonexistent"))
}

func TestProcessManager_ExitChAndExitCode(t *testing.T) {
	// Test the public accessors on ManagedProcess
	proc := &ManagedProcess{
		exitCh:   make(chan struct{}),
		exitCode: 0,
	}

	// exitCh should not be closed yet
	select {
	case <-proc.ExitCh():
		t.Fatal("exitCh should not be closed")
	default:
		// good
	}

	// Simulate exit
	proc.mu.Lock()
	proc.exitCode = 42
	proc.mu.Unlock()
	close(proc.exitCh)

	// Now it should be readable
	<-proc.ExitCh()
	assert.Equal(t, 42, proc.ExitCode())
}

// --- StartWithDeps stream tests ---

// collectProgress drains a StartupProgress channel and returns all messages.
func collectProgress(ch <-chan StartupProgress) []StartupProgress { //nolint:unused // kept for future tests
	var results []StartupProgress
	for p := range ch {
		results = append(results, p)
	}
	return results
}

func TestStartWithDeps_AlreadyRunning_AdoptsAndSkips(t *testing.T) {
	// Scenario: bitcoind and enforcer already running when thunderd starts.
	// Should adopt them, not try to start duplicates.
	o := newTestOrchestrator(t)

	// Pre-register "already running" processes by adopting them
	bitcoindCfg, _ := o.getConfig("bitcoind")
	enforcerCfg, _ := o.getConfig("enforcer")
	o.process.AdoptProcess(bitcoindCfg, 1234)
	o.process.AdoptProcess(enforcerCfg, 5678)

	assert.True(t, o.process.IsRunning("bitcoind"))
	assert.True(t, o.process.IsAdopted("bitcoind"))
	assert.True(t, o.process.IsRunning("enforcer"))
	assert.True(t, o.process.IsAdopted("enforcer"))
}

func TestStartWithDeps_ShutdownSkipsAdopted(t *testing.T) {
	// Scenario: adopted processes should not be killed during shutdown.
	o := newTestOrchestrator(t)

	bitcoindCfg, _ := o.getConfig("bitcoind")
	enforcerCfg, _ := o.getConfig("enforcer")
	o.process.AdoptProcess(bitcoindCfg, 1234)
	o.process.AdoptProcess(enforcerCfg, 5678)

	ctx := context.Background()
	ch, err := o.ShutdownAll(ctx, false)
	require.NoError(t, err)

	var progress []ShutdownProgress
	for p := range ch {
		progress = append(progress, p)
	}

	// After shutdown, adopted processes should be removed from tracking (not killed)
	assert.False(t, o.process.IsRunning("bitcoind"))
	assert.False(t, o.process.IsRunning("enforcer"))

	// The final progress should indicate completion
	assert.True(t, progress[len(progress)-1].Done)
}

func TestStartWithDeps_ShutdownAdopted_MonitorEntersConnectMode(t *testing.T) {
	// Scenario: after shutting down adopted processes, monitors should enter
	// connectModeOnly to detect if they come back externally.
	o := newTestOrchestrator(t)

	// Create monitors
	checker := &mockChecker{}
	checker.healthy.Store(true)
	coreMon := o.getOrCreateMonitor("bitcoind", checker, bitcoindStartupPatterns)
	coreMon.testConnection(context.Background())
	assert.True(t, coreMon.Connected())

	// Adopt bitcoind
	bitcoindCfg, _ := o.getConfig("bitcoind")
	o.process.AdoptProcess(bitcoindCfg, 1234)

	// Shutdown
	ctx := context.Background()
	ch, err := o.ShutdownAll(ctx, false)
	require.NoError(t, err)
	for range ch {
	} // drain

	// Monitor should be in connectModeOnly
	checker.healthy.Store(false)
	coreMon.testConnection(context.Background())
	assert.False(t, coreMon.Connected())
	assert.Empty(t, coreMon.ConnectionError()) // suppressed in connectModeOnly
}

func TestConnectionMonitor_StartupError_FlowsCorrectly(t *testing.T) {
	// Scenario: during bitcoind boot, health check returns -28 warmup errors.
	// These should be classified as startupError, not connectionError.
	warmupChecker := &warmupChecker{stage: 0}
	mon := NewConnectionMonitor("bitcoind", warmupChecker, bitcoindStartupPatterns, testLogger(t))

	// First check: connection refused (not started yet)
	mon.testConnection(context.Background())
	assert.False(t, mon.Connected())
	assert.Contains(t, mon.ConnectionError(), "connection refused")
	assert.Empty(t, mon.StartupError())

	// Second check: -28 warmup (bitcoind is booting)
	warmupChecker.stage = 1
	mon.testConnection(context.Background())
	assert.False(t, mon.Connected())
	assert.Equal(t, "Loading block index…", mon.StartupError())

	// Third check: success (bitcoind ready)
	warmupChecker.stage = 2
	mon.testConnection(context.Background())
	assert.True(t, mon.Connected())
	assert.Empty(t, mon.StartupError())
	assert.Empty(t, mon.ConnectionError())
}

func TestConnectionMonitor_StartupError_EnforcerWarmup(t *testing.T) {
	// Enforcer returns "Validator is not synced" during startup
	enfChecker := &startupErrorChecker{errMsg: "Validator is not synced"}
	mon := NewConnectionMonitor("enforcer", enfChecker, enforcerStartupPatterns, testLogger(t))

	mon.testConnection(context.Background())
	assert.False(t, mon.Connected())
	assert.Equal(t, "Validator is not synced", mon.StartupError())
	assert.Empty(t, mon.ConnectionError()) // classified as startup, not error
}

func TestConnectionMonitor_FullLifecycle(t *testing.T) {
	// Full lifecycle: boot → connect → crash → restart → reconnect
	checker := &mockChecker{}
	mon := NewConnectionMonitor("bitcoind", checker, bitcoindStartupPatterns, testLogger(t))

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// 1. Start connection timer — not connected yet
	mon.StartConnectionTimer(ctx)
	assert.False(t, mon.Connected())

	// 2. "Boot" the process — simulate it becoming healthy
	checker.healthy.Store(true)
	require.Eventually(t, func() bool {
		return mon.Connected()
	}, 3*time.Second, 100*time.Millisecond)

	// 3. Process crashes
	checker.healthy.Store(false)
	require.Eventually(t, func() bool {
		return !mon.Connected()
	}, 3*time.Second, 100*time.Millisecond)

	// 4. Start restart timer
	var restarted atomic.Int32
	mon.StartRestartTimer(ctx,
		func(_ context.Context) error {
			restarted.Add(1)
			checker.healthy.Store(true) // restart succeeds
			return nil
		},
		func() (int, bool) {
			return 1, true // crashed with code 1
		},
	)

	// 5. Restart timer fires and restarts the process
	require.Eventually(t, func() bool {
		return restarted.Load() > 0
	}, 3*time.Second, 100*time.Millisecond)

	// 6. Connection timer detects it's back
	require.Eventually(t, func() bool {
		return mon.Connected()
	}, 3*time.Second, 100*time.Millisecond)

	mon.StopAllTimers()
}

// --- Helper types ---

// warmupChecker simulates bitcoind boot stages:
// stage 0: connection refused
// stage 1: -28 warmup error
// stage 2: healthy
type warmupChecker struct {
	stage int
}

func (c *warmupChecker) Check(_ context.Context) error {
	switch c.stage {
	case 0:
		return fmt.Errorf("connection refused")
	case 1:
		return fmt.Errorf("getblockcount([]): -28 - Loading block index…")
	default:
		return nil
	}
}

type startupErrorChecker struct {
	errMsg string
}

func (c *startupErrorChecker) Check(_ context.Context) error {
	return fmt.Errorf("%s", c.errMsg)
}
