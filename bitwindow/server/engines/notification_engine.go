package engines

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/notifications"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
)

// notificationBacklog is how old a wallet transaction has to be before it counts
// as history: recorded as seen, never announced.
const notificationBacklog = 24 * time.Hour

type NotificationEngine struct {
	db       *sql.DB
	bitcoind *service.Service[corerpc.BitcoinServiceClient]
	nodeMode *NodeMode

	mu          sync.RWMutex
	subscribers []chan *notificationv1.WatchResponse
}

func NewNotificationEngine(
	db *sql.DB,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	nodeMode *NodeMode,
) *NotificationEngine {
	return &NotificationEngine{
		db:          db,
		bitcoind:    bitcoind,
		nodeMode:    nodeMode,
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
			if !e.nodeMode.RunsLocalNode(ctx) {
				continue
			}
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
		// A discovered timestamp has no filename; this app did not create it.
		if ts.TxID == nil || ts.Filename == "" {
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
				if err != nil {
					log.Warn().
						Err(err).
						Str("txid", *ts.TxID).
						Msg("get block for notification")
					continue
				}
				height := int64(blockResp.Msg.Height)
				blockHeight = &height
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

			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTimestamp, eventID); err != nil {
				return fmt.Errorf("mark timestamp %d notified: %w", ts.ID, err)
			}
			e.Deliver(ctx, event)

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
			if !e.nodeMode.RunsLocalNode(ctx) {
				continue
			}
			if err := e.checkWalletTransactions(ctx); err != nil {
				// Connection errors during startup are expected, log at debug level
				if connect.CodeOf(err) == connect.CodeUnavailable || strings.Contains(err.Error(), "connection refused") {
					log.Debug().Msg("check wallet transactions: waiting for connection")
				} else {
					log.Warn().Err(err).Msg("check wallet transactions")
				}
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

		if err := e.processWalletTransactions(ctx, walletName, resp.Msg.Transactions); err != nil {
			return fmt.Errorf("process transactions of wallet %s: %w", walletName, err)
		}
	}

	return nil
}

// walletTx is one transaction's wallet-relevant outputs in a single direction, summed.
type walletTx struct {
	txid          string
	amount        btcutil.Amount
	confirmations uint32
	txTime        time.Time
}

// aggregateByTxid folds Core's per-output rows into one entry per txid and
// direction; sends and receives stay apart so a self-send can't net to zero.
func aggregateByTxid(transactions []*corepb.GetTransactionResponse) ([]walletTx, error) {
	type bucket struct {
		txid     string
		received bool
	}

	aggregated := make([]walletTx, 0, len(transactions))
	seen := make(map[bucket]int, len(transactions))
	for _, tx := range transactions {
		amount, err := btcutil.NewAmount(tx.Amount)
		if err != nil {
			return nil, fmt.Errorf("amount of %s: %w", tx.Txid, err)
		}
		key := bucket{txid: tx.Txid, received: amount >= 0}
		if idx, ok := seen[key]; ok {
			aggregated[idx].amount += amount
			continue
		}

		var txTime time.Time
		if t := tx.GetTime(); t != nil {
			txTime = t.AsTime()
		}

		seen[key] = len(aggregated)
		aggregated = append(aggregated, walletTx{
			txid:          tx.Txid,
			amount:        amount,
			confirmations: uint32(tx.Confirmations),
			txTime:        txTime,
		})
	}
	return aggregated, nil
}

func (e *NotificationEngine) processWalletTransactions(ctx context.Context, walletName string, transactions []*corepb.GetTransactionResponse) error {
	log := zerolog.Ctx(ctx)
	aggregated, err := aggregateByTxid(transactions)
	if err != nil {
		return err
	}
	for _, tx := range aggregated {
		txid := tx.txid
		confirmations := tx.confirmations

		// The same txid can show up in several loaded wallets, so scope the
		// dedup key by wallet. Otherwise the first wallet we process swallows
		// the notification for all the others.
		eventID := walletName + ":" + txid

		// Check if we've already notified about this transaction
		notified, err := notifications.HasBeenNotified(ctx, e.db, notifications.EventTypeTransaction, eventID)
		if err != nil {
			log.Warn().Err(err).Str("txid", txid).Msg("check transaction notification status")
			continue
		}

		// For confirmation notifications, use a separate event type
		confEventID := eventID + ":confirmed"
		confNotified, err := notifications.HasBeenNotified(ctx, e.db, notifications.EventTypeTransactionConf, confEventID)
		if err != nil {
			log.Warn().Err(err).Str("txid", txid).Msg("check transaction confirmation notification status")
			continue
		}

		if notified && confNotified {
			continue
		}

		if !tx.txTime.IsZero() && time.Since(tx.txTime) > notificationBacklog {
			if !notified {
				if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, eventID); err != nil {
					return fmt.Errorf("mark backlog transaction %s notified: %w", txid, err)
				}
			}
			if !confNotified && confirmations >= 1 {
				if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransactionConf, confEventID); err != nil {
					return fmt.Errorf("mark backlog transaction %s confirmation notified: %w", txid, err)
				}
			}
			continue
		}

		switch {
		case !notified && tx.amount > 0:
			// Received transaction
			event := &notificationv1.WatchResponse{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.WatchResponse_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_RECEIVED,
						Txid:          txid,
						AmountSats:    uint64(tx.amount),
						Confirmations: confirmations,
					},
				},
			}
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, eventID); err != nil {
				return fmt.Errorf("mark transaction %s notified: %w", txid, err)
			}
			e.Deliver(ctx, event)
			log.Info().
				Str("txid", txid).
				Int64("amount_sats", int64(tx.amount)).
				Msg("received transaction notification sent")

		case !notified && tx.amount < 0:
			// Sent transaction
			event := &notificationv1.WatchResponse{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.WatchResponse_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_SENT,
						Txid:          txid,
						AmountSats:    uint64(-tx.amount),
						Confirmations: confirmations,
					},
				},
			}
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, eventID); err != nil {
				return fmt.Errorf("mark transaction %s notified: %w", txid, err)
			}
			e.Deliver(ctx, event)
			log.Info().
				Str("txid", txid).
				Int64("amount_sats", int64(-tx.amount)).
				Msg("sent transaction notification sent")

		case !notified:
			// New transaction with zero amount - just mark as seen
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, eventID); err != nil {
				return fmt.Errorf("mark transaction %s notified: %w", txid, err)
			}

		case !confNotified && confirmations >= 1:
			// Transaction just got first confirmation (and we haven't notified about it)
			event := &notificationv1.WatchResponse{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.WatchResponse_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_CONFIRMED,
						Txid:          txid,
						AmountSats:    uint64(max(tx.amount, -tx.amount)),
						Confirmations: confirmations,
					},
				},
			}
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransactionConf, confEventID); err != nil {
				return fmt.Errorf("mark transaction %s confirmation notified: %w", txid, err)
			}
			e.Deliver(ctx, event)
			log.Info().
				Str("txid", txid).
				Uint32("confirmations", confirmations).
				Msg("transaction confirmed notification sent")
		}
	}
	return nil
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

// Deliver sends an event to each subscriber and reports how many took it. A
// send to nobody, or to a full channel, reaches nobody.
func (e *NotificationEngine) Deliver(ctx context.Context, event *notificationv1.WatchResponse) int {
	log := zerolog.Ctx(ctx)
	e.mu.RLock()
	defer e.mu.RUnlock()

	delivered := 0
	for _, sub := range e.subscribers {
		select {
		case sub <- event:
			delivered++
		default:
			log.Warn().Msg("subscriber channel full, dropping event")
		}
	}
	return delivered
}
