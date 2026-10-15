package service_test

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
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
