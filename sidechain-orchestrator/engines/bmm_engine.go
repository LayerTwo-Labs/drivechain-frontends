package engines

import (
	"context"
	"fmt"
	"sync"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines/bmmstate"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

const (
	// bmmTickInterval is how often the tip and the competing bids are re-read.
	// One tick is a couple of local RPCs.
	bmmTickInterval = 2 * time.Second
	// bmmRaiseBumpSats is the smallest raise worth broadcasting: a replacement
	// must beat the incremental relay fee or Core rejects it outright.
	bmmRaiseBumpSats = 1000
	// bmmConnectAttempts bounds how long a won block is retried, at one attempt
	// per tick. The fee is already paid, so it is worth waiting minutes.
	bmmConnectAttempts = 150
)

// Round result values.
const (
	ResultOpen    = "open"
	ResultWon     = "won"
	ResultLost    = "lost"
	ResultSkipped = "skipped"
)

// Bid state values, for our own bids.
const (
	BidLive      = "live"
	BidReplaced  = "replaced"
	BidConnected = "connected"
	BidMissed    = "missed"
	BidFailed    = "failed"
)

// BmmBackend assembles, broadcasts and connects bids, and reads what a
// mainchain block committed to. Implemented by the BMM handler.
type BmmBackend interface {
	CreateBid(context.Context, *connect.Request[bmmpb.CreateBidRequest]) (*connect.Response[bmmpb.CreateBidResponse], error)
	ConnectBid(context.Context, *connect.Request[bmmpb.ConnectBidRequest]) (*connect.Response[bmmpb.ConnectBidResponse], error)
	ListBids(context.Context, *connect.Request[bmmpb.ListBidsRequest]) (*connect.Response[bmmpb.ListBidsResponse], error)
	// Commitment reports the sidechain block hash a mainchain block committed
	// to for this sidechain, empty when it carried none.
	Commitment(ctx context.Context, sidechain pb.BinaryType, mainBlockHash string) (string, error)
	// BlockAfter names the mainchain block following prevMainHash on the chain
	// ending at tipHash, empty when the walk never reaches it.
	BlockAfter(ctx context.Context, prevMainHash, tipHash string) (string, error)
}

// MainchainTip reports the mainchain tip the enforcer has validated.
type MainchainTip interface {
	ChainTip(context.Context) (hash string, height int32, err error)
}

type bmmTarget struct {
	minBidSats int64
	maxBidSats int64
	// walletID funds every bid. Empty spends from the active wallet.
	walletID string
	// lastTip is the tip this sidechain last opened a round on. Per sidechain,
	// so starting one does not have to wait out another's round.
	lastTip string
}

// BmmEngine opens a round on every new mainchain tip, raises while it is
// outbid, and settles the round once the next block decides it.
type BmmEngine struct {
	log     zerolog.Logger
	backend BmmBackend
	tip     MainchainTip
	store   *bmmstate.Store

	mu      sync.Mutex
	targets map[pb.BinaryType]bmmTarget
	current map[pb.BinaryType]*bmmstate.Round
	// unconnected holds rounds a miner took but the sidechain has not accepted
	// yet. Giving up here would forfeit a block we already paid for.
	unconnected map[pb.BinaryType][]*bmmstate.Round
	subs        map[chan struct{}]struct{}

	wake chan struct{}
}

func NewBmmEngine(log zerolog.Logger, backend BmmBackend, tip MainchainTip, store *bmmstate.Store) *BmmEngine {
	return &BmmEngine{
		log:         log.With().Str("component", "bmm").Logger(),
		backend:     backend,
		tip:         tip,
		store:       store,
		targets:     make(map[pb.BinaryType]bmmTarget),
		current:     make(map[pb.BinaryType]*bmmstate.Round),
		unconnected: make(map[pb.BinaryType][]*bmmstate.Round),
		subs:        make(map[chan struct{}]struct{}),
		wake:        make(chan struct{}, 1),
	}
}

// Start bids for sidechain on every new mainchain tip until Stop, raising
// toward maxBidSats when outbid. walletID funds every bid.
func (e *BmmEngine) Start(sidechain pb.BinaryType, walletID string, minBidSats, maxBidSats int64) error {
	if minBidSats <= 0 {
		return fmt.Errorf("min_bid_sats must be positive")
	}
	if maxBidSats < minBidSats {
		return fmt.Errorf("max_bid_sats must be at least min_bid_sats")
	}

	e.mu.Lock()
	target := bmmTarget{minBidSats: minBidSats, maxBidSats: maxBidSats, walletID: walletID}
	if existing, ok := e.targets[sidechain]; ok {
		target.lastTip = existing.lastTip
	} else if round, ok := e.current[sidechain]; ok {
		target.lastTip = round.PrevMainHash
	}
	e.targets[sidechain] = target
	e.mu.Unlock()

	e.log.Info().Stringer("sidechain", sidechain).
		Int64("min_bid_sats", minBidSats).Int64("max_bid_sats", maxBidSats).Msg("bmm started")
	e.notify()
	e.poke()
	return nil
}

// Stop ends automated bidding. Bids already broadcast still settle.
func (e *BmmEngine) Stop(sidechain pb.BinaryType) {
	e.mu.Lock()
	delete(e.targets, sidechain)
	e.mu.Unlock()
	e.log.Info().Stringer("sidechain", sidechain).Msg("bmm stopped")
	e.notify()
}

// ResetForNetwork drops automation and per-chain round state, and repoints the
// store, so a network swap cannot leave the engine bidding on a chain the user
// never armed it for.
func (e *BmmEngine) ResetForNetwork(networkDir string) {
	e.store.Rebind(networkDir)
	e.mu.Lock()
	e.targets = make(map[pb.BinaryType]bmmTarget)
	e.current = make(map[pb.BinaryType]*bmmstate.Round)
	e.unconnected = make(map[pb.BinaryType][]*bmmstate.Round)
	e.mu.Unlock()
	e.log.Info().Msg("bmm automation cleared for network swap")
	e.notify()
}

// Running reports whether the engine bids for sidechain, with the wallet it
// spends from and its bid bounds.
func (e *BmmEngine) Running(sidechain pb.BinaryType) (bool, string, int64, int64) {
	e.mu.Lock()
	defer e.mu.Unlock()
	t, ok := e.targets[sidechain]
	return ok, t.walletID, t.minBidSats, t.maxBidSats
}

// Current returns the round being bid on, or nil.
func (e *BmmEngine) Current(sidechain pb.BinaryType) *bmmstate.Round {
	e.mu.Lock()
	defer e.mu.Unlock()
	round, ok := e.current[sidechain]
	if !ok {
		return nil
	}
	out := cloneRound(round)
	return &out
}

// cloneRound deep-copies a round so readers never share the bid slices the
// engine keeps mutating.
func cloneRound(r *bmmstate.Round) bmmstate.Round {
	out := *r
	out.OurBids = append([]bmmstate.Bid(nil), r.OurBids...)
	out.OtherBids = append([]bmmstate.Bid(nil), r.OtherBids...)
	return out
}

// History returns a sidechain's settled rounds, newest first.
func (e *BmmEngine) History(sidechain pb.BinaryType) ([]bmmstate.Round, error) {
	return e.store.List(int32(sidechain))
}

// Round returns one round by its mainchain tip, current or settled.
func (e *BmmEngine) Round(sidechain pb.BinaryType, prevMainHash string) (*bmmstate.Round, error) {
	if current := e.Current(sidechain); current != nil && current.PrevMainHash == prevMainHash {
		return current, nil
	}
	return e.store.Get(int32(sidechain), prevMainHash)
}

// ClearHistory drops the settled rounds for a sidechain.
func (e *BmmEngine) ClearHistory(sidechain pb.BinaryType) error {
	if err := e.store.Clear(int32(sidechain)); err != nil {
		return err
	}
	e.notify()
	return nil
}

// Subscribe reports every change to bidding state until ctx ends.
func (e *BmmEngine) Subscribe(ctx context.Context) <-chan struct{} {
	ch := make(chan struct{}, 1)

	e.mu.Lock()
	e.subs[ch] = struct{}{}
	e.mu.Unlock()

	go func() {
		<-ctx.Done()
		e.mu.Lock()
		delete(e.subs, ch)
		e.mu.Unlock()
	}()

	return ch
}

func (e *BmmEngine) notify() {
	e.mu.Lock()
	defer e.mu.Unlock()
	for ch := range e.subs {
		select {
		case ch <- struct{}{}:
		default:
		}
	}
}

func (e *BmmEngine) poke() {
	select {
	case e.wake <- struct{}{}:
	default:
	}
}

// Run loops until ctx is cancelled. A sidechain that errors is logged and the
// rest of the pass continues — one dead node must not stall the others.
func (e *BmmEngine) Run(ctx context.Context) error {
	ticker := time.NewTicker(bmmTickInterval)
	defer ticker.Stop()

	e.resumeUnconnected()
	e.log.Info().Dur("interval", bmmTickInterval).Msg("bmm engine started")

	for {
		e.tick(ctx)
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
		case <-e.wake:
		}
	}
}

// resumeUnconnected reloads blocks a miner took that were never accepted by the
// sidechain, so a restart mid-round does not forfeit a block already paid for.
func (e *BmmEngine) resumeUnconnected() {
	rounds, err := e.store.All()
	if err != nil {
		e.log.Warn().Err(err).Msg("read stored rounds")
		return
	}

	e.mu.Lock()
	defer e.mu.Unlock()
	for i := range rounds {
		round := rounds[i]
		// Open rounds are the ones the engine could not decide before it stopped;
		// both they and won rounds may still hold a block already paid for.
		if round.Result != ResultWon && round.Result != ResultOpen {
			continue
		}
		live := liveBid(&round)
		if live == nil {
			continue
		}
		sidechain := pb.BinaryType(round.Sidechain)
		e.unconnected[sidechain] = append(e.unconnected[sidechain], &round)
		e.log.Info().Stringer("sidechain", sidechain).Str("round", round.PrevMainHash).
			Msg("resuming a won block that never connected")
	}
}

func (e *BmmEngine) tick(ctx context.Context) {
	e.mu.Lock()
	targets := make(map[pb.BinaryType]bmmTarget, len(e.targets))
	for k, v := range e.targets {
		targets[k] = v
	}
	e.mu.Unlock()

	pending := e.pendingSidechains()
	if len(targets) == 0 && len(pending) == 0 {
		return
	}

	tip, height, err := e.tip.ChainTip(ctx)
	if err != nil {
		e.log.Debug().Err(err).Msg("read mainchain tip")
		return
	}
	if tip == "" {
		return
	}

	// Settle and retry for every sidechain with work outstanding, not just the
	// ones still bidding: Stop must not strand a bid that is already paid for.
	for _, sidechain := range pending {
		if ctx.Err() != nil {
			return
		}
		e.retryConnects(ctx, sidechain, tip, height)
		if _, bidding := targets[sidechain]; bidding {
			continue
		}
		// Only once the tip has moved past it: until then the bid can still win.
		if round := e.Current(sidechain); round != nil && round.PrevMainHash != tip {
			e.settleRound(ctx, sidechain, tip, height)
		}
	}

	for sidechain, target := range targets {
		if ctx.Err() != nil {
			return
		}

		// Same tip means the same round; the only move left is to out-bid.
		if target.lastTip == tip {
			e.maybeRaise(ctx, sidechain, target)
			continue
		}
		if !e.markTip(sidechain, tip) {
			continue
		}
		e.settleRound(ctx, sidechain, tip, height)
		e.openRound(ctx, sidechain, tip, height, target)
	}
}

// pendingSidechains lists sidechains with an open round or an unconnected win.
func (e *BmmEngine) pendingSidechains() []pb.BinaryType {
	e.mu.Lock()
	defer e.mu.Unlock()

	seen := make(map[pb.BinaryType]bool)
	var out []pb.BinaryType
	for sidechain, round := range e.current {
		if round != nil && !seen[sidechain] {
			seen[sidechain] = true
			out = append(out, sidechain)
		}
	}
	for sidechain, rounds := range e.unconnected {
		if len(rounds) > 0 && !seen[sidechain] {
			seen[sidechain] = true
			out = append(out, sidechain)
		}
	}
	return out
}

// markTip records the tip a sidechain is about to open a round on. It reports
// false when the sidechain was stopped in the meantime.
func (e *BmmEngine) markTip(sidechain pb.BinaryType, tip string) bool {
	e.mu.Lock()
	defer e.mu.Unlock()

	target, ok := e.targets[sidechain]
	if !ok {
		return false
	}
	target.lastTip = tip
	e.targets[sidechain] = target
	return true
}

// openRound snapshots who else is bidding, then places the opening bid.
func (e *BmmEngine) openRound(
	ctx context.Context, sidechain pb.BinaryType, tip string, height int32, target bmmTarget,
) {
	round := &bmmstate.Round{
		Sidechain:      int32(sidechain),
		PrevMainHash:   tip,
		PrevMainHeight: height,
		Result:         ResultOpen,
		StartedAtUnix:  time.Now().Unix(),
	}
	round.OtherBids = e.snapshotOthers(ctx, sidechain, tip)

	e.mu.Lock()
	e.current[sidechain] = round
	e.mu.Unlock()

	if err := e.placeBid(ctx, sidechain, round, target.walletID, target.minBidSats, ""); err != nil {
		if connect.CodeOf(err) == connect.CodeFailedPrecondition {
			e.log.Info().Err(err).Stringer("sidechain", sidechain).Msg("opening bmm bid refused, retrying next tick")
			e.retryTip(sidechain, tip)
		} else {
			e.log.Warn().Err(err).Stringer("sidechain", sidechain).Msg("opening bmm bid failed")
		}
	}
	e.notify()
}

// retryTip unwinds a round whose opening bid was refused on a precondition, so
// the next tick opens it again on the same tip. The sync snapshot the backend
// gates on can trail the tip read here by one poll interval; without this the
// tip stays marked, every later tick takes the maybeRaise path, and the block
// is skipped for good.
func (e *BmmEngine) retryTip(sidechain pb.BinaryType, tip string) {
	e.mu.Lock()
	defer e.mu.Unlock()

	if round, ok := e.current[sidechain]; ok && round != nil && round.PrevMainHash == tip {
		delete(e.current, sidechain)
	}
	target, ok := e.targets[sidechain]
	if !ok || target.lastTip != tip {
		return
	}
	target.lastTip = ""
	e.targets[sidechain] = target
}

// snapshotOthers records the competing bids. Once the round is decided these
// are unrecoverable, so this is the only chance to see them.
func (e *BmmEngine) snapshotOthers(ctx context.Context, sidechain pb.BinaryType, tip string) []bmmstate.Bid {
	resp, err := e.backend.ListBids(ctx, connect.NewRequest(&bmmpb.ListBidsRequest{Sidechain: sidechain}))
	if err != nil {
		e.log.Debug().Err(err).Stringer("sidechain", sidechain).Msg("read competing bids")
		return nil
	}

	ours := e.ourTxids(sidechain)
	out := make([]bmmstate.Bid, 0, len(resp.Msg.Bids))
	for _, b := range resp.Msg.Bids {
		if ours[b.Txid] {
			continue
		}
		// A bid built on another tip can never win this round, so raising
		// against it would spend for nothing.
		if tip != "" && b.PrevMainHash != "" && b.PrevMainHash != tip {
			continue
		}
		out = append(out, bmmstate.Bid{
			Txid:         b.Txid,
			CriticalHash: b.CriticalHash,
			PrevMainHash: b.PrevMainHash,
			BidSats:      b.BidSats,
		})
	}
	return out
}

func (e *BmmEngine) ourTxids(sidechain pb.BinaryType) map[string]bool {
	e.mu.Lock()
	defer e.mu.Unlock()

	out := make(map[string]bool)
	if round, ok := e.current[sidechain]; ok {
		for _, b := range round.OurBids {
			out[b.Txid] = true
		}
	}
	return out
}

// placeBid broadcasts an M8 and records it. replaceTxid raises an earlier bid,
// which evicts that one from the mempool.
func (e *BmmEngine) placeBid(
	ctx context.Context, sidechain pb.BinaryType, round *bmmstate.Round,
	walletID string, bidSats int64, replaceTxid string,
) error {
	resp, err := e.backend.CreateBid(ctx, connect.NewRequest(&bmmpb.CreateBidRequest{
		Sidechain:          sidechain,
		WalletId:           walletID,
		BidSats:            bidSats,
		ReplaceTxid:        replaceTxid,
		ExpectPrevMainHash: round.PrevMainHash,
		CapToBlockWorth:    true,
	}))

	e.mu.Lock()
	defer e.mu.Unlock()

	if err != nil {
		round.OurBids = append(round.OurBids, bmmstate.Bid{
			BidSats: bidSats,
			IsOurs:  true,
			State:   BidFailed,
			Error:   err.Error(),
		})
		return err
	}

	if replaceTxid != "" {
		for i := range round.OurBids {
			if round.OurBids[i].Txid == replaceTxid {
				round.OurBids[i].ReplacedByTxid = resp.Msg.BmmTxid
				round.OurBids[i].State = BidReplaced
			}
		}
	}

	round.BlockWorthSats = resp.Msg.FeesSats
	if resp.Msg.BidSats > 0 {
		bidSats = resp.Msg.BidSats
	}
	round.OurBids = append(round.OurBids, bmmstate.Bid{
		Txid:         resp.Msg.BmmTxid,
		CriticalHash: resp.Msg.CriticalHash,
		PrevMainHash: resp.Msg.PrevMainHash,
		BidSats:      bidSats,
		IsOurs:       true,
		State:        BidLive,
		BlockJSON:    resp.Msg.BlockJson,
		WalletID:     walletID,
	})

	e.log.Info().Stringer("sidechain", sidechain).Str("txid", resp.Msg.BmmTxid).
		Int64("bid_sats", bidSats).Int64("block_worth_sats", resp.Msg.FeesSats).Msg("bmm bid broadcast")
	return nil
}

// maybeRaise replaces our live bid when a competitor has overtaken it, never
// going above the ceiling or above what the block is worth.
func (e *BmmEngine) maybeRaise(ctx context.Context, sidechain pb.BinaryType, target bmmTarget) {
	e.mu.Lock()
	round, ok := e.current[sidechain]
	e.mu.Unlock()
	if !ok || round == nil {
		return
	}

	others := e.snapshotOthers(ctx, sidechain, round.PrevMainHash)

	e.mu.Lock()
	round.OtherBids = others
	live := liveBid(round)
	worth := round.BlockWorthSats
	e.mu.Unlock()

	if live == nil {
		return
	}

	top := int64(0)
	for _, b := range others {
		if b.BidSats > top {
			top = b.BidSats
		}
	}
	if top < live.BidSats {
		return
	}

	ceiling := target.maxBidSats
	if worth > 0 && worth < ceiling {
		ceiling = worth
	}
	next := top + bmmRaiseBumpSats
	if next > ceiling || next <= live.BidSats {
		return
	}

	// The raise respends the live bid's inputs, so only the wallet that funded
	// it can sign them.
	walletID := live.WalletID
	if walletID == "" {
		walletID = target.walletID
	}

	e.log.Info().Stringer("sidechain", sidechain).
		Int64("from_sats", live.BidSats).Int64("to_sats", next).Msg("raising bmm bid")
	// The live bid stands when a raise is refused, so the round carries on at
	// its current price rather than being unwound.
	if err := e.placeBid(ctx, sidechain, round, walletID, next, live.Txid); err != nil {
		e.log.Warn().Err(err).Stringer("sidechain", sidechain).
			Int64("to_sats", next).Msg("raising bmm bid failed, keeping the live bid")
	}
	e.notify()
}

func liveBid(round *bmmstate.Round) *bmmstate.Bid {
	for i := len(round.OurBids) - 1; i >= 0; i-- {
		if round.OurBids[i].State == BidLive {
			return &round.OurBids[i]
		}
	}
	return nil
}

// settleRound decides the round the new tip just closed: the mined block
// carried one of our bids, someone else's, or no commitment at all.
func (e *BmmEngine) settleRound(ctx context.Context, sidechain pb.BinaryType, newTip string, newHeight int32) {
	e.mu.Lock()
	round, ok := e.current[sidechain]
	if ok {
		delete(e.current, sidechain)
	}
	e.mu.Unlock()

	if !ok || round == nil {
		return
	}

	if len(round.OurBids) == 0 {
		round.Result = ResultSkipped
		e.save(round)
		return
	}

	live := liveBid(round)
	commitment, err := e.backend.Commitment(ctx, sidechain, newTip)
	if err != nil && live != nil {
		// Without the commitment we cannot tell a loss from a win, and calling
		// it lost would stop us connecting a block we may have paid for.
		e.log.Debug().Err(err).Stringer("sidechain", sidechain).Msg("read bmm commitment")
		e.park(sidechain, round)
		return
	}

	round.IncludedInBlock = newTip
	round.IncludedInHeight = newHeight
	round.WinnerCriticalHash = commitment

	if commitment != "" && live != nil && commitment == live.CriticalHash {
		round.Result = ResultWon
		round.WinnerTxid = live.Txid
		round.WinnerBidSats = live.BidSats
		// The fee is already paid, so a sidechain that rejects the block now is
		// worth retrying rather than forfeiting.
		if !e.connectWon(ctx, sidechain, round) {
			e.park(sidechain, round)
		}
		e.save(round)
		return
	}

	// The tip ran past the block that decided this round, so its commitment says
	// nothing about our bid: settle on the deciding block instead.
	if live != nil && newHeight > round.PrevMainHeight+1 {
		if !e.settleOutrunRound(ctx, sidechain, round, live, newTip, newHeight) {
			e.park(sidechain, round)
		}
		return
	}

	e.markLost(round, live, commitment)
}

// markLost records a round another bidder took, naming the winner when their
// bid was in our snapshot of the round.
func (e *BmmEngine) markLost(round *bmmstate.Round, live *bmmstate.Bid, commitment string) {
	round.Result = ResultLost
	if live != nil {
		live.State = BidMissed
	}
	for _, b := range round.OtherBids {
		if commitment != "" && b.CriticalHash == commitment {
			round.WinnerTxid = b.Txid
			round.WinnerBidSats = b.BidSats
			break
		}
	}
	e.save(round)
}

// settleOutrunRound decides a round whose deciding block the engine slept
// through, by walking back from the tip to that block.
func (e *BmmEngine) settleOutrunRound(
	ctx context.Context, sidechain pb.BinaryType, round *bmmstate.Round, live *bmmstate.Bid,
	tip string, tipHeight int32,
) bool {
	decider := tip
	if tipHeight != round.PrevMainHeight+1 {
		found, err := e.backend.BlockAfter(ctx, round.PrevMainHash, tip)
		if err != nil || found == "" {
			e.log.Warn().Err(err).Stringer("sidechain", sidechain).Str("round", round.PrevMainHash).
				Msg("cannot name the block that decided this round")
			return false
		}
		decider = found
	}

	commitment, err := e.backend.Commitment(ctx, sidechain, decider)
	if err != nil {
		e.log.Warn().Err(err).Stringer("sidechain", sidechain).Str("main_block", decider).
			Msg("read bmm commitment of the deciding block")
		return false
	}

	round.IncludedInBlock = decider
	round.IncludedInHeight = round.PrevMainHeight + 1
	round.WinnerCriticalHash = commitment

	if commitment != live.CriticalHash {
		e.markLost(round, live, commitment)
		return true
	}

	round.Result = ResultWon
	round.WinnerTxid = live.Txid
	round.WinnerBidSats = live.BidSats
	connected := e.connectWon(ctx, sidechain, round)
	e.save(round)
	return connected
}

// park queues a round for the retry pass and records it, so a restart mid-wait
// can resume a block already paid for.
func (e *BmmEngine) park(sidechain pb.BinaryType, round *bmmstate.Round) {
	e.mu.Lock()
	e.unconnected[sidechain] = append(e.unconnected[sidechain], round)
	e.mu.Unlock()
	e.save(round)
}

// retryConnects re-attempts blocks a miner took that the sidechain has not
// accepted yet.
func (e *BmmEngine) retryConnects(ctx context.Context, sidechain pb.BinaryType, tip string, tipHeight int32) {
	e.mu.Lock()
	pending := e.unconnected[sidechain]
	e.unconnected[sidechain] = nil
	e.mu.Unlock()

	if len(pending) == 0 {
		return
	}

	var stillPending []*bmmstate.Round
	for _, round := range pending {
		if e.retryRound(ctx, sidechain, round, tip, tipHeight) {
			continue
		}
		round.BlocksWaited++
		if round.BlocksWaited < bmmConnectAttempts {
			stillPending = append(stillPending, round)
			continue
		}
		// No commitment ever said another bidder took it, so it stays open and a
		// restart can pick it up again.
		if round.Result == ResultOpen {
			e.log.Warn().Stringer("sidechain", sidechain).Str("round", round.PrevMainHash).
				Msg("giving up on deciding this round for now")
		}
	}

	e.mu.Lock()
	e.unconnected[sidechain] = append(e.unconnected[sidechain], stillPending...)
	e.mu.Unlock()
}

// retryRound settles a round still waiting: one whose deciding block was never
// named has to be decided first, the rest only have to connect.
func (e *BmmEngine) retryRound(
	ctx context.Context, sidechain pb.BinaryType, round *bmmstate.Round, tip string, tipHeight int32,
) bool {
	if round.Result == ResultOpen {
		live := liveBid(round)
		if live == nil {
			return true
		}
		return e.settleOutrunRound(ctx, sidechain, round, live, tip, tipHeight)
	}
	if !e.connectWon(ctx, sidechain, round) {
		return false
	}
	e.save(round)
	return true
}

// connectWon hands the won block to the sidechain, naming the mainchain block
// that carries the commitment — the sidechain cannot name a block it never saw.
func (e *BmmEngine) connectWon(ctx context.Context, sidechain pb.BinaryType, round *bmmstate.Round) bool {
	live := liveBid(round)
	if live == nil {
		return false
	}
	resp, err := e.backend.ConnectBid(ctx, connect.NewRequest(&bmmpb.ConnectBidRequest{
		Sidechain:     sidechain,
		CriticalHash:  live.CriticalHash,
		BlockJson:     live.BlockJSON,
		MainBlockHash: round.IncludedInBlock,
	}))
	if err != nil {
		e.log.Warn().Err(err).Stringer("sidechain", sidechain).
			Str("critical_hash", live.CriticalHash).Msg("connect won block")
		return false
	}
	if !resp.Msg.Connected {
		e.log.Warn().Stringer("sidechain", sidechain).Str("critical_hash", live.CriticalHash).
			Str("main_block", round.IncludedInBlock).Msg("sidechain refused the won block")
		return false
	}
	live.State = BidConnected
	round.Result = ResultWon
	round.WinnerCriticalHash = live.CriticalHash
	round.WinnerTxid = live.Txid
	round.WinnerBidSats = live.BidSats
	if resp.Msg.MainBlockHash != "" {
		round.IncludedInBlock = resp.Msg.MainBlockHash
	}
	return true
}

func (e *BmmEngine) save(round *bmmstate.Round) {
	if err := e.store.Save(*round); err != nil {
		e.log.Warn().Err(err).Str("round", round.PrevMainHash).Msg("save bmm round")
	}
	e.notify()
}
