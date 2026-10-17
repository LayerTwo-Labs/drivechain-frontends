package engines

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
)

// Derivation path for cheques: m/44'/0'/999'/{index}
const chequeAccount = 999

type ChequeRecovery struct {
	Index   uint32
	Address string
	Amount  uint64
	Outputs []cheques.FundingOutput
}

// ChequeEngine derives cheque keys from the wallet seed, and reads their
// addresses off the chain.
type ChequeEngine struct {
	db           *sql.DB
	walletEngine *WalletEngine
	chainParams  *chaincfg.Params
	chain        ChequeChain
	scanRetry    time.Duration
}

func NewChequeEngine(db *sql.DB, walletEngine *WalletEngine, chainParams *chaincfg.Params, chain ChequeChain) *ChequeEngine {
	return &ChequeEngine{
		db:           db,
		walletEngine: walletEngine,
		chainParams:  chainParams,
		chain:        chain,
		scanRetry:    10 * time.Second,
	}
}

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
func (e *ChequeEngine) DeriveChequeAddress(ctx context.Context, walletID string, index uint32) (string, error) {
	seedHex, err := e.walletEngine.GetWalletSeed(ctx, walletID)
	if err != nil {
		return "", err
	}

	return e.chequeAddress(seedHex, index)
}

// chequeAddress derives the native segwit (P2WPKH) address at
// m/44'/0'/999'/{index}.
func (e *ChequeEngine) chequeAddress(seedHex string, index uint32) (string, error) {
	chequeKey, err := e.deriveChequeKey(seedHex, index)
	if err != nil {
		return "", err
	}

	pubKey, err := chequeKey.ECPubKey()
	if err != nil {
		return "", fmt.Errorf("get public key: %w", err)
	}

	pubKeyHash := btcutil.Hash160(pubKey.SerializeCompressed())
	address, err := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, e.chainParams)
	if err != nil {
		return "", fmt.Errorf("create witness address: %w", err)
	}

	return address.EncodeAddress(), nil
}

// DeriveChequePrivateKey derives the WIF private key at m/44'/0'/999'/{index}
func (e *ChequeEngine) DeriveChequePrivateKey(ctx context.Context, walletID string, index uint32) (string, error) {
	seedHex, err := e.walletEngine.GetWalletSeed(ctx, walletID)
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

// chequeGapLimit is the number of empty cheque indices in a row after the
// stored counter that ends a recovery scan.
const chequeGapLimit = 20

// ScanForFunds reads each cheque address from index 0 until gapLimit indices
// in a row at or above the stored counter hold no UTXO.
func (e *ChequeEngine) ScanForFunds(ctx context.Context, walletID string, gapLimit int) ([]ChequeRecovery, error) {
	seedHex, err := e.walletEngine.GetWalletSeed(ctx, walletID)
	if err != nil {
		return nil, err
	}
	nextIndex, err := cheques.GetNextIndex(ctx, e.db, walletID)
	if err != nil {
		return nil, err
	}

	log := zerolog.Ctx(ctx)
	var recoveries []ChequeRecovery

	empty := 0
	for i := uint32(0); empty < gapLimit; i++ {
		address, err := e.chequeAddress(seedHex, i)
		if err != nil {
			return nil, fmt.Errorf("derive cheque address %d: %w", i, err)
		}

		utxos, err := e.chain.AddressUnspent(ctx, address)
		if err != nil {
			return nil, fmt.Errorf("read cheque address %s: %w", address, err)
		}
		if len(utxos) == 0 {
			if i >= nextIndex {
				empty++
			}
			continue
		}
		empty = 0

		var amountSats uint64
		var outputs []cheques.FundingOutput
		for _, utxo := range utxos {
			amountSats += uint64(utxo.ValueSats)
			outputs = append(outputs, cheques.FundingOutput{Txid: utxo.TxID, BlockHeight: utxo.Height})
		}

		recoveries = append(recoveries, ChequeRecovery{
			Index:   i,
			Address: address,
			Amount:  amountSats,
			Outputs: outputs,
		})

		log.Info().
			Uint32("index", i).
			Str("address", address).
			Uint64("amount_sats", amountSats).
			Msg("recovered funded cheque")
	}

	return recoveries, nil
}

// ChequeFunding is what a cheque address holds.
type ChequeFunding struct {
	Funded           bool
	AmountSats       uint64
	Txids            []string
	MinConfirmations uint32
	FundedAt         *time.Time
}

// CheckFunding reads the coins at the cheque address and stores them. A cheque
// with stored funds and no coins left becomes swept.
func (e *ChequeEngine) CheckFunding(ctx context.Context, cheque *cheques.Cheque) (ChequeFunding, error) {
	log := zerolog.Ctx(ctx)

	utxos, err := e.chain.AddressUnspent(ctx, cheque.Address)
	if err != nil {
		return ChequeFunding{}, connect.NewError(connect.CodeUnavailable, fmt.Errorf("query UTXOs of %s: %w", cheque.Address, err))
	}

	log.Debug().
		Str("address", cheque.Address).
		Int("utxo_count", len(utxos)).
		Msg("check cheque funding: UTXOs found")

	if len(utxos) == 0 {
		if len(cheque.FundedTxids) > 0 && cheque.SweptTxid == nil {
			log.Warn().
				Str("address", cheque.Address).
				Int64("id", cheque.ID).
				Msg("funded cheque has no UTXOs - was swept externally")

			// Only a full chain scan finds the spending tx of a watched address.
			if err := cheques.UpdateSwept(ctx, e.db, cheque.WalletID, cheque.ID, "swept_externally"); err != nil {
				return ChequeFunding{}, connect.NewError(connect.CodeInternal, fmt.Errorf("mark cheque swept: %w", err))
			}
		}
		return ChequeFunding{}, nil
	}

	funding := ChequeFunding{MinConfirmations: math.MaxUint32}
	var outputs []cheques.FundingOutput
	for _, utxo := range utxos {
		funding.AmountSats += uint64(utxo.ValueSats)
		funding.Txids = append(funding.Txids, utxo.TxID)
		outputs = append(outputs, cheques.FundingOutput{Txid: utxo.TxID, BlockHeight: utxo.Height})
		funding.MinConfirmations = min(funding.MinConfirmations, uint32(utxo.Confirmations))
	}

	if err := cheques.UpdateFunding(ctx, e.db, cheque.WalletID, cheque.ID, outputs, funding.AmountSats); err != nil {
		return ChequeFunding{}, connect.NewError(connect.CodeInternal, fmt.Errorf("update funding: %w", err))
	}

	log.Info().
		Int64("id", cheque.ID).
		Str("address", cheque.Address).
		Uint64("amount_sats", funding.AmountSats).
		Int("utxo_count", len(funding.Txids)).
		Msg("cheque funded")

	updated, err := cheques.Get(ctx, e.db, cheque.WalletID, cheque.ID)
	if err != nil {
		return ChequeFunding{}, connect.NewError(connect.CodeInternal, fmt.Errorf("refetch cheque: %w", err))
	}
	funding.Funded = updated.IsFunded()
	funding.FundedAt = updated.FundedAt
	return funding, nil
}

// ChequeSweep is a broadcast sweep.
type ChequeSweep struct {
	Txid           string
	AmountSats     uint64
	FeeSatPerVbyte uint64
}

// Sweep sends all coins of a private key to destination. If the key is a
// cheque of the wallet, the cheque becomes swept.
func (e *ChequeEngine) Sweep(
	ctx context.Context, walletID string, wifKey *btcutil.WIF, destination string, feeSatPerVbyte uint64,
) (ChequeSweep, error) {
	log := zerolog.Ctx(ctx)

	source, err := ResolveSweepSource(ctx, e.chain, wifKey, e.chainParams)
	if err != nil {
		return ChequeSweep{}, connect.NewError(connect.CodeUnavailable, fmt.Errorf("query UTXOs: %w", err))
	}
	if len(source.UTXOs) == 0 {
		return ChequeSweep{}, connect.NewError(connect.CodeNotFound, errors.New("no funds found at this address"))
	}

	totalAmount := source.TotalSats()

	log.Debug().Str("address", source.Address).Str("kind", source.Kind.String()).Msg("sweep cheque: sweeping")

	cheque, err := cheques.GetByAddress(ctx, e.db, walletID, source.Address)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		log.Debug().Str("address", source.Address).Msg("swept key is not a cheque of this wallet")
	case err != nil:
		return ChequeSweep{}, connect.NewError(connect.CodeInternal, fmt.Errorf("find cheque at %s: %w", source.Address, err))
	}

	feeSatPerVbyte, err = e.SweepFeeRate(ctx, feeSatPerVbyte)
	if err != nil {
		return ChequeSweep{}, err
	}

	unsignedTx, err := BuildSweepTx(source, destination, feeSatPerVbyte, e.chainParams)
	switch {
	case errors.Is(err, ErrInvalidSweep):
		return ChequeSweep{}, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("build transaction: %w", err))
	case err != nil:
		return ChequeSweep{}, connect.NewError(connect.CodeInternal, fmt.Errorf("build transaction: %w", err))
	}

	signedTx, err := SignSweepTx(unsignedTx, source, wifKey, e.chainParams)
	if err != nil {
		return ChequeSweep{}, connect.NewError(connect.CodeInternal, fmt.Errorf("sign transaction: %w", err))
	}

	var txBytes bytes.Buffer
	if err := signedTx.Serialize(&txBytes); err != nil {
		return ChequeSweep{}, connect.NewError(connect.CodeInternal, fmt.Errorf("serialize transaction: %w", err))
	}

	txid, err := e.chain.Broadcast(ctx, hex.EncodeToString(txBytes.Bytes()))
	if err != nil {
		return ChequeSweep{}, fmt.Errorf("broadcast transaction: %w", err)
	}

	if cheque != nil && cheque.SweptTxid == nil {
		if err := cheques.UpdateSwept(ctx, e.db, walletID, cheque.ID, txid); err != nil {
			return ChequeSweep{}, connect.NewError(connect.CodeInternal, fmt.Errorf("mark cheque %d swept by %s: %w", cheque.ID, txid, err))
		}
	}

	log.Info().
		Str("from", source.Address).
		Str("to", destination).
		Str("txid", txid).
		Uint64("amount_sats", totalAmount).
		Msg("cheque swept successfully")

	return ChequeSweep{Txid: txid, AmountSats: totalAmount, FeeSatPerVbyte: feeSatPerVbyte}, nil
}

// SweepFeeRate gives the sweep fee rate in sat/vB: requested, or the 6-block
// estimate when requested is zero.
func (e *ChequeEngine) SweepFeeRate(ctx context.Context, requested uint64) (uint64, error) {
	if requested > 0 {
		return requested, nil
	}
	rate, err := e.chain.FeeRateSatPerVByte(ctx, 6)
	if err != nil {
		return 0, connect.NewError(connect.CodeUnavailable, fmt.Errorf("estimate fee: %w", err))
	}
	return uint64(math.Ceil(rate)), nil
}

// Start runs cheque recovery in the background. The returned channel closes
// when recovery exits.
func (e *ChequeEngine) Start(ctx context.Context) <-chan struct{} {
	log := zerolog.Ctx(ctx)
	log.Info().Msg("cheque engine started")

	done := make(chan struct{})
	go func() {
		defer close(done)
		e.recoverChequesOnUnlock(ctx)
	}()
	return done
}

// recoverChequesOnUnlock waits for wallet unlock, then recovers cheques for all wallets
func (e *ChequeEngine) recoverChequesOnUnlock(ctx context.Context) {
	log := zerolog.Ctx(ctx)

	log.Debug().Msg("waiting for wallet unlock for cheque recovery")

	for !e.walletEngine.IsUnlocked() {
		select {
		case <-ctx.Done():
			return
		case <-time.After(100 * time.Millisecond):
		}
	}

	log.Info().Msg("wallet unlocked, recovering cheques for all wallets")

	wallets, err := e.walletEngine.GetAllWallets(ctx)
	if err != nil {
		log.Error().Err(err).Msg("cheque recovery: get wallets")
		return
	}

	totalRecoveries := 0
	pending := wallets
	warned := map[string]bool{}
	for {
		var failed []WalletInfo
		for _, wallet := range pending {
			recoveries, err := e.ScanForFunds(ctx, wallet.ID, chequeGapLimit)
			if err != nil {
				if connect.CodeOf(err) == connect.CodeFailedPrecondition {
					log.Debug().Str("wallet_id", wallet.ID).Msg("cheque recovery: skip wallet with no seed")
					continue
				}
				// The chain source refuses reads while it boots, so scan again
				// later. A failure that stays is reported one time.
				level := zerolog.WarnLevel
				if IsBitcoinCoreStartupError(err.Error()) || warned[wallet.ID] {
					level = zerolog.DebugLevel
				}
				warned[wallet.ID] = true
				log.WithLevel(level).Err(err).Str("wallet_id", wallet.ID).Msg("scan wallet for cheque funds")
				failed = append(failed, wallet)
				continue
			}

			for _, recovery := range recoveries {
				if err := cheques.CreateOrUpdateFromRecovery(
					ctx, e.db, wallet.ID, recovery.Index, recovery.Address, recovery.Outputs, recovery.Amount,
				); err != nil {
					log.Error().Err(err).
						Str("wallet_id", wallet.ID).
						Uint32("index", recovery.Index).
						Msg("save recovered cheque")
					return
				}
			}

			if len(recoveries) > 0 {
				log.Info().
					Str("wallet_id", wallet.ID).
					Int("count", len(recoveries)).
					Msg("found funded cheques during recovery scan")
				totalRecoveries += len(recoveries)
			}
		}

		if len(failed) == 0 {
			break
		}
		pending = failed
		select {
		case <-ctx.Done():
			return
		case <-time.After(e.scanRetry):
		}
	}

	if totalRecoveries == 0 {
		log.Info().Msg("no funded cheques found during recovery scan across all wallets")
	} else {
		log.Info().Int("total_count", totalRecoveries).Msg("cheque recovery scan complete")
	}
}
