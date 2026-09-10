package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math"
	"slices"
	"sort"
	"sync"
	"time"

	"github.com/rs/zerolog"

	"connectrpc.com/connect"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines/bmmstate"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// bmmAncestorWalk bounds the walk back from the tip when looking for the block
// that decided a round the engine slept through.
const bmmAncestorWalk = 200

const (
	// bmmSlotCoinRounds is how many rounds one slot coin funds. It sizes each
	// output of the coin split.
	bmmSlotCoinRounds = 20
	// bmmSlotCoinFeeSats is what a slot coin holds over the bid itself, for the
	// change output every bid adds. The coin split pays it as its fee.
	bmmSlotCoinFeeSats = 10_000
	// bmmSplitPatience is how long a split holds the next one back after the
	// mempool stops naming it. An Electrum wallet broadcasts through Esplora,
	// and the local node can take a moment to see the transaction.
	bmmSplitPatience = 10 * time.Minute
	// noSlot claims no slot, so every live bid counts as another slot's bid.
	noSlot = -1
)

// bidWallet is the wallet surface a bid spends through.
type bidWallet interface {
	// ResolveWalletID names the wallet an empty id means.
	ResolveWalletID(walletID string) (string, error)
	ListUnspent(
		context.Context, *connect.Request[wpb.ListUnspentRequest],
	) (*connect.Response[wpb.ListUnspentResponse], error)
	GetNewAddress(
		context.Context, *connect.Request[wpb.GetNewAddressRequest],
	) (*connect.Response[wpb.GetNewAddressResponse], error)
	SendTransaction(
		context.Context, *connect.Request[wpb.SendTransactionRequest],
	) (*connect.Response[wpb.SendTransactionResponse], error)
}

// BMMHandler serves BMMService. It owns bid assembly; the engine drives it on
// a loop so both paths build an M8 exactly one way.
type BMMHandler struct {
	orch   *orchestrator.Orchestrator
	wallet bidWallet
	engine *engines.BmmEngine
	// core reads bitcoind. A test supplies its own through SetCoreCaller.
	core CoreRawCaller

	splitMu sync.Mutex
	// splits names the coin split each wallet waits for. Bitcoin Core lists no
	// coin of an unconfirmed split, so this holds a second split back.
	splits map[string]pendingSplit
}

func NewBMMHandler(orch *orchestrator.Orchestrator, wallet *WalletHandler) *BMMHandler {
	h := &BMMHandler{orch: orch}
	// A nil pointer in the interface answers every call, and then panics inside
	// it. An empty field answers the wallet check below instead.
	if wallet != nil {
		h.wallet = wallet
	}
	return h
}

// SetCoreCaller replaces the bitcoind seam.
func (h *BMMHandler) SetCoreCaller(c CoreRawCaller) { h.core = c }

// SetEngine wires the background bidder, which calls back into this handler.
func (h *BMMHandler) SetEngine(engine *engines.BmmEngine) {
	h.engine = engine
}

func (h *BMMHandler) runsLocalCore() bool {
	return h.orch.NodeMode() != orchestrator.NodeModeLight
}

// ReadsMempool reports whether this install reads the mainchain mempool. Only a
// local Bitcoin Core serves that read; the remote enforcer publishes no mempool method.
func (h *BMMHandler) ReadsMempool() bool {
	return h.runsLocalCore()
}

func (h *BMMHandler) requireMempoolRead(action string) error {
	if h.ReadsMempool() {
		return nil
	}
	return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
		"%s reads the mainchain mempool, and light mode runs no Bitcoin Core", action))
}

// requireEnforcerSynced rejects bidding until the enforcer has validated every
// block Bitcoin Core knows about. A bid assembled against a trailing tip
// commits to a prev-main-hash miners have already built past, so it can never
// be included and the sats spent on it are lost.
//
// The rule matches SyncInfo.isSynced on the frontend, so both agree on when the
// controls unlock: GetSyncStatus fills the enforcer's Headers from the
// mainchain tip, leaving Blocks == Headers as "level with Core".
func (h *BMMHandler) requireEnforcerSynced(ctx context.Context) error {
	status, err := h.orch.GetSyncStatus(ctx)
	if err != nil {
		return connect.NewError(connect.CodeUnavailable, fmt.Errorf("read sync status: %w", err))
	}
	return enforcerBiddingBlocked(status, h.runsLocalCore())
}

// enforcerBiddingBlocked returns the reason bidding is unavailable for status,
// or nil when it is allowed. readsCore is false for an install with no local
// Bitcoin Core, which reports a mainchain error at all times.
func enforcerBiddingBlocked(status *orchestrator.SyncStatus, readsCore bool) error {
	if status == nil || status.Enforcer == nil || (readsCore && status.Mainchain == nil) {
		return connect.NewError(connect.CodeUnavailable, fmt.Errorf("sync status unavailable"))
	}
	if readsCore && status.Mainchain.Error != "" {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"bitcoin core is not available: %s", status.Mainchain.Error))
	}
	if msg := status.Enforcer.Error; msg != "" {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("enforcer is not available: %s", msg))
	}
	if !readsCore {
		return enforcerLevelWithChainSource(status)
	}
	if status.Enforcer.Headers <= 0 || status.Enforcer.Blocks != status.Enforcer.Headers {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"enforcer is still syncing: %d of %d blocks", status.Enforcer.Blocks, status.Enforcer.Headers,
		))
	}
	return nil
}

// enforcerLevelWithChainSource measures the remote enforcer against the wallet
// chain source. Without Core, GetSyncStatus fills the enforcer's Headers from
// its own Blocks, so that pair reports a stale enforcer as synced. The wallet
// chain source is the only other mainchain tip a light install reads.
func enforcerLevelWithChainSource(status *orchestrator.SyncStatus) error {
	source := status.ChainSource
	if source == nil || source.Error != "" || source.Blocks <= 0 {
		return connect.NewError(connect.CodeUnavailable, fmt.Errorf(
			"the wallet chain source reports no tip to measure the enforcer against"))
	}
	if status.Enforcer.Blocks < source.Blocks {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"enforcer is still syncing: %d of %d blocks", status.Enforcer.Blocks, source.Blocks,
		))
	}
	return nil
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
	if req.Msg.MaxBidSats <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("max_bid_sats must be positive"))
	}
	if err := h.requireEnforcerSynced(ctx); err != nil {
		return nil, err
	}
	// Past validation, an engine failure is a storage one, not a client one.
	if err := h.engine.Start(ctx, req.Msg.Sidechain, req.Msg.WalletId,
		req.Msg.MaxBidSats, req.Msg.CapToBlockWorth); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&bmmpb.StartResponse{}), nil
}

func (h *BMMHandler) Stop(
	ctx context.Context, req *connect.Request[bmmpb.StopRequest],
) (*connect.Response[bmmpb.StopResponse], error) {
	if h.engine == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bmm engine not wired"))
	}
	if err := h.engine.Stop(req.Msg.Sidechain); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
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
		state, err := h.state(ctx, req.Msg.Sidechain)
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

func (h *BMMHandler) state(ctx context.Context, sidechain pb.BinaryType) (*bmmpb.WatchResponse, error) {
	running, walletID, maxBid := h.engine.Running(sidechain)

	history, err := h.engine.History(sidechain)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	out := &bmmpb.WatchResponse{
		Running:               running,
		WalletId:              walletID,
		MaxBidSats:            maxBid,
		NextBlockFeeRateSatVb: h.engine.NextBlockRate(ctx),
		History:               lo.Map(history, func(r bmmstate.Round, _ int) *bmmpb.Round { return roundToProto(r) }),
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

	// A bid no miner took is never paid, so it neither costs nor earns. A won
	// bid is paid, and the block pays its fees back only once it connects.
	if r.Result == engines.ResultWon {
		out.HasProfit = true
		out.ProfitSats = -r.WinnerBidSats
		if wonBlockConnected(r) {
			out.ProfitSats = r.BlockWorthSats - r.WinnerBidSats
		}
	}
	return out
}

// wonBlockConnected reports whether the won block reached the sidechain.
func wonBlockConnected(r bmmstate.Round) bool {
	return lo.ContainsBy(r.OurBids, func(b bmmstate.Bid) bool {
		return b.State == engines.BidConnected
	})
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
	if err := checkBidInput(req.Msg.BidSats, req.Msg.FeeRateSatVb); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	// A raise is refused for good, so it names its own reason before a gate that refuses for a moment.
	if req.Msg.ReplaceTxid != "" {
		if err := h.requireMempoolRead("a raise"); err != nil {
			return nil, err
		}
	}
	if err := h.requireEnforcerSynced(ctx); err != nil {
		return nil, err
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

	bidSats, byRate := bidSizing(bidInput{
		bidSats:         bidSats,
		rateSatVb:       req.Msg.FeeRateSatVb,
		blockWorthSats:  template.FeesSats,
		maxBidSats:      req.Msg.MaxBidSats,
		capToBlockWorth: req.Msg.CapToBlockWorth,
	})

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
		var roots []string
		requiredInputs, roots, err = h.bidInputs(ctx, req.Msg.ReplaceTxid)
		if err != nil {
			return nil, err
		}
		// The replacement evicts every bid over those coins, so it pays more
		// than all of them together.
		floorSats, err := h.replacementFloorSats(ctx, roots)
		if err != nil {
			return nil, err
		}
		raised, ok := replacementBid(bidSats, floorSats, req.Msg.MaxBidSats)
		if !ok {
			return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
				"replacing %s costs %d sats, over the %d sat ceiling",
				req.Msg.ReplaceTxid, floorSats, req.Msg.MaxBidSats))
		}
		if raised != bidSats {
			bidSats, byRate = raised, false
		}
	} else {
		coin, err := h.slotCoin(ctx, req.Msg, cfg.Slot, pinSats(bidSats, byRate, req.Msg.FeeRateSatVb))
		if err != nil {
			return nil, err
		}
		requiredInputs = []*wpb.UnspentOutput{coin}
	}

	// The M8's OP_RETURN must be output 0 with no value, so the bid only
	// reaches a miner as the fee.
	//
	// A rate lets the wallet size the fee itself. A wallet that needs several
	// inputs, or signs a multisig descriptor, builds a larger transaction than
	// any fixed amount assumes, and would then pay under the rate it asked for.
	sendReq := &wpb.SendTransactionRequest{
		WalletId: req.Msg.WalletId,
		RawOutputs: []*wpb.RawOutput{{
			ValueSats: 0,
			ScriptHex: hex.EncodeToString(script),
		}},
		RequiredInputs: requiredInputs,
		Replaceable:    true,
	}
	if byRate {
		sendReq.FeeRateSatPerVbyte = int64(math.Ceil(req.Msg.FeeRateSatVb))
	} else {
		sendReq.FixedFeeSats = bidSats
	}

	send, err := h.wallet.SendTransaction(ctx, connect.NewRequest(sendReq))
	if err != nil {
		return nil, err
	}

	// The chain is the only place that knows what the bid cost. A rate lets
	// the wallet size the fee, and a fixed fee still grows when coin selection
	// leaves change below the dust threshold and pays the remainder instead.
	// The fee is spent by now, so a lookup that misses — an electrum broadcast
	// the local node has not seen, or a block that already took it — reports
	// the asking price rather than losing the bid.
	if !h.ReadsMempool() {
		bidSats = askingBidSats(bidSats, byRate, req.Msg.FeeRateSatVb)
	} else if paid, err := h.bidFeeSats(ctx, send.Msg.Txid); err == nil {
		bidSats = paid
	} else {
		bidSats = askingBidSats(bidSats, byRate, req.Msg.FeeRateSatVb)
		zerolog.Ctx(ctx).Warn().Err(err).Str("txid", send.Msg.Txid).
			Msg("could not read what the bid paid, reporting what it asked for")
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

	// A sidechain reports an inclusion only for a block it already holds, and it
	// gets ours from this very call.
	mainBlockHash := req.Msg.MainBlockHash
	if mainBlockHash == "" {
		inclusions, err := bmmInclusions(ctx, proxy, req.Msg.CriticalHash)
		if err != nil {
			return nil, err
		}
		mainBlockHash = connectTarget("", inclusions)
		if mainBlockHash == "" {
			return connect.NewResponse(&bmmpb.ConnectBidResponse{}), nil
		}
	}

	connected, err := proxy.ConnectBlock(ctx, json.RawMessage(req.Msg.BlockJson), mainBlockHash)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("connect block: %w", err))
	}
	if !connected {
		// A sidechain learns of an inclusion by polling, and refuses every block
		// until it does. The empty answer names no block, which is how the caller
		// tells that wait from a refusal it must not repeat.
		inclusions, err := bmmInclusions(ctx, proxy, req.Msg.CriticalHash)
		if err != nil {
			return nil, err
		}
		if connectTarget(mainBlockHash, inclusions) == "" {
			return connect.NewResponse(&bmmpb.ConnectBidResponse{}), nil
		}
	}
	return connect.NewResponse(&bmmpb.ConnectBidResponse{
		Connected:     connected,
		MainBlockHash: mainBlockHash,
	}), nil
}

func bmmInclusions(ctx context.Context, proxy sidechain.BMMNode, criticalHash string) ([]string, error) {
	inclusions, err := proxy.GetBmmInclusions(ctx, criticalHash)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get bmm inclusions: %w", err))
	}
	return inclusions, nil
}

// connectTarget picks the mainchain block to connect the won block on, empty
// while the sidechain lists no inclusion for it.
func connectTarget(want string, inclusions []string) string {
	if want == "" {
		if len(inclusions) == 0 {
			return ""
		}
		return inclusions[0]
	}
	if !slices.Contains(inclusions, want) {
		return ""
	}
	return want
}

// ListBids reads the slot's bids out of the mainchain mempool. An M8 is a
// standard transaction, so competitors are public until the block decides them.
func (h *BMMHandler) ListBids(
	ctx context.Context, req *connect.Request[bmmpb.ListBidsRequest],
) (*connect.Response[bmmpb.ListBidsResponse], error) {
	if err := h.requireMempoolRead("the competing bids"); err != nil {
		return nil, err
	}
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
		// A transaction can leave the mempool between the two reads, and one the
		// node cannot name is no competitor of ours.
		request, err := h.m8Request(ctx, txid)
		if err != nil || request == nil || int(request.Slot) != cfg.Slot {
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

// mempoolTxids names every transaction the mainchain mempool holds. It names
// none for an install that reads no mempool.
func (h *BMMHandler) mempoolTxids(ctx context.Context) (map[string]bool, error) {
	if !h.ReadsMempool() {
		return nil, nil
	}
	raw, err := h.coreCall(ctx, "getrawmempool", "[false]")
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get raw mempool: %w", err))
	}
	var txids []string
	if err := json.Unmarshal(raw, &txids); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("decode mempool: %w", err))
	}
	held := make(map[string]bool, len(txids))
	for _, txid := range txids {
		held[txid] = true
	}
	return held, nil
}

// m8Request reads the bid a transaction carries, nil when it carries none.
func (h *BMMHandler) m8Request(ctx context.Context, txid string) (*orchestrator.BmmRequest, error) {
	raw, err := h.coreCall(ctx, "getrawtransaction", fmt.Sprintf("[%q,true]", txid))
	if err != nil {
		return nil, fmt.Errorf("get raw transaction %s: %w", txid, err)
	}
	var tx struct {
		Vout []struct {
			ScriptPubKey struct {
				Hex string `json:"hex"`
			} `json:"scriptPubKey"`
		} `json:"vout"`
	}
	if err := json.Unmarshal(raw, &tx); err != nil {
		return nil, fmt.Errorf("decode transaction %s: %w", txid, err)
	}
	if len(tx.Vout) == 0 {
		return nil, nil
	}
	script, err := hex.DecodeString(tx.Vout[0].ScriptPubKey.Hex)
	if err != nil {
		return nil, fmt.Errorf("decode the script of %s: %w", txid, err)
	}
	return orchestrator.ParseM8BmmRequestScript(script), nil
}

// slotCoin picks the coin an opening bid spends, and holds every slot to a coin
// lineage of its own.
//
// One wallet funds all the sidechains. A bid built on another slot's bid change
// dies the moment that slot replaces its own bid, because a replacement evicts
// every mempool descendant of the transaction it replaces.
func (h *BMMHandler) slotCoin(
	ctx context.Context, req *bmmpb.CreateBidRequest, slot int, bidSats int64,
) (*wpb.UnspentOutput, error) {
	coins, err := h.readWalletCoins(ctx, req.WalletId, slot)
	if err != nil {
		return nil, err
	}

	// A slot-sized coin comes first, smallest of them: it covers the bid and
	// every raise on it, and it keeps the larger coins of the wallet out of the
	// bid lineage, where a replacement takes away whatever hangs below.
	want := bidSats + bmmSlotCoinFeeSats
	slotSats := slotCoinSats(req.MaxBidSats)
	var coin *wpb.UnspentOutput
	for _, u := range coins.own {
		if u.AmountSats < want {
			continue
		}
		if coin == nil || betterSlotCoin(u, coin, slotSats) {
			coin = u
		}
	}
	if coin == nil {
		// PrepareBMM pays the missing coins. The engine opens the round again on
		// the next tick, once one of them lands.
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"the wallet holds no coin of its own for slot %d", slot))
	}
	return coin, nil
}

// betterSlotCoin says whether a beats b as the coin one slot bids from. A coin
// that covers a full round of raises comes first, and the smallest of those
// wins. A wallet with none of them falls back to its largest coin.
func betterSlotCoin(a, b *wpb.UnspentOutput, slotSats int64) bool {
	aFits, bFits := a.AmountSats >= slotSats, b.AmountSats >= slotSats
	if aFits != bFits {
		return aFits
	}
	if aFits {
		return a.AmountSats < b.AmountSats
	}
	return a.AmountSats > b.AmountSats
}

// PrepareBMM gives every bidding sidechain a coin of its own, and splits one
// large coin when a wallet holds too few.
func (h *BMMHandler) PrepareBMM(
	ctx context.Context, req *connect.Request[bmmpb.PrepareBMMRequest],
) (*connect.Response[bmmpb.PrepareBMMResponse], error) {
	if len(req.Msg.Targets) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("targets must name a sidechain"))
	}
	if h.wallet == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("no wallet is wired"))
	}

	// Two targets can name one wallet, by its id and by the empty active id, and
	// both then bid from the same coins.
	type want struct {
		sidechains int32
		maxBidSats int64
	}
	wants := make(map[string]*want, len(req.Msg.Targets))
	var order []string
	for _, target := range req.Msg.Targets {
		if target.MaxBidSats <= 0 {
			return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("max_bid_sats must be positive"))
		}
		walletID, err := h.wallet.ResolveWalletID(target.WalletId)
		if err != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, err)
		}
		w, ok := wants[walletID]
		if !ok {
			w = &want{}
			wants[walletID] = w
			order = append(order, walletID)
		}
		w.sidechains++
		if target.MaxBidSats > w.maxBidSats {
			w.maxBidSats = target.MaxBidSats
		}
	}

	out := &bmmpb.PrepareBMMResponse{}
	var failure error
	for _, walletID := range order {
		w := wants[walletID]
		state, err := h.prepareWallet(ctx, walletID, w.sidechains, w.maxBidSats)
		if err != nil {
			// One wallet that cannot pay must not hold back the coins of the next
			// one, which the engine counts again only on the next block.
			if failure == nil {
				failure = err
			}
			continue
		}
		out.Wallets = append(out.Wallets, state)
	}
	if failure != nil {
		return nil, failure
	}
	return connect.NewResponse(out), nil
}

// prepareWallet counts the coins one wallet can bid from, and pays the missing
// ones out of its largest coin.
func (h *BMMHandler) prepareWallet(
	ctx context.Context, walletID string, sidechains int32, maxBidSats int64,
) (*bmmpb.PrepareBMMWallet, error) {
	coins, err := h.readWalletCoins(ctx, walletID, noSlot)
	if err != nil {
		return nil, err
	}

	workingSats := slotCoinSats(maxBidSats)
	// A coin a live bid created counts: that slot bids from it again, and its
	// replacement respends the same inputs.
	usable := lo.Filter(coins.all, func(u *wpb.UnspentOutput, _ int) bool {
		return u.AmountSats >= workingSats
	})

	out := &bmmpb.PrepareBMMWallet{
		WalletId:    walletID,
		UsableCoins: int32(len(usable)),
		WantedCoins: sidechains,
	}
	if int32(len(usable)) >= sidechains {
		h.splitLanded(walletID)
		return out, nil
	}
	// A split still in the mempool pays coins that a second split would spend
	// again.
	if h.pendingSplitTxid(walletID) != "" {
		return out, nil
	}

	source := largestCoin(coins.free)
	missing := int(sidechains) - len(usable)
	// The split spends its source, so a source that counts as usable pays itself
	// back as one more coin.
	if source != nil && source.AmountSats >= workingSats {
		missing++
	}

	txid, err := h.splitBMMCoins(ctx, walletID, source, missing, workingSats)
	if err != nil {
		return nil, err
	}
	h.holdSplit(walletID, txid)
	out.SplitTxid = txid
	return out, nil
}

// walletCoins is what one wallet holds for a bid.
type walletCoins struct {
	// all holds every coin the wallet can sign. A coin a live bid created still
	// belongs to the slot that made it, and that slot bids from it again.
	all []*wpb.UnspentOutput
	// own holds the coins a bid for the named slot may spend.
	own []*wpb.UnspentOutput
	// free holds the coins no live bid created, which a split may spend.
	free []*wpb.UnspentOutput
	// held names every transaction the mainchain mempool holds.
	held map[string]bool
}

// readWalletCoins sorts the coins of the wallet by the slot that may spend
// them. A bid over another slot's bid change dies with the replacement that
// slot broadcasts, because a replacement evicts every mempool descendant.
//
// A block already took a confirmed coin out of reach of a replacement, so only
// an unconfirmed coin costs a read. An unconfirmed coin the node cannot name
// waits: an Electrum wallet lists its own change before Core sees the bid that
// paid it.
func (h *BMMHandler) readWalletCoins(
	ctx context.Context, walletID string, slot int,
) (*walletCoins, error) {
	if h.wallet == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("no wallet is wired"))
	}
	resolved, err := h.wallet.ResolveWalletID(walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	unspent, err := h.wallet.ListUnspent(ctx, connect.NewRequest(&wpb.ListUnspentRequest{
		WalletId: resolved,
	}))
	if err != nil {
		return nil, err
	}
	held, err := h.mempoolTxids(ctx)
	if err != nil {
		return nil, err
	}
	// An electrum scan lists a coin a live bid already spends until the scan
	// catches up. An opening bid over one of those conflicts with that bid, and
	// the node refuses it at the same fee.
	bids := newBidCache(h)
	spent, err := h.bidSpentCoins(ctx, lo.Map(unspent.Msg.Utxos, func(u *wpb.UnspentOutput, _ int) wallet.Outpoint {
		return wallet.Outpoint{TxID: u.Txid, Vout: int(u.Vout), Confirmed: u.Confirmations > 0}
	}), bids)
	if err != nil {
		return nil, err
	}

	out := &walletCoins{held: held}
	for _, u := range unspent.Msg.Utxos {
		if !u.Spendable {
			continue
		}
		if spent[(wallet.Outpoint{TxID: u.Txid, Vout: int(u.Vout)}).Key()] {
			continue
		}
		if u.Confirmations > 0 {
			out.all = append(out.all, u)
			out.own = append(out.own, u)
			out.free = append(out.free, u)
			continue
		}
		if !h.ReadsMempool() {
			continue
		}
		request, err := bids.get(ctx, u.Txid)
		if err != nil {
			zerolog.Ctx(ctx).Debug().Err(err).Str("txid", u.Txid).Msg("read the parent of a wallet coin")
			continue
		}
		if request == nil {
			ancestor, err := bids.lineageBid(ctx, u.Txid)
			if err != nil {
				return nil, err
			}
			if ancestor != nil {
				continue
			}
		}
		out.all = append(out.all, u)
		if request == nil {
			out.own = append(out.own, u)
			out.free = append(out.free, u)
			continue
		}
		if int(request.Slot) == slot {
			out.own = append(out.own, u)
		}
	}
	h.clearSplitWhenDone(resolved, out.all, held)
	return out, nil
}

// splitBMMCoins pays count coins to the wallet itself, out of the source coin.
// It spends that one coin alone, so the coins the other slots bid from stay
// where they are.
func (h *BMMHandler) splitBMMCoins(
	ctx context.Context, walletID string, source *wpb.UnspentOutput, count int, coinSats int64,
) (string, error) {
	want := int64(count)*coinSats + bmmSlotCoinFeeSats
	if source == nil || source.AmountSats < want {
		return "", connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"no coin holds the %d sats that %d more bmm coins cost", want, count))
	}

	destinations := make(map[string]int64, count)
	for range count {
		addr, err := h.wallet.GetNewAddress(ctx, connect.NewRequest(&wpb.GetNewAddressRequest{
			WalletId: walletID,
		}))
		if err != nil {
			return "", err
		}
		destinations[addr.Msg.Address] = coinSats
	}
	if len(destinations) != count {
		return "", connect.NewError(connect.CodeInternal, fmt.Errorf(
			"the wallet named %d addresses for %d bmm coins", len(destinations), count))
	}

	send, err := h.wallet.SendTransaction(ctx, connect.NewRequest(&wpb.SendTransactionRequest{
		WalletId:       walletID,
		Destinations:   destinations,
		RequiredInputs: []*wpb.UnspentOutput{source},
		// The source pays this exact fee, or coin selection reaches for a second
		// coin and puts the split on another slot's lineage.
		FixedFeeSats: bmmSlotCoinFeeSats,
	}))
	if err != nil {
		return "", err
	}
	return send.Msg.Txid, nil
}

// pendingSplit is a coin split a wallet waits for.
type pendingSplit struct {
	txid string
	at   time.Time
}

// largestCoin names the coin that pays for a split, nil when the wallet holds
// none.
func largestCoin(coins []*wpb.UnspentOutput) *wpb.UnspentOutput {
	var largest *wpb.UnspentOutput
	for _, u := range coins {
		if largest == nil || u.AmountSats > largest.AmountSats {
			largest = u
		}
	}
	return largest
}

// askingBidSats is the price a bid asked for. It stands in when no mempool entry
// reports what the bid paid.
func askingBidSats(bidSats int64, byRate bool, rateSatVb float64) int64 {
	if !byRate {
		return bidSats
	}
	return int64(math.Ceil(rateSatVb * nominalBidVsize))
}

// pinSats is what the pinned coin has to cover. A bid sized at a rate carries
// no amount yet, and a coin under what that rate costs makes the wallet reach
// for a coin of another slot.
func pinSats(bidSats int64, byRate bool, rateSatVb float64) int64 {
	if !byRate {
		return bidSats
	}
	return int64(math.Ceil(rateSatVb * nominalBidVsize))
}

// slotCoinSats is the balance one slot works from: enough for many rounds at
// the ceiling the operator set, plus the change of each bid.
func slotCoinSats(maxBidSats int64) int64 {
	return maxBidSats*bmmSlotCoinRounds + bmmSlotCoinFeeSats
}

// pendingSplitTxid names the split the wallet waits for, empty when it waits
// for none.
func (h *BMMHandler) pendingSplitTxid(walletID string) string {
	h.splitMu.Lock()
	defer h.splitMu.Unlock()
	return h.splits[walletID].txid
}

func (h *BMMHandler) holdSplit(walletID, txid string) {
	h.splitMu.Lock()
	defer h.splitMu.Unlock()
	if h.splits == nil {
		h.splits = make(map[string]pendingSplit)
	}
	h.splits[walletID] = pendingSplit{txid: txid, at: time.Now()}
}

// clearSplitWhenDone drops the hold once the split paid a coin the wallet can
// name. A hold the mempool stopped naming waits out the propagation gap first,
// and then goes, or a split the node dropped holds the next one back forever.
func (h *BMMHandler) clearSplitWhenDone(
	walletID string, coins []*wpb.UnspentOutput, held map[string]bool,
) {
	h.splitMu.Lock()
	defer h.splitMu.Unlock()

	split, ok := h.splits[walletID]
	if !ok {
		return
	}
	for _, u := range coins {
		if u.Txid == split.txid {
			delete(h.splits, walletID)
			return
		}
	}
	if held[split.txid] || time.Since(split.at) < bmmSplitPatience {
		return
	}
	delete(h.splits, walletID)
}

// splitLanded drops the hold, because a wallet with a coin for every sidechain
// waits for nothing.
func (h *BMMHandler) splitLanded(walletID string) {
	h.splitMu.Lock()
	defer h.splitMu.Unlock()
	delete(h.splits, walletID)
}

// bidFeeSats reads what a broadcast bid paid, from the mempool entry Core
// keeps for it.
func (h *BMMHandler) bidFeeSats(ctx context.Context, txid string) (int64, error) {
	raw, err := h.coreCall(ctx, "getmempoolentry", fmt.Sprintf("[%q]", txid))
	if err != nil {
		return 0, err
	}
	var entry struct {
		Fees struct {
			Base float64 `json:"base"`
		} `json:"fees"`
	}
	if err := json.Unmarshal(raw, &entry); err != nil {
		return 0, fmt.Errorf("decode the mempool entry: %w", err)
	}
	return int64(math.Round(entry.Fees.Base * 1e8)), nil
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

// BlockAfter returns the mainchain block that follows prevMainHash on the chain
// ending at tipHash, empty when the walk back from the tip never reaches it.
func (h *BMMHandler) BlockAfter(ctx context.Context, prevMainHash, tipHash string) (string, error) {
	if h.orch == nil {
		return "", fmt.Errorf("orchestrator not wired")
	}
	validator, err := h.orch.EnforcerValidator()
	if err != nil {
		return "", err
	}

	resp, err := validator.GetBlockHeaderInfo(ctx, connect.NewRequest(&enforcerpb.GetBlockHeaderInfoRequest{
		BlockHash:    &commonv1.ReverseHex{Hex: wrapperspb.String(tipHash)},
		MaxAncestors: lo.ToPtr(uint32(bmmAncestorWalk)),
	}))
	if err != nil {
		return "", fmt.Errorf("get block header info: %w", err)
	}
	for _, info := range resp.Msg.GetHeaderInfos() {
		if info.GetPrevBlockHash().GetHex().GetValue() == prevMainHash {
			return info.GetBlockHash().GetHex().GetValue(), nil
		}
	}
	return "", nil
}

func (h *BMMHandler) sidechainTarget(
	binary pb.BinaryType,
) (orchestrator.BinaryConfig, sidechain.BMMNode, error) {
	cfg, err := h.sidechainConfig(binary)
	if err != nil {
		return orchestrator.BinaryConfig{}, nil, err
	}
	node, err := bmmNode(cfg, config.NetworkFromString(h.orch.CurrentNetwork()))
	if err != nil {
		return orchestrator.BinaryConfig{}, nil, connect.NewError(connect.CodeUnavailable, err)
	}
	return cfg, node, nil
}

// sidechainConfig resolves a sidechain binary to its config, with the slot it
// claims on the mainchain.
func (h *BMMHandler) sidechainConfig(binary pb.BinaryType) (orchestrator.BinaryConfig, error) {
	if h.orch == nil {
		return orchestrator.BinaryConfig{}, connect.NewError(
			connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not wired"),
		)
	}
	name, _, err := sidechainNames(binary)
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

// replacementFloorSats is the least a replacement can pay and still evict the
// transaction it replaces. The mempool counts that transaction and every
// descendant, and a replacement has to beat their total, so a long chain of
// stranded bids costs the sum of all of them.
//
// A transaction the mempool no longer holds needs no floor at all.
func (h *BMMHandler) replacementFloorSats(ctx context.Context, roots []string) (int64, error) {
	total, err := h.evictedFeeSats(ctx, h.evictedByReplacement(ctx, roots))
	if err != nil || total == 0 {
		return 0, err
	}
	return total + replacementBumpSats, nil
}

// evictedByReplacement names every transaction the replacement removes: each
// root of the chain and everything the mempool holds over it.
func (h *BMMHandler) evictedByReplacement(ctx context.Context, roots []string) []string {
	// One chain can carry two roots, and a bid over both of them belongs to
	// each root's descendants. So each transaction counts one time, by txid.
	seen := make(map[string]bool)
	var all []string
	for _, root := range roots {
		for _, txid := range append([]string{root}, h.mempoolDescendants(ctx, root)...) {
			if seen[txid] {
				continue
			}
			seen[txid] = true
			all = append(all, txid)
		}
	}
	return all
}

// evictedFeeSats totals the modified fees of the evicted transactions.
func (h *BMMHandler) evictedFeeSats(ctx context.Context, evicted []string) (int64, error) {
	var total int64
	for _, txid := range evicted {
		fee, ok, err := h.modifiedFeeSats(ctx, txid)
		if err != nil {
			return 0, err
		}
		if ok {
			total += fee
		}
	}
	// A node that deprioritised the chain reports a fee far below zero, and a
	// replacement then beats it at any price. Core compares the same modified
	// fees, so this is the number its own rule reads.
	return max(total, 0), nil
}

// mempoolDescendants names every transaction the mempool holds over one
// transaction. A read that fails names none, and the floor then counts the
// transactions it does know.
func (h *BMMHandler) mempoolDescendants(ctx context.Context, txid string) []string {
	raw, err := h.coreCall(ctx, "getmempooldescendants", fmt.Sprintf("[%q]", txid))
	if err != nil {
		return nil
	}
	var txids []string
	if err := json.Unmarshal(raw, &txids); err != nil {
		return nil
	}
	return txids
}

// modifiedFeeSats reads what one mempool transaction pays after the deltas a
// node applied. It reports false for a transaction the mempool no longer holds.
func (h *BMMHandler) modifiedFeeSats(ctx context.Context, txid string) (int64, bool, error) {
	raw, err := h.coreCall(ctx, "getmempoolentry", fmt.Sprintf("[%q]", txid))
	if err != nil {
		return 0, false, nil
	}
	var entry struct {
		Fees struct {
			Modified float64 `json:"modified"`
		} `json:"fees"`
	}
	if err := json.Unmarshal(raw, &entry); err != nil {
		return 0, false, connect.NewError(connect.CodeInternal,
			fmt.Errorf("decode mempool entry %s: %w", txid, err))
	}
	return int64(math.Round(entry.Fees.Modified * 1e8)), true, nil
}

// maxBidChain bounds the walk down a chain of stranded bids. A wallet that
// stacks more than this names a loop, not a chain.
const maxBidChain = 50

// bidInputs names the coins a replacement respends to evict a stranded bid.
//
// A new bid takes the change of the bid before it, so one stranded bid can
// carry a whole chain of stranded bids under it. Respending the top one leaves
// the rest, and every one of them holds the chain unminable. So the walk goes
// down while a parent is another bid for this slot, and it returns the coins a
// block already carries. Spending those evicts the whole chain at one time.
func (h *BMMHandler) bidInputs(
	ctx context.Context, txid string,
) (inputs []*wpb.UnspentOutput, roots []string, err error) {
	var (
		seen     = make(map[string]bool)
		rootSeen = make(map[string]bool)
	)

	var walk func(txid string, depth int) error
	walk = func(txid string, depth int) error {
		if depth > maxBidChain {
			return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
				"bid %s sits over more than %d unconfirmed bids", txid, maxBidChain))
		}
		spends, err := h.txInputs(ctx, txid)
		if err != nil {
			return err
		}
		for _, in := range spends {
			key := fmt.Sprintf("%s:%d", in.Txid, in.Vout)
			if seen[key] {
				continue
			}
			seen[key] = true
			if h.pendingBid(ctx, in.Txid) {
				if err := walk(in.Txid, depth+1); err != nil {
					return err
				}
				continue
			}
			inputs = append(inputs, in)
			// This bid holds a coin under the chain, so the mempool counts
			// every bid above it as its descendant.
			if !rootSeen[txid] {
				rootSeen[txid] = true
				roots = append(roots, txid)
			}
		}
		return nil
	}

	if err := walk(txid, 0); err != nil {
		return nil, nil, err
	}
	if len(inputs) == 0 {
		return nil, nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("bid %s has no inputs to reuse", txid))
	}
	return inputs, roots, nil
}

// txInputs names the outpoints one transaction spends.
func (h *BMMHandler) txInputs(ctx context.Context, txid string) ([]*wpb.UnspentOutput, error) {
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

// pendingBid says whether one transaction is an unconfirmed BMM request. The
// slot does not matter: one wallet funds the bids of every slot, so a bid for
// another slot can sit between two of ours, and stopping there would leave the
// stranded bid under it in place. A replacement evicts that other bid, and its
// own engine bids again on the next tip.
//
// Everything else stops the walk. A read that fails stops it too, because a
// coin the node cannot name is one the replacement keeps.
func (h *BMMHandler) pendingBid(ctx context.Context, txid string) bool {
	raw, err := h.coreCall(ctx, "getrawtransaction", fmt.Sprintf("[%q,true]", txid))
	if err != nil {
		return false
	}
	var tx struct {
		Confirmations int `json:"confirmations"`
		Vout          []struct {
			ScriptPubKey struct {
				Hex string `json:"hex"`
			} `json:"scriptPubKey"`
		} `json:"vout"`
	}
	if err := json.Unmarshal(raw, &tx); err != nil || tx.Confirmations > 0 || len(tx.Vout) == 0 {
		return false
	}
	script, err := hex.DecodeString(tx.Vout[0].ScriptPubKey.Hex)
	if err != nil {
		return false
	}
	return orchestrator.ParseM8BmmRequestScript(script) != nil
}

func (h *BMMHandler) coreCall(ctx context.Context, method, paramsJSON string) (json.RawMessage, error) {
	if h.core != nil {
		return h.core(ctx, method, paramsJSON, "")
	}
	handler := NewHandler(h.orch)
	return handler.RawCoreCall(ctx, method, paramsJSON, "")
}
