//go:build !windows

package orchestrator

import (
	"context"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// startSleeper runs a real child this test can watch die. A PID from exec is a
// live process, so the drain has something it must actually signal.
func startSleeper(t *testing.T) int {
	t.Helper()
	return startSleeperNamed(t, "sleep")
}

// startSleeperNamed runs the sleeper from a copy named for the binary it will
// stand in for, so the name check before a signal recognises it.
func startSleeperNamed(t *testing.T, name string) int {
	t.Helper()
	sleep, err := exec.LookPath("sleep")
	require.NoError(t, err)
	body, err := os.ReadFile(sleep)
	require.NoError(t, err)
	path := filepath.Join(t.TempDir(), name)
	require.NoError(t, os.WriteFile(path, body, 0o755))

	cmd := exec.Command(path, "300")
	cmd.Args[0] = "sleep" // busybox picks its applet from argv[0]
	require.NoError(t, cmd.Start())
	pid := cmd.Process.Pid
	t.Cleanup(func() {
		_ = cmd.Process.Kill()
		_, _ = cmd.Process.Wait()
	})
	go func() { _, _ = cmd.Process.Wait() }()
	return pid
}

// alive reports whether the pid still exists. Signal 0 asks the kernel without
// sending anything.
func alive(t *testing.T, pid int) bool {
	t.Helper()
	return syscall.Kill(pid, 0) == nil
}

func waitGone(t *testing.T, pid int, timeout time.Duration) bool {
	t.Helper()
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		if !alive(t, pid) {
			return true
		}
		time.Sleep(20 * time.Millisecond)
	}
	return !alive(t, pid)
}

// adoptSleeper starts a child and hands it to the orchestrator as bitcoind.
// recordPid writes this install's PID record first, which is what marks the
// process as a leftover of an earlier run of ours.
func adoptSleeper(t *testing.T, o *Orchestrator, recordPid bool) int {
	t.Helper()
	cfg, err := o.getConfig("bitcoind")
	require.NoError(t, err)
	pid := startSleeperNamed(t, cfg.BinaryName)
	if recordPid {
		require.NoError(t, o.pidManager.WritePidFile(cfg.BinaryName, pid))
	}
	o.process.AdoptProcess(cfg, pid)
	require.True(t, o.process.IsAdopted("bitcoind"))
	return pid
}

func drain(t *testing.T, o *Orchestrator) {
	t.Helper()
	ch, err := o.ShutdownAll(context.Background(), false)
	require.NoError(t, err)
	for range ch {
	}
}

// backdatePidRecord makes the PID record predate the process it names, which
// is the shape a reused PID leaves behind.
func backdatePidRecord(t *testing.T, o *Orchestrator, binaryName string) {
	t.Helper()
	path := filepath.Join(PidDir(o.DataDir), binaryName+".pid")
	old := time.Now().Add(-time.Hour)
	require.NoError(t, os.Chtimes(path, old, old))
}

func ownThisInstall(t *testing.T, o *Orchestrator) {
	t.Helper()
	lock, held, err := TakeOwnerLock(t.TempDir())
	require.NoError(t, err)
	require.True(t, held)
	t.Cleanup(func() { _ = lock.Release() })
	o.SetOwnerLock(lock)
}

// The bug: a daemon that survived one bad exit got adopted on the next boot,
// and the drain then refused to stop it. It stayed for good and held the ports
// the fresh stack wants.
func TestDrainStopsAnAdoptedOrphanThisInstallOwns(t *testing.T) {
	o := newTestOrchestrator(t)
	ownThisInstall(t, o)

	pid := adoptSleeper(t, o, true)
	drain(t, o)

	require.True(t, waitGone(t, pid, 30*time.Second), "the drain must stop an orphan this install owns")
}

// An adopted PID came off disk and the OS reuses PID numbers. A stop that
// trusts the cached number signals whichever stranger now holds it.
func TestStopRefusesAnAdoptedPidThatIsNoLongerTheBinary(t *testing.T) {
	o := newTestOrchestrator(t)

	cfg, err := o.getConfig("bitcoind")
	require.NoError(t, err)
	pid := startSleeper(t) // runs as "sleep", not as bitcoind
	require.NoError(t, o.pidManager.WritePidFile(cfg.BinaryName, pid))
	o.process.AdoptProcess(cfg, pid)

	require.Error(t, o.process.Stop(context.Background(), "bitcoind", false))
	require.True(t, alive(t, pid), "a PID that is not the binary must not be signalled")
	require.False(t, o.process.IsRunning("bitcoind"), "the registration that named it must go")
	_, err = o.pidManager.ReadPidFile(cfg.BinaryName)
	require.Error(t, err, "so must the PID record")
}

// thunder-orchard is zSide's executable. A substring match let it answer for
// "thunder", so the zSide daemon filled Thunder's slot and the next stop of
// Thunder signalled it.
func TestAdoptOrphansNeverPutsZsideInThundersSlot(t *testing.T) {
	o := newTestOrchestrator(t)

	cfg, err := o.getConfig("zside")
	require.NoError(t, err)
	require.Equal(t, "thunder-orchard", cfg.BinaryName)
	pid := startSleeperNamed(t, cfg.BinaryName)
	require.NoError(t, o.pidManager.WritePidFile(cfg.BinaryName, pid))

	require.NoError(t, o.AdoptOrphans(context.Background()))

	require.Nil(t, o.process.Get("thunder"), "zSide's PID must never fill Thunder's slot")
	proc := o.process.Get("zside")
	require.NotNil(t, proc, "zSide's PID belongs in zSide's slot")
	require.Equal(t, pid, proc.Pid)
}

// A binary a different live install owns stays untouched, whatever this run
// finds on disk.
func TestDrainLeavesAnAdoptedProcessAnotherInstallOwns(t *testing.T) {
	o := newTestOrchestrator(t)
	require.False(t, o.OwnsInstall())

	pid := adoptSleeper(t, o, true)
	drain(t, o)

	require.True(t, alive(t, pid), "another install's process must survive this drain")
}

// A daemon the user started themselves has no PID record here. Owning the
// install says nothing about it, so the drain leaves their node running.
func TestDrainLeavesADaemonThisInstallNeverStarted(t *testing.T) {
	o := newTestOrchestrator(t)
	ownThisInstall(t, o)

	pid := adoptSleeper(t, o, false)
	require.False(t, o.process.IsOrphan("bitcoind"))
	drain(t, o)

	require.True(t, alive(t, pid), "a daemon this install never started must survive the drain")
}

// The wait for an adopted binary must end when the process does. Nothing
// closes its exit channel otherwise, so every stop burned the whole window.
func TestAdoptedProcessExitEndsTheWait(t *testing.T) {
	o := newTestOrchestrator(t)
	pid := adoptSleeper(t, o, true)

	require.NoError(t, syscall.Kill(pid, syscall.SIGKILL))

	require.True(t, o.process.WaitForExit("bitcoind", 30*time.Second),
		"the wait must end when the adopted process dies")
	require.False(t, o.process.IsRunning("bitcoind"))
}

// The OS reuses PID numbers. A stale record can name a PID the kernel later
// gave to a daemon the user started, so the record alone proves nothing.
func TestDrainLeavesAProcessThatReusedARecordedPid(t *testing.T) {
	o := newTestOrchestrator(t)
	ownThisInstall(t, o)

	pid := startSleeper(t)
	cfg, err := o.getConfig("bitcoind")
	require.NoError(t, err)
	require.NoError(t, o.pidManager.WritePidFile(cfg.BinaryName, pid))
	backdatePidRecord(t, o, cfg.BinaryName)

	o.process.AdoptProcess(cfg, pid)
	require.False(t, o.process.IsOrphan("bitcoind"), "a record older than the process proves nothing")

	drain(t, o)

	require.True(t, alive(t, pid), "a process that reused a recorded PID must survive the drain")
}

// ps prints the elapsed time in four shapes. A misread age makes a real orphan
// look young, and the drain then leaves it running.
func TestParseElapsedReadsEveryPsShape(t *testing.T) {
	tests := []struct {
		in   string
		want time.Duration
	}{
		{"05:30", 5*time.Minute + 30*time.Second},
		{"01:05:30", time.Hour + 5*time.Minute + 30*time.Second},
		{"2-01:05:30", 49*time.Hour + 5*time.Minute + 30*time.Second},
		{"10-00:00:00", 240 * time.Hour},
	}
	for _, tt := range tests {
		t.Run(tt.in, func(t *testing.T) {
			got, err := parseElapsed(tt.in)
			require.NoError(t, err)
			require.Equal(t, tt.want, got)
		})
	}

	for _, bad := range []string{"", "abc", "1:2:3:4", "x-01:00:00"} {
		_, err := parseElapsed(bad)
		require.Error(t, err, "parseElapsed(%q) must fail", bad)
	}
}

// A process this run started is younger than nothing, so its own age must read
// back as a real duration.
func TestProcessAgeReadsALiveProcess(t *testing.T) {
	pid := startSleeper(t)
	age, err := processAge(pid)
	require.NoError(t, err)
	require.Less(t, age, time.Minute, "a process started just now must read as young")
}
