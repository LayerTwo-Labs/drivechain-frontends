package api

import (
	"time"

	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/samber/lo"
	"strconv"
	"strings"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
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

	destination, err := depositDestination(slot, req.Msg.Destination)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

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

	h.svc.Log().Info().Uint8("slot", slot).Str("destination", destination).
		Int64("amount_sats", req.Msg.AmountSats).Int64("fee_sats", req.Msg.FeeSats).
		Int64("old_treasury_sats", oldTreasurySats).Int64("new_treasury_sats", treasurySats).
		Int("external_inputs", len(externalInputs)).Msg("building the deposit")

	// The enforcer wallet takes no raw outputs, but it builds the whole M5
	// itself from the slot and the destination.
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	walletID, err := h.engine.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	send, err := h.SendTransaction(ctx, connect.NewRequest(&wpb.SendTransactionRequest{
		WalletId:       req.Msg.WalletId,
		RawOutputs:     []*wpb.RawOutput{{ValueSats: treasurySats, ScriptHex: treasuryHex}},
		OpReturnHex:    hex.EncodeToString([]byte(destination)),
		ExternalInputs: externalInputs,
		FixedFeeSats:   req.Msg.FeeSats,
	}))
	if err != nil {
		return nil, err
	}

	h.svc.Log().Info().Str("txid", send.Msg.Txid).Uint8("slot", slot).
		Int64("amount_sats", req.Msg.AmountSats).Msg("broadcast the deposit")

	// An M5 is an ordinary transaction on the wire, so nothing later can tell
	// it apart from a normal send. Record it while we still know.
	if err := h.svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid:        send.Msg.Txid,
		WalletID:    walletID,
		Slot:        uint32(slot),
		Destination: destination,
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

// depositDestination unwraps the s<slot>_<address>_<checksum> deposit form to
// the bare address. The OP_RETURN must carry the bare address: the sidechain
// cannot parse the wrapped form and credits the coins to an unspendable address.
func depositDestination(slot uint8, destination string) (string, error) {
	if !strings.Contains(destination, "_") {
		return destination, nil
	}
	parts := strings.Split(destination, "_")
	if len(parts) > 3 || !strings.HasPrefix(parts[0], "s") {
		return "", fmt.Errorf("destination must be an address, s<slot>_<address>, or s<slot>_<address>_<checksum>")
	}
	prefixSlot, err := strconv.ParseUint(parts[0][1:], 10, 8)
	if err != nil {
		return "", fmt.Errorf("destination slot must be a number 0-255: %w", err)
	}
	if uint8(prefixSlot) != slot {
		return "", fmt.Errorf("destination is for slot %d, the request is for slot %d", prefixSlot, slot)
	}
	address := parts[1]
	if address == "" {
		return "", fmt.Errorf("destination holds no address")
	}
	if len(parts) == 3 {
		sum := sha256.Sum256(fmt.Appendf(nil, "s%d_%s_", slot, address))
		want := hex.EncodeToString(sum[:3])
		if strings.ToLower(parts[2]) != want {
			return "", fmt.Errorf("destination checksum mismatch: got %s, want %s", parts[2], want)
		}
	}
	return address, nil
}

// sidechainCtip reads the sidechain's current treasury outpoint, or nil when the
// sidechain has taken no deposit yet.
func (h *WalletHandler) sidechainCtip(
	ctx context.Context, slot uint32,
) (*enforcerpb.GetCtipResponse_Ctip, error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not wired"))
	}

	// A light install runs no enforcer. The hosted index reads the escrow on
	// its behalf, and the treasury it reports is the outpoint an M5 spends.
	if h.orch.NodeMode() == orchestrator.NodeModeLight {
		return h.indexCtip(ctx, slot)
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

// indexCtip reads the treasury outpoint from the hosted index, for an install
// that runs no enforcer of its own.
func (h *WalletHandler) indexCtip(
	ctx context.Context, slot uint32,
) (*enforcerpb.GetCtipResponse_Ctip, error) {
	url := config.DrivechainIndexURLForNetwork(config.Network(h.orch.CurrentNetwork()))
	if url == "" {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("this network serves no escrow index, so a deposit needs full mode"))
	}

	ctip, err := readIndexCtip(ctx, url, slot)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get ctip: %w", err))
	}
	if ctip == nil {
		h.svc.Log().Info().Uint32("slot", slot).Str("index", url).
			Msg("the index reports no treasury yet, so this deposit starts one")
		return nil, nil
	}

	h.svc.Log().Info().Uint32("slot", slot).Str("index", url).
		Str("txid", ctip.Txid).Uint32("vout", ctip.Vout).Uint64("value_sats", ctip.Value).
		Msg("read the treasury from the index, with no enforcer")

	return &enforcerpb.GetCtipResponse_Ctip{
		Txid:  &commonv1.ReverseHex{Hex: wrapperspb.String(ctip.Txid)},
		Vout:  ctip.Vout,
		Value: ctip.Value,
	}, nil
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
