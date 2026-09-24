package api

import (
	"context"
	"encoding/json"
	"fmt"
	"math"

	"connectrpc.com/connect"

	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// defaultIncrementalFeeSatPerKvB is the incremental relay fee Bitcoin Core
// takes when no node reports its own.
const defaultIncrementalFeeSatPerKvB = 1000

// CancelBid replaces a stranded bid with a payment back to its own wallet.
//
// The replacement respends the coins under the whole unconfirmed bid chain, so
// it evicts every bid that sits on them, and it pays more than all of them
// together. It carries no M8, so the mempool drops the request and the coins
// come back.
func (h *BMMHandler) CancelBid(
	ctx context.Context, req *connect.Request[bmmpb.CancelBidRequest],
) (*connect.Response[bmmpb.CancelBidResponse], error) {
	if h.wallet == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("no wallet is loaded"))
	}
	if req.Msg.Txid == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("name the bid to cancel"))
	}
	walletID, err := h.wallet.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	own := h.ownBids()
	tip, err := own.tip(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	if err := requireStrandedBid(ctx, own, walletID, req.Msg.Txid, tip); err != nil {
		return nil, err
	}

	replacement, err := bidSource{h: h, own: own}.Replacement(ctx, walletID, req.Msg.Txid)
	if err != nil {
		return nil, err
	}
	inputs, evicted := replacement.Inputs, replacement.Evicted
	if err := requireNoLiveBid(ctx, own, walletID, evicted, tip, req.Msg.Txid); err != nil {
		return nil, err
	}

	vsize, err := cancelVsize(ctx, own, walletID, replacement.Roots, len(inputs))
	if err != nil {
		return nil, err
	}
	incrementalSatPerKvB, err := own.incrementalFeeSatPerKvB(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	totalSats, err := inputValueSats(ctx, own, walletID, inputs)
	if err != nil {
		return nil, err
	}
	feeSats := wallet.CancelFeeSats(replacement.EvictedFeeSats, vsize, incrementalSatPerKvB, 0)
	recoveredSats := totalSats - feeSats
	if recoveredSats < wallet.CancelDustSats {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"the coins under %s hold %d sats, under the %d sat replacement fee plus dust",
			req.Msg.Txid, totalSats, feeSats))
	}

	address, err := h.wallet.GetNewAddress(ctx, connect.NewRequest(&wpb.GetNewAddressRequest{
		WalletId: walletID,
	}))
	if err != nil {
		return nil, err
	}

	send, err := h.wallet.SendTransaction(ctx, connect.NewRequest(&wpb.SendTransactionRequest{
		WalletId:       walletID,
		Destinations:   map[string]int64{address.Msg.Address: recoveredSats},
		RequiredInputs: inputs,
		FixedFeeSats:   feeSats,
		Replaceable:    true,
	}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&bmmpb.CancelBidResponse{
		ReplacementTxid: send.Msg.Txid,
		RecoveredSats:   recoveredSats,
		FeeSats:         feeSats,
		CancelledTxids:  evicted,
	}), nil
}

// requireStrandedBid refuses a bid the next block can still take. Cancelling
// one throws away a round the wallet already paid for.
func requireStrandedBid(ctx context.Context, own ownBids, walletID, txid, tip string) error {
	if !own.pending(ctx, walletID, txid) {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"%s is not an unconfirmed BMM bid", txid))
	}
	if !own.live(ctx, walletID, txid) {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"bid %s is not in the mempool", txid))
	}
	bid, err := own.request(ctx, walletID, txid)
	if err != nil {
		return connect.NewError(connect.CodeNotFound, err)
	}
	if bid == nil {
		return connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("%s is not a BMM bid", txid))
	}
	if bid.PrevMainHash == tip {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"bid %s builds on the current tip and can still win", txid))
	}
	return nil
}

// cancelVsize bounds the size of the cancel. It spends only coins the roots
// spend, through one output, so only a longer signature makes it larger.
func cancelVsize(ctx context.Context, own ownBids, walletID string, roots []string, inputCount int) (int64, error) {
	var total int64
	for _, root := range roots {
		vsize, err := own.vsize(ctx, walletID, root)
		if err != nil {
			return 0, err
		}
		if vsize <= 0 {
			return 0, connect.NewError(connect.CodeInternal, fmt.Errorf("bid %s reports no size", root))
		}
		total += vsize
	}
	return total + int64(inputCount), nil
}

// incrementalRelayFeeSatPerKvB reads the rate a replacement pays on its own
// size, over the fees it evicts.
func incrementalRelayFeeSatPerKvB(ctx context.Context, call coreReader) (int64, error) {
	raw, err := call(ctx, "getnetworkinfo", "[]")
	if err != nil {
		return 0, fmt.Errorf("read the incremental relay fee: %w", err)
	}
	var info struct {
		IncrementalFee *float64 `json:"incrementalfee"`
	}
	if err := json.Unmarshal(raw, &info); err != nil {
		return 0, fmt.Errorf("decode the incremental relay fee: %w", err)
	}
	if info.IncrementalFee == nil {
		return 0, fmt.Errorf("the node reports no incremental relay fee")
	}
	return int64(math.Round(*info.IncrementalFee * 1e8)), nil
}

// requireNoLiveBid refuses a cancel that would take this round's bid with it.
// One wallet funds every slot, so a live bid of another slot can sit on the
// same coins.
func requireNoLiveBid(ctx context.Context, own ownBids, walletID string, evicted []string, tip, cancelling string) error {
	for _, txid := range evicted {
		if txid == cancelling {
			continue
		}
		req, err := own.request(ctx, walletID, txid)
		if err != nil || req == nil {
			continue
		}
		if req.PrevMainHash == tip {
			return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
				"cancelling %s would evict the live bid %s", cancelling, txid))
		}
	}
	return nil
}

// inputValueSats totals what the named outpoints hold. It reads each parent
// transaction one time, because a bid chain shares its parents.
func inputValueSats(ctx context.Context, own ownBids, walletID string, inputs []*wpb.UnspentOutput) (int64, error) {
	values := make(map[string][]int64, len(inputs))
	var total int64
	for _, in := range inputs {
		outs, ok := values[in.Txid]
		if !ok {
			var err error
			outs, err = own.outputValues(ctx, walletID, in.Txid)
			if err != nil {
				return 0, err
			}
			values[in.Txid] = outs
		}
		if int(in.Vout) >= len(outs) {
			return 0, connect.NewError(connect.CodeInternal, fmt.Errorf(
				"transaction %s has no output %d", in.Txid, in.Vout))
		}
		total += outs[in.Vout]
	}
	return total, nil
}

// outputValuesSats reads what every output of one transaction holds.
func outputValuesSats(ctx context.Context, call coreReader, txid string) ([]int64, error) {
	raw, err := call(ctx, "getrawtransaction", fmt.Sprintf("[%q,true]", txid))
	if err != nil {
		return nil, fmt.Errorf("read transaction %s: %w", txid, err)
	}
	var tx struct {
		Vout []struct {
			Value float64 `json:"value"`
		} `json:"vout"`
	}
	if err := json.Unmarshal(raw, &tx); err != nil {
		return nil, fmt.Errorf("decode transaction %s: %w", txid, err)
	}
	values := make([]int64, len(tx.Vout))
	for i, out := range tx.Vout {
		values[i] = int64(math.Round(out.Value * 1e8))
	}
	return values, nil
}
