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
	logpool "github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
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
				logger.Debug().Err(err).Msg("error checking denials")
				continue
			}
		}
	}
}

func (e *DeniabilityEngine) checkDenials(ctx context.Context) error {
	logger := zerolog.Ctx(ctx)

	utxos, denials, err := e.CleanupDenials(ctx)
	if err != nil {
		return fmt.Errorf("could not cleanup denials: %w", err)
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
			Msg("executing denial")

		// It's time! Execute.
		if err := e.ExecuteDenial(ctx, utxos, denial); err != nil {
			logger.Error().
				Err(err).
				Int64("denial_id", denial.ID).
				Msg("could not execute denial")
			continue
		}
	}

	return nil
}

func (e *DeniabilityEngine) CleanupDenials(ctx context.Context) ([]*pb.ListUnspentOutputsResponse_Output, []deniability.Denial, error) {
	// all denial checking starts with a list of current utxos
	utxos, err := e.listWalletUTXOs(ctx)
	if err != nil {
		return nil, nil, fmt.Errorf("could not list utxos: %w", err)
	}

	// then get all active denials
	denials, err := deniability.List(ctx, e.db, deniability.WithExcludeCancelled())
	if err != nil {
		return nil, nil, fmt.Errorf("could not list denials: %w", err)
	}

	// if any denial tips are missing from the wallet, we must abort them before moving on
	if err := e.cancelIfUTXOIsGone(ctx, utxos, denials); err != nil {
		return nil, nil, fmt.Errorf("could not handle aborted denials: %w", err)
	}

	// relist all guaranteed good denials
	denials, err = deniability.List(ctx, e.db, deniability.WithExcludeCancelled())
	if err != nil {
		return nil, nil, fmt.Errorf("could not list denials: %w", err)
	}

	return utxos, denials, nil
}

func (e *DeniabilityEngine) cancelIfUTXOIsGone(ctx context.Context, utxos []*pb.ListUnspentOutputsResponse_Output, denials []deniability.Denial) error {
	logger := zerolog.Ctx(ctx)

	for _, denial := range denials {
		utxoExists := lo.ContainsBy(utxos, func(utxo *pb.ListUnspentOutputsResponse_Output) bool {
			return utxo.Txid.Hex.Value == denial.TipTXID && int32(utxo.Vout) == denial.TipVout
		})

		if !utxoExists {
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
	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return fmt.Errorf("deniability/process: %w", err)
	}

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
			return fmt.Errorf("could not cancel denial: %w", err)
		}
		return nil
	}

	destinations, err := e.chooseDenialStrategy(ctx, denial, utxo, fee)
	if err != nil {
		return fmt.Errorf("could not choose denial strategy: %w", err)
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
		logger.Error().
			Err(err).
			Msg("failed to send transaction")
		return fmt.Errorf("could not send transaction: %w", err)
	}

	newUTXOs, err := e.waitForUTXOsToAppear(ctx, sendResp.Msg.Txid.Hex.Value, destinations)
	if err != nil {
		return fmt.Errorf("could not wait for tx to appear: %w", err)
	}

	for _, newUTXO := range newUTXOs {
		if newUTXO.Txid.Hex.Value != sendResp.Msg.Txid.Hex.Value {
			panic("DEVELOPER ERROR: returned UTXO txid did not match sent txid")
		}

		if err := deniability.RecordExecution(ctx, e.db, denial.ID,
			utxo.Txid.Hex.Value,
			int32(utxo.Vout),
			sendResp.Msg.Txid.Hex.Value,
			newUTXO.Vout,
		); err != nil {
			logger.Error().
				Err(err).
				Str("to_txid", sendResp.Msg.Txid.Hex.Value).
				Msg("failed to record execution")
			return fmt.Errorf("could not record execution: %w", err)
		}
	}

	logger.Info().
		Str("to_txid", sendResp.Msg.Txid.Hex.Value).
		Msg("executed denial split")

	return nil
}

// the enforcer wallet takes a few seconds/minutes to add the sent transaction
// to the wallet utxos. This function waits for the passed txid to appear. Waits
// forever, and only returns an error if the enforcer returns an error
func (e *DeniabilityEngine) waitForUTXOsToAppear(
	ctx context.Context,
	txid string,
	destinations map[string]uint64,
) ([]*pb.ListUnspentOutputsResponse_Output, error) {
	for {
		select {
		case <-ctx.Done():
			panic("findNewUTXOs loop exited due to context cancellation")
		default:
			utxos, err := e.listWalletUTXOs(ctx)
			if err != nil {
				return nil, fmt.Errorf("could not list utxos: %w", err)
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
				return foundUTXOs, nil
			}

			time.Sleep(time.Second)
		}
	}
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
		return nil, fmt.Errorf("deniability/split: %w", err)
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
		return nil, fmt.Errorf("enforcer/wallet: %w", err)
	}

	resp, err := wallet.ListUnspentOutputs(ctx, &connect.Request[pb.ListUnspentOutputsRequest]{
		Msg: &pb.ListUnspentOutputsRequest{},
	})
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not list transactions: %w", err)
	}

	return resp.Msg.Outputs, nil
}
