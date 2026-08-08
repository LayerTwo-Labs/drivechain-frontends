//go:build e2e && windows

package e2e

import (
	"fmt"
	"os/exec"
	"strconv"
	"strings"
	"syscall"
	"testing"
	"time"
	"unsafe"
)

const (
	processQueryLimitedInformation = 0x1000
	jobObjectQuery                 = 0x0004
)

var (
	kernel32           = syscall.NewLazyDLL("kernel32.dll")
	procIsProcessInJob = kernel32.NewProc("IsProcessInJob")
	procOpenJobObjectW = kernel32.NewProc("OpenJobObjectW")
)

// openDaemonJob opens the job the runner names after its own pid, and returns
// the pid that owns it. Asking whether a process is in *any* job is useless
// here: CI runners already put every process in one.
func openDaemonJob(t *testing.T, appPIDs []int) (syscall.Handle, int) {
	t.Helper()
	for _, pid := range appPIDs {
		name, err := syscall.UTF16PtrFromString(fmt.Sprintf("bitwindow-daemons-%d", pid))
		if err != nil {
			t.Fatalf("job name for pid %d: %v", pid, err)
		}
		ret, _, _ := procOpenJobObjectW.Call(
			uintptr(jobObjectQuery), 0, uintptr(unsafe.Pointer(name)),
		)
		if ret != 0 {
			return syscall.Handle(ret), pid
		}
	}
	t.Fatalf("no daemon job found for app pids %s; the runner never created one", prettyPIDs(appPIDs))
	return 0, 0
}

// isProcessInJob reports whether pid belongs to job.
func isProcessInJob(t *testing.T, pid int, job syscall.Handle) bool {
	t.Helper()
	handle, err := syscall.OpenProcess(processQueryLimitedInformation, false, uint32(pid))
	if err != nil {
		t.Fatalf("OpenProcess(%d): %v", pid, err)
	}
	defer syscall.CloseHandle(handle) //nolint:errcheck

	var inJob int32
	ret, _, callErr := procIsProcessInJob.Call(
		uintptr(handle), uintptr(job), uintptr(unsafe.Pointer(&inJob)),
	)
	if ret == 0 {
		t.Fatalf("IsProcessInJob(%d): %v", pid, callErr)
	}
	return inJob != 0
}

func daemonPIDsByName(t *testing.T) map[string][]int {
	t.Helper()
	return map[string][]int{
		bitwindowdName:    processPIDs(t, bitwindowdName),
		orchestratordName: processPIDs(t, orchestratordName),
	}
}

// describeJobMembership renders "bitwindowd[500]=in orchestratord[5940]=out",
// so a reap failure says which daemon escaped instead of only that one did.
func describeJobMembership(t *testing.T, job syscall.Handle) string {
	t.Helper()
	var parts []string
	for name, pids := range daemonPIDsByName(t) {
		for _, pid := range pids {
			state := "out"
			if isProcessInJob(t, pid, job) {
				state = "in"
			}
			parts = append(parts, fmt.Sprintf("%s[%d]=%s", name, pid, state))
		}
	}
	if len(parts) == 0 {
		return "no daemons running"
	}
	return strings.Join(parts, " ")
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

// The app must not be in its own daemon job: a member of a KILL_ON_JOB_CLOSE
// job dies with the job, and so does everything it launched — which is what
// killed the updater.
func TestFlutterProcessIsNotInTheDaemonJob(t *testing.T) {
	skipIfNoDisplay(t)

	run := startJustRun(t, nil)
	t.Cleanup(func() {
		run.dumpDiagnostics(t)
		run.stop(t, 5*time.Second)
	})

	appPIDs, _ := waitForBoot(t)
	job, owner := openDaemonJob(t, appPIDs)
	defer syscall.CloseHandle(job) //nolint:errcheck

	for _, pid := range appPIDs {
		if isProcessInJob(t, pid, job) {
			t.Errorf("app pid %d is in the daemon job owned by %d; anything it launches can be killed with it", pid, owner)
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

	appPIDs, _ := waitForBoot(t)
	job, _ := openDaemonJob(t, appPIDs)
	defer syscall.CloseHandle(job) //nolint:errcheck

	for name, pids := range daemonPIDsByName(t) {
		if len(pids) == 0 {
			t.Errorf("%s is not running", name)
			continue
		}
		for _, pid := range pids {
			if !isProcessInJob(t, pid, job) {
				t.Errorf("%s pid %d is not in the daemon job; it would outlive the app", name, pid)
			}
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

	job, _ := openDaemonJob(t, appPIDs)
	membership := describeJobMembership(t, job)
	// KILL_ON_JOB_CLOSE fires when the last handle closes, so ours must go
	// before the app's.
	if err := syscall.CloseHandle(job); err != nil {
		t.Fatalf("close job handle: %v", err)
	}

	// No /T: the daemons must be reaped by the job, not by taskkill walking
	// the tree.
	for _, pid := range appPIDs {
		if out, err := exec.Command("taskkill", "/F", "/PID", strconv.Itoa(pid)).CombinedOutput(); err != nil {
			t.Fatalf("taskkill /F /PID %d: %v (%s)", pid, err, string(out))
		}
	}

	const reapDeadline = 60 * time.Second
	const reapPoll = 500 * time.Millisecond
	for _, name := range []string{bitwindowdName, orchestratordName} {
		waitUntil(t, reapDeadline, reapPoll,
			fmt.Sprintf("%s survived a force-kill of the app (job membership at boot: %s)", name, membership),
			func() bool { return len(processPIDs(t, name)) == 0 },
		)
	}
}
