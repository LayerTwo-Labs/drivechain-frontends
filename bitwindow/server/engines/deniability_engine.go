package engines

import (
	"context"
	"database/sql"
	"fmt"
	"math/rand"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

type DeniabilityEngine struct {
	wallet   *service.Service[validatorrpc.WalletServiceClient]
	bitcoind *service.Service[bitcoindv1alphaconnect.BitcoinServiceClient]
	db       *sql.DB
}

func NewDeniability(
	wallet *service.Service[validatorrpc.WalletServiceClient],
	bitcoind *service.Service[bitcoindv1alphaconnect.BitcoinServiceClient],
	db *sql.DB,
) *DeniabilityEngine {
	return &DeniabilityEngine{
		wallet:   wallet,
		bitcoind: bitcoind,
		db:       db,
	}
}

func (e *DeniabilityEngine) Run(ctx context.Context) error {
	logger := zerolog.Ctx(ctx)
	logger.Info().Msg("starting deniability engine")
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			logger.Info().Msg("deniability engine shutting down")
			return nil

		case <-ticker.C:
			if err := e.checkDenials(ctx); err != nil {
				logger.Error().Err(err).Msg("error checking denials")
				continue
			}
		}
	}
}

func (e *DeniabilityEngine) checkDenials(ctx context.Context) error {
	logger := zerolog.Ctx(ctx)

	// all denial checking starts with a list of current utxos
	utxos, err := e.listWalletUTXOs(ctx)
	if err != nil {
		return fmt.Errorf("could not list utxos: %w", err)
	}

	// then get all active denials
	denials, err := deniability.List(ctx, e.db)
	if err != nil {
		return fmt.Errorf("could not list denials: %w", err)
	}

	// if any denial tips are missing from the wallet, we must abort them before moving on
	if err := e.checkAbortedDenials(ctx, utxos, denials); err != nil {
		return fmt.Errorf("could not check aborted denials: %w", err)
	}

	// relist all guaranteed good denials
	denials, err = deniability.List(ctx, e.db)
	if err != nil {
		return fmt.Errorf("could not list denials: %w", err)
	}

	now := time.Now()
	// lets start processing
	for _, denial := range denials {
		if denial.CancelledAt != nil {
			continue
		}

		nextExecution, err := deniability.NextExecution(ctx, e.db, denial)
		if err != nil {
			logger.Error().
				Err(err).
				Int64("denial_id", denial.ID).
				Msg("could not get next execution")
			return err
		}

		if nextExecution == nil || now.Before(*nextExecution) {
			logger.Info().
				Int64("denial_id", denial.ID).
				Interface("next_execution", nextExecution).
				Msg("denial not ready for execution")
			continue
		}

		logger.Info().
			Int64("denial_id", denial.ID).
			Time("next_execution", *nextExecution).
			Msg("executing denial")

		// It's time! Execute. This might hang... forever!
		if err := e.executeDenial(ctx, utxos, denial); err != nil {
			logger.Error().
				Err(err).
				Int64("denial_id", denial.ID).
				Msg("could not execute denial")
			continue
		}
	}

	return nil
}

func (e *DeniabilityEngine) checkAbortedDenials(ctx context.Context, utxos []*pb.ListUnspentOutputsResponse_Output, denials []deniability.Denial) error {
	logger := zerolog.Ctx(ctx)
	// Create map of existing UTXOs for quick lookup
	utxoMap := make(map[string]bool)
	txidMap := make(map[string]bool) // Track which txids exist at all

	for _, utxo := range utxos {
		key := fmt.Sprintf("%s:%d", utxo.Txid.Hex.Value, utxo.Vout)
		utxoMap[key] = true
		txidMap[utxo.Txid.Hex.Value] = true
	}

	// Check each active denial
	for _, denial := range denials {
		// Skip if already cancelled
		if denial.CancelledAt != nil {
			continue
		}

		// Check if the UTXO exists
		if denial.TipVout != nil {
			// If we have a vout, require exact match
			key := fmt.Sprintf("%s:%d", denial.TipTXID, *denial.TipVout)
			if !utxoMap[key] {
				if err := deniability.Cancel(ctx, e.db, denial.ID, "cancelled due to UTXO being moved"); err != nil {
					return fmt.Errorf("could not cancel denial %d: %w", denial.ID, err)
				}
				logger.Info().
					Int64("denial_id", denial.ID).
					Str("txid", denial.TipTXID).
					Int32("vout", *denial.TipVout).
					Msg("cancelled denial due to missing UTXO")
			}
		} else if !txidMap[denial.TipTXID] {
			// If no vout specified, just check if any UTXO with this txid exists
			if err := deniability.Cancel(ctx, e.db, denial.ID, "cancelled due to UTXO being moved"); err != nil {
				return fmt.Errorf("could not cancel denial %d: %w", denial.ID, err)
			}
			logger.Info().
				Int64("denial_id", denial.ID).
				Str("txid", denial.TipTXID).
				Msg("cancelled denial due to missing UTXO")
		}
	}

	return nil
}

func (e *DeniabilityEngine) findDenialUTXOs(
	utxos []*pb.ListUnspentOutputsResponse_Output,
	txid string,
) []*pb.ListUnspentOutputsResponse_Output {
	var matchingUTXOs []*pb.ListUnspentOutputsResponse_Output
	for _, utxo := range utxos {
		if utxo.Txid.Hex.Value == txid {
			matchingUTXOs = append(matchingUTXOs, utxo)
		}
	}
	return matchingUTXOs
}

func (e *DeniabilityEngine) waitForTXToAppear(
	ctx context.Context,
	txid string,
) ([]*pb.ListUnspentOutputsResponse_Output, error) {
	var foundUTXOs []*pb.ListUnspentOutputsResponse_Output

	for {
		select {
		case <-ctx.Done():
			panic("findNewUTXOs loop exited due to context cancellation")
		default:
			utxos, err := e.listWalletUTXOs(ctx)
			if err != nil {
				return nil, fmt.Errorf("could not list utxos: %w", err)
			}

			foundUTXOs = nil
			for _, utxo := range utxos {
				if utxo.Txid.Hex.Value == txid {
					foundUTXOs = append(foundUTXOs, utxo)
				}
			}

			if len(foundUTXOs) > 0 {
				return foundUTXOs, nil
			}

			time.Sleep(time.Second)
		}
	}
}

func (e *DeniabilityEngine) executeDenial(ctx context.Context, utxos []*pb.ListUnspentOutputsResponse_Output, denial deniability.Denial) error {
	// Find all UTXOs for this denial tip
	tipUTXOs := e.findDenialUTXOs(utxos, denial.TipTXID)
	if len(tipUTXOs) == 0 {
		return fmt.Errorf("no matching utxos found")
	}

	// Process each UTXO
	for _, utxo := range tipUTXOs {
		if err := e.processUTXO(ctx, utxo, denial); err != nil {
			return fmt.Errorf("failed to process UTXO %s:%d: %w", utxo.Txid.Hex.Value, utxo.Vout, err)
		}
	}

	return nil
}

func (e *DeniabilityEngine) processUTXO(ctx context.Context, utxo *pb.ListUnspentOutputsResponse_Output, denial deniability.Denial) error {
	logger := zerolog.Ctx(ctx)

	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return fmt.Errorf("could not get wallet client: %w", err)
	}

	logger.Info().
		Int64("denial_id", denial.ID).
		Str("utxo_txid", utxo.Txid.Hex.Value).
		Uint32("utxo_vout", utxo.Vout).
		Uint64("utxo_amount", utxo.ValueSats).
		Msg("processing UTXO for denial")

	// Calculate random split amounts (10-90% of total)
	const fee = 10000
	if utxo.ValueSats < fee {
		reason := "utxo is too small to split"
		logger.Warn().
			Int64("denial_id", denial.ID).
			Uint64("utxo_amount", utxo.ValueSats).
			Uint64("required_fee", fee).
			Msg("cancelling denial due to insufficient UTXO amount")

		if err := deniability.Cancel(ctx, e.db, denial.ID, reason); err != nil {
			return fmt.Errorf("could not cancel denial: %w", err)
		}
		return nil
	}

	destinations, err := e.chooseDenialStrategy(ctx, denial, utxo, fee)
	if err != nil {
		return fmt.Errorf("could not choose denial strategy: %w", err)
	}

	// Send transaction with two outputs
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
		logger.Error().
			Err(err).
			Int64("denial_id", denial.ID).
			Str("utxo_txid", utxo.Txid.Hex.Value).
			Uint32("utxo_vout", utxo.Vout).
			Msg("failed to send transaction")
		return fmt.Errorf("could not send transaction: %w", err)
	}

	logger.Info().
		Int64("denial_id", denial.ID).
		Str("txid", sendResp.Msg.Txid.Hex.Value).
		Msg("transaction sent, waiting for UTXOs")

	// Wait for the new UTXO to appear in the wallet
	newUTXOs, err := e.waitForTXToAppear(ctx, sendResp.Msg.Txid.Hex.Value)
	if err != nil {
		logger.Error().
			Err(err).
			Int64("denial_id", denial.ID).
			Str("txid", sendResp.Msg.Txid.Hex.Value).
			Msg("failed to find new UTXOs")
		return fmt.Errorf("could not find new UTXOs: %w", err)
	}

	logger.Info().
		Int64("denial_id", denial.ID).
		Str("txid", sendResp.Msg.Txid.Hex.Value).
		Int("utxo_count", len(newUTXOs)).
		Msg("found new UTXOs")

	// Record execution for each new UTXO
	for _, newUTXO := range newUTXOs {
		if err := deniability.RecordExecution(ctx, e.db, denial.ID,
			utxo.Txid.Hex.Value,
			int32(utxo.Vout),
			newUTXO.Txid.Hex.Value,
		); err != nil {
			logger.Error().
				Err(err).
				Int64("denial_id", denial.ID).
				Str("from_txid", utxo.Txid.Hex.Value).
				Str("to_txid", newUTXO.Txid.Hex.Value).
				Msg("failed to record execution")
			return fmt.Errorf("could not record execution: %w", err)
		}
	}

	logger.Info().
		Int64("denial_id", denial.ID).
		Str("from_txid", utxo.Txid.Hex.Value).
		Uint32("from_vout", utxo.Vout).
		Str("to_txid", sendResp.Msg.Txid.Hex.Value).
		Msg("executed denial split")

	return nil
}

func (e *DeniabilityEngine) chooseDenialStrategy(
	ctx context.Context, denial deniability.Denial, utxo *pb.ListUnspentOutputsResponse_Output, fee uint64,
) (map[string]uint64, error) {

	// currently we only have one strategy, but we'll keep the structure
	return e.simpleSplit(ctx, denial, utxo, fee)
}

// simpleSplit sends 10-90% of the utxo to a new address. Change is indistinguishable, making it a somewhat OK
// strategy for bamboozling chain analysis
func (e *DeniabilityEngine) simpleSplit(
	ctx context.Context, denial deniability.Denial, utxo *pb.ListUnspentOutputsResponse_Output, fee uint64,
) (map[string]uint64, error) {
	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("could not get wallet client: %w", err)
	}

	// Create two new addresses for the split
	addr, err := wallet.CreateNewAddress(ctx, &connect.Request[pb.CreateNewAddressRequest]{
		Msg: &pb.CreateNewAddressRequest{},
	})
	if err != nil {
		return nil, fmt.Errorf("could not get first new address: %w", err)
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
		addr.Msg.Address: sendAmount,
	}, nil
}

type UTXO struct {
	TxID   string
	Vout   int32
	Amount uint64
}

// listUTXOs gets all unspent transaction outputs from the wallet
func (e *DeniabilityEngine) listWalletUTXOs(ctx context.Context) ([]*pb.ListUnspentOutputsResponse_Output, error) {
	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not get wallet client: %w", err)
	}

	resp, err := wallet.ListUnspentOutputs(ctx, &connect.Request[pb.ListUnspentOutputsRequest]{
		Msg: &pb.ListUnspentOutputsRequest{},
	})
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not list transactions: %w", err)
	}

	return resp.Msg.Outputs, nil
}
