package orchestrator

import (
	"context"
	"slices"
	"strings"
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

// SubscribeBinaries wakes the returned channel when the connection state of
// a binary changes. The channel lives until ctx is done.
func (o *Orchestrator) SubscribeBinaries(ctx context.Context) <-chan struct{} {
	return o.binariesChanged.subscribe(ctx)
}

// BinaryConnection is the connection state that the monitor of a binary holds.
type BinaryConnection struct {
	Name      string
	Connected bool
}

// Connections reads the state of each connection monitor, sorted by name. It
// probes no binary.
func (o *Orchestrator) Connections() []BinaryConnection {
	o.monitorsMu.Lock()
	out := make([]BinaryConnection, 0, len(o.monitors))
	for name, mon := range o.monitors {
		out = append(out, BinaryConnection{Name: name, Connected: mon.Connected()})
	}
	o.monitorsMu.Unlock()
	slices.SortFunc(out, func(a, b BinaryConnection) int { return strings.Compare(a.Name, b.Name) })
	return out
}
