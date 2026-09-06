package engines

import (
	"context"
	"database/sql"
	"fmt"
	"math"
	"strings"
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

// SetNodeMode gates both watches on the node mode. Light mode runs no local
// Bitcoin Core, so there are no core wallets and no confirmations to read.
func (e *NotificationEngine) SetNodeMode(nodeMode *NodeMode) {
	e.nodeMode = nodeMode
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
			if err := notifications.MarkNotifiedAt(ctx, e.db, notifications.EventTypeTimestamp, eventID, blockHeight); err != nil {
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

	// The tip turns a confirmation count into the height that confirmed the
	// transaction, which is what a fork purge matches on.
	chainInfo, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
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

		e.processWalletTransactions(ctx, walletName, chainInfo.Msg.Blocks, resp.Msg.Transactions)
	}

	return nil
}

// walletTx is one transaction's wallet-relevant outputs in a single direction, summed.
type walletTx struct {
	txid          string
	amount        float64
	confirmations uint32
	txTime        time.Time
}

// aggregateByTxid folds Core's per-output rows into one entry per txid and
// direction; sends and receives stay apart so a self-send can't net to zero.
func aggregateByTxid(transactions []*corepb.GetTransactionResponse) []walletTx {
	type bucket struct {
		txid     string
		received bool
	}

	aggregated := make([]walletTx, 0, len(transactions))
	seen := make(map[bucket]int, len(transactions))
	for _, tx := range transactions {
		key := bucket{txid: tx.Txid, received: tx.Amount >= 0}
		if idx, ok := seen[key]; ok {
			aggregated[idx].amount += tx.Amount
			continue
		}

		var txTime time.Time
		if t := tx.GetTime(); t != nil {
			txTime = t.AsTime()
		}

		seen[key] = len(aggregated)
		aggregated = append(aggregated, walletTx{
			txid:          tx.Txid,
			amount:        tx.Amount,
			confirmations: uint32(tx.Confirmations),
			txTime:        txTime,
		})
	}
	return aggregated
}

// confirmingHeight is the height of the block that gave a transaction its first
// confirmation, or nil when the tip doesn't place it.
func confirmingHeight(tipHeight, confirmations uint32) *int64 {
	if tipHeight == 0 || confirmations == 0 || confirmations > tipHeight {
		return nil
	}
	height := int64(tipHeight - confirmations + 1)
	return &height
}

func (e *NotificationEngine) processWalletTransactions(ctx context.Context, walletName string, tipHeight uint32, transactions []*corepb.GetTransactionResponse) {
	log := zerolog.Ctx(ctx)
	for _, tx := range aggregateByTxid(transactions) {
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
					log.Warn().Err(err).Str("txid", txid).Msg("mark backlog transaction notified")
					continue
				}
			}
			if !confNotified && confirmations >= 1 {
				if err := notifications.MarkNotifiedAt(ctx, e.db, notifications.EventTypeTransactionConf, confEventID, confirmingHeight(tipHeight, confirmations)); err != nil {
					log.Warn().Err(err).Str("txid", txid).Msg("mark backlog transaction confirmation notified")
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
						AmountSats:    uint64(math.Round(tx.amount * 100000000)),
						Confirmations: confirmations,
					},
				},
			}
			e.broadcast(ctx, event)
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, eventID); err != nil {
				log.Warn().Err(err).Str("txid", txid).Msg("mark transaction notified")
			}
			log.Info().
				Str("txid", txid).
				Float64("amount", tx.amount).
				Msg("received transaction notification sent")

		case !notified && tx.amount < 0:
			// Sent transaction
			event := &notificationv1.WatchResponse{
				Timestamp: timestamppb.Now(),
				Event: &notificationv1.WatchResponse_Transaction{
					Transaction: &notificationv1.TransactionEvent{
						Type:          notificationv1.TransactionEvent_TYPE_SENT,
						Txid:          txid,
						AmountSats:    uint64(math.Round(-tx.amount * 100000000)),
						Confirmations: confirmations,
					},
				},
			}
			e.broadcast(ctx, event)
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, eventID); err != nil {
				log.Warn().Err(err).Str("txid", txid).Msg("mark transaction notified")
			}
			log.Info().
				Str("txid", txid).
				Float64("amount", -tx.amount).
				Msg("sent transaction notification sent")

		case !notified:
			// New transaction with zero amount - just mark as seen
			if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeTransaction, eventID); err != nil {
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
						AmountSats:    uint64(math.Round(tx.amount * 100000000)),
						Confirmations: confirmations,
					},
				},
			}
			e.broadcast(ctx, event)
			if err := notifications.MarkNotifiedAt(ctx, e.db, notifications.EventTypeTransactionConf, confEventID, confirmingHeight(tipHeight, confirmations)); err != nil {
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

// Broadcast sends a notification event to all subscribers (public method)
func (e *NotificationEngine) Broadcast(ctx context.Context, event *notificationv1.WatchResponse) {
	e.broadcast(ctx, event)
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
