package api

import (
	"time"

	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strconv"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/samber/lo"

	"connectrpc.com/connect/v2"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// CreateDeposit broadcasts a BIP300 deposit request: the amount to OP_DRIVECHAIN
// <slot> OP_TRUE, then the address in an OP_RETURN. It spends no CTIP; the block
// that mines it consolidates it into the slot's CTIP.
func (h *WalletHandler) CreateDeposit(
	ctx context.Context, req *wpb.CreateDepositRequest,
) (*wpb.CreateDepositResponse, error) {
	if req.AmountSats <= 0 {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "amount_sats must be positive")
	}
	if req.FeeSats <= 0 {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "fee_sats must be positive")
	}
	if req.Destination == "" {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "destination must be set")
	}
	if req.Slot < 0 || req.Slot > 255 {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "slot must be 0-255")
	}
	slot := uint8(req.Slot)

	destination, err := depositDestination(slot, req.Destination)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	if err := h.requireActiveSlot(ctx, uint32(slot)); err != nil {
		return nil, err
	}

	h.svc.Log().Info().Uint8("slot", slot).Str("destination", destination).
		Int64("amount_sats", req.AmountSats).Int64("fee_sats", req.FeeSats).
		Msg("building the deposit request")

	send, err := h.SendTransaction(ctx, &wpb.SendTransactionRequest{
		WalletId:     req.WalletId,
		RawOutputs:   []*wpb.RawOutput{{ValueSats: req.AmountSats, ScriptHex: hex.EncodeToString(orchestrator.M8TreasuryScript(slot))}},
		OpReturnHex:  hex.EncodeToString([]byte(destination)),
		FixedFeeSats: req.FeeSats,
	})
	if err != nil {
		return nil, err
	}

	h.svc.Log().Info().Str("txid", send.Txid).Uint8("slot", slot).
		Int64("amount_sats", req.AmountSats).Msg("broadcast the deposit request")

	// The broadcast already happened, so a failed record must not fail the call.
	if err := h.recordDeposit(ctx, wallet.SidechainDeposit{
		Txid:        send.Txid,
		WalletID:    walletID,
		Slot:        uint32(slot),
		Destination: destination,
		AmountSats:  req.AmountSats,
		FeeSats:     req.FeeSats,
	}); err != nil {
		h.svc.Log().Error().Err(err).Str("txid", send.Txid).Uint8("slot", slot).
			Msg("could not record the deposit request")
	}

	return &wpb.CreateDepositResponse{Txid: send.Txid}, nil
}

// depositDestination unwraps the s<slot>_<address>_<checksum> deposit form to
// the bare address. The OP_RETURN must carry the bare address: the sidechain
// cannot parse the wrapped form and credits the coins to an unspendable address.
func depositDestination(slot uint8, destination string) (string, error) {
	if err := orchestrator.CheckDepositDestination(destination); err != nil {
		return "", err
	}
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

// requireActiveSlot refuses a slot that holds no active sidechain: no sweep
// would ever consolidate a request to it.
func (h *WalletHandler) requireActiveSlot(ctx context.Context, slot uint32) error {
	if h.orch == nil {
		return connect.Errorf(connect.CodeFailedPrecondition, "orchestrator not wired")
	}
	validator, err := h.orch.EnforcerValidator()
	if err != nil {
		return connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	sidechains, err := validator.GetSidechains(ctx, &enforcerpb.GetSidechainsRequest{})
	if err != nil {
		return connect.NewError(connect.CodeUnavailable, fmt.Errorf("get sidechains: %w", err).Error())
	}
	active := lo.ContainsBy(sidechains.GetSidechains(), func(s *enforcerpb.GetSidechainsResponse_SidechainInfo) bool {
		return s.GetSidechainNumber().GetValue() == slot
	})
	if !active {
		return connect.Errorf(connect.CodeFailedPrecondition, "slot %d holds no active sidechain", slot)
	}
	return nil
}

// depositRecordAttempts is how many times a broadcast deposit tries to reach
// the store. The broadcast cannot be undone, so a busy database gets a retry.
const depositRecordAttempts = 3

// recordDeposit stores a deposit that is already on the wire.
func (h *WalletHandler) recordDeposit(ctx context.Context, d wallet.SidechainDeposit) error {
	var err error
	for attempt := 0; attempt < depositRecordAttempts; attempt++ {
		if err = h.svc.RecordSidechainDeposit(ctx, d); err == nil {
			return nil
		}
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(time.Duration(attempt+1) * 100 * time.Millisecond):
		}
	}
	return err
}

// ListSidechainDeposits reports the deposits this install made to a slot. The
// enforcer used to keep a global list in its own wallet; it runs none, so only
// our own deposits are knowable.
func (h *WalletHandler) ListSidechainDeposits(
	ctx context.Context, req *wpb.ListSidechainDepositsRequest,
) (*wpb.ListSidechainDepositsResponse, error) {
	deposits, err := h.svc.SidechainDeposits(ctx, req.Slot, req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &wpb.ListSidechainDepositsResponse{
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
				DroppedAt:     isoOrEmpty(d.DroppedAt),
			}
		}),
	}, nil
}

func isoOrEmpty(t time.Time) string {
	if t.IsZero() {
		return ""
	}
	return t.Format(time.RFC3339)
}

// depositConfirmations reads the chain rather than the store, because a
// confirmation count goes stale the moment a block arrives. Zero when the
// chain source cannot answer.
func (h *WalletHandler) depositConfirmations(ctx context.Context, d wallet.SidechainDeposit) int32 {
	// A dropped deposit is in no block, so zero is its real count and the
	// chain read would only confirm that.
	if !d.DroppedAt.IsZero() {
		return 0
	}
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
	ctx context.Context, req *wpb.GetSidechainDepositTotalsRequest,
) (*wpb.GetSidechainDepositTotalsResponse, error) {
	total, recent, err := h.svc.SidechainDepositTotals(ctx, time.Unix(req.SinceUnix, 0), req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &wpb.GetSidechainDepositTotalsResponse{
		TotalSats:  total,
		RecentSats: recent,
	}, nil
}
