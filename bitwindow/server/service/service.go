package service

import (
	"context"
	"fmt"
	"os"
	"sync"
	"sync/atomic"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
)

// Connector represents a function that attempts to connect to a service
type Connector[T any] func(ctx context.Context) (T, error)

// Service wraps a connection to an external service with reconnection capabilities
type Service[T any] struct {
	mu sync.RWMutex

	name      string
	client    T
	connector Connector[T]

	// For checking if service is connected
	connected atomic.Bool

	// Per-subscriber fan-out for connection state changes. See ConnectedChan.
	subsMu sync.Mutex
	subs   map[chan bool]struct{}
}

// New creates a new service wrapper
func New[T any](name string, connector Connector[T]) *Service[T] {
	return &Service[T]{
		name:      name,
		connector: connector,
		subs:      make(map[chan bool]struct{}),
	}
}

// Get returns the current client, attempting to connect if not connected
func (s *Service[T]) Get(ctx context.Context) (T, error) {
	if s.connected.Load() {
		zerolog.Ctx(ctx).Trace().
			Msgf("get service: %q is already connected", s.name)
		s.mu.RLock()
		client := s.client
		s.mu.RUnlock()
		return client, nil
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("get service: %q is not connected, connecting...", s.name)

	return s.Connect(ctx)
}

// Connect attempts to connect to the service, retrying every 500ms for 3 seconds
func (s *Service[T]) Connect(ctx context.Context) (T, error) {
	if s.connector == nil {
		s.setConnected(ctx, false)
		var zero T
		return zero, connect.NewError(connect.CodeUnavailable, fmt.Errorf("%s has no connector configured", s.name))
	}
	client, err := s.connector(ctx)
	if err != nil {
		s.setConnected(ctx, false)
		var zero T
		return zero, connect.NewError(connect.CodeUnavailable, fmt.Errorf("%s does not accept connections", s.name))
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	s.client = client
	s.setConnected(ctx, true)
	return client, nil
}

// IsConnected returns whether the service is currently connected
func (s *Service[T]) IsConnected() bool {
	return s.connected.Load()
}

// StartReconnectLoop starts a goroutine that attempts to connect periodically,
// to check whether the service is still available.
func (s *Service[T]) StartReconnectLoop(ctx context.Context) {
	go func() {
		ticker := time.NewTicker(time.Second)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				// Only log if we were connected before
				connected := s.connected.Load()
				if _, err := s.Connect(ctx); err != nil && connected {
					zerolog.Ctx(ctx).Debug().
						Err(err).
						Msgf("reconnect loop: could not connect to %q", s.name)
				}
			}
		}
	}()
}

func (s *Service[T]) setConnected(ctx context.Context, val bool) {
	old := s.connected.Swap(val)
	if old != val {
		// Use logger from context, fallback to nop if not available
		log := zerolog.Ctx(ctx)
		if log.GetLevel() == zerolog.Disabled {
			// Context doesn't have a logger, create a minimal one
			logger := zerolog.New(os.Stderr).With().Timestamp().Logger()
			log = &logger
		}
		log.Info().Msgf("%s changed connected to: %t", s.name, val)

		// Fan out to every subscriber. Each subscriber owns its own
		// buffered-by-1 channel; we drop on full buffer rather than block,
		// matching the original non-blocking-send semantics. A subscriber
		// that's wedged on its receiver will just miss intermediate updates
		// and pick up the next one.
		s.subsMu.Lock()
		for ch := range s.subs {
			select {
			case ch <- val:
			default:
			}
		}
		s.subsMu.Unlock()
	}
}

// ConnectedChan subscribes to this service's connection-state changes. Each
// call returns a fresh buffered-by-1 channel, pre-seeded with the current
// connection state, that receives a value every time setConnected fires.
//
// The subscription is unwound automatically when ctx is canceled — callers
// should pass a ctx scoped to the lifetime of their consumer (per-stream for
// a Watch handler, the server ctx for engine-wide bootstrap goroutines).
//
// Returning a fresh channel per caller (rather than the legacy single shared
// buffered channel) is load-bearing: with the shared channel, two consumers
// racing for one buffered value meant the loser deadlocked indefinitely.
func (s *Service[T]) ConnectedChan(ctx context.Context) <-chan bool {
	ch := make(chan bool, 1)
	ch <- s.connected.Load()

	s.subsMu.Lock()
	s.subs[ch] = struct{}{}
	s.subsMu.Unlock()

	go func() {
		<-ctx.Done()
		s.subsMu.Lock()
		defer s.subsMu.Unlock()
		if _, ok := s.subs[ch]; ok {
			delete(s.subs, ch)
			close(ch)
		}
	}()

	return ch
}
