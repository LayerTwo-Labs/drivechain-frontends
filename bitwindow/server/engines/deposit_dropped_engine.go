package engines

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/notifications"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/rs/zerolog"
)

// depositDroppedTickInterval is how often the engine re-reads the deposits.
// The orchestrator stamps a drop about a minute after the network loses the
// transaction, so a slower poll here only delays the news.
const depositDroppedTickInterval = 60 * time.Second

// DepositLister reads the deposits of one slot from the orchestrator.
type DepositLister interface {
	ListSidechainDeposits(ctx context.Context, slot uint32, walletID string) ([]*orchpb.SidechainDeposit, error)
}

// DepositDroppedEngine tells the user about a deposit the network dropped. The
// coin never reaches the sidechain, and nothing else in the app says so, so
// without this the deposit simply never arrives.
// NotificationSink delivers an event and reports how many subscribers took it.
type NotificationSink interface {
	Deliver(ctx context.Context, event *notificationv1.WatchResponse) int
}

type DepositDroppedEngine struct {
	db            *sql.DB
	deposits      DepositLister
	notifications NotificationSink
	slots         func() []uint32
}

func NewDepositDroppedEngine(
	db *sql.DB, deposits DepositLister, broadcaster NotificationSink, slots func() []uint32,
) *DepositDroppedEngine {
	return &DepositDroppedEngine{db: db, deposits: deposits, notifications: broadcaster, slots: slots}
}

func (e *DepositDroppedEngine) Run(ctx context.Context) error {
	ticker := time.NewTicker(depositDroppedTickInterval)
	defer ticker.Stop()

	zerolog.Ctx(ctx).Info().Dur("interval", depositDroppedTickInterval).
		Msg("deposit dropped engine started")

	// The first pass waits for the tick. At startup the orchestrator has
	// stamped nothing yet, so an immediate poll only wakes the enforcer.
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
		}
		e.tick(ctx)
	}
}

func (e *DepositDroppedEngine) tick(ctx context.Context) {
	log := zerolog.Ctx(ctx)
	for _, slot := range e.slots() {
		deposits, err := e.deposits.ListSidechainDeposits(ctx, slot, "")
		if err != nil {
			log.Debug().Err(err).Uint32("slot", slot).Msg("could not read the deposits of the slot")
			continue
		}
		for _, d := range deposits {
			// The orchestrator lifts the stamp when a deposit comes back. A
			// later eviction is a new episode, so the old report must not
			// silence it.
			if d.GetDroppedAt() == "" {
				if err := notifications.ClearNotified(ctx, e.db, notifications.EventTypeDepositDropped, d.GetTxid()); err != nil {
					log.Debug().Err(err).Str("txid", d.GetTxid()).Msg("could not clear the drop report")
				}
				continue
			}
			if err := e.report(ctx, slot, d); err != nil {
				log.Warn().Err(err).Str("txid", d.GetTxid()).Msg("could not report the dropped deposit")
			}
		}
	}
}

// report tells the user one time per deposit. The engine re-reads the same
// dropped deposit every minute for as long as the row lives.
func (e *DepositDroppedEngine) report(ctx context.Context, slot uint32, d *orchpb.SidechainDeposit) error {
	notified, err := notifications.HasBeenNotified(ctx, e.db, notifications.EventTypeDepositDropped, d.GetTxid())
	if err != nil {
		return fmt.Errorf("read the notified state: %w", err)
	}
	if notified {
		return nil
	}
	delivered := e.notifications.Deliver(ctx, &notificationv1.WatchResponse{
		Event: &notificationv1.WatchResponse_System{
			System: &notificationv1.SystemEvent{
				Type: notificationv1.SystemEvent_TYPE_DEPOSIT_DROPPED,
				Message: fmt.Sprintf(
					"The network dropped your deposit of %d sats to slot %d, so it can never confirm. Deposit again to send it.",
					d.GetAmountSats(), slot),
			},
		},
	})
	// A send that reached nobody, or a full channel, is not a report. Leave
	// the deposit pending so the news survives until BitWindow listens.
	if delivered == 0 {
		return nil
	}

	if err := notifications.MarkNotified(ctx, e.db, notifications.EventTypeDepositDropped, d.GetTxid()); err != nil {
		return fmt.Errorf("mark the deposit reported: %w", err)
	}
	return nil
}
