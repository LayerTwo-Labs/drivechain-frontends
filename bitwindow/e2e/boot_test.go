//go:build e2e

package e2e

import (
	"runtime"
	"testing"
	"time"
)

// TestJustRunBootsDaemons covers Issue 1: `just run` must successfully boot
// bitwindowd and drivechaind on every supported OS. We assert positive
// signals (processes alive, ports listening, RPC responsive) rather than
// matching error strings, which are noisy during the normal startup race.
func TestJustRunBootsDaemons(t *testing.T) {
	skipIfNoDisplay(t)

	// 9 minutes: Windows CI runners are slow to build + launch the Flutter app,
	// and bitwindowd was intermittently not appearing within 6m.
	const bootDeadline = 9 * time.Minute
	const pollInterval = 2 * time.Second
	const rpcDeadline = 90 * time.Second // cold macOS/Windows CI runners are slow to make drivechaind RPC-ready

	t.Logf("Issue 1 / boot: launching `just run` on %s", runtime.GOOS)

	run := startJustRun(t, nil)
	t.Cleanup(func() {
		run.dumpDiagnostics(t)
		run.stop(t, 15*time.Second)
	})

	// 1. bitwindowd process — Flutter spawns it directly.
	waitUntil(t, bootDeadline, pollInterval, "bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	t.Logf("bitwindowd pids: %s", prettyPIDs(processPIDs(t, bitwindowdName)))

	// 2. drivechaind process — bitwindowd spawns it as a subprocess.
	waitUntil(t, bootDeadline, pollInterval, "drivechaind did not start", func() bool {
		return len(processPIDs(t, drivechaindName)) > 0
	})
	t.Logf("drivechaind pids: %s", prettyPIDs(processPIDs(t, drivechaindName)))

	// 3. Ports accepting connections — proves daemons got past init.
	waitForPort(t, bitwindowdPort, rpcDeadline, "bitwindowd")
	waitForPort(t, drivechaindPort, rpcDeadline, "drivechaind")
	t.Logf("both daemons listening on their ports")

	// 4. drivechaind RPC actually responds — proves it's serving, not
	//    merely holding the port.
	waitForOrchestratorRPC(t, rpcDeadline, run.dataDir)
	t.Log("drivechaind RPC is responsive")

	// 5. Give it 10s to surface any early crash, then verify the daemons
	//    are still alive (no crash loop).
	time.Sleep(10 * time.Second)

	if got := len(processPIDs(t, bitwindowdName)); got == 0 {
		run.dumpDiagnostics(t)
		t.Fatal("bitwindowd exited after boot")
	}
	if got := len(processPIDs(t, drivechaindName)); got == 0 {
		run.dumpDiagnostics(t)
		t.Fatal("drivechaind exited after boot")
	}

	t.Log("boot test passed: bitwindowd and drivechaind running + responsive")
}
