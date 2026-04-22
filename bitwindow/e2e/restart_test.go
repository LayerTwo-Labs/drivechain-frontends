//go:build e2e

package e2e

import (
	"runtime"
	"testing"
	"time"
)

// TestJustRunRestart covers Issue 3: after closing bitwindow cleanly, a
// second `just run` against the same datadir must find the wallet from
// the first run — not re-prompt for wallet generation.
//
// We generate a deterministic wallet on boot 1 (fixed BIP39 test mnemonic),
// record its wallet_id, shut down, boot again against the same datadir,
// and assert GetWalletStatus reports the same active wallet_id. Address
// derivation would be a stronger signal but needs bitcoind up, which adds
// a long sync dependency we don't want in a startup test.
func TestJustRunRestart(t *testing.T) {
	skipIfNoDisplay(t)

	const bootDeadline = 6 * time.Minute
	const bootPoll = 2 * time.Second
	const rpcDeadline = 30 * time.Second
	const shutdownDeadline = 30 * time.Second
	const shutdownPoll = 500 * time.Millisecond

	t.Logf("Issue 3 / restart: launching two successive `just run` on %s", runtime.GOOS)

	dataDir := makeTempDataDir(t)

	// ------------------------------------------------------------------
	// Boot 1 — generate wallet, save address at derivation index 0.
	// ------------------------------------------------------------------
	first := startJustRunIn(t, dataDir, nil)
	t.Cleanup(func() { first.stop(t, 5*time.Second) })

	waitUntil(t, bootDeadline, bootPoll, "first launch: bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	waitUntil(t, bootDeadline, bootPoll, "first launch: orchestratord did not start", func() bool {
		return len(processPIDs(t, orchestratordName)) > 0
	})
	waitForPort(t, orchestratordPort, rpcDeadline, "first launch: orchestratord")
	waitForOrchestratorRPC(t, rpcDeadline)

	firstWalletID := generateTestWallet(t)
	t.Logf("first launch: wallet created, wallet_id=%s", firstWalletID)

	first.stop(t, shutdownDeadline)
	waitUntil(t, shutdownDeadline, shutdownPoll, "first launch: bitwindowd lingered", func() bool {
		return len(processPIDs(t, bitwindowdName)) == 0
	})
	waitUntil(t, shutdownDeadline, shutdownPoll, "first launch: orchestratord lingered", func() bool {
		return len(processPIDs(t, orchestratordName)) == 0
	})
	t.Log("first launch: both daemons exited cleanly")

	// ------------------------------------------------------------------
	// Boot 2 — same datadir. Wallet must already exist; address[0] must
	// match. If bitwindow re-prompts for wallet generation (the reported
	// bug), GetWalletStatus.has_wallet will be false and the test fails.
	// ------------------------------------------------------------------
	second := startJustRunIn(t, dataDir, nil)
	t.Cleanup(func() {
		second.dumpDiagnostics(t)
		second.stop(t, 15*time.Second)
	})

	waitUntil(t, bootDeadline, bootPoll, "second launch: bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	waitUntil(t, bootDeadline, bootPoll, "second launch: orchestratord did not start", func() bool {
		return len(processPIDs(t, orchestratordName)) > 0
	})
	waitForPort(t, orchestratordPort, rpcDeadline, "second launch: orchestratord")
	waitForOrchestratorRPC(t, rpcDeadline)

	hasWallet, activeID := walletStatus(t)
	if !hasWallet {
		second.dumpDiagnostics(t)
		t.Fatalf("second launch: no wallet present — bitwindow re-prompted for wallet generation (active_wallet_id=%q)", activeID)
	}
	if activeID != firstWalletID {
		second.dumpDiagnostics(t)
		t.Fatalf("second launch: active_wallet_id=%s, want %s (different wallet — state was not persisted)", activeID, firstWalletID)
	}

	t.Logf("restart test passed: wallet_id=%s loaded on both boots — wallet persisted", firstWalletID)
}
