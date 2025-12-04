package engines

import (
	"context"
	"database/sql"
	"fmt"
	"math/rand"
	"time"

	"connectrpc.com/connect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	logpool "github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

type DeniabilityEngine struct {
	wallet       *service.Service[validatorrpc.WalletServiceClient]
	bitcoind     *service.Service[corerpc.BitcoinServiceClient]
	db           *sql.DB
	walletEngine *WalletEngine
}

func NewDeniability(
	wallet *service.Service[validatorrpc.WalletServiceClient],
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	db *sql.DB,
	walletEngine *WalletEngine,
) *DeniabilityEngine {
	return &DeniabilityEngine{
		wallet:       wallet,
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
			// Skip if wallet service isn't connected yet
			if !e.wallet.IsConnected() {
				continue
			}

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
			continue
		}
		logger.Info().
			Int64("denial_id", denial.ID).
			Dur("duration", time.Since(execStart)).
			Msg("deniability: finished executing denial")
	}

	return nil
}

func (e *DeniabilityEngine) CleanupDenials(ctx context.Context) ([]*pb.ListUnspentOutputsResponse_Output, []deniability.Denial, error) {
	logger := zerolog.Ctx(ctx)

	denials, err := deniability.List(ctx, e.db, deniability.WithExcludeCancelled())
	if err != nil {
		return nil, nil, fmt.Errorf("list denials: %w", err)
	}

	if len(denials) == 0 {
		return nil, nil, nil
	}

	// Build a map of wallet_id -> UTXOs for efficient lookup
	walletUTXOs := make(map[string][]*pb.ListUnspentOutputsResponse_Output)

	// Track wallets that had errors to avoid repeated attempts
	failedWallets := make(map[string]bool)

	for _, denial := range denials {
		walletId := ""
		if denial.WalletID != nil {
			walletId = *denial.WalletID
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
	var allUTXOs []*pb.ListUnspentOutputsResponse_Output
	for _, utxos := range walletUTXOs {
		allUTXOs = append(allUTXOs, utxos...)
	}

	return allUTXOs, denials, nil
}

func (e *DeniabilityEngine) cancelIfUTXOIsGone(ctx context.Context, walletUTXOs map[string][]*pb.ListUnspentOutputsResponse_Output, denials []deniability.Denial) error {
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

		utxoExists := lo.ContainsBy(utxos, func(utxo *pb.ListUnspentOutputsResponse_Output) bool {
			return utxo.Txid.Hex.Value == denial.TipTXID && int32(utxo.Vout) == denial.TipVout
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

func (e *DeniabilityEngine) ExecuteDenial(ctx context.Context, utxos []*pb.ListUnspentOutputsResponse_Output, denial deniability.Denial) error {
	var tipUTXOs []*pb.ListUnspentOutputsResponse_Output
	for _, utxo := range utxos {
		if utxo.Txid.Hex.Value == denial.TipTXID && int32(utxo.Vout) == denial.TipVout {
			tipUTXOs = append(tipUTXOs, utxo)
		}
	}
	if len(tipUTXOs) == 0 {
		return fmt.Errorf("no matching utxos found for tip %s:%d", denial.TipTXID, denial.TipVout)
	}

	// Create a pool for parallel processing
	pool := logpool.New(ctx, "denial-processing")
	for _, utxo := range tipUTXOs {
		pool.Go(fmt.Sprintf("utxo-%s-%d", utxo.Txid.Hex.Value, utxo.Vout), func(ctx context.Context) error {
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

func (e *DeniabilityEngine) ProcessUTXO(ctx context.Context, utxo *pb.ListUnspentOutputsResponse_Output, denial deniability.Denial) error {
	logger := zerolog.Ctx(ctx).With().
		Int64("denial_id", denial.ID).
		Str("utxo_txid", utxo.Txid.Hex.Value).
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

	if denial.WalletID != nil && *denial.WalletID != "" {
		// Use the wallet_id stored with the denial
		walletId = *denial.WalletID
		if e.walletEngine != nil {
			walletType, err = e.walletEngine.GetWalletBackendType(ctx, walletId)
			if err != nil {
				return fmt.Errorf("get wallet type for denial %d: %w", denial.ID, err)
			}
		} else {
			walletType = WalletTypeEnforcer
		}
	} else {
		// Legacy denial without wallet_id - use active wallet or fall back to enforcer
		if e.walletEngine != nil {
			walletType, walletId, err = e.getActiveWalletType(ctx)
			if err != nil {
				walletType = WalletTypeEnforcer
			}
		} else {
			walletType = WalletTypeEnforcer
		}
	}

	destinations, err := e.chooseDenialStrategy(ctx, denial, utxo, fee, walletType, walletId)
	if err != nil {
		return fmt.Errorf("choose denial strategy: %w", err)
	}

	// Send transaction based on wallet type
	var txid string
	switch walletType {
	case WalletTypeEnforcer:
		txid, err = e.sendEnforcerTransaction(ctx, utxo, destinations, fee)
	case WalletTypeBitcoinCore:
		txid, err = e.sendBitcoinCoreTransaction(ctx, walletId, destinations)
	case WalletTypeWatchOnly:
		return fmt.Errorf("cannot send transactions from watch-only wallet")
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
		if newUTXO.Txid.Hex.Value != txid {
			panic("DEVELOPER ERROR: returned UTXO txid did not match sent txid")
		}

		if err := deniability.RecordExecution(ctx, e.db, denial.ID,
			utxo.Txid.Hex.Value,
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

// sendEnforcerTransaction sends a transaction via the enforcer wallet
func (e *DeniabilityEngine) sendEnforcerTransaction(
	ctx context.Context,
	utxo *pb.ListUnspentOutputsResponse_Output,
	destinations map[string]uint64,
	fee uint64,
) (string, error) {
	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("get enforcer wallet: %w", err)
	}

	sendResp, err := wallet.SendTransaction(ctx, &connect.Request[pb.SendTransactionRequest]{
		Msg: &pb.SendTransactionRequest{
			Destinations: destinations,
			RequiredUtxos: []*pb.SendTransactionRequest_RequiredUtxo{
				{
					Txid: &commonv1.ReverseHex{
						Hex: &wrapperspb.StringValue{Value: utxo.Txid.Hex.Value},
					},
					Vout: utxo.Vout,
				},
			},
			FeeRate: &pb.SendTransactionRequest_FeeRate{
				Fee: &pb.SendTransactionRequest_FeeRate_Sats{
					Sats: fee,
				},
			},
		},
	})
	if err != nil {
		return "", err
	}

	return sendResp.Msg.Txid.Hex.Value, nil
}

// sendBitcoinCoreTransaction sends a transaction via Bitcoin Core
func (e *DeniabilityEngine) sendBitcoinCoreTransaction(
	ctx context.Context,
	walletId string,
	destinations map[string]uint64,
) (string, error) {
	coreWalletName, err := e.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return "", fmt.Errorf("get bitcoin core wallet name: %w", err)
	}

	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("get bitcoind client: %w", err)
	}

	// Convert satoshi amounts to BTC (Bitcoin Core uses BTC, not satoshis)
	btcDestinations := make(map[string]float64)
	for addr, sats := range destinations {
		btcDestinations[addr] = float64(sats) / 1e8
	}

	resp, err := bitcoind.Send(ctx, connect.NewRequest(&corepb.SendRequest{
		Destinations: btcDestinations,
		Wallet:       coreWalletName,
	}))
	if err != nil {
		return "", fmt.Errorf("bitcoin core send: %w", err)
	}

	return resp.Msg.Txid, nil
}

// the enforcer wallet takes a few seconds/minutes to add the sent transaction
// to the wallet utxos. This function waits for the passed txid to appear with a timeout.
func (e *DeniabilityEngine) waitForUTXOsToAppear(
	ctx context.Context,
	walletId string,
	txid string,
	destinations map[string]uint64,
) ([]*pb.ListUnspentOutputsResponse_Output, error) {
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

			var foundUTXOs []*pb.ListUnspentOutputsResponse_Output
			for _, utxo := range utxos {
				if utxo.Txid.Hex.Value == txid {
					// Check if this UTXO's address matches any of our destination addresses
					if _, exists := destinations[utxo.Address.Value]; exists {
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

func (e *DeniabilityEngine) chooseDenialStrategy(
	ctx context.Context,
	denial deniability.Denial,
	utxo *pb.ListUnspentOutputsResponse_Output,
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
	utxo *pb.ListUnspentOutputsResponse_Output,
	fee uint64,
	walletType WalletType,
	walletId string,
) (map[string]uint64, error) {
	// Get a new address based on wallet type
	var address string
	var err error

	switch walletType {
	case WalletTypeEnforcer:
		address, err = e.getEnforcerNewAddress(ctx)
	case WalletTypeBitcoinCore:
		address, err = e.getBitcoinCoreNewAddress(ctx, walletId)
	case WalletTypeWatchOnly:
		return nil, fmt.Errorf("deniability not supported for watch-only wallets")
	default:
		return nil, fmt.Errorf("unsupported wallet type for deniability: %s", walletType)
	}

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
	utxo *pb.ListUnspentOutputsResponse_Output,
	fee uint64,
	walletType WalletType,
	walletId string,
	targetSize int64,
) (map[string]uint64, error) {
	// Get a new address based on wallet type
	var address string
	var err error

	switch walletType {
	case WalletTypeEnforcer:
		address, err = e.getEnforcerNewAddress(ctx)
	case WalletTypeBitcoinCore:
		address, err = e.getBitcoinCoreNewAddress(ctx, walletId)
	case WalletTypeWatchOnly:
		return nil, fmt.Errorf("deniability not supported for watch-only wallets")
	default:
		return nil, fmt.Errorf("unsupported wallet type for deniability: %s", walletType)
	}

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

// getEnforcerNewAddress creates a new address from the enforcer wallet
func (e *DeniabilityEngine) getEnforcerNewAddress(ctx context.Context) (string, error) {
	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("get enforcer wallet: %w", err)
	}

	addr, err := wallet.CreateNewAddress(ctx, &connect.Request[pb.CreateNewAddressRequest]{
		Msg: &pb.CreateNewAddressRequest{},
	})
	if err != nil {
		return "", fmt.Errorf("create new address: %w", err)
	}

	return addr.Msg.Address, nil
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

type UTXO struct {
	TxID   string
	Vout   int32
	Amount uint64
}

// getActiveWalletType returns the wallet type and wallet ID for the active wallet
// Returns error if wallet is encrypted and locked, or if no enforcer wallet exists
func (e *DeniabilityEngine) getActiveWalletType(ctx context.Context) (WalletType, string, error) {
	activeWallet, err := e.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		return "", "", fmt.Errorf("get active wallet: %w", err)
	}

	return activeWallet.WalletType, activeWallet.ID, nil
}

// listUTXOsForWallet gets UTXOs for a specific wallet ID
func (e *DeniabilityEngine) listUTXOsForWallet(ctx context.Context, walletId string) ([]*pb.ListUnspentOutputsResponse_Output, error) {
	if walletId == "" || e.walletEngine == nil {
		// Legacy denial without wallet_id or no wallet engine - use enforcer
		return e.listEnforcerUTXOs(ctx)
	}

	walletType, err := e.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	switch walletType {
	case WalletTypeEnforcer:
		return e.listEnforcerUTXOs(ctx)

	case WalletTypeBitcoinCore:
		return e.listBitcoinCoreUTXOs(ctx, walletId)

	case WalletTypeWatchOnly:
		return nil, fmt.Errorf("deniability not supported for watch-only wallets")

	default:
		return nil, fmt.Errorf("unknown wallet type: %s", walletType)
	}
}

// listEnforcerUTXOs lists UTXOs from the enforcer wallet
func (e *DeniabilityEngine) listEnforcerUTXOs(ctx context.Context) ([]*pb.ListUnspentOutputsResponse_Output, error) {
	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: %w", err)
	}

	resp, err := wallet.ListUnspentOutputs(ctx, &connect.Request[pb.ListUnspentOutputsRequest]{
		Msg: &pb.ListUnspentOutputsRequest{},
	})
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: list transactions: %w", err)
	}

	return resp.Msg.Outputs, nil
}

// listBitcoinCoreUTXOs lists UTXOs from a Bitcoin Core wallet
func (e *DeniabilityEngine) listBitcoinCoreUTXOs(ctx context.Context, walletId string) ([]*pb.ListUnspentOutputsResponse_Output, error) {
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

	// Convert Bitcoin Core UTXOs to the enforcer format for compatibility
	var outputs []*pb.ListUnspentOutputsResponse_Output
	for _, utxo := range resp.Msg.Unspent {
		valueSats := uint64(utxo.Amount * 100000000)
		outputs = append(outputs, &pb.ListUnspentOutputsResponse_Output{
			Txid: &commonv1.ReverseHex{
				Hex: &wrapperspb.StringValue{Value: utxo.Txid},
			},
			Vout:      utxo.Vout,
			Address:   &wrapperspb.StringValue{Value: utxo.Address},
			ValueSats: valueSats,
		})
	}

	return outputs, nil
}
