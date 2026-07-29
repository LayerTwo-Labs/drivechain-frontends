package engines

import (
	"context"
	"encoding/hex"
	"fmt"
	"sync/atomic"
	"time"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
)

// Derivation path for cheques: m/44'/0'/999'/{index}
const chequeAccount = 999

// ChequeRecovery represents a recovered cheque with funds
type ChequeRecovery struct {
	Index   uint32
	Address string
	Amount  uint64
	Txid    string
}

// ChequeEngine manages cheque derivation (ONLY)
// Gets seed from WalletEngine when needed
type ChequeEngine struct {
	walletEngine *WalletEngine
	chainParams  *chaincfg.Params
	chain        ChequeChain
}

// NewChequeEngine creates a new cheque engine
func NewChequeEngine(walletEngine *WalletEngine, chainParams *chaincfg.Params, chain ChequeChain) *ChequeEngine {
	return &ChequeEngine{
		walletEngine: walletEngine,
		chainParams:  chainParams,
		chain:        chain,
	}
}

// GetChainParams returns the chain parameters
func (e *ChequeEngine) GetChainParams() *chaincfg.Params {
	return e.chainParams
}

// deriveChequeKey derives the HD key at m/44'/0'/999'/{index}
func (e *ChequeEngine) deriveChequeKey(seedHex string, index uint32) (*hdkeychain.ExtendedKey, error) {
	seedBytes, err := hex.DecodeString(seedHex)
	if err != nil {
		return nil, fmt.Errorf("decode seed: %w", err)
	}

	masterKey, err := hdkeychain.NewMaster(seedBytes, e.chainParams)
	if err != nil {
		return nil, fmt.Errorf("create master key: %w", err)
	}

	// m/44'
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 44)
	if err != nil {
		return nil, fmt.Errorf("derive purpose: %w", err)
	}

	// m/44'/0'
	coinType, err := purpose.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		return nil, fmt.Errorf("derive coin type: %w", err)
	}

	// m/44'/0'/999'
	chequeAcct, err := coinType.Derive(hdkeychain.HardenedKeyStart + chequeAccount)
	if err != nil {
		return nil, fmt.Errorf("derive cheque account: %w", err)
	}

	// m/44'/0'/999'/{index} - index is NOT hardened per BIP44
	chequeKey, err := chequeAcct.Derive(index)
	if err != nil {
		return nil, fmt.Errorf("derive cheque key: %w", err)
	}

	return chequeKey, nil
}

// DeriveChequeAddress derives the native segwit address at m/44'/0'/999'/{index}
// for a specific wallet
func (e *ChequeEngine) DeriveChequeAddress(walletId string, index uint32) (string, error) {
	// Get seed from wallet engine for the specific wallet
	seedHex, err := e.walletEngine.GetWalletSeed(walletId)
	if err != nil {
		return "", err
	}

	chequeKey, err := e.deriveChequeKey(seedHex, index)
	if err != nil {
		return "", err
	}

	// Get the public key
	pubKey, err := chequeKey.ECPubKey()
	if err != nil {
		return "", fmt.Errorf("get public key: %w", err)
	}

	// Create native segwit (P2WPKH) address
	pubKeyHash := btcutil.Hash160(pubKey.SerializeCompressed())
	address, err := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, e.chainParams)
	if err != nil {
		return "", fmt.Errorf("create witness address: %w", err)
	}

	return address.EncodeAddress(), nil
}

// DeriveChequePrivateKey derives the WIF private key at m/44'/0'/999'/{index}
// for a specific wallet
func (e *ChequeEngine) DeriveChequePrivateKey(walletId string, index uint32) (string, error) {
	// Get seed from wallet engine for the specific wallet
	seedHex, err := e.walletEngine.GetWalletSeed(walletId)
	if err != nil {
		return "", err
	}

	chequeKey, err := e.deriveChequeKey(seedHex, index)
	if err != nil {
		return "", err
	}

	privKey, err := chequeKey.ECPrivKey()
	if err != nil {
		return "", fmt.Errorf("get private key: %w", err)
	}

	wif, err := btcutil.NewWIF(privKey, e.chainParams, true)
	if err != nil {
		return "", fmt.Errorf("create WIF: %w", err)
	}

	return wif.String(), nil
}

// ScanForFunds scans the first count addresses for UTXOs for a specific wallet
func (e *ChequeEngine) ScanForFunds(ctx context.Context, walletId string, count int) ([]ChequeRecovery, error) {
	// Get seed from wallet engine for the specific wallet
	seedHex, err := e.walletEngine.GetWalletSeed(walletId)
	if err != nil {
		return nil, err
	}

	log := zerolog.Ctx(ctx)
	var recoveries []ChequeRecovery

	for i := uint32(0); i < uint32(count); i++ {
		chequeKey, err := e.deriveChequeKey(seedHex, i)
		if err != nil {
			log.Warn().Err(err).Uint32("index", i).Msg("failed to derive key during scan")
			continue
		}

		pubKey, err := chequeKey.ECPubKey()
		if err != nil {
			log.Warn().Err(err).Uint32("index", i).Msg("failed to get public key during scan")
			continue
		}

		pubKeyHash := btcutil.Hash160(pubKey.SerializeCompressed())
		addr, err := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, e.chainParams)
		if err != nil {
			log.Warn().Err(err).Uint32("index", i).Msg("failed to create address during scan")
			continue
		}

		address := addr.EncodeAddress()

		utxos, err := e.chain.AddressUnspent(ctx, address, time.Unix(0, 0))
		if err != nil {
			log.Warn().Err(err).Str("address", address).Msg("failed to query UTXOs")
			continue
		}

		if len(utxos) > 0 {
			var amountSats uint64
			var txid string
			for _, utxo := range utxos {
				amountSats += uint64(utxo.ValueSats)
				txid = utxo.TxID
			}

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

// Start begins the cheque engine background monitoring. Returned channel
// closes once both background goroutines have exited; runtime/test
// shutdown should block on it so in-flight bitcoind RPC calls don't race
// the gomock controller's teardown (calling t.Fatalf from a goroutine
// after the test ended panics).
func (e *ChequeEngine) Start(ctx context.Context) <-chan struct{} {
	log := zerolog.Ctx(ctx)
	log.Info().Msg("cheque engine started")

	done := make(chan struct{})
	var pending atomic.Int32
	pending.Store(1)
	finish := func() {
		if pending.Add(-1) == 0 {
			close(done)
		}
	}

	// Cheque recovery waits for unlock since it needs to derive addresses
	go func() {
		defer finish()
		e.recoverChequesOnUnlock(ctx)
	}()

	return done
}

// recoverChequesOnUnlock waits for wallet unlock and bitcoind, then recovers cheques for all wallets
func (e *ChequeEngine) recoverChequesOnUnlock(ctx context.Context) {
	log := zerolog.Ctx(ctx)

	// Wait for unlock
	log.Debug().Msg("waiting for wallet unlock for cheque recovery")

	for !e.walletEngine.IsUnlocked() {
		select {
		case <-ctx.Done():
			return
		case <-time.After(100 * time.Millisecond):
			// Check again
		}
	}

	log.Info().Msg("wallet unlocked, recovering cheques for all wallets")

	wallets, err := e.walletEngine.GetAllWallets(ctx)
	if err != nil {
		log.Error().Err(err).Msg("failed to get wallets for cheque recovery")
		return
	}

	totalRecoveries := 0
	for _, wallet := range wallets {
		recoveries, err := e.ScanForFunds(ctx, wallet.ID, 20)
		if err != nil {
			log.Warn().Err(err).Str("wallet_id", wallet.ID).Msg("failed to scan wallet for cheque funds")
			continue
		}

		if len(recoveries) > 0 {
			log.Info().
				Str("wallet_id", wallet.ID).
				Int("count", len(recoveries)).
				Msg("found funded cheques during recovery scan")
			totalRecoveries += len(recoveries)
		}
	}

	if totalRecoveries == 0 {
		log.Info().Msg("no funded cheques found during recovery scan across all wallets")
	} else {
		log.Info().Int("total_count", totalRecoveries).Msg("cheque recovery scan complete")
	}
}
