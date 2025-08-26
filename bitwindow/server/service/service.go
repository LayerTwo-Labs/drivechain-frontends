package service

import (
	"context"
	"fmt"
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
	// Channel to send connection status changes
	connectedCh chan bool
}

// New creates a new service wrapper
func New[T any](name string, connector Connector[T]) *Service[T] {
	return &Service[T]{
		name:        name,
		connector:   connector,
		connectedCh: make(chan bool, 1),
	}
}

// Get returns the current client, attempting to connect if not connected
func (s *Service[T]) Get(ctx context.Context) (T, error) {
	if s.connected.Load() {
		zerolog.Ctx(ctx).Trace().
			Msgf("get service: %q is already connected", s.name)
		client := s.client
		return client, nil
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("get service: %q is not connected, connecting...", s.name)

	return s.Connect(ctx)
}

// Connect attempts to connect to the service, retrying every 500ms for 3 seconds
func (s *Service[T]) Connect(ctx context.Context) (T, error) {
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
		zerolog.Ctx(ctx).Info().
			Msgf("%s changed connected to: %t", s.name, val)
		select {
		case s.connectedCh <- val:
		default: // don't block if nobody is listening
		}
	}
}

func (s *Service[T]) ConnectedChan() <-chan bool {
	return s.connectedCh
}
