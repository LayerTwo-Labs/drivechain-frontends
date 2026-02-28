package orchestrator

import (
	"context"
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
