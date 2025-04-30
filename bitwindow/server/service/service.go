package service

import (
	"context"
	"fmt"
	"sync"
	"time"

	"connectrpc.com/connect"
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

// Connect attempts to connect to the service, retrying every 500ms for 3 seconds
func (s *Service[T]) Connect(ctx context.Context) (T, error) {

	ticker := time.NewTicker(500 * time.Millisecond)
	defer ticker.Stop()
	deadline := time.Now().Add(3 * time.Second)

	for time.Now().Before(deadline) {
		client, err := s.connector(ctx)
		if err != nil {
			s.mu.Lock()
			s.connected = false
			s.mu.Unlock()
		} else {
			s.mu.Lock()
			s.client = client
			s.connected = true
			s.mu.Unlock()
			return client, nil
		}

		select {
		case <-ctx.Done():
			var zero T
			return zero, connect.NewError(connect.CodeUnavailable, ctx.Err())
		case <-ticker.C:
			continue
		}
	}

	var zero T
	return zero, connect.NewError(connect.CodeUnavailable, fmt.Errorf("%s not available", s.name))
}

// IsConnected returns whether the service is currently connected
func (s *Service[T]) IsConnected() bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.connected
}

// StartReconnectLoop starts a goroutine that attempts to connect periodically,
// to check whether the service is still available.
func (s *Service[T]) StartReconnectLoop(ctx context.Context) {
	go func() {
		ticker := time.NewTicker(5 * time.Second)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				_, _ = s.Connect(ctx)
			}
		}
	}()
}
