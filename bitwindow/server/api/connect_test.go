package api

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"connectrpc.com/connect/v2/connectproto"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/wrapperspb"

	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1/notificationv1connect"
	utilsv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1/utilsv1connect"
)

type wireUtils struct {
	utilsv1connect.UnimplementedUtilsServiceHandler
	parse func(context.Context, *utilsv1.ParseBitcoinURIRequest) (*utilsv1.ParseBitcoinURIResponse, error)
}

func (s wireUtils) ParseBitcoinURI(ctx context.Context, req *utilsv1.ParseBitcoinURIRequest) (*utilsv1.ParseBitcoinURIResponse, error) {
	return s.parse(ctx, req)
}

type wireNotification struct {
	err error
}

func (s wireNotification) Watch(ctx context.Context, _ *emptypb.Empty, stream notificationv1connect.NotificationServiceWatchServerStream) error {
	if err := setWireMetadata(ctx); err != nil {
		return err
	}
	for _, txid := range []string{"first", "second"} {
		if err := stream.Send(&notificationv1.WatchResponse{
			Event: &notificationv1.WatchResponse_Transaction{
				Transaction: &notificationv1.TransactionEvent{Txid: txid, AmountSats: 42},
			},
		}); err != nil {
			return err
		}
	}
	return s.err
}

func setWireMetadata(ctx context.Context) error {
	info, ok := connect.CallInfoForServerContext(ctx)
	if !ok {
		return errors.New("the call info is absent")
	}
	info.ResponseHeader().Set("X-Test-Header", info.RequestHeader().Get("X-Test-Request"))
	info.ResponseTrailer().Set("X-Test-Trailer", "complete")
	return nil
}

func wireServer(t *testing.T, utils wireUtils, notification wireNotification) *httptest.Server {
	t.Helper()
	server := connect.NewServer(logInterceptor(), recoverInterceptor(), errorInterceptor())
	utilsv1connect.RegisterUtilsServiceHandler(server, utils)
	notificationv1connect.RegisterNotificationServiceHandler(server, notification)
	mux := http.NewServeMux()
	connecthttp.Mount(mux, server, connecthttp.WithReadMaxBytes(0))
	httpServer := httptest.NewUnstartedServer(mux)
	httpServer.EnableHTTP2 = true
	httpServer.StartTLS()
	t.Cleanup(httpServer.Close)
	return httpServer
}

func TestV1ClientsUseV2API(t *testing.T) {
	oldDetail, err := connectv1.NewErrorDetail(wrapperspb.String("v1 detail"))
	require.NoError(t, err)
	oldError := connectv1.NewError(connectv1.CodeFailedPrecondition, errors.New("the wallet is locked"))
	oldError.AddDetail(oldDetail)
	oldError.Meta()["X-Test-Error"] = []string{"first", "second"}

	remoteDetail, err := connectproto.NewErrorDetail(wrapperspb.String("remote detail"))
	require.NoError(t, err)
	upstream := wireServer(t, wireUtils{
		parse: func(context.Context, *utilsv1.ParseBitcoinURIRequest) (*utilsv1.ParseBitcoinURIResponse, error) {
			return nil, connect.NewError(connect.CodeUnavailable, "the node is offline").WithDetail(remoteDetail)
		},
	}, wireNotification{})
	remoteClient := utilsv1connect.NewUtilsServiceClient(connect.NewClient(
		connecthttp.NewTransport(upstream.Client(), upstream.URL, connecthttp.WithReadMaxBytes(0)),
	))
	_, remoteErr := remoteClient.ParseBitcoinURI(t.Context(), &utilsv1.ParseBitcoinURIRequest{})
	var remoteError *connect.Error
	require.ErrorAs(t, remoteErr, &remoteError)
	require.True(t, remoteError.IsRemote())

	server := wireServer(t, wireUtils{
		parse: func(ctx context.Context, req *utilsv1.ParseBitcoinURIRequest) (*utilsv1.ParseBitcoinURIResponse, error) {
			if err := setWireMetadata(ctx); err != nil {
				return nil, err
			}
			switch req.Uri {
			case "v1":
				return nil, fmt.Errorf("wallet call: %w", oldError)
			case "local":
				return nil, connect.NewError(connect.CodeInternal, "the wallet call failed").WithCause(oldError)
			case "remote":
				return nil, fmt.Errorf("node call: %w", remoteError)
			case "bare":
				return nil, errors.New("private wallet path")
			case "panic":
				panic("private panic value")
			default:
				return &utilsv1.ParseBitcoinURIResponse{Address: req.Uri, Amount: 1.25}, nil
			}
		},
	}, wireNotification{err: oldError})

	for _, protocol := range []struct {
		name    string
		options []connectv1.ClientOption
	}{
		{name: "Connect protobuf"},
		{name: "Connect JSON", options: []connectv1.ClientOption{connectv1.WithProtoJSON()}},
		{name: "gRPC", options: []connectv1.ClientOption{connectv1.WithGRPC()}},
		{name: "gRPC-Web", options: []connectv1.ClientOption{connectv1.WithGRPCWeb()}},
	} {
		t.Run(protocol.name, func(t *testing.T) {
			client := connectv1.NewClient[utilsv1.ParseBitcoinURIRequest, utilsv1.ParseBitcoinURIResponse](
				server.Client(), server.URL+utilsv1connect.UtilsServiceParseBitcoinURIProcedure, protocol.options...,
			)
			t.Run("unary data and metadata", func(t *testing.T) {
				req := connectv1.NewRequest(&utilsv1.ParseBitcoinURIRequest{Uri: "address"})
				req.Header().Set("X-Test-Request", "unary request")
				resp, err := client.CallUnary(t.Context(), req)
				require.NoError(t, err)
				require.Equal(t, "address", resp.Msg.Address)
				require.Equal(t, 1.25, resp.Msg.Amount)
				require.Equal(t, "unary request", resp.Header().Get("X-Test-Header"))
				require.Equal(t, "complete", resp.Trailer().Get("X-Test-Trailer"))
			})

			for _, tt := range []struct {
				name    string
				code    connectv1.Code
				message string
				detail  string
			}{
				{name: "v1", code: connectv1.CodeFailedPrecondition, message: "the wallet is locked", detail: "v1 detail"},
				{name: "local", code: connectv1.CodeInternal, message: "the wallet call failed"},
				{name: "remote", code: connectv1.CodeUnavailable, message: "the node is offline", detail: "remote detail"},
				{name: "bare", code: connectv1.CodeUnknown},
				{name: "panic", code: connectv1.CodeInternal, message: "panic in " + utilsv1connect.UtilsServiceParseBitcoinURIProcedure},
			} {
				t.Run(tt.name, func(t *testing.T) {
					req := connectv1.NewRequest(&utilsv1.ParseBitcoinURIRequest{Uri: tt.name})
					_, err := client.CallUnary(t.Context(), req)
					var rpcError *connectv1.Error
					require.ErrorAs(t, err, &rpcError)
					require.Equal(t, tt.code, rpcError.Code())
					require.Equal(t, tt.message, rpcError.Message())
					require.NotContains(t, err.Error(), "private")
					if tt.detail == "" {
						require.Empty(t, rpcError.Details())
					} else {
						require.Len(t, rpcError.Details(), 1)
						detail, err := rpcError.Details()[0].Value()
						require.NoError(t, err)
						require.True(t, proto.Equal(wrapperspb.String(tt.detail), detail))
					}
					if tt.name == "v1" {
						require.Equal(t, []string{"first", "second"}, rpcError.Meta().Values("X-Test-Error"))
					}
				})
			}

			t.Run("stream data then error", func(t *testing.T) {
				client := connectv1.NewClient[emptypb.Empty, notificationv1.WatchResponse](
					server.Client(), server.URL+notificationv1connect.NotificationServiceWatchProcedure, protocol.options...,
				)
				req := connectv1.NewRequest(&emptypb.Empty{})
				req.Header().Set("X-Test-Request", "stream request")
				stream, err := client.CallServerStream(t.Context(), req)
				require.NoError(t, err)
				t.Cleanup(func() { require.NoError(t, stream.Close()) })
				var txids []string
				for stream.Receive() {
					txids = append(txids, stream.Msg().GetTransaction().GetTxid())
					require.Equal(t, uint64(42), stream.Msg().GetTransaction().GetAmountSats())
				}
				require.Equal(t, []string{"first", "second"}, txids)
				var rpcError *connectv1.Error
				require.ErrorAs(t, stream.Err(), &rpcError)
				require.Equal(t, oldError.Code(), rpcError.Code())
				require.Equal(t, oldError.Message(), rpcError.Message())
				require.Len(t, rpcError.Details(), 1)
				detail, err := rpcError.Details()[0].Value()
				require.NoError(t, err)
				require.True(t, proto.Equal(wrapperspb.String("v1 detail"), detail))
				require.Equal(t, "stream request", stream.ResponseHeader().Get("X-Test-Header"))
				require.Equal(t, "complete", stream.ResponseTrailer().Get("X-Test-Trailer"))
				require.Equal(t, []string{"first", "second"}, stream.ResponseTrailer().Values("X-Test-Error"))
			})
		})
	}
}
