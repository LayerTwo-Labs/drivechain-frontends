//go:build e2e

package e2e

import (
	"fmt"
	"testing"
	"time"
)

// A force-killed app must leave nothing behind. No signal reaches the daemons
// here, so only their owner watchdog can reap them.
func TestForceKillingAppReapsDaemons(t *testing.T) {
	skipIfNoDisplay(t)

	run := startJustRun(t, nil)
	t.Cleanup(func() {
		run.dumpDiagnostics(t)
		run.stop(t, 5*time.Second)
	})

	for _, pid := range waitForBoot(t) {
		if err := forceKillPID(pid); err != nil {
			t.Fatalf("force-kill app pid %d: %v", pid, err)
		}
	}

	// The watchdog polls, and orchestratord drains bitcoind before it exits.
	const reapDeadline = 150 * time.Second
	const reapPoll = time.Second
	for _, name := range []string{bitwindowdName, orchestratordName} {
		waitUntil(t, reapDeadline, reapPoll,
			fmt.Sprintf("%s survived a force-kill of the app", name),
			func() bool { return len(processPIDs(t, name)) == 0 },
		)
	}
}

// waitForBoot returns the app pids once both daemons and the app are up.
func waitForBoot(t *testing.T) []int {
	t.Helper()
	const bootDeadline = 9 * time.Minute
	const bootPoll = 2 * time.Second

	waitUntil(t, bootDeadline, bootPoll, "bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	waitUntil(t, bootDeadline, bootPoll, "orchestratord did not start", func() bool {
		return len(processPIDs(t, orchestratordName)) > 0
	})

	appName := flutterAppProcessName()
	waitUntil(t, bootDeadline, bootPoll, "Flutter app process did not start", func() bool {
		return len(processPIDs(t, appName)) > 0
	})
	return processPIDs(t, appName)
}
