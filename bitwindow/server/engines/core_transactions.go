package engines

import (
	"context"
	"fmt"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
)

// ReadCoreTransactions returns complete transactions for recentRows rows, or all rows when recentRows is zero.
func ReadCoreTransactions(ctx context.Context, client corerpc.BitcoinServiceClient, walletName string, recentRows uint32) ([]*corepb.GetTransactionResponse, error) {
	count := recentRows
	if count == 0 {
		count = 1000
	}
	for {
		response, err := client.ListTransactions(ctx, connect.NewRequest(&corepb.ListTransactionsRequest{
			Wallet: walletName,
			Count:  count,
		}))
		if err != nil {
			return nil, fmt.Errorf("list Core transactions: %w", err)
		}
		rows := response.Msg.Transactions
		complete := len(rows) < int(count)
		if recentRows == 0 {
			if complete {
				return rows, nil
			}
		} else {
			start := max(0, len(rows)-int(recentRows))
			for start > 0 && rows[start-1].Txid == rows[start].Txid {
				start--
			}
			if start > 0 || complete {
				return rows[start:], nil
			}
		}
		count *= 2
	}
}
