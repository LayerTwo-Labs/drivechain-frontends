package engines

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/wallet"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
)

// WalletType represents the type of wallet backend
type WalletType string

const (
	WalletTypeEnforcer    WalletType = "enforcer"
	WalletTypeBitcoinCore WalletType = "bitcoinCore"
	WalletTypeWatchOnly   WalletType = "watchOnly"
)

// WalletInfo contains information about a wallet from wallet.json
type WalletInfo struct {
	ID         string     `json:"id"`
	Name       string     `json:"name"`
	WalletType WalletType `json:"wallet_type"`
	Master     struct {
		SeedHex string `json:"seed_hex"`
	} `json:"master"`
	L1 struct {
		Mnemonic string `json:"mnemonic"`
	} `json:"l1"`
	WatchOnly *struct {
		Descriptor string `json:"descriptor"`
		Xpub       string `json:"xpub"`
	} `json:"watch_only,omitempty"`
}

// WalletEngine handles wallet unlock/lock, backend routing, and Bitcoin Core sync
type WalletEngine struct {
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error)
	enforcerConnector func(context.Context) (validatorrpc.WalletServiceClient, error)
	walletDir         string
	chainParams       *chaincfg.Params

	// Unlocked wallet state (in memory)
	mu             sync.RWMutex
	seedHex        string
	activeWalletId string
	isUnlocked     bool
	unlockCond     *sync.Cond

	// Maps walletId -> Bitcoin Core wallet name (cache)
	coreWallets map[string]string

	// Cached wallet metadata (populated during unlock for encrypted wallets)
	walletCache map[string]*WalletInfo

	// Sync throttling
	lastSync time.Time
}

// NewWalletEngine creates a new unified wallet engine
func NewWalletEngine(
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error),
	enforcerConnector func(context.Context) (validatorrpc.WalletServiceClient, error),
	walletDir string,
	chainParams *chaincfg.Params,
) *WalletEngine {
	e := &WalletEngine{
		bitcoindConnector: bitcoindConnector,
		enforcerConnector: enforcerConnector,
		walletDir:         walletDir,
		chainParams:       chainParams,
		isUnlocked:        false,
		coreWallets:       make(map[string]string),
		walletCache:       make(map[string]*WalletInfo),
	}
	e.unlockCond = sync.NewCond(&e.mu)

	// Auto-unlock unencrypted wallets at startup
	if !wallet.IsWalletEncrypted(walletDir) {
		walletData, err := wallet.LoadUnencryptedWallet(walletDir)
		if err == nil {
			if unlockErr := e.Unlock(walletData); unlockErr != nil {
				zerolog.Ctx(context.Background()).Warn().Err(unlockErr).Msg("failed to unlock wallet engine")
			}
		}
	}

	return e
}

// ============================================================================
// Unlock/Lock/State Management
// ============================================================================

// Unlock loads the seed into memory from decrypted wallet data
func (e *WalletEngine) Unlock(walletData map[string]any) error {
	e.mu.Lock()
	defer e.mu.Unlock()

	// Handle multi-wallet structure: { version, activeWalletId, wallets: [...] }
	wallets, ok := walletData["wallets"].([]any)
	if !ok {
		return errors.New("invalid wallet structure: missing wallets array")
	}

	if len(wallets) == 0 {
		return errors.New("no wallets found in wallet.json")
	}

	// Get activeWalletId if present
	activeWalletId, _ := walletData["activeWalletId"].(string)

	// Find active wallet
	var activeWallet map[string]any
	var firstWallet map[string]any
	var firstWalletId string
	var enforcerWallet map[string]any
	var enforcerWalletId string

	for _, w := range wallets {
		wallet, ok := w.(map[string]any)
		if !ok {
			continue
		}

		walletId, _ := wallet["id"].(string)
		walletType, _ := wallet["wallet_type"].(string)

		// Track first wallet as fallback
		if firstWallet == nil {
			firstWallet = wallet
			firstWalletId = walletId
		}

		// Track enforcer wallet as preferred fallback
		if walletType == "enforcer" {
			enforcerWallet = wallet
			enforcerWalletId = walletId
		}

		// If activeWalletId is set, use that specific wallet
		if activeWalletId != "" && walletId == activeWalletId {
			activeWallet = wallet
			break
		}
	}

	// Select wallet in order of preference:
	// 1. Explicitly set activeWalletId
	// 2. Enforcer wallet (if exists)
	// 3. First wallet in list
	if activeWallet != nil {
		// Already found by activeWalletId
	} else if enforcerWallet != nil {
		activeWallet = enforcerWallet
		activeWalletId = enforcerWalletId
	} else if firstWallet != nil {
		activeWallet = firstWallet
		activeWalletId = firstWalletId
	}

	if activeWallet == nil {
		return errors.New("no wallets found in wallets array")
	}

	// Extract master seed from active wallet
	master, ok := activeWallet["master"].(map[string]any)
	if !ok {
		return errors.New("invalid wallet structure: missing master key")
	}

	seedHex, ok := master["seed_hex"].(string)
	if !ok || seedHex == "" {
		return errors.New("invalid wallet structure: missing or empty seed_hex")
	}

	// Validate seed hex
	if _, err := hex.DecodeString(seedHex); err != nil {
		return fmt.Errorf("invalid seed hex: %w", err)
	}

	// Cache all wallet metadata for encrypted wallets
	e.walletCache = make(map[string]*WalletInfo)
	for _, w := range wallets {
		walletMap, ok := w.(map[string]any)
		if !ok {
			continue
		}

		// Parse wallet info
		walletBytes, err := json.Marshal(walletMap)
		if err != nil {
			continue
		}

		var walletInfo WalletInfo
		if err := json.Unmarshal(walletBytes, &walletInfo); err != nil {
			continue
		}

		e.walletCache[walletInfo.ID] = &walletInfo
	}

	e.seedHex = seedHex
	e.activeWalletId = activeWalletId
	e.isUnlocked = true
	e.unlockCond.Broadcast()
	return nil
}

// Lock clears the seed from memory
func (e *WalletEngine) Lock() {
	e.mu.Lock()
	defer e.mu.Unlock()

	// Zero out the seed for security
	if e.seedHex != "" {
		zeros := make([]byte, len(e.seedHex))
		e.seedHex = string(zeros)
	}
	e.seedHex = ""
	e.activeWalletId = ""
	e.isUnlocked = false
	e.walletCache = make(map[string]*WalletInfo)
}

// IsUnlocked returns whether the engine is unlocked
func (e *WalletEngine) IsUnlocked() bool {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.isUnlocked
}

// GetEnforcerSeed returns the enforcer wallet's seed hex
// Used by ChequeEngine for deriving cheque addresses
func (e *WalletEngine) GetEnforcerSeed() (string, error) {
	wallets, err := e.loadAllWallets()
	if err != nil {
		return "", fmt.Errorf("load wallets: %w", err)
	}

	// Find enforcer wallet
	enforcerWallets := lo.Filter(wallets, func(w WalletInfo, _ int) bool {
		return w.WalletType == WalletTypeEnforcer
	})

	if len(enforcerWallets) == 0 {
		return "", errors.New("no enforcer wallet found")
	}

	if enforcerWallets[0].Master.SeedHex == "" {
		return "", errors.New("enforcer wallet has no seed")
	}

	return enforcerWallets[0].Master.SeedHex, nil
}

// GetActiveWallet returns the active wallet
// If the wallet is encrypted, it uses the unlocked data from memory
// If the wallet is unencrypted, it reads directly from wallet.json
func (e *WalletEngine) GetActiveWallet(ctx context.Context) (*WalletInfo, error) {
	var activeWalletId string

	// Check if wallet is encrypted
	if wallet.IsWalletEncrypted(e.walletDir) {
		// For encrypted wallets, use the active wallet ID stored in memory
		e.mu.RLock()
		if !e.isUnlocked {
			e.mu.RUnlock()
			return nil, errors.New("wallet is encrypted and locked")
		}
		activeWalletId = e.activeWalletId
		e.mu.RUnlock()
	} else {
		// For unencrypted wallets, read directly from wallet.json
		walletData, err := wallet.LoadUnencryptedWallet(e.walletDir)
		if err != nil {
			return nil, fmt.Errorf("load wallet.json: %w", err)
		}

		id, ok := walletData["activeWalletId"].(string)
		if !ok || id == "" {
			return nil, fmt.Errorf("no active wallet ID found in wallet.json")
		}
		activeWalletId = id
	}

	return e.GetWalletInfo(ctx, activeWalletId)
}

// ============================================================================
// Wallet Info & Backend Routing
// ============================================================================

// GetChainParams returns the chain parameters for this wallet engine
func (e *WalletEngine) GetChainParams() *chaincfg.Params {
	return e.chainParams
}

// GetWalletInfo reads wallet.json and returns info for the specified walletId
func (e *WalletEngine) GetWalletInfo(ctx context.Context, walletId string) (*WalletInfo, error) {
	// Check if wallet is encrypted
	if wallet.IsWalletEncrypted(e.walletDir) {
		// For encrypted wallets, use the cache populated during unlock
		e.mu.RLock()
		defer e.mu.RUnlock()

		if !e.isUnlocked {
			return nil, errors.New("wallet is encrypted and locked")
		}

		walletInfo, exists := e.walletCache[walletId]
		if !exists {
			return nil, fmt.Errorf("wallet %s not found in cache", walletId)
		}

		return walletInfo, nil
	}

	// For unencrypted wallets, read from file
	walletFile := filepath.Join(e.walletDir, "wallet.json")

	data, err := os.ReadFile(walletFile)
	if err != nil {
		return nil, fmt.Errorf("read wallet.json: %w", err)
	}

	var walletData struct {
		Version        int          `json:"version"`
		ActiveWalletId string       `json:"activeWalletId"`
		Wallets        []WalletInfo `json:"wallets"`
	}

	if err := json.Unmarshal(data, &walletData); err != nil {
		return nil, fmt.Errorf("parse wallet.json: %w", err)
	}

	walletInfo := lo.Filter(walletData.Wallets, func(w WalletInfo, _ int) bool {
		return w.ID == walletId
	})

	if len(walletInfo) == 0 {
		return nil, fmt.Errorf("wallet %s not found", walletId)
	}

	return &walletInfo[0], nil
}

// GetActiveWalletInfo returns the WalletInfo for the currently active wallet
// This is an alias for GetActiveWallet for backwards compatibility
func (e *WalletEngine) GetActiveWalletInfo(ctx context.Context) (*WalletInfo, error) {
	return e.GetActiveWallet(ctx)
}

// GetWalletBackendType returns the backend type for a wallet
func (e *WalletEngine) GetWalletBackendType(ctx context.Context, walletId string) (WalletType, error) {
	if walletId == "" {
		return "", fmt.Errorf("wallet_id required")
	}
	wallet, err := e.GetWalletInfo(ctx, walletId)
	if err != nil {
		return "", err
	}
	return wallet.WalletType, nil
}

// ============================================================================
// Bitcoin Core Wallet Management
// ============================================================================

// EnsureBitcoinCoreWallet ensures a Bitcoin Core wallet exists for the given walletId
// Creates it from the seed if it doesn't exist (lazy loading)
func (e *WalletEngine) EnsureBitcoinCoreWallet(ctx context.Context, walletId string) (string, error) {
	e.mu.Lock()
	defer e.mu.Unlock()

	// Check cache
	if walletName, exists := e.coreWallets[walletId]; exists {
		return walletName, nil
	}

	// Get wallet info
	wallet, err := e.GetWalletInfo(ctx, walletId)
	if err != nil {
		return "", err
	}

	if wallet.WalletType != WalletTypeBitcoinCore {
		return "", fmt.Errorf("wallet %s is not a Bitcoin Core wallet", walletId)
	}

	// Generate wallet name from wallet ID
	walletName := fmt.Sprintf("wallet_%s", walletId[:8])

	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return "", fmt.Errorf("get bitcoind client: %w", err)
	}

	// Check if wallet already exists in Bitcoin Core
	listResp, err := bitcoindClient.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return "", fmt.Errorf("list Bitcoin Core wallets: %w", err)
	}

	walletExists := lo.Contains(listResp.Msg.Wallets, walletName)
	if !walletExists {
		// Create wallet from seed
		if err := e.CreateBitcoinCoreWalletFromSeed(ctx, walletName, wallet.Master.SeedHex); err != nil {
			return "", fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}
		zerolog.Ctx(ctx).Info().
			Str("wallet_id", walletId).
			Str("wallet_name", walletName).
			Msg("created Bitcoin Core wallet from seed")
	}

	// Cache the mapping
	e.coreWallets[walletId] = walletName
	return walletName, nil
}

// CreateBitcoinCoreWalletFromSeed creates a Bitcoin Core wallet and imports the seed
func (e *WalletEngine) CreateBitcoinCoreWalletFromSeed(
	ctx context.Context,
	walletName string,
	seedHex string,
) error {
	// Decode seed
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return fmt.Errorf("decode seed hex: %w", err)
	}

	// Derive master key
	masterKey, err := hdkeychain.NewMaster(seed, e.chainParams)
	if err != nil {
		return fmt.Errorf("derive master key: %w", err)
	}

	// Derive to BIP84 account level: m/84'/0'/0'
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
	if err != nil {
		return fmt.Errorf("derive purpose: %w", err)
	}

	// Coin type: 0' for mainnet, 1' for testnet/signet
	coinType := uint32(0)
	if e.chainParams.Name != "mainnet" {
		coinType = 1
	}
	coin, err := purpose.Derive(hdkeychain.HardenedKeyStart + coinType)
	if err != nil {
		return fmt.Errorf("derive coin type: %w", err)
	}

	// Account: 0'
	account, err := coin.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		return fmt.Errorf("derive account: %w", err)
	}

	// Get the xprv string for the account
	accountXprv := account.String()

	// Compute master fingerprint for key origin info
	pubKey, err := masterKey.ECPubKey()
	if err != nil {
		return fmt.Errorf("get master public key: %w", err)
	}
	hash160 := btcutil.Hash160(pubKey.SerializeCompressed())
	fingerprint := hex.EncodeToString(hash160[:4])

	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return fmt.Errorf("get bitcoind client: %w", err)
	}

	// Create descriptor wallet in Bitcoin Core
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               walletName,
		DisablePrivateKeys: false,
		Blank:              true,
		Passphrase:         "",
		AvoidReuse:         false,
	}))
	if err != nil {
		// If wallet already exists on disk, load it instead
		if strings.Contains(err.Error(), "Database already exists") {
			zerolog.Ctx(ctx).Info().
				Str("wallet_name", walletName).
				Msg("Bitcoin Core wallet already exists on disk, loading it")

			_, err = bitcoindClient.LoadWallet(ctx, connect.NewRequest(&corepb.LoadWalletRequest{
				Filename:      walletName,
				LoadOnStartup: true,
			}))
			if err != nil {
				return fmt.Errorf("load Bitcoin Core wallet: %w", err)
			}
		} else {
			return fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}
	}

	// Import descriptors for receiving and change addresses with key origin info
	descriptors := []struct {
		desc     string
		internal bool
	}{
		{fmt.Sprintf("wpkh([%s/84'/%d'/0']%s/0/*)", fingerprint, coinType, accountXprv), false}, // Receiving
		{fmt.Sprintf("wpkh([%s/84'/%d'/0']%s/1/*)", fingerprint, coinType, accountXprv), true},  // Change
	}

	var requests []*corepb.ImportDescriptorsRequest_Request
	for _, d := range descriptors {
		descriptorWithChecksum, err := AddDescriptorChecksum(d.desc)
		if err != nil {
			return fmt.Errorf("compute descriptor checksum: %w", err)
		}

		requests = append(requests, &corepb.ImportDescriptorsRequest_Request{
			Descriptor_: descriptorWithChecksum,
			Active:      true,
			Timestamp:   nil,
			Internal:    d.internal,
			RangeEnd:    999,
		})
	}

	resp, err := bitcoindClient.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet:   walletName,
		Requests: requests,
	}))
	if err != nil {
		return fmt.Errorf("import descriptors: %w", err)
	}

	// Check results
	for i, result := range resp.Msg.Responses {
		if !result.Success {
			errMsg := "unknown error"
			if result.Error != nil {
				errMsg = result.Error.Message
			}
			return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
		}
	}

	return nil
}

// GetBitcoinCoreWalletName returns the Bitcoin Core wallet name for a walletId
func (e *WalletEngine) GetBitcoinCoreWalletName(ctx context.Context, walletId string) (string, error) {
	return e.EnsureBitcoinCoreWallet(ctx, walletId)
}

// EnsureWatchOnlyWallet ensures a watch-only wallet exists in Bitcoin Core
func (e *WalletEngine) EnsureWatchOnlyWallet(ctx context.Context, walletId string) (string, error) {
	e.mu.Lock()
	defer e.mu.Unlock()

	// Check cache
	if walletName, exists := e.coreWallets[walletId]; exists {
		return walletName, nil
	}

	// Get wallet info
	wallet, err := e.GetWalletInfo(ctx, walletId)
	if err != nil {
		return "", err
	}

	if wallet.WalletType != WalletTypeWatchOnly {
		return "", fmt.Errorf("wallet %s is not a watch-only wallet", walletId)
	}

	if wallet.WatchOnly == nil {
		return "", fmt.Errorf("wallet %s missing watch_only data", walletId)
	}

	// Generate wallet name from wallet ID
	walletName := fmt.Sprintf("watch_%s", walletId[:8])

	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return "", fmt.Errorf("get bitcoind client: %w", err)
	}

	// Check if wallet already exists in Bitcoin Core
	listResp, err := bitcoindClient.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return "", fmt.Errorf("list Bitcoin Core wallets: %w", err)
	}

	walletExists := lo.Contains(listResp.Msg.Wallets, walletName)
	if !walletExists {
		// Create watch-only wallet
		if err := e.createWatchOnlyWallet(ctx, walletName, wallet); err != nil {
			return "", fmt.Errorf("create watch-only wallet: %w", err)
		}
		zerolog.Ctx(ctx).Info().
			Str("wallet_id", walletId).
			Str("wallet_name", walletName).
			Msg("created watch-only Bitcoin Core wallet")
	}

	// Cache the mapping
	e.coreWallets[walletId] = walletName
	return walletName, nil
}

// createWatchOnlyWallet creates a watch-only Bitcoin Core wallet
func (e *WalletEngine) createWatchOnlyWallet(
	ctx context.Context,
	walletName string,
	wallet *WalletInfo,
) error {
	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return fmt.Errorf("get bitcoind client: %w", err)
	}

	// Create descriptor wallet in Bitcoin Core (watch-only)
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               walletName,
		DisablePrivateKeys: true,
		Blank:              true,
		Passphrase:         "",
		AvoidReuse:         false,
	}))
	if err != nil {
		// If wallet already exists on disk, load it instead
		if strings.Contains(err.Error(), "Database already exists") {
			zerolog.Ctx(ctx).Info().
				Str("wallet_name", walletName).
				Msg("Bitcoin Core watch-only wallet already exists on disk, loading it")

			_, err = bitcoindClient.LoadWallet(ctx, connect.NewRequest(&corepb.LoadWalletRequest{
				Filename:      walletName,
				LoadOnStartup: false,
			}))
			if err != nil {
				return fmt.Errorf("load Bitcoin Core wallet: %w", err)
			}
		} else {
			return fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}
	}

	// Import the descriptor or xpub
	var descriptorToImport string
	var isXpub bool

	switch {
	case wallet.WatchOnly.Descriptor != "":
		descriptorToImport = wallet.WatchOnly.Descriptor
		isXpub = false

	case wallet.WatchOnly.Xpub != "":
		xpub := wallet.WatchOnly.Xpub
		descriptorToImport = fmt.Sprintf("wpkh(%s/0/*)#checksum", xpub)
		isXpub = true

	default:
		return fmt.Errorf("watch-only wallet requires either descriptor or xpub")
	}

	if err := e.importDescriptorToWallet(ctx, bitcoindClient, walletName, descriptorToImport, isXpub); err != nil {
		return fmt.Errorf("import descriptor: %w", err)
	}

	return nil
}

// importDescriptorToWallet imports a descriptor into a Bitcoin Core wallet
func (e *WalletEngine) importDescriptorToWallet(
	ctx context.Context,
	bitcoindClient corerpc.BitcoinServiceClient,
	walletName string,
	descriptor string,
	isXpub bool,
) error {
	descriptorsToImport := []string{descriptor}

	if isXpub {
		// Add change descriptor for xpub-based wallets
		xpubStart := strings.Index(descriptor, "wpkh(") + 5
		xpubEnd := strings.Index(descriptor, "/0/*)")
		if xpubStart > 5 && xpubEnd > xpubStart {
			xpub := descriptor[xpubStart:xpubEnd]
			changeDescriptor := fmt.Sprintf("wpkh(%s/1/*)#checksum", xpub)
			descriptorsToImport = append(descriptorsToImport, changeDescriptor)
		}
	}

	var requests []*corepb.ImportDescriptorsRequest_Request
	for i, desc := range descriptorsToImport {
		desc = strings.Split(desc, "#")[0]
		isInternal := i == 1

		requests = append(requests, &corepb.ImportDescriptorsRequest_Request{
			Descriptor_: desc,
			Active:      true,
			Timestamp:   nil,
			Internal:    isInternal,
			Label:       "",
			RangeStart:  0,
			RangeEnd:    1000,
		})
	}

	resp, err := bitcoindClient.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet:   walletName,
		Requests: requests,
	}))
	if err != nil {
		return fmt.Errorf("bitcoin core importdescriptors: %w", err)
	}

	// Check results
	for i, result := range resp.Msg.Responses {
		if !result.Success {
			errMsg := "unknown error"
			if result.Error != nil {
				errMsg = result.Error.Message
			}
			return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
		}
	}

	return nil
}

// ============================================================================
// Wallet Sync (from WalletSyncer)
// ============================================================================

// SyncWallets syncs Bitcoin Core wallets from wallet.json to Bitcoin Core
// This is called after wallet unlock to ensure all Bitcoin Core wallets exist
func (e *WalletEngine) SyncWallets(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	// Throttle syncs to once per 5 seconds
	e.mu.Lock()
	if time.Since(e.lastSync) < 5*time.Second {
		e.mu.Unlock()
		log.Debug().Msg("wallet sync: throttled, skipping")
		return nil
	}
	e.lastSync = time.Now()
	e.mu.Unlock()

	log.Info().Msg("wallet sync: starting")

	wallets, err := e.loadAllWallets()
	if err != nil {
		return fmt.Errorf("load wallets: %w", err)
	}

	if len(wallets) == 0 {
		log.Info().Msg("wallet sync: no wallets to sync")
		return nil
	}

	// Ensure Bitcoin Core wallets exist
	if err := e.ensureBitcoinCoreWallets(ctx, wallets); err != nil {
		log.Error().Err(err).Msg("wallet sync: failed")
	}

	log.Info().Msg("wallet sync: completed")
	return nil
}

func (e *WalletEngine) loadAllWallets() ([]WalletInfo, error) {
	// Check if wallet is encrypted
	if wallet.IsWalletEncrypted(e.walletDir) {
		// For encrypted wallets, use the cache populated during unlock
		e.mu.RLock()
		defer e.mu.RUnlock()

		if !e.isUnlocked {
			return nil, errors.New("wallet is encrypted and locked")
		}

		// Extract wallets from cache
		wallets := make([]WalletInfo, 0, len(e.walletCache))
		for _, w := range e.walletCache {
			wallets = append(wallets, *w)
		}

		return wallets, nil
	}

	// For unencrypted wallets, read from file
	walletFile := filepath.Join(e.walletDir, "wallet.json")

	data, err := os.ReadFile(walletFile)
	if err != nil {
		return nil, fmt.Errorf("read wallet.json: %w", err)
	}

	var walletData struct {
		Version        int          `json:"version"`
		ActiveWalletId string       `json:"activeWalletId"`
		Wallets        []WalletInfo `json:"wallets"`
	}

	if err := json.Unmarshal(data, &walletData); err != nil {
		return nil, fmt.Errorf("parse wallet.json: %w", err)
	}

	return walletData.Wallets, nil
}

func (e *WalletEngine) ensureBitcoinCoreWallets(ctx context.Context, wallets []WalletInfo) error {
	log := zerolog.Ctx(ctx)

	// Find all Bitcoin Core wallets
	coreWallets := lo.Filter(wallets, func(w WalletInfo, _ int) bool {
		return w.WalletType == WalletTypeBitcoinCore
	})

	if len(coreWallets) == 0 {
		return nil
	}

	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return fmt.Errorf("bitcoind not available: %w", err)
	}

	// List existing wallets in Bitcoin Core
	listResp, err := bitcoindClient.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return fmt.Errorf("list Bitcoin Core wallets: %w", err)
	}

	// Check each wallet
	for _, wallet := range coreWallets {
		walletName := fmt.Sprintf("wallet_%s", wallet.ID[:8])
		walletExists := lo.Contains(listResp.Msg.Wallets, walletName)

		if !walletExists {
			log.Info().
				Str("wallet_id", wallet.ID).
				Str("wallet_name", walletName).
				Msg("wallet sync: creating missing Bitcoin Core wallet")

			if err := e.createBitcoinCoreWalletForSync(ctx, bitcoindClient, walletName, &wallet); err != nil {
				log.Error().
					Err(err).
					Str("wallet_id", wallet.ID).
					Msg("wallet sync: failed to create Bitcoin Core wallet")
				continue
			}

			log.Info().
				Str("wallet_id", wallet.ID).
				Str("wallet_name", walletName).
				Msg("wallet sync: created Bitcoin Core wallet")
		}
	}

	return nil
}

func (e *WalletEngine) createBitcoinCoreWalletForSync(
	ctx context.Context,
	bitcoindClient corerpc.BitcoinServiceClient,
	walletName string,
	wallet *WalletInfo,
) error {
	// Decode seed
	seed, err := hex.DecodeString(wallet.Master.SeedHex)
	if err != nil {
		return fmt.Errorf("decode seed hex: %w", err)
	}

	// Derive master key
	masterKey, err := hdkeychain.NewMaster(seed, e.chainParams)
	if err != nil {
		return fmt.Errorf("derive master key: %w", err)
	}

	// Derive to BIP84 account level: m/84'/0'/0'
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
	if err != nil {
		return fmt.Errorf("derive purpose: %w", err)
	}

	// Coin type
	coinType := uint32(1)
	if e.chainParams.Net == wire.MainNet {
		coinType = 0
	}
	coin, err := purpose.Derive(hdkeychain.HardenedKeyStart + coinType)
	if err != nil {
		return fmt.Errorf("derive coin type: %w", err)
	}

	// Account: 0'
	account, err := coin.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		return fmt.Errorf("derive account: %w", err)
	}

	accountXprv := account.String()

	// Create wallet
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               walletName,
		DisablePrivateKeys: false,
		Blank:              true,
		Passphrase:         "",
		AvoidReuse:         false,
	}))
	if err != nil {
		// If wallet already exists on disk, load it instead
		if strings.Contains(err.Error(), "Database already exists") {
			zerolog.Ctx(ctx).Info().
				Str("wallet_name", walletName).
				Msg("Bitcoin Core wallet already exists on disk, loading it")

			_, err = bitcoindClient.LoadWallet(ctx, connect.NewRequest(&corepb.LoadWalletRequest{
				Filename:      walletName,
				LoadOnStartup: false,
			}))
			if err != nil {
				return fmt.Errorf("load Bitcoin Core wallet: %w", err)
			}
		} else {
			return fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}
	}

	// Import descriptors
	descriptors := []struct {
		desc     string
		internal bool
	}{
		{fmt.Sprintf("wpkh(%s/0/*)", accountXprv), false},
		{fmt.Sprintf("wpkh(%s/1/*)", accountXprv), true},
	}

	var requests []*corepb.ImportDescriptorsRequest_Request
	for _, d := range descriptors {
		descriptorWithChecksum, err := AddDescriptorChecksum(d.desc)
		if err != nil {
			return fmt.Errorf("compute descriptor checksum: %w", err)
		}

		requests = append(requests, &corepb.ImportDescriptorsRequest_Request{
			Descriptor_: descriptorWithChecksum,
			Active:      true,
			Timestamp:   nil,
			Internal:    d.internal,
			RangeStart:  1,
			RangeEnd:    1000,
		})
	}

	resp, err := bitcoindClient.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet:   walletName,
		Requests: requests,
	}))
	if err != nil {
		return fmt.Errorf("import descriptors: %w", err)
	}

	// Check results
	for i, result := range resp.Msg.Responses {
		if !result.Success {
			errMsg := "unknown error"
			if result.Error != nil {
				errMsg = result.Error.Message
			}
			return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
		}
	}

	return nil
}
