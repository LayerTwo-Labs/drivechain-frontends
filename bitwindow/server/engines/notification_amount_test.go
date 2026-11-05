package engines

import (
	"context"
	"fmt"
	"testing"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

func TestNotificationKeepsEachOutputAmount(t *testing.T) {
	for _, count := range []int{99, 100, 101} {
		t.Run(fmt.Sprintf("%d outputs", count), func(t *testing.T) {
			rows := make([]*corepb.GetTransactionResponse, count)
			for i := range rows {
				rows[i] = &corepb.GetTransactionResponse{Txid: fmt.Sprintf("%064x", 1), Amount: 0.00001}
			}
			core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
			core.EXPECT().ListWallets(gomock.Any(), gomock.Any()).Return(
				connect.NewResponse(&corepb.ListWalletsResponse{Wallets: []string{"wallet-a"}}), nil,
			)
			core.EXPECT().ListTransactions(gomock.Any(), gomock.Any()).DoAndReturn(
				func(_ context.Context, req *connect.Request[corepb.ListTransactionsRequest]) (*connect.Response[corepb.ListTransactionsResponse], error) {
					end := max(0, len(rows)-int(req.Msg.Skip))
					start := max(0, end-int(req.Msg.Count))
					return connect.NewResponse(&corepb.ListTransactionsResponse{Transactions: rows[start:end]}), nil
				},
			).AnyTimes()
			engine := NewNotificationEngine(database.Test(t), service.New("bitcoind", func(context.Context) (corerpc.BitcoinServiceClient, error) {
				return core, nil
			}), nil)
			events := engine.Subscribe(t.Context())
			require.NoError(t, engine.checkWalletTransactions(t.Context()))
			event := nextEvent(t, events).GetTransaction()
			t.Logf("outputs=%d amount=%d", count, event.GetAmountSats())
			require.Equal(t, uint64(count*1000), event.GetAmountSats())
		})
	}
}
