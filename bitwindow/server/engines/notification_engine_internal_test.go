package engines

import (
	"context"
	"errors"
	"fmt"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/notifications"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

// A wallet's transaction history must not be announced: on a fresh database
// every past transaction is unseen, and there can be a hundred of them.
func TestProcessWalletTransactions_HistoryIsNotAnnounced(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	engine := NewNotificationEngine(db, nil, nil)
	events := engine.Subscribe(ctx)

	const txid = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", []*corepb.GetTransactionResponse{{
		Txid:          txid,
		Amount:        1,
		Confirmations: 6,
		Time:          timestamppb.New(time.Now().Add(-notificationBacklog - time.Hour)),
	}}))

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
	ctx := t.Context()
	db := database.Test(t)

	engine := NewNotificationEngine(db, nil, nil)
	events := engine.Subscribe(ctx)

	const txid = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	txs := []*corepb.GetTransactionResponse{{
		Txid:          txid,
		Amount:        1,
		Confirmations: 0,
	}}

	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", txs))
	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-b", txs))

	// A second pass must not notify again for either wallet.
	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", txs))
	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-b", txs))

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
	ctx := t.Context()
	db := database.Test(t)

	engine := NewNotificationEngine(db, nil, nil)
	events := engine.Subscribe(ctx)

	const txid = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", []*corepb.GetTransactionResponse{
		{Txid: txid, Amount: 1.5, Confirmations: 0},
		{Txid: txid, Amount: 0.25, Confirmations: 0},
	}))

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
	ctx := t.Context()
	db := database.Test(t)

	engine := NewNotificationEngine(db, nil, nil)
	events := engine.Subscribe(ctx)

	const txid = "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", []*corepb.GetTransactionResponse{
		{Txid: txid, Amount: -1.0, Confirmations: 0},
		{Txid: txid, Amount: 1.0, Confirmations: 0},
	}))

	select {
	case event := <-events:
		require.Equal(t, notificationv1.TransactionEvent_TYPE_SENT, event.GetTransaction().GetType())
		require.Equal(t, txid, event.GetTransaction().GetTxid())
		require.Equal(t, uint64(100_000_000), event.GetTransaction().GetAmountSats())
	default:
		t.Fatal("expected a sent notification, got none")
	}
}

func TestCheckTimestampConfirmations_SkipsDiscovered(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	txid := "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
	_, err := timestamps.Create(ctx, db, timestamps.FileTimestamp{
		FileHash:  "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
		TxID:      &txid,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	})
	require.NoError(t, err)

	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	engine := NewNotificationEngine(db, service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return core, nil
	}), nil)
	events := engine.Subscribe(ctx)

	require.NoError(t, engine.checkTimestampConfirmations(ctx))

	select {
	case event := <-events:
		t.Fatalf("announced a discovered timestamp: %v", event)
	default:
	}
}

func nextEvent(t *testing.T, events <-chan *notificationv1.WatchResponse) *notificationv1.WatchResponse {
	t.Helper()
	select {
	case event := <-events:
		return event
	default:
		t.Fatal("expected a notification")
		return nil
	}
}

func TestProcessWalletTransactions_AmountInSats(t *testing.T) {
	const txid = "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
	cases := []struct {
		name     string
		rows     []*corepb.GetTransactionResponse
		wantType notificationv1.TransactionEvent_Type
		wantSats uint64
	}{
		{
			name:     "received amount rounds to sats",
			rows:     []*corepb.GetTransactionResponse{{Txid: txid, Amount: 0.29}},
			wantType: notificationv1.TransactionEvent_TYPE_RECEIVED,
			wantSats: 29_000_000,
		},
		{
			name:     "outputs sum in sats",
			rows:     []*corepb.GetTransactionResponse{{Txid: txid, Amount: 0.1}, {Txid: txid, Amount: 0.2}},
			wantType: notificationv1.TransactionEvent_TYPE_RECEIVED,
			wantSats: 30_000_000,
		},
		{
			name:     "dust",
			rows:     []*corepb.GetTransactionResponse{{Txid: txid, Amount: 0.00000001}},
			wantType: notificationv1.TransactionEvent_TYPE_RECEIVED,
			wantSats: 1,
		},
		{
			name:     "sent amount is positive",
			rows:     []*corepb.GetTransactionResponse{{Txid: txid, Amount: -0.29}},
			wantType: notificationv1.TransactionEvent_TYPE_SENT,
			wantSats: 29_000_000,
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			ctx := t.Context()
			engine := NewNotificationEngine(database.Test(t), nil, nil)
			events := engine.Subscribe(ctx)

			require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", tc.rows))

			event := nextEvent(t, events)
			require.Equal(t, tc.wantType, event.GetTransaction().GetType())
			require.Equal(t, tc.wantSats, event.GetTransaction().GetAmountSats())
		})
	}
}

func TestProcessWalletTransactions_ConfirmedSendIsPositive(t *testing.T) {
	ctx := t.Context()
	engine := NewNotificationEngine(database.Test(t), nil, nil)
	events := engine.Subscribe(ctx)

	const txid = "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", []*corepb.GetTransactionResponse{{Txid: txid, Amount: -0.5}}))
	require.Equal(t, notificationv1.TransactionEvent_TYPE_SENT, nextEvent(t, events).GetTransaction().GetType())

	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", []*corepb.GetTransactionResponse{{Txid: txid, Amount: -0.5, Confirmations: 1}}))
	event := nextEvent(t, events)
	require.Equal(t, notificationv1.TransactionEvent_TYPE_CONFIRMED, event.GetTransaction().GetType())
	require.Equal(t, uint64(50_000_000), event.GetTransaction().GetAmountSats())
}

func TestProcessWalletTransactions_MarkFailureReturnsError(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	engine := NewNotificationEngine(db, nil, nil)
	engine.Subscribe(ctx)

	_, err := db.ExecContext(ctx, `CREATE TRIGGER fail_mark BEFORE INSERT ON notified_events
		BEGIN SELECT RAISE(ABORT, 'insert refused'); END`)
	require.NoError(t, err)

	const txid = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
	err = engine.processWalletTransactions(ctx, "wallet-a", []*corepb.GetTransactionResponse{{Txid: txid, Amount: 1}})
	require.ErrorContains(t, err, "insert refused")
}

// An event with no listener stays unmarked, so it reaches the app once it listens.
func TestProcessWalletTransactions_NoSubscriberKeepsTheEvent(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	engine := NewNotificationEngine(db, nil, nil)

	const txid = "abababababababababababababababababababababababababababababababab"
	rows := []*corepb.GetTransactionResponse{{Txid: txid, Amount: 1}}
	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", rows))

	notified, err := notifications.HasBeenNotified(ctx, db, notifications.EventTypeTransaction, "wallet-a:"+txid)
	require.NoError(t, err)
	require.False(t, notified)

	events := engine.Subscribe(ctx)
	require.NoError(t, engine.processWalletTransactions(ctx, "wallet-a", rows))
	require.Equal(t, notificationv1.TransactionEvent_TYPE_RECEIVED, nextEvent(t, events).GetTransaction().GetType())

	notified, err = notifications.HasBeenNotified(ctx, db, notifications.EventTypeTransaction, "wallet-a:"+txid)
	require.NoError(t, err)
	require.True(t, notified)
}

func TestCheckTimestampConfirmations_NoSubscriberKeepsTheEvent(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	txid := "3333333333333333333333333333333333333333333333333333333333333333"
	id, err := timestamps.Create(ctx, db, timestamps.FileTimestamp{
		Filename:  "a.txt",
		FileHash:  "4444444444444444444444444444444444444444444444444444444444444444",
		TxID:      &txid,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	})
	require.NoError(t, err)

	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	core.EXPECT().GetRawTransaction(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.GetRawTransactionResponse{Confirmations: 1}), nil).
		Times(2)
	engine := NewNotificationEngine(db, service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return core, nil
	}), nil)

	require.NoError(t, engine.checkTimestampConfirmations(ctx))
	notified, err := notifications.HasBeenNotified(ctx, db, notifications.EventTypeTimestamp, fmt.Sprintf("%d", id))
	require.NoError(t, err)
	require.False(t, notified)

	events := engine.Subscribe(ctx)
	require.NoError(t, engine.checkTimestampConfirmations(ctx))
	require.Equal(t, notificationv1.TimestampEvent_TYPE_CONFIRMED, nextEvent(t, events).GetTimestampEvent().GetType())
	notified, err = notifications.HasBeenNotified(ctx, db, notifications.EventTypeTimestamp, fmt.Sprintf("%d", id))
	require.NoError(t, err)
	require.True(t, notified)
}

func TestCheckTimestampConfirmations_BlockErrorSendsNothing(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	txid := "1111111111111111111111111111111111111111111111111111111111111111"
	id, err := timestamps.Create(ctx, db, timestamps.FileTimestamp{
		Filename:  "a.txt",
		FileHash:  "2222222222222222222222222222222222222222222222222222222222222222",
		TxID:      &txid,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	})
	require.NoError(t, err)

	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	core.EXPECT().GetRawTransaction(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.GetRawTransactionResponse{
			Confirmations: 1,
			Blockhash:     "0000000000000000000000000000000000000000000000000000000000000abc",
		}), nil)
	core.EXPECT().GetBlock(gomock.Any(), gomock.Any()).Return(nil, errors.New("block not found"))
	engine := NewNotificationEngine(db, service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return core, nil
	}), nil)
	events := engine.Subscribe(ctx)

	require.NoError(t, engine.checkTimestampConfirmations(ctx))

	select {
	case event := <-events:
		t.Fatalf("sent a notification with no block height: %v", event)
	default:
	}
	notified, err := notifications.HasBeenNotified(ctx, db, notifications.EventTypeTimestamp, fmt.Sprintf("%d", id))
	require.NoError(t, err)
	require.False(t, notified)
}

// A network swap stops the old engine. Its subscribers must see the channel
// close, or each Watch stream stays on the old engine.
func TestNotificationEngineRunClosesSubscribers(t *testing.T) {
	engine := NewNotificationEngine(database.Test(t), nil, nil)
	events := engine.Subscribe(t.Context())

	runCtx, stop := context.WithCancel(t.Context())
	stop()
	require.NoError(t, engine.Run(runCtx))

	select {
	case _, ok := <-events:
		require.False(t, ok)
	case <-time.After(time.Second):
		t.Fatal("the subscriber channel stayed open")
	}

	_, ok := <-engine.Subscribe(t.Context())
	require.False(t, ok)
}
