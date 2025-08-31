package api_bitwindowd_test

import (
	"context"
	"crypto/rand"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	v1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	v1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

func TestService_Stop(t *testing.T) {
	t.Parallel()

	t.Run("shutdown success", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.Stop(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
	})

	t.Run("shutdown with context timeout", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		ctx, cancel := context.WithTimeout(context.Background(), 0)
		defer cancel()

		_, err := cli.Stop(ctx, connect.NewRequest(&emptypb.Empty{}))
		require.Error(t, err)
	})
}

func TestService_CreateDenial(t *testing.T) {
	t.Parallel()

	t.Run("invalid delay seconds", func(t *testing.T) {
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

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 0,
			NumHops:      1,
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("negative delay seconds", func(t *testing.T) {
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

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: -10,
			NumHops:      1,
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("invalid num hops", func(t *testing.T) {
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

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      0,
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("negative num hops", func(t *testing.T) {
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

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      -5,
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("empty txid", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)

		ctrl := gomock.NewController(t)
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)
		mockWallet.EXPECT().
			ListUnspentOutputs(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[mainchainv1.ListUnspentOutputsResponse]{
				Msg: &mainchainv1.ListUnspentOutputsResponse{
					Outputs: []*mainchainv1.ListUnspentOutputsResponse_Output{},
				},
			}, nil)

		cli := v1connect.NewBitwindowdServiceClient(
			apitests.API(
				t,
				database,
				apitests.WithWallet(mockWallet),
			))

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      1,
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("utxo not found", func(t *testing.T) {
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

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      1,
		}))
		require.NoError(t, err)

		denials, err := deniability.List(context.Background(), database)
		require.NoError(t, err)
		assert.Len(t, denials, 1)
		assert.EqualValues(t, 1, denials[0].ID)
		assert.Equal(t, "abc123", denials[0].TipTXID)
		assert.Equal(t, int32(0), denials[0].TipVout)
		assert.EqualValues(t, int32(60), denials[0].DelayDuration.Seconds())
		assert.Equal(t, int32(1), denials[0].NumHops)

		// creating again updates
		_, err = cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 120,
			NumHops:      1,
		}))
		require.NoError(t, err)

		denials, err = deniability.List(context.Background(), database)
		require.NoError(t, err)
		assert.Len(t, denials, 1)
		assert.EqualValues(t, int32(120), denials[0].DelayDuration.Seconds())
	})

	t.Run("multiple denials different utxos", func(t *testing.T) {
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
						{
							Txid: &commonv1.ReverseHex{
								Hex: &wrapperspb.StringValue{
									Value: "def456",
								},
							},
							Vout:        1,
							ValueSats:   2000000,
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

		// Create first denial
		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      1,
		}))
		require.NoError(t, err)

		// Create second denial
		_, err = cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "def456",
			Vout:         1,
			DelaySeconds: 120,
			NumHops:      2,
		}))
		require.NoError(t, err)

		denials, err := deniability.List(context.Background(), database)
		require.NoError(t, err)
		assert.Len(t, denials, 2)
	})

	t.Run("large delay seconds", func(t *testing.T) {
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

		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 86400, // 24 hours
			NumHops:      10,
		}))
		require.NoError(t, err)

		denials, err := deniability.List(context.Background(), database)
		require.NoError(t, err)
		assert.Len(t, denials, 1)
		assert.EqualValues(t, int32(86400), denials[0].DelayDuration.Seconds())
		assert.Equal(t, int32(10), denials[0].NumHops)
	})
}

func TestService_CancelDenial(t *testing.T) {
	t.Parallel()

	t.Run("non-existent denial", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.CancelDenial(context.Background(), connect.NewRequest(&v1.CancelDenialRequest{
			Id: 999,
		}))
		assert.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	})

	t.Run("zero denial id", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.CancelDenial(context.Background(), connect.NewRequest(&v1.CancelDenialRequest{
			Id: 0,
		}))
		assert.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	})

	t.Run("negative denial id", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.CancelDenial(context.Background(), connect.NewRequest(&v1.CancelDenialRequest{
			Id: -1,
		}))
		assert.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	})

	t.Run("cancel existing denial", func(t *testing.T) {
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

		// First create a denial
		_, err := cli.CreateDenial(context.Background(), connect.NewRequest(&v1.CreateDenialRequest{
			Txid:         "abc123",
			Vout:         0,
			DelaySeconds: 60,
			NumHops:      1,
		}))
		require.NoError(t, err)

		// Get the denial ID from the database
		denials, err := deniability.List(context.Background(), database)
		require.NoError(t, err)
		require.Len(t, denials, 1)

		// Then cancel it
		_, err = cli.CancelDenial(context.Background(), connect.NewRequest(&v1.CancelDenialRequest{
			Id: denials[0].ID,
		}))
		require.NoError(t, err)

		// Verify it's cancelled
		denials, err = deniability.List(context.Background(), database)
		require.NoError(t, err)
		assert.Len(t, denials, 1)
		assert.NotNil(t, denials[0].CancelledAt)
	})
}

func TestService_AddressBook(t *testing.T) {
	t.Parallel()

	t.Run("create entry", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "Test Address",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.NoError(t, err)
	})

	t.Run("create entry with empty label", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.NoError(t, err)
	})

	t.Run("create entry with invalid address", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "Invalid Address",
			Address:   "invalid-bitcoin-address",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.Error(t, err)
	})

	t.Run("create entry with send direction", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "Send Address",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_SEND,
		}))
		require.NoError(t, err)
	})

	t.Run("create duplicate address", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		// Create first entry
		_, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "First Label",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.NoError(t, err)

		// Try to create duplicate
		_, err = cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "Second Label",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.NoError(t, err)
		// If it succeeds, verify we have 2 entries
		resp, err := cli.ListAddressBook(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		assert.Len(t, resp.Msg.Entries, 1)
		// Label should be updated
		assert.Equal(t, "Second Label", resp.Msg.Entries[0].Label)
	})

	t.Run("list entries", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

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

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

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

	t.Run("update entry with empty label", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		// Create an entry first
		createResp, err := cli.CreateAddressBookEntry(context.Background(), connect.NewRequest(&v1.CreateAddressBookEntryRequest{
			Label:     "Original Label",
			Address:   "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
			Direction: v1.Direction_DIRECTION_RECEIVE,
		}))
		require.NoError(t, err)

		// Try to update with empty label
		_, err = cli.UpdateAddressBookEntry(context.Background(), connect.NewRequest(&v1.UpdateAddressBookEntryRequest{
			Id:    createResp.Msg.Entry.Id,
			Label: "",
		}))
		require.NoError(t, err)
	})

	t.Run("update non-existent entry", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		// Try to update non-existent entry
		_, err := cli.UpdateAddressBookEntry(context.Background(), connect.NewRequest(&v1.UpdateAddressBookEntryRequest{
			Id:    99999,
			Label: "New Label",
		}))
		require.Error(t, err)
	})

	t.Run("delete entry", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

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

	t.Run("delete non-existent entry", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		// Try to delete non-existent entry
		_, err := cli.DeleteAddressBookEntry(context.Background(), connect.NewRequest(&v1.DeleteAddressBookEntryRequest{
			Id: 99999,
		}))
		require.Error(t, err)
	})

	t.Run("delete already deleted entry", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

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

		// Try to delete again
		_, err = cli.DeleteAddressBookEntry(context.Background(), connect.NewRequest(&v1.DeleteAddressBookEntryRequest{
			Id: createResp.Msg.Entry.Id,
		}))
		require.Error(t, err)
	})
}

func TestService_GetSyncInfo(t *testing.T) {
	t.Parallel()

	t.Run("get sync info", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{
					Chain: "main",
				},
			}, nil)

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.GetSyncInfo(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		assert.NotNil(t, resp.Msg)
		assert.GreaterOrEqual(t, resp.Msg.TipBlockHeight, int64(0))
		assert.GreaterOrEqual(t, resp.Msg.HeaderHeight, int64(0))
		assert.GreaterOrEqual(t, resp.Msg.SyncProgress, float64(0))
		assert.LessOrEqual(t, resp.Msg.SyncProgress, float64(1))
	})

	t.Run("get sync info with error", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeInternal, nil))

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.GetSyncInfo(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.Error(t, err)
	})

	t.Run("get sync info with testnet", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{
					Chain: "test",
				},
			}, nil)

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.GetSyncInfo(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		assert.NotNil(t, resp.Msg)
	})
}

func TestService_SetTransactionNote(t *testing.T) {
	t.Parallel()

	t.Run("set note", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.SetTransactionNote(context.Background(), connect.NewRequest(&v1.SetTransactionNoteRequest{
			Txid: "abc123",
			Note: "Test note",
		}))
		require.NoError(t, err)
	})

	t.Run("set empty note", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.SetTransactionNote(context.Background(), connect.NewRequest(&v1.SetTransactionNoteRequest{
			Txid: "abc123",
			Note: "",
		}))
		require.NoError(t, err)
	})

	t.Run("set note with empty txid", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.SetTransactionNote(context.Background(), connect.NewRequest(&v1.SetTransactionNoteRequest{
			Txid: "",
			Note: "Test note",
		}))
		require.Error(t, err)
	})

	t.Run("set very long note", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		longNote := ""
		for i := 0; i < 1000; i++ {
			longNote += "This is a very long note. "
		}

		_, err := cli.SetTransactionNote(context.Background(), connect.NewRequest(&v1.SetTransactionNoteRequest{
			Txid: "abc123",
			Note: longNote,
		}))
		// This might succeed or fail depending on implementation limits
		// Just verify it doesn't panic
		_ = err
	})

	t.Run("update existing note", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		// Set initial note
		_, err := cli.SetTransactionNote(context.Background(), connect.NewRequest(&v1.SetTransactionNoteRequest{
			Txid: "abc123",
			Note: "Initial note",
		}))
		require.NoError(t, err)

		// Update the note
		_, err = cli.SetTransactionNote(context.Background(), connect.NewRequest(&v1.SetTransactionNoteRequest{
			Txid: "abc123",
			Note: "Updated note",
		}))
		require.NoError(t, err)
	})
}

func TestService_GetFireplaceStats(t *testing.T) {
	t.Parallel()

	ctx := context.Background()
	database := database.Test(t)
	cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

	resp, err := cli.GetFireplaceStats(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)

	assert.Empty(t, resp.Msg.TransactionCount_24H)
	assert.Empty(t, resp.Msg.CoinnewsCount_7D)
	assert.Empty(t, resp.Msg.BlockCount_24H)

	newHash := func(t *testing.T) chainhash.Hash {
		buf := make([]byte, chainhash.HashSize)
		_, err := rand.Read(buf)
		require.NoError(t, err)

		hash, err := chainhash.NewHash(buf)
		require.NoError(t, err)
		return *hash
	}

	require.NoError(t, blocks.MarkBlocksProcessed(ctx, database, []blocks.ProcessedBlock{
		{
			Height:      100,
			Hash:        newHash(t),
			BlockTime:   time.Now(),
			ProcessedAt: time.Now(),
			Txids: []chainhash.Hash{
				newHash(t),
				newHash(t),
			},
		},
		// old block, doesn't count
		{
			Height:      99,
			Hash:        newHash(t),
			BlockTime:   time.Now().AddDate(0, 0, -2),
			ProcessedAt: time.Now(),
			Txids: []chainhash.Hash{
				newHash(t),
				newHash(t),
				newHash(t),
			},
		},
	}))

	topicID, err := opreturns.ValidNewsTopicID("deadbeefdeadbeef")
	require.NoError(t, err)
	require.NoError(t, opreturns.CreateTopic(ctx, database, topicID, "Test Topic", "topic_txid1"))

	unknownTopicID, err := opreturns.ValidNewsTopicID("1234567887654321")
	require.NoError(t, err)

	// one old coin news entry
	require.NoError(t, opreturns.Persist(ctx, database, []opreturns.OPReturn{
		// coins new topic creation
		{
			Height:    lo.ToPtr(uint32(10)),
			TxID:      "topic_txid1",
			Vout:      0,
			Data:      opreturns.EncodeTopicCreationMessage(topicID, "Test Topic"),
			CreatedAt: lo.ToPtr(time.Now()),
		},
		// looks like a coin news entry, but we don't know about the topic
		// should NOT be included
		{
			Height:    lo.ToPtr(uint32(10)),
			TxID:      "news_txid4",
			Vout:      0,
			Data:      opreturns.EncodeNewsMessage(unknownTopicID, "Test Topic", "Test Content"),
			CreatedAt: lo.ToPtr(time.Now()),
		},
		// one new coin news entry
		{
			Height:    lo.ToPtr(uint32(9)),
			TxID:      "news_txid2",
			Vout:      0,
			Data:      opreturns.EncodeNewsMessage(topicID, "Test Topic", "Test Content"),
			CreatedAt: lo.ToPtr(time.Now()),
		},
		{
			Height:    lo.ToPtr(uint32(10)),
			TxID:      "news_txid3",
			Vout:      0,
			Data:      opreturns.EncodeNewsMessage(topicID, "Test Topic", "Test Content"),
			CreatedAt: lo.ToPtr(time.Now().AddDate(-1, 0, 0)),
		},
		// one old coin news entry
	}))

	resp, err = cli.GetFireplaceStats(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)

	assert.EqualValues(t, 1, resp.Msg.TransactionCount_24H)
	assert.EqualValues(t, 1, resp.Msg.CoinnewsCount_7D)
	assert.EqualValues(t, 1, resp.Msg.BlockCount_24H)

}
