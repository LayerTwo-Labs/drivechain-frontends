package watch

import (
	"context"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestChangesSendsOnlyChanges(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	changed := make(chan struct{}, 1)
	var mu sync.Mutex
	value := 1
	sent := make(chan int, 10)
	beats := make(chan struct{}, 10)

	go func() {
		_ = Changes(ctx, changed, time.Hour, 150*time.Millisecond,
			func() (int, error) { mu.Lock(); defer mu.Unlock(); return value, nil },
			func(a, b int) bool { return a == b },
			func(v int) error { sent <- v; return nil },
			func() error { beats <- struct{}{}; return nil },
		)
	}()

	require.Equal(t, 1, <-sent)

	changed <- struct{}{}
	select {
	case v := <-sent:
		t.Fatalf("sent %d with no change", v)
	case <-time.After(50 * time.Millisecond):
	}

	mu.Lock()
	value = 2
	mu.Unlock()
	changed <- struct{}{}
	select {
	case v := <-sent:
		require.Equal(t, 2, v)
	case <-time.After(100 * time.Millisecond):
		t.Fatal("a change did not send at once")
	}

	select {
	case <-beats:
	case <-time.After(time.Second):
		t.Fatal("no heartbeat on an idle stream")
	}
}

func TestChangesBeatsDuringASlowRead(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	release := make(chan struct{})
	beats := make(chan struct{}, 10)
	go func() {
		_ = Changes(ctx, nil, time.Hour, 50*time.Millisecond,
			func() (int, error) { <-release; return 1, nil },
			func(a, b int) bool { return a == b },
			func(int) error { return nil },
			func() error { beats <- struct{}{}; return nil },
		)
	}()
	defer close(release)

	select {
	case <-beats:
	case <-time.After(time.Second):
		t.Fatal("a slow read stopped the heartbeat")
	}
}
