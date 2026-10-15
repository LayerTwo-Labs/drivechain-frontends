package api_wallet_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// A send that names its inputs spends exactly those coins, so no lock reaches
// them. A frozen one has to stop the send.
func TestSendRefusesAFrozenRequiredInput(t *testing.T) {
	ctrl := gomock.NewController(t)
	db := database.Test(t)
	mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
	apitests.ExpectOrchestratorReads(mockOrch)
	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

	ctx := context.Background()
	frozen := true
	_, err := cli.SetUTXOMetadata(ctx, connect.NewRequest(&walletv1.SetUTXOMetadataRequest{
		Outpoint: "frozen:0",
		IsFrozen: &frozen,
	}))
	require.NoError(t, err)

	_, err = cli.SendTransaction(ctx, connect.NewRequest(&walletv1.SendTransactionRequest{
		WalletId:       "test-wallet-id-1234",
		Destinations:   map[string]uint64{"bcrt1qdest": 50_000},
		RequiredInputs: []*walletv1.UnspentOutput{{Output: "frozen:0"}},
	}))
	require.ErrorContains(t, err, "is frozen")
}

// A freeze the daemon never learns is no freeze at all, so the write reports
// the failure instead of success.
func TestSetUTXOMetadataReportsAFailedPush(t *testing.T) {
	ctrl := gomock.NewController(t)
	db := database.Test(t)
	mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
	apitests.ExpectOrchestratorReadsWithoutFrozenCoins(mockOrch)
	mockOrch.EXPECT().
		SetFrozenCoins(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return((*connect.Response[emptypb.Empty])(nil), connect.NewError(connect.CodeUnavailable, assert.AnError))
	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

	frozen := true
	_, err := cli.SetUTXOMetadata(context.Background(), connect.NewRequest(&walletv1.SetUTXOMetadataRequest{
		Outpoint: "aa:0",
		IsFrozen: &frozen,
	}))
	require.ErrorContains(t, err, "set frozen coins")
}

// A caller can spell a vout with a leading zero, and a txid in either case.
func TestSendRefusesAFrozenInputInAnySpelling(t *testing.T) {
	ctrl := gomock.NewController(t)
	db := database.Test(t)
	mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
	apitests.ExpectOrchestratorReads(mockOrch)
	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

	ctx := context.Background()
	frozen := true
	_, err := cli.SetUTXOMetadata(ctx, connect.NewRequest(&walletv1.SetUTXOMetadataRequest{
		Outpoint: "abcdef:1",
		IsFrozen: &frozen,
	}))
	require.NoError(t, err)

	for _, spelling := range []string{"ABCDEF:1", "abcdef:01", "ABCDEF:01"} {
		t.Run(spelling, func(t *testing.T) {
			_, err := cli.SendTransaction(t.Context(), connect.NewRequest(&walletv1.SendTransactionRequest{
				WalletId:       "test-wallet-id-1234",
				Destinations:   map[string]uint64{"bcrt1qdest": 50_000},
				RequiredInputs: []*walletv1.UnspentOutput{{Output: spelling}},
			}))
			require.ErrorContains(t, err, "is frozen")
		})
	}
}

func TestSendTransactionWithRequiredInputs(t *testing.T) {
	const txid = "abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234"

	t.Run("sends the inputs through the orchestrator", func(t *testing.T) {
		db := database.Test(t)
		ctrl := gomock.NewController(t)
		mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
		apitests.ExpectOrchestratorReads(mockOrch)
		mockOrch.EXPECT().CreateBitcoinCoreWallet(gomock.Any(), gomock.Any()).Times(0)
		var sent []*orchpb.SendTransactionRequest
		mockOrch.EXPECT().
			SendTransaction(gomock.Any(), gomock.Any()).
			DoAndReturn(func(
				_ any, req *connect.Request[orchpb.SendTransactionRequest],
			) (*connect.Response[orchpb.SendTransactionResponse], error) {
				sent = append(sent, req.Msg)
				return connect.NewResponse(&orchpb.SendTransactionResponse{Txid: "sent"}), nil
			}).
			Times(1)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		mockBitcoind.EXPECT().GetRawMempool(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.GetRawMempoolResponse{}), nil).AnyTimes()
		mockBitcoind.EXPECT().ListUnspent(gomock.Any(), gomock.Any()).Times(0)
		mockBitcoind.EXPECT().CreateRawTransaction(gomock.Any(), gomock.Any()).Times(0)
		mockBitcoind.EXPECT().SignRawTransactionWithWallet(gomock.Any(), gomock.Any()).Times(0)
		mockBitcoind.EXPECT().SendRawTransaction(gomock.Any(), gomock.Any()).Times(0)
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db,
			apitests.WithOrchestrator(mockOrch), apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.SendTransaction(t.Context(), connect.NewRequest(&walletv1.SendTransactionRequest{
			WalletId:       testWalletID,
			Destinations:   map[string]uint64{"bcrt1qdest": 50_000},
			FixedFeeSats:   500,
			RequiredInputs: []*walletv1.UnspentOutput{{Output: txid + ":1", ValueSats: 80_000}},
		}))
		require.NoError(t, err)
		require.Equal(t, "sent", resp.Msg.Txid)

		require.Len(t, sent, 1)
		require.Equal(t, testWalletID, sent[0].WalletId)
		require.Equal(t, map[string]int64{"bcrt1qdest": 50_000}, sent[0].Destinations)
		require.EqualValues(t, 500, sent[0].FixedFeeSats)
		require.Len(t, sent[0].RequiredInputs, 1)
		require.Equal(t, txid, sent[0].RequiredInputs[0].Txid)
		require.EqualValues(t, 1, sent[0].RequiredInputs[0].Vout)
		require.EqualValues(t, 80_000, sent[0].RequiredInputs[0].AmountSats)
	})

	for name, outpoint := range map[string]string{
		"no vout":       txid,
		"text vout":     txid + ":x",
		"negative vout": txid + ":-1",
	} {
		t.Run("refuses an outpoint with "+name, func(t *testing.T) {
			db := database.Test(t)
			ctrl := gomock.NewController(t)
			mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
			apitests.ExpectOrchestratorReads(mockOrch)
			mockOrch.EXPECT().SendTransaction(gomock.Any(), gomock.Any()).Times(0)
			cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

			_, err := cli.SendTransaction(t.Context(), connect.NewRequest(&walletv1.SendTransactionRequest{
				WalletId:       testWalletID,
				Destinations:   map[string]uint64{"bcrt1qdest": 50_000},
				RequiredInputs: []*walletv1.UnspentOutput{{Output: outpoint}},
			}))
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		})
	}
}
