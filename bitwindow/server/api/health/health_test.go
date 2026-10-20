package health_test

import (
	"context"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"
	"time"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"

	api_health "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/health"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	healthv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1/healthv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

func TestService_Check(t *testing.T) {
	t.Parallel()

	t.Run("returns service statuses", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		// Create mocks for all services
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)
		mockCrypto := mocks.NewMockCryptoServiceClient(ctrl)

		apitests.ExpectCoreWalletSetup(mockBitcoind)

		// Health check calls
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		mockValidator.EXPECT().
			GetChainInfo(gomock.Any(), gomock.Any()).
			Return(&mainchainv1.GetChainInfoResponse{}, nil).
			AnyTimes()

		mockCrypto.EXPECT().
			Ripemd160(gomock.Any(), gomock.Any()).
			Return(&cryptov1.Ripemd160Response{}, nil).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.RPC(t, db,
			apitests.WithBitcoind(mockBitcoind),
			apitests.WithValidator(mockValidator),
			apitests.WithCrypto(mockCrypto),
		))

		resp, err := cli.Check(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)
		require.NotEmpty(t, resp.ServiceStatuses)

		// Check that we have status for each service
		serviceNames := make(map[string]bool)
		for _, status := range resp.ServiceStatuses {
			serviceNames[status.ServiceName] = true
		}
		assert.True(t, serviceNames["database"])
		assert.True(t, serviceNames["bitcoind"])
		assert.True(t, serviceNames["enforcer"])
		assert.NotContains(t, serviceNames, "wallet", "the enforcer runs no wallet")
		assert.True(t, serviceNames["crypto"])
	})

	t.Run("database health check", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		// Background operations
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		// Health check
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.RPC(t, db, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.Check(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)

		// Find database status
		var dbStatus *healthv1.CheckResponse_ServiceStatus
		for _, status := range resp.ServiceStatuses {
			if status.ServiceName == "database" {
				dbStatus = status
				break
			}
		}
		require.NotNil(t, dbStatus)
		assert.Equal(t, healthv1.CheckResponse_STATUS_SERVING, dbStatus.Status)
	})

	t.Run("bitcoind unhealthy", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		// Background operations still need to work
		apitests.ExpectCoreWalletSetup(mockBitcoind)

		// Health check fails
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(nil, connectv1.NewError(connectv1.CodeUnavailable, nil)).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.RPC(t, db, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.Check(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)

		// Find bitcoind status
		var bitcoindStatus *healthv1.CheckResponse_ServiceStatus
		for _, status := range resp.ServiceStatuses {
			if status.ServiceName == "bitcoind" {
				bitcoindStatus = status
				break
			}
		}
		require.NotNil(t, bitcoindStatus)
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, bitcoindStatus.Status)
	})

	t.Run("enforcer unhealthy", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		// Background operations
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		// Health check
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)
		// Health check fails
		mockValidator.EXPECT().
			GetChainInfo(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, "")).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.RPC(t, db,
			apitests.WithBitcoind(mockBitcoind),
			apitests.WithValidator(mockValidator),
		))

		resp, err := cli.Check(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)

		// Find enforcer status
		var enforcerStatus *healthv1.CheckResponse_ServiceStatus
		for _, status := range resp.ServiceStatuses {
			if status.ServiceName == "enforcer" {
				enforcerStatus = status
				break
			}
		}
		require.NotNil(t, enforcerStatus)
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, enforcerStatus.Status)
	})

	t.Run("crypto unhealthy", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		// Background operations
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		// Health check
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		mockCrypto := mocks.NewMockCryptoServiceClient(ctrl)

		// Health check fails
		mockCrypto.EXPECT().
			Ripemd160(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, "")).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.RPC(t, db,
			apitests.WithBitcoind(mockBitcoind),
			apitests.WithCrypto(mockCrypto),
		))

		resp, err := cli.Check(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)

		// Find crypto status
		var cryptoStatus *healthv1.CheckResponse_ServiceStatus
		for _, status := range resp.ServiceStatuses {
			if status.ServiceName == "crypto" {
				cryptoStatus = status
				break
			}
		}
		require.NotNil(t, cryptoStatus)
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, cryptoStatus.Status)
	})

	t.Run("partial failures", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		// bitcoind healthy
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		// enforcer unhealthy
		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)
		mockValidator.EXPECT().
			GetChainInfo(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, "")).
			AnyTimes()

		// wallet healthy
		// crypto unhealthy
		mockCrypto := mocks.NewMockCryptoServiceClient(ctrl)
		mockCrypto.EXPECT().
			Ripemd160(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, "")).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.RPC(t, db,
			apitests.WithBitcoind(mockBitcoind),
			apitests.WithValidator(mockValidator),
			apitests.WithCrypto(mockCrypto),
		))

		resp, err := cli.Check(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)

		// Check statuses
		statusMap := make(map[string]healthv1.CheckResponse_Status)
		for _, status := range resp.ServiceStatuses {
			statusMap[status.ServiceName] = status.Status
		}

		// Database is always healthy (we're using a real test DB)
		assert.Equal(t, healthv1.CheckResponse_STATUS_SERVING, statusMap["database"])
		// bitcoind healthy - ensureWatchWallet goroutine causes it to connect
		assert.Equal(t, healthv1.CheckResponse_STATUS_SERVING, statusMap["bitcoind"])
		// enforcer unhealthy (mock returns error)
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, statusMap["enforcer"])
		// wallet and crypto report NOT_SERVING because their services haven't
		// been connected yet (no eager caller like ensureWatchWallet for bitcoind).
		// The mocks would succeed if called, but IsConnected() returns false
		// until the reconnect loop ticks or Get() is called.
		// crypto unhealthy (mock returns error)
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, statusMap["crypto"])
	})
}

func refuse[T any](context.Context) (T, error) {
	var zero T
	return zero, errors.New("refused")
}

func TestService_Watch(t *testing.T) {
	t.Run("a connection change reaches the stream", func(t *testing.T) {
		var enforcerUp atomic.Bool
		enforcer := service.New("enforcer", func(context.Context) (validatorrpc.ValidatorServiceClient, error) {
			if !enforcerUp.Load() {
				return nil, errors.New("refused")
			}
			return nil, nil
		})
		srv := api_health.New(database.Test(t),
			service.New("bitcoind", refuse[corerpc.BitcoinServiceClient]),
			enforcer,
			service.New("crypto", refuse[cryptorpc.CryptoServiceClient]),
		)
		mux := http.NewServeMux()
		srv2 := connect.NewServer()
		rpc.RegisterHealthServiceHandler(srv2, srv)
		connecthttp.Mount(mux, srv2, connecthttp.WithReadMaxBytes(0))
		server := httptest.NewServer(mux)
		t.Cleanup(server.Close)

		ctx, cancel := context.WithTimeout(t.Context(), 10*time.Second)
		defer cancel()
		stream, err := rpc.NewHealthServiceClient(connect.NewClient(connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0)))).
			Watch(ctx, &emptypb.Empty{})
		require.NoError(t, err)
		t.Cleanup(func() { require.NoError(t, stream.Close()) })

		statusOf := func(response *healthv1.CheckResponse, name string) healthv1.CheckResponse_Status {
			for _, st := range response.ServiceStatuses {
				if st.ServiceName == name {
					return st.Status
				}
			}
			t.Fatalf("no status for %s", name)
			return 0
		}

		response, err := stream.Receive()
		require.NoError(t, err)
		assert.Equal(t, healthv1.CheckResponse_STATUS_SERVING, statusOf(response, "database"))
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, statusOf(response, "enforcer"))

		enforcerUp.Store(true)
		_, err = enforcer.Connect(ctx)
		require.NoError(t, err)

		var streamErr error
		for {
			response, err := stream.Receive()
			if err != nil {
				streamErr = err
				break
			}
			if statusOf(response, "enforcer") == healthv1.CheckResponse_STATUS_SERVING {
				assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, statusOf(response, "bitcoind"))
				return
			}
		}
		if errors.Is(streamErr, io.EOF) {
			streamErr = nil
		}
		t.Fatalf("the stream ended before the enforcer was serving: %v", streamErr)
	})
}
