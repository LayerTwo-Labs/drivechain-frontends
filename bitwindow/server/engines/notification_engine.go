package engines

import (
	"context"
	"database/sql"
	"fmt"
	"sync"
	"time"

	"connectrpc.com/connect"
	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/notifications"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type NotificationEngine struct {
	db       *sql.DB
	bitcoind *service.Service[corerpc.BitcoinServiceClient]

	mu          sync.RWMutex
	subscribers []chan *notificationv1.WatchResponse
}

func NewNotificationEngine(
	db *sql.DB,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
) *NotificationEngine {
	return &NotificationEngine{
		db:          db,
		bitcoind:    bitcoind,
		subscribers: make([]chan *notificationv1.WatchResponse, 0),
	}
}

func (e *NotificationEngine) Run(ctx context.Context) error {
	log := zerolog.Ctx(ctx)
	log.Info().Msg("notification engine started")

	// Watch for timestamp confirmations
	go e.watchTimestamps(ctx)

	// Watch for wallet transaction confirmations
	go e.watchWalletTransactions(ctx)

	<-ctx.Done()
	log.Info().Msg("notification engine stopped")
	return ctx.Err()
}

func (e *NotificationEngine) watchTimestamps(ctx context.Context) {
	log := zerolog.Ctx(ctx)
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := e.checkTimestampConfirmations(ctx); err != nil {
				log.Warn().Err(err).Msg("check timestamp confirmations")
			}
		}
	}
}

func (e *NotificationEngine) checkTimestampConfirmations(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	// Get all confirming timestamps
	confirmingTimestamps, err := timestamps.List(ctx, e.db, timestamps.WithStatus(timestamps.StatusConfirming))
	if err != nil {
		return err
	}

	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		return err
	}

	for _, ts := range confirmingTimestamps {
		if ts.TxID == nil {
			continue
		}

		// Check if already notified
		eventID := fmt.Sprintf("%d", ts.ID)
		notified, err := notifications.HasBeenNotified(ctx, e.db, notifications.EventTypeTimestamp, eventID)
		if err != nil {
			log.Warn().Err(err).Int64("id", ts.ID).Msg("check timestamp notification status")
			continue
		}
		if notified {
			continue
		}

		// Check confirmations
		resp, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
			Txid:      *ts.TxID,
			Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
		}))
		if err != nil {
			log.Warn().
				Err(err).
				Str("txid", *ts.TxID).
				Msg("get raw transaction for notification")
			continue
		}

		// If confirmed (1+ confirmations), send notification
		if resp.Msg.Confirmations >= 1 {
			var blockHeight *int64
			if resp.Msg.Blockhash != "" {
				blockResp, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
					Hash:      resp.Msg.Blockhash,
					Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
				}))
				if err == nil {
					height := int64(blockResp.Msg.Height)
					blockHeight = &height
				}
			}

			event := &notificationv1.WatchResponse{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.WatchResponse_TimestampEvent{
					TimestampEvent: &notificationv1.TimestampEvent{
						Type:        notificationv1.TimestampEvent_TYPE_CONFIRMED,
						Id:          ts.ID,
						Filename:    ts.Filename,
						Txid:        *ts.TxID,
						BlockHeight: blockHeight,
					},
				},
			}

			e.broadcast(ctx, event)

			// Mark as notified
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTimestamp, eventID); err != nil {
				log.Warn().Err(err).Int64("id", ts.ID).Msg("mark timestamp notified")
			}

			log.Info().
				Int64("id", ts.ID).
				Str("filename", ts.Filename).
				Msg("timestamp confirmed notification sent")
		}
	}

	return nil
}

func (e *NotificationEngine) watchWalletTransactions(ctx context.Context) {
	log := zerolog.Ctx(ctx)
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := e.checkWalletTransactions(ctx); err != nil {
				log.Warn().Err(err).Msg("check wallet transactions")
			}
		}
	}
}

func (e *NotificationEngine) checkWalletTransactions(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		return err
	}

	// Get list of loaded wallets
	walletsResp, err := bitcoind.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return err
	}

	// Check transactions for each wallet
	for _, walletName := range walletsResp.Msg.Wallets {
		resp, err := bitcoind.ListTransactions(ctx, connect.NewRequest(&corepb.ListTransactionsRequest{
			Count:  100,
			Wallet: walletName,
		}))
		if err != nil {
			log.Warn().
				Err(err).
				Str("wallet", walletName).
				Msg("list transactions for wallet")
			continue
		}

		e.processWalletTransactions(ctx, resp.Msg.Transactions)
	}

	return nil
}

func (e *NotificationEngine) processWalletTransactions(ctx context.Context, transactions []*corepb.GetTransactionResponse) {
	log := zerolog.Ctx(ctx)
	for _, tx := range transactions {
		txid := tx.Txid
		confirmations := uint32(tx.Confirmations)

		// Check if we've already notified about this transaction
		notified, err := notifications.HasBeenNotified(ctx, e.db, notifications.EventTypeTransaction, txid)
		if err != nil {
			log.Warn().Err(err).Str("txid", txid).Msg("check transaction notification status")
			continue
		}

		// For confirmation notifications, use a separate event type
		confEventID := txid + ":confirmed"
		confNotified, err := notifications.HasBeenNotified(ctx, e.db, notifications.EventTypeTransactionConf, confEventID)
		if err != nil {
			log.Warn().Err(err).Str("txid", txid).Msg("check transaction confirmation notification status")
			continue
		}

		if notified && confNotified {
			continue
		}

		switch {
		case !notified && tx.Amount > 0:
			// Received transaction
			event := &notificationv1.WatchResponse{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.WatchResponse_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_RECEIVED,
						Txid:          txid,
						AmountSats:    uint64(tx.Amount * 100000000),
						Confirmations: confirmations,
					},
				},
			}
			e.broadcast(ctx, event)
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, txid); err != nil {
				log.Warn().Err(err).Str("txid", txid).Msg("mark transaction notified")
			}
			log.Info().
				Str("txid", txid).
				Float64("amount", tx.Amount).
				Msg("received transaction notification sent")

		case !notified && tx.Amount < 0:
			// Sent transaction
			event := &notificationv1.WatchResponse{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.WatchResponse_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_SENT,
						Txid:          txid,
						AmountSats:    uint64(-tx.Amount * 100000000),
						Confirmations: confirmations,
					},
				},
			}
			e.broadcast(ctx, event)
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, txid); err != nil {
				log.Warn().Err(err).Str("txid", txid).Msg("mark transaction notified")
			}
			log.Info().
				Str("txid", txid).
				Float64("amount", -tx.Amount).
				Msg("sent transaction notification sent")

		case !notified:
			// New transaction with zero amount - just mark as seen
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, txid); err != nil {
				log.Warn().Err(err).Str("txid", txid).Msg("mark transaction notified")
			}

		case !confNotified && confirmations >= 1:
			// Transaction just got first confirmation (and we haven't notified about it)
			event := &notificationv1.WatchResponse{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.WatchResponse_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_CONFIRMED,
						Txid:          txid,
						AmountSats:    uint64(tx.Amount * 100000000),
						Confirmations: confirmations,
					},
				},
			}
			e.broadcast(ctx, event)
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransactionConf, confEventID); err != nil {
				log.Warn().Err(err).Str("txid", txid).Msg("mark transaction confirmation notified")
			}
			log.Info().
				Str("txid", txid).
				Uint32("confirmations", confirmations).
				Msg("transaction confirmed notification sent")
		}
	}
}

func (e *NotificationEngine) Subscribe(ctx context.Context) <-chan *notificationv1.WatchResponse {
	log := zerolog.Ctx(ctx)
	e.mu.Lock()
	defer e.mu.Unlock()

	ch := make(chan *notificationv1.WatchResponse, 10)
	e.subscribers = append(e.subscribers, ch)

	log.Debug().
		Int("subscriber_count", len(e.subscribers)).
		Msg("new subscriber added")

	// Handle cleanup when context is done
	go func() {
		<-ctx.Done()
		e.mu.Lock()
		defer e.mu.Unlock()

		// Remove subscriber
		e.subscribers = lo.Filter(e.subscribers, func(sub chan *notificationv1.WatchResponse, _ int) bool {
			return sub != ch
		})
		close(ch)

		log.Debug().
			Int("subscriber_count", len(e.subscribers)).
			Msg("subscriber removed")
	}()

	return ch
}

func (e *NotificationEngine) broadcast(ctx context.Context, event *notificationv1.WatchResponse) {
	log := zerolog.Ctx(ctx)
	e.mu.RLock()
	defer e.mu.RUnlock()

	for _, sub := range e.subscribers {
		select {
		case sub <- event:
		default:
			log.Warn().Msg("subscriber channel full, dropping event")
		}
	}
}
