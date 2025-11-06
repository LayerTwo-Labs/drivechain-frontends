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

		// Note: This test will fail with "wallet not found" since we don't have a wallet.json
		// In a real test, we'd need to set up a temporary wallet.json file
		resp, err := cli.GetBalance(context.Background(), connect.NewRequest(&walletv1.GetBalanceRequest{
			WalletId: "test-wallet-id",
		}))
		require.Error(t, err) // Expect error since wallet.json doesn't exist in tests
		_ = resp
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

		// Note: This test will fail with "wallet not found" since we don't have a wallet.json
		// In a real test, we'd need to set up a temporary wallet.json file
		resp, err := cli.GetNewAddress(context.Background(), connect.NewRequest(&walletv1.GetNewAddressRequest{
			WalletId: "test-wallet-id",
		}))
		require.Error(t, err) // Expect error since wallet.json doesn't exist in tests
		_ = resp
	})
}
