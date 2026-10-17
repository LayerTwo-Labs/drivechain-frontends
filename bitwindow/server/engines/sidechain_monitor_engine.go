package engines

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/timestamppb"

	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
)

// SidechainMonitorEngine reports the withdrawals in the pending bundle of each sidechain.
type SidechainMonitorEngine struct {
	// Sidechain services
	thunder   *service.Service[*thunder.Client]
	bitnames  *service.Service[*bitnames.Client]
	bitassets *service.Service[*bitassets.Client]
	truthcoin *service.Service[*truthcoin.Client]
	photon    *service.Service[*photon.Client]
	coinshift *service.Service[*coinshift.Client]

	// Notification engine for streaming updates
	notificationEngine NotificationSink

	// State tracking (in-memory only)
	mu                  sync.RWMutex
	detectedWithdrawals map[string]DetectedWithdrawal // withdrawalKey -> withdrawal
	notified            map[string]bool               // withdrawalKey -> a subscriber got the event
}

const sidechainMonitorPollInterval = 30 * time.Second

type DetectedWithdrawal struct {
	Txid        string    `json:"txid"`
	Vout        uint32    `json:"vout"`
	Sidechain   string    `json:"sidechain"`
	Amount      int64     `json:"amount"`
	Destination string    `json:"destination"`
	DetectedAt  time.Time `json:"detected_at"`
	BlockHash   *string   `json:"block_hash,omitempty"`
}

func NewSidechainMonitorEngine(
	thunder *service.Service[*thunder.Client],
	bitnames *service.Service[*bitnames.Client],
	bitassets *service.Service[*bitassets.Client],
	truthcoin *service.Service[*truthcoin.Client],
	photon *service.Service[*photon.Client],
	coinshift *service.Service[*coinshift.Client],
	notificationEngine NotificationSink,
) *SidechainMonitorEngine {
	return &SidechainMonitorEngine{
		thunder:             thunder,
		bitnames:            bitnames,
		bitassets:           bitassets,
		truthcoin:           truthcoin,
		photon:              photon,
		coinshift:           coinshift,
		notificationEngine:  notificationEngine,
		detectedWithdrawals: make(map[string]DetectedWithdrawal),
		notified:            make(map[string]bool),
	}
}

// Run starts the monitoring engine
func (e *SidechainMonitorEngine) Run(ctx context.Context) error {
	log := zerolog.Ctx(ctx)
	log.Info().Msg("sidechain monitor engine starting")

	sidechains := []struct {
		name   string
		client func(context.Context) (sidechainRPC, error)
	}{
		{"thunder", rpcOf(e.thunder)},
		{"bitnames", rpcOf(e.bitnames)},
		{"bitassets", rpcOf(e.bitassets)},
		{"truthcoin", rpcOf(e.truthcoin)},
		{"photon", rpcOf(e.photon)},
		{"coinshift", rpcOf(e.coinshift)},
	}

	pool := logpool.New(ctx, "sidechain-monitor")
	for _, sc := range sidechains {
		pool.Go(sc.name, func(ctx context.Context) error {
			log := zerolog.Ctx(ctx).With().Str("sidechain", sc.name).Logger()
			ctx = log.WithContext(ctx)

			for {
				if err := e.monitor(ctx, sc.name, sc.client); err != nil {
					log.Debug().Err(err).Msgf("%s monitor error, retrying", sc.name)
				}

				select {
				case <-ctx.Done():
					return nil
				case <-time.After(sidechainMonitorPollInterval):
				}
			}
		})
	}
	return pool.Wait(ctx)
}

func (e *SidechainMonitorEngine) GetDetectedWithdrawals(ctx context.Context) ([]DetectedWithdrawal, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	return lo.Values(e.detectedWithdrawals), nil
}

func (e *SidechainMonitorEngine) GetWithdrawalByTxid(ctx context.Context, txid string) (*DetectedWithdrawal, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	withdrawal, ok := lo.FindKeyBy(e.detectedWithdrawals, func(_ string, w DetectedWithdrawal) bool { return w.Txid == txid })
	if !ok {
		return nil, nil
	}
	found := e.detectedWithdrawals[withdrawal]
	return &found, nil
}

// One sidechain tx can pay several withdrawal outputs, so the key holds the vout.
func withdrawalKey(w DetectedWithdrawal) string {
	return fmt.Sprintf("%s:%s:%d", w.Sidechain, w.Txid, w.Vout)
}

// setWithdrawals makes the detected withdrawals of sidechain the same as
// withdrawals, and reports each one that no subscriber got yet.
func (e *SidechainMonitorEngine) setWithdrawals(ctx context.Context, sidechain string, withdrawals []DetectedWithdrawal) {
	e.mu.Lock()
	defer e.mu.Unlock()

	current := lo.SliceToMap(withdrawals, func(w DetectedWithdrawal) (string, DetectedWithdrawal) { return withdrawalKey(w), w })
	for key, w := range e.detectedWithdrawals {
		if _, ok := current[key]; w.Sidechain == sidechain && !ok {
			delete(e.detectedWithdrawals, key)
			delete(e.notified, key)
		}
	}

	for _, withdrawal := range withdrawals {
		key := withdrawalKey(withdrawal)
		if _, exists := e.detectedWithdrawals[key]; !exists {
			e.detectedWithdrawals[key] = withdrawal
			zerolog.Ctx(ctx).Info().
				Str("txid", withdrawal.Txid).
				Str("sidechain", withdrawal.Sidechain).
				Int64("amount", withdrawal.Amount).
				Msg("detected withdrawal in the pending bundle")
		}
		if e.notified[key] {
			continue
		}

		withdrawal = e.detectedWithdrawals[key]
		delivered := e.notificationEngine.Deliver(ctx, &notificationv1.WatchResponse{
			Timestamp: timestamppb.Now(),
			Event: &notificationv1.WatchResponse_SidechainWithdrawal{
				SidechainWithdrawal: &notificationv1.SidechainWithdrawalEvent{
					Type:        notificationv1.SidechainWithdrawalEvent_TYPE_DETECTED,
					Txid:        withdrawal.Txid,
					Sidechain:   withdrawal.Sidechain,
					Amount:      withdrawal.Amount,
					Destination: withdrawal.Destination,
					DetectedAt:  timestamppb.New(withdrawal.DetectedAt),
					BlockHash:   withdrawal.BlockHash,
				},
			},
		})
		e.notified[key] = delivered > 0
	}
}

// sidechainRPC is the part of a sidechain client that the monitor reads.
type sidechainRPC interface {
	PendingWithdrawalBundle(ctx context.Context) (json.RawMessage, error)
}

func rpcOf[C sidechainRPC](s *service.Service[C]) func(context.Context) (sidechainRPC, error) {
	return func(ctx context.Context) (sidechainRPC, error) {
		return s.Get(ctx)
	}
}

// monitor reads the pending withdrawal bundle of one sidechain.
func (e *SidechainMonitorEngine) monitor(ctx context.Context, name string, getClient func(context.Context) (sidechainRPC, error)) error {
	client, err := getClient(ctx)
	if err != nil {
		return fmt.Errorf("get %s client: %w", name, err)
	}

	bundleRaw, err := client.PendingWithdrawalBundle(ctx)
	if err != nil {
		return fmt.Errorf("get pending withdrawal bundle: %w", err)
	}

	return e.parseWithdrawalBundle(ctx, bundleRaw, name)
}

// pendingBundle is the WithdrawalBundle of thunder types/lib.rs in its JSON
// form. Each spend_utxos entry is an [OutPoint, Output] pair.
type pendingBundle struct {
	SpendUtxos [][2]json.RawMessage `json:"spend_utxos"`
}

type bundleOutPoint struct {
	Regular *struct {
		Txid string `json:"txid"`
		Vout uint32 `json:"vout"`
	} `json:"Regular"`
}

// bitassets names the payout BitcoinWithdrawal; the other sidechains name it Withdrawal.
type bundleOutput struct {
	Content struct {
		Withdrawal        *bundlePayout `json:"Withdrawal"`
		BitcoinWithdrawal *bundlePayout `json:"BitcoinWithdrawal"`
	} `json:"content"`
}

type bundlePayout struct {
	ValueSats   int64  `json:"value_sats"`
	MainAddress string `json:"main_address"`
}

// parseWithdrawalBundle reads the payouts of the pending bundle. A null
// bundle means that the sidechain has no pending bundle.
func (e *SidechainMonitorEngine) parseWithdrawalBundle(ctx context.Context, bundleRaw json.RawMessage, sidechainName string) error {
	var bundle *pendingBundle
	if err := json.Unmarshal(bundleRaw, &bundle); err != nil {
		return fmt.Errorf("parse withdrawal bundle: %w", err)
	}

	var withdrawals []DetectedWithdrawal
	if bundle != nil {
		for _, pair := range bundle.SpendUtxos {
			var outPoint bundleOutPoint
			if err := json.Unmarshal(pair[0], &outPoint); err != nil {
				return fmt.Errorf("parse bundle outpoint: %w", err)
			}
			var output bundleOutput
			if err := json.Unmarshal(pair[1], &output); err != nil {
				return fmt.Errorf("parse bundle output: %w", err)
			}
			payout := output.Content.Withdrawal
			if payout == nil {
				payout = output.Content.BitcoinWithdrawal
			}
			if outPoint.Regular == nil || payout == nil {
				return fmt.Errorf("bundle spends a coin that is not a withdrawal: %s", pair[0])
			}
			withdrawals = append(withdrawals, DetectedWithdrawal{
				Txid:        outPoint.Regular.Txid,
				Vout:        outPoint.Regular.Vout,
				Sidechain:   sidechainName,
				Amount:      payout.ValueSats,
				Destination: payout.MainAddress,
				DetectedAt:  time.Now(),
			})
		}
	}

	e.setWithdrawals(ctx, sidechainName, withdrawals)
	return nil
}
