//go:build e2e

package e2e

import (
	"runtime"
	"testing"
	"time"
)

// exitPath is one way a user or the OS stops BitWindow.
type exitPath struct {
	name string
	// quit stops the app by this path. It gets the pids of the Flutter app.
	quit func(t *testing.T, appPIDs []int)
	// unixOnly marks a path the app cannot handle on Windows.
	unixOnly bool
}

// TestEveryExitPathRestartsClean drives each way out of BitWindow and checks the
// next launch serves RPC and keeps the wallet.
//
// The exit tests beside this one prove the daemons go away. This one proves the
// user gets a working app back, which is the half a crash report starts from.
//
// Each case relaunches as soon as the app process goes, without a wait for the
// daemons. A user who quits and starts again does not wait either, and neither
// does an update.
func TestEveryExitPathRestartsClean(t *testing.T) {
	skipIfNoDisplay(t)

	paths := []exitPath{
		{
			// Ctrl+C in a terminal, and the polite stop an updater sends first.
			name:     "sigint",
			unixOnly: true,
			quit: func(t *testing.T, appPIDs []int) {
				for _, pid := range appPIDs {
					if err := signalPID(pid, "SIGINT"); err != nil {
						t.Fatalf("SIGINT app pid %d: %v", pid, err)
					}
				}
			},
		},
		{
			// `kill`, a logout, and an updater that escalates.
			name:     "sigterm",
			unixOnly: true,
			quit: func(t *testing.T, appPIDs []int) {
				for _, pid := range appPIDs {
					if err := signalPID(pid, "SIGTERM"); err != nil {
						t.Fatalf("SIGTERM app pid %d: %v", pid, err)
					}
				}
			},
		},
		{
			// Force Quit and Activity Monitor. No handler runs, so only the
			// owner watchdog reaps the daemons.
			name: "force-kill",
			quit: func(t *testing.T, appPIDs []int) {
				for _, pid := range appPIDs {
					if err := forceKillPID(pid); err != nil {
						t.Fatalf("force-kill app pid %d: %v", pid, err)
					}
				}
			},
		},
		{
			// Cmd+Q, the red X, and the Cocoa quit an update sends on macOS.
			// This one never becomes a POSIX signal.
			name: "window-close",
			quit: func(t *testing.T, appPIDs []int) {
				if err := closeAppViaWindowSystem(t, appPIDs[0]); err != nil {
					t.Fatalf("window-close app pid %d: %v", appPIDs[0], err)
				}
			},
		},
	}

	for _, path := range paths {
		t.Run(path.name, func(t *testing.T) {
			if path.unixOnly && runtime.GOOS == "windows" {
				t.Skip("the app watches no POSIX signal on windows")
			}
			assertRestartAfterExit(t, path)
		})
	}
}

func assertRestartAfterExit(t *testing.T, path exitPath) {
	t.Helper()

	const bootPoll = 2 * time.Second
	const rpcDeadline = 120 * time.Second
	// A force-killed app leaves the daemons to a polling watchdog.
	const appExitDeadline = 150 * time.Second

	dataDir := makeTempDataDir(t)
	appName := flutterAppProcessName()

	first := startJustRunIn(t, dataDir, nil)
	t.Cleanup(func() { first.stop(t, 10*time.Second) })

	waitUntil(t, bootDeadline, bootPoll, path.name+": bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	waitUntil(t, bootDeadline, bootPoll, path.name+": the app did not start", func() bool {
		return len(processPIDs(t, appName)) > 0
	})
	waitForPort(t, drivechaindPort, rpcDeadline, path.name+": first launch drivechaind")
	waitForOrchestratorRPC(t, rpcDeadline, dataDir)
	walletID := generateTestWallet(t, dataDir)

	appPIDs := processPIDs(t, appName)
	t.Logf("%s: quitting app pids=%s", path.name, prettyPIDs(appPIDs))
	path.quit(t, appPIDs)

	waitUntil(t, appExitDeadline, bootPoll, path.name+": the app survived the quit", func() bool {
		return len(processPIDs(t, appName)) == 0
	})

	// launchJustRun, not startJustRunIn: the sweep would kill a daemon that
	// the first launch still winds down, and that overlap is the real case.
	second := launchJustRun(t, dataDir, nil)
	t.Cleanup(func() {
		second.dumpDiagnostics(t)
		second.stop(t, 15*time.Second)
	})

	waitUntil(t, bootDeadline, bootPoll, path.name+": second launch bitwindowd did not start", func() bool {
		return len(processPIDs(t, bitwindowdName)) > 0
	})
	waitForPort(t, drivechaindPort, rpcDeadline, path.name+": second launch drivechaind")
	waitForOrchestratorRPC(t, rpcDeadline, dataDir)

	for _, signature := range []string{
		"its RPC port stays dead until BitWindow restarts",
		"exited with code -9",
		"drivechaind did not become ready",
	} {
		if second.stdout.contains(signature) || second.stderr.contains(signature) {
			second.dumpDiagnostics(t)
			t.Fatalf("%s: second launch logged %q", path.name, signature)
		}
	}

	hasWallet, activeID := walletStatus(t, dataDir)
	if !hasWallet || activeID != walletID {
		second.dumpDiagnostics(t)
		t.Fatalf("%s: second launch active_wallet_id=%q has_wallet=%t, want %q", path.name, activeID, hasWallet, walletID)
	}

	t.Logf("%s: the next launch served RPC and kept wallet_id=%s", path.name, walletID)
}
