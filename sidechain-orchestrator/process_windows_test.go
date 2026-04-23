//go:build windows

// Windows-specific process management tests that exercise the real
// GenerateConsoleCtrlEvent + taskkill /F /T paths. These tests catch the
// "binaries don't stop on shutdown" class of bug — regressions where
// ProcessManager.Stop returns before the OS has reaped the child or before
// the file handles bitcoind holds on blocks/chainstate have been released.
//
// The tests spawn real children (ping.exe, cmd.exe) rather than mocks,
// because the bugs only reproduce against the kernel's process lifecycle.

package orchestrator

import (
	"context"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// prepareWindowsBinary hardlinks (or copies) a system .exe into the test
// BinDir so ProcessManager.Start's os.Stat and spawn succeed.
func prepareWindowsBinary(t *testing.T, dataDir, name string) {
	t.Helper()
	sysPath, err := exec.LookPath(name + ".exe")
	require.NoError(t, err, "system binary %q not found", name)

	binDir := BinDir(dataDir)
	require.NoError(t, os.MkdirAll(binDir, 0o755))
	dst := filepath.Join(binDir, name+".exe")

	if _, err := os.Stat(dst); err == nil {
		return
	}
	if err := os.Link(sysPath, dst); err == nil {
		return
	}
	// Cross-volume or permission: fall back to copy.
	data, err := os.ReadFile(sysPath)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(dst, data, 0o755))
}

// waitFor polls until pred returns true or timeout expires. Returns true
// on success; callers use this to avoid racy sleep-based assertions.
func waitFor(timeout time.Duration, pred func() bool) bool {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		if pred() {
			return true
		}
		time.Sleep(50 * time.Millisecond)
	}
	return pred()
}

// startLongRunning boots a ping.exe that keeps the process alive for ~60s
// and returns a handle the caller must stop. Ping reacts to CTRL_BREAK
// (exits cleanly) AND to taskkill /F.
func startLongRunning(t *testing.T, pm *ProcessManager, dataDir, name string) int {
	t.Helper()
	prepareWindowsBinary(t, dataDir, "ping")
	pid, err := pm.Start(context.Background(), BinaryConfig{
		Name:       name,
		BinaryName: "ping",
	}, []string{"-n", "60", "127.0.0.1"}, nil)
	require.NoError(t, err, "start ping")
	require.Greater(t, pid, 0)
	return pid
}

func TestWindowsStop_ExitChClosedBeforeReturn(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	startLongRunning(t, pm, dir, "ping-exit")
	proc := pm.Get("ping-exit")
	require.NotNil(t, proc)

	require.NoError(t, pm.Stop(context.Background(), "ping-exit", false))

	// After Stop returns the exit channel MUST be closed — otherwise
	// callers (reset, shutdown-all) proceed to os.RemoveAll while the
	// kernel still holds file locks on bitcoind's blocks/ dir.
	select {
	case <-proc.ExitCh():
	default:
		t.Fatal("Stop returned but exitCh not closed — caller will race against lingering file handles")
	}
}

func TestWindowsForceStop_ExitChClosedBeforeReturn(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	startLongRunning(t, pm, dir, "ping-force")
	proc := pm.Get("ping-force")
	require.NotNil(t, proc)

	require.NoError(t, pm.Stop(context.Background(), "ping-force", true))

	// Same invariant for force=true. taskkill /F returning does NOT mean
	// the OS has reaped the process — cmd.Wait() must have run.
	select {
	case <-proc.ExitCh():
	default:
		t.Fatal("force Stop returned but exitCh not closed — file handles may still be held")
	}
}

func TestWindowsStop_ProcessDeadInOSTable(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	pid := startLongRunning(t, pm, dir, "ping-os")

	require.NoError(t, pm.Stop(context.Background(), "ping-os", false))

	// isPidAlive consults tasklist — this is the ground truth the
	// reset/delete path cares about.
	if !waitFor(5*time.Second, func() bool { return !isPidAlive(pid) }) {
		t.Fatalf("pid %d still in tasklist after Stop", pid)
	}
}

func TestWindowsForceStop_ProcessDeadInOSTable(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	pid := startLongRunning(t, pm, dir, "ping-os-force")

	require.NoError(t, pm.Stop(context.Background(), "ping-os-force", true))

	if !waitFor(5*time.Second, func() bool { return !isPidAlive(pid) }) {
		t.Fatalf("pid %d still in tasklist after force Stop", pid)
	}
}

func TestWindowsStopAll_AllProcessesDead(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	names := []string{"ping-a", "ping-b", "ping-c"}
	pids := make([]int, 0, len(names))
	for _, n := range names {
		pids = append(pids, startLongRunning(t, pm, dir, n))
	}

	require.NoError(t, pm.StopAll(context.Background(), false))

	for _, n := range names {
		assert.False(t, pm.IsRunning(n), "%s still tracked as running after StopAll", n)
	}
	for i, pid := range pids {
		if !waitFor(5*time.Second, func() bool { return !isPidAlive(pid) }) {
			t.Errorf("%s (pid %d) still alive in OS table after StopAll", names[i], pid)
		}
	}
}

func TestWindowsStopAll_ForceAllProcessesDead(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	names := []string{"ping-fa", "ping-fb", "ping-fc"}
	pids := make([]int, 0, len(names))
	for _, n := range names {
		pids = append(pids, startLongRunning(t, pm, dir, n))
	}

	require.NoError(t, pm.StopAll(context.Background(), true))

	for i, pid := range pids {
		if !waitFor(5*time.Second, func() bool { return !isPidAlive(pid) }) {
			t.Errorf("%s (pid %d) still alive in OS table after force StopAll", names[i], pid)
		}
	}
}

func TestWindowsStop_PidFileDeleted(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	startLongRunning(t, pm, dir, "ping-pid")

	pidPath := filepath.Join(PidDir(dir), "ping.pid")
	require.FileExists(t, pidPath, "PID file should exist while running")

	require.NoError(t, pm.Stop(context.Background(), "ping-pid", false))

	if !waitFor(3*time.Second, func() bool {
		_, err := os.Stat(pidPath)
		return os.IsNotExist(err)
	}) {
		t.Fatalf("PID file %s not cleaned up after Stop — next run will adopt a stale PID", pidPath)
	}
}

// TestWindowsStop_KillsChildTree verifies taskkill /T semantics: when a
// managed process has spawned its own children, Stop must take the whole
// subtree down. This is the specific failure mode behind the PR under
// review — children (bitcoind, enforcer, sidechains) spawned as part of
// the orchestrator tree must die together.
func TestWindowsStop_KillsChildTree(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	prepareWindowsBinary(t, dir, "cmd")

	// cmd /c spawns a ping child in the same process tree. After Stop,
	// both cmd.exe and its ping.exe descendant must be gone.
	// (We use a subshell so the parent cmd.exe is alive long enough for
	// us to read its PID before Stop.)
	pid, err := pm.Start(context.Background(), BinaryConfig{
		Name:       "parent",
		BinaryName: "cmd",
	}, []string{"/c", "ping -n 60 127.0.0.1"}, nil)
	require.NoError(t, err, "start cmd")

	// Find the child ping PID before we kill anything.
	childPIDs := findChildPIDs(t, pid)
	require.NotEmpty(t, childPIDs, "cmd should have spawned at least one child ping process")

	require.NoError(t, pm.Stop(context.Background(), "parent", true))

	// Parent MUST be dead.
	if !waitFor(5*time.Second, func() bool { return !isPidAlive(pid) }) {
		t.Errorf("parent cmd.exe (pid %d) survived Stop", pid)
	}
	// Every child MUST be dead too.
	for _, cpid := range childPIDs {
		if !waitFor(5*time.Second, func() bool { return !isPidAlive(cpid) }) {
			t.Errorf("child ping.exe (pid %d) survived Stop — tree-kill did not propagate", cpid)
		}
	}
}

// findChildPIDs returns PIDs whose ParentProcessId matches parentPID.
// Uses wmic because tasklist doesn't expose PPID.
func findChildPIDs(t *testing.T, parentPID int) []int {
	t.Helper()
	// wmic is deprecated in recent Windows 11 builds; fall back to
	// PowerShell if it's missing.
	out, err := exec.Command("wmic", "process", "where",
		"ParentProcessId="+strconv.Itoa(parentPID), "get", "ProcessId", "/format:value").Output()
	if err == nil {
		return parsePidValueList(string(out))
	}
	out, err = exec.Command("powershell", "-NoProfile", "-Command",
		"Get-CimInstance Win32_Process -Filter \"ParentProcessId="+strconv.Itoa(parentPID)+
			"\" | Select-Object -ExpandProperty ProcessId").Output()
	if err != nil {
		t.Logf("could not enumerate children of pid %d: %v", parentPID, err)
		return nil
	}
	var pids []int
	for _, line := range strings.Split(string(out), "\n") {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		if pid, err := strconv.Atoi(line); err == nil {
			pids = append(pids, pid)
		}
	}
	return pids
}

// parsePidValueList parses wmic /format:value output like "ProcessId=1234".
func parsePidValueList(out string) []int {
	var pids []int
	for _, line := range strings.Split(out, "\n") {
		line = strings.TrimSpace(line)
		const prefix = "ProcessId="
		if !strings.HasPrefix(line, prefix) {
			continue
		}
		if pid, err := strconv.Atoi(strings.TrimSpace(line[len(prefix):])); err == nil && pid > 0 {
			pids = append(pids, pid)
		}
	}
	return pids
}
