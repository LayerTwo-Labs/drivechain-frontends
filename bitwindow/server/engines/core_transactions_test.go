package engines

import (
	"context"
	"errors"
	"fmt"
	"testing"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

func TestCoreHistoryKeepsTheBoundaryTransaction(t *testing.T) {
	rows := []*corepb.GetTransactionResponse{{Txid: "old"}, {Txid: "boundary"}, {Txid: "boundary"}, {Txid: "boundary"}}
	for i := range 99 {
		rows = append(rows, &corepb.GetTransactionResponse{Txid: fmt.Sprintf("recent-%d", i)})
	}
	client := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	client.EXPECT().ListTransactions(gomock.Any(), gomock.Any()).DoAndReturn(
		func(_ context.Context, req *connect.Request[corepb.ListTransactionsRequest]) (*connect.Response[corepb.ListTransactionsResponse], error) {
			require.Zero(t, req.Msg.Skip)
			require.Equal(t, "wallet", req.Msg.Wallet)
			start := max(0, len(rows)-int(req.Msg.Count))
			return connect.NewResponse(&corepb.ListTransactionsResponse{Transactions: rows[start:]}), nil
		},
	).Times(2)
	result, err := ReadCoreTransactions(t.Context(), client, "wallet", 100)
	require.NoError(t, err)
	require.Equal(t, rows[1:], result)
}

func TestCoreHistoryReturnsTheReadError(t *testing.T) {
	readErr := errors.New("history read failed")
	client := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	gomock.InOrder(
		client.EXPECT().ListTransactions(gomock.Any(), gomock.Any()).Return(connect.NewResponse(&corepb.ListTransactionsResponse{
			Transactions: []*corepb.GetTransactionResponse{{Txid: "receipt"}},
		}), nil),
		client.EXPECT().ListTransactions(gomock.Any(), gomock.Any()).Return(nil, readErr),
	)
	result, err := ReadCoreTransactions(t.Context(), client, "wallet", 1)
	require.ErrorIs(t, err, readErr)
	require.Nil(t, result)
}
