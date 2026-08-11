package api

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math"
	"sort"
	"time"

	"connectrpc.com/connect"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines/bmmstate"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// BMMHandler serves BMMService. It owns bid assembly; the engine drives it on
// a loop so both paths build an M8 exactly one way.
type BMMHandler struct {
	orch   *orchestrator.Orchestrator
	wallet *WalletHandler
	engine *engines.BmmEngine
}

func NewBMMHandler(orch *orchestrator.Orchestrator, wallet *WalletHandler) *BMMHandler {
	return &BMMHandler{orch: orch, wallet: wallet}
}

// SetEngine wires the background bidder, which calls back into this handler.
func (h *BMMHandler) SetEngine(engine *engines.BmmEngine) {
	h.engine = engine
}

func (h *BMMHandler) Start(
	ctx context.Context, req *connect.Request[bmmpb.StartRequest],
) (*connect.Response[bmmpb.StartResponse], error) {
	if h.engine == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bmm engine not wired"))
	}
	if _, err := h.sidechainConfig(req.Msg.Sidechain); err != nil {
		return nil, err
	}
	if err := h.engine.Start(req.Msg.Sidechain, req.Msg.WalletId, req.Msg.MinBidSats, req.Msg.MaxBidSats); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	return connect.NewResponse(&bmmpb.StartResponse{}), nil
}

func (h *BMMHandler) Stop(
	ctx context.Context, req *connect.Request[bmmpb.StopRequest],
) (*connect.Response[bmmpb.StopResponse], error) {
	if h.engine == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bmm engine not wired"))
	}
	h.engine.Stop(req.Msg.Sidechain)
	return connect.NewResponse(&bmmpb.StopResponse{}), nil
}

func (h *BMMHandler) ClearHistory(
	ctx context.Context, req *connect.Request[bmmpb.ClearHistoryRequest],
) (*connect.Response[bmmpb.ClearHistoryResponse], error) {
	if h.engine == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bmm engine not wired"))
	}
	if err := h.engine.ClearHistory(req.Msg.Sidechain); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&bmmpb.ClearHistoryResponse{}), nil
}

// Watch streams the full bidding state on every change, so a reconnect needs
// no delta merge.
func (h *BMMHandler) Watch(
	ctx context.Context, req *connect.Request[bmmpb.WatchRequest], stream *connect.ServerStream[bmmpb.WatchResponse],
) error {
	if h.engine == nil {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bmm engine not wired"))
	}

	changed := h.engine.Subscribe(ctx)

	send := func() error {
		state, err := h.state(req.Msg.Sidechain)
		if err != nil {
			return err
		}
		return stream.Send(state)
	}
	if err := send(); err != nil {
		return err
	}

	heartbeat := time.NewTicker(WatchHeartbeatInterval)
	defer heartbeat.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-changed:
			if err := send(); err != nil {
				return err
			}
			heartbeat.Reset(WatchHeartbeatInterval)
		case <-heartbeat.C:
			if err := send(); err != nil {
				return err
			}
		}
	}
}

func (h *BMMHandler) state(sidechain pb.BinaryType) (*bmmpb.WatchResponse, error) {
	running, walletID, minBid, maxBid := h.engine.Running(sidechain)

	history, err := h.engine.History(sidechain)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	out := &bmmpb.WatchResponse{
		Running:    running,
		WalletId:   walletID,
		MinBidSats: minBid,
		MaxBidSats: maxBid,
		History:    lo.Map(history, func(r bmmstate.Round, _ int) *bmmpb.Round { return roundToProto(r) }),
	}
	if current := h.engine.Current(sidechain); current != nil {
		out.Current = roundToProto(*current)
	}
	return out, nil
}

func (h *BMMHandler) GetRoundBids(
	ctx context.Context, req *connect.Request[bmmpb.GetRoundBidsRequest],
) (*connect.Response[bmmpb.GetRoundBidsResponse], error) {
	if h.engine == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bmm engine not wired"))
	}
	round, err := h.engine.Round(req.Msg.Sidechain, req.Msg.PrevMainHash)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if round == nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("round %s not found", req.Msg.PrevMainHash))
	}
	return connect.NewResponse(&bmmpb.GetRoundBidsResponse{Round: roundToProto(*round)}), nil
}

func roundToProto(r bmmstate.Round) *bmmpb.Round {
	out := &bmmpb.Round{
		PrevMainHash:       r.PrevMainHash,
		PrevMainHeight:     r.PrevMainHeight,
		Result:             r.Result,
		BlockWorthSats:     r.BlockWorthSats,
		WinnerCriticalHash: r.WinnerCriticalHash,
		WinnerTxid:         r.WinnerTxid,
		WinnerBidSats:      r.WinnerBidSats,
		IncludedInBlock:    r.IncludedInBlock,
		IncludedInHeight:   r.IncludedInHeight,
		StartedAtUnix:      r.StartedAtUnix,
		OurBids:            lo.Map(r.OurBids, func(b bmmstate.Bid, _ int) *bmmpb.Bid { return bidToProto(b) }),
		OtherBids:          lo.Map(r.OtherBids, func(b bmmstate.Bid, _ int) *bmmpb.Bid { return bidToProto(b) }),
	}

	// Profit is only real once the block connects: a bid no miner took is
	// never paid, so it neither costs nor earns anything.
	if r.Result == engines.ResultWon {
		out.HasProfit = true
		out.ProfitSats = r.BlockWorthSats - r.WinnerBidSats
	}
	return out
}

func bidToProto(b bmmstate.Bid) *bmmpb.Bid {
	return &bmmpb.Bid{
		Txid:           b.Txid,
		CriticalHash:   b.CriticalHash,
		BidSats:        b.BidSats,
		IsOurs:         b.IsOurs,
		ReplacedByTxid: b.ReplacedByTxid,
		State:          b.State,
		Error:          b.Error,
		PrevMainHash:   b.PrevMainHash,
	}
}

// CreateBid assembles a sidechain block and broadcasts an M8 bid for it. The
// bid is the transaction's fee, which is the only thing a miner can collect.
func (h *BMMHandler) CreateBid(
	ctx context.Context, req *connect.Request[bmmpb.CreateBidRequest],
) (*connect.Response[bmmpb.CreateBidResponse], error) {
	if req.Msg.BidSats <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("bid_sats must be positive"))
	}
	cfg, proxy, err := h.sidechainTarget(req.Msg.Sidechain)
	if err != nil {
		return nil, err
	}

	template, err := proxy.GetBlockTemplate(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get block template: %w", err))
	}
	var block struct {
		Header struct {
			PrevMainHash string `json:"prev_main_hash"`
		} `json:"header"`
	}
	if err := json.Unmarshal(template.Block, &block); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("decode block header: %w", err))
	}

	// A bid only reaches the next block, so building on a tip the caller has
	// already moved past would spend the fee on a round that cannot be won.
	if want := req.Msg.ExpectPrevMainHash; want != "" && want != block.Header.PrevMainHash {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"sidechain builds on %s, not the current tip %s", block.Header.PrevMainHash, want,
		))
	}

	bidSats := req.Msg.BidSats
	if req.Msg.CapToBlockWorth && template.FeesSats > 0 && bidSats > template.FeesSats {
		bidSats = template.FeesSats
	}

	script, err := orchestrator.M8BmmRequestScript(
		uint8(cfg.Slot), template.CriticalHash, block.Header.PrevMainHash,
	)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("build bmm request: %w", err))
	}

	// Spending the earlier bid's inputs again replaces it, rather than
	// bidding against it: only one M8 per slot can be accepted.
	var requiredInputs []*wpb.UnspentOutput
	if req.Msg.ReplaceTxid != "" {
		requiredInputs, err = h.bidInputs(ctx, req.Msg.ReplaceTxid)
		if err != nil {
			return nil, err
		}
	}

	// The M8's OP_RETURN must be output 0 with no value, so the bid only
	// reaches a miner as the fee.
	send, err := h.wallet.SendTransaction(ctx, connect.NewRequest(&wpb.SendTransactionRequest{
		WalletId: req.Msg.WalletId,
		RawOutputs: []*wpb.RawOutput{{
			ValueSats: 0,
			ScriptHex: hex.EncodeToString(script),
		}},
		FixedFeeSats:   bidSats,
		RequiredInputs: requiredInputs,
		Replaceable:    true,
	}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&bmmpb.CreateBidResponse{
		CriticalHash: template.CriticalHash,
		BmmTxid:      send.Msg.Txid,
		FeesSats:     template.FeesSats,
		BlockJson:    string(template.Block),
		PrevMainHash: block.Header.PrevMainHash,
		BidSats:      bidSats,
	}), nil
}

func (h *BMMHandler) ConnectBid(
	ctx context.Context, req *connect.Request[bmmpb.ConnectBidRequest],
) (*connect.Response[bmmpb.ConnectBidResponse], error) {
	_, proxy, err := h.sidechainTarget(req.Msg.Sidechain)
	if err != nil {
		return nil, err
	}

	inclusions, err := proxy.GetBmmInclusions(ctx, req.Msg.CriticalHash)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get bmm inclusions: %w", err))
	}
	if len(inclusions) == 0 {
		return connect.NewResponse(&bmmpb.ConnectBidResponse{}), nil
	}

	mainBlockHash := inclusions[0]
	connected, err := proxy.ConnectBlock(ctx, json.RawMessage(req.Msg.BlockJson), mainBlockHash)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("connect block: %w", err))
	}
	return connect.NewResponse(&bmmpb.ConnectBidResponse{
		Connected:     connected,
		MainBlockHash: mainBlockHash,
	}), nil
}

// ListBids reads the slot's bids out of the mainchain mempool. An M8 is a
// standard transaction, so competitors are public until the block decides them.
func (h *BMMHandler) ListBids(
	ctx context.Context, req *connect.Request[bmmpb.ListBidsRequest],
) (*connect.Response[bmmpb.ListBidsResponse], error) {
	cfg, err := h.sidechainConfig(req.Msg.Sidechain)
	if err != nil {
		return nil, err
	}

	raw, err := h.coreCall(ctx, "getrawmempool", "[true]")
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get raw mempool: %w", err))
	}
	var mempool map[string]struct {
		Fees struct {
			Base float64 `json:"base"`
		} `json:"fees"`
	}
	if err := json.Unmarshal(raw, &mempool); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("decode mempool: %w", err))
	}

	var bids []*bmmpb.Bid
	for txid, entry := range mempool {
		rawTx, err := h.coreCall(ctx, "getrawtransaction", fmt.Sprintf("[%q,true]", txid))
		if err != nil {
			continue
		}
		var tx struct {
			Vout []struct {
				ScriptPubKey struct {
					Hex string `json:"hex"`
				} `json:"scriptPubKey"`
			} `json:"vout"`
		}
		if err := json.Unmarshal(rawTx, &tx); err != nil || len(tx.Vout) == 0 {
			continue
		}
		script, err := hex.DecodeString(tx.Vout[0].ScriptPubKey.Hex)
		if err != nil {
			continue
		}
		request := orchestrator.ParseM8BmmRequestScript(script)
		if request == nil || int(request.Slot) != cfg.Slot {
			continue
		}
		bids = append(bids, &bmmpb.Bid{
			Txid:         txid,
			CriticalHash: request.CriticalHash,
			PrevMainHash: request.PrevMainHash,
			BidSats:      int64(math.Round(entry.Fees.Base * 1e8)),
		})
	}
	sort.Slice(bids, func(i, j int) bool { return bids[i].BidSats > bids[j].BidSats })

	return connect.NewResponse(&bmmpb.ListBidsResponse{Bids: bids}), nil
}

// AttackBid bids on a slot with a commitment to no real block and never
// connects it, stalling an honest producer. Rejected on mainnet.
func (h *BMMHandler) AttackBid(
	ctx context.Context, req *connect.Request[bmmpb.AttackBidRequest],
) (*connect.Response[bmmpb.AttackBidResponse], error) {
	if req.Msg.BidSats <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("bid_sats must be positive"))
	}
	if h.orch != nil && h.orch.CurrentNetwork() == "mainnet" {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("attack bids are disabled on mainnet"))
	}

	cfg, proxy, err := h.sidechainTarget(req.Msg.Sidechain)
	if err != nil {
		return nil, err
	}

	template, err := proxy.GetBlockTemplate(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get block template: %w", err))
	}
	var block struct {
		Header struct {
			PrevMainHash string `json:"prev_main_hash"`
		} `json:"header"`
	}
	if err := json.Unmarshal(template.Block, &block); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("decode block header: %w", err))
	}

	fakeHash := make([]byte, 32)
	if _, err := rand.Read(fakeHash); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("random commitment: %w", err))
	}
	criticalHash := hex.EncodeToString(fakeHash)

	script, err := orchestrator.M8BmmRequestScript(uint8(cfg.Slot), criticalHash, block.Header.PrevMainHash)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("build bmm request: %w", err))
	}

	send, err := h.wallet.SendTransaction(ctx, connect.NewRequest(&wpb.SendTransactionRequest{
		WalletId: req.Msg.WalletId,
		RawOutputs: []*wpb.RawOutput{{
			ValueSats: 0,
			ScriptHex: hex.EncodeToString(script),
		}},
		FixedFeeSats: req.Msg.BidSats,
		Replaceable:  true,
	}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&bmmpb.AttackBidResponse{
		CriticalHash: criticalHash,
		BmmTxid:      send.Msg.Txid,
	}), nil
}

// Commitment reports the sidechain block a mainchain block committed to, which
// is how a round is decided when the winner was not us.
func (h *BMMHandler) Commitment(
	ctx context.Context, sidechainType pb.BinaryType, mainBlockHash string,
) (string, error) {
	cfg, err := h.sidechainConfig(sidechainType)
	if err != nil {
		return "", err
	}
	if h.orch == nil {
		return "", fmt.Errorf("orchestrator not wired")
	}
	validator, err := h.orch.EnforcerValidator()
	if err != nil {
		return "", err
	}

	resp, err := validator.GetBmmHStarCommitment(ctx, connect.NewRequest(&enforcerpb.GetBmmHStarCommitmentRequest{
		BlockHash:   &commonv1.ReverseHex{Hex: wrapperspb.String(mainBlockHash)},
		SidechainId: wrapperspb.UInt32(uint32(cfg.Slot)),
	}))
	if err != nil {
		return "", fmt.Errorf("get bmm commitment: %w", err)
	}
	return resp.Msg.GetCommitment().GetCommitment().GetHex().GetValue(), nil
}

func (h *BMMHandler) sidechainTarget(
	binary pb.BinaryType,
) (orchestrator.BinaryConfig, sidechain.SidechainRPCProxy, error) {
	cfg, err := h.sidechainConfig(binary)
	if err != nil {
		return orchestrator.BinaryConfig{}, nil, err
	}
	return cfg, sidechain.NewJSONRPCProxy(cfg.RPCHost(), cfg.Port), nil
}

// sidechainConfig resolves a sidechain binary to its config, with the slot it
// claims on the mainchain.
func (h *BMMHandler) sidechainConfig(binary pb.BinaryType) (orchestrator.BinaryConfig, error) {
	if h.orch == nil {
		return orchestrator.BinaryConfig{}, connect.NewError(
			connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not wired"),
		)
	}
	name, _, err := sidechainBalanceTarget(binary)
	if err != nil {
		return orchestrator.BinaryConfig{}, err
	}
	cfg, ok := h.orch.Configs()[name]
	if !ok {
		return orchestrator.BinaryConfig{}, connect.NewError(
			connect.CodeNotFound, fmt.Errorf("sidechain %s is not configured", name),
		)
	}
	if cfg.Slot < 0 || cfg.Slot > 255 {
		return orchestrator.BinaryConfig{}, connect.NewError(
			connect.CodeFailedPrecondition, fmt.Errorf("sidechain %s has no valid slot", name),
		)
	}
	return cfg, nil
}

func (h *BMMHandler) bidInputs(ctx context.Context, txid string) ([]*wpb.UnspentOutput, error) {
	raw, err := h.coreCall(ctx, "getrawtransaction", fmt.Sprintf("[%q,true]", txid))
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("read bid %s: %w", txid, err))
	}
	var tx struct {
		Vin []struct {
			Txid string `json:"txid"`
			Vout uint32 `json:"vout"`
		} `json:"vin"`
	}
	if err := json.Unmarshal(raw, &tx); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("decode bid %s: %w", txid, err))
	}
	if len(tx.Vin) == 0 {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bid %s has no inputs to reuse", txid))
	}
	return lo.Map(tx.Vin, func(in struct {
		Txid string `json:"txid"`
		Vout uint32 `json:"vout"`
	}, _ int) *wpb.UnspentOutput {
		return &wpb.UnspentOutput{Txid: in.Txid, Vout: int32(in.Vout)}
	}), nil
}

func (h *BMMHandler) coreCall(ctx context.Context, method, paramsJSON string) (json.RawMessage, error) {
	handler := NewHandler(h.orch)
	return handler.RawCoreCall(ctx, method, paramsJSON, "")
}
