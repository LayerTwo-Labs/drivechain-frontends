package engines

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
)

// WalletSyncer ensures Bitcoin Core wallets are properly created/imported
type WalletSyncer struct {
	walletManager     *WalletManager
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error)
	walletDir         string
	chainParams       *chaincfg.Params
	lastSync          time.Time
}

// NewWalletSyncer creates a new wallet syncer
func NewWalletSyncer(
	walletManager *WalletManager,
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error),
	walletDir string,
	chainParams *chaincfg.Params,
) *WalletSyncer {
	return &WalletSyncer{
		walletManager:     walletManager,
		bitcoindConnector: bitcoindConnector,
		walletDir:         walletDir,
		chainParams:       chainParams,
	}
}

// SyncWallets syncs Bitcoin Core wallets from wallet.json to Bitcoin Core
// This is called after wallet unlock to ensure all Bitcoin Core wallets exist
// NOTE: Enforcer wallet is managed by enforcer itself via starter file, not synced here
func (ws *WalletSyncer) SyncWallets(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	// Throttle syncs to once per 5 seconds to avoid excessive syncing
	if time.Since(ws.lastSync) < 5*time.Second {
		log.Debug().Msg("wallet sync: throttled, skipping")
		return nil
	}
	ws.lastSync = time.Now()

	log.Info().Msg("wallet sync: starting Bitcoin Core wallet sync")

	wallets, err := ws.loadAllWallets()
	if err != nil {
		return fmt.Errorf("load wallets: %w", err)
	}

	if len(wallets) == 0 {
		log.Info().Msg("wallet sync: no wallets to sync")
		return nil
	}

	// Ensure Bitcoin Core wallets exist
	if err := ws.ensureBitcoinCoreWallets(ctx, wallets); err != nil {
		log.Error().Err(err).Msg("wallet sync: failed to ensure Bitcoin Core wallets")
		// Don't return error
	}

	log.Info().Msg("wallet sync: completed")
	return nil
}

func (ws *WalletSyncer) loadAllWallets() ([]WalletInfo, error) {
	walletFile := filepath.Join(ws.walletDir, "wallet.json")

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

func (ws *WalletSyncer) ensureBitcoinCoreWallets(ctx context.Context, wallets []WalletInfo) error {
	log := zerolog.Ctx(ctx)

	// Find all Bitcoin Core wallets
	coreWallets := lo.Filter(wallets, func(w WalletInfo, _ int) bool {
		return w.WalletType == WalletTypeBitcoinCore
	})

	if len(coreWallets) == 0 {
		log.Info().Msg("wallet sync: no Bitcoin Core wallets to sync")
		return nil
	}

	// Get bitcoind client
	bitcoindClient, err := ws.bitcoindConnector(ctx)
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

			if err := ws.createBitcoinCoreWallet(ctx, bitcoindClient, walletName, &wallet); err != nil {
				log.Error().
					Err(err).
					Str("wallet_id", wallet.ID).
					Str("wallet_name", walletName).
					Msg("wallet sync: failed to create Bitcoin Core wallet")
				continue
			}

			log.Info().
				Str("wallet_id", wallet.ID).
				Str("wallet_name", walletName).
				Msg("wallet sync: created Bitcoin Core wallet")
		} else {
			log.Debug().
				Str("wallet_id", wallet.ID).
				Str("wallet_name", walletName).
				Msg("wallet sync: Bitcoin Core wallet already exists")
		}
	}

	return nil
}

func (ws *WalletSyncer) createBitcoinCoreWallet(
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
	masterKey, err := hdkeychain.NewMaster(seed, ws.chainParams)
	if err != nil {
		return fmt.Errorf("derive master key: %w", err)
	}

	// Derive to BIP84 account level: m/84'/0'/0'
	// Purpose: 84' (native segwit)
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
	if err != nil {
		return fmt.Errorf("derive purpose: %w", err)
	}

	// coin type 1' for testnet/signet
	coinType := uint32(1)
	if ws.chainParams.Net == wire.MainNet {
		// Coin type: 0' for mainnet
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

	// Get the xprv string for the account
	accountXprv := account.String()

	// Create descriptor wallet in Bitcoin Core
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               walletName,
		DisablePrivateKeys: false,
		Blank:              true,
		Passphrase:         "",
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

	return nil
}
