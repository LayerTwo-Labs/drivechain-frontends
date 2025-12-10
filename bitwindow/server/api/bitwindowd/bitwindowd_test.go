package api_bitwindowd_test

import (
	"context"
	"crypto/rand"
	"fmt"
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
	"google.golang.org/protobuf/types/known/timestamppb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

func TestService_Stop(t *testing.T) {
	t.Parallel()

	t.Run("shutdown success", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		_, err := cli.Stop(context.Background(), connect.NewRequest(&v1.BitwindowdServiceStopRequest{}))
		require.NoError(t, err)
	})

	t.Run("shutdown with context timeout", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, database))

		ctx, cancel := context.WithTimeout(context.Background(), 0)
		defer cancel()

		_, err := cli.Stop(ctx, connect.NewRequest(&v1.BitwindowdServiceStopRequest{}))
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

		// Background operations expectations
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{
					Wallets: []string{},
				},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{
					Name: "cheque_watch",
				},
			}, nil).
			AnyTimes()

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

		// Background operations expectations
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{
					Wallets: []string{},
				},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{
					Name: "cheque_watch",
				},
			}, nil).
			AnyTimes()

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

		// Background operations expectations
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{
					Wallets: []string{},
				},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{
					Name: "cheque_watch",
				},
			}, nil).
			AnyTimes()

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

	topicID, err := opreturns.ValidNewsTopicID("deadbeef")
	require.NoError(t, err)
	require.NoError(t, opreturns.CreateTopic(ctx, database, topicID, "Test Topic", "topic_txid1", true))

	unknownTopicID, err := opreturns.ValidNewsTopicID("12345678")
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

func TestService_PauseDenial(t *testing.T) {
	t.Parallel()

	t.Run("pause existing denial", func(t *testing.T) {
		t.Parallel()

		ctx := context.Background()
		db := database.Test(t)

		ctrl := gomock.NewController(t)
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)
		mockWallet.EXPECT().
			ListUnspentOutputs(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[mainchainv1.ListUnspentOutputsResponse]{
				Msg: &mainchainv1.ListUnspentOutputsResponse{
					Outputs: []*mainchainv1.ListUnspentOutputsResponse_Output{
						{
							Txid: &commonv1.ReverseHex{Hex: &wrapperspb.StringValue{Value: "abc123"}},
							Vout: 0, ValueSats: 1000000,
						},
					},
				},
			}, nil)

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db, apitests.WithWallet(mockWallet)))

		// First create a denial
		_, err := cli.CreateDenial(ctx, connect.NewRequest(&v1.CreateDenialRequest{
			Txid: "abc123", Vout: 0, DelaySeconds: 60, NumHops: 1,
		}))
		require.NoError(t, err)

		// Get the denial ID from the database
		denials, err := deniability.List(ctx, db)
		require.NoError(t, err)
		require.Len(t, denials, 1)
		denialID := denials[0].ID

		// Pause it
		_, err = cli.PauseDenial(ctx, connect.NewRequest(&v1.PauseDenialRequest{Id: denialID}))
		require.NoError(t, err)

		// Verify it's paused by checking the database
		denials, err = deniability.List(ctx, db)
		require.NoError(t, err)
		require.Len(t, denials, 1)
		assert.NotNil(t, denials[0].PausedAt)
	})

	t.Run("pause non-existent denial returns error", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db))

		_, err := cli.PauseDenial(context.Background(), connect.NewRequest(&v1.PauseDenialRequest{Id: 99999}))
		require.Error(t, err)
	})
}

func TestService_ResumeDenial(t *testing.T) {
	t.Parallel()

	t.Run("resume paused denial", func(t *testing.T) {
		t.Parallel()

		ctx := context.Background()
		db := database.Test(t)

		ctrl := gomock.NewController(t)
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)
		mockWallet.EXPECT().
			ListUnspentOutputs(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[mainchainv1.ListUnspentOutputsResponse]{
				Msg: &mainchainv1.ListUnspentOutputsResponse{
					Outputs: []*mainchainv1.ListUnspentOutputsResponse_Output{
						{
							Txid: &commonv1.ReverseHex{Hex: &wrapperspb.StringValue{Value: "abc123"}},
							Vout: 0, ValueSats: 1000000,
						},
					},
				},
			}, nil)

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db, apitests.WithWallet(mockWallet)))

		// Create a denial
		_, err := cli.CreateDenial(ctx, connect.NewRequest(&v1.CreateDenialRequest{
			Txid: "abc123", Vout: 0, DelaySeconds: 60, NumHops: 1,
		}))
		require.NoError(t, err)

		// Get the denial ID from the database
		denials, err := deniability.List(ctx, db)
		require.NoError(t, err)
		require.Len(t, denials, 1)
		denialID := denials[0].ID

		// Pause it
		_, err = cli.PauseDenial(ctx, connect.NewRequest(&v1.PauseDenialRequest{Id: denialID}))
		require.NoError(t, err)

		// Resume it
		_, err = cli.ResumeDenial(ctx, connect.NewRequest(&v1.ResumeDenialRequest{Id: denialID}))
		require.NoError(t, err)

		// Verify it's resumed by checking the database
		denials, err = deniability.List(ctx, db)
		require.NoError(t, err)
		require.Len(t, denials, 1)
		assert.Nil(t, denials[0].PausedAt)
	})

	t.Run("resume non-existent denial returns error", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db))

		_, err := cli.ResumeDenial(context.Background(), connect.NewRequest(&v1.ResumeDenialRequest{Id: 99999}))
		require.Error(t, err)
	})
}

func TestService_ListBlocks(t *testing.T) {
	t.Parallel()

	t.Run("list blocks with default pagination", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		// Mock ListWallets and CreateWallet for background ensureWatchWallet
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		// Mock GetBlockchainInfo
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Blocks: 100},
			}, nil)

		// Mock GetBlockHash and GetBlock for each block (default page size is 50)
		for i := 0; i < 50; i++ {
			height := uint32(100 - i)
			mockBitcoind.EXPECT().
				GetBlockHash(gomock.Any(), gomock.Any()).
				Return(&connect.Response[corepb.GetBlockHashResponse]{
					Msg: &corepb.GetBlockHashResponse{Hash: fmt.Sprintf("hash%d", height)},
				}, nil)
			mockBitcoind.EXPECT().
				GetBlock(gomock.Any(), gomock.Any()).
				Return(&connect.Response[corepb.GetBlockResponse]{
					Msg: &corepb.GetBlockResponse{
						Height:        height,
						Hash:          fmt.Sprintf("hash%d", height),
						Time:          timestamppb.Now(),
						Confirmations: int32(100 - int(height) + 1),
					},
				}, nil)
		}

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListBlocks(context.Background(), connect.NewRequest(&v1.ListBlocksRequest{}))
		require.NoError(t, err)
		assert.Len(t, resp.Msg.RecentBlocks, 50)
		assert.True(t, resp.Msg.HasMore)

		// Verify blocks are sorted by height descending
		for i := 1; i < len(resp.Msg.RecentBlocks); i++ {
			assert.Greater(t, resp.Msg.RecentBlocks[i-1].Height, resp.Msg.RecentBlocks[i].Height)
		}
	})

	t.Run("list blocks with custom page size", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Blocks: 10},
			}, nil)

		// Mock for 5 blocks
		for i := 0; i < 5; i++ {
			height := uint32(10 - i)
			mockBitcoind.EXPECT().
				GetBlockHash(gomock.Any(), gomock.Any()).
				Return(&connect.Response[corepb.GetBlockHashResponse]{
					Msg: &corepb.GetBlockHashResponse{Hash: fmt.Sprintf("hash%d", height)},
				}, nil)
			mockBitcoind.EXPECT().
				GetBlock(gomock.Any(), gomock.Any()).
				Return(&connect.Response[corepb.GetBlockResponse]{
					Msg: &corepb.GetBlockResponse{
						Height: height,
						Hash:   fmt.Sprintf("hash%d", height),
						Time:   timestamppb.Now(),
					},
				}, nil)
		}

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListBlocks(context.Background(), connect.NewRequest(&v1.ListBlocksRequest{
			PageSize: 5,
		}))
		require.NoError(t, err)
		assert.Len(t, resp.Msg.RecentBlocks, 5)
	})
}

func TestService_ListRecentTransactions(t *testing.T) {
	t.Parallel()

	t.Run("list recent transactions from mempool and blocks", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		// Mock GetRawMempool with one tx
		mockBitcoind.EXPECT().
			GetRawMempool(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetRawMempoolResponse]{
				Msg: &corepb.GetRawMempoolResponse{
					Transactions: map[string]*corepb.MempoolEntry{
						"mempool_tx1": {
							VirtualSize: 200,
							Time:        timestamppb.Now(),
							Fees: &corepb.MempoolEntry_Fees{
								Base: 0.00001000,
							},
						},
					},
				},
			}, nil)

		// Mock GetBlockchainInfo - return BestBlockHash
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{
					Blocks:        1,
					BestBlockHash: "blockhash1",
				},
			}, nil)

		// Mock GetBlock - returns empty txids to avoid needing GetRawTransaction mocks
		mockBitcoind.EXPECT().
			GetBlock(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockResponse]{
				Msg: &corepb.GetBlockResponse{
					Height:            1,
					Hash:              "blockhash1",
					Time:              timestamppb.Now(),
					Txids:             []string{}, // Empty - no transactions to fetch
					PreviousBlockHash: "",         // Genesis, stop loop
				},
			}, nil).Times(2) // First for GetBlock with BestBlockHash, second for the loop

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListRecentTransactions(context.Background(), connect.NewRequest(&v1.ListRecentTransactionsRequest{
			Count: 10,
		}))
		require.NoError(t, err)
		// Should have 1 mempool tx
		assert.Len(t, resp.Msg.Transactions, 1)
		assert.Equal(t, "mempool_tx1", resp.Msg.Transactions[0].Txid)
	})

	t.Run("empty mempool and genesis block", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		// Empty mempool
		mockBitcoind.EXPECT().
			GetRawMempool(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetRawMempoolResponse]{
				Msg: &corepb.GetRawMempoolResponse{
					Transactions: map[string]*corepb.MempoolEntry{},
				},
			}, nil)

		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{
					Blocks:        0,
					BestBlockHash: "genesis",
				},
			}, nil)

		// Genesis block - empty txids
		mockBitcoind.EXPECT().
			GetBlock(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockResponse]{
				Msg: &corepb.GetBlockResponse{
					Height:            0,
					Hash:              "genesis",
					Time:              timestamppb.Now(),
					Txids:             []string{}, // Empty
					PreviousBlockHash: "",         // Genesis, no previous
				},
			}, nil).Times(2)

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListRecentTransactions(context.Background(), connect.NewRequest(&v1.ListRecentTransactionsRequest{
			Count: 10,
		}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.Transactions)
	})
}

func TestService_GetNetworkStats(t *testing.T) {
	t.Parallel()

	t.Run("returns network statistics", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListWalletsResponse]{
				Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.CreateWalletResponse]{
				Msg: &corepb.CreateWalletResponse{Name: "cheque_watch"},
			}, nil).AnyTimes()

		// Mock GetBlockchainInfo
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{
					Blocks: 1000,
					Chain:  "signet",
				},
			}, nil)

		// Mock GetBlockHash for calculating avg block time and difficulty
		mockBitcoind.EXPECT().
			GetBlockHash(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockHashResponse]{
				Msg: &corepb.GetBlockHashResponse{Hash: "latesthash"},
			}, nil).AnyTimes()

		// Mock GetBlock for difficulty and avg block time calculation
		mockBitcoind.EXPECT().
			GetBlock(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetBlockResponse]{
				Msg: &corepb.GetBlockResponse{
					Height:     1000,
					Hash:       "latesthash",
					Time:       timestamppb.Now(),
					Difficulty: 12345.67,
				},
			}, nil).AnyTimes()

		// Mock GetNetworkInfo
		mockBitcoind.EXPECT().
			GetNetworkInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetNetworkInfoResponse]{
				Msg: &corepb.GetNetworkInfoResponse{
					Version:    250000,
					Subversion: "/Satoshi:25.0.0/",
				},
			}, nil)

		// Mock GetNetTotals
		mockBitcoind.EXPECT().
			GetNetTotals(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetNetTotalsResponse]{
				Msg: &corepb.GetNetTotalsResponse{
					TotalBytesRecv: 1000000,
					TotalBytesSent: 500000,
				},
			}, nil)

		// Mock GetPeerInfo
		mockBitcoind.EXPECT().
			GetPeerInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.GetPeerInfoResponse]{
				Msg: &corepb.GetPeerInfoResponse{
					Peers: []*corepb.Peer{
						{Inbound: true},
						{Inbound: false},
						{Inbound: false},
					},
				},
			}, nil)

		cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.GetNetworkStats(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)

		assert.Equal(t, int64(1000), resp.Msg.BlockHeight)
		assert.Equal(t, int32(3), resp.Msg.PeerCount)
		assert.Equal(t, int32(1), resp.Msg.ConnectionsIn)
		assert.Equal(t, int32(2), resp.Msg.ConnectionsOut)
		assert.Equal(t, uint64(1000000), resp.Msg.TotalBytesReceived)
		assert.Equal(t, uint64(500000), resp.Msg.TotalBytesSent)
		assert.Equal(t, int32(250000), resp.Msg.NetworkVersion)
		assert.Equal(t, "/Satoshi:25.0.0/", resp.Msg.Subversion)
		assert.Equal(t, 12345.67, resp.Msg.Difficulty)
	})
}
