package service

import (
	"context"
	"fmt"
	"os"
	"sync"
	"sync/atomic"
	"time"

	"connectrpc.com/connect/v2"
	"github.com/rs/zerolog"
)

type Connector[T any] func(ctx context.Context) (T, error)

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

func New[T any](name string, connector Connector[T]) *Service[T] {
	return &Service[T]{
		name:      name,
		connector: connector,
		subs:      make(map[chan bool]struct{}),
	}
}

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

// Connect calls the connector one time and records the result.
func (s *Service[T]) Connect(ctx context.Context) (T, error) {
	client, err := s.connector(ctx)
	if err != nil {
		s.setConnected(ctx, false)
		var zero T
		return zero, connect.NewError(connect.CodeUnavailable, fmt.Sprintf("%s does not accept connections: %s", s.name, err)).WithCause(err)
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	s.client = client
	s.setConnected(ctx, true)
	return client, nil
}

func (s *Service[T]) IsConnected() bool {
	return s.connected.Load()
}

// followRetry is the first wait before a new dial of a service that is up but
// did not answer. It doubles to followRetryMax.
var (
	followRetry    = 25 * time.Millisecond
	followRetryMax = time.Second
)

// Follow sets the connection state from an outside liveness source until ctx
// ends. A change to up dials the service, again and again until it answers or
// goes down. A change to down drops it.
func (s *Service[T]) Follow(ctx context.Context, up <-chan bool) {
	go func() {
		isUp := false
		wait := followRetry
		retry := time.NewTimer(time.Hour)
		retry.Stop()
		defer retry.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case v := <-up:
				isUp = v
				wait = followRetry
				if !v {
					retry.Stop()
					s.setConnected(ctx, false)
					continue
				}
			case <-retry.C:
				if !isUp {
					continue
				}
			}
			if s.connected.Load() {
				continue
			}
			if _, err := s.Connect(ctx); err != nil {
				zerolog.Ctx(ctx).Debug().Err(err).Msgf("dial %q after it came up", s.name)
				retry.Reset(wait)
				wait = min(2*wait, followRetryMax)
			}
		}
	}()
}

func (s *Service[T]) setConnected(ctx context.Context, val bool) {
	s.subsMu.Lock()
	defer s.subsMu.Unlock()

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

		// A slow subscriber loses the unread state, never the newest one.
		for ch := range s.subs {
			select {
			case <-ch:
			default:
			}
			ch <- val
		}
	}
}

// ConnectedChan subscribes to this service's connection-state changes. Each
// call returns a fresh buffered-by-1 channel, pre-seeded with the current
// connection state, that holds the newest state after each change.
//
// The subscription ends and the channel closes when ctx ends.
func (s *Service[T]) ConnectedChan(ctx context.Context) <-chan bool {
	ch := make(chan bool, 1)
	s.subsMu.Lock()
	ch <- s.connected.Load()
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
