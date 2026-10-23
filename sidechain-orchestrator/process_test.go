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

func TestProcessManagerRejectsCancellationDuringStartCheck(t *testing.T) {
	o := newTestOrchestrator(t)
	pm := o.process
	symlinkSystemBinary(t, o.DataDir, "sleep")
	stopOnCleanup(t, pm, "enforcer")

	o.migrationMu.Lock()
	release := sync.OnceFunc(o.migrationMu.Unlock)
	defer release()
	entered := make(chan struct{})
	beforeStart := pm.BeforeStart
	pm.BeforeStart = func(ctx context.Context, cfg BinaryConfig) error {
		close(entered)
		return beforeStart(ctx, cfg)
	}
	ctx, cancel := context.WithCancel(t.Context())
	defer cancel()
	done := make(chan struct{})
	var pid int
	var err error
	go func() {
		defer close(done)
		pid, err = pm.Start(ctx, BinaryConfig{Name: "enforcer", BinaryName: "sleep"}, []string{"30"}, nil)
	}()

	select {
	case <-entered:
	case <-time.After(5 * time.Second):
		t.Fatal("the start check did not begin")
	}
	cancel()
	release()
	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("the start did not return after cancellation")
	}

	assert.ErrorIs(t, err, context.Canceled)
	assert.Zero(t, pid)
	assert.False(t, pm.IsRunning("enforcer"))
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

func TestManagedProcessSubscribeIncludesEachEntryOnce(t *testing.T) {
	for range 100 {
		proc := &ManagedProcess{runID: "test-run", exitCh: make(chan struct{})}
		var wg sync.WaitGroup
		wg.Go(func() {
			for i := range 64 {
				proc.addLog(LogEntry{
					Timestamp: time.Unix(int64(64-i), 0),
					Stream:    "stdout",
					Line:      "same line",
				})
			}
			proc.closeExit()
		})
		recent, sub := proc.subscribe(100, "", 0)
		entries, cancel := sub.Entries(), sub.Cancel
		wg.Wait()
		for entry := range entries {
			recent = append(recent, entry)
		}
		cancel()
		require.Len(t, recent, 64)
		for i, entry := range recent {
			require.Equal(t, "test-run", entry.RunID)
			require.Equal(t, uint64(i+1), entry.Sequence)
			require.Equal(t, "same line", entry.Line)
		}
	}
}

func TestManagedProcessResumeReturnsRetainedEntries(t *testing.T) {
	proc := &ManagedProcess{runID: "test-run", exitCh: make(chan struct{})}
	const entryCount = maxLogEntries + 5
	for range entryCount {
		proc.addLog(LogEntry{Stream: "stdout", Line: "same line"})
	}
	proc.closeExit()

	for _, tc := range []struct {
		name  string
		after uint64
		count int
		first uint64
	}{
		{name: "old cursor", after: 2, count: maxLogEntries, first: 6},
		{name: "recent cursor", after: entryCount - 150, count: 150, first: entryCount - 149},
		{name: "last cursor", after: entryCount},
		{name: "future cursor", after: entryCount + 1},
	} {
		t.Run(tc.name, func(t *testing.T) {
			recent, sub := proc.subscribe(100, "test-run", tc.after)
			entries, cancel := sub.Entries(), sub.Cancel
			defer cancel()
			require.Len(t, recent, tc.count)
			for i, entry := range recent {
				require.Equal(t, tc.first+uint64(i), entry.Sequence)
			}
			_, open := <-entries
			require.False(t, open)
		})
	}
}

func TestManagedProcessClosesFullSubscriber(t *testing.T) {
	proc := &ManagedProcess{runID: "test-run", exitCh: make(chan struct{})}
	for range maxLogEntries {
		proc.addLog(LogEntry{Stream: "stdout", Line: "saved line"})
	}
	recent, sub := proc.subscribe(100, "test-run", 1)
	entries, cancel := sub.Entries(), sub.Cancel
	defer cancel()
	require.Len(t, recent, maxLogEntries-1)
	fast, cancelFast := proc.Subscribe()
	defer cancelFast()

	for i := range 101 {
		proc.addLog(LogEntry{Stream: "stdout", Line: "live line"})
		entry := <-fast
		require.Equal(t, uint64(maxLogEntries+i+1), entry.Sequence)
	}
	var last uint64
	for range 100 {
		entry, open := <-entries
		require.True(t, open)
		last = entry.Sequence
	}
	proc.addLog(LogEntry{Stream: "stdout", Line: "next line"})
	entry, open := <-entries
	require.False(t, open, "the subscriber skipped sequence %d and sent %d", last+1, entry.Sequence)
	require.ErrorIs(t, sub.Err(), ErrLogBufferFull)
	cancel()
	cancel()

	resumed, resumeSub := proc.subscribe(100, "test-run", last)
	defer resumeSub.Cancel()
	require.Len(t, resumed, 2)
	require.Equal(t, last+1, resumed[0].Sequence)
	require.Equal(t, last+2, resumed[1].Sequence)
}

func TestManagedProcessCancelAtOverflowAndExit(t *testing.T) {
	for range 100 {
		proc := &ManagedProcess{runID: "test-run", exitCh: make(chan struct{})}
		_, sub := proc.subscribe(0, "", 0)
		for range 100 {
			proc.addLog(LogEntry{Line: "live line"})
		}
		var wg sync.WaitGroup
		wg.Go(func() { proc.addLog(LogEntry{Line: "next line"}) })
		wg.Go(sub.Cancel)
		wg.Go(proc.closeExit)
		var readErr error
		wg.Go(func() { readErr = sub.Err() })
		wg.Wait()
		if readErr != nil {
			require.ErrorIs(t, readErr, ErrLogBufferFull)
		}
		sub.Cancel()
		sub.Cancel()
		var count int
		for range sub.Entries() {
			count++
		}
		require.Equal(t, 100, count)
		if err := sub.Err(); err != nil {
			require.ErrorIs(t, err, ErrLogBufferFull)
		}
	}
}

func TestManagedProcess_SubscribeClosesAfterExit(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	symlinkSystemBinary(t, dir, "sleep")
	_, err := pm.Start(t.Context(), BinaryConfig{
		Name: "sleep-test", BinaryName: "sleep",
	}, []string{"30"}, nil)
	require.NoError(t, err)
	proc := pm.Get("sleep-test")
	require.NotNil(t, proc)
	entries, cancel := proc.Subscribe()
	defer cancel()

	require.NoError(t, pm.Stop(t.Context(), "sleep-test", false))
	select {
	case <-proc.ExitCh():
	default:
		t.Fatal("the process exit channel stays open after Stop")
	}

	for {
		select {
		case _, open := <-entries:
			if !open {
				return
			}
		default:
			t.Fatal("the log channel stays open after process exit")
		}
	}
}

func TestManagedProcess_SubscribeAfterExit(t *testing.T) {
	proc := &ManagedProcess{exitCh: make(chan struct{})}
	proc.closeExit()
	entries, cancel := proc.Subscribe()
	defer cancel()

	select {
	case _, open := <-entries:
		assert.False(t, open)
	default:
		t.Fatal("the log channel stays open after process exit")
	}
}

func TestManagedProcess_CancelSubscriptionAtExit(t *testing.T) {
	proc := &ManagedProcess{exitCh: make(chan struct{})}
	entries, cancel := proc.Subscribe()
	var wg sync.WaitGroup
	wg.Go(cancel)
	wg.Go(proc.closeExit)
	wg.Wait()
	cancel()

	_, open := <-entries
	assert.False(t, open)
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
