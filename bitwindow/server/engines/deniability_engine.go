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
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return nil

		case <-ticker.C:
			if err := e.checkDenials(ctx); err != nil {
				continue
			}
		}
	}
}

func (e *DeniabilityEngine) checkDenials(ctx context.Context) error {
	// all denial checking starts with a list of current utxos
	utxos, err := e.listUTXOs(ctx)
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
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not get next execution")
			return err
		}

		if nextExecution == nil || now.Before(*nextExecution) {
			// it's not time to execute!
			continue
		}

		// It's time! Execute. This might hang... forever!
		if err := e.executeDenial(ctx, utxos, denial); err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not execute denial")
			continue
		}
	}

	return nil
}

// checkAbortedDenials loops through all current utxos, and matches them with all denial tips.
// If it finds a denial tip that does not exist in the wallet, it aborts it with a specific error message
func (e *DeniabilityEngine) checkAbortedDenials(ctx context.Context, utxos []*pb.ListUnspentOutputsResponse_Output, denials []deniability.Denial) error {
	// Create map of existing UTXOs for quick lookup
	utxoMap := make(map[string]bool)
	for _, utxo := range utxos {
		key := fmt.Sprintf("%s:%d", utxo.Txid.Hex.Value, utxo.Vout)
		utxoMap[key] = true
	}

	// Check each active denial
	for _, denial := range denials {
		// Skip if already cancelled
		if denial.CancelledAt != nil {
			continue
		}

		// Check if the UTXO exists
		key := fmt.Sprintf("%s:%d", denial.TipTXID, denial.TipVout)
		if !utxoMap[key] {
			// UTXO is missing, cancel the denial
			if err := deniability.Cancel(ctx, e.db, denial.ID, "cancelled due to UTXO being moved"); err != nil {
				return fmt.Errorf("could not cancel denial %d: %w", denial.ID, err)
			}

			zerolog.Ctx(ctx).Info().
				Int64("denial_id", denial.ID).
				Str("txid", denial.TipTXID).
				Int32("vout", lo.FromPtr(denial.TipVout)).
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

func (e *DeniabilityEngine) findNewUTXOs(
	ctx context.Context,
	txid string,
	expectedAmounts []uint64,
) ([]*pb.ListUnspentOutputsResponse_Output, error) {
	var foundUTXOs []*pb.ListUnspentOutputsResponse_Output
	expectedCount := len(expectedAmounts)

	for {
		utxos, err := e.listUTXOs(ctx)
		if err != nil {
			return nil, fmt.Errorf("could not list utxos: %w", err)
		}

		foundUTXOs = nil
		for _, utxo := range utxos {
			if utxo.Txid.Hex.Value == txid {
				for _, expectedAmount := range expectedAmounts {
					if utxo.ValueSats == expectedAmount {
						foundUTXOs = append(foundUTXOs, utxo)
						break
					}
				}
			}
		}

		if len(foundUTXOs) == expectedCount {
			return foundUTXOs, nil
		}

		time.Sleep(time.Second)
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
	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return fmt.Errorf("could not get wallet client: %w", err)
	}

	// Create two new addresses for the split
	addr1Resp, err := wallet.CreateNewAddress(ctx, &connect.Request[pb.CreateNewAddressRequest]{
		Msg: &pb.CreateNewAddressRequest{},
	})
	if err != nil {
		return fmt.Errorf("could not get first new address: %w", err)
	}

	addr2Resp, err := wallet.CreateNewAddress(ctx, &connect.Request[pb.CreateNewAddressRequest]{
		Msg: &pb.CreateNewAddressRequest{},
	})
	if err != nil {
		return fmt.Errorf("could not get second new address: %w", err)
	}

	// Calculate random split amounts (10-90% of total)
	const fee = 10000
	if utxo.ValueSats < fee {
		reason := "utxo is too small to split"
		if err := deniability.Cancel(ctx, e.db, denial.ID, reason); err != nil {
			return fmt.Errorf("could not cancel denial: %w", err)
		}
		return nil
	}

	availableAmount := utxo.ValueSats - fee
	// Send 10-90% of the utxo to a new address
	percentage := 10 + rand.Intn(80)
	firstAmount := (availableAmount * uint64(percentage)) / 100
	secondAmount := availableAmount - firstAmount

	// Send transaction with two outputs
	sendResp, err := wallet.SendTransaction(ctx, &connect.Request[pb.SendTransactionRequest]{
		Msg: &pb.SendTransactionRequest{
			Destinations: map[string]uint64{
				addr1Resp.Msg.Address: firstAmount,
				addr2Resp.Msg.Address: secondAmount,
			},
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
		return fmt.Errorf("could not send transaction: %w", err)
	}

	// Wait for both new UTXOs to appear
	newUTXOs, err := e.findNewUTXOs(ctx, sendResp.Msg.Txid.Hex.Value, []uint64{firstAmount, secondAmount})
	if err != nil {
		return fmt.Errorf("could not find new UTXOs: %w", err)
	}

	// Record execution for each new UTXO
	for _, newUTXO := range newUTXOs {
		if err := deniability.RecordExecution(ctx, e.db, denial.ID,
			utxo.Txid.Hex.Value,
			int32(utxo.Vout),
			newUTXO.Txid.Hex.Value,
		); err != nil {
			return fmt.Errorf("could not record execution: %w", err)
		}
	}

	zerolog.Ctx(ctx).Info().
		Int64("denial_id", denial.ID).
		Str("from_txid", utxo.Txid.Hex.Value).
		Uint32("from_vout", utxo.Vout).
		Str("to_txid", sendResp.Msg.Txid.Hex.Value).
		Uint64("first_amount", firstAmount).
		Uint64("second_amount", secondAmount).
		Msg("executed denial split")

	return nil
}

type UTXO struct {
	TxID   string
	Vout   int32
	Amount uint64
}

// listUTXOs gets all unspent transaction outputs from the wallet
func (e *DeniabilityEngine) listUTXOs(ctx context.Context) ([]*pb.ListUnspentOutputsResponse_Output, error) {
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
