package engines

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/service"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/rs/zerolog"
)

type DeniabilityEngine struct {
	wallet   *service.Service[validatorrpc.WalletServiceClient]
	bitcoind *service.Service[*coreproxy.Bitcoind]
	db       *sql.DB
}

func NewDeniability(
	wallet *service.Service[validatorrpc.WalletServiceClient],
	bitcoind *service.Service[*coreproxy.Bitcoind],
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

		// It's time! Execute.
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
				Int32("vout", denial.TipVout).
				Msg("cancelled denial due to missing UTXO")
		}
	}

	return nil
}

func (e *DeniabilityEngine) findDenialUTXO(
	utxos []*pb.ListUnspentOutputsResponse_Output, txid string, vout uint32,
) (*pb.ListUnspentOutputsResponse_Output, error) {
	for _, utxo := range utxos {
		if utxo.Txid.Hex.Value == txid && utxo.Vout == vout {
			return utxo, nil
		}
	}

	return nil, fmt.Errorf("no matching utxo found")
}

func (e *DeniabilityEngine) findNewUTXO(
	ctx context.Context, txid string, expectedAmount uint64,
) (*pb.ListUnspentOutputsResponse_Output, error) {
	// we need to wait for the new utxo to appear in the wallet. might take a while
	for i := 0; i < 30; i++ {
		utxos, err := e.listUTXOs(ctx)
		if err != nil {
			return nil, fmt.Errorf("could not list utxos: %w", err)
		}

		// Look for our new UTXO
		for _, utxo := range utxos {
			if utxo.Txid.Hex.Value == txid && utxo.ValueSats == expectedAmount {
				return utxo, nil
			}
		}

		// Wait a second before trying again
		time.Sleep(time.Second)
	}

	return nil, fmt.Errorf("timed out waiting for UTXO %s", txid)
}

func (e *DeniabilityEngine) executeDenial(ctx context.Context, utxos []*pb.ListUnspentOutputsResponse_Output, denial deniability.Denial) error {
	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return fmt.Errorf("could not get wallet client: %w", err)
	}

	// We need to find the specific UTXO that matches our denial tip
	utxo, err := e.findDenialUTXO(utxos, denial.TipTXID, uint32(denial.TipVout))
	if err != nil {
		return fmt.Errorf("could not find matching utxo: %w", err)
	}

	// Next hop must have a unique address
	addrResp, err := wallet.CreateNewAddress(ctx, &connect.Request[pb.CreateNewAddressRequest]{
		Msg: &pb.CreateNewAddressRequest{},
	})
	if err != nil {
		return fmt.Errorf("enforcer/wallet: could not get new address: %w", err)
	}

	const fee = 10000
	if utxo.ValueSats < fee {
		reason := "utxo is too small to send"
		if err := deniability.Cancel(ctx, e.db, denial.ID, reason); err != nil {
			return fmt.Errorf("could not cancel denial: %w", err)
		}
		return nil
	}

	sendAmount := utxo.ValueSats - fee
	sendResp, err := wallet.SendTransaction(ctx, &connect.Request[pb.SendTransactionRequest]{
		Msg: &pb.SendTransactionRequest{
			Destinations: map[string]uint64{
				// TODO: We need better coin selection here. But for the time being,
				// we just pray to the gods the wallet is smart and selects the right UTXO,
				// matching by value
				addrResp.Msg.Address: sendAmount,
			},
			FeeRate: &pb.SendTransactionRequest_FeeRate{
				Fee: &pb.SendTransactionRequest_FeeRate_Sats{
					Sats: fee,
				},
			},
		},
	})
	if err != nil {
		return fmt.Errorf("enforcer/wallet: could not send to address: %w", err)
	}

	// Wait for the new UTXO to appear and find its vout
	newUtxo, err := e.findNewUTXO(ctx, sendResp.Msg.Txid.Hex.Value, sendAmount)
	if err != nil {
		return fmt.Errorf("could not find new utxo: %w", err)
	}

	// Record execution with the correct vout
	if err := deniability.RecordExecution(ctx, e.db, denial.ID,
		utxo.Txid.Hex.Value,
		int32(utxo.Vout),
		newUtxo.Txid.Hex.Value,
		int32(newUtxo.Vout),
	); err != nil {
		return fmt.Errorf("could not record execution: %w", err)
	}

	zerolog.Ctx(ctx).Info().
		Int64("denial_id", denial.ID).
		Str("from_txid", utxo.Txid.Hex.Value).
		Uint32("from_vout", utxo.Vout).
		Str("to_txid", sendResp.Msg.Txid.Hex.Value).
		Uint32("to_vout", newUtxo.Vout).
		Uint64("amount", utxo.ValueSats).
		Msg("executed denial")

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
