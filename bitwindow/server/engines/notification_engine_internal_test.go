package engines

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/notifications"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// A wallet's transaction history must not be announced: on a fresh database
// every past transaction is unseen, and there can be a hundred of them.
func TestProcessWalletTransactions_HistoryIsNotAnnounced(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)

	engine := NewNotificationEngine(db, nil)
	events := engine.Subscribe(ctx)

	const txid = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	engine.processWalletTransactions(ctx, "wallet-a", 200, []*corepb.GetTransactionResponse{{
		Txid:          txid,
		Amount:        1,
		Confirmations: 6,
		Time:          timestamppb.New(time.Now().Add(-notificationBacklog - time.Hour)),
	}})

	select {
	case event := <-events:
		t.Fatalf("announced a historical transaction: %v", event)
	default:
	}

	// Both the receive and the confirmation are recorded, so a later poll stays quiet.
	for _, tc := range []struct{ eventType, eventID string }{
		{notifications.EventTypeTransaction, "wallet-a:" + txid},
		{notifications.EventTypeTransactionConf, "wallet-a:" + txid + ":confirmed"},
	} {
		notified, err := notifications.HasBeenNotified(ctx, db, tc.eventType, tc.eventID)
		require.NoError(t, err)
		require.True(t, notified, tc.eventID)
	}
}

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

	engine.processWalletTransactions(ctx, "wallet-a", 200, txs)
	engine.processWalletTransactions(ctx, "wallet-b", 200, txs)

	// A second pass must not notify again for either wallet.
	engine.processWalletTransactions(ctx, "wallet-a", 200, txs)
	engine.processWalletTransactions(ctx, "wallet-b", 200, txs)

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
	engine.processWalletTransactions(ctx, "wallet-a", 200, []*corepb.GetTransactionResponse{
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

// A self-send inside one wallet produces both a send and a receive row for the
// same txid. Summing across directions nets them to zero and notifies nothing.
func TestProcessWalletTransactions_SelfSendIsNotNettedToZero(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)

	engine := NewNotificationEngine(db, nil)
	events := engine.Subscribe(ctx)

	const txid = "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
	engine.processWalletTransactions(ctx, "wallet-a", 200, []*corepb.GetTransactionResponse{
		{Txid: txid, Amount: -1.0, Confirmations: 0},
		{Txid: txid, Amount: 1.0, Confirmations: 0},
	})

	select {
	case event := <-events:
		require.Equal(t, notificationv1.TransactionEvent_TYPE_SENT, event.GetTransaction().GetType())
		require.Equal(t, txid, event.GetTransaction().GetTxid())
		require.Equal(t, uint64(100_000_000), event.GetTransaction().GetAmountSats())
	default:
		t.Fatal("expected a sent notification, got none")
	}
}

// A confirmation is recorded for good, so a fork that orphans the confirming
// block has to clear it. Otherwise the re-confirmation on the new chain is
// swallowed as a duplicate and the wallet never hears the transaction landed.
func TestProcessWalletTransactions_ForkReArmsConfirmation(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)

	engine := NewNotificationEngine(db, nil)
	events := engine.Subscribe(ctx)

	const txid = "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
	// Seen in the mempool, then confirmed by the block at height 120.
	engine.processWalletTransactions(ctx, "wallet-a", 119, []*corepb.GetTransactionResponse{
		{Txid: txid, Amount: 1, Confirmations: 0},
	})
	engine.processWalletTransactions(ctx, "wallet-a", 120, []*corepb.GetTransactionResponse{
		{Txid: txid, Amount: 1, Confirmations: 1},
	})

	parser := &Parser{db: db}
	require.NoError(t, parser.purgeChainDerivedAtOrAbove(ctx, 110))

	// The new chain confirms it again, at height 121.
	engine.processWalletTransactions(ctx, "wallet-a", 121, []*corepb.GetTransactionResponse{
		{Txid: txid, Amount: 1, Confirmations: 1},
	})

	seen := make(map[notificationv1.TransactionEvent_Type]int)
	for done := false; !done; {
		select {
		case event := <-events:
			seen[event.GetTransaction().GetType()]++
		default:
			done = true
		}
	}

	require.Equal(t, 1, seen[notificationv1.TransactionEvent_TYPE_RECEIVED],
		"the receive isn't tied to a block, so the fork leaves it alone")
	require.Equal(t, 2, seen[notificationv1.TransactionEvent_TYPE_CONFIRMED],
		"the re-confirmation after the fork is announced again")
}
