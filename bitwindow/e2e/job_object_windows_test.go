//go:build e2e && windows

package e2e

import (
	"os/exec"
	"strconv"
	"syscall"
	"testing"
	"time"
	"unsafe"
)

const processQueryLimitedInformation = 0x1000

var (
	kernel32           = syscall.NewLazyDLL("kernel32.dll")
	procIsProcessInJob = kernel32.NewProc("IsProcessInJob")
)

// isProcessInJob reports whether pid belongs to any job object.
func isProcessInJob(t *testing.T, pid int) bool {
	t.Helper()
	handle, err := syscall.OpenProcess(processQueryLimitedInformation, false, uint32(pid))
	if err != nil {
		t.Fatalf("OpenProcess(%d): %v", pid, err)
	}
	defer syscall.CloseHandle(handle) //nolint:errcheck

	var inJob int32
	ret, _, callErr := procIsProcessInJob.Call(
		uintptr(handle), 0, uintptr(unsafe.Pointer(&inJob)),
	)
	if ret == 0 {
		t.Fatalf("IsProcessInJob(%d): %v", pid, callErr)
	}
	return inJob != 0
}

func waitForBoot(t *testing.T) (appPIDs, daemonPIDs []int) {
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

	daemons := append(processPIDs(t, bitwindowdName), processPIDs(t, orchestratordName)...)
	return processPIDs(t, appName), daemons
}

// The app must belong to no job: a member of a KILL_ON_JOB_CLOSE job dies with
// the job, and so does everything it launched — which is what killed the updater.
func TestFlutterProcessIsNotInAJob(t *testing.T) {
	skipIfNoDisplay(t)

	run := startJustRun(t, nil)
	t.Cleanup(func() {
		run.dumpDiagnostics(t)
		run.stop(t, 5*time.Second)
	})

	appPIDs, _ := waitForBoot(t)

	for _, pid := range appPIDs {
		if isProcessInJob(t, pid) {
			t.Fatalf("app pid %d is in a job; anything it launches can be killed with it", pid)
		}
	}
}

// The daemons must be in the job — that is what still guarantees they die with
// the app however it dies.
func TestDaemonsAreInTheJob(t *testing.T) {
	skipIfNoDisplay(t)

	run := startJustRun(t, nil)
	t.Cleanup(func() {
		run.dumpDiagnostics(t)
		run.stop(t, 5*time.Second)
	})

	_, daemonPIDs := waitForBoot(t)

	if len(daemonPIDs) == 0 {
		t.Fatal("no daemons found to check")
	}
	for _, pid := range daemonPIDs {
		if !isProcessInJob(t, pid) {
			t.Fatalf("daemon pid %d is not in the job; it would outlive the app", pid)
		}
	}
}

// Force-killing the app without /T must still reap the daemons. Independent of
// the mechanism, so it also catches a future removal of the job.
func TestForceKillingAppReapsDaemons(t *testing.T) {
	skipIfNoDisplay(t)

	run := startJustRun(t, nil)
	t.Cleanup(func() {
		run.dumpDiagnostics(t)
		run.stop(t, 5*time.Second)
	})

	appPIDs, _ := waitForBoot(t)

	// No /T: the daemons must be reaped by the job, not by taskkill walking
	// the tree.
	for _, pid := range appPIDs {
		if out, err := exec.Command("taskkill", "/F", "/PID", strconv.Itoa(pid)).CombinedOutput(); err != nil {
			t.Fatalf("taskkill /F /PID %d: %v (%s)", pid, err, string(out))
		}
	}

	const reapDeadline = 60 * time.Second
	const reapPoll = 500 * time.Millisecond
	waitUntil(t, reapDeadline, reapPoll, "bitwindowd survived a force-kill of the app", func() bool {
		return len(processPIDs(t, bitwindowdName)) == 0
	})
	waitUntil(t, reapDeadline, reapPoll, "orchestratord survived a force-kill of the app", func() bool {
		return len(processPIDs(t, orchestratordName)) == 0
	})
}
