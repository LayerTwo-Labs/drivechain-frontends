package orchestrator

// WalletEngine manages the mapping between wallet.json wallets and Bitcoin Core wallets.
// Ported from bitwindow/server/engines/wallet_engine.go.
//
// Key responsibilities:
//   - Lazy-create Bitcoin Core wallets when first accessed (EnsureBitcoinCoreWallet)
//   - Lazy-create watch-only wallets (EnsureWatchOnlyWallet)
//   - Sync all wallets to Core after unlock (SyncWallets)
//   - Route operations by wallet type (GetWalletBackendType)

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
)

// WalletBackendType determines where wallet operations are routed.
type WalletBackendType string

const (
	WalletBackendEnforcer    WalletBackendType = "enforcer"
	WalletBackendBitcoinCore WalletBackendType = "bitcoinCore"
	WalletBackendWatchOnly   WalletBackendType = "watchOnly"
)

// WalletEngine manages the lifecycle of Bitcoin Core wallets created from wallet.json seeds.
type WalletEngine struct {
	mu sync.RWMutex

	// Maps walletID → Bitcoin Core wallet name (cache)
	coreWallets map[string]string

	// Dependencies
	walletSvc  *wallet.Service
	coreClient func() (*CoreStatusClient, error)
	network    string
	log        zerolog.Logger

	// Sync throttling
	lastSync time.Time
}

// NewWalletEngine creates a new WalletEngine.
func NewWalletEngine(
	walletSvc *wallet.Service,
	coreClient func() (*CoreStatusClient, error),
	network string,
	log zerolog.Logger,
) *WalletEngine {
	return &WalletEngine{
		coreWallets: make(map[string]string),
		walletSvc:   walletSvc,
		coreClient:  coreClient,
		network:     network,
		log:         log.With().Str("component", "wallet-engine").Logger(),
	}
}

// GetWalletBackendType returns the backend type for a wallet.
func (e *WalletEngine) GetWalletBackendType(walletID string) (WalletBackendType, error) {
	if walletID == "" {
		return "", fmt.Errorf("wallet_id required")
	}
	w := e.walletSvc.GetWalletByID(walletID)
	if w == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}
	switch w.WalletType {
	case "enforcer":
		return WalletBackendEnforcer, nil
	case "bitcoinCore":
		return WalletBackendBitcoinCore, nil
	case "watchOnly":
		return WalletBackendWatchOnly, nil
	default:
		return "", fmt.Errorf("unknown wallet type: %s", w.WalletType)
	}
}

// coreWalletNameForID returns the Bitcoin Core wallet name for a given walletID.
// Convention: "wallet_<first8hex>" matching bitwindow.
func coreWalletNameForID(walletID string) string {
	id := walletID
	if len(id) > 8 {
		id = id[:8]
	}
	return fmt.Sprintf("wallet_%s", id)
}

// watchWalletNameForID returns the watch-only wallet name for a given walletID.
func watchWalletNameForID(walletID string) string {
	id := walletID
	if len(id) > 8 {
		id = id[:8]
	}
	return fmt.Sprintf("watch_%s", id)
}

// EnsureBitcoinCoreWallet ensures a Bitcoin Core wallet exists for walletID.
// Creates it from the seed if it doesn't exist (lazy loading). Returns the Core wallet name.
func (e *WalletEngine) EnsureBitcoinCoreWallet(ctx context.Context, walletID string) (string, error) {
	// Check cache first (read lock)
	e.mu.RLock()
	if name, ok := e.coreWallets[walletID]; ok {
		e.mu.RUnlock()
		return name, nil
	}
	e.mu.RUnlock()

	// Upgrade to write lock
	e.mu.Lock()
	defer e.mu.Unlock()

	// Double-check after lock upgrade
	if name, ok := e.coreWallets[walletID]; ok {
		return name, nil
	}

	// Validate wallet type
	w := e.walletSvc.GetWalletByID(walletID)
	if w == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}
	if w.WalletType != "bitcoinCore" {
		return "", fmt.Errorf("wallet %s is type %s, not bitcoinCore", walletID, w.WalletType)
	}
	if w.Master.SeedHex == "" {
		return "", fmt.Errorf("wallet %s has no seed", walletID)
	}

	coreWalletName := coreWalletNameForID(walletID)

	client, err := e.coreClient()
	if err != nil {
		return "", fmt.Errorf("get core client: %w", err)
	}

	// Check if wallet already exists in Core
	wallets, err := client.ListWallets(ctx)
	if err != nil {
		return "", fmt.Errorf("list wallets: %w", err)
	}

	walletExists := false
	for _, name := range wallets {
		if name == coreWalletName {
			walletExists = true
			break
		}
	}

	if !walletExists {
		e.log.Info().
			Str("wallet_id", walletID).
			Str("core_name", coreWalletName).
			Msg("creating missing Bitcoin Core wallet from seed")

		if err := client.CreateBitcoinCoreWalletFromSeed(ctx, coreWalletName, w.Master.SeedHex, e.network); err != nil {
			return "", fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}

		e.log.Info().
			Str("wallet_id", walletID).
			Str("core_name", coreWalletName).
			Msg("created Bitcoin Core wallet from seed")
	}

	// Cache the mapping
	e.coreWallets[walletID] = coreWalletName
	return coreWalletName, nil
}

// EnsureWatchOnlyWallet ensures a watch-only wallet exists for walletID.
// Creates it if it doesn't exist (lazy loading). Returns the Core wallet name.
func (e *WalletEngine) EnsureWatchOnlyWallet(ctx context.Context, walletID string) (string, error) {
	// Check cache first
	e.mu.RLock()
	if name, ok := e.coreWallets[walletID]; ok {
		e.mu.RUnlock()
		return name, nil
	}
	e.mu.RUnlock()

	e.mu.Lock()
	defer e.mu.Unlock()

	// Double-check
	if name, ok := e.coreWallets[walletID]; ok {
		return name, nil
	}

	w := e.walletSvc.GetWalletByID(walletID)
	if w == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}
	if w.WalletType != "watchOnly" {
		return "", fmt.Errorf("wallet %s is type %s, not watchOnly", walletID, w.WalletType)
	}
	if len(w.WatchOnly) == 0 {
		return "", fmt.Errorf("wallet %s has no watch_only data", walletID)
	}

	// Parse watch_only to get descriptor or xpub
	var watchOnly struct {
		Descriptor string `json:"descriptor"`
		Xpub       string `json:"xpub"`
	}
	if err := json.Unmarshal(w.WatchOnly, &watchOnly); err != nil {
		return "", fmt.Errorf("parse watch_only: %w", err)
	}

	descriptorOrXpub := watchOnly.Descriptor
	if descriptorOrXpub == "" {
		descriptorOrXpub = watchOnly.Xpub
	}
	if descriptorOrXpub == "" {
		return "", fmt.Errorf("wallet %s watch_only has no descriptor or xpub", walletID)
	}

	watchWalletName := watchWalletNameForID(walletID)

	client, err := e.coreClient()
	if err != nil {
		return "", fmt.Errorf("get core client: %w", err)
	}

	wallets, err := client.ListWallets(ctx)
	if err != nil {
		return "", fmt.Errorf("list wallets: %w", err)
	}

	walletExists := false
	for _, name := range wallets {
		if name == watchWalletName {
			walletExists = true
			break
		}
	}

	if !walletExists {
		e.log.Info().
			Str("wallet_id", walletID).
			Str("core_name", watchWalletName).
			Msg("creating watch-only wallet in Bitcoin Core")

		if err := client.CreateWatchOnlyWalletInCore(ctx, watchWalletName, descriptorOrXpub); err != nil {
			return "", fmt.Errorf("create watch-only wallet: %w", err)
		}

		e.log.Info().
			Str("wallet_id", walletID).
			Str("core_name", watchWalletName).
			Msg("created watch-only wallet in Bitcoin Core")
	}

	e.coreWallets[walletID] = watchWalletName
	return watchWalletName, nil
}

// GetCoreWalletName returns the Bitcoin Core wallet name for a walletID.
// Calls EnsureBitcoinCoreWallet to lazy-create if needed.
func (e *WalletEngine) GetCoreWalletName(ctx context.Context, walletID string) (string, error) {
	backendType, err := e.GetWalletBackendType(walletID)
	if err != nil {
		return "", err
	}

	switch backendType {
	case WalletBackendBitcoinCore:
		return e.EnsureBitcoinCoreWallet(ctx, walletID)
	case WalletBackendWatchOnly:
		return e.EnsureWatchOnlyWallet(ctx, walletID)
	default:
		return "", fmt.Errorf("wallet %s (type %s) does not map to a Bitcoin Core wallet", walletID, backendType)
	}
}

// SyncWallets ensures all bitcoinCore wallets in wallet.json exist in Bitcoin Core.
// Called after wallet unlock. Errors are logged but do not fail the sync.
func (e *WalletEngine) SyncWallets(ctx context.Context) error {
	// Throttle syncs to once per 5 seconds
	e.mu.Lock()
	if time.Since(e.lastSync) < 5*time.Second {
		e.mu.Unlock()
		e.log.Debug().Msg("wallet sync: throttled, skipping")
		return nil
	}
	e.lastSync = time.Now()
	e.mu.Unlock()

	e.log.Info().Msg("wallet sync: starting")

	wallets := e.walletSvc.ListWallets()
	if len(wallets) == 0 {
		e.log.Info().Msg("wallet sync: no wallets to sync")
		return nil
	}

	client, err := e.coreClient()
	if err != nil {
		return fmt.Errorf("get core client: %w", err)
	}

	// List existing Core wallets
	coreWallets, err := client.ListWallets(ctx)
	if err != nil {
		return fmt.Errorf("list core wallets: %w", err)
	}

	coreWalletSet := make(map[string]bool)
	for _, name := range coreWallets {
		coreWalletSet[name] = true
	}

	var syncErrors []string

	for _, w := range wallets {
		switch w.WalletType {
		case "bitcoinCore":
			coreName := coreWalletNameForID(w.ID)
			if coreWalletSet[coreName] {
				// Already exists, cache it
				e.mu.Lock()
				e.coreWallets[w.ID] = coreName
				e.mu.Unlock()
				continue
			}

			// Need to create it
			fullWallet := e.walletSvc.GetWalletByID(w.ID)
			if fullWallet == nil || fullWallet.Master.SeedHex == "" {
				syncErrors = append(syncErrors, fmt.Sprintf("wallet %s: no seed available", w.ID))
				continue
			}

			e.log.Info().
				Str("wallet_id", w.ID).
				Str("core_name", coreName).
				Msg("wallet sync: creating missing Bitcoin Core wallet")

			if err := client.CreateBitcoinCoreWalletFromSeed(ctx, coreName, fullWallet.Master.SeedHex, e.network); err != nil {
				syncErrors = append(syncErrors, fmt.Sprintf("wallet %s: %v", w.ID, err))
				continue
			}

			e.mu.Lock()
			e.coreWallets[w.ID] = coreName
			e.mu.Unlock()

			e.log.Info().
				Str("wallet_id", w.ID).
				Str("core_name", coreName).
				Msg("wallet sync: created Bitcoin Core wallet")

		case "watchOnly":
			coreName := watchWalletNameForID(w.ID)
			if coreWalletSet[coreName] {
				e.mu.Lock()
				e.coreWallets[w.ID] = coreName
				e.mu.Unlock()
				continue
			}
			// Watch-only wallets are created lazily on first access
			// We don't force-create them during sync
		}
	}

	if len(syncErrors) > 0 {
		return fmt.Errorf("sync errors: %s", strings.Join(syncErrors, "; "))
	}

	e.log.Info().Msg("wallet sync: completed")
	return nil
}

// ClearCache clears the Core wallet name cache. Called on wallet delete/wipe.
func (e *WalletEngine) ClearCache() {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.coreWallets = make(map[string]string)
}

// --- Balance/Transaction helpers ---

// GetBalance returns the balance for a wallet, routing to the correct backend.
func (e *WalletEngine) GetBalance(ctx context.Context, walletID string) (confirmedSats, pendingSats uint64, err error) {
	backendType, err := e.GetWalletBackendType(walletID)
	if err != nil {
		return 0, 0, err
	}

	switch backendType {
	case WalletBackendEnforcer:
		// Enforcer balance is handled by the caller via enforcer RPC
		return 0, 0, fmt.Errorf("use enforcer RPC for enforcer wallet balance")

	case WalletBackendBitcoinCore:
		coreName, err := e.EnsureBitcoinCoreWallet(ctx, walletID)
		if err != nil {
			return 0, 0, err
		}
		client, err := e.coreClient()
		if err != nil {
			return 0, 0, err
		}
		balances, err := client.GetBalances(ctx, coreName)
		if err != nil {
			return 0, 0, fmt.Errorf("get balances: %w", err)
		}
		return uint64(balances.Mine.Trusted * 1e8), uint64(balances.Mine.UntrustedPending * 1e8), nil

	case WalletBackendWatchOnly:
		coreName, err := e.EnsureWatchOnlyWallet(ctx, walletID)
		if err != nil {
			return 0, 0, err
		}
		client, err := e.coreClient()
		if err != nil {
			return 0, 0, err
		}
		balances, err := client.GetBalances(ctx, coreName)
		if err != nil {
			return 0, 0, fmt.Errorf("get balances: %w", err)
		}
		if balances.Watchonly != nil {
			return uint64(balances.Watchonly.Trusted * 1e8), uint64(balances.Watchonly.UntrustedPending * 1e8), nil
		}
		return uint64(balances.Mine.Trusted * 1e8), uint64(balances.Mine.UntrustedPending * 1e8), nil

	default:
		return 0, 0, fmt.Errorf("unknown wallet type: %s", backendType)
	}
}

// GetNewCoreAddress gets a new address from Bitcoin Core for the given wallet.
func (e *WalletEngine) GetNewCoreAddress(ctx context.Context, walletID string) (string, error) {
	coreName, err := e.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	client, err := e.coreClient()
	if err != nil {
		return "", err
	}
	return client.GetNewAddress(ctx, coreName)
}

// ListCoreTransactions lists transactions for a Bitcoin Core wallet.
func (e *WalletEngine) ListCoreTransactions(ctx context.Context, walletID string, count int) ([]CoreTransaction, error) {
	coreName, err := e.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	client, err := e.coreClient()
	if err != nil {
		return nil, err
	}
	return client.ListTransactionsWallet(ctx, coreName, count)
}

// ListCoreUnspent lists UTXOs for a Bitcoin Core wallet.
func (e *WalletEngine) ListCoreUnspent(ctx context.Context, walletID string) ([]CoreUnspent, error) {
	coreName, err := e.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	client, err := e.coreClient()
	if err != nil {
		return nil, err
	}
	return client.ListUnspentWallet(ctx, coreName)
}

// SendFromCoreWallet sends BTC from a Bitcoin Core wallet.
func (e *WalletEngine) SendFromCoreWallet(ctx context.Context, walletID string, destinations map[string]float64, feeRate float64) (string, error) {
	coreName, err := e.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	client, err := e.coreClient()
	if err != nil {
		return "", err
	}
	return client.Send(ctx, coreName, destinations, feeRate)
}

// BumpCoreFee bumps the fee for a transaction in a Bitcoin Core wallet.
func (e *WalletEngine) BumpCoreFee(ctx context.Context, walletID, txid string) (*BumpFeeResult, error) {
	coreName, err := e.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	client, err := e.coreClient()
	if err != nil {
		return nil, err
	}
	return client.BumpFee(ctx, coreName, txid)
}
