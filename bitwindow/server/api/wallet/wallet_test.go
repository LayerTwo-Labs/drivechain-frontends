package api_wallet_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	"github.com/stretchr/testify/assert"
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

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithWallet(mockWallet)))

		resp, err := cli.GetBalance(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		assert.EqualValues(t, 100000, resp.Msg.ConfirmedSatoshi)
		assert.EqualValues(t, 50000, resp.Msg.PendingSatoshi)
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

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithWallet(mockWallet)))

		resp, err := cli.GetNewAddress(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		assert.Equal(t, "bc1qtest123456789", resp.Msg.Address)
	})
}
