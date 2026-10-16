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
	detectedWithdrawals map[string]DetectedWithdrawal // txid -> withdrawal info
}

type DetectedWithdrawal struct {
	Txid        string    `json:"txid"`
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
	}
}

// Run starts the monitoring engine
func (e *SidechainMonitorEngine) Run(ctx context.Context) error {
	log := zerolog.Ctx(ctx)
	log.Info().Msg("sidechain monitor engine starting")

	// Start monitoring each sidechain in parallel
	var wg sync.WaitGroup

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

	for _, sc := range sidechains {
		wg.Add(1)
		go func(name string, client func(context.Context) (sidechainRPC, error)) {
			defer wg.Done()
			log := log.With().Str("sidechain", name).Logger()
			ctx := log.WithContext(ctx)

			var pollCount int
			for {
				select {
				case <-ctx.Done():
					return
				default:
					if err := e.monitor(ctx, name, client); err != nil {
						log.Debug().Err(err).Msgf("%s monitor error, retrying", name)
					}

					pollCount++
					// Cleanup old withdrawals every 60 polls for ALL sidechains (fix memory leak)
					if pollCount%60 == 0 {
						e.cleanupOldWithdrawals()
					}

					// Dynamic polling interval based on pending withdrawals
					pollInterval := e.getPollInterval()

					// Wait before next poll
					select {
					case <-ctx.Done():
						return
					case <-time.After(pollInterval):
					}
				}
			}
		}(sc.name, sc.client)
	}

	wg.Wait()
	return nil
}

func (e *SidechainMonitorEngine) GetDetectedWithdrawals(ctx context.Context) ([]DetectedWithdrawal, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	return lo.Values(e.detectedWithdrawals), nil
}

func (e *SidechainMonitorEngine) GetWithdrawalByTxid(ctx context.Context, txid string) (*DetectedWithdrawal, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	if withdrawal, exists := e.detectedWithdrawals[txid]; exists {
		return &withdrawal, nil
	}

	return nil, nil
}

// getPollInterval returns the polling interval based on pending withdrawals
func (e *SidechainMonitorEngine) getPollInterval() time.Duration {
	e.mu.RLock()
	defer e.mu.RUnlock()

	pendingCount := len(e.detectedWithdrawals)

	switch {
	case pendingCount == 0:
		return 30 * time.Second // No activity
	case pendingCount < 3:
		return 5 * time.Second // Light activity - more reasonable
	default:
		return 2 * time.Second // Heavy activity - cap at 2 seconds (less aggressive)
	}
}

// cleanupOldWithdrawals removes withdrawals older than 1 hour to prevent memory bloat
func (e *SidechainMonitorEngine) cleanupOldWithdrawals() {
	e.mu.Lock()
	defer e.mu.Unlock()

	cutoff := time.Now().Add(-time.Hour)
	for txid, withdrawal := range e.detectedWithdrawals {
		if withdrawal.DetectedAt.Before(cutoff) {
			delete(e.detectedWithdrawals, txid)
		}
	}
}

// storeWithdrawal stores a detected withdrawal in memory only
func (e *SidechainMonitorEngine) storeWithdrawal(ctx context.Context, withdrawal DetectedWithdrawal) {
	log := zerolog.Ctx(ctx)

	e.mu.Lock()
	defer e.mu.Unlock()

	// Check if already detected
	if _, exists := e.detectedWithdrawals[withdrawal.Txid]; exists {
		return
	}

	// Store in memory only
	e.detectedWithdrawals[withdrawal.Txid] = withdrawal

	// Broadcast notification to frontend
	event := &notificationv1.WatchResponse{
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
	}
	e.notificationEngine.Deliver(ctx, event)

	log.Info().
		Str("txid", withdrawal.Txid).
		Str("sidechain", withdrawal.Sidechain).
		Int64("amount", withdrawal.Amount).
		Msg("detected fast withdrawal transaction")
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

// parseWithdrawalBundle is a helper to parse withdrawal bundle JSON for any sidechain
func (e *SidechainMonitorEngine) parseWithdrawalBundle(ctx context.Context, bundleRaw json.RawMessage, sidechainName string) error {

	var bundle map[string]interface{}
	if err := json.Unmarshal(bundleRaw, &bundle); err != nil {
		return fmt.Errorf("parse withdrawal bundle: %w", err)
	}

	// Extract withdrawal transactions from bundle
	if transactions, ok := bundle["transactions"].([]interface{}); ok {
		for _, tx := range transactions {
			if txMap, ok := tx.(map[string]interface{}); ok {
				if txid, hasID := txMap["txid"].(string); hasID {
					if amount, hasAmount := txMap["amount"].(float64); hasAmount {
						if dest, hasDest := txMap["destination"].(string); hasDest {
							withdrawal := DetectedWithdrawal{
								Txid:        txid,
								Sidechain:   sidechainName,
								Amount:      int64(amount),
								Destination: dest,
								DetectedAt:  time.Now(),
							}

							e.storeWithdrawal(ctx, withdrawal)
						}
					}
				}
			}
		}
	}

	return nil
}
