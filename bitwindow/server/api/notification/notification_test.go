package notification_test

import (
	"context"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/notification"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1/notificationv1connect"
)

func TestWatch(t *testing.T) {
	t.Run("the stream ends when the engine stops", func(t *testing.T) {
		engine := engines.NewNotificationEngine(database.Test(t), nil, nil)
		runCtx, stop := context.WithCancel(t.Context())
		done := make(chan error, 1)
		go func() { done <- engine.Run(runCtx) }()

		mux := http.NewServeMux()
		srv := connect.NewServer()
		rpc.RegisterNotificationServiceHandler(srv, notification.New(engine))
		connecthttp.Mount(mux, srv, connecthttp.WithReadMaxBytes(0))
		server := httptest.NewServer(mux)
		t.Cleanup(server.Close)

		client := rpc.NewNotificationServiceClient(connect.NewClient(connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0))))
		ended := make(chan error, 1)
		go func() {
			stream, err := client.Watch(t.Context(), &emptypb.Empty{})
			if err != nil {
				ended <- err
				return
			}
			var streamErr error
			for {
				_, err := stream.Receive()
				if err != nil {
					streamErr = err
					break
				}
			}
			if errors.Is(streamErr, io.EOF) {
				streamErr = nil
			}
			ended <- errors.Join(streamErr, stream.Close())
		}()

		stop()
		require.NoError(t, <-done)

		select {
		case err := <-ended:
			require.NoError(t, err)
		case <-time.After(5 * time.Second):
			t.Fatal("the stream stayed open after the engine stopped")
		}
	})
}
