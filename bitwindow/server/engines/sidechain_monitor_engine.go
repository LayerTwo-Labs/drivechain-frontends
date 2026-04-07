package engines

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// SidechainMonitorEngine monitors all sidechains for fast withdrawal transactions
type SidechainMonitorEngine struct {
	// Sidechain services
	thunder   *service.Service[*thunder.Client]
	bitnames  *service.Service[*bitnames.Client]
	bitassets *service.Service[*bitassets.Client]
	truthcoin *service.Service[*truthcoin.Client]
	photon    *service.Service[*photon.Client]
	coinshift *service.Service[*coinshift.Client]

	// Notification engine for streaming updates
	notificationEngine *NotificationEngine

	// State tracking (in-memory only)
	mu                sync.RWMutex
	detectedWithdrawals map[string]DetectedWithdrawal // txid -> withdrawal info
}

// DetectedWithdrawal represents a detected fast withdrawal transaction
type DetectedWithdrawal struct {
	Txid        string    `json:"txid"`
	Sidechain   string    `json:"sidechain"`
	Amount      int64     `json:"amount"`
	Destination string    `json:"destination"`
	DetectedAt  time.Time `json:"detected_at"`
	BlockHash   *string   `json:"block_hash,omitempty"`
}

// NewSidechainMonitorEngine creates a new sidechain monitoring engine
func NewSidechainMonitorEngine(
	thunder *service.Service[*thunder.Client],
	bitnames *service.Service[*bitnames.Client],
	bitassets *service.Service[*bitassets.Client],
	truthcoin *service.Service[*truthcoin.Client],
	photon *service.Service[*photon.Client],
	coinshift *service.Service[*coinshift.Client],
	notificationEngine *NotificationEngine,
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
		name    string
		monitor func(context.Context) error
	}{
		{"thunder", e.monitorThunder},
		{"bitnames", e.monitorBitnames},
		{"bitassets", e.monitorBitassets},
		{"truthcoin", e.monitorTruthcoin},
		{"photon", e.monitorPhoton},
		{"coinshift", e.monitorCoinshift},
	}

	for _, sc := range sidechains {
		wg.Add(1)
		go func(name string, monitor func(context.Context) error) {
			defer wg.Done()
			log := log.With().Str("sidechain", name).Logger()
			ctx := log.WithContext(ctx)

			var pollCount int
			for {
				select {
				case <-ctx.Done():
					return
				default:
					if err := monitor(ctx); err != nil {
						log.Debug().Err(err).Msgf("%s monitor error, retrying", name)
					}
					
					pollCount++
					// Cleanup old withdrawals every 60 polls for one sidechain
					if name == "thunder" && pollCount%60 == 0 {
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
		}(sc.name, sc.monitor)
	}

	wg.Wait()
	return nil
}

// GetDetectedWithdrawals returns all detected withdrawals
func (e *SidechainMonitorEngine) GetDetectedWithdrawals(ctx context.Context) ([]DetectedWithdrawal, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	withdrawals := make([]DetectedWithdrawal, 0, len(e.detectedWithdrawals))
	for _, withdrawal := range e.detectedWithdrawals {
		withdrawals = append(withdrawals, withdrawal)
	}

	return withdrawals, nil
}

// GetWithdrawalByTxid returns a specific withdrawal by transaction ID
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

	// If there are pending withdrawals, poll every second for quick confirmation detection
	if len(e.detectedWithdrawals) > 0 {
		return 1 * time.Second
	}
	
	// Otherwise, normal 30-second interval
	return 30 * time.Second
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
func (e *SidechainMonitorEngine) storeWithdrawal(ctx context.Context, withdrawal DetectedWithdrawal) error {
	log := zerolog.Ctx(ctx)

	e.mu.Lock()
	defer e.mu.Unlock()

	// Check if already detected
	if _, exists := e.detectedWithdrawals[withdrawal.Txid]; exists {
		return nil // Already stored
	}

	// Store in memory only
	e.detectedWithdrawals[withdrawal.Txid] = withdrawal

	// Broadcast notification to frontend
	if e.notificationEngine != nil {
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
		e.notificationEngine.Broadcast(ctx, event)
	}

	log.Info().
		Str("txid", withdrawal.Txid).
		Str("sidechain", withdrawal.Sidechain).
		Int64("amount", withdrawal.Amount).
		Msg("detected fast withdrawal transaction")

	return nil
}

// monitorThunder monitors Thunder sidechain for withdrawal transactions
func (e *SidechainMonitorEngine) monitorThunder(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	client, err := e.thunder.Get(ctx)
	if err != nil {
		return fmt.Errorf("get thunder client: %w", err)
	}

	// Get pending withdrawal bundle (contains fast withdrawals)
	bundleRaw, err := client.PendingWithdrawalBundle(ctx)
	if err != nil {
		return fmt.Errorf("get pending withdrawal bundle: %w", err)
	}

	// Parse the JSON response to extract withdrawal transactions
	var bundle map[string]interface{}
	if err := json.Unmarshal(bundleRaw, &bundle); err != nil {
		return fmt.Errorf("parse withdrawal bundle: %w", err)
	}

	// Extract withdrawal transactions from bundle
	// This depends on the actual Thunder withdrawal bundle format
	if transactions, ok := bundle["transactions"].([]interface{}); ok {
		for _, tx := range transactions {
			if txMap, ok := tx.(map[string]interface{}); ok {
				if txid, hasId := txMap["txid"].(string); hasId {
					if amount, hasAmount := txMap["amount"].(float64); hasAmount {
						if dest, hasDest := txMap["destination"].(string); hasDest {
							withdrawal := DetectedWithdrawal{
								Txid:        txid,
								Sidechain:   "thunder",
								Amount:      int64(amount),
								Destination: dest,
								DetectedAt:  time.Now(),
							}

							if err := e.storeWithdrawal(ctx, withdrawal); err != nil {
								log.Warn().Err(err).Str("txid", txid).Msg("failed to store thunder withdrawal")
							}
						}
					}
				}
			}
		}
	}

	return nil
}

// monitorBitnames monitors BitNames sidechain for withdrawal transactions
func (e *SidechainMonitorEngine) monitorBitnames(ctx context.Context) error {
	client, err := e.bitnames.Get(ctx)
	if err != nil {
		return fmt.Errorf("get bitnames client: %w", err)
	}

	// Get pending withdrawal bundle
	bundleRaw, err := client.PendingWithdrawalBundle(ctx)
	if err != nil {
		return fmt.Errorf("get pending withdrawal bundle: %w", err)
	}

	// Parse similar to Thunder
	return e.parseWithdrawalBundle(ctx, bundleRaw, "bitnames")
}

// monitorBitassets monitors BitAssets sidechain for withdrawal transactions
func (e *SidechainMonitorEngine) monitorBitassets(ctx context.Context) error {
	client, err := e.bitassets.Get(ctx)
	if err != nil {
		return fmt.Errorf("get bitassets client: %w", err)
	}

	bundleRaw, err := client.PendingWithdrawalBundle(ctx)
	if err != nil {
		return fmt.Errorf("get pending withdrawal bundle: %w", err)
	}

	return e.parseWithdrawalBundle(ctx, bundleRaw, "bitassets")
}

// monitorTruthcoin monitors Truthcoin sidechain for withdrawal transactions
func (e *SidechainMonitorEngine) monitorTruthcoin(ctx context.Context) error {
	client, err := e.truthcoin.Get(ctx)
	if err != nil {
		return fmt.Errorf("get truthcoin client: %w", err)
	}

	bundleRaw, err := client.PendingWithdrawalBundle(ctx)
	if err != nil {
		return fmt.Errorf("get pending withdrawal bundle: %w", err)
	}

	return e.parseWithdrawalBundle(ctx, bundleRaw, "truthcoin")
}

// monitorPhoton monitors Photon sidechain for withdrawal transactions
func (e *SidechainMonitorEngine) monitorPhoton(ctx context.Context) error {
	client, err := e.photon.Get(ctx)
	if err != nil {
		return fmt.Errorf("get photon client: %w", err)
	}

	bundleRaw, err := client.PendingWithdrawalBundle(ctx)
	if err != nil {
		return fmt.Errorf("get pending withdrawal bundle: %w", err)
	}

	return e.parseWithdrawalBundle(ctx, bundleRaw, "photon")
}

// monitorCoinshift monitors CoinShift sidechain for withdrawal transactions
func (e *SidechainMonitorEngine) monitorCoinshift(ctx context.Context) error {
	client, err := e.coinshift.Get(ctx)
	if err != nil {
		return fmt.Errorf("get coinshift client: %w", err)
	}

	bundleRaw, err := client.PendingWithdrawalBundle(ctx)
	if err != nil {
		return fmt.Errorf("get pending withdrawal bundle: %w", err)
	}

	return e.parseWithdrawalBundle(ctx, bundleRaw, "coinshift")
}

// parseWithdrawalBundle is a helper to parse withdrawal bundle JSON for any sidechain
func (e *SidechainMonitorEngine) parseWithdrawalBundle(ctx context.Context, bundleRaw json.RawMessage, sidechainName string) error {
	log := zerolog.Ctx(ctx)

	var bundle map[string]interface{}
	if err := json.Unmarshal(bundleRaw, &bundle); err != nil {
		return fmt.Errorf("parse withdrawal bundle: %w", err)
	}

	// Extract withdrawal transactions from bundle
	if transactions, ok := bundle["transactions"].([]interface{}); ok {
		for _, tx := range transactions {
			if txMap, ok := tx.(map[string]interface{}); ok {
				if txid, hasId := txMap["txid"].(string); hasId {
					if amount, hasAmount := txMap["amount"].(float64); hasAmount {
						if dest, hasDest := txMap["destination"].(string); hasDest {
							withdrawal := DetectedWithdrawal{
								Txid:        txid,
								Sidechain:   sidechainName,
								Amount:      int64(amount),
								Destination: dest,
								DetectedAt:  time.Now(),
							}

							if err := e.storeWithdrawal(ctx, withdrawal); err != nil {
								log.Warn().Err(err).Str("txid", txid).Msg("failed to store withdrawal")
							}
						}
					}
				}
			}
		}
	}

	return nil
}