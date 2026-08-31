//go:build e2e

package e2e

import (
	"runtime"
	"testing"
	"time"
)

// TestWindowCloseShutsDownDaemons covers the GUI window-close variant of
// Issue 2. The `setupSignalHandlers` path in bitwindow/lib/main.dart
// responds to SIGINT/SIGTERM and calls BinaryProvider.onShutdown() — that's
// what TestJustRunShutsDownDaemons exercises. The reported bug however
// triggers on clicking the red X / pressing Cmd+Q / Alt+F4, which goes
// through WindowListener.onWindowClose in root_page.dart, a completely
// different code path. This test dispatches the platform-native window
// close event (no POSIX signals) and asserts bitwindowd + drivechaind
// still exit.
func TestWindowCloseShutsDownDaemons(t *testing.T) {
	skipIfNoDisplay(t)

	const bootPoll = 2 * time.Second
	// 5m: onWindowClose acks fast but drivechaind finishes a graceful bitcoind
	// drain in the background before exiting (see RootPage.onWindowClose). On a
	// cold macOS runner that drain is slow and variable (observed 160-250s), so
	// wait well clear of it. The test's own go-test timeout is 15m.
	const shutdownDeadline = 5 * time.Minute
	const shutdownPoll = 500 * time.Millisecond

	t.Logf("window-close shutdown test on %s", runtime.GOOS)

	run := startJustRun(t, nil)
	t.Cleanup(func() {
		run.dumpDiagnostics(t)
		// Force-kill fallback in case the window-close attempt didn't
		// terminate the `just run` tree.
		run.stop(t, 5*time.Second)
	})

	// Boot preconditions — same as the SIGINT shutdown test.
	waitUntil(t, bootDeadline, bootPoll, "bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	waitUntil(t, bootDeadline, bootPoll, "drivechaind did not start", func() bool {
		return len(processPIDs(t, drivechaindName)) > 0
	})

	appName := flutterAppProcessName()
	waitUntil(t, bootDeadline, bootPoll, "Flutter app process did not start", func() bool {
		return len(processPIDs(t, appName)) > 0
	})
	appPIDs := processPIDs(t, appName)
	t.Logf("booted: %s=%s bitwindowd=%s drivechaind=%s",
		appName, prettyPIDs(appPIDs),
		prettyPIDs(processPIDs(t, bitwindowdName)),
		prettyPIDs(processPIDs(t, drivechaindName)))

	// Let late-init work finish so the shutdown path isn't racing.
	time.Sleep(5 * time.Second)

	// Dispatch the OS-native close event to the GUI app — simulates
	// red-X / Cmd+Q / Alt+F4. This path goes through onWindowClose in
	// root_page.dart, not the signal handler.
	t.Log("sending window-close event")
	if err := closeAppViaWindowSystem(t, appPIDs[0]); err != nil {
		t.Fatalf("closeAppViaWindowSystem: %v", err)
	}

	// Now assert the daemons actually exit. If bitwindow's
	// onWindowClose → onShutdown flow has a bug, bitwindowd and/or
	// drivechaind will still be alive when the deadline fires.
	waitUntil(t, shutdownDeadline, shutdownPoll, "bitwindowd did not exit after window-close", func() bool {
		return len(processPIDs(t, bitwindowdName)) == 0
	})
	if pids := processPIDs(t, bitwindowdName); len(pids) > 0 {
		run.dumpDiagnostics(t)
		t.Fatalf("bitwindowd lingered after window-close: %s", prettyPIDs(pids))
	}

	waitUntil(t, shutdownDeadline, shutdownPoll, "drivechaind did not exit after window-close", func() bool {
		return len(processPIDs(t, drivechaindName)) == 0
	})
	if pids := processPIDs(t, drivechaindName); len(pids) > 0 {
		run.dumpDiagnostics(t)
		t.Fatalf("drivechaind lingered after window-close: %s", prettyPIDs(pids))
	}

	t.Log("window-close test passed: GUI close event cleaned up both daemons")
}
