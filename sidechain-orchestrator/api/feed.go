package api

import (
	"context"
	"sync"
	"time"
)

// feed reads one value for all streams that watch it, and wakes them on each
// change.
type feed[T any] struct {
	read    func(ctx context.Context) (T, error)
	same    func(a, b T) bool
	changed func(ctx context.Context) <-chan struct{}
	// recheck is the read tick for the state that changed does not cover.
	// Zero gives no tick.
	recheck time.Duration

	mu      sync.Mutex
	last    T
	lastErr error
	// ready closes after the first read of a run.
	ready  chan struct{}
	subs   map[chan struct{}]struct{}
	cancel context.CancelFunc
}

// subscribe returns a channel that wakes on each change of the value. The
// first subscriber starts the reads, and the last one to leave stops them.
// The first read runs in the background, so a slow read holds no stream
// back from its heartbeats.
func (f *feed[T]) subscribe(ctx context.Context) <-chan struct{} {
	ch := make(chan struct{}, 1)
	f.mu.Lock()
	if f.subs == nil {
		f.subs = make(map[chan struct{}]struct{})
	}
	if len(f.subs) == 0 {
		runCtx, cancel := context.WithCancel(context.Background())
		f.cancel = cancel
		f.ready = make(chan struct{})
		go f.run(runCtx, f.changed(runCtx), f.ready)
	}
	f.subs[ch] = struct{}{}
	f.mu.Unlock()

	go func() {
		<-ctx.Done()
		f.mu.Lock()
		defer f.mu.Unlock()
		delete(f.subs, ch)
		if len(f.subs) == 0 {
			f.cancel()
		}
	}()
	return ch
}

// latest returns the newest value, or the error of the newest read. It waits
// for the first read. The caller must not change the value.
func (f *feed[T]) latest() (T, error) {
	f.mu.Lock()
	ready := f.ready
	f.mu.Unlock()
	<-ready
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.last, f.lastErr
}

func (f *feed[T]) run(ctx context.Context, changed <-chan struct{}, ready chan struct{}) {
	first, err := f.read(ctx)
	f.mu.Lock()
	if ctx.Err() == nil {
		f.last, f.lastErr = first, err
	}
	f.mu.Unlock()
	close(ready)

	var tick <-chan time.Time
	if f.recheck > 0 {
		ticker := time.NewTicker(f.recheck)
		defer ticker.Stop()
		tick = ticker.C
	}
	for {
		select {
		case <-ctx.Done():
			return
		case <-changed:
		case <-tick:
		}
		next, err := f.read(ctx)
		f.mu.Lock()
		if ctx.Err() != nil || (err == nil && f.lastErr == nil && f.same(f.last, next)) {
			f.mu.Unlock()
			continue
		}
		f.last, f.lastErr = next, err
		for ch := range f.subs {
			select {
			case ch <- struct{}{}:
			default:
			}
		}
		f.mu.Unlock()
	}
}
