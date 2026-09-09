package orchestrator

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestParallelCoreBootsWaitForTheReservedProcess(t *testing.T) {
	marker := filepath.Join(t.TempDir(), "starts")
	o := fakeCoreFixture(t, fmt.Sprintf("#!/bin/sh\nprintf x >> %q\nexec sleep 30\n", marker))
	checker := &mockChecker{}
	monitor := o.getOrCreateMonitor("bitcoind", checker, bitcoindStartupPatterns)

	reserved := make(chan struct{})
	release := make(chan struct{})
	var releaseOnce sync.Once
	resolve := o.process.CoreVariant
	o.process.CoreVariant = func(cfg BinaryConfig) (CoreVariantSpec, bool) {
		close(reserved)
		<-release
		return resolve(cfg)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	var workers sync.WaitGroup
	t.Cleanup(func() {
		releaseOnce.Do(func() { close(release) })
		cancel()
		workers.Wait()
		o.StopAllMonitors()
		require.NoError(t, o.process.StopAll(context.Background(), true))
		require.True(t, o.process.WaitForExit("bitcoind", 5*time.Second))
	})

	const callers = 4
	sinks := make([]bootSink, callers)
	results := make([]bool, callers)
	start := func(i int) {
		sinks[i] = newBootSink()
		workers.Go(func() {
			results[i] = o.startBitcoindOnly(ctx, StartOpts{}, sinks[i])
		})
	}
	start(0)
	select {
	case <-reserved:
	case <-ctx.Done():
		t.Fatal(ctx.Err())
	}
	require.Nil(t, o.process.Get("bitcoind"))

	for i := 1; i < callers; i++ {
		start(i)
		for {
			select {
			case progress := <-sinks[i]:
				require.NoError(t, progress.Error)
				if progress.Stage == "waiting-bitcoind" {
					goto nextCaller
				}
			case <-ctx.Done():
				t.Fatal(ctx.Err())
			}
		}
	nextCaller:
	}
	require.Nil(t, o.process.Get("bitcoind"))
	releaseOnce.Do(func() { close(release) })
	require.Eventually(t, func() bool {
		_, err := os.Stat(marker)
		return err == nil && o.process.IsRunning("bitcoind")
	}, 3*time.Second, time.Millisecond)
	checker.healthy.Store(true)
	monitor.testConnection(ctx)
	workers.Wait()

	for i := range callers {
		require.True(t, results[i], "caller %d", i)
		require.Empty(t, sinks[i].failures(t), "caller %d", i)
	}
	data, err := os.ReadFile(marker)
	require.NoError(t, err)
	require.Equal(t, "x", string(data))
}
