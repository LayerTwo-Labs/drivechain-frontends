package engines

import (
	"context"
	"database/sql"
	"sync"
	"time"

	"connectrpc.com/connect"
	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type NotificationEngine struct {
	db       *sql.DB
	log      zerolog.Logger
	bitcoind *service.Service[corerpc.BitcoinServiceClient]

	mu          sync.RWMutex
	subscribers []chan *notificationv1.NotificationEvent

	// Track last seen state to detect changes
	lastSeenTxs             map[string]uint32 // txid -> confirmations
	lastConfirmedTimestamps map[int64]bool
}

func NewNotificationEngine(
	db *sql.DB,
	log zerolog.Logger,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
) *NotificationEngine {
	return &NotificationEngine{
		db:                      db,
		log:                     log.With().Str("component", "notification_engine").Logger(),
		bitcoind:                bitcoind,
		subscribers:             make([]chan *notificationv1.NotificationEvent, 0),
		lastSeenTxs:             make(map[string]uint32),
		lastConfirmedTimestamps: make(map[int64]bool),
	}
}

func (e *NotificationEngine) Run(ctx context.Context) error {
	e.log.Info().Msg("notification engine started")

	// Watch for timestamp confirmations
	go e.watchTimestamps(ctx)

	// Watch for wallet transaction confirmations
	go e.watchWalletTransactions(ctx)

	<-ctx.Done()
	e.log.Info().Msg("notification engine stopped")
	return ctx.Err()
}

func (e *NotificationEngine) watchTimestamps(ctx context.Context) {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := e.checkTimestampConfirmations(ctx); err != nil {
				e.log.Warn().Err(err).Msg("check timestamp confirmations")
			}
		}
	}
}

func (e *NotificationEngine) checkTimestampConfirmations(ctx context.Context) error {
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
		if e.lastConfirmedTimestamps[ts.ID] {
			continue
		}

		// Check confirmations
		resp, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
			Txid:      *ts.TxID,
			Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
		}))
		if err != nil {
			e.log.Warn().
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

			event := &notificationv1.NotificationEvent{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.NotificationEvent_TimestampEvent{
					TimestampEvent: &notificationv1.TimestampEvent{
						Type:        notificationv1.TimestampEvent_TYPE_CONFIRMED,
						Id:          ts.ID,
						Filename:    ts.Filename,
						Txid:        *ts.TxID,
						BlockHeight: blockHeight,
					},
				},
			}

			e.broadcast(event)

			// Mark as notified
			e.lastConfirmedTimestamps[ts.ID] = true

			e.log.Info().
				Int64("id", ts.ID).
				Str("filename", ts.Filename).
				Msg("timestamp confirmed notification sent")
		}
	}

	return nil
}

func (e *NotificationEngine) watchWalletTransactions(ctx context.Context) {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := e.checkWalletTransactions(ctx); err != nil {
				e.log.Warn().Err(err).Msg("check wallet transactions")
			}
		}
	}
}

func (e *NotificationEngine) checkWalletTransactions(ctx context.Context) error {
	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		return err
	}

	// Get recent transactions from all wallets
	resp, err := bitcoind.ListTransactions(ctx, connect.NewRequest(&corepb.ListTransactionsRequest{
		Count: 100,
	}))
	if err != nil {
		return err
	}

	for _, tx := range resp.Msg.Transactions {
		txid := tx.Txid
		confirmations := uint32(tx.Confirmations)

		// Check if this is a new transaction or confirmation state changed
		lastConfirmations, seen := e.lastSeenTxs[txid]

		switch {
		case !seen && tx.Amount > 0:
			// Received transaction
			event := &notificationv1.NotificationEvent{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.NotificationEvent_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_RECEIVED,
						Txid:          txid,
						AmountSats:    uint64(tx.Amount * 100000000),
						Confirmations: confirmations,
					},
				},
			}
			e.broadcast(event)
			e.log.Info().
				Str("txid", txid).
				Float64("amount", tx.Amount).
				Msg("received transaction notification sent")
			e.lastSeenTxs[txid] = confirmations

		case !seen && tx.Amount < 0:
			// Sent transaction
			event := &notificationv1.NotificationEvent{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.NotificationEvent_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_SENT,
						Txid:          txid,
						AmountSats:    uint64(-tx.Amount * 100000000),
						Confirmations: confirmations,
					},
				},
			}
			e.broadcast(event)
			e.log.Info().
				Str("txid", txid).
				Float64("amount", -tx.Amount).
				Msg("sent transaction notification sent")
			e.lastSeenTxs[txid] = confirmations

		case !seen:
			// New transaction with zero amount - just track it
			e.lastSeenTxs[txid] = confirmations

		case lastConfirmations == 0 && confirmations >= 1:
			// Transaction just got first confirmation
			event := &notificationv1.NotificationEvent{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.NotificationEvent_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_CONFIRMED,
						Txid:          txid,
						AmountSats:    uint64(tx.Amount * 100000000),
						Confirmations: confirmations,
					},
				},
			}
			e.broadcast(event)
			e.log.Info().
				Str("txid", txid).
				Uint32("confirmations", confirmations).
				Msg("transaction confirmed notification sent")
			e.lastSeenTxs[txid] = confirmations

		default:
			// Just update the confirmation count
			e.lastSeenTxs[txid] = confirmations
		}
	}

	return nil
}

func (e *NotificationEngine) Subscribe(ctx context.Context) <-chan *notificationv1.NotificationEvent {
	e.mu.Lock()
	defer e.mu.Unlock()

	ch := make(chan *notificationv1.NotificationEvent, 10)
	e.subscribers = append(e.subscribers, ch)

	e.log.Debug().
		Int("subscriber_count", len(e.subscribers)).
		Msg("new subscriber added")

	// Handle cleanup when context is done
	go func() {
		<-ctx.Done()
		e.mu.Lock()
		defer e.mu.Unlock()

		// Remove subscriber
		e.subscribers = lo.Filter(e.subscribers, func(sub chan *notificationv1.NotificationEvent, _ int) bool {
			return sub != ch
		})
		close(ch)

		e.log.Debug().
			Int("subscriber_count", len(e.subscribers)).
			Msg("subscriber removed")
	}()

	return ch
}

func (e *NotificationEngine) broadcast(event *notificationv1.NotificationEvent) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	for _, sub := range e.subscribers {
		select {
		case sub <- event:
		default:
			e.log.Warn().Msg("subscriber channel full, dropping event")
		}
	}
}
