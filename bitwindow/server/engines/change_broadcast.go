package engines

import (
	"context"
	"sync"
)

// changeBroadcast wakes every subscriber on notify. A slow subscriber keeps
// one pending wake and drops the rest.
type changeBroadcast struct {
	mu   sync.Mutex
	subs map[chan struct{}]struct{}
}

func (b *changeBroadcast) subscribe(ctx context.Context) <-chan struct{} {
	ch := make(chan struct{}, 1)
	b.mu.Lock()
	if b.subs == nil {
		b.subs = make(map[chan struct{}]struct{})
	}
	b.subs[ch] = struct{}{}
	b.mu.Unlock()

	go func() {
		<-ctx.Done()
		b.mu.Lock()
		delete(b.subs, ch)
		b.mu.Unlock()
	}()
	return ch
}

func (b *changeBroadcast) notify() {
	b.mu.Lock()
	defer b.mu.Unlock()
	for ch := range b.subs {
		select {
		case ch <- struct{}{}:
		default:
		}
	}
}
