package api_wallet_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

func immatureByTxid(txs []*walletv1.WalletTransaction) map[string]bool {
	out := make(map[string]bool, len(txs))
	for _, tx := range txs {
		out[tx.Txid] = tx.Immature
	}
	return out
}

func TestImmatureCoinbase(t *testing.T) {
	t.Parallel()

	t.Run("electrum balance reports immature coins apart", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		mockOrch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
		mockOrch.EXPECT().
			GetBalance(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&orchpb.GetBalanceResponse{
				ConfirmedSats:   100_000,
				UnconfirmedSats: 50_000,
				ImmatureSats:    625_000_000,
			}), nil)
		apitests.ExpectOrchestratorReads(mockOrch)
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

		resp, err := cli.GetBalance(context.Background(), connect.NewRequest(&walletv1.GetBalanceRequest{WalletId: testWalletID}))
		require.NoError(t, err)
		require.Equal(t, uint64(100_000), resp.Msg.ConfirmedSatoshi)
		require.Equal(t, uint64(50_000), resp.Msg.PendingSatoshi)
		require.Equal(t, uint64(625_000_000), resp.Msg.ImmatureSatoshi)
	})

	t.Run("electrum transactions mark an immature coinbase", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		mockOrch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
		mockOrch.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&orchpb.ListTransactionsResponse{
				Transactions: []*orchpb.TransactionEntry{
					{Txid: "maturing", Category: "immature", AmountSats: 312_500_000, Confirmations: 10},
					{Txid: "mature", Category: "generate", AmountSats: 312_500_000, Confirmations: 150},
					{Txid: "payment", Category: "receive", AmountSats: 15_000_000, Confirmations: 3},
				},
			}), nil)
		apitests.ExpectOrchestratorReads(mockOrch)
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

		resp, err := cli.ListTransactions(context.Background(), connect.NewRequest(&walletv1.ListTransactionsRequest{WalletId: testWalletID}))
		require.NoError(t, err)
		require.Equal(t, map[string]bool{"maturing": true, "mature": false, "payment": false}, immatureByTxid(resp.Msg.Transactions))
	})

	t.Run("core balance reports immature coins apart", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
		mockBitcoind.EXPECT().
			GetBalances(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.GetBalancesResponse{
				Mine: &corepb.GetBalancesResponse_Mine{Trusted: 1.5, UntrustedPending: 0.25, Immature: 6.25},
			}), nil)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.GetBalance(context.Background(), connect.NewRequest(&walletv1.GetBalanceRequest{WalletId: testWalletID}))
		require.NoError(t, err)
		require.Equal(t, uint64(150_000_000), resp.Msg.ConfirmedSatoshi)
		require.Equal(t, uint64(25_000_000), resp.Msg.PendingSatoshi)
		require.Equal(t, uint64(625_000_000), resp.Msg.ImmatureSatoshi)
	})

	t.Run("core transactions mark an immature coinbase", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		detail := func(category corepb.GetTransactionResponse_Category) []*corepb.GetTransactionResponse_Details {
			return []*corepb.GetTransactionResponse_Details{{Address: "bcrt1qminer", Category: category, Amount: 3.125}}
		}
		mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.ListTransactionsResponse{
				Transactions: []*corepb.GetTransactionResponse{
					{Txid: "maturing", Amount: 3.125, Confirmations: 10, Details: detail(corepb.GetTransactionResponse_CATEGORY_IMMATURE)},
					{Txid: "mature", Amount: 3.125, Confirmations: 150, Details: detail(corepb.GetTransactionResponse_CATEGORY_GENERATE)},
					{Txid: "payment", Amount: 0.15, Confirmations: 3, Details: detail(corepb.GetTransactionResponse_CATEGORY_RECEIVE)},
				},
			}), nil).
			AnyTimes()
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListTransactions(context.Background(), connect.NewRequest(&walletv1.ListTransactionsRequest{WalletId: testWalletID}))
		require.NoError(t, err)
		require.Equal(t, map[string]bool{"maturing": true, "mature": false, "payment": false}, immatureByTxid(resp.Msg.Transactions))
	})
}
