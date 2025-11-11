package engines

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"sync"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

const (
	// Derivation path for cheques: m/44'/0'/999'/{index}
	chequeAccount = 999

	// ChequeWalletName is the name of the watch-only Bitcoin Core wallet for cheques
	ChequeWalletName = "cheque_watch"
)

// ChequeRecovery represents a recovered cheque with funds
type ChequeRecovery struct {
	Index   uint32
	Address string
	Amount  uint64
	Txid    string
}

// ChequeEngine manages in-memory seed for cheque derivation
type ChequeEngine struct {
	mu          sync.RWMutex
	seedHex     string
	isUnlocked  bool
	unlockCond  *sync.Cond
	chainParams *chaincfg.Params
	bitcoind    *service.Service[corerpc.BitcoinServiceClient]
}

// NewChequeEngine creates a new cheque engine
func NewChequeEngine(chainParams *chaincfg.Params, bitcoind *service.Service[corerpc.BitcoinServiceClient]) *ChequeEngine {
	e := &ChequeEngine{
		isUnlocked:  false,
		chainParams: chainParams,
		bitcoind:    bitcoind,
	}
	e.unlockCond = sync.NewCond(&e.mu)
	return e
}

// GetChainParams returns the chain parameters
func (e *ChequeEngine) GetChainParams() *chaincfg.Params {
	return e.chainParams
}

// Unlock loads the seed into memory from decrypted wallet data
func (e *ChequeEngine) Unlock(walletData map[string]any) error {
	e.mu.Lock()
	defer e.mu.Unlock()

	// Handle new multi-wallet structure: { version, activeWalletId, wallets: [...] }
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
	for _, w := range wallets {
		wallet, ok := w.(map[string]any)
		if !ok {
			continue
		}

		walletId, _ := wallet["id"].(string)
		if activeWalletId == "" || walletId == activeWalletId {
			activeWallet = wallet
			break
		}
	}

	if activeWallet == nil {
		return errors.New("active wallet not found in wallets array")
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

	e.seedHex = seedHex
	e.isUnlocked = true
	e.unlockCond.Broadcast()
	return nil
}

// Lock clears the seed from memory
func (e *ChequeEngine) Lock() {
	e.mu.Lock()
	defer e.mu.Unlock()

	// Zero out the seed for security
	if e.seedHex != "" {
		// Create a new string of zeros
		zeros := make([]byte, len(e.seedHex))
		e.seedHex = string(zeros)
	}
	e.seedHex = ""
	e.isUnlocked = false
}

// IsUnlocked returns whether the engine is unlocked
func (e *ChequeEngine) IsUnlocked() bool {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.isUnlocked
}

// deriveChequeKey derives the HD key at m/44'/0'/999'/{index}
func (e *ChequeEngine) deriveChequeKey(index uint32) (*hdkeychain.ExtendedKey, error) {
	seedBytes, err := hex.DecodeString(e.seedHex)
	if err != nil {
		return nil, fmt.Errorf("failed to decode seed: %w", err)
	}

	masterKey, err := hdkeychain.NewMaster(seedBytes, e.chainParams)
	if err != nil {
		return nil, fmt.Errorf("failed to create master key: %w", err)
	}

	// m/44'
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 44)
	if err != nil {
		return nil, fmt.Errorf("failed to derive purpose: %w", err)
	}

	// m/44'/0'
	coinType, err := purpose.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		return nil, fmt.Errorf("failed to derive coin type: %w", err)
	}

	// m/44'/0'/999'
	chequeAcct, err := coinType.Derive(hdkeychain.HardenedKeyStart + chequeAccount)
	if err != nil {
		return nil, fmt.Errorf("failed to derive cheque account: %w", err)
	}

	// m/44'/0'/999'/{index} - index is NOT hardened per BIP44
	chequeKey, err := chequeAcct.Derive(index)
	if err != nil {
		return nil, fmt.Errorf("failed to derive cheque key: %w", err)
	}

	return chequeKey, nil
}

// DeriveChequeAddress derives the native segwit address at m/44'/0'/999'/{index}
func (e *ChequeEngine) DeriveChequeAddress(index uint32) (string, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	if !e.isUnlocked {
		return "", errors.New("cheque engine is locked")
	}

	chequeKey, err := e.deriveChequeKey(index)
	if err != nil {
		return "", err
	}

	// Get the public key
	pubKey, err := chequeKey.ECPubKey()
	if err != nil {
		return "", fmt.Errorf("failed to get public key: %w", err)
	}

	// Create native segwit (P2WPKH) address
	pubKeyHash := btcutil.Hash160(pubKey.SerializeCompressed())
	address, err := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, e.chainParams)
	if err != nil {
		return "", fmt.Errorf("failed to create witness address: %w", err)
	}

	return address.EncodeAddress(), nil
}

// DeriveChequePrivateKey derives the WIF private key at m/44'/0'/999'/{index}
func (e *ChequeEngine) DeriveChequePrivateKey(index uint32) (string, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	if !e.isUnlocked {
		return "", errors.New("cheque engine is locked")
	}

	chequeKey, err := e.deriveChequeKey(index)
	if err != nil {
		return "", err
	}

	privKey, err := chequeKey.ECPrivKey()
	if err != nil {
		return "", fmt.Errorf("failed to get private key: %w", err)
	}

	wif, err := btcutil.NewWIF(privKey, e.chainParams, true)
	if err != nil {
		return "", fmt.Errorf("failed to create WIF: %w", err)
	}

	return wif.String(), nil
}

// ScanForFunds scans the first count addresses for UTXOs
func (e *ChequeEngine) ScanForFunds(ctx context.Context, bitcoind corerpc.BitcoinServiceClient, count int) ([]ChequeRecovery, error) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	if !e.isUnlocked {
		return nil, errors.New("cheque engine is locked")
	}

	log := zerolog.Ctx(ctx)
	var recoveries []ChequeRecovery

	for i := uint32(0); i < uint32(count); i++ {
		address, err := e.deriveChequeAddressUnlocked(i)
		if err != nil {
			log.Warn().Err(err).Uint32("index", i).Msg("failed to derive address during scan")
			continue
		}

		// Query bitcoind for UTXOs on this address using cheque wallet
		utxos, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
			MinimumConfirmations: lo.ToPtr(uint32(0)), // Include unconfirmed
			Addresses:            []string{address},
			Wallet:               ChequeWalletName,
		}))

		if err != nil {
			log.Warn().Err(err).Str("address", address).Msg("failed to query UTXOs")
			continue
		}

		if len(utxos.Msg.Unspent) > 0 {
			// Calculate total amount
			var totalAmount float64
			var txid string
			for _, utxo := range utxos.Msg.Unspent {
				totalAmount += utxo.Amount
				txid = utxo.Txid
			}

			// Convert BTC to satoshis
			amountSats := uint64(totalAmount * 100000000)

			recoveries = append(recoveries, ChequeRecovery{
				Index:   i,
				Address: address,
				Amount:  amountSats,
				Txid:    txid,
			})

			log.Info().
				Uint32("index", i).
				Str("address", address).
				Uint64("amount_sats", amountSats).
				Msg("recovered funded cheque")
		}
	}

	return recoveries, nil
}

// deriveChequeAddressUnlocked is the same as DeriveChequeAddress but without locking
// Used internally when already holding the lock
func (e *ChequeEngine) deriveChequeAddressUnlocked(index uint32) (string, error) {
	if !e.isUnlocked {
		return "", errors.New("cheque engine is locked")
	}

	chequeKey, err := e.deriveChequeKey(index)
	if err != nil {
		return "", err
	}

	// Get the public key
	pubKey, err := chequeKey.ECPubKey()
	if err != nil {
		return "", fmt.Errorf("failed to get public key: %w", err)
	}

	// Create native segwit (P2WPKH) address
	pubKeyHash := btcutil.Hash160(pubKey.SerializeCompressed())
	address, err := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, e.chainParams)
	if err != nil {
		return "", fmt.Errorf("failed to create witness address: %w", err)
	}

	return address.EncodeAddress(), nil
}

// Start begins the cheque engine background monitoring
func (e *ChequeEngine) Start(ctx context.Context) {
	log := zerolog.Ctx(ctx)
	log.Info().Msg("cheque engine started")

	// Import cheque descriptor into Bitcoin Core so it tracks all cheque addresses
	go e.importChequeDescriptor(ctx)

	// Cheque recovery waits for unlock since it needs to derive addresses
	go e.recoverChequesOnUnlock(ctx)
}

// importChequeDescriptor imports the cheque derivation path descriptor into Bitcoin Core
// This allows Core to automatically track all cheque addresses without individual imports
func (e *ChequeEngine) importChequeDescriptor(ctx context.Context) {
	log := zerolog.Ctx(ctx)

	// Wait for wallet to be unlocked so we can access the seed
	e.mu.Lock()
	for !e.isUnlocked {
		e.unlockCond.Wait()
	}
	seedHex := e.seedHex
	e.mu.Unlock()

	if seedHex == "" {
		log.Warn().Msg("cannot import cheque descriptor: wallet not unlocked")
		return
	}

	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		log.Warn().Err(err).Msg("failed to get bitcoind for descriptor import")
		return
	}

	seedBytes, err := hex.DecodeString(seedHex)
	if err != nil {
		log.Error().Err(err).Msg("failed to decode seed for descriptor import")
		return
	}

	// Create master key and derive to account level m/44'/0'/999'
	masterKey, err := hdkeychain.NewMaster(seedBytes, e.chainParams)
	if err != nil {
		log.Error().Err(err).Msg("failed to create master key for descriptor")
		return
	}

	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 44)
	if err != nil {
		log.Error().Err(err).Msg("failed to derive purpose")
		return
	}

	coinType, err := purpose.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		log.Error().Err(err).Msg("failed to derive coin type")
		return
	}

	chequeAcct, err := coinType.Derive(hdkeychain.HardenedKeyStart + chequeAccount)
	if err != nil {
		log.Error().Err(err).Msg("failed to derive cheque account")
		return
	}

	// Get the xpub for the account level
	xpub := chequeAcct.String()

	// Create wpkh descriptor without checksum first
	descriptorWithoutChecksum := fmt.Sprintf("wpkh(%s/*)", xpub)

	// Get Bitcoin Core to add the checksum for us using GetDescriptorInfo
	descInfo, err := bitcoind.GetDescriptorInfo(ctx, connect.NewRequest(&corepb.GetDescriptorInfoRequest{
		Descriptor_: descriptorWithoutChecksum,
	}))
	if err != nil {
		log.Error().Err(err).Msg("failed to get descriptor info")
		return
	}

	// Use the descriptor with checksum from Bitcoin Core
	descriptor := descInfo.Msg.Descriptor_

	// Import the descriptor into Bitcoin Core cheque wallet
	resp, err := bitcoind.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet: ChequeWalletName,
		Requests: []*corepb.ImportDescriptorsRequest_Request{
			{
				Descriptor_: descriptor,
				Active:      true, // Must be active for range to work
				RangeStart:  0,
				RangeEnd:    1000, // Watch first 1000 addresses
				Timestamp:   nil,  // nil = "now", don't rescan
				Internal:    false,
			},
		},
	}))

	if err != nil {
		log.Error().Err(err).Msg("failed to import cheque descriptor")
		return
	}

	// Check if import was successful
	if len(resp.Msg.Responses) > 0 {
		if resp.Msg.Responses[0].Success {
			log.Info().Msg("cheque descriptor imported successfully")
		} else {
			// Log the warnings/errors for debugging
			if len(resp.Msg.Responses[0].Warnings) > 0 {
				log.Warn().Strs("warnings", resp.Msg.Responses[0].Warnings).Msg("cheque descriptor import had warnings")
			}
			if resp.Msg.Responses[0].Error != nil {
				log.Error().Str("error", resp.Msg.Responses[0].Error.Message).Msg("cheque descriptor import failed")
			}
		}
	}
}

// recoverChequesOnUnlock waits for wallet unlock and bitcoind, then recovers cheques once
func (e *ChequeEngine) recoverChequesOnUnlock(ctx context.Context) {
	log := zerolog.Ctx(ctx)

	// Wait for unlock
	log.Debug().Msg("waiting for wallet unlock for cheque recovery")
	unlocked := make(chan struct{})
	go func() {
		e.mu.Lock()
		for !e.isUnlocked {
			e.unlockCond.Wait()
		}
		e.mu.Unlock()
		close(unlocked)
	}()

	select {
	case <-ctx.Done():
		return
	case <-unlocked:
	}

	log.Info().Msg("wallet unlocked, waiting for bitcoind for cheque recovery")

	// Wait for bitcoind to connect
	var connected bool
	for !connected {
		select {
		case <-ctx.Done():
			return
		case connected = <-e.bitcoind.ConnectedChan():
			if !connected {
				log.Debug().Msg("bitcoind disconnected, waiting for reconnection")
			}
		}
	}

	log.Info().Msg("bitcoind connected, recovering cheques")

	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		log.Error().Err(err).Msg("failed to get bitcoind client for recovery")
		return
	}

	recoveries, err := e.ScanForFunds(ctx, bitcoind, 20)
	if err != nil {
		log.Error().Err(err).Msg("failed to scan for cheque funds")
		return
	}

	if len(recoveries) == 0 {
		log.Info().Msg("no funded cheques found during recovery scan")
		return
	}

	log.Info().Int("count", len(recoveries)).Msg("found funded cheques during recovery scan")
}
