//go:build !windows

package orchestrator

import (
	"context"
	"os"
	"os/exec"
	"path/filepath"
	"sync"
	"syscall"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// sleeperExit names the channel that closes when one sleeper exits, by pid. A
// dead child stays a zombie until its parent reaps it, and a signal 0 to a
// zombie still succeeds, so a poll alone reads a dead process as alive.
var sleeperExit sync.Map

// startSleeper runs a real child this test can watch die. A PID from exec is a
// live process, so the drain has something it must actually signal.
func startSleeper(t *testing.T) int {
	t.Helper()
	cmd := exec.Command("sleep", "300")
	require.NoError(t, cmd.Start())
	pid := cmd.Process.Pid

	exited := make(chan struct{})
	sleeperExit.Store(pid, exited)
	go func() {
		_, _ = cmd.Process.Wait()
		close(exited)
	}()
	t.Cleanup(func() {
		_ = cmd.Process.Kill()
		sleeperExit.Delete(pid)
	})
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
	if value, ok := sleeperExit.Load(pid); ok {
		select {
		case <-value.(chan struct{}):
			return true
		case <-time.After(timeout):
			return false
		}
	}

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
	pid := startSleeper(t)
	cfg, err := o.getConfig("bitcoind")
	require.NoError(t, err)
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
