package engines

import (
	"context"
	"encoding/hex"
	"fmt"
	"time"

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

// ChequeEngine manages cheque derivation (ONLY)
// Gets seed from WalletEngine when needed
type ChequeEngine struct {
	walletEngine *WalletEngine
	chainParams  *chaincfg.Params
	bitcoind     *service.Service[corerpc.BitcoinServiceClient]
}

// NewChequeEngine creates a new cheque engine
func NewChequeEngine(
	walletEngine *WalletEngine,
	chainParams *chaincfg.Params,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
) *ChequeEngine {
	return &ChequeEngine{
		walletEngine: walletEngine,
		chainParams:  chainParams,
		bitcoind:     bitcoind,
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
func (e *ChequeEngine) DeriveChequeAddress(index uint32) (string, error) {
	// Get seed from wallet engine
	seedHex, err := e.walletEngine.GetSeed()
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
func (e *ChequeEngine) DeriveChequePrivateKey(index uint32) (string, error) {
	// Get seed from wallet engine
	seedHex, err := e.walletEngine.GetSeed()
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

// ScanForFunds scans the first count addresses for UTXOs
func (e *ChequeEngine) ScanForFunds(ctx context.Context, bitcoind corerpc.BitcoinServiceClient, count int) ([]ChequeRecovery, error) {
	// Get seed from wallet engine
	seedHex, err := e.walletEngine.GetSeed()
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
func (e *ChequeEngine) importChequeDescriptor(ctx context.Context) {
	log := zerolog.Ctx(ctx)

	// Wait for wallet to be unlocked
	for !e.walletEngine.IsUnlocked() {
		select {
		case <-ctx.Done():
			return
		case <-time.After(100 * time.Millisecond):
			// Check again
		}
	}

	seedHex, err := e.walletEngine.GetSeed()
	if err != nil {
		log.Warn().Err(err).Msg("cannot import cheque descriptor: wallet not unlocked")
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
				Active:      true,
				RangeStart:  0,
				RangeEnd:    1000,
				Timestamp:   nil,
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

	for !e.walletEngine.IsUnlocked() {
		select {
		case <-ctx.Done():
			return
		case <-time.After(100 * time.Millisecond):
			// Check again
		}
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
