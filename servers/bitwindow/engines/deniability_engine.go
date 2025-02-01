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
	"github.com/rs/zerolog"
)

type DeniabilityEngine struct {
	wallet *service.Service[validatorrpc.WalletServiceClient]
	db     *sql.DB
}

func NewDeniability(
	wallet *service.Service[validatorrpc.WalletServiceClient],
	db *sql.DB,
) *DeniabilityEngine {
	return &DeniabilityEngine{
		wallet: wallet,
		db:     db,
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

	// Get all active denials
	denials, err := deniability.List(ctx, e.db)
	if err != nil {
		return fmt.Errorf("could not list denials: %w", err)
	}

	for _, denial := range denials {
		// Skip if cancelled
		if denial.CancelledAt != nil {
			continue
		}

		// Check if it's time to execute
		nextExecution, err := deniability.NextExecution(ctx, e.db, denial.ID)
		if err != nil {
			continue
		}

		// Skip if no more executions needed or not time yet
		if nextExecution == nil {
			continue
		}
		if time.Now().Before(*nextExecution) {
			continue
		}

		// Time to execute!
		if err := e.executeDenial(ctx, denial.ID); err != nil {
			continue
		}
	}

	return nil
}

func (e *DeniabilityEngine) executeDenial(ctx context.Context, denialID int64) error {

	wallet, err := e.wallet.Get(ctx)
	if err != nil {
		return fmt.Errorf("could not get wallet client: %w", err)
	}

	// Get a new address
	addrResp, err := wallet.CreateNewAddress(ctx, &connect.Request[pb.CreateNewAddressRequest]{
		Msg: &pb.CreateNewAddressRequest{},
	})
	if err != nil {
		return fmt.Errorf("could not get new address: %w", err)
	}

	// Get current balance
	balResp, err := wallet.GetBalance(ctx, &connect.Request[pb.GetBalanceRequest]{
		Msg: &pb.GetBalanceRequest{},
	})
	if err != nil {
		return fmt.Errorf("could not get balance: %w", err)
	}

	const fee = 10000
	// Send entire balance to new address with fixed fee rate
	sendResp, err := wallet.SendTransaction(ctx, &connect.Request[pb.SendTransactionRequest]{
		Msg: &pb.SendTransactionRequest{
			Destinations: map[string]uint64{
				addrResp.Msg.Address: uint64(balResp.Msg.ConfirmedSats - fee),
			},
			FeeRate: &pb.SendTransactionRequest_FeeRate{
				Fee: &pb.SendTransactionRequest_FeeRate_Sats{
					Sats: fee,
				},
			},
		},
	})
	if err != nil {
		return fmt.Errorf("could not send to address: %w", err)
	}

	// Record the execution
	if err := deniability.RecordExecution(ctx, e.db, denialID, sendResp.Msg.Txid.Hex.Value); err != nil {
		return fmt.Errorf("could not record execution: %w", err)
	}

	zerolog.Ctx(ctx).Info().
		Int64("denial_id", denialID).
		Str("txid", sendResp.Msg.Txid.Hex.Value).
		Float64("amount", float64(balResp.Msg.ConfirmedSats)).
		Msg("executed denial")

	return nil
}
