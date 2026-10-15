package api

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"

	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1/notificationv1connect"
	utilsv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1/utilsv1connect"
)

// Every daemon answers the same way while it boots, and the console holds
// nothing the reader can act on until one of them is up.
func TestGetLogLevelDuringBoot(t *testing.T) {
	tests := []struct {
		name      string
		procedure string
		code      connect.Code
		err       error
		want      zerolog.Level
	}{
		{
			name:      "the enforcer is not up yet",
			procedure: "/drivechain.v1.DrivechainService/ListSidechains",
			code:      connect.CodeInternal,
			err:       errors.New("internal: enforcer: unavailable: enforcer does not accept connections"),
			want:      zerolog.Disabled,
		},
		{
			name:      "Core still loads its block index",
			procedure: "/bitwindowd.v1.BitwindowdService/ListBlocks",
			code:      connect.CodeUnknown,
			err:       errors.New("-28: Loading block index…"),
			want:      zerolog.Disabled,
		},
		{
			name:      "a real fault still prints",
			procedure: "/drivechain.v1.DrivechainService/ListSidechains",
			code:      connect.CodeInternal,
			err:       errors.New("no such column: slot"),
			want:      zerolog.ErrorLevel,
		},
		{
			name:      "Core stays quiet while it is busy",
			procedure: "/bitwindowd.v1.BitwindowdService/ListBlocks",
			code:      connect.CodeUnknown,
			err:       errors.New("-28: Verifying blocks…"),
			want:      zerolog.Disabled,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, getLogLevel(tc.procedure, tc.code, tc.err))
		})
	}
}

type panicUtils struct {
	utilsv1connect.UnimplementedUtilsServiceHandler
}

func (panicUtils) ParseBitcoinURI(context.Context, *connect.Request[utilsv1.ParseBitcoinURIRequest]) (*connect.Response[utilsv1.ParseBitcoinURIResponse], error) {
	panic("boom")
}

func (panicUtils) ValidateBitcoinURI(context.Context, *connect.Request[utilsv1.ValidateBitcoinURIRequest]) (*connect.Response[utilsv1.ValidateBitcoinURIResponse], error) {
	return connect.NewResponse(&utilsv1.ValidateBitcoinURIResponse{Valid: true}), nil
}

type panicNotification struct {
	notificationv1connect.UnimplementedNotificationServiceHandler
}

func (panicNotification) Watch(context.Context, *connect.Request[emptypb.Empty], *connect.ServerStream[notificationv1.WatchResponse]) error {
	panic("boom")
}

func TestRecoverInterceptor(t *testing.T) {
	opts := connect.WithInterceptors(logInterceptor(), recoverInterceptor{})
	mux := http.NewServeMux()
	mux.Handle(utilsv1connect.NewUtilsServiceHandler(panicUtils{}, opts))
	mux.Handle(notificationv1connect.NewNotificationServiceHandler(panicNotification{}, opts))
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)

	t.Run("a unary panic gives CodeInternal and the server keeps serving", func(t *testing.T) {
		cli := utilsv1connect.NewUtilsServiceClient(srv.Client(), srv.URL)

		_, err := cli.ParseBitcoinURI(t.Context(), connect.NewRequest(&utilsv1.ParseBitcoinURIRequest{}))
		require.ErrorContains(t, err, "panic in /utils.v1.UtilsService/ParseBitcoinURI")
		require.Equal(t, connect.CodeInternal, connect.CodeOf(err))

		resp, err := cli.ValidateBitcoinURI(t.Context(), connect.NewRequest(&utilsv1.ValidateBitcoinURIRequest{}))
		require.NoError(t, err)
		require.True(t, resp.Msg.Valid)
	})

	t.Run("a stream panic gives CodeInternal", func(t *testing.T) {
		cli := notificationv1connect.NewNotificationServiceClient(srv.Client(), srv.URL)

		stream, err := cli.Watch(t.Context(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		require.False(t, stream.Receive())
		require.ErrorContains(t, stream.Err(), "panic in /notification.v1.NotificationService/Watch")
		require.Equal(t, connect.CodeInternal, connect.CodeOf(stream.Err()))
		require.NoError(t, stream.Close())
	})
}
