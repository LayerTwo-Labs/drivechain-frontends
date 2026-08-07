package api

import (
	"context"
	"encoding/hex"
	"fmt"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// CreateDeposit builds a BIP300 M5: it spends the sidechain's current treasury
// output and pays a larger one back, naming the depositor in an OP_RETURN.
func (h *WalletHandler) CreateDeposit(
	ctx context.Context, req *connect.Request[wpb.CreateDepositRequest],
) (*connect.Response[wpb.CreateDepositResponse], error) {
	if req.Msg.AmountSats <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("amount_sats must be positive"))
	}
	if req.Msg.FeeSats <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("fee_sats must be positive"))
	}
	if req.Msg.Destination == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("destination must be set"))
	}
	if req.Msg.Slot < 0 || req.Msg.Slot > 255 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("slot must be 0-255"))
	}
	slot := uint8(req.Msg.Slot)

	treasuryHex := hex.EncodeToString(orchestrator.M5TreasuryScript(slot))
	ctip, err := h.sidechainCtip(ctx, uint32(slot))
	if err != nil {
		return nil, err
	}

	// No CTIP means nobody has deposited to this sidechain yet, so there is no
	// treasury output to spend and the deposit starts one.
	var externalInputs []*wpb.ExternalInput
	oldTreasurySats := int64(0)
	if ctip != nil {
		oldTreasurySats = int64(ctip.Value)
		externalInputs = []*wpb.ExternalInput{{
			Txid:            ctip.GetTxid().GetHex().GetValue(),
			Vout:            int32(ctip.Vout),
			ValueSats:       oldTreasurySats,
			ScriptPubkeyHex: treasuryHex,
		}}
	}

	treasurySats := oldTreasurySats + req.Msg.AmountSats
	send, err := h.SendTransaction(ctx, connect.NewRequest(&wpb.SendTransactionRequest{
		WalletId:       req.Msg.WalletId,
		RawOutputs:     []*wpb.RawOutput{{ValueSats: treasurySats, ScriptHex: treasuryHex}},
		OpReturnHex:    hex.EncodeToString([]byte(req.Msg.Destination)),
		ExternalInputs: externalInputs,
		FixedFeeSats:   req.Msg.FeeSats,
	}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&wpb.CreateDepositResponse{
		Txid:         send.Msg.Txid,
		TreasurySats: treasurySats,
	}), nil
}

// sidechainCtip reads the sidechain's current treasury outpoint, or nil when the
// sidechain has taken no deposit yet.
func (h *WalletHandler) sidechainCtip(
	ctx context.Context, slot uint32,
) (*enforcerpb.GetCtipResponse_Ctip, error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not wired"))
	}
	validator, err := h.orch.EnforcerValidator()
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	resp, err := validator.GetCtip(ctx, connect.NewRequest(&enforcerpb.GetCtipRequest{
		SidechainNumber: wrapperspb.UInt32(slot),
	}))
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get ctip: %w", err))
	}
	return resp.Msg.GetCtip(), nil
}
