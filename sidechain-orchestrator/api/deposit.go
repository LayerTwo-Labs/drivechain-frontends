package api

import (
	"time"

	"context"
	"encoding/hex"
	"fmt"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/samber/lo"

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

	// The enforcer wallet takes no raw outputs, but it builds the whole M5
	// itself from the slot and the destination.
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	walletID, err := h.engine.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	// Read the network before the broadcast: a swap racing it would file the
	// record under the chain we swapped to.
	network := h.svc.Network()
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

	// An M5 is an ordinary transaction on the wire, so nothing later can tell
	// it apart from a normal send. Record it while we still know.
	if err := h.svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Network:     network,
		Txid:        send.Msg.Txid,
		WalletID:    walletID,
		Slot:        uint32(slot),
		Destination: req.Msg.Destination,
		AmountSats:  req.Msg.AmountSats,
		FeeSats:     req.Msg.FeeSats,
	}); err != nil {
		// The broadcast already happened, so failing the call would report a
		// deposit that did not land. This row is the only record of it.
		h.svc.Log().Error().Err(err).Str("txid", send.Msg.Txid).Msg("could not record the deposit")
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

// ListSidechainDeposits reports the deposits this install made to a slot. The
// enforcer used to keep a global list in its own wallet; it runs none, so only
// our own deposits are knowable.
func (h *WalletHandler) ListSidechainDeposits(
	ctx context.Context, req *connect.Request[wpb.ListSidechainDepositsRequest],
) (*connect.Response[wpb.ListSidechainDepositsResponse], error) {
	deposits, err := h.svc.SidechainDeposits(ctx, req.Msg.Slot, req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&wpb.ListSidechainDepositsResponse{
		Deposits: lo.Map(deposits, func(d wallet.SidechainDeposit, _ int) *wpb.SidechainDeposit {
			return &wpb.SidechainDeposit{
				Txid:          d.Txid,
				WalletId:      d.WalletID,
				Slot:          d.Slot,
				Destination:   d.Destination,
				AmountSats:    d.AmountSats,
				FeeSats:       d.FeeSats,
				Confirmations: h.depositConfirmations(ctx, d),
				CreatedAt:     d.CreatedAt.Format(time.RFC3339),
			}
		}),
	}), nil
}

// depositConfirmations reads the chain rather than the store, because a
// confirmation count goes stale the moment a block arrives. Zero when the
// chain source cannot answer.
func (h *WalletHandler) depositConfirmations(ctx context.Context, d wallet.SidechainDeposit) int32 {
	if h.engine == nil {
		return 0
	}
	tx, err := h.engine.ChainForWallet(d.WalletID).GetRawTransaction(ctx, d.Txid)
	if err != nil || tx == nil {
		return 0
	}
	return tx.Confirmations
}

// GetSidechainDepositTotals sums what this install deposited. The wallet
// overview shows it, and only our own record knows it.
func (h *WalletHandler) GetSidechainDepositTotals(
	ctx context.Context, req *connect.Request[wpb.GetSidechainDepositTotalsRequest],
) (*connect.Response[wpb.GetSidechainDepositTotalsResponse], error) {
	total, recent, err := h.svc.SidechainDepositTotals(ctx, time.Unix(req.Msg.SinceUnix, 0), req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&wpb.GetSidechainDepositTotalsResponse{
		TotalSats:  total,
		RecentSats: recent,
	}), nil
}
