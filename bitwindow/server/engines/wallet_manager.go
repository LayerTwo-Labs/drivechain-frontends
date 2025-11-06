package engines

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
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
)

// WalletInfo contains information about a wallet from wallet.json
type WalletInfo struct {
	ID         string     `json:"id"`
	Name       string     `json:"name"`
	WalletType WalletType `json:"walletType"`
	Master     struct {
		SeedHex string `json:"seed_hex"`
	} `json:"master"`
	L1 struct {
		Mnemonic string `json:"mnemonic"`
	} `json:"l1"`
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
	_, err = hdkeychain.NewMaster(seed, wm.chainParams)
	if err != nil {
		return fmt.Errorf("derive master key: %w", err)
	}

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

	// TODO: Import the master key/descriptor into the wallet
	// This requires deriving descriptors and using importdescriptors RPC
	// For now, Bitcoin Core wallet is created but empty
	// This will be implemented based on your specific descriptor requirements

	zerolog.Ctx(ctx).Warn().
		Str("wallet_name", walletName).
		Msg("Bitcoin Core wallet created but descriptor import not yet implemented")

	return nil
}

// GetBitcoinCoreWalletName returns the Bitcoin Core wallet name for a walletId
// Returns error if wallet doesn't exist or isn't a Bitcoin Core wallet
func (wm *WalletManager) GetBitcoinCoreWalletName(ctx context.Context, walletId string) (string, error) {
	return wm.EnsureBitcoinCoreWallet(ctx, walletId)
}
