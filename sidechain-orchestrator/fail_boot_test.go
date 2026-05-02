package orchestrator

import (
	"context"
	"errors"
	"strings"
	"testing"
)

// TestFailBoot_PropagatesEverywhere is the regression guard for the
// "fatal boot error invisible to the frontend" bug. When pm.Start fails
// inside StartWithL1, the error needs to reach three places:
//
//  1. ConnectionMonitor.connectionError — so the next listBinaries poll
//     carries it to Flutter and DaemonConnectionCard renders the red error.
//  2. ConnectionMonitor.initializing = false — so the spinner stops.
//  3. StartupProgress.Error on the StartWithL1 stream — so the caller's
//     awaited future actually rejects (not silent "still initializing").
//
// The original bug: pm.Start returned `binary not found at /...bitcoin/bitcoind`
// (variant subfolder mismatch). Only path #3 was wired, BackendStateProvider
// logged + threw, and DaemonConnectionCard never saw the error because
// _syncConnectionState reads from the listBinaries snapshot (#1), not
// from the throw.
func TestFailBoot_PropagatesEverywhere(t *testing.T) {
	mon := NewConnectionMonitor("bitcoind", &fakeChecker{}, nil, testLogger(t))
	mon.SetInitializing(true)

	ch := make(chan StartupProgress, 1)
	bootErr := errors.New("binary not found at /bin/bitcoin/bitcoind")

	failBoot(mon, ch, "start bitcoind", bootErr)

	if mon.InitializingBinary() {
		t.Error("monitor.InitializingBinary still true after failBoot; spinner would never stop")
	}

	got := mon.ConnectionError()
	if got == "" {
		t.Fatal("monitor.connectionError empty after failBoot; listBinaries wouldn't carry the error to Flutter")
	}
	if !strings.Contains(got, "start bitcoind") || !strings.Contains(got, "binary not found") {
		t.Errorf("monitor.connectionError = %q, want both %q and %q substrings", got, "start bitcoind", "binary not found")
	}

	select {
	case progress := <-ch:
		if progress.Error == nil {
			t.Error("StartupProgress.Error nil; caller's await would not reject")
		}
		if !strings.Contains(progress.Error.Error(), "start bitcoind") {
			t.Errorf("StartupProgress.Error = %q, want prefix %q", progress.Error, "start bitcoind")
		}
	default:
		t.Error("no StartupProgress sent to channel")
	}
}

// fakeChecker is a HealthChecker stub for tests where we don't actually
// run a connection probe — only need a monitor instance to call methods on.
type fakeChecker struct{}

func (fakeChecker) Check(_ context.Context) error { return nil }
