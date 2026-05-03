package orchestrator

import (
	"context"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// TestRestartDaemon_UnknownBinary verifies that asking to restart an
// unknown binary fails fast with a config error rather than silently
// dispatching a no-op goroutine.
func TestRestartDaemon_UnknownBinary(t *testing.T) {
	o := newTestOrchestrator(t)
	_, err := o.RestartDaemon(context.Background(), "nonexistent")
	require.Error(t, err)
}

// TestRestartDaemon_EnforcerLeavesBitcoindMonitorUntouched is the regression
// guard for the "restart enforcer surfaces 'bitcoind is already running' on
// Bitcoin Core's card" bug.
//
// Before the fix, every restart went through StartWithL1's full L1 chain.
// If coreMon briefly reported not connected (transient RPC blip after a
// previous stop, slow first ping, etc.) the bitcoind block called
// process.Start("bitcoind", ...). With pm.processes already holding bitcoind,
// that returned "bitcoind is already running" — failBoot then surfaced the
// error on the bitcoind monitor as a phantom connection error visible on
// Bitcoin Core's card, even though the user had only clicked Restart on
// the enforcer.
//
// With the dedicated RestartDaemon path, restarting "enforcer" must never
// touch bitcoind state. This test wedges the orchestrator into the exact
// pre-condition that triggered the old bug and asserts the bitcoind
// monitor's ConnectionError stays clear of the phantom string.
func TestRestartDaemon_EnforcerLeavesBitcoindMonitorUntouched(t *testing.T) {
	o := newTestOrchestrator(t)

	// Pre-populate pm.processes with bitcoind. This is the state that
	// makes the old buggy path's process.Start("bitcoind", ...) return
	// "bitcoind is already running".
	bitcoindCfg, _ := o.getConfig("bitcoind")
	o.process.AdoptProcess(bitcoindCfg, 1234)

	// Materialise the bitcoind monitor with the same checker the production
	// code would use. We deliberately do NOT call testConnection — the
	// regression isn't about the monitor's pre-state, it's about whether
	// RestartDaemon("enforcer") surfaces a phantom "already running" error
	// here as a side effect.
	coreChecker := &mockChecker{}
	coreMon := o.getOrCreateMonitor("bitcoind", coreChecker, bitcoindStartupPatterns)
	require.Empty(t, coreMon.ConnectionError())

	// Tight timeout: the inner enforcer start path will block on download
	// and process spawn, neither of which we want to actually exercise.
	// Cancellation propagates and the goroutine returns.
	ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
	defer cancel()

	ch, err := o.RestartDaemon(ctx, "enforcer")
	require.NoError(t, err)

	for range ch {
	}

	// The phantom error string from process.go's "%s is already running"
	// must never reach Bitcoin Core's monitor on a sibling-daemon restart.
	got := coreMon.ConnectionError()
	if strings.Contains(got, "already running") {
		t.Errorf("bitcoind monitor.ConnectionError = %q after RestartDaemon(\"enforcer\"); restart enforcer must not surface 'already running' phantom errors on bitcoind", got)
	}
	if strings.Contains(got, "bitcoind") && strings.Contains(got, "start") {
		t.Errorf("bitcoind monitor.ConnectionError = %q after RestartDaemon(\"enforcer\"); the enforcer restart path must not call into bitcoind's failBoot routing", got)
	}
}

// TestPrepareCoreArgs_NoOpWhenAlreadySet verifies the extracted helper
// doesn't clobber explicitly-supplied core args.
func TestPrepareCoreArgs_NoOpWhenAlreadySet(t *testing.T) {
	o := newTestOrchestrator(t)
	opts := StartOpts{CoreArgs: []string{"-existing=arg"}}
	o.prepareCoreArgs(&opts)
	require.Equal(t, []string{"-existing=arg"}, opts.CoreArgs)
}

// TestPrepareCoreArgs_NoOpWhenBitcoinConfNil verifies the extracted helper
// is a safe no-op when no config manager is wired.
func TestPrepareCoreArgs_NoOpWhenBitcoinConfNil(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = nil
	opts := StartOpts{}
	o.prepareCoreArgs(&opts)
	require.Empty(t, opts.CoreArgs)
}

// TestPrepareEnforcerArgs_NoOpWhenAlreadySet ensures the enforcer-args
// helper preserves caller-supplied args.
func TestPrepareEnforcerArgs_NoOpWhenAlreadySet(t *testing.T) {
	o := newTestOrchestrator(t)
	opts := StartOpts{EnforcerArgs: []string{"--my=arg"}}
	o.prepareEnforcerArgs(&opts)
	require.Equal(t, []string{"--my=arg"}, opts.EnforcerArgs)
}

// TestStartEnforcerWhenReady_AlreadyInPM_NoPhantomStart is the symmetric
// regression guard for the bitcoind-side IsRunning race PR #1703 fixed.
//
// Scenario: enforcer is adopted (sits in pm.processes from a PID file), the
// L1 cascade re-enters startEnforcerWhenReady, and enforcerMon.Connected()
// briefly reports false (transient blip, slow first ping). Without the
// guard, process.Start("enforcer", ...) returns "enforcer is already
// running" — a phantom error condition that the orchestrator should treat
// as "wait for the existing process's RPC to come back," not "boot
// failure."
//
// With the guard in place, the function falls through to
// waitForConnectedOrExit on the existing process. The pm entry for the
// adopted enforcer must remain intact (PID unchanged), and no
// "already running" string appears on the enforcer monitor's
// ConnectionError.
func TestStartEnforcerWhenReady_AlreadyInPM_NoPhantomStart(t *testing.T) {
	o := newTestOrchestrator(t)

	enforcerCfg, _ := o.getConfig("enforcer")
	const adoptedPid = 1234
	o.process.AdoptProcess(enforcerCfg, adoptedPid)
	require.True(t, o.process.IsRunning("enforcer"))

	// mockChecker keeps mon.Connected() false through the function's
	// connected-skip check, forcing the path that previously ran into
	// process.Start("enforcer", ...).
	enforcerChecker := &mockChecker{}
	enforcerMon := o.getOrCreateMonitor("enforcer", enforcerChecker, enforcerStartupPatterns)
	require.Empty(t, enforcerMon.ConnectionError())

	// Tight timeout: waitForConnectedOrExit blocks until the (fake) process
	// exits or ctx expires. We cancel quickly to keep the test fast.
	ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
	defer cancel()

	o.startEnforcerWhenReady(ctx, StartOpts{}, nil)

	// Adopted PID survives — the guard never spawned a new process and
	// never tried to mutate pm.processes.
	proc := o.process.Get("enforcer")
	require.NotNil(t, proc)
	require.Equal(t, adoptedPid, proc.Pid)

	// "already running" must never reach the enforcer monitor as a
	// surfaced error string.
	got := enforcerMon.ConnectionError()
	if strings.Contains(got, "already running") {
		t.Errorf("enforcer monitor.ConnectionError = %q; the IsRunning guard must prevent process.Start from racing pm.processes", got)
	}
}

// TestRestartDaemon_BitcoindLeavesEnforcerMonitorUntouched is the symmetric
// counterpart to TestRestartDaemon_EnforcerLeavesBitcoindMonitorUntouched.
// Confirms the per-daemon scope of RestartDaemon: restarting bitcoind must
// never touch enforcer state.
func TestRestartDaemon_BitcoindLeavesEnforcerMonitorUntouched(t *testing.T) {
	o := newTestOrchestrator(t)

	enforcerCfg, _ := o.getConfig("enforcer")
	o.process.AdoptProcess(enforcerCfg, 5678)

	enforcerChecker := &mockChecker{}
	enforcerMon := o.getOrCreateMonitor("enforcer", enforcerChecker, enforcerStartupPatterns)
	require.Empty(t, enforcerMon.ConnectionError())

	ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
	defer cancel()

	ch, err := o.RestartDaemon(ctx, "bitcoind")
	require.NoError(t, err)

	for range ch {
	}

	got := enforcerMon.ConnectionError()
	if strings.Contains(got, "already running") {
		t.Errorf("enforcer monitor.ConnectionError = %q after RestartDaemon(\"bitcoind\"); restart bitcoind must not surface 'already running' phantom errors on enforcer", got)
	}
}
