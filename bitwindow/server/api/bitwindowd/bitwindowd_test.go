package api_bitwindowd_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	v1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	v1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

func TestService_Stop(t *testing.T) {
	t.Parallel()

	database := database.Test(t)
	cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

	t.Run("shutdown success", func(t *testing.T) {
		t.Parallel()

		_, err := cli.Stop(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
	})
}

func TestService_CreateDenial(t *testing.T) {
	t.Parallel()

	database := database.Test(t)

	ctrl := gomock.NewController(t)
	mockWallet := mocks.NewMockWalletServiceClient(ctrl)
	mockWallet.EXPECT().
		ListUnspentOutputs(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(&connect.Response[mainchainv1.ListUnspentOutputsResponse]{
			Msg: &mainchainv1.ListUnspentOutputsResponse{
				Outputs: []*mainchainv1.ListUnspentOutputsResponse_Output{
					{
						Txid: &commonv1.ReverseHex{
							Hex: &wrapperspb.StringValue{
								Value: "abc123",
							},
						},
						Vout:        0,
						ValueSats:   1000000,
						IsInternal:  false,
						IsConfirmed: true,
					},
				},
			},
		}, nil)

	cli := v1connect.NewBitwindowdServiceClient(
		apitests.API(
			t,
			database,
			apitests.WithWallet(mockWallet),
		))

	t.Run("invalid delay seconds", func(t *testing.T) {
		t.Parallel()

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 0,
			NumHops:      1,
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("invalid num hops", func(t *testing.T) {
		t.Parallel()

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      0,
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("utxo not found", func(t *testing.T) {
		t.Parallel()

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "nonexistent",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      1,
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("utxo found", func(t *testing.T) {
		t.Parallel()

		res, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      1,
		}))
		require.NoError(t, err)
		assert.NotNil(t, res.Msg.Deniability)

		resp, err := cli.ListDenials(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Utxos, 1)
		assert.NotNil(t, resp.Msg.Utxos[0].Deniability)
	})
}

func TestService_ListDenials(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)

	mockWallet := mocks.NewMockWalletServiceClient(ctrl)
	mockWallet.EXPECT().
		ListUnspentOutputs(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(&connect.Response[mainchainv1.ListUnspentOutputsResponse]{
			Msg: &mainchainv1.ListUnspentOutputsResponse{
				Outputs: []*mainchainv1.ListUnspentOutputsResponse_Output{
					{
						Txid: &commonv1.ReverseHex{
							Hex: &wrapperspb.StringValue{
								Value: "abc123",
							},
						},
						Vout:        0,
						ValueSats:   1000000,
						IsInternal:  false,
						IsConfirmed: true,
					},
				},
			},
		}, nil)

	cli := v1connect.NewBitwindowdServiceClient(
		apitests.API(
			t,
			database.Test(t),
			apitests.WithWallet(mockWallet),
		))

	t.Run("empty list", func(t *testing.T) {
		t.Parallel()

		resp, err := cli.ListDenials(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Utxos, 1)
		assert.Nil(t, resp.Msg.Utxos[0].Deniability)
	})

	t.Run("with denials", func(t *testing.T) {
		t.Parallel()

		// Create a denial first
		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      1,
		}))
		require.NoError(t, err)

		resp, err := cli.ListDenials(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		assert.NotEmpty(t, resp.Msg.Utxos)
	})
}

func TestService_CancelDenial(t *testing.T) {
	t.Parallel()

	database := database.Test(t)
	cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

	t.Run("non-existent denial", func(t *testing.T) {
		t.Parallel()

		_, err := cli.CancelDenial(context.Background(), connect.NewRequest(&v1.CancelDenialRequest{
			Id: 999,
		}))
		assert.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	})
}

func TestService_AddressBook(t *testing.T) {
	t.Parallel()

	database := database.Test(t)
	cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

	t.Run("create entry", func(t *testing.T) {
		t.Parallel()

		_, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "Test Address",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.NoError(t, err)
	})

	t.Run("list entries", func(t *testing.T) {
		t.Parallel()

		// Create an entry first
		_, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "Test Address",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.NoError(t, err)

		resp, err := cli.ListAddressBook(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		assert.NotEmpty(t, resp.Msg.Entries)
	})

	t.Run("update entry", func(t *testing.T) {
		t.Parallel()

		// Create an entry first
		createResp, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "Original Label",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.NoError(t, err)

		// Update the entry
		_, err = cli.UpdateAddressBookEntry(context.Background(), connect.NewRequest(&v1.UpdateAddressBookEntryRequest{
			Id:    createResp.Msg.Entry.Id,
			Label: "Updated Label",
		}))
		require.NoError(t, err)
	})

	t.Run("delete entry", func(t *testing.T) {
		t.Parallel()

		// Create an entry first
		createResp, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "Test Address",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.NoError(t, err)

		// Delete the entry
		_, err = cli.DeleteAddressBookEntry(context.Background(), connect.NewRequest(&v1.DeleteAddressBookEntryRequest{
			Id: createResp.Msg.Entry.Id,
		}))
		require.NoError(t, err)
	})
}

func TestService_GetSyncInfo(t *testing.T) {
	t.Parallel()

	t.Run("get sync info", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{
					Chain: "main",
				},
			}, nil)

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.GetSyncInfo(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		assert.NotNil(t, resp.Msg)
		assert.GreaterOrEqual(t, resp.Msg.TipBlockHeight, int64(0))
		assert.GreaterOrEqual(t, resp.Msg.HeaderHeight, int64(0))
		assert.GreaterOrEqual(t, resp.Msg.SyncProgress, float64(0))
		assert.LessOrEqual(t, resp.Msg.SyncProgress, float64(1))
	})
}

func TestService_SetTransactionNote(t *testing.T) {
	t.Parallel()

	database := database.Test(t)
	cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

	t.Run("set note", func(t *testing.T) {
		t.Parallel()

		_, err := cli.SetTransactionNote(context.Background(), connect.NewRequest(&v1.SetTransactionNoteRequest{
			Txid: "abc123",
			Note: "Test note",
		}))
		require.NoError(t, err)
	})
}
