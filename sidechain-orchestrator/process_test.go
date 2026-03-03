package orchestrator

import (
	"context"
	"os"
	"path/filepath"
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
