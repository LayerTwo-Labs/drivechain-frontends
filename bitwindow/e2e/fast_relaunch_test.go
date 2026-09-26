//go:build e2e

package e2e

import (
	"runtime"
	"testing"
	"time"
)

// TestFastRelaunchKeepsDrivechaindAlive covers the fault a user hit: a relaunch
// inside drivechaind's owner grace overwrote assets/bin under the daemons the
// first launch still ran. macOS killed the new ones with SIGKILL, and the
// orchestrator RPC port stayed dead for the whole session.
//
// TestJustRunRestart waits for both daemons to exit before boot 2, so it never
// reaches this state. This test relaunches at once and leaves the overlap.
func TestFastRelaunchKeepsDrivechaindAlive(t *testing.T) {
	skipIfNoDisplay(t)

	const bootPoll = 2 * time.Second
	const rpcDeadline = 90 * time.Second
	const treeDeadline = 30 * time.Second

	t.Logf("fast relaunch: two `just run` with an overlap on %s", runtime.GOOS)

	dataDir := makeTempDataDir(t)

	first := startJustRunIn(t, dataDir, nil)
	t.Cleanup(func() { first.stop(t, 5*time.Second) })

	waitUntil(t, bootDeadline, bootPoll, "first launch: bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	waitForPort(t, drivechaindPort, rpcDeadline, "first launch: drivechaind")
	waitForOrchestratorRPC(t, rpcDeadline, dataDir)
	walletID := generateTestWallet(t, dataDir)

	// Quit the app tree and relaunch at once. drivechaind runs in its own
	// process group, so the tree signal leaves it alive for its grace period.
	first.stop(t, treeDeadline)
	t.Logf("first launch: app tree exited, drivechaind pids=%s", prettyPIDs(processPIDs(t, drivechaindName)))

	// launchJustRun, not startJustRunIn: the sweep would kill the very
	// drivechaind this test keeps alive.
	second := launchJustRun(t, dataDir, nil)
	t.Cleanup(func() {
		second.dumpDiagnostics(t)
		second.stop(t, 15*time.Second)
	})

	waitUntil(t, bootDeadline, bootPoll, "second launch: bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	waitForPort(t, drivechaindPort, rpcDeadline, "second launch: drivechaind")
	waitForOrchestratorRPC(t, rpcDeadline, dataDir)

	for _, signature := range []string{
		"its RPC port stays dead until BitWindow restarts",
		"exited with code -9",
		"drivechaind did not become ready",
	} {
		if second.stdout.contains(signature) || second.stderr.contains(signature) {
			second.dumpDiagnostics(t)
			t.Fatalf("second launch logged %q — the relaunch killed a running daemon", signature)
		}
	}

	hasWallet, activeID := walletStatus(t, dataDir)
	if !hasWallet || activeID != walletID {
		second.dumpDiagnostics(t)
		t.Fatalf("second launch: active_wallet_id=%q has_wallet=%t, want %q", activeID, hasWallet, walletID)
	}

	t.Logf("fast relaunch passed: drivechaind served through the overlap, wallet_id=%s", walletID)
}
