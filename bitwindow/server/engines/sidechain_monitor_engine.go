package engines

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"regexp"
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

type DetectedWithdrawal struct {
	Txid        string    `json:"txid"`
	Sidechain   string    `json:"sidechain"`
	Amount      int64     `json:"amount"`
	Destination string    `json:"destination"`
	DetectedAt  time.Time `json:"detected_at"`
	BlockHash   *string   `json:"block_hash,omitempty"`
}

type PendingFastWithdrawal struct {
	Hash           string    `json:"hash"`            // Withdrawal hash from server
	Sidechain      string    `json:"sidechain"`       // Which sidechain
	ServerAddress  string    `json:"server_address"`  // L2 address to send to
	ExpectedAmount int64     `json:"expected_amount"` // Amount expected (sats)
	ServerURL      string    `json:"server_url"`      // Fast withdrawal server URL
	CreatedAt      time.Time `json:"created_at"`
}

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

// RegisterPendingFastWithdrawal adds a pending fast withdrawal to monitor for
func (e *SidechainMonitorEngine) RegisterPendingFastWithdrawal(ctx context.Context, withdrawal PendingFastWithdrawal) {
	e.mu.Lock()
	defer e.mu.Unlock()

	e.pendingFastWithdrawals[withdrawal.Hash] = withdrawal

	zerolog.Ctx(ctx).Info().
		Str("hash", withdrawal.Hash).
		Str("sidechain", withdrawal.Sidechain).
		Str("address", withdrawal.ServerAddress).
		Int64("amount", withdrawal.ExpectedAmount).
		Msg("registered pending fast withdrawal for monitoring")
}

func (e *SidechainMonitorEngine) GetPendingFastWithdrawals(ctx context.Context) ([]PendingFastWithdrawal, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	return lo.Values(e.pendingFastWithdrawals), nil
}

type withdrawResponse struct {
	Status string `json:"status"`
	Error  string `json:"error"`
	Data   *struct {
		Hash            string `json:"hash"`
		ServerL2Address *struct {
			Info string `json:"info"`
		} `json:"server_l2_address"`
		ServerFeeSats *int64 `json:"server_fee_sats"`
	} `json:"data"`
}

// InitiateFastWithdrawal asks the fast withdrawal server at serverURL to pay
// destination, and registers the withdrawal for payment. It returns the withdrawal hash.
func (e *SidechainMonitorEngine) InitiateFastWithdrawal(ctx context.Context, serverURL string, sidechain string, amount int64, destination string) (string, error) {
	log := zerolog.Ctx(ctx)

	// Call external fast withdrawal server (like fw1.drivechain.info)
	withdrawalRequest := map[string]interface{}{
		"withdrawal_destination": destination,
		"withdrawal_amount":      float64(amount) / 100000000.0, // Convert sats to BTC
		"layer_2_chain_name":     sidechain,
	}

	log.Info().Interface("request", withdrawalRequest).Str("server", serverURL).Msg("requesting fast withdrawal from external server")

	// Make actual HTTP call to external server
	jsonPayload, err := json.Marshal(withdrawalRequest)
	if err != nil {
		return "", fmt.Errorf("marshal request: %w", err)
	}

	withdrawURL := serverURL + "/withdraw"
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, withdrawURL, bytes.NewBuffer(jsonPayload))
	if err != nil {
		return "", fmt.Errorf("build request to %s: %w", withdrawURL, err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	resp, err := e.httpClient.Do(httpReq)
	if err != nil {
		return "", fmt.Errorf("http request to %s: %w", withdrawURL, err)
	}
	defer resp.Body.Close()

	var result withdrawResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", fmt.Errorf("decode response: %w", err)
	}

	if result.Status != "success" {
		return "", fmt.Errorf("withdrawal request failed: %s", result.Error)
	}

	data := result.Data
	if data == nil {
		return "", errors.New("invalid response format: missing data")
	}
	if data.Hash == "" {
		return "", errors.New("invalid response format: missing hash")
	}
	if data.ServerL2Address == nil {
		return "", errors.New("invalid response format: missing server_l2_address")
	}
	if data.ServerL2Address.Info == "" {
		return "", errors.New("invalid response format: missing server L2 address info")
	}
	if data.ServerFeeSats == nil {
		return "", errors.New("invalid response format: missing server_fee_sats")
	}
	withdrawalHash := data.Hash
	serverAddress := data.ServerL2Address.Info
	serverFeeSats := *data.ServerFeeSats

	// Register this pending withdrawal for monitoring
	pending := PendingFastWithdrawal{
		Hash:           withdrawalHash,
		Sidechain:      sidechain,
		ServerAddress:  serverAddress,
		ExpectedAmount: amount + serverFeeSats,
		ServerURL:      serverURL,
		CreatedAt:      time.Now(),
	}

	e.RegisterPendingFastWithdrawal(ctx, pending)

	return withdrawalHash, nil
}

// checkFastWithdrawalPayments checks if any pending fast withdrawals have been paid
func (e *SidechainMonitorEngine) checkFastWithdrawalPayments(ctx context.Context, sidechain string, client sidechainRPC) error {
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

	for _, pending := range pendingForSidechain {
		txid, err := e.findTransactionToAddress(ctx, client, pending.ServerAddress, pending.ExpectedAmount, sidechain)
		if err != nil {
			return fmt.Errorf("find payment for withdrawal %s: %w", pending.Hash, err)
		}
		if txid != "" {
			log.Info().
				Str("hash", pending.Hash).
				Str("txid", txid).
				Str("address", pending.ServerAddress).
				Msg("detected L2 payment for fast withdrawal, auto-completing")

			// Auto-complete the withdrawal
			if err := e.completeWithdrawal(ctx, pending, txid); err != nil {
				log.Error().Err(err).Str("hash", pending.Hash).Msg("auto-complete withdrawal")
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
	e.notificationEngine.Broadcast(ctx, event)

	log.Info().
		Str("txid", withdrawal.Txid).
		Str("sidechain", withdrawal.Sidechain).
		Int64("amount", withdrawal.Amount).
		Msg("detected fast withdrawal transaction")
}

// sidechainRPC is the part of a sidechain client that the monitor reads.
type sidechainRPC interface {
	PendingWithdrawalBundle(ctx context.Context) (json.RawMessage, error)
	ListUTXOs(ctx context.Context) (json.RawMessage, error)
}

func rpcOf[C sidechainRPC](s *service.Service[C]) func(context.Context) (sidechainRPC, error) {
	return func(ctx context.Context) (sidechainRPC, error) {
		return s.Get(ctx)
	}
}

// monitor reads the pending withdrawal bundle of one sidechain and checks the
// pending fast withdrawals for a payment.
func (e *SidechainMonitorEngine) monitor(ctx context.Context, name string, getClient func(context.Context) (sidechainRPC, error)) error {
	client, err := getClient(ctx)
	if err != nil {
		return fmt.Errorf("get %s client: %w", name, err)
	}

	bundleRaw, err := client.PendingWithdrawalBundle(ctx)
	if err != nil {
		return fmt.Errorf("get pending withdrawal bundle: %w", err)
	}

	if err := e.parseWithdrawalBundle(ctx, bundleRaw, name); err != nil {
		return err
	}

	if err := e.checkFastWithdrawalPayments(ctx, name, client); err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("check fast withdrawal payments")
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

	return nil
}

// findTransactionToAddress returns the txid of a UTXO at address that pays at
// least 95% of expectedAmount, or "" when there is none.
func (e *SidechainMonitorEngine) findTransactionToAddress(
	ctx context.Context,
	client sidechainRPC,
	address string,
	expectedAmount int64,
	sidechainName string,
) (string, error) {
	log := zerolog.Ctx(ctx)

	utxosRaw, err := client.ListUTXOs(ctx)
	if err != nil {
		return "", fmt.Errorf("list UTXOs: %w", err)
	}

	var utxos []map[string]interface{}
	if err := json.Unmarshal(utxosRaw, &utxos); err != nil {
		return "", fmt.Errorf("parse UTXOs: %w", err)
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
						return txid, nil
					}
				}
			}
		}
	}

	return "", nil
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
		return errors.New("invalid hash format: contains invalid characters")
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
		return errors.New("response missing 'status' field")
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
