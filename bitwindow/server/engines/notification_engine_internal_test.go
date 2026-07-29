package engines

import (
	"context"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
)

// The same txid shows up in every wallet that takes part in it, so dedup has to
// be per-wallet. Otherwise the first wallet we process swallows the
// notification for all the others.
func TestProcessWalletTransactions_DedupIsPerWallet(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)

	engine := NewNotificationEngine(db, nil)
	events := engine.Subscribe(ctx)

	const txid = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	txs := []*corepb.GetTransactionResponse{{
		Txid:          txid,
		Amount:        1,
		Confirmations: 0,
	}}

	engine.processWalletTransactions(ctx, "wallet-a", txs)
	engine.processWalletTransactions(ctx, "wallet-b", txs)

	// A second pass must not notify again for either wallet.
	engine.processWalletTransactions(ctx, "wallet-a", txs)
	engine.processWalletTransactions(ctx, "wallet-b", txs)

	var received int
	for done := false; !done; {
		select {
		case event := <-events:
			require.Equal(t, notificationv1.TransactionEvent_TYPE_RECEIVED, event.GetTransaction().GetType())
			require.Equal(t, txid, event.GetTransaction().GetTxid())
			received++
		default:
			done = true
		}
	}

	require.Equal(t, 2, received)
}
