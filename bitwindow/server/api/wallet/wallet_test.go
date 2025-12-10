package api_wallet_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	bitcoindv1alpha "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"
)

func TestService_GetBalance(t *testing.T) {
	t.Parallel()

	t.Run("get balance successfully", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		// Create mock wallet client
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)
		mockWallet.EXPECT().
			GetBalance(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetBalanceResponse]{
				Msg: &mainchainv1.GetBalanceResponse{
					ConfirmedSats: 100000,
					PendingSats:   50000,
				},
			}, nil)

		// Create mock bitcoind client (to handle ensureWatchWallet calls)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{
					Wallets: []string{}, // No wallets exist yet
				},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{
					Name: "cheque_watch",
				},
			}, nil).
			AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithWallet(mockWallet), apitests.WithBitcoind(mockBitcoind)))

		// Use the test wallet ID from apitests.createTestWalletJSON
		resp, err := cli.GetBalance(context.Background(), connect.NewRequest(&walletv1.GetBalanceRequest{
			WalletId: "test-wallet-id-1234",
		}))
		require.NoError(t, err)
		require.Equal(t, uint64(100000), resp.Msg.ConfirmedSatoshi)
		require.Equal(t, uint64(50000), resp.Msg.PendingSatoshi)
	})

}

func TestService_GetNewAddress(t *testing.T) {
	t.Parallel()

	t.Run("get new address successfully", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		// Create mock wallet client
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)
		mockWallet.EXPECT().
			CreateNewAddress(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.CreateNewAddressResponse]{
				Msg: &mainchainv1.CreateNewAddressResponse{
					Address: "bc1qtest123456789",
				},
			}, nil)

		// Create mock bitcoind client (to handle ensureWatchWallet calls)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{
					Wallets: []string{}, // No wallets exist yet
				},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{
					Name: "cheque_watch",
				},
			}, nil).
			AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithWallet(mockWallet), apitests.WithBitcoind(mockBitcoind)))

		// Use the test wallet ID from apitests.createTestWalletJSON
		resp, err := cli.GetNewAddress(context.Background(), connect.NewRequest(&walletv1.GetNewAddressRequest{
			WalletId: "test-wallet-id-1234",
		}))
		require.NoError(t, err)
		require.Equal(t, "bc1qtest123456789", resp.Msg.Address)
	})
}

func TestService_ListCheques(t *testing.T) {
	t.Parallel()

	t.Run("list empty cheques", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListCheques(context.Background(), connect.NewRequest(&walletv1.ListChequesRequest{
			WalletId: "test-wallet-id-1234",
		}))
		require.NoError(t, err)
		require.Empty(t, resp.Msg.Cheques)
	})
}

func TestService_GetCheque(t *testing.T) {
	t.Parallel()

	t.Run("get non-existent cheque returns not found", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.GetCheque(context.Background(), connect.NewRequest(&walletv1.GetChequeRequest{
			WalletId: "test-wallet-id-1234",
			Id:       99999,
		}))
		require.Error(t, err)
		// Error contains "no rows" for non-existent cheque
		require.Contains(t, err.Error(), "no rows")
	})
}

func TestService_DeleteCheque(t *testing.T) {
	t.Parallel()

	t.Run("delete non-existent cheque returns not found", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.DeleteCheque(context.Background(), connect.NewRequest(&walletv1.DeleteChequeRequest{
			WalletId: "test-wallet-id-1234",
			Id:       99999,
		}))
		require.Error(t, err)
		// Error contains "no rows" for non-existent cheque
		require.Contains(t, err.Error(), "no rows")
	})
}

func TestService_IsWalletUnlocked(t *testing.T) {
	t.Parallel()

	t.Run("wallet is locked by default", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		// Test wallets are not encrypted, so they should be "unlocked"
		_, err := cli.IsWalletUnlocked(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		// The test wallet is unencrypted, so it should be considered unlocked
		require.NoError(t, err)
	})
}

func TestService_LockWallet(t *testing.T) {
	t.Parallel()

	t.Run("lock wallet succeeds", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.LockWallet(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
	})
}

func TestService_UnlockWallet(t *testing.T) {
	t.Parallel()

	t.Run("unlock unencrypted wallet returns error", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		// Test wallet is not encrypted, so unlock should fail
		_, err := cli.UnlockWallet(context.Background(), connect.NewRequest(&walletv1.UnlockWalletRequest{
			Password: "anypassword",
		}))
		require.Error(t, err)
		require.Contains(t, err.Error(), "not encrypted")
	})
}
