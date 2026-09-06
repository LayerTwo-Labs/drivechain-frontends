package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestProcessManager_StartAndStop(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	symlinkSystemBinary(t, dir, "sleep")

	pid, err := pm.Start(context.Background(), BinaryConfig{
		Name: "sleep-test", BinaryName: "sleep",
	}, []string{"30"}, nil)
	require.NoError(t, err)
	assert.Greater(t, pid, 0)
	assert.True(t, pm.IsRunning("sleep-test"))
	assert.Contains(t, pm.ListRunning(), "sleep-test")

	require.NoError(t, pm.Stop(context.Background(), "sleep-test", false))
	time.Sleep(200 * time.Millisecond)
	assert.False(t, pm.IsRunning("sleep-test"))
}

// A relative data dir must still launch: cmd.Dir is set to it, so an
// unresolved binary path would be looked up under <dataDir>/<dataDir>.
func TestProcessManager_StartWithRelativeDataDir(t *testing.T) {
	t.Chdir(t.TempDir())

	const dir = "orchestrator"
	log := testLogger(t)
	pm := NewProcessManager(dir, NewPidFileManager(dir, log), log)
	t.Cleanup(func() {
		_ = pm.StopAll(context.Background(), true)
		pm.WaitForExit("sleep-test", 5*time.Second)
	})
	symlinkSystemBinary(t, dir, "sleep")

	pid, err := pm.Start(context.Background(), BinaryConfig{
		Name: "sleep-test", BinaryName: "sleep",
	}, []string{"30"}, nil)
	require.NoError(t, err)
	assert.Greater(t, pid, 0)

	require.NoError(t, pm.Stop(context.Background(), "sleep-test", false))
}

func TestProcessManager_ConcurrentStartSpawnsOnce(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	symlinkSystemBinary(t, dir, "sleep")

	const starters = 4
	var wg sync.WaitGroup
	pids := make([]int, starters)
	errs := make([]error, starters)
	for i := range starters {
		wg.Add(1)
		go func() {
			defer wg.Done()
			pids[i], errs[i] = pm.Start(context.Background(), BinaryConfig{
				Name: "sleep-test", BinaryName: "sleep",
			}, []string{"30"}, nil)
		}()
	}
	wg.Wait()

	proc := pm.Get("sleep-test")
	require.NotNil(t, proc)

	var started int
	for i := range starters {
		if errs[i] == nil {
			started++
			assert.Equal(t, proc.Pid, pids[i], "the tracked process must be the one we started")
		} else {
			assert.ErrorContains(t, errs[i], "already running")
		}
	}
	assert.Equal(t, 1, started, "concurrent starts must not fork a second daemon the manager loses track of")

	require.NoError(t, pm.Stop(context.Background(), "sleep-test", false))
}

func TestProcessManager_LastExit(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	symlinkSystemBinary(t, dir, "false")
	symlinkSystemBinary(t, dir, "sleep")

	_, ok := pm.LastExit("false-test")
	assert.False(t, ok)

	_, _ = pm.Start(context.Background(), BinaryConfig{
		Name: "false-test", BinaryName: "false",
	}, nil, nil)

	require.Eventually(t, func() bool {
		code, ok := pm.LastExit("false-test")
		return ok && code == 1
	}, 3*time.Second, 50*time.Millisecond)

	_, err := pm.Start(context.Background(), BinaryConfig{
		Name: "false-test", BinaryName: "sleep",
	}, []string{"30"}, nil)
	require.NoError(t, err)

	_, ok = pm.LastExit("false-test")
	assert.False(t, ok)
}

func TestProcessManager_LatestRunKeepsExitedLogs(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	symlinkSystemBinary(t, dir, "sh")

	// Start reports the immediate exit; the point here is the logs outliving it.
	_, _ = pm.Start(context.Background(), BinaryConfig{
		Name: "sh-test", BinaryName: "sh",
	}, []string{"-c", "echo Please restart with -reindex; exit 1"}, nil)

	require.Eventually(t, func() bool {
		code, ok := pm.LastExit("sh-test")
		return ok && code == 1
	}, 3*time.Second, 50*time.Millisecond)

	assert.Nil(t, pm.Get("sh-test"))

	proc := pm.LatestRun("sh-test")
	require.NotNil(t, proc, "the exited process must stay reachable for crash handlers")

	var sawReindex bool
	for _, entry := range proc.RecentLogs(100) {
		if strings.Contains(entry.Line, "Please restart with -reindex") {
			sawReindex = true
		}
	}
	assert.True(t, sawReindex, "logs the process died with must survive its removal")
}

// A descendant inheriting stdout and stderr outlives the child, so the drain has
// to be bounded or the exit is never recorded and the name can't be restarted.
func TestProcessManager_ExitRecordedWhenDescendantHoldsPipes(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	symlinkSystemBinary(t, dir, "sh")

	_, _ = pm.Start(context.Background(), BinaryConfig{
		Name: "sh-daemon", BinaryName: "sh",
	}, []string{"-c", "sleep 20 & echo spawned; exit 0"}, nil)

	require.Eventually(t, func() bool {
		_, ok := pm.LastExit("sh-daemon")
		return ok
	}, 10*time.Second, 100*time.Millisecond, "the exit must be recorded even while a descendant holds the pipes")

	assert.False(t, pm.IsRunning("sh-daemon"))
}

func TestProcessManager_StopNotRunning(t *testing.T) {
	pm, _ := newTestProcessManager(t)
	assert.Error(t, pm.Stop(context.Background(), "nonexistent", false))
}

func TestProcessManager_LogCapture(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	symlinkSystemBinary(t, dir, "printf")

	// printf exits immediately; just verify log capture doesn't panic.
	_, _ = pm.Start(context.Background(), BinaryConfig{
		Name: "printf-test", BinaryName: "printf",
	}, []string{"hello\\n"}, nil)
	time.Sleep(100 * time.Millisecond)
}

func TestIsSpam(t *testing.T) {
	assert.True(t, isSpam("tower_http::trace::on_request"))
	assert.True(t, isSpam("Ripemd160 hash mismatch"))
	assert.True(t, isSpam("rpc: fetch completed in 50ms"))
	assert.False(t, isSpam("Starting up bip300301_enforcer"))
	assert.False(t, isSpam("Connected to mainchain"))
}

func TestStripANSI(t *testing.T) {
	assert.Equal(t, "hello world", stripANSI("\x1b[31mhello\x1b[0m world"))
	assert.Equal(t, "plain text", stripANSI("plain text"))
}

func TestManagedProcess_Subscribe(t *testing.T) {
	proc := &ManagedProcess{
		logs:   make([]LogEntry, 0),
		exitCh: make(chan struct{}),
	}

	ch, cancel := proc.Subscribe()
	defer cancel()

	proc.addLog(LogEntry{Timestamp: time.Now(), Stream: "stdout", Line: "test line"})

	select {
	case got := <-ch:
		assert.Equal(t, "test line", got.Line)
	case <-time.After(time.Second):
		t.Fatal("timeout waiting for log entry")
	}
}

func TestPidFile_WriteReadDelete(t *testing.T) {
	m := newTestPidManager(t)

	require.NoError(t, m.WritePidFile("test-binary", 12345))

	pid, err := m.ReadPidFile("test-binary")
	require.NoError(t, err)
	assert.Equal(t, 12345, pid)

	require.NoError(t, m.DeletePidFile("test-binary"))

	_, err = m.ReadPidFile("test-binary")
	assert.ErrorIs(t, err, os.ErrNotExist)
}

func TestPidFile_ReadNonExistent(t *testing.T) {
	m := newTestPidManager(t)
	_, err := m.ReadPidFile("nonexistent")
	assert.ErrorIs(t, err, os.ErrNotExist)
}

func TestPidFile_InvalidContentDeletesFile(t *testing.T) {
	m := newTestPidManager(t)

	path := filepath.Join(m.pidDir, "bad.pid")
	require.NoError(t, os.WriteFile(path, []byte("not-a-number"), 0o644))

	_, err := m.ReadPidFile("bad")
	assert.Error(t, err)

	_, err = os.Stat(path)
	assert.True(t, os.IsNotExist(err))
}

func TestPidFile_DeleteNonExistentIsNoop(t *testing.T) {
	m := newTestPidManager(t)
	assert.NoError(t, m.DeletePidFile("nonexistent"))
}

func TestPidFile_List(t *testing.T) {
	m := newTestPidManager(t)

	require.NoError(t, m.WritePidFile("aaa", 100))
	require.NoError(t, m.WritePidFile("bbb", 200))

	pids := m.ListPidFiles()
	assert.Equal(t, map[string]int{"aaa": 100, "bbb": 200}, pids)
}

func TestPidFile_OverwriteKeepsLatest(t *testing.T) {
	m := newTestPidManager(t)

	require.NoError(t, m.WritePidFile("bin", 100))
	require.NoError(t, m.WritePidFile("bin", 200))

	pid, err := m.ReadPidFile("bin")
	require.NoError(t, err)
	assert.Equal(t, 200, pid)
}

func TestProcessNameMatches(t *testing.T) {
	tests := []struct {
		proc, bin string
		want      bool
	}{
		{"bitcoind", "bitcoind", true},
		{"Bitcoind", "bitcoind", true},   // case insensitive
		{"bitcoin", "bitcoind", true},    // ps truncation
		{"bitcoind", "bitcoin", true},    // reverse contains
		{"unrelated", "bitcoind", false}, // no overlap
		{"bip300301-enforcer", "bip300301-enforcer", true},
		{"bip300301", "bip300301-enforcer", true}, // truncated
	}
	for _, tt := range tests {
		t.Run(tt.proc+"_vs_"+tt.bin, func(t *testing.T) {
			assert.Equal(t, tt.want, processNameMatches(tt.proc, tt.bin))
		})
	}
}

// A pid of 0 means discovery found nothing. Adopting it would make Stop
// report success without ever signalling the daemon.
func TestProcessManager_AdoptRejectsInvalidPid(t *testing.T) {
	pm, _ := newTestProcessManager(t)
	cfg := BinaryConfig{Name: "bitcoind", BinaryName: "bitcoind"}

	pm.AdoptProcess(cfg, 0)
	assert.False(t, pm.IsRunning("bitcoind"), "pid 0 must not be adopted")

	pm.AdoptProcess(cfg, -1)
	assert.False(t, pm.IsRunning("bitcoind"), "negative pid must not be adopted")

	assert.Error(t, pm.Stop(context.Background(), "bitcoind", false))
}

func TestKillProcess_RejectsInvalidPid(t *testing.T) {
	for _, pid := range []int{0, -1} {
		assert.Error(t, killProcess(pid))
		assert.Error(t, forceKillProcess(pid))
	}
}
