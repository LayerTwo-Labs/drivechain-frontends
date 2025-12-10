package api_health_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	healthv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1/healthv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"
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
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)
		mockCrypto := mocks.NewMockCryptoServiceClient(ctrl)

		// Background operations for bitcoind
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).
			AnyTimes()

		// Health check calls
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		mockValidator.EXPECT().
			GetChainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetChainInfoResponse]{
				Msg: &mainchainv1.GetChainInfoResponse{},
			}, nil).
			AnyTimes()

		mockWallet.EXPECT().
			GetInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetInfoResponse]{
				Msg: &mainchainv1.GetInfoResponse{},
			}, nil).
			AnyTimes()

		mockCrypto.EXPECT().
			Ripemd160(gomock.Any(), gomock.Any()).
			Return(&connect.Response[cryptov1.Ripemd160Response]{
				Msg: &cryptov1.Ripemd160Response{},
			}, nil).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.API(t, db,
			apitests.WithBitcoind(mockBitcoind),
			apitests.WithValidator(mockValidator),
			apitests.WithWallet(mockWallet),
			apitests.WithCrypto(mockCrypto),
		))

		resp, err := cli.Check(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		require.NotEmpty(t, resp.Msg.ServiceStatuses)

		// Check that we have status for each service
		serviceNames := make(map[string]bool)
		for _, status := range resp.Msg.ServiceStatuses {
			serviceNames[status.ServiceName] = true
		}
		assert.True(t, serviceNames["database"])
		assert.True(t, serviceNames["bitcoind"])
		assert.True(t, serviceNames["enforcer"])
		assert.True(t, serviceNames["wallet"])
		assert.True(t, serviceNames["crypto"])
	})

	t.Run("database health check", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		// Background operations
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).
			AnyTimes()
		// Health check
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.Check(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)

		// Find database status
		var dbStatus *healthv1.CheckResponse_ServiceStatus
		for _, status := range resp.Msg.ServiceStatuses {
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
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).
			AnyTimes()

		// Health check fails
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, nil)).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.Check(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)

		// Find bitcoind status
		var bitcoindStatus *healthv1.CheckResponse_ServiceStatus
		for _, status := range resp.Msg.ServiceStatuses {
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
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).
			AnyTimes()
		// Health check
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)
		// Health check fails
		mockValidator.EXPECT().
			GetChainInfo(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, nil)).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.API(t, db,
			apitests.WithBitcoind(mockBitcoind),
			apitests.WithValidator(mockValidator),
		))

		resp, err := cli.Check(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)

		// Find enforcer status
		var enforcerStatus *healthv1.CheckResponse_ServiceStatus
		for _, status := range resp.Msg.ServiceStatuses {
			if status.ServiceName == "enforcer" {
				enforcerStatus = status
				break
			}
		}
		require.NotNil(t, enforcerStatus)
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, enforcerStatus.Status)
	})

	t.Run("wallet unhealthy", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		// Background operations
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).
			AnyTimes()
		// Health check
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		mockWallet := mocks.NewMockWalletServiceClient(ctrl)
		// Health check fails
		mockWallet.EXPECT().
			GetInfo(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, nil)).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.API(t, db,
			apitests.WithBitcoind(mockBitcoind),
			apitests.WithWallet(mockWallet),
		))

		resp, err := cli.Check(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)

		// Find wallet status
		var walletStatus *healthv1.CheckResponse_ServiceStatus
		for _, status := range resp.Msg.ServiceStatuses {
			if status.ServiceName == "wallet" {
				walletStatus = status
				break
			}
		}
		require.NotNil(t, walletStatus)
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, walletStatus.Status)
	})

	t.Run("crypto unhealthy", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		// Background operations
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).
			AnyTimes()
		// Health check
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		mockCrypto := mocks.NewMockCryptoServiceClient(ctrl)

		// Health check fails
		mockCrypto.EXPECT().
			Ripemd160(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, nil)).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.API(t, db,
			apitests.WithBitcoind(mockBitcoind),
			apitests.WithCrypto(mockCrypto),
		))

		resp, err := cli.Check(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)

		// Find crypto status
		var cryptoStatus *healthv1.CheckResponse_ServiceStatus
		for _, status := range resp.Msg.ServiceStatuses {
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
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Chain: "signet"},
			}, nil).
			AnyTimes()

		// enforcer unhealthy
		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)
		mockValidator.EXPECT().
			GetChainInfo(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, nil)).
			AnyTimes()

		// wallet healthy
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)
		mockWallet.EXPECT().
			GetInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetInfoResponse]{
				Msg: &mainchainv1.GetInfoResponse{},
			}, nil).
			AnyTimes()

		// crypto unhealthy
		mockCrypto := mocks.NewMockCryptoServiceClient(ctrl)
		mockCrypto.EXPECT().
			Ripemd160(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, nil)).
			AnyTimes()

		cli := rpc.NewHealthServiceClient(apitests.API(t, db,
			apitests.WithBitcoind(mockBitcoind),
			apitests.WithValidator(mockValidator),
			apitests.WithWallet(mockWallet),
			apitests.WithCrypto(mockCrypto),
		))

		resp, err := cli.Check(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)

		// Check statuses
		statusMap := make(map[string]healthv1.CheckResponse_Status)
		for _, status := range resp.Msg.ServiceStatuses {
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
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, statusMap["wallet"])
		// crypto unhealthy (mock returns error)
		assert.Equal(t, healthv1.CheckResponse_STATUS_NOT_SERVING, statusMap["crypto"])
	})
}
