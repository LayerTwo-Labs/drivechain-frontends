package orchestrator

import (
	"context"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

type blockedHealthCheck struct {
	entered chan struct{}
	release chan struct{}
	calls   atomic.Int32
}

func (c *blockedHealthCheck) Check(ctx context.Context) error {
	if c.calls.Add(1) == 1 {
		close(c.entered)
	}
	select {
	case <-c.release:
		return nil
	case <-ctx.Done():
		return ctx.Err()
	}
}

func TestConnectionTimerWaitsForTheActiveProbe(t *testing.T) {
	checker := &blockedHealthCheck{entered: make(chan struct{}), release: make(chan struct{})}
	mon := newTestMonitor(t, checker, nil)
	ctx, cancel := context.WithCancel(context.Background())
	t.Cleanup(cancel)
	t.Cleanup(mon.StopAllTimers)
	first := make(chan struct{})
	go func() {
		mon.StartConnectionTimer(ctx)
		close(first)
	}()
	<-checker.entered
	second := make(chan struct{})
	go func() {
		mon.StartConnectionTimer(ctx)
		close(second)
	}()
	select {
	case <-second:
		t.Fatal("the second startup returned before the health result")
	case <-time.After(100 * time.Millisecond):
	}
	close(checker.release)
	select {
	case <-first:
	case <-time.After(time.Second):
		t.Fatal("the first startup did not return")
	}
	select {
	case <-second:
	case <-time.After(time.Second):
		t.Fatal("the second startup did not return")
	}
	require.True(t, mon.Connected())
	require.EqualValues(t, 1, checker.calls.Load())
}

func TestConnectionTimerCancelsAnActiveProbeWait(t *testing.T) {
	checker := &blockedHealthCheck{entered: make(chan struct{}), release: make(chan struct{})}
	mon := newTestMonitor(t, checker, nil)
	ctx, cancel := context.WithCancel(context.Background())
	t.Cleanup(cancel)
	t.Cleanup(mon.StopAllTimers)
	first := make(chan struct{})
	go func() {
		mon.StartConnectionTimer(ctx)
		close(first)
	}()
	<-checker.entered
	waitCtx, stopWait := context.WithCancel(ctx)
	stopWait()
	second := make(chan struct{})
	go func() {
		mon.StartConnectionTimer(waitCtx)
		close(second)
	}()
	select {
	case <-second:
	case <-time.After(time.Second):
		t.Fatal("the startup did not return after context cancellation")
	}
	require.False(t, mon.Connected())
	close(checker.release)
	<-first
}
