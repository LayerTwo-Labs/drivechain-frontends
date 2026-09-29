package orchestrator

import (
	"context"
	"runtime"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// watchExit swaps the daemon exit for a channel, so a test reads the exit code
// instead of losing the test binary.
func watchExit(t *testing.T) <-chan int {
	t.Helper()
	code := make(chan int, 1)
	restore := exitProcess
	exitProcess = func(c int) {
		code <- c
		runtime.Goexit()
	}
	t.Cleanup(func() { exitProcess = restore })
	return code
}

func startManagedSleeper(t *testing.T, o *Orchestrator) BinaryConfig {
	t.Helper()
	symlinkSystemBinary(t, o.DataDir, "sleep")
	cfg := BinaryConfig{Name: "sleep-test", BinaryName: "sleep", ChainLayer: 1}
	o.configs["sleep-test"] = cfg
	pid, err := o.process.Start(context.Background(), cfg, []string{"30"}, nil)
	require.NoError(t, err)
	require.Greater(t, pid, 0)
	t.Cleanup(func() { _ = o.process.Stop(context.Background(), "sleep-test", true) })
	return cfg
}

// An app start replaces drivechaind alone. Every child keeps running, and the
// daemon that takes the port adopts it.
func TestBeginShutdownKeepsTheChildrenWhenAsked(t *testing.T) {
	o := newTestOrchestrator(t)
	startManagedSleeper(t, o)
	code := watchExit(t)

	require.True(t, o.BeginShutdown(true))

	select {
	case c := <-code:
		require.Equal(t, 0, c)
	case <-time.After(10 * time.Second):
		t.Fatal("the daemon never exited")
	}
	assert.True(t, o.process.IsRunning("sleep-test"), "the child must outlive the daemon")
}

// A plain shutdown still drains every child, so a quit leaves nothing behind.
func TestBeginShutdownStopsTheChildrenByDefault(t *testing.T) {
	o := newTestOrchestrator(t)
	startManagedSleeper(t, o)
	code := watchExit(t)

	require.True(t, o.BeginShutdown(false))

	select {
	case c := <-code:
		require.Equal(t, 0, c)
	case <-time.After(30 * time.Second):
		t.Fatal("the daemon never exited")
	}
	assert.False(t, o.process.IsRunning("sleep-test"), "a plain shutdown must stop the child")
}

// A client that takes the daemon over mid-retire must not strand the app that
// asked for the exit. The keep-L1 path answers to nobody.
func TestKeepL1ExitIgnoresACancel(t *testing.T) {
	o := newTestOrchestrator(t)
	code := watchExit(t)

	o.shutdownMu.Lock()
	o.shutdownState = shutdownStateDrainingExit
	idleCh := make(chan struct{})
	o.shutdownIdle = idleCh
	o.shutdownMu.Unlock()

	require.True(t, o.CancelShutdownExit())
	go o.runShutdown(idleCh, true)

	select {
	case c := <-code:
		require.Equal(t, 0, c)
	case <-time.After(10 * time.Second):
		t.Fatal("a cancel stopped the retire")
	}
}
