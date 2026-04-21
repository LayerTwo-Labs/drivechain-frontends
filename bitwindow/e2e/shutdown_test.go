//go:build e2e

package e2e

import (
	"runtime"
	"testing"
	"time"
)

// TestJustRunShutsDownDaemons covers Issue 2: closing the bitwindow window
// should tear down bitwindowd and orchestratord. The reported symptoms are
// that bitwindowd lingers on Mac+Linux and orchestratord specifically lingers
// on Linux, so we assert OS-level process death rather than Flutter-side
// state.
func TestJustRunShutsDownDaemons(t *testing.T) {
	skipIfNoDisplay(t)

	const bootDeadline = 6 * time.Minute
	const bootPoll = 2 * time.Second
	const shutdownDeadline = 30 * time.Second
	const shutdownPoll = 500 * time.Millisecond

	t.Logf("Issue 2 / shutdown: launching `just run` on %s", runtime.GOOS)

	run := startJustRun(t, nil)
	t.Cleanup(func() {
		run.dumpDiagnostics(t)
		run.stop(t, 5*time.Second)
	})

	// Wait for full boot — same preconditions as Issue 1, otherwise we'd be
	// testing shutdown of a half-booted app which doesn't match the bug.
	waitUntil(t, bootDeadline, bootPoll, "bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	waitUntil(t, bootDeadline, bootPoll, "orchestratord did not start", func() bool {
		return len(processPIDs(t, orchestratordName)) > 0
	})
	bitwindowdBefore := processPIDs(t, bitwindowdName)
	orchestratordBefore := processPIDs(t, orchestratordName)
	t.Logf("booted: bitwindowd=%s orchestratord=%s",
		prettyPIDs(bitwindowdBefore), prettyPIDs(orchestratordBefore))

	// Let the app settle so shutdown isn't racing against late init work.
	time.Sleep(5 * time.Second)

	// Request a graceful shutdown and wait up to `shutdownDeadline` for the
	// whole tree to exit. This mirrors the user closing the window — we
	// don't force-kill here; any force escalation inside stop() is a FAIL
	// signal for this test (see below).
	t.Log("requesting graceful shutdown")
	run.stop(t, shutdownDeadline)

	// bitwindowd must be gone. This is the Mac+Linux symptom the user
	// reported: "Bitwindowd isn't shutting down properly when you close
	// Bitwindow."
	waitUntil(t, shutdownDeadline, shutdownPoll, "bitwindowd did not exit after shutdown", func() bool {
		return len(processPIDs(t, bitwindowdName)) == 0
	})
	if pids := processPIDs(t, bitwindowdName); len(pids) > 0 {
		run.dumpDiagnostics(t)
		t.Fatalf("bitwindowd lingered after shutdown: %s", prettyPIDs(pids))
	}

	// orchestratord must be gone. Linux was the user's specific report:
	// "The orchestrator also isn't shutting down on Linux".
	waitUntil(t, shutdownDeadline, shutdownPoll, "orchestratord did not exit after shutdown", func() bool {
		return len(processPIDs(t, orchestratordName)) == 0
	})
	if pids := processPIDs(t, orchestratordName); len(pids) > 0 {
		run.dumpDiagnostics(t)
		t.Fatalf("orchestratord lingered after shutdown: %s", prettyPIDs(pids))
	}

	t.Log("shutdown test passed: bitwindowd and orchestratord both exited cleanly")
}
