package engines

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"

	"connectrpc.com/connect"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
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

// WalletManager routes wallet operations to the correct backend
type WalletManager struct {
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error)
	enforcerConnector func(context.Context) (validatorrpc.WalletServiceClient, error)
	walletDir         string
	chainParams       *chaincfg.Params

	// Maps walletId -> Bitcoin Core wallet name
	coreWallets map[string]string
	mu          sync.RWMutex
}

// NewWalletManager creates a new WalletManager
func NewWalletManager(
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error),
	enforcerConnector func(context.Context) (validatorrpc.WalletServiceClient, error),
	walletDir string,
	chainParams *chaincfg.Params,
) *WalletManager {
	return &WalletManager{
		bitcoindConnector: bitcoindConnector,
		enforcerConnector: enforcerConnector,
		walletDir:         walletDir,
		chainParams:       chainParams,
		coreWallets:       make(map[string]string),
	}
}

// GetWalletInfo reads wallet.json and returns info for the specified walletId
func (wm *WalletManager) GetWalletInfo(ctx context.Context, walletId string) (*WalletInfo, error) {
	walletFile := filepath.Join(wm.walletDir, "wallet.json")

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

	wallet := lo.Filter(walletData.Wallets, func(w WalletInfo, _ int) bool {
		return w.ID == walletId
	})

	if len(wallet) == 0 {
		return nil, fmt.Errorf("wallet %s not found", walletId)
	}

	return &wallet[0], nil
}

// GetWalletBackendType returns the backend type for a wallet
func (wm *WalletManager) GetWalletBackendType(ctx context.Context, walletId string) (WalletType, error) {
	if walletId == "" {
		return "", fmt.Errorf("wallet_id required")
	}
	wallet, err := wm.GetWalletInfo(ctx, walletId)
	if err != nil {
		return "", err
	}
	return wallet.WalletType, nil
}

// EnsureBitcoinCoreWallet ensures a Bitcoin Core wallet exists for the given walletId
// Creates it from the seed if it doesn't exist (lazy loading)
func (wm *WalletManager) EnsureBitcoinCoreWallet(ctx context.Context, walletId string) (string, error) {
	wm.mu.Lock()
	defer wm.mu.Unlock()

	// Check cache
	if walletName, exists := wm.coreWallets[walletId]; exists {
		return walletName, nil
	}

	// Get wallet info
	wallet, err := wm.GetWalletInfo(ctx, walletId)
	if err != nil {
		return "", err
	}

	if wallet.WalletType != WalletTypeBitcoinCore {
		return "", fmt.Errorf("wallet %s is not a Bitcoin Core wallet", walletId)
	}

	// Generate wallet name from wallet ID
	walletName := fmt.Sprintf("wallet_%s", walletId[:8])

	// Get bitcoind client
	bitcoindClient, err := wm.bitcoindConnector(ctx)
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
		if err := wm.createBitcoinCoreWalletFromSeed(ctx, walletName, wallet); err != nil {
			return "", fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}
		zerolog.Ctx(ctx).Info().
			Str("wallet_id", walletId).
			Str("wallet_name", walletName).
			Msg("created Bitcoin Core wallet from seed")
	}

	// Cache the mapping
	wm.coreWallets[walletId] = walletName
	return walletName, nil
}

// createBitcoinCoreWalletFromSeed creates a Bitcoin Core wallet and imports the seed
func (wm *WalletManager) createBitcoinCoreWalletFromSeed(
	ctx context.Context,
	walletName string,
	wallet *WalletInfo,
) error {
	// Decode seed
	seed, err := hex.DecodeString(wallet.Master.SeedHex)
	if err != nil {
		return fmt.Errorf("decode seed hex: %w", err)
	}

	// Derive master key
	masterKey, err := hdkeychain.NewMaster(seed, wm.chainParams)
	if err != nil {
		return fmt.Errorf("derive master key: %w", err)
	}

	// Derive to BIP84 account level: m/84'/0'/0'
	// Purpose: 84' (native segwit)
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
	if err != nil {
		return fmt.Errorf("derive purpose: %w", err)
	}

	// Coin type: 0' for mainnet, 1' for testnet/signet
	coinType := uint32(0)
	if wm.chainParams.Name != "mainnet" {
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

	// Get bitcoind client
	bitcoindClient, err := wm.bitcoindConnector(ctx)
	if err != nil {
		return fmt.Errorf("get bitcoind client: %w", err)
	}

	// Create descriptor wallet in Bitcoin Core
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               walletName,
		DisablePrivateKeys: false,
		Blank:              true, // Start with blank wallet, we'll import descriptor
		Passphrase:         "",   // TODO: Support encrypted wallets
		AvoidReuse:         false,
	}))
	if err != nil {
		return fmt.Errorf("create Bitcoin Core wallet: %w", err)
	}

	// Import descriptors for receiving and change addresses
	descriptors := []struct {
		desc     string
		internal bool
	}{
		{fmt.Sprintf("wpkh(%s/0/*)", accountXprv), false}, // Receiving
		{fmt.Sprintf("wpkh(%s/1/*)", accountXprv), true},  // Change
	}

	var requests []*corepb.ImportDescriptorsRequest_Request
	for _, d := range descriptors {
		// Don't use GetDescriptorInfo - it strips private keys!
		// Compute checksum ourselves to keep private keys intact
		descriptorWithChecksum, err := AddDescriptorChecksum(d.desc)
		if err != nil {
			return fmt.Errorf("compute descriptor checksum: %w", err)
		}

		requests = append(requests, &corepb.ImportDescriptorsRequest_Request{
			Descriptor_: descriptorWithChecksum,
			Active:      true,
			Timestamp:   nil, // nil = "now"
			Internal:    d.internal,
			RangeStart:  1,    // Start from 1 (0 gets omitted by protobuf)
			RangeEnd:    1000, // Generate 1000 keys
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

	zerolog.Ctx(ctx).Info().
		Str("wallet_name", walletName).
		Msg("Bitcoin Core wallet created and descriptors imported")

	return nil
}

// GetBitcoinCoreWalletName returns the Bitcoin Core wallet name for a walletId
// Returns error if wallet doesn't exist or isn't a Bitcoin Core wallet
func (wm *WalletManager) GetBitcoinCoreWalletName(ctx context.Context, walletId string) (string, error) {
	return wm.EnsureBitcoinCoreWallet(ctx, walletId)
}

// EnsureWatchOnlyWallet ensures a watch-only wallet exists in Bitcoin Core for the given walletId
// Creates it from the descriptor/xpub if it doesn't exist (lazy loading)
func (wm *WalletManager) EnsureWatchOnlyWallet(ctx context.Context, walletId string) (string, error) {
	wm.mu.Lock()
	defer wm.mu.Unlock()

	// Check cache
	if walletName, exists := wm.coreWallets[walletId]; exists {
		return walletName, nil
	}

	// Get wallet info
	wallet, err := wm.GetWalletInfo(ctx, walletId)
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
	bitcoindClient, err := wm.bitcoindConnector(ctx)
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
		if err := wm.createWatchOnlyWallet(ctx, walletName, wallet); err != nil {
			return "", fmt.Errorf("create watch-only wallet: %w", err)
		}
		zerolog.Ctx(ctx).Info().
			Str("wallet_id", walletId).
			Str("wallet_name", walletName).
			Msg("created watch-only Bitcoin Core wallet")
	}

	// Cache the mapping
	wm.coreWallets[walletId] = walletName
	return walletName, nil
}

// createWatchOnlyWallet creates a watch-only Bitcoin Core wallet and imports descriptor/xpub
func (wm *WalletManager) createWatchOnlyWallet(
	ctx context.Context,
	walletName string,
	wallet *WalletInfo,
) error {
	// Get bitcoind client
	bitcoindClient, err := wm.bitcoindConnector(ctx)
	if err != nil {
		return fmt.Errorf("get bitcoind client: %w", err)
	}

	// Create descriptor wallet in Bitcoin Core (watch-only, no private keys)
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               walletName,
		DisablePrivateKeys: true, // Watch-only wallet
		Blank:              true, // Start blank, we'll import descriptor
		Passphrase:         "",
		AvoidReuse:         false,
	}))
	if err != nil {
		return fmt.Errorf("create Bitcoin Core wallet: %w", err)
	}

	// Import the descriptor or xpub
	// If user provided a descriptor, use it directly
	// If user provided an xpub, convert it to a descriptor
	var descriptorToImport string
	var isXpub bool

	switch {
	case wallet.WatchOnly.Descriptor != "":
		descriptorToImport = wallet.WatchOnly.Descriptor
		isXpub = false

	case wallet.WatchOnly.Xpub != "":
		// Convert xpub to descriptor format
		// Standard formats: wpkh(xpub...) for native segwit, or sh(wpkh(xpub...)) for wrapped segwit
		xpub := wallet.WatchOnly.Xpub
		descriptorToImport = fmt.Sprintf("wpkh(%s/0/*)#checksum", xpub) // External chain (receiving)
		isXpub = true
		zerolog.Ctx(ctx).Info().
			Str("xpub", xpub).
			Str("descriptor", descriptorToImport).
			Msg("converted xpub to descriptor")

	default:
		return fmt.Errorf("watch-only wallet requires either descriptor or xpub")
	}

	// Import the descriptor into the wallet
	// Note: Bitcoin Core will calculate the checksum if we use importdescriptors
	if err := wm.importDescriptorToWallet(ctx, bitcoindClient, walletName, descriptorToImport, isXpub); err != nil {
		return fmt.Errorf("import descriptor: %w", err)
	}

	zerolog.Ctx(ctx).Info().
		Str("wallet_name", walletName).
		Str("descriptor", descriptorToImport).
		Bool("from_xpub", isXpub).
		Msg("watch-only wallet created and descriptor imported")

	return nil
}

// importDescriptorToWallet imports a descriptor into a Bitcoin Core wallet using importdescriptors RPC
func (wm *WalletManager) importDescriptorToWallet(
	ctx context.Context,
	bitcoindClient corerpc.BitcoinServiceClient,
	walletName string,
	descriptor string,
	isXpub bool,
) error {
	// For xpub-based descriptors, we need to import both external (receiving) and internal (change) chains
	descriptorsToImport := []string{descriptor}

	if isXpub {
		// Extract the xpub from the descriptor
		// descriptor format: wpkh(xpub.../0/*)#checksum
		// We need to add the change descriptor: wpkh(xpub.../1/*)#checksum
		xpubStart := strings.Index(descriptor, "wpkh(") + 5
		xpubEnd := strings.Index(descriptor, "/0/*)")
		if xpubStart > 5 && xpubEnd > xpubStart {
			xpub := descriptor[xpubStart:xpubEnd]
			changeDescriptor := fmt.Sprintf("wpkh(%s/1/*)#checksum", xpub)
			descriptorsToImport = append(descriptorsToImport, changeDescriptor)
			zerolog.Ctx(ctx).Info().
				Str("change_descriptor", changeDescriptor).
				Msg("added change chain descriptor")
		}
	}

	// Prepare import requests
	var requests []*corepb.ImportDescriptorsRequest_Request
	for i, desc := range descriptorsToImport {
		// Remove the #checksum placeholder - Bitcoin Core will calculate it
		desc = strings.Split(desc, "#")[0]

		// Determine if this is receiving or change chain
		isInternal := i == 1 // Second descriptor is change chain

		requests = append(requests, &corepb.ImportDescriptorsRequest_Request{
			Descriptor_: desc,
			Active:      true,
			Timestamp:   nil, // nil = "now", bypasses rescan (watch-only doesn't need rescan)
			Internal:    isInternal,
			Label:       "", // No label for ranged descriptors
			RangeStart:  0,
			RangeEnd:    1000, // Scan first 1000 addresses
		})

		zerolog.Ctx(ctx).Info().
			Str("descriptor", desc).
			Bool("is_change", isInternal).
			Msg("prepared descriptor for import")
	}

	// Import all descriptors in one call
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
			zerolog.Ctx(ctx).Error().
				Int("index", i).
				Str("error", errMsg).
				Msg("descriptor import failed")
			return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
		}

		// Log any warnings
		for _, warning := range result.Warnings {
			zerolog.Ctx(ctx).Warn().
				Int("index", i).
				Str("warning", warning).
				Msg("descriptor import warning")
		}

		zerolog.Ctx(ctx).Info().
			Int("index", i).
			Msg("descriptor imported successfully")
	}

	return nil
}
