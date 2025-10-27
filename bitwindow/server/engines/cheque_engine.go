package engines

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"sync"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
)

const (
	// Derivation path for cheques: m/44'/0'/999'/{index}
	chequeAccount = 999
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
	chainParams *chaincfg.Params
}

// NewChequeEngine creates a new cheque engine
func NewChequeEngine(chainParams *chaincfg.Params) *ChequeEngine {
	return &ChequeEngine{
		isUnlocked:  false,
		chainParams: chainParams,
	}
}

// Unlock loads the seed into memory from decrypted wallet data
func (e *ChequeEngine) Unlock(walletData map[string]interface{}) error {
	e.mu.Lock()
	defer e.mu.Unlock()

	master, ok := walletData["master"].(map[string]interface{})
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

	// m/44'/0'/999'/{index}
	chequeKey, err := chequeAcct.Derive(hdkeychain.HardenedKeyStart + index)
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

		// Query bitcoind for UTXOs on this address
		utxos, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
			Addresses: []string{address},
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
