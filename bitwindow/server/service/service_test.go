package service_test

import (
	"context"
	"errors"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
)

func TestConnect(t *testing.T) {
	t.Run("a failed connector keeps its cause", func(t *testing.T) {
		cause := errors.New("thunder connection test: refused")
		svc := service.New("thunder", func(context.Context) (string, error) {
			return "", cause
		})

		_, err := svc.Connect(t.Context())
		require.ErrorIs(t, err, cause)
		require.ErrorContains(t, err, "thunder does not accept connections")
		require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
		require.False(t, svc.IsConnected())
	})
}

type upKey struct{}

// newUpService gives a service whose connector succeeds when the ctx holds upKey true.
func newUpService() *service.Service[string] {
	return service.New("bitcoind", func(ctx context.Context) (string, error) {
		if up, _ := ctx.Value(upKey{}).(bool); up {
			return "client", nil
		}
		return "", errors.New("refused")
	})
}

func connectTo(ctx context.Context, svc *service.Service[string], up bool) {
	_, _ = svc.Connect(context.WithValue(ctx, upKey{}, up))
}

func TestConnectedChan(t *testing.T) {
	t.Run("a slow subscriber reads the newest state", func(t *testing.T) {
		svc := newUpService()
		ch := svc.ConnectedChan(t.Context())

		connectTo(t.Context(), svc, true)
		connectTo(t.Context(), svc, false)
		connectTo(t.Context(), svc, true)

		assert.True(t, <-ch)
		select {
		case val := <-ch:
			t.Fatalf("the channel holds a second value %t", val)
		default:
		}
	})

	t.Run("the last value matches the state after concurrent connects", func(t *testing.T) {
		for range 20 {
			svc := newUpService()
			ch := svc.ConnectedChan(t.Context())

			var wg sync.WaitGroup
			for i := range 50 {
				wg.Go(func() { connectTo(t.Context(), svc, i%2 == 0) })
			}
			wg.Wait()

			require.Equal(t, svc.IsConnected(), <-ch)
		}
	})

	t.Run("the channel closes when the ctx ends", func(t *testing.T) {
		svc := newUpService()
		ctx, cancel := context.WithCancel(t.Context())
		ch := svc.ConnectedChan(ctx)

		assert.False(t, <-ch)
		cancel()
		select {
		case _, ok := <-ch:
			assert.False(t, ok)
		case <-time.After(5 * time.Second):
			t.Fatal("the channel did not close")
		}
	})
}
