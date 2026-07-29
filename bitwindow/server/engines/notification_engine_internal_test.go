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

// Bitcoin Core hands back one row per wallet-relevant output, so a transaction
// paying us twice arrives as two rows sharing a txid. The notification has to
// carry the summed amount, not just whichever output came first.
func TestProcessWalletTransactions_SumsOutputsWithSameTxid(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)

	engine := NewNotificationEngine(db, nil)
	events := engine.Subscribe(ctx)

	const txid = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	engine.processWalletTransactions(ctx, "wallet-a", []*corepb.GetTransactionResponse{
		{Txid: txid, Amount: 1.5, Confirmations: 0},
		{Txid: txid, Amount: 0.25, Confirmations: 0},
	})

	select {
	case event := <-events:
		require.Equal(t, notificationv1.TransactionEvent_TYPE_RECEIVED, event.GetTransaction().GetType())
		require.Equal(t, txid, event.GetTransaction().GetTxid())
		require.Equal(t, uint64(175_000_000), event.GetTransaction().GetAmountSats())
	default:
		t.Fatal("expected a received notification")
	}

	select {
	case event := <-events:
		t.Fatalf("expected a single notification, got another: %v", event)
	default:
	}
}
