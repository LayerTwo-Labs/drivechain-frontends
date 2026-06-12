package wallet

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/tyler-smith/go-bip32"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
)

// walletLoadingBackoff is how long Ensure short-circuits subsequent calls
// after a transient bitcoind error (e.g. -4 Wallet already loading or -28
// Verifying blocks). Frontends poll this path aggressively while the user
// stares at the wallet view; without a gate every poll triggers a fresh
// CreateWallet/LoadWallet RPC and we drown bitcoind in retries that all fail
// the same way until Core is past startup.
const walletLoadingBackoff = 5 * time.Second

// CoreProvider serves wallets from Bitcoin Core descriptor wallets: it
// derives BIP84 descriptors from wallet.json seeds, lazily creates the Core
// wallets, and proxies all wallet operations to Core RPC.
type CoreProvider struct {
	svc     *Service
	rpc     *CoreRPCClient
	log     zerolog.Logger
	network *chaincfg.Params

	mu          sync.Mutex
	coreWallets map[string]string // walletID -> Core wallet name

	// Transient backoff: when bitcoind responds with a "still booting" error
	// (-4 Wallet already loading, -28 Verifying blocks, …), Ensure returns
	// the cached error for `walletLoadingBackoff` so the next ~5s of
	// frontend polls don't translate into RPC storms against bitcoind.
	loadingUntil time.Time
	loadingErr   error
}

var _ Provider = (*CoreProvider)(nil)

// NewCoreProvider creates the Bitcoin Core wallet provider.
func NewCoreProvider(svc *Service, rpc *CoreRPCClient, network *chaincfg.Params, log zerolog.Logger) *CoreProvider {
	return &CoreProvider{
		svc:         svc,
		rpc:         rpc,
		log:         log.With().Str("component", "core-provider").Logger(),
		network:     network,
		coreWallets: make(map[string]string),
	}
}

// Ensure ensures a Bitcoin Core wallet exists for a wallet.json wallet.
// Returns the Core wallet name.
func (p *CoreProvider) Ensure(ctx context.Context, walletID string) (string, error) {
	p.mu.Lock()
	defer p.mu.Unlock()

	// Check cache
	if name, ok := p.coreWallets[walletID]; ok {
		return name, nil
	}

	// Short-circuit while a recent attempt is still in the bitcoind-warming-up
	// window — return the same error without re-hitting RPC.
	if p.loadingErr != nil && time.Now().Before(p.loadingUntil) {
		return "", p.loadingErr
	}

	// Find wallet data
	all := p.svc.GetAllWallets()
	var targetWallet *WalletData
	for i := range all {
		if all[i].ID == walletID {
			targetWallet = &all[i]
			break
		}
	}
	if targetWallet == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}

	walletName := fmt.Sprintf("wallet_%s", walletID[:8])

	var err error
	switch targetWallet.WalletType {
	case "bitcoinCore":
		err = p.createBitcoinCoreWallet(ctx, walletName, targetWallet.Master.SeedHex)
	case "watchOnly":
		err = p.createWatchOnlyWallet(ctx, walletName, targetWallet)
	default:
		return "", fmt.Errorf("wallet type %s does not use Bitcoin Core", targetWallet.WalletType)
	}

	if err != nil {
		if isTransientWalletErr(err) {
			p.loadingUntil = time.Now().Add(walletLoadingBackoff)
			p.loadingErr = err
		}
		return "", err
	}

	// Ensure the wallet's BIP47 notification descriptor is imported. Runs
	// both for newly-created wallets and existing ones so the descriptor
	// lands on first boot post-engine-deploy. Idempotent in Core, and a
	// failure here shouldn't break wallet loading — the provider will retry
	// next time Ensure runs.
	if targetWallet.WalletType == "bitcoinCore" {
		if perr := p.ensureBip47NotificationDescriptor(ctx, walletName, targetWallet.Master.SeedHex); perr != nil {
			p.log.Warn().Err(perr).Str("wallet", walletName).Msg("could not ensure bip47 notification descriptor")
		}
	}

	// Success — clear any previous transient gate and cache the wallet name.
	p.loadingUntil = time.Time{}
	p.loadingErr = nil
	p.coreWallets[walletID] = walletName
	return walletName, nil
}

// EnsureAll syncs all bitcoinCore/watchOnly wallets to Bitcoin Core.
func (p *CoreProvider) EnsureAll(ctx context.Context) (int, error) {
	wallets := p.svc.GetAllWallets()
	synced := 0

	for _, w := range wallets {
		if w.WalletType != "bitcoinCore" && w.WalletType != "watchOnly" {
			continue
		}
		if _, err := p.Ensure(ctx, w.ID); err != nil {
			p.log.Warn().Err(err).Str("wallet_id", w.ID).Msg("failed to ensure core wallet")
			continue
		}
		synced++
	}

	return synced, nil
}

// walletName returns the Core wallet name for a wallet ID, ensuring it exists.
func (p *CoreProvider) walletName(ctx context.Context, walletID string) (string, error) {
	p.mu.Lock()
	if name, ok := p.coreWallets[walletID]; ok {
		p.mu.Unlock()
		return name, nil
	}
	p.mu.Unlock()

	return p.Ensure(ctx, walletID)
}

func (p *CoreProvider) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return 0, 0, err
	}
	confirmed, err := p.rpc.GetBalance(ctx, name)
	if err != nil {
		return 0, 0, err
	}
	unconfirmed, err := p.rpc.GetUnconfirmedBalance(ctx, name)
	if err != nil {
		return 0, 0, err
	}
	return confirmed, unconfirmed, nil
}

func (p *CoreProvider) ListUnspent(ctx context.Context, walletID string) ([]UTXO, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.ListUnspent(ctx, name)
}

func (p *CoreProvider) ListTransactions(ctx context.Context, walletID string, count int) ([]WalletTransaction, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.ListTransactions(ctx, name, count)
}

func (p *CoreProvider) ListTransactionsRange(ctx context.Context, walletID string, count, skip int) ([]WalletTransaction, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.ListTransactionsRange(ctx, name, count, skip)
}

func (p *CoreProvider) ListReceivedByAddress(ctx context.Context, walletID string) ([]ReceivedByAddress, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.ListReceivedByAddress(ctx, name)
}

func (p *CoreProvider) GetWalletTransaction(ctx context.Context, walletID, txid string) (json.RawMessage, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.GetTransaction(ctx, name, txid)
}

func (p *CoreProvider) AddressInfo(ctx context.Context, walletID, address string) (*AddressInfo, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.GetAddressInfo(ctx, name, address)
}

// NextReceiveAddress returns an existing unused address from the wallet, or
// mints a new one if every address has received funds. "Unused" = present in
// listreceivedbyaddress with zero amount and no txids (minconf=0 also catches
// mempool receives). Lets the receive page poll without burning the keypool,
// while staying entirely stateless across orchestrator restarts.
//
// Candidates are filtered to the chain's bech32 prefix because the Core wallet
// also imports P2PKH addresses for BIP47 (the notification address + per-sender
// derived payment addresses) — those must never leak into the regular receive
// flow.
func (p *CoreProvider) NextReceiveAddress(ctx context.Context, walletID string) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	addrs, err := p.rpc.ListReceivedByAddress(ctx, name)
	if err != nil {
		return "", err
	}
	prefix := p.bech32Prefix()
	for _, a := range addrs {
		if a.Amount != 0 || len(a.TxIDs) != 0 {
			continue
		}
		if prefix != "" && !strings.HasPrefix(a.Address, prefix) {
			continue
		}
		return a.Address, nil
	}
	return p.rpc.GetNewAddress(ctx, name, "", "bech32")
}

func (p *CoreProvider) NextChangeAddress(ctx context.Context, walletID string) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	return p.rpc.GetRawChangeAddress(ctx, name)
}

func (p *CoreProvider) WatchDescriptors(ctx context.Context, walletID string, descriptors []ImportDescriptor) ([]ImportDescriptorResult, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.ImportDescriptors(ctx, name, descriptors)
}

func (p *CoreProvider) SendToAddress(ctx context.Context, walletID, address string, amount float64, subtractFee bool) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	return p.rpc.SendToAddress(ctx, name, address, amount, subtractFee)
}

func (p *CoreProvider) SendMany(ctx context.Context, walletID string, amounts map[string]float64) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	return p.rpc.SendMany(ctx, name, amounts)
}

func (p *CoreProvider) FundTransaction(ctx context.Context, walletID, rawHex string, options map[string]interface{}) (*FundRawTransactionResult, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.FundRawTransaction(ctx, name, rawHex, options)
}

func (p *CoreProvider) SignTransaction(ctx context.Context, walletID, rawHex string) (*SignRawTransactionResult, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.SignRawTransactionWithWallet(ctx, name, rawHex)
}

func (p *CoreProvider) BumpFee(ctx context.Context, walletID, txid string, newFeeRate int64) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	return p.rpc.BumpFee(ctx, name, txid, newFeeRate)
}

// Chain returns the Core-backed chain source.
func (p *CoreProvider) Chain() ChainSource {
	return coreChain{rpc: p.rpc}
}

// coreChain adapts CoreRPCClient to ChainSource.
type coreChain struct {
	rpc *CoreRPCClient
}

func (c coreChain) GetRawTransaction(ctx context.Context, txid string) (*RawTransaction, error) {
	return c.rpc.GetRawTransaction(ctx, txid)
}

func (c coreChain) CreateRawTransaction(ctx context.Context, inputs []RawInput, outputs []map[string]interface{}) (string, error) {
	return c.rpc.CreateRawTransaction(ctx, inputs, outputs)
}

func (c coreChain) Broadcast(ctx context.Context, rawHex string) (string, error) {
	return c.rpc.SendRawTransaction(ctx, rawHex)
}

func (c coreChain) DeriveAddresses(ctx context.Context, descriptor string, rangeStart, rangeEnd int) ([]string, error) {
	return c.rpc.DeriveAddresses(ctx, descriptor, rangeStart, rangeEnd)
}

// ============================================================================
// Core wallet creation (descriptor derivation + import)
// ============================================================================

// ensureBip47NotificationDescriptor imports the wallet's BIP47 notification
// P2PKH key (m/47'/0'/0'/0) into Core if not already present. Uses
// timestamp=0 so the first import rescans the chain from genesis and picks
// up historic notification txs; subsequent imports are no-ops because Core
// recognizes the descriptor as already known.
func (p *CoreProvider) ensureBip47NotificationDescriptor(ctx context.Context, walletName, seedHex string) error {
	if p.network == nil {
		return nil
	}
	notifPriv, _, err := bip47.DeriveOwnNotificationKey(seedHex, p.network)
	if err != nil {
		return fmt.Errorf("derive notification key: %w", err)
	}
	wif, err := btcutil.NewWIF(notifPriv, p.network, true)
	if err != nil {
		return fmt.Errorf("encode notification wif: %w", err)
	}
	desc := mustAddChecksum(fmt.Sprintf("pkh(%s)", wif.String()))
	results, err := p.rpc.ImportDescriptors(ctx, walletName, []ImportDescriptor{{
		Desc:      desc,
		Active:    false,
		Timestamp: int64(0),
	}})
	if err != nil {
		return fmt.Errorf("import bip47 notification descriptor: %w", err)
	}
	for i, r := range results {
		if r.Success {
			continue
		}
		msg := "unknown"
		if r.Error != nil {
			msg = r.Error.Message
		}
		return fmt.Errorf("bip47 descriptor %d import failed: %s", i, msg)
	}
	return nil
}

// createBitcoinCoreWallet creates a Bitcoin Core descriptor wallet from a seed.
func (p *CoreProvider) createBitcoinCoreWallet(ctx context.Context, walletName, seedHex string) error {
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return fmt.Errorf("decode seed hex: %w", err)
	}

	masterKey, err := bip32.NewMasterKey(seed)
	if err != nil {
		return fmt.Errorf("create master key: %w", err)
	}

	// Derive BIP84 account: m/84'/coin'/0'
	purpose, err := masterKey.NewChildKey(bip32.FirstHardenedChild + 84)
	if err != nil {
		return fmt.Errorf("derive purpose: %w", err)
	}

	coin, err := purpose.NewChildKey(bip32.FirstHardenedChild + p.coinType())
	if err != nil {
		return fmt.Errorf("derive coin: %w", err)
	}

	account, err := coin.NewChildKey(bip32.FirstHardenedChild + 0)
	if err != nil {
		return fmt.Errorf("derive account: %w", err)
	}

	accountXprv := serializeKeyForNetwork(account, p.network)
	fingerprint := masterFingerprint(masterKey)
	coinType := p.coinType()

	// Build descriptors with checksum
	descriptors := []ImportDescriptor{
		{
			Desc:      mustAddChecksum(fmt.Sprintf("wpkh([%s/84'/%d'/0']%s/0/*)", fingerprint, coinType, accountXprv)),
			Active:    true,
			Timestamp: "now",
			Internal:  false,
			Range:     []int{0, 999},
		},
		{
			Desc:      mustAddChecksum(fmt.Sprintf("wpkh([%s/84'/%d'/0']%s/1/*)", fingerprint, coinType, accountXprv)),
			Active:    true,
			Timestamp: "now",
			Internal:  true,
			Range:     []int{0, 999},
		},
	}

	return p.createAndImport(ctx, walletName, false, descriptors)
}

// createWatchOnlyWallet creates a watch-only Bitcoin Core wallet.
func (p *CoreProvider) createWatchOnlyWallet(ctx context.Context, walletName string, w *WalletData) error {
	if w.WatchOnly == nil {
		return fmt.Errorf("watch-only wallet missing watch_only data")
	}

	var watchOnly struct {
		Descriptor string `json:"descriptor"`
		Xpub       string `json:"xpub"`
	}
	if err := json.Unmarshal(w.WatchOnly, &watchOnly); err != nil {
		return fmt.Errorf("parse watch_only: %w", err)
	}

	var descriptors []ImportDescriptor
	if watchOnly.Descriptor != "" {
		desc := watchOnly.Descriptor
		if !strings.Contains(desc, "#") {
			var err error
			desc, err = AddDescriptorChecksum(desc)
			if err != nil {
				return fmt.Errorf("add checksum: %w", err)
			}
		}
		descriptors = append(descriptors, ImportDescriptor{
			Desc:      desc,
			Active:    true,
			Timestamp: "now",
			Range:     []int{0, 1000},
		})
	} else if watchOnly.Xpub != "" {
		descriptors = append(descriptors,
			ImportDescriptor{
				Desc:      mustAddChecksum(fmt.Sprintf("wpkh(%s/0/*)", watchOnly.Xpub)),
				Active:    true,
				Timestamp: "now",
				Range:     []int{0, 1000},
			},
			ImportDescriptor{
				Desc:      mustAddChecksum(fmt.Sprintf("wpkh(%s/1/*)", watchOnly.Xpub)),
				Active:    true,
				Timestamp: "now",
				Internal:  true,
				Range:     []int{0, 1000},
			},
		)
	} else {
		return fmt.Errorf("watch-only wallet requires descriptor or xpub")
	}

	return p.createAndImport(ctx, walletName, true, descriptors)
}

// createAndImport creates a Core wallet and imports descriptors.
func (p *CoreProvider) createAndImport(ctx context.Context, walletName string, disablePrivateKeys bool, descriptors []ImportDescriptor) error {
	existing, err := p.rpc.ListWallets(ctx)
	if err != nil {
		return fmt.Errorf("list wallets: %w", err)
	}

	found := false
	for _, w := range existing {
		if w == walletName {
			found = true
			break
		}
	}

	if !found {
		if err := p.rpc.CreateWallet(ctx, walletName, disablePrivateKeys, true); err != nil {
			if strings.Contains(err.Error(), "already exists") {
				if loadErr := p.rpc.LoadWallet(ctx, walletName); loadErr != nil {
					return fmt.Errorf("load existing wallet: %w", loadErr)
				}
			} else {
				return fmt.Errorf("create wallet: %w", err)
			}
		}

		results, err := p.rpc.ImportDescriptors(ctx, walletName, descriptors)
		if err != nil {
			return fmt.Errorf("import descriptors: %w", err)
		}

		for i, r := range results {
			if !r.Success {
				errMsg := "unknown"
				if r.Error != nil {
					errMsg = r.Error.Message
				}
				return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
			}
		}

		p.log.Info().Str("wallet", walletName).Msg("created Bitcoin Core wallet")
	}

	return nil
}

// bech32Prefix returns the HRP-with-separator prefix that any BIP84 receive
// address on this network must start with — read directly off the typed
// chaincfg.Params instead of remapping a network name string.
func (p *CoreProvider) bech32Prefix() string {
	if p.network == nil {
		return ""
	}
	return p.network.Bech32HRPSegwit + "1"
}

// coinType returns the BIP44 coin type for the network.
func (p *CoreProvider) coinType() uint32 {
	return p.network.HDCoinType
}
