package wallet_test

import (
	"context"
	"fmt"
	"testing"

	connectv1 "connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	walletpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

func TestHistoryKeepsAmountsAfterANewReceipt(t *testing.T) {
	history := make([]*corepb.GetTransactionResponse, 1000)
	for i := range history {
		history[i] = &corepb.GetTransactionResponse{Txid: fmt.Sprintf("%064x", i+1), Amount: 0.001}
	}
	calls := 0
	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	core.EXPECT().ListTransactions(gomock.Any(), gomock.Any()).DoAndReturn(
		func(_ context.Context, req *connectv1.Request[corepb.ListTransactionsRequest]) (*connectv1.Response[corepb.ListTransactionsResponse], error) {
			calls++
			if calls == 2 {
				history = append(history, &corepb.GetTransactionResponse{Txid: fmt.Sprintf("%064x", 1001), Amount: 0.001})
			}
			end := max(0, len(history)-int(req.Msg.Skip))
			start := max(0, end-int(req.Msg.Count))
			return connectv1.NewResponse(&corepb.ListTransactionsResponse{Transactions: history[start:end]}), nil
		}).Times(2)
	apitests.ExpectCoreWalletSetup(core)
	client := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithCoreWallet(), apitests.WithBitcoind(core)))
	response, err := client.ListTransactions(t.Context(), &walletpb.ListTransactionsRequest{WalletId: testWalletID})
	require.NoError(t, err)
	require.Len(t, response.Transactions, 1001)
	for _, tx := range response.Transactions {
		assert.Equal(t, uint64(100000), tx.ReceivedSatoshi, "receipt %s", tx.Txid)
	}
}
