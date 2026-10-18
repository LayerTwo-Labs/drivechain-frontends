package connector

import (
	"context"
	"fmt"
	"sync"

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
	connected bool
}

// New creates a new service wrapper
func New[T any](name string, connector Connector[T]) *Service[T] {
	return &Service[T]{
		name:      name,
		connector: connector,
	}
}

// Get returns the current client, attempting to connect if not connected
func (s *Service[T]) Get(ctx context.Context) (T, error) {
	s.mu.RLock()
	if s.connected {
		client := s.client
		s.mu.RUnlock()
		return client, nil
	}
	s.mu.RUnlock()

	return s.Connect(ctx)
}

// Connect makes one connection attempt to the service
func (s *Service[T]) Connect(ctx context.Context) (T, error) {
	client, err := s.connector(ctx)
	if err != nil {
		s.setConnected(ctx, false)
		var zero T
		return zero, connect.NewError(
			connect.CodeUnavailable,
			fmt.Errorf("%s does not accept connections: %w", s.name, err),
		)
	} else {
		s.mu.Lock()
		s.client = client
		s.mu.Unlock()
		s.setConnected(ctx, true)
		return client, nil
	}

}

func (s *Service[T]) setConnected(ctx context.Context, val bool) {
	s.mu.Lock()
	changed := s.connected != val
	s.connected = val
	s.mu.Unlock()
	if changed {
		zerolog.Ctx(ctx).Info().
			Msgf("%s changed connected to: %t", s.name, val)
	}
}
