package engines

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"net/http"
	"regexp"
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

// NotificationBroadcaster interface for testability
type NotificationBroadcaster interface {
	Broadcast(ctx context.Context, event *notificationv1.WatchResponse)
}

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
	notificationEngine NotificationBroadcaster

	// State tracking (in-memory only)
	mu                     sync.RWMutex
	detectedWithdrawals    map[string]DetectedWithdrawal    // txid -> withdrawal info
	pendingFastWithdrawals map[string]PendingFastWithdrawal // hash -> pending withdrawal

	// Secure HTTP client
	httpClient *http.Client
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

// PendingFastWithdrawal represents a fast withdrawal waiting for L2 payment
type PendingFastWithdrawal struct {
	Hash           string    `json:"hash"`            // Withdrawal hash from server
	Sidechain      string    `json:"sidechain"`       // Which sidechain
	ServerAddress  string    `json:"server_address"`  // L2 address to send to
	ExpectedAmount int64     `json:"expected_amount"` // Amount expected (sats)
	ServerURL      string    `json:"server_url"`      // Fast withdrawal server URL
	CreatedAt      time.Time `json:"created_at"`
}

// NewSidechainMonitorEngine creates a new sidechain monitoring engine
func NewSidechainMonitorEngine(
	thunder *service.Service[*thunder.Client],
	bitnames *service.Service[*bitnames.Client],
	bitassets *service.Service[*bitassets.Client],
	truthcoin *service.Service[*truthcoin.Client],
	photon *service.Service[*photon.Client],
	coinshift *service.Service[*coinshift.Client],
	notificationEngine NotificationBroadcaster,
) *SidechainMonitorEngine {
	return &SidechainMonitorEngine{
		thunder:                thunder,
		bitnames:               bitnames,
		bitassets:              bitassets,
		truthcoin:              truthcoin,
		photon:                 photon,
		coinshift:              coinshift,
		notificationEngine:     notificationEngine,
		detectedWithdrawals:    make(map[string]DetectedWithdrawal),
		pendingFastWithdrawals: make(map[string]PendingFastWithdrawal),
		httpClient:             createSecureHTTPClient(),
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

// RegisterPendingFastWithdrawal adds a pending fast withdrawal to monitor for
func (e *SidechainMonitorEngine) RegisterPendingFastWithdrawal(ctx context.Context, withdrawal PendingFastWithdrawal) error {
	e.mu.Lock()
	defer e.mu.Unlock()

	e.pendingFastWithdrawals[withdrawal.Hash] = withdrawal

	zerolog.Ctx(ctx).Info().
		Str("hash", withdrawal.Hash).
		Str("sidechain", withdrawal.Sidechain).
		Str("address", withdrawal.ServerAddress).
		Int64("amount", withdrawal.ExpectedAmount).
		Msg("registered pending fast withdrawal for monitoring")

	return nil
}

// GetPendingFastWithdrawals returns all pending fast withdrawals
func (e *SidechainMonitorEngine) GetPendingFastWithdrawals(ctx context.Context) ([]PendingFastWithdrawal, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	withdrawals := make([]PendingFastWithdrawal, 0, len(e.pendingFastWithdrawals))
	for _, withdrawal := range e.pendingFastWithdrawals {
		withdrawals = append(withdrawals, withdrawal)
	}

	return withdrawals, nil
}

// checkFastWithdrawalPayments checks if any pending fast withdrawals have been paid
func (e *SidechainMonitorEngine) checkFastWithdrawalPayments(ctx context.Context, sidechain string) error {
	log := zerolog.Ctx(ctx)

	// Get pending fast withdrawals for this sidechain
	e.mu.RLock()
	var pendingForSidechain []PendingFastWithdrawal
	for _, pending := range e.pendingFastWithdrawals {
		if pending.Sidechain == sidechain {
			pendingForSidechain = append(pendingForSidechain, pending)
		}
	}
	e.mu.RUnlock()

	if len(pendingForSidechain) == 0 {
		return nil // Nothing to check
	}

	// Get the sidechain client to check for transactions
	var client interface{}
	var err error

	switch sidechain {
	case "thunder":
		client, err = e.thunder.Get(ctx)
	case "bitnames":
		client, err = e.bitnames.Get(ctx)
	case "bitassets":
		client, err = e.bitassets.Get(ctx)
	case "truthcoin":
		client, err = e.truthcoin.Get(ctx)
	case "photon":
		client, err = e.photon.Get(ctx)
	case "coinshift":
		client, err = e.coinshift.Get(ctx)
	default:
		return fmt.Errorf("unsupported sidechain: %s", sidechain)
	}

	if err != nil {
		return fmt.Errorf("get %s client: %w", sidechain, err)
	}

	// TODO: Check for transactions to each pending withdrawal's server address
	// This would require extending sidechain clients with a method to get transactions to specific addresses
	// For now, this is a placeholder that shows the architecture

	for _, pending := range pendingForSidechain {
		// Check if transaction to pending.ServerAddress exists
		// If found, auto-complete the withdrawal
		txid := e.findTransactionToAddress(ctx, client, pending.ServerAddress, pending.ExpectedAmount)
		if txid != "" {
			log.Info().
				Str("hash", pending.Hash).
				Str("txid", txid).
				Str("address", pending.ServerAddress).
				Msg("detected L2 payment for fast withdrawal, auto-completing")

			// Auto-complete the withdrawal
			if err := e.completeWithdrawal(ctx, pending, txid); err != nil {
				log.Error().Err(err).Str("hash", pending.Hash).Msg("failed to auto-complete withdrawal")
			}
		}
	}

	return nil
}

// getPollInterval returns the polling interval based on pending withdrawals
func (e *SidechainMonitorEngine) getPollInterval() time.Duration {
	e.mu.RLock()
	defer e.mu.RUnlock()

	// Check both detected withdrawals and pending fast withdrawals
	pendingCount := len(e.detectedWithdrawals) + len(e.pendingFastWithdrawals)

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
								return fmt.Errorf("store thunder withdrawal %s: %w", txid, err)
							}
						}
					}
				}
			}
		}
	}

	// Also check for transactions to pending fast withdrawal addresses
	if err := e.checkFastWithdrawalPayments(ctx, "thunder"); err != nil {
		log.Warn().Err(err).Msg("failed to check fast withdrawal payments")
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
	err = e.parseWithdrawalBundle(ctx, bundleRaw, "bitnames")
	if err != nil {
		return err
	}

	// Also check for transactions to pending fast withdrawal addresses
	if err := e.checkFastWithdrawalPayments(ctx, "bitnames"); err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("failed to check fast withdrawal payments")
	}

	return nil
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

	err = e.parseWithdrawalBundle(ctx, bundleRaw, "bitassets")
	if err != nil {
		return err
	}

	// Also check for transactions to pending fast withdrawal addresses
	if err := e.checkFastWithdrawalPayments(ctx, "bitassets"); err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("failed to check fast withdrawal payments")
	}

	return nil
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

	err = e.parseWithdrawalBundle(ctx, bundleRaw, "truthcoin")
	if err != nil {
		return err
	}

	// Also check for transactions to pending fast withdrawal addresses
	if err := e.checkFastWithdrawalPayments(ctx, "truthcoin"); err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("failed to check fast withdrawal payments")
	}

	return nil
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

	err = e.parseWithdrawalBundle(ctx, bundleRaw, "photon")
	if err != nil {
		return err
	}

	// Also check for transactions to pending fast withdrawal addresses
	if err := e.checkFastWithdrawalPayments(ctx, "photon"); err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("failed to check fast withdrawal payments")
	}

	return nil
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

	err = e.parseWithdrawalBundle(ctx, bundleRaw, "coinshift")
	if err != nil {
		return err
	}

	// Also check for transactions to pending fast withdrawal addresses
	if err := e.checkFastWithdrawalPayments(ctx, "coinshift"); err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("failed to check fast withdrawal payments")
	}

	return nil
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
								return fmt.Errorf("store %s withdrawal %s: %w", sidechainName, txid, err)
							}
						}
					}
				}
			}
		}
	}

	return nil
}

// findTransactionToAddress checks if there's a transaction to the given address
func (e *SidechainMonitorEngine) findTransactionToAddress(ctx context.Context, client interface{}, address string, expectedAmount int64) string {
	log := zerolog.Ctx(ctx)

	// Try to get recent transactions and check if any are to our address
	// This is a simplified implementation - in reality we'd need proper address-specific queries

	switch c := client.(type) {
	case *thunder.Client:
		return e.findThunderTransactionToAddress(ctx, c, address, expectedAmount)
	case *bitnames.Client:
		return e.findBitnamesTransactionToAddress(ctx, c, address, expectedAmount)
	case *bitassets.Client:
		return e.findBitassetsTransactionToAddress(ctx, c, address, expectedAmount)
	case *truthcoin.Client:
		return e.findTruthcoinTransactionToAddress(ctx, c, address, expectedAmount)
	case *photon.Client:
		return e.findPhotonTransactionToAddress(ctx, c, address, expectedAmount)
	case *coinshift.Client:
		return e.findCoinshiftTransactionToAddress(ctx, c, address, expectedAmount)
	default:
		log.Warn().Str("address", address).Msg("unknown sidechain client type for transaction detection")
		return ""
	}
}

// completeWithdrawal automatically completes a fast withdrawal by calling the external server
func (e *SidechainMonitorEngine) completeWithdrawal(ctx context.Context, pending PendingFastWithdrawal, txid string) error {
	log := zerolog.Ctx(ctx)

	// Validate inputs
	if err := validateWithdrawalHash(pending.Hash); err != nil {
		return fmt.Errorf("invalid withdrawal hash: %w", err)
	}
	if err := validateWithdrawalHash(txid); err != nil {
		return fmt.Errorf("invalid transaction ID: %w", err)
	}

	// Call the external fast withdrawal server's /paid endpoint
	payload := map[string]string{
		"hash": pending.Hash,
		"txid": txid,
	}

	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshal payload: %w", err)
	}

	url := pending.ServerURL + "/paid"
	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonPayload))
	if err != nil {
		return fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := e.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("http request to %s: %w", url, err)
	}
	defer resp.Body.Close()

	// Limit response size
	limitedReader := http.MaxBytesReader(nil, resp.Body, 1024*1024) // 1MB max
	var result map[string]interface{}
	if err := json.NewDecoder(limitedReader).Decode(&result); err != nil {
		return fmt.Errorf("decode response: %w", err)
	}

	// Validate server response
	if err := validateServerResponse(resp, result); err != nil {
		return fmt.Errorf("server response validation failed: %w", err)
	}

	// Remove from pending withdrawals
	e.mu.Lock()
	delete(e.pendingFastWithdrawals, pending.Hash)
	e.mu.Unlock()

	log.Info().
		Str("hash", pending.Hash).
		Str("txid", txid).
		Msg("fast withdrawal completed automatically")

	// TODO: Broadcast notification to frontend about completion

	return nil
}

// findThunderTransactionToAddress checks Thunder for transactions to specific address
func (e *SidechainMonitorEngine) findThunderTransactionToAddress(ctx context.Context, client *thunder.Client, address string, expectedAmount int64) string {
	return e.findTransactionToAddressViaUTXOs(ctx, func() (json.RawMessage, error) {
		return client.ListUTXOs(ctx)
	}, address, expectedAmount, "Thunder")
}

// findBitnamesTransactionToAddress checks BitNames for transactions to specific address
func (e *SidechainMonitorEngine) findBitnamesTransactionToAddress(ctx context.Context, client *bitnames.Client, address string, expectedAmount int64) string {
	return e.findTransactionToAddressViaUTXOs(ctx, func() (json.RawMessage, error) {
		return client.ListUTXOs(ctx)
	}, address, expectedAmount, "BitNames")
}

// findBitassetsTransactionToAddress checks BitAssets for transactions to specific address
func (e *SidechainMonitorEngine) findBitassetsTransactionToAddress(ctx context.Context, client *bitassets.Client, address string, expectedAmount int64) string {
	return e.findTransactionToAddressViaUTXOs(ctx, func() (json.RawMessage, error) {
		return client.ListUTXOs(ctx)
	}, address, expectedAmount, "BitAssets")
}

// findTruthcoinTransactionToAddress checks Truthcoin for transactions to specific address
func (e *SidechainMonitorEngine) findTruthcoinTransactionToAddress(ctx context.Context, client *truthcoin.Client, address string, expectedAmount int64) string {
	return e.findTransactionToAddressViaUTXOs(ctx, func() (json.RawMessage, error) {
		return client.ListUTXOs(ctx)
	}, address, expectedAmount, "Truthcoin")
}

// findPhotonTransactionToAddress checks Photon for transactions to specific address
func (e *SidechainMonitorEngine) findPhotonTransactionToAddress(ctx context.Context, client *photon.Client, address string, expectedAmount int64) string {
	return e.findTransactionToAddressViaUTXOs(ctx, func() (json.RawMessage, error) {
		return client.ListUTXOs(ctx)
	}, address, expectedAmount, "Photon")
}

// findCoinshiftTransactionToAddress checks CoinShift for transactions to specific address
func (e *SidechainMonitorEngine) findCoinshiftTransactionToAddress(ctx context.Context, client *coinshift.Client, address string, expectedAmount int64) string {
	return e.findTransactionToAddressViaUTXOs(ctx, func() (json.RawMessage, error) {
		return client.ListUTXOs(ctx)
	}, address, expectedAmount, "CoinShift")
}

// findTransactionToAddressViaUTXOs is a common helper for UTXO-based transaction detection
func (e *SidechainMonitorEngine) findTransactionToAddressViaUTXOs(
	ctx context.Context,
	getUTXOs func() (json.RawMessage, error),
	address string,
	expectedAmount int64,
	sidechainName string,
) string {
	log := zerolog.Ctx(ctx)

	// Get all UTXOs to check for transactions to our target address
	utxosRaw, err := getUTXOs()
	if err != nil {
		log.Debug().Err(err).Str("address", address).Str("sidechain", sidechainName).Msg("failed to get UTXOs")
		return ""
	}

	// Parse UTXOs JSON to find transactions to our address
	var utxos []map[string]interface{}
	if err := json.Unmarshal(utxosRaw, &utxos); err != nil {
		log.Debug().Err(err).Str("sidechain", sidechainName).Msg("failed to parse UTXOs")
		return ""
	}

	// Look for UTXOs at our target address with expected amount
	for _, utxo := range utxos {
		utxoAddress, ok := utxo["address"].(string)
		if !ok {
			continue
		}

		// Check if this UTXO is at our target address
		if utxoAddress == address {
			// Check amount (UTXOs typically store in sats)
			if amountFloat, ok := utxo["amount"].(float64); ok {
				amount := int64(amountFloat)
				if amount >= expectedAmount*95/100 { // Allow 5% tolerance for fees
					// Found matching transaction, extract txid
					if txid, ok := utxo["txid"].(string); ok {
						log.Info().
							Str("address", address).
							Str("txid", txid).
							Int64("amount", amount).
							Int64("expected", expectedAmount).
							Str("sidechain", sidechainName).
							Msg("found transaction to fast withdrawal address")
						return txid
					}
				}
			}
		}
	}

	return "" // No matching transaction found
}

// createSecureHTTPClient creates an HTTP client with security timeouts and limits
func createSecureHTTPClient() *http.Client {
	return &http.Client{
		Timeout: 30 * time.Second,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				MinVersion: tls.VersionTLS12,
			},
			MaxResponseHeaderBytes: 4096,
			ResponseHeaderTimeout:  10 * time.Second,
		},
	}
}

// validateWithdrawalHash validates the hash format from external servers
func validateWithdrawalHash(hash string) error {
	if len(hash) < 16 || len(hash) > 128 {
		return fmt.Errorf("invalid hash length: %d (must be 16-128)", len(hash))
	}

	// Allow alphanumeric, dashes, and underscores (common in hashes and IDs)
	matched, _ := regexp.MatchString(`^[a-zA-Z0-9\-_]+$`, hash)
	if !matched {
		return fmt.Errorf("invalid hash format: contains invalid characters")
	}

	return nil
}

// validateServerResponse validates the HTTP response from external servers
func validateServerResponse(resp *http.Response, result map[string]interface{}) error {
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("server returned HTTP status %d", resp.StatusCode)
	}

	status, ok := result["status"].(string)
	if !ok {
		return fmt.Errorf("response missing 'status' field")
	}

	if status != "success" {
		errorMsg, _ := result["error"].(string)
		if errorMsg == "" {
			errorMsg = "unknown error"
		}
		return fmt.Errorf("server error: %s", errorMsg)
	}

	return nil
}
