package engines

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"math/rand"
	"time"

	"connectrpc.com/connect"
	logpool "github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

type DeniabilityEngine struct {
	bitcoind     *service.Service[corerpc.BitcoinServiceClient]
	db           *sql.DB
	walletEngine *WalletEngine
}

func NewDeniability(
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	db *sql.DB,
	walletEngine *WalletEngine,
) *DeniabilityEngine {
	return &DeniabilityEngine{
		bitcoind:     bitcoind,
		db:           db,
		walletEngine: walletEngine,
	}
}

func (e *DeniabilityEngine) Run(ctx context.Context) error {
	logger := zerolog.Ctx(ctx)
	logger.Info().Msg("deniability: starting engine")
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			logger.Info().Msg("deniability: engine shutting down")
			return nil

		case <-ticker.C:
			// No readiness gate here. An electrum denial reads and spends over
			// Esplora, so waiting on Bitcoin Core would strand every denial on
			// a migrated wallet in light mode. Each backend reports its own
			// unavailability below.
			if err := e.checkDenials(ctx); err != nil {
				logger.Warn().Err(err).Msg("deniability: error checking denials")
			}
		}
	}
}

func (e *DeniabilityEngine) checkDenials(ctx context.Context) error {
	logger := zerolog.Ctx(ctx)

	utxos, denials, err := e.CleanupDenials(ctx)
	if err != nil {
		return fmt.Errorf("cleanup denials: %w", err)
	}

	now := time.Now()
	// cleanup complete lets start processing
	for _, denial := range denials {
		if denial.NextExecution == nil || now.Before(*denial.NextExecution) {
			continue
		}

		// A denial that just failed backs off, so a failure that persists does
		// not re-issue the same send on every tick.
		if denial.RetryAfter != nil && now.Before(*denial.RetryAfter) {
			continue
		}

		logger.Info().
			Int64("denial_id", denial.ID).
			Time("next_execution", *denial.NextExecution).
			Msg("deniability: executing denial")

		// It's time! Execute.
		execStart := time.Now()
		if err := e.ExecuteDenial(ctx, utxos, denial); err != nil {
			logger.Error().
				Err(err).
				Int64("denial_id", denial.ID).
				Dur("duration", time.Since(execStart)).
				Msg("deniability: could not execute denial")

			if ferr := e.recordDenialFailure(ctx, denial, err); ferr != nil {
				logger.Error().
					Err(ferr).
					Int64("denial_id", denial.ID).
					Msg("deniability: could not record failed denial")
			}
			continue
		}
		logger.Info().
			Int64("denial_id", denial.ID).
			Dur("duration", time.Since(execStart)).
			Msg("deniability: finished executing denial")
	}

	return nil
}

// maxDenialFailures is how many executions may fail in a row before the denial
// is given up on, so the user gets a reason instead of a retry that never ends.
const maxDenialFailures = 10

// recordDenialFailure backs the denial off, and cancels it once it has failed
// maxDenialFailures times in a row.
func (e *DeniabilityEngine) recordDenialFailure(ctx context.Context, denial deniability.Denial, cause error) error {
	attempts, err := deniability.RecordFailure(ctx, e.db, denial)
	if err != nil {
		return fmt.Errorf("record failure: %w", err)
	}

	if attempts < maxDenialFailures {
		return nil
	}

	return deniability.Cancel(ctx, e.db, denial.ID,
		fmt.Sprintf("cancelled after %d failed attempts: %s", attempts, cause))
}

// UTXO is one spendable output. Bitcoin Core and electrum report different
// shapes, and both convert into this one.
type UTXO struct {
	Txid      string
	Vout      uint32
	Address   string
	ValueSats uint64
}

func (e *DeniabilityEngine) CleanupDenials(ctx context.Context) ([]*UTXO, []deniability.Denial, error) {
	logger := zerolog.Ctx(ctx)

	denials, err := deniability.List(ctx, e.db, deniability.WithExcludeCancelled())
	if err != nil {
		return nil, nil, fmt.Errorf("list denials: %w", err)
	}

	if len(denials) == 0 {
		return nil, nil, nil
	}

	// Build a map of wallet_id -> UTXOs for efficient lookup
	walletUTXOs := make(map[string][]*UTXO)

	// Track wallets that had errors to avoid repeated attempts
	failedWallets := make(map[string]bool)

	for _, denial := range denials {
		// A denial from before wallet_id existed names none, so it runs on the
		// active wallet. Erroring instead would mark it failed on every cycle
		// and strand it forever.
		walletId, err := e.resolveDenialWallet(denial)
		if err != nil {
			logger.Warn().Err(err).Int64("denial", denial.ID).Msg("deniability: no wallet for this denial, will retry")
			continue
		}

		// Skip if we already failed to get UTXOs for this wallet
		if failedWallets[walletId] {
			continue
		}

		// Only fetch UTXOs for each wallet once
		if _, exists := walletUTXOs[walletId]; !exists {
			rpcCtx, cancel := context.WithTimeout(ctx, 30*time.Second)
			utxos, err := e.listUTXOsForWallet(rpcCtx, walletId)
			cancel()

			if err != nil {
				failedWallets[walletId] = true
				logger.Warn().Err(err).Str("wallet_id", walletId).Msg("deniability: wallet error, will retry")
				continue
			}
			walletUTXOs[walletId] = utxos
		}
	}

	// if any denial tips are missing from the wallet, we must abort them before moving on
	if err := e.cancelIfUTXOIsGone(ctx, walletUTXOs, denials); err != nil {
		return nil, nil, fmt.Errorf("handle aborted denials: %w", err)
	}

	// relist all guaranteed good denials
	denials, err = deniability.List(ctx, e.db, deniability.WithExcludeCancelled())
	if err != nil {
		return nil, nil, fmt.Errorf("list denials: %w", err)
	}

	// Flatten all UTXOs for ExecuteDenial (which will also re-verify)
	allUTXOs := lo.Flatten(lo.Values(walletUTXOs))

	return allUTXOs, denials, nil
}

func (e *DeniabilityEngine) cancelIfUTXOIsGone(ctx context.Context, walletUTXOs map[string][]*UTXO, denials []deniability.Denial) error {
	logger := zerolog.Ctx(ctx)

	for _, denial := range denials {
		walletId := ""
		if denial.WalletID != nil {
			walletId = *denial.WalletID
		}

		// If we don't have UTXOs for this wallet, it means the wallet failed
		// and the denial was already cancelled in CleanupDenials
		utxos, hasWallet := walletUTXOs[walletId]
		if !hasWallet {
			continue
		}

		utxoExists := lo.ContainsBy(utxos, func(utxo *UTXO) bool {
			return utxo.Txid == denial.TipTXID && int32(utxo.Vout) == denial.TipVout
		})

		if !utxoExists {
			if err := deniability.Cancel(ctx, e.db, denial.ID, "cancelled due to UTXO being moved"); err != nil {
				return fmt.Errorf("cancel denial %d: %w", denial.ID, err)
			}

			logger.Info().
				Int64("denial_id", denial.ID).
				Str("txid", denial.TipTXID).
				Msg("cancelled denial due to missing UTXO")
		}
	}

	return nil
}

func (e *DeniabilityEngine) ExecuteDenial(ctx context.Context, utxos []*UTXO, denial deniability.Denial) error {
	tipUTXOs := lo.Filter(utxos, func(utxo *UTXO, _ int) bool {
		return utxo.Txid == denial.TipTXID && int32(utxo.Vout) == denial.TipVout
	})
	if len(tipUTXOs) == 0 {
		return fmt.Errorf("no matching utxos found for tip %s:%d", denial.TipTXID, denial.TipVout)
	}

	// Create a pool for parallel processing
	pool := logpool.New(ctx, "denial-processing")
	for _, utxo := range tipUTXOs {
		pool.Go(fmt.Sprintf("utxo-%s-%d", utxo.Txid, utxo.Vout), func(ctx context.Context) error {
			return e.ProcessUTXO(ctx, utxo, denial)
		})
	}

	// Wait for all tasks to complete and collect errors
	err := pool.Wait(ctx)
	if err != nil {
		return fmt.Errorf("failed to process UTXOs: %w", err)
	}

	return nil
}

func (e *DeniabilityEngine) ProcessUTXO(ctx context.Context, utxo *UTXO, denial deniability.Denial) error {
	logger := zerolog.Ctx(ctx).With().
		Int64("denial_id", denial.ID).
		Str("utxo_txid", utxo.Txid).
		Uint32("utxo_vout", utxo.Vout).
		Uint64("utxo_amount", utxo.ValueSats).
		Str("tip_txid", denial.TipTXID).
		Logger()

	logger.Info().Msg("processing UTXO for denial")

	const fee = 10000
	if utxo.ValueSats < fee {
		reason := "utxo is too small to split"
		logger.Warn().Msg("cancelling denial due to insufficient UTXO amount")

		if err := deniability.Cancel(ctx, e.db, denial.ID, reason); err != nil {
			return fmt.Errorf("cancel denial: %w", err)
		}
		return nil
	}

	// Use the denial's stored wallet_id to determine routing
	var walletType WalletType
	var walletId string
	var err error

	// A denial names the wallet it spends from. Without one we cannot run the
	// watch-only check, and an unnamed wallet reaches Core's loaded wallet —
	// which is one the user never picked for this denial.
	if e.walletEngine == nil {
		return fmt.Errorf("denial %d: no wallet engine to resolve a wallet with", denial.ID)
	}

	walletId, err = e.resolveDenialWallet(denial)
	if err != nil {
		return fmt.Errorf("denial %d: %w", denial.ID, err)
	}
	walletType, err = e.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return fmt.Errorf("get wallet type for denial %d: %w", denial.ID, err)
	}

	destinations, err := e.chooseDenialStrategy(ctx, denial, utxo, fee, walletType, walletId)
	if err != nil {
		return fmt.Errorf("choose denial strategy: %w", err)
	}

	// Send transaction based on wallet type
	var txid string
	switch walletType {
	case WalletTypeBitcoinCore:
		if werr := e.rejectWatchOnly(ctx, walletId); werr != nil {
			return werr
		}
		txid, err = e.sendBitcoinCoreTransaction(ctx, walletId, utxo, destinations, fee)
	case WalletTypeElectrum:
		txid, err = e.sendElectrumTransaction(ctx, walletId, utxo, destinations, fee)
	default:
		return fmt.Errorf("unknown wallet type: %s", walletType)
	}

	if err != nil {
		logger.Error().
			Err(err).
			Msg("failed to send transaction")
		return fmt.Errorf("send transaction: %w", err)
	}

	newUTXOs, err := e.waitForUTXOsToAppear(ctx, walletId, txid, destinations)
	if err != nil {
		return fmt.Errorf("wait for tx to appear: %w", err)
	}

	for _, newUTXO := range newUTXOs {
		if newUTXO.Txid != txid {
			panic("DEVELOPER ERROR: returned UTXO txid did not match sent txid")
		}

		if err := deniability.RecordExecution(ctx, e.db, denial.ID,
			utxo.Txid,
			int32(utxo.Vout),
			txid,
			newUTXO.Vout,
		); err != nil {
			logger.Error().
				Err(err).
				Str("to_txid", txid).
				Msg("failed to record execution")
			return fmt.Errorf("record execution: %w", err)
		}
	}

	logger.Info().
		Str("to_txid", txid).
		Msg("executed denial split")

	return nil
}

// sendBitcoinCoreTransaction sends a transaction via Bitcoin Core, spending the
// chosen UTXO into the denial destinations.
func (e *DeniabilityEngine) sendBitcoinCoreTransaction(
	ctx context.Context,
	walletId string,
	utxo *UTXO,
	destinations map[string]uint64,
	fee uint64,
) (string, error) {
	coreWalletName, err := e.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return "", fmt.Errorf("get bitcoin core wallet name: %w", err)
	}

	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("get bitcoind client: %w", err)
	}

	return SendCoreWithRequiredInputs(ctx, bitcoind, coreWalletName, []CoreOutpoint{
		{Txid: utxo.Txid, Vout: utxo.Vout},
	}, destinations, 0, fee)
}

// sendElectrumTransaction sends a transaction via the orchestrator wallet
// manager, spending the chosen UTXO into the denial destinations.
func (e *DeniabilityEngine) sendElectrumTransaction(
	ctx context.Context,
	walletId string,
	utxo *UTXO,
	destinations map[string]uint64,
	fee uint64,
) (string, error) {
	dests := lo.MapValues(destinations, func(sats uint64, _ string) int64 {
		return int64(sats)
	})
	return e.walletEngine.SendTransaction(ctx, &orchpb.SendTransactionRequest{
		WalletId:     walletId,
		Destinations: dests,
		FixedFeeSats: int64(fee),
		RequiredInputs: []*orchpb.UnspentOutput{
			{Txid: utxo.Txid, Vout: int32(utxo.Vout)},
		},
	})
}

// the enforcer wallet takes a few seconds/minutes to add the sent transaction
// to the wallet utxos. This function waits for the passed txid to appear with a timeout.
func (e *DeniabilityEngine) waitForUTXOsToAppear(
	ctx context.Context,
	walletId string,
	txid string,
	destinations map[string]uint64,
) ([]*UTXO, error) {
	logger := zerolog.Ctx(ctx)

	// Use a ticker for proper wait pattern
	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()

	// Timeout after 5 minutes - if UTXO hasn't appeared by then, something is wrong
	timeout := time.After(5 * time.Minute)

	// Track retry attempts for logging
	attempts := 0
	const maxLogAttempts = 10 // Only log first N attempts to avoid spam

	for {
		select {
		case <-ctx.Done():
			return nil, fmt.Errorf("context cancelled while waiting for UTXO %s", txid)
		case <-timeout:
			return nil, fmt.Errorf("timeout after 5 minutes waiting for UTXO %s to appear (tried %d times)", txid, attempts)
		case <-ticker.C:
			attempts++

			// Create a timeout context for the RPC call to prevent hanging
			rpcCtx, cancel := context.WithTimeout(ctx, 30*time.Second)
			utxos, err := e.listUTXOsForWallet(rpcCtx, walletId)
			cancel()

			if err != nil {
				// Log error but continue retrying - might be transient
				if attempts <= maxLogAttempts {
					logger.Warn().
						Err(err).
						Str("txid", txid).
						Int("attempt", attempts).
						Msg("error listing UTXOs while waiting for transaction, will retry")
				}
				continue
			}

			var foundUTXOs []*UTXO
			for _, utxo := range utxos {
				if utxo.Txid == txid {
					// Check if this UTXO's address matches any of our destination addresses
					if _, exists := destinations[utxo.Address]; exists {
						foundUTXOs = append(foundUTXOs, utxo)
					}
					// any non-matched is change. We don't care about those
				}
			}

			if len(foundUTXOs) > 0 {
				logger.Info().
					Str("txid", txid).
					Int("attempts", attempts).
					Int("found_utxos", len(foundUTXOs)).
					Msg("UTXO appeared in wallet")
				return foundUTXOs, nil
			}

			if attempts <= maxLogAttempts || attempts%60 == 0 {
				logger.Debug().
					Str("txid", txid).
					Int("attempt", attempts).
					Msg("waiting for UTXO to appear in wallet")
			}
		}
	}
}

// rejectWatchOnly returns an error if the wallet has no signing key.
// Deniability requires spending, which a watch-only wallet cannot do.
func (e *DeniabilityEngine) rejectWatchOnly(ctx context.Context, walletId string) error {
	if e.walletEngine == nil {
		return errors.New("no wallet engine to check watch-only against")
	}
	if walletId == "" {
		return errors.New("no wallet named, so watch-only cannot be ruled out")
	}
	watchOnly, err := e.walletEngine.IsWatchOnly(ctx, walletId)
	if err != nil {
		return fmt.Errorf("check watch-only: %w", err)
	}
	if watchOnly {
		return fmt.Errorf("deniability is not supported for watch-only wallets")
	}
	return nil
}

func (e *DeniabilityEngine) chooseDenialStrategy(
	ctx context.Context,
	denial deniability.Denial,
	utxo *UTXO,
	fee uint64,
	walletType WalletType,
	walletId string,
) (map[string]uint64, error) {
	logger := zerolog.Ctx(ctx)
	completedHops := len(denial.ExecutedDenials)

	// Target sizes are now a sparse array where targetSizes[hopIndex] = amount
	// A value of 0 means "use random split" for that hop
	// The frontend pre-distributes user-specified amounts randomly across hop indices
	if completedHops < len(denial.TargetUTXOSizes) {
		targetSize := denial.TargetUTXOSizes[completedHops]
		if targetSize > 0 {
			logger.Info().
				Int("hop", completedHops).
				Int64("target_size", targetSize).
				Msg("using pre-assigned target size for this hop")
			return e.targetAmountSplit(ctx, denial, utxo, fee, walletType, walletId, targetSize)
		}
	}

	// No target size for this hop (or value is 0), use random split
	logger.Info().
		Int("hop", completedHops).
		Msg("using random split for this hop")
	return e.simpleSplit(ctx, denial, utxo, fee, walletType, walletId)
}

// simpleSplit sends 10-90% of the utxo to a new address. Change is indistinguishable, making it a somewhat OK
// strategy for bamboozling chain analysis
func (e *DeniabilityEngine) simpleSplit(
	ctx context.Context,
	denial deniability.Denial,
	utxo *UTXO,
	fee uint64,
	walletType WalletType,
	walletId string,
) (map[string]uint64, error) {
	address, err := e.getNewAddress(ctx, walletType, walletId)
	if err != nil {
		return nil, fmt.Errorf("get new address: %w", err)
	}

	availableAmount := utxo.ValueSats - fee
	// Send 10-90% of the utxo to a new address. Change is indistinguishable,
	// so we don't know
	percentage := 10 + rand.Intn(80)
	sendAmount := (availableAmount * uint64(percentage)) / 100

	zerolog.Ctx(ctx).Info().
		Int64("denial_id", denial.ID).
		Uint64("total_amount", utxo.ValueSats).
		Uint64("fee", fee).
		Uint64("first_amount", sendAmount).
		Int("split_percentage", percentage).
		Msg("calculated split amounts")

	return map[string]uint64{
		address: sendAmount,
	}, nil
}

// targetAmountSplit sends the user-specified target amount to a new address
func (e *DeniabilityEngine) targetAmountSplit(
	ctx context.Context,
	denial deniability.Denial,
	utxo *UTXO,
	fee uint64,
	walletType WalletType,
	walletId string,
	targetSize int64,
) (map[string]uint64, error) {
	address, err := e.getNewAddress(ctx, walletType, walletId)
	if err != nil {
		return nil, fmt.Errorf("get new address: %w", err)
	}

	targetAmount := uint64(targetSize)
	availableAmount := utxo.ValueSats - fee

	// Ensure target amount doesn't exceed available
	if targetAmount > availableAmount {
		targetAmount = availableAmount
	}

	zerolog.Ctx(ctx).Info().
		Int64("denial_id", denial.ID).
		Uint64("total_amount", utxo.ValueSats).
		Uint64("fee", fee).
		Uint64("target_amount", targetAmount).
		Msg("using target amount split")

	return map[string]uint64{
		address: targetAmount,
	}, nil
}

// getNewAddress returns a fresh destination address for the active wallet's
// backend. Watch-only Bitcoin Core wallets are rejected (they can't sign).
func (e *DeniabilityEngine) getNewAddress(ctx context.Context, walletType WalletType, walletId string) (string, error) {
	switch walletType {
	case WalletTypeBitcoinCore:
		if werr := e.rejectWatchOnly(ctx, walletId); werr != nil {
			return "", werr
		}
		return e.getBitcoinCoreNewAddress(ctx, walletId)
	case WalletTypeElectrum:
		return e.walletEngine.GetElectrumReceiveAddress(ctx, walletId)
	default:
		return "", fmt.Errorf("unsupported wallet type for deniability: %s", walletType)
	}
}

// getBitcoinCoreNewAddress creates a new address from a Bitcoin Core wallet
func (e *DeniabilityEngine) getBitcoinCoreNewAddress(ctx context.Context, walletId string) (string, error) {
	coreWalletName, err := e.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return "", fmt.Errorf("get bitcoin core wallet name: %w", err)
	}

	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("get bitcoind client: %w", err)
	}

	resp, err := bitcoind.GetNewAddress(ctx, connect.NewRequest(&corepb.GetNewAddressRequest{
		Wallet:      coreWalletName,
		AddressType: "bech32",
	}))
	if err != nil {
		return "", fmt.Errorf("bitcoin core get new address: %w", err)
	}

	return resp.Msg.Address, nil
}

// resolveDenialWallet names the wallet a denial spends from: the one stored
// with it, or the active wallet for a row from before wallet_id existed.
func (e *DeniabilityEngine) resolveDenialWallet(denial deniability.Denial) (string, error) {
	if denial.WalletID != nil && *denial.WalletID != "" {
		return *denial.WalletID, nil
	}
	if e.walletEngine == nil {
		return "", errors.New("no wallet engine to resolve the active wallet with")
	}
	active, err := e.walletEngine.GetActiveWallet(context.Background())
	if err != nil {
		return "", fmt.Errorf("get active wallet: %w", err)
	}
	if active.ID == "" {
		return "", errors.New("no wallet is active")
	}
	return active.ID, nil
}

// listUTXOsForWallet gets UTXOs for a specific wallet ID
func (e *DeniabilityEngine) listUTXOsForWallet(ctx context.Context, walletId string) ([]*UTXO, error) {
	// A denial from before wallet_id existed names no wallet, and so does a
	// single-wallet install. Both read Bitcoin Core's loaded wallet.
	if e.walletEngine == nil {
		return nil, errors.New("no wallet engine to resolve the wallet with")
	}
	if walletId == "" {
		return nil, errors.New("no wallet named to list unspent outputs for")
	}

	walletType, err := e.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	switch walletType {
	case WalletTypeBitcoinCore:
		if werr := e.rejectWatchOnly(ctx, walletId); werr != nil {
			return nil, werr
		}
		return e.listBitcoinCoreUTXOs(ctx, walletId)

	case WalletTypeElectrum:
		return e.listElectrumUTXOs(ctx, walletId)

	default:
		return nil, fmt.Errorf("unknown wallet type: %s", walletType)
	}
}

// listElectrumUTXOs lists an electrum wallet's UTXOs (served via the
// orchestrator/Esplora) and converts them to the enforcer output shape the
// rest of the engine works with.
func (e *DeniabilityEngine) listElectrumUTXOs(ctx context.Context, walletId string) ([]*UTXO, error) {
	utxos, err := e.walletEngine.GetElectrumUnspent(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("electrum: list unspent: %w", err)
	}
	return lo.Map(utxos, func(u *orchpb.UnspentOutput, _ int) *UTXO {
		return &UTXO{
			Txid:      u.Txid,
			Vout:      uint32(u.Vout),
			ValueSats: uint64(u.AmountSats),
			Address:   u.Address,
		}
	}), nil
}

// listBitcoinCoreUTXOs lists UTXOs from a Bitcoin Core wallet
func (e *DeniabilityEngine) listBitcoinCoreUTXOs(ctx context.Context, walletId string) ([]*UTXO, error) {
	coreWalletName, err := e.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get bitcoin core wallet name: %w", err)
	}

	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("get bitcoind client: %w", err)
	}

	resp, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
		Wallet: coreWalletName,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoin core list unspent: %w", err)
	}

	outputs := lo.Map(resp.Msg.Unspent, func(utxo *corepb.UnspentOutput, _ int) *UTXO {
		return &UTXO{
			Txid:      utxo.Txid,
			Vout:      utxo.Vout,
			Address:   utxo.Address,
			ValueSats: uint64(utxo.Amount * 100000000),
		}
	})

	return outputs, nil
}
