//go:build e2e

package e2e

import (
	"runtime"
	"testing"
	"time"
)

// TestJustRunBootsDaemons covers Issue 1: `just run` must successfully boot
// bitwindowd and orchestratord on every supported OS. We assert positive
// signals (processes alive, ports listening, RPC responsive) rather than
// matching error strings, which are noisy during the normal startup race.
func TestJustRunBootsDaemons(t *testing.T) {
	skipIfNoDisplay(t)

	const bootDeadline = 6 * time.Minute
	const pollInterval = 2 * time.Second
	const rpcDeadline = 30 * time.Second

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

	// 2. orchestratord process — bitwindowd spawns it as a subprocess.
	waitUntil(t, bootDeadline, pollInterval, "orchestratord did not start", func() bool {
		return len(processPIDs(t, orchestratordName)) > 0
	})
	t.Logf("orchestratord pids: %s", prettyPIDs(processPIDs(t, orchestratordName)))

	// 3. Ports accepting connections — proves daemons got past init.
	waitForPort(t, bitwindowdPort, rpcDeadline, "bitwindowd")
	waitForPort(t, orchestratordPort, rpcDeadline, "orchestratord")
	t.Logf("both daemons listening on their ports")

	// 4. orchestratord RPC actually responds — proves it's serving, not
	//    merely holding the port.
	waitForOrchestratorRPC(t, rpcDeadline)
	t.Log("orchestratord RPC is responsive")

	// 5. Give it 10s to surface any early crash, then verify the daemons
	//    are still alive (no crash loop).
	time.Sleep(10 * time.Second)

	if got := len(processPIDs(t, bitwindowdName)); got == 0 {
		run.dumpDiagnostics(t)
		t.Fatal("bitwindowd exited after boot")
	}
	if got := len(processPIDs(t, orchestratordName)); got == 0 {
		run.dumpDiagnostics(t)
		t.Fatal("orchestratord exited after boot")
	}

	t.Log("boot test passed: bitwindowd and orchestratord running + responsive")
}
