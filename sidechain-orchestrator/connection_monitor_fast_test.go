package orchestrator

import (
	"context"
	"fmt"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

type probeCounter struct {
	healthy atomic.Bool
	calls   atomic.Int32
}

func (c *probeCounter) Check(context.Context) error {
	c.calls.Add(1)
	if c.healthy.Load() {
		return nil
	}
	return fmt.Errorf("connection refused")
}

func TestConnectionMonitorSeesAStartFast(t *testing.T) {
	checker := &probeCounter{}
	mon := newTestMonitor(t, checker, nil)
	t.Cleanup(mon.StopAllTimers)
	mon.StartConnectionTimer(t.Context())

	time.Sleep(300 * time.Millisecond)
	checker.healthy.Store(true)
	start := time.Now()
	require.Eventually(t, mon.Connected, time.Second, time.Millisecond)
	require.Less(t, time.Since(start), 200*time.Millisecond)
}

func TestConnectionMonitorSeesARestartFast(t *testing.T) {
	checker := &probeCounter{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)
	t.Cleanup(mon.StopAllTimers)
	mon.StartConnectionTimer(t.Context())
	require.True(t, mon.Connected())

	mon.ProcessExited(-1, "killed")
	require.False(t, mon.Connected())
	checker.healthy.Store(false)
	time.Sleep(1200 * time.Millisecond)

	checker.healthy.Store(true)
	start := time.Now()
	require.Eventually(t, mon.Connected, 2*time.Second, time.Millisecond)
	require.Less(t, time.Since(start), 200*time.Millisecond)
}

func TestConnectionMonitorSeesAnExternalStartFast(t *testing.T) {
	checker := &probeCounter{}
	mon := newTestMonitor(t, checker, nil)
	t.Cleanup(mon.StopAllTimers)
	mon.StartConnectionTimer(t.Context())
	mon.MarkStopped()

	time.Sleep(100 * time.Millisecond)
	before := checker.calls.Load()
	time.Sleep(time.Second)
	require.InDelta(t, 20, checker.calls.Load()-before, 6)

	checker.healthy.Store(true)
	start := time.Now()
	require.Eventually(t, mon.Connected, time.Second, time.Millisecond, "an external start was not seen")
	require.Less(t, time.Since(start), 100*time.Millisecond)
}

func TestCleanExitMarksTheBinaryDown(t *testing.T) {
	checker := &probeCounter{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)
	mon.testConnection(t.Context())
	require.True(t, mon.Connected())

	mon.ProcessExited(0, "")
	require.False(t, mon.Connected())
	require.Empty(t, mon.ConnectionError())
}

func TestCrashWakesTheRestartTimer(t *testing.T) {
	checker := &probeCounter{}
	checker.healthy.Store(true)
	mon := newTestMonitor(t, checker, nil)
	mon.testConnection(t.Context())
	t.Cleanup(mon.StopAllTimers)

	restarted := make(chan time.Time, 1)
	mon.StartRestartTimer(t.Context(),
		func(context.Context) error { restarted <- time.Now(); return nil },
		func() (int, bool) { return -1, true },
	)
	time.Sleep(600 * time.Millisecond)

	start := time.Now()
	mon.ProcessExited(-1, "killed")
	select {
	case at := <-restarted:
		require.Less(t, at.Sub(start), 100*time.Millisecond)
	case <-time.After(time.Second):
		t.Fatal("no restart")
	}
}

func TestStopExitDoesNotKick(t *testing.T) {
	checker := &probeCounter{}
	mon := newTestMonitor(t, checker, nil)
	t.Cleanup(mon.StopAllTimers)
	mon.StartConnectionTimer(t.Context())
	mon.MarkStopped()
	mon.ProcessExited(-1, "signal: terminated")

	time.Sleep(100 * time.Millisecond)
	before := checker.calls.Load()
	time.Sleep(500 * time.Millisecond)
	require.LessOrEqual(t, checker.calls.Load()-before, int32(13), "the stop exit kicked the fast probe")
}

type remoteProbe struct {
	probeCounter
	remote bool
}

func (r *remoteProbe) Remote() bool { return r.remote }

func TestALongDownBinaryKeepsTheFastProbe(t *testing.T) {
	local := newTestMonitor(t, &probeCounter{}, nil)
	local.kickedAt = time.Now().Add(-2 * remoteProbeWindow)
	require.Equal(t, downProbeInterval, local.nextProbe())

	far := &remoteProbe{remote: true}
	remote := newTestMonitor(t, far, nil)
	remote.kickedAt = time.Now().Add(-2 * remoteProbeWindow)
	require.Equal(t, probeInterval, remote.nextProbe())
	far.remote = false
	require.Equal(t, downProbeInterval, remote.nextProbe())

	remote.kickedAt = time.Now()
	far.remote = true
	require.Equal(t, fastProbeInterval, remote.nextProbe())
}
