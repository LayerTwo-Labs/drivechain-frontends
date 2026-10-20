package server

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/grpcreflect"
	btcpb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	btcrpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/wrapperspb"

	api_explorer "github.com/LayerTwo-Labs/sidesail/dc-hub/server/api/explorer"
	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/dial"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/cusf/mainchain/v1/mainchainv1connect"
	explorerv1 "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/explorer/v1/explorerv1connect"
	hubv1 "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/hub/v1"
	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/hub/v1/hubv1connect"
)

func TestV1Clients(t *testing.T) {
	detail, err := connectv1.NewErrorDetail(wrapperspb.String("retry"))
	if err != nil {
		t.Fatal(err)
	}
	coreMux := http.NewServeMux()
	coreMux.Handle(btcrpc.BitcoinServiceSendToAddressProcedure, connectv1.NewUnaryHandler(
		btcrpc.BitcoinServiceSendToAddressProcedure,
		func(_ context.Context, req *connectv1.Request[btcpb.SendToAddressRequest]) (*connectv1.Response[btcpb.SendToAddressResponse], error) {
			if req.Msg.Address != "destination" || req.Msg.Amount != 1 {
				t.Error("The Bitcoin request changed.")
			}
			return connectv1.NewResponse(&btcpb.SendToAddressResponse{Txid: "test-txid"}), nil
		},
	))
	coreMux.Handle(btcrpc.BitcoinServiceGetBlockchainInfoProcedure, connectv1.NewUnaryHandler(
		btcrpc.BitcoinServiceGetBlockchainInfoProcedure,
		func(context.Context, *connectv1.Request[btcpb.GetBlockchainInfoRequest]) (*connectv1.Response[btcpb.GetBlockchainInfoResponse], error) {
			err := connectv1.NewError(connectv1.CodeUnavailable, errors.New("mainchain unavailable"))
			err.AddDetail(detail)
			err.Meta().Set("X-Core", "unavailable")
			return nil, err
		},
	))
	core := httptest.NewServer(coreMux)
	t.Cleanup(core.Close)

	cancelled := make(chan struct{}, 1)
	enforcerMux := http.NewServeMux()
	enforcerMux.Handle(mainchainv1connect.ValidatorServiceGetSidechainsProcedure, connectv1.NewUnaryHandler(
		mainchainv1connect.ValidatorServiceGetSidechainsProcedure,
		func(context.Context, *connectv1.Request[mainchainv1.GetSidechainsRequest]) (*connectv1.Response[mainchainv1.GetSidechainsResponse], error) {
			return connectv1.NewResponse(&mainchainv1.GetSidechainsResponse{}), nil
		},
	))
	enforcerMux.Handle(mainchainv1connect.ValidatorServiceGetChainInfoProcedure, connectv1.NewUnaryHandler(
		mainchainv1connect.ValidatorServiceGetChainInfoProcedure,
		func(_ context.Context, req *connectv1.Request[mainchainv1.GetChainInfoRequest]) (*connectv1.Response[mainchainv1.GetChainInfoResponse], error) {
			if req.Header().Get("X-Token") != "token" {
				return nil, connectv1.NewError(connectv1.CodeUnauthenticated, errors.New("token absent"))
			}
			res := connectv1.NewResponse(&mainchainv1.GetChainInfoResponse{})
			res.Header().Add("X-Reply", "first")
			res.Header().Add("X-Reply", "second")
			res.Trailer().Set("X-Trailer", "complete")
			return res, nil
		},
	))
	enforcerMux.Handle(mainchainv1connect.ValidatorServiceGetBlockInfoProcedure, connectv1.NewUnaryHandler(
		mainchainv1connect.ValidatorServiceGetBlockInfoProcedure,
		func(context.Context, *connectv1.Request[mainchainv1.GetBlockInfoRequest]) (*connectv1.Response[mainchainv1.GetBlockInfoResponse], error) {
			err := connectv1.NewError(connectv1.CodeNotFound, errors.New("block absent"))
			err.AddDetail(detail)
			err.Meta().Set("X-Error", "block")
			return nil, err
		},
	))
	enforcerMux.Handle(mainchainv1connect.ValidatorServiceSubscribeHeaderSyncProgressProcedure, connectv1.NewServerStreamHandler(
		mainchainv1connect.ValidatorServiceSubscribeHeaderSyncProgressProcedure,
		func(ctx context.Context, req *connectv1.Request[mainchainv1.SubscribeHeaderSyncProgressRequest], stream *connectv1.ServerStream[mainchainv1.SubscribeHeaderSyncProgressResponse]) error {
			if req.Header().Get("X-Token") != "token" {
				return connectv1.NewError(connectv1.CodeUnauthenticated, errors.New("token absent"))
			}
			for height := range uint32(2) {
				if err := stream.Send(&mainchainv1.SubscribeHeaderSyncProgressResponse{CurrentHeight: wrapperspb.UInt32(height)}); err != nil {
					return err
				}
			}
			switch req.Header().Get("X-Mode") {
			case "error":
				err := connectv1.NewError(connectv1.CodeUnavailable, errors.New("sync stopped"))
				err.AddDetail(detail)
				return err
			case "wait":
				<-ctx.Done()
				cancelled <- struct{}{}
				return ctx.Err()
			default:
				return nil
			}
		},
	))
	enforcer := httptest.NewUnstartedServer(enforcerMux)
	enforcer.Config.Protocols = new(http.Protocols)
	enforcer.Config.Protocols.SetHTTP1(true)
	enforcer.Config.Protocols.SetUnencryptedHTTP2(true)
	enforcer.Start()
	t.Cleanup(enforcer.Close)

	api := New(t.Context(), btcrpc.NewBitcoinServiceClient(core.Client(), core.URL), &api_explorer.RpcClients{},
		func(ctx context.Context) (mainchainv1connect.ValidatorServiceClient, error) {
			return dial.EnforcerValidator(ctx, enforcer.URL)
		},
	)
	server := httptest.NewUnstartedServer(api.Handler(t.Context()))
	server.EnableHTTP2 = true
	server.StartTLS()
	t.Cleanup(server.Close)

	for _, protocol := range []struct {
		name    string
		options []connectv1.ClientOption
	}{
		{name: "Connect"},
		{name: "JSON", options: []connectv1.ClientOption{connectv1.WithProtoJSON()}},
		{name: "gRPC", options: []connectv1.ClientOption{connectv1.WithGRPC()}},
		{name: "gRPCWeb", options: []connectv1.ClientOption{connectv1.WithGRPCWeb()}},
	} {
		t.Run(protocol.name, func(t *testing.T) {
			faucet := connectv1.NewClient[hubv1.DispenseCoinsRequest, hubv1.DispenseCoinsResponse](
				server.Client(), server.URL+hubv1connect.FaucetServiceDispenseCoinsProcedure, protocol.options...,
			)
			_, err := faucet.CallUnary(t.Context(), connectv1.NewRequest(&hubv1.DispenseCoinsRequest{Amount: 1}))
			if connectv1.CodeOf(err) != connectv1.CodeInvalidArgument {
				t.Fatalf("The empty destination returned %v.", err)
			}
			response, err := faucet.CallUnary(t.Context(), connectv1.NewRequest(&hubv1.DispenseCoinsRequest{Destination: "destination", Amount: 1}))
			if err != nil {
				t.Fatal(err)
			}
			if response.Msg.Txid != "test-txid" {
				t.Fatalf("The transaction ID is %q.", response.Msg.Txid)
			}

			chain := connectv1.NewClient[mainchainv1.GetChainInfoRequest, mainchainv1.GetChainInfoResponse](
				server.Client(), server.URL+mainchainv1connect.ValidatorServiceGetChainInfoProcedure, protocol.options...,
			)
			request := connectv1.NewRequest(&mainchainv1.GetChainInfoRequest{})
			request.Header().Set("X-Token", "token")
			chainResponse, err := chain.CallUnary(t.Context(), request)
			if err != nil {
				t.Fatal(err)
			}
			if len(chainResponse.Header().Values("X-Reply")) != 2 || chainResponse.Trailer().Get("X-Trailer") != "complete" {
				t.Fatal("The proxy changed the response metadata.")
			}

			block := connectv1.NewClient[mainchainv1.GetBlockInfoRequest, mainchainv1.GetBlockInfoResponse](
				server.Client(), server.URL+mainchainv1connect.ValidatorServiceGetBlockInfoProcedure, protocol.options...,
			)
			_, err = block.CallUnary(t.Context(), connectv1.NewRequest(&mainchainv1.GetBlockInfoRequest{}))
			blockError := checkRPCError(t, err, connectv1.CodeNotFound, "block absent")
			checkErrorDetail(t, blockError)
			if blockError.Meta().Get("X-Error") != "block" {
				t.Fatal("The proxy changed the error metadata.")
			}

			explorer := connectv1.NewClient[explorerv1.GetChainTipsRequest, explorerv1.GetChainTipsResponse](
				server.Client(), server.URL+explorerv1connect.ExplorerServiceGetChainTipsProcedure, protocol.options...,
			)
			_, err = explorer.CallUnary(t.Context(), connectv1.NewRequest(&explorerv1.GetChainTipsRequest{}))
			coreError := checkRPCError(t, err, connectv1.CodeUnavailable, "mainchain unavailable")
			checkErrorDetail(t, coreError)
			if coreError.Meta().Get("X-Core") != "unavailable" {
				t.Fatal("The proxy changed the Bitcoin error metadata.")
			}

			sync := connectv1.NewClient[mainchainv1.SubscribeHeaderSyncProgressRequest, mainchainv1.SubscribeHeaderSyncProgressResponse](
				server.Client(), server.URL+mainchainv1connect.ValidatorServiceSubscribeHeaderSyncProgressProcedure, protocol.options...,
			)
			for _, mode := range []string{"complete", "error"} {
				request := connectv1.NewRequest(&mainchainv1.SubscribeHeaderSyncProgressRequest{})
				request.Header().Set("X-Token", "token")
				request.Header().Set("X-Mode", mode)
				stream, err := sync.CallServerStream(t.Context(), request)
				if err != nil {
					t.Fatal(err)
				}
				var count uint32
				for stream.Receive() {
					if stream.Msg().GetCurrentHeight().GetValue() != count {
						t.Fatal("The proxy changed the stream order.")
					}
					count++
				}
				if count != 2 {
					t.Fatalf("The stream returned %d messages.", count)
				}
				if mode == "error" {
					checkErrorDetail(t, checkRPCError(t, stream.Err(), connectv1.CodeUnavailable, "sync stopped"))
				} else if err := stream.Err(); err != nil {
					t.Fatal(err)
				}
				if err := stream.Close(); err != nil {
					t.Fatal(err)
				}
			}
		})
	}

	ctx, cancel := context.WithCancel(t.Context())
	defer cancel()
	client := connectv1.NewClient[mainchainv1.SubscribeHeaderSyncProgressRequest, mainchainv1.SubscribeHeaderSyncProgressResponse](
		server.Client(), server.URL+mainchainv1connect.ValidatorServiceSubscribeHeaderSyncProgressProcedure,
	)
	request := connectv1.NewRequest(&mainchainv1.SubscribeHeaderSyncProgressRequest{})
	request.Header().Set("X-Token", "token")
	request.Header().Set("X-Mode", "wait")
	stream, err := client.CallServerStream(ctx, request)
	if err != nil {
		t.Fatal(err)
	}
	if !stream.Receive() {
		t.Fatal(stream.Err())
	}
	cancel()
	if err := stream.Close(); err != nil {
		t.Fatal(err)
	}
	select {
	case <-cancelled:
	case <-time.After(5 * time.Second):
		t.Fatal("The upstream stream did not stop.")
	}

	reflection := grpcreflect.NewClient(server.Client(), server.URL)
	reflectionStream := reflection.NewStream(t.Context())
	services, err := reflectionStream.ListServices()
	if err != nil {
		t.Fatal(err)
	}
	if len(services) != 3 {
		t.Fatalf("Reflection returned %d services.", len(services))
	}
	if _, err := reflectionStream.Close(); err != nil {
		t.Fatal(err)
	}
}

func checkRPCError(t *testing.T, err error, code connectv1.Code, message string) *connectv1.Error {
	t.Helper()
	var rpcError *connectv1.Error
	if !errors.As(err, &rpcError) {
		t.Fatalf("The RPC did not return a Connect error: %v.", err)
	}
	if rpcError.Code() != code || rpcError.Message() != message {
		t.Fatalf("The RPC returned %v.", rpcError)
	}
	return rpcError
}

func checkErrorDetail(t *testing.T, err *connectv1.Error) {
	t.Helper()
	if len(err.Details()) != 1 {
		t.Fatalf("The RPC returned %d error details.", len(err.Details()))
	}
	value, detailError := err.Details()[0].Value()
	if detailError != nil {
		t.Fatal(detailError)
	}
	if !proto.Equal(value, wrapperspb.String("retry")) {
		t.Fatalf("The RPC returned the error detail %v.", value)
	}
}
