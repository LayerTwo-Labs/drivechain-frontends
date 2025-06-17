package engines_test

import (
	"context"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

func TestDeniabilityEngine(t *testing.T) {
	t.Parallel()

	ctx := context.Background()
	db := database.Test(t)
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockWallet := mocks.NewMockWalletServiceClient(ctrl)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

	walletService := service.New("wallet", func(ctx context.Context) (validatorrpc.WalletServiceClient, error) {
		return mockWallet, nil
	})
	bitcoindService := service.New("bitcoind", func(ctx context.Context) (bitcoindv1alphaconnect.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	})

	engine := engines.NewDeniability(walletService, bitcoindService, db)

	t.Run("handleAbortedDenials", func(t *testing.T) {
		t.Parallel()

		// Create a denial
		denial, err := deniability.Create(ctx, db, "test-txid", 0, 1*time.Hour, 3)
		require.NoError(t, err)

		// Mock wallet response with no matching UTXO
		mockWallet.EXPECT().
			ListUnspentOutputs(gomock.Any(), gomock.Any()).
			Return(&connect.Response[pb.ListUnspentOutputsResponse]{
				Msg: &pb.ListUnspentOutputsResponse{
					Outputs: []*pb.ListUnspentOutputsResponse_Output{
						{
							Txid: &commonv1.ReverseHex{
								Hex: &wrapperspb.StringValue{Value: "different-txid"},
							},
							Vout: 0,
						},
					},
				},
			}, nil)

		// Run cleanup
		utxos, denials, err := engine.CleanupDenials(ctx)
		require.NoError(t, err)
		assert.Empty(t, denials) // Denial should be cancelled
		assert.Len(t, utxos, 1)

		// Verify denial was cancelled
		denial, err = deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		assert.NotNil(t, denial.CancelledAt)
		assert.Equal(t, "cancelled due to UTXO being moved", *denial.CancelReason)
	})

	t.Run("executeDenial", func(t *testing.T) {
		t.Parallel()

		// Create a denial
		denial, err := deniability.Create(ctx, db, "test-txid", 0, 1*time.Hour, 3)
		require.NoError(t, err)

		// Mock wallet responses
		mockWallet.EXPECT().
			ListUnspentOutputs(gomock.Any(), gomock.Any()).
			Return(&connect.Response[pb.ListUnspentOutputsResponse]{
				Msg: &pb.ListUnspentOutputsResponse{
					Outputs: []*pb.ListUnspentOutputsResponse_Output{
						{
							Txid: &commonv1.ReverseHex{
								Hex: &wrapperspb.StringValue{Value: "test-txid"},
							},
							Vout:       0,
							ValueSats:  1000000, // 0.01 BTC
							IsInternal: false,
						},
					},
				},
			}, nil)

		mockWallet.EXPECT().
			CreateNewAddress(gomock.Any(), gomock.Any()).
			Return(&connect.Response[pb.CreateNewAddressResponse]{
				Msg: &pb.CreateNewAddressResponse{
					Address: "bc1qtest",
				},
			}, nil)

		mockWallet.EXPECT().
			SendTransaction(gomock.Any(), gomock.Any()).
			Return(&connect.Response[pb.SendTransactionResponse]{
				Msg: &pb.SendTransactionResponse{
					Txid: &commonv1.ReverseHex{
						Hex: &wrapperspb.StringValue{Value: "new-txid"},
					},
				},
			}, nil)

		// Execute denial
		err = engine.ExecuteDenial(ctx, []*pb.ListUnspentOutputsResponse_Output{
			{
				Txid: &commonv1.ReverseHex{
					Hex: &wrapperspb.StringValue{Value: "test-txid"},
				},
				Vout:       0,
				ValueSats:  1000000,
				IsInternal: false,
			},
		}, denial)
		require.NoError(t, err)

		// Verify execution was recorded
		denial, err = deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		assert.NotNil(t, denial)
	})

	t.Run("processUTXO with insufficient amount", func(t *testing.T) {
		t.Parallel()

		// Create a denial
		denial, err := deniability.Create(ctx, db, "test-txid", 0, 1*time.Hour, 3)
		require.NoError(t, err)

		// Process UTXO with insufficient amount
		err = engine.ProcessUTXO(ctx, &pb.ListUnspentOutputsResponse_Output{
			Txid: &commonv1.ReverseHex{
				Hex: &wrapperspb.StringValue{Value: "test-txid"},
			},
			Vout:       0,
			ValueSats:  5000, // Less than fee
			IsInternal: false,
		}, denial)
		require.NoError(t, err)

		// Verify denial was cancelled
		denial, err = deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		assert.NotNil(t, denial.CancelledAt)
		assert.Equal(t, "utxo is too small to split", *denial.CancelReason)
	})
}
