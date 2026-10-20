package apitests_test

import (
	"errors"
	"net/http"
	"strings"
	"testing"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"connectrpc.com/grpcreflect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/reflect/protoregistry"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	healthv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1/healthv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

func TestLocalAuth(t *testing.T) {
	t.Parallel()

	db := database.Test(t)
	ctrl := gomock.NewController(t)

	bitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	apitests.ExpectCoreWalletSetup(bitcoind)
	bitcoind.EXPECT().
		GetRawMempool(gomock.Any(), gomock.Any()).
		Return(&connectv1.Response[corepb.GetRawMempoolResponse]{Msg: &corepb.GetRawMempoolResponse{}}, nil).
		AnyTimes()
	bitcoind.EXPECT().
		GetBlockchainInfo(gomock.Any(), gomock.Any()).
		Return(&connectv1.Response[corepb.GetBlockchainInfoResponse]{Msg: &corepb.GetBlockchainInfoResponse{Chain: "regtest"}}, nil).
		AnyTimes()

	validator := mocks.NewMockValidatorServiceClient(ctrl)
	validator.EXPECT().
		GetChainInfo(gomock.Any(), gomock.Any()).
		Return(&mainchainv1.GetChainInfoResponse{}, nil).
		AnyTimes()

	crypto := mocks.NewMockCryptoServiceClient(ctrl)
	crypto.EXPECT().
		Ripemd160(gomock.Any(), gomock.Any()).
		Return(&cryptov1.Ripemd160Response{}, nil).
		AnyTimes()

	dir := t.TempDir()
	_, err := localauth.WriteCookie(dir)
	require.NoError(t, err)

	httpClient, baseURL := apitests.API(t, db,
		apitests.WithLocalAuth(dir),
		apitests.WithBitcoind(bitcoind),
		apitests.WithValidator(validator),
		apitests.WithCrypto(crypto),
	)

	t.Run("every service rejects a call with no token", func(t *testing.T) {
		h2 := http2Client(t)

		stream := grpcreflect.NewClient(h2, baseURL).NewStream(t.Context())
		names, err := stream.ListServices()
		require.NoError(t, err)
		_, err = stream.Close()
		require.NoError(t, err)

		var checked int
		for _, path := range names {
			// The runtime registers each service by its route path, "/pkg.Service/".
			name := protoreflect.FullName(strings.Trim(string(path), "/"))
			if strings.HasPrefix(string(name), "grpc.reflection.") {
				continue
			}
			desc, err := protoregistry.GlobalFiles.FindDescriptorByName(name)
			require.NoError(t, err)
			service, ok := desc.(protoreflect.ServiceDescriptor)
			require.True(t, ok)

			methods := service.Methods()
			for i := range methods.Len() {
				procedure := "/" + string(service.FullName()) + "/" + string(methods.Get(i).Name())
				var connectErr *connectv1.Error
				require.ErrorAs(t, callWithoutToken(t, h2, baseURL+procedure, methods.Get(i)), &connectErr, procedure)
				require.Equal(t, connectv1.CodeUnauthenticated, connectErr.Code(), procedure)
				require.Equal(t, localauth.TokenRejectedMessage, connectErr.Message(), procedure)
				checked++
			}
		}
		require.Positive(t, checked)
	})

	t.Run("enforcer jsonrpc rejects a call with no token", func(t *testing.T) {
		req, err := http.NewRequestWithContext(t.Context(), http.MethodPost, baseURL+"/enforcer/jsonrpc",
			strings.NewReader(`{"jsonrpc":"2.0","id":1,"method":"getblockcount","params":[]}`))
		require.NoError(t, err)
		req.Header.Set("Content-Type", "application/json")

		resp, err := httpClient.Do(req)
		require.NoError(t, err)
		require.NoError(t, resp.Body.Close())
		require.Equal(t, http.StatusUnauthorized, resp.StatusCode)
	})

	t.Run("a call with the cookie token passes auth", func(t *testing.T) {
		cli := healthv1connect.NewHealthServiceClient(connect.NewClient(connecthttp.NewTransport(httpClient, baseURL,
			connecthttp.WithReadMaxBytes(0),
		), localauth.ClientInterceptor(dir)))

		_, err := cli.Check(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)
	})
}

// http2Client speaks h2c, which bidi streams such as gRPC reflection need.
func http2Client(t *testing.T) *http.Client {
	t.Helper()

	protocols := new(http.Protocols)
	protocols.SetUnencryptedHTTP2(true)
	transport := &http.Transport{Protocols: protocols}
	t.Cleanup(transport.CloseIdleConnections)
	return &http.Client{Transport: transport}
}

// callWithoutToken sends an empty message, which is valid wire data for every
// request type, so the call reaches the auth check of any method.
func callWithoutToken(t *testing.T, h2 *http.Client, url string, method protoreflect.MethodDescriptor) error {
	t.Helper()

	client := connectv1.NewClient[emptypb.Empty, emptypb.Empty](h2, url)
	switch {
	case !method.IsStreamingClient() && !method.IsStreamingServer():
		_, err := client.CallUnary(t.Context(), connectv1.NewRequest(&emptypb.Empty{}))
		return err

	case !method.IsStreamingClient():
		stream, err := client.CallServerStream(t.Context(), connectv1.NewRequest(&emptypb.Empty{}))
		if err != nil {
			return err
		}
		for stream.Receive() {
		}
		return errors.Join(stream.Err(), stream.Close())

	default:
		stream := client.CallBidiStream(t.Context())
		if err := stream.CloseRequest(); err != nil {
			return err
		}
		_, err := stream.Receive()
		return errors.Join(err, stream.CloseResponse())
	}
}
