package engines

import (
	"context"
	"errors"
	"math"
	"os"
	"path/filepath"
	"sync"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines/bmmstate"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

const testSidechain = pb.BinaryType_BINARY_TYPE_THUNDER

type fakeBackend struct {
	mu sync.Mutex

	disabled          bool
	bids              int
	connects          int
	connected         bool
	noInclusion       bool
	lastMainBlockHash string
	bidErr            error
	prepares          int
	lastPrepare       *bmmpb.PrepareBMMRequest
	prepareErr        error
	splitTxid         string
	shortCoins        bool
	feesSats          int64
	others            []*bmmpb.Bid
	commitment        string
	commitmentByBlock map[string]string
	commitmentErr     error
	blockAfter        string
	blockAfterErr     error
	lastReplace       string
	lastBidSats       int64
	lastExpectTip     string
	lastWalletID      string
	lastFeeRate       float64
}

func (f *fakeBackend) BMMAvailable() bool {
	f.mu.Lock()
	defer f.mu.Unlock()
	return !f.disabled
}

func (f *fakeBackend) CreateBid(
	_ context.Context, req *connect.Request[bmmpb.CreateBidRequest],
) (*connect.Response[bmmpb.CreateBidResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.bidErr != nil {
		return nil, f.bidErr
	}
	f.bids++
	f.lastReplace = req.Msg.ReplaceTxid
	f.lastBidSats = req.Msg.BidSats
	bid := req.Msg.BidSats
	// A rate-sized bid costs whatever the wallet builds. The real handler
	// reads that back off the chain, so the fake reports it too.
	if bid == 0 && req.Msg.FeeRateSatVb > 0 {
		bid = int64(math.Ceil(req.Msg.FeeRateSatVb * fakeBidVsize))
	}
	if req.Msg.CapToBlockWorth && f.feesSats > 0 && bid > f.feesSats {
		bid = f.feesSats
	}
	f.lastBidSats = bid
	f.lastExpectTip = req.Msg.ExpectPrevMainHash
	f.lastWalletID = req.Msg.WalletId
	f.lastFeeRate = req.Msg.FeeRateSatVb
	return connect.NewResponse(&bmmpb.CreateBidResponse{
		CriticalHash: "critical",
		BmmTxid:      "txid-" + string(rune('0'+f.bids)),
		FeesSats:     f.feesSats,
		BlockJson:    "{}",
		PrevMainHash: req.Msg.ExpectPrevMainHash,
		BidSats:      bid,
	}), nil
}

func (f *fakeBackend) ConnectBid(
	_ context.Context, req *connect.Request[bmmpb.ConnectBidRequest],
) (*connect.Response[bmmpb.ConnectBidResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.connects++
	f.lastMainBlockHash = req.Msg.MainBlockHash
	// The handler names no block while the sidechain reports no inclusion for
	// the critical hash.
	if f.noInclusion {
		return connect.NewResponse(&bmmpb.ConnectBidResponse{}), nil
	}
	// The handler echoes the block it connected on, resolving it itself only
	// when the caller named none.
	main := req.Msg.MainBlockHash
	if main == "" {
		main = "mainblock"
	}
	return connect.NewResponse(&bmmpb.ConnectBidResponse{
		Connected:     f.connected,
		MainBlockHash: main,
	}), nil
}

func (f *fakeBackend) ListBids(
	_ context.Context, _ *connect.Request[bmmpb.ListBidsRequest],
) (*connect.Response[bmmpb.ListBidsResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return connect.NewResponse(&bmmpb.ListBidsResponse{Bids: f.others}), nil
}

func (f *fakeBackend) PrepareBMM(
	_ context.Context, req *connect.Request[bmmpb.PrepareBMMRequest],
) (*connect.Response[bmmpb.PrepareBMMResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.prepares++
	f.lastPrepare = req.Msg
	if f.prepareErr != nil {
		return nil, f.prepareErr
	}
	wanted := int32(len(req.Msg.Targets))
	usable := wanted
	if f.shortCoins {
		usable = wanted - 1
	}
	return connect.NewResponse(&bmmpb.PrepareBMMResponse{
		Wallets: []*bmmpb.PrepareBMMWallet{{
			WalletId:    req.Msg.Targets[0].WalletId,
			UsableCoins: usable,
			WantedCoins: wanted,
			SplitTxid:   f.splitTxid,
		}},
	}), nil
}

func (f *fakeBackend) Commitment(_ context.Context, _ pb.BinaryType, main string) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if c, ok := f.commitmentByBlock[main]; ok {
		return c, nil
	}
	return f.commitment, f.commitmentErr
}

func (f *fakeBackend) BlockAfter(_ context.Context, _, _ string) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.blockAfter, f.blockAfterErr
}

// fakeFee stands in for Core's next block estimate.
type fakeFee struct {
	mu    sync.Mutex
	calls int
	rate  float64
	err   error
}

func (f *fakeFee) EstimateFee(context.Context) (float64, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.calls++
	return f.rate, f.err
}

func (f *fakeFee) set(rate float64) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.rate = rate
}

// fakeBidVsize is the size the fake wallet builds a bid at, so a rate turns
// into an amount the assertions below can name.
const fakeBidVsize = 200

// newFakeFee reports a rate every engine test opens at. At fakeBidVsize it
// costs 10 000 sats, which is the opening bid the assertions expect.
func newFakeFee() *fakeFee { return &fakeFee{rate: 50} }

type fakeTip struct {
	mu     sync.Mutex
	calls  int
	hash   string
	height int32
}

func (f *fakeTip) ChainTip(context.Context) (string, int32, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.calls++
	return f.hash, f.height, nil
}

func (f *fakeTip) set(hash string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.hash = hash
	f.height++
}

func (f *fakeTip) jump(hash string, blocks int32) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.hash = hash
	f.height += blocks
}

func newEngine(t *testing.T) (*BmmEngine, *fakeBackend, *fakeTip, *bmmstate.Store) {
	t.Helper()
	backend := &fakeBackend{feesSats: 12500}
	tip := &fakeTip{hash: "block-1", height: 100}
	store := bmmstate.NewStore(t.TempDir(), 0)
	return NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store), backend, tip, store
}

// Stopped is the default: the engine must not spend a satoshi until asked.
func TestBmmEngineIdleUntilStarted(t *testing.T) {
	engine, backend, _, _ := newEngine(t)

	engine.tick(context.Background())

	assert.Zero(t, backend.bids)
	running, _, _ := engine.Running(testSidechain)
	assert.False(t, running)
}

// Only a new tip opens a round, so a repeated tip must not bid again.
func TestBmmEngineOpensOneRoundPerTip(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 20_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	engine.tick(ctx)
	assert.Equal(t, 1, backend.bids, "same tip, one opening bid")

	tip.set("block-2")
	engine.tick(ctx)
	assert.Equal(t, 2, backend.bids, "a new tip is a new round")
}

// Starting a second sidechain must bid on the tip already in play.
func TestBmmEngineBidsForASidechainStartedMidBlock(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	ctx := context.Background()

	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 20_000, false))
	engine.tick(ctx)
	require.Equal(t, 1, backend.bids)

	const other = pb.BinaryType_BINARY_TYPE_BITNAMES
	require.NoError(t, engine.Start(context.Background(), other, "", 20_000, false))
	engine.tick(ctx)

	assert.Equal(t, 2, backend.bids, "the newly started sidechain bids on the current tip")
	assert.NotNil(t, engine.Current(other))
}

// The competitors are only visible while the round is open, so they must be
// captured then and survive into history.
func TestBmmEngineKeepsCompetitorsAfterTheRoundCloses(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	backend.others = []*bmmpb.Bid{{Txid: "rival", CriticalHash: "rival-h", BidSats: 9000}}
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.Len(t, engine.Current(testSidechain).OtherBids, 1)

	backend.others = nil // the losing bid is gone from the mempool
	tip.set("block-2")
	engine.tick(ctx)

	history, err := engine.History(testSidechain)
	require.NoError(t, err)
	require.NotEmpty(t, history)
	require.Len(t, history[len(history)-1].OtherBids, 1, "snapshot outlives the mempool")
	assert.Equal(t, "rival", history[len(history)-1].OtherBids[0].Txid)
}

func TestBmmEngineSettlesAWonRound(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.commitment = "critical"
	backend.connected = true
	tip.set("block-2")
	engine.tick(ctx)

	history, err := engine.History(testSidechain)
	require.NoError(t, err)
	won := history[len(history)-1]
	assert.Equal(t, ResultWon, won.Result)
	assert.Equal(t, "block-2", won.IncludedInBlock)
	assert.Equal(t, int64(10_000), won.WinnerBidSats)
}

// A round nobody took from us is lost, and the winner is named from the
// commitment when we saw that bid.
func TestBmmEngineSettlesALostRound(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	backend.others = []*bmmpb.Bid{{Txid: "rival", CriticalHash: "rival-h", BidSats: 30_000}}
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.commitment = "rival-h"
	tip.set("block-2")
	engine.tick(ctx)

	history, err := engine.History(testSidechain)
	require.NoError(t, err)
	lost := history[len(history)-1]
	assert.Equal(t, ResultLost, lost.Result)
	assert.Equal(t, "rival", lost.WinnerTxid)
	assert.Equal(t, int64(30_000), lost.WinnerBidSats)
}

// Being outbid inside a round raises our bid by replacing it, which is the
// only thing that produces a replaced_by link.
func TestBmmEngineRaisesWhenOutbid(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 50_000
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 30_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.Equal(t, 1, backend.bids)

	backend.others = []*bmmpb.Bid{{Txid: "rival", CriticalHash: "rival-h", BidSats: 12_000}}
	engine.tick(ctx)

	require.Equal(t, 2, backend.bids, "outbid, so we raise")
	assert.Equal(t, int64(13_000), backend.lastBidSats, "just above the rival")
	assert.Equal(t, "txid-1", backend.lastReplace, "the raise replaces our own bid")

	round := engine.Current(testSidechain)
	require.Len(t, round.OurBids, 2)
	assert.Equal(t, BidReplaced, round.OurBids[0].State)
	assert.Equal(t, "txid-2", round.OurBids[0].ReplacedByTxid)
	assert.Equal(t, BidLive, round.OurBids[1].State)
}

// The wallet Start names funds the opening bid and every raise after it.
func TestBmmEngineBidsFromTheNamedWallet(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 50_000
	require.NoError(t, engine.Start(context.Background(), testSidechain, "wallet-b", 30_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.Equal(t, "wallet-b", backend.lastWalletID)

	backend.others = []*bmmpb.Bid{{Txid: "rival", BidSats: 12_000}}
	engine.tick(ctx)

	require.Equal(t, 2, backend.bids)
	assert.Equal(t, "wallet-b", backend.lastWalletID, "a raise spends from the same wallet")

	running, walletID, _ := engine.Running(testSidechain)
	assert.True(t, running)
	assert.Equal(t, "wallet-b", walletID)
}

// A raise respends the live bid's inputs, so switching wallets mid-round must
// not hand those inputs to a wallet that cannot sign them.
func TestBmmEngineRaisesFromTheWalletThatFundedTheBid(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 50_000
	require.NoError(t, engine.Start(context.Background(), testSidechain, "wallet-b", 30_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	require.NoError(t, engine.Start(context.Background(), testSidechain, "wallet-c", 30_000, false))
	backend.others = []*bmmpb.Bid{{Txid: "rival", BidSats: 12_000}}
	engine.tick(ctx)

	require.Equal(t, 2, backend.bids)
	assert.Equal(t, "txid-1", backend.lastReplace)
	assert.Equal(t, "wallet-b", backend.lastWalletID, "the raise stays on the wallet that funded the bid")
}

func TestBmmEngineNeverRaisesAboveMax(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 90_000
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 12_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.others = []*bmmpb.Bid{{Txid: "rival", BidSats: 40_000}}
	engine.tick(ctx)

	assert.Equal(t, 1, backend.bids, "a raise above max is not worth making")
}

// An operator who asks for the cap keeps every bid at or under what the block
// collects.
func TestBmmEngineHoldsTheCapWhenTheOperatorAsks(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 12_500
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 100_000, true))

	ctx := context.Background()
	engine.tick(ctx)

	backend.others = []*bmmpb.Bid{{Txid: "rival", BidSats: 12_000}}
	engine.tick(ctx)

	assert.Equal(t, 1, backend.bids, "13 000 would exceed the 12 500 the block is worth")
}

// A chain whose blocks carry few fees loses every round under the cap. So the
// raise answers the ceiling alone unless the operator asks for the cap.
func TestBmmEngineRaisesPastTheBlockWorth(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 1_000
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 100_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.others = []*bmmpb.Bid{{Txid: "rival", BidSats: 12_000}}
	engine.tick(ctx)

	assert.Equal(t, 2, backend.bids, "the raise beats the rival, over the 1 000 the block is worth")
}

func TestBmmEngineRecordsAFailedBid(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.bidErr = errors.New("no block template")
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	engine.tick(context.Background())

	round := engine.Current(testSidechain)
	require.Len(t, round.OurBids, 1)
	assert.Equal(t, BidFailed, round.OurBids[0].State)
	assert.Contains(t, round.OurBids[0].Error, "no block template")
}

func TestBmmEngineStopEndsBidding(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.Equal(t, 1, backend.bids)

	require.NoError(t, engine.Stop(testSidechain))
	tip.set("block-2")
	engine.tick(ctx)

	assert.Equal(t, 1, backend.bids, "no bids after stop")
	running, _, _ := engine.Running(testSidechain)
	assert.False(t, running)
}

func TestBmmEngineRejectsBadBounds(t *testing.T) {
	engine, _, _, _ := newEngine(t)
	require.Error(t, engine.Start(context.Background(), testSidechain, "", 0, false), "a ceiling of zero bids nothing")
	require.Error(t, engine.Start(context.Background(), testSidechain, "", -1, false), "a negative ceiling is not a bid")
}

// Core names the rate, so a caller that wants a cheaper bid cannot have one.
func TestBmmEngineOpensAtTheNextBlockRate(t *testing.T) {
	engine, _, _, _ := newEngine(t)

	engine.fee.(*fakeFee).set(37.5)
	assert.InDelta(t, 37.5, engine.NextBlockRate(t.Context()), 0.001)
}

// Core answers nothing on a fresh node, and a bid still has to pay something.
func TestBmmEngineOpensAtTheRelayMinimumWithoutAnEstimate(t *testing.T) {
	engine, _, _, _ := newEngine(t)

	engine.fee.(*fakeFee).set(0)
	assert.InDelta(t, relayMinimumRate, engine.NextBlockRate(t.Context()), 0.001)

	engine.fee.(*fakeFee).set(0.2)
	assert.InDelta(t, relayMinimumRate, engine.NextBlockRate(t.Context()), 0.001,
		"a rate under the relay minimum never relays")
}

// The wallet sizes the opening bid, so the engine names a rate and no amount.
// A fixed amount underpays the rate when the wallet builds a larger bid.
func TestBmmEngineOpensByRateNotByAmount(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	engine.fee.(*fakeFee).set(42)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 100_000, false))
	tip.set("main-1")

	engine.tick(context.Background())

	backend.mu.Lock()
	defer backend.mu.Unlock()
	assert.InDelta(t, 42, backend.lastFeeRate, 0.001)
}

// The sidechain never saw the block it just won, so it cannot look up which
// mainchain block carried the commitment. We must name that block.
func TestBmmEngineNamesTheMainBlockOnConnect(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.commitment = "critical"
	backend.connected = true
	tip.set("block-2")
	engine.tick(ctx)

	assert.Equal(t, "block-2", backend.lastMainBlockHash)
}

// A sleeping laptop can leave the tip several blocks past the round. The block
// that decided it still holds our commitment, so the round is a win and must
// connect on that block, not on the tip.
func TestBmmEngineWinsARoundTheTipOutran(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.blockAfter = "block-2"
	backend.commitmentByBlock = map[string]string{"block-2": "critical", "block-5": "someone-else"}
	backend.connected = true
	tip.jump("block-5", 4)
	engine.tick(ctx)

	history := mustHistory(t, engine)
	require.NotEmpty(t, history)
	won := history[len(history)-1]
	assert.Equal(t, ResultWon, won.Result)
	assert.Equal(t, "block-2", won.IncludedInBlock)
	assert.Equal(t, "block-2", backend.lastMainBlockHash)
}

// With no way to name the deciding block, the paid round is held for retry and
// written down, so a restart can still resume it.
func TestBmmEngineHoldsAnUndecidableRound(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.blockAfter = ""
	backend.commitment = "someone-else"
	tip.jump("block-5", 4)
	engine.tick(ctx)

	history := mustHistory(t, engine)
	require.NotEmpty(t, history, "a paid round survives a restart")
	for _, r := range history {
		assert.NotEqual(t, ResultLost, r.Result, "a round we cannot decide is not a loss")
	}
}

// A round parked by a failed lookup must be decided on the block that carried
// the bid, not connected blind on whatever the tip is by then.
func TestBmmEngineDecidesAParkedRoundOnRetry(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.blockAfterErr = errors.New("enforcer down")
	tip.jump("block-5", 4)
	engine.tick(ctx)

	backend.blockAfterErr = nil
	backend.blockAfter = "block-2"
	backend.commitmentByBlock = map[string]string{"block-2": "critical"}
	backend.connected = true
	engine.retryConnects(ctx, testSidechain, tip.hash, tip.height)

	assert.Equal(t, ResultWon, roundOn(t, engine, "block-1").Result)
	assert.Equal(t, "block-2", backend.lastMainBlockHash)
}

// Running out of retries proves nothing about who won, so an undecidable round
// must never be written down as a loss.
func TestBmmEngineNeverCallsAnUndecidableRoundLost(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.blockAfterErr = errors.New("enforcer down")
	tip.jump("block-5", 4)
	engine.tick(ctx)

	for range bmmConnectAttempts + 1 {
		engine.retryConnects(ctx, testSidechain, tip.hash, tip.height)
	}

	history := mustHistory(t, engine)
	require.NotEmpty(t, history)
	assert.Equal(t, ResultOpen, history[0].Result, "an undecided round stays open")
}

// History is on disk, so a restart keeps what past rounds cost and earned.
func TestBmmEngineHistorySurvivesRestart(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	backend.commitment = "critical"
	backend.connected = true
	tip.set("block-2")
	engine.tick(ctx)

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
	history, err := restarted.History(testSidechain)
	require.NoError(t, err)
	require.NotEmpty(t, history)
	assert.Equal(t, ResultWon, history[len(history)-1].Result)

	running, _, _ := restarted.Running(testSidechain)
	assert.False(t, running, "a fresh engine bids for nothing until it runs")
}

// The operator starts bidding once. A restart must carry on, or the chain
// stalls until somebody notices and starts it by hand.
func TestBmmEngineResumesItsTargetAfterRestart(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "spender", 10_000, true))

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
	running, _, _ := restarted.Running(testSidechain)
	require.False(t, running, "the target loads when the engine runs")

	restarted.resumeTargets()
	running, wallet, max := restarted.Running(testSidechain)
	assert.True(t, running)
	assert.Equal(t, "spender", wallet)
	assert.Equal(t, int64(10_000), max)

	restarted.tick(context.Background())
	assert.Positive(t, backend.bids, "a resumed target bids on the next tip")
}

// Stop is a decision, so it must outlive the process too.
func TestBmmEngineForgetsAStoppedTargetAfterRestart(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))
	require.NoError(t, engine.Stop(testSidechain))

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
	restarted.resumeTargets()

	running, _, _ := restarted.Running(testSidechain)
	assert.False(t, running)
	restarted.tick(context.Background())
	assert.Zero(t, backend.bids, "a stopped engine spends nothing")
}

func TestBmmEngineClearHistory(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	backend.commitment = "critical"
	backend.connected = true
	tip.set("block-2")
	engine.tick(ctx)
	require.NotEmpty(t, mustHistory(t, engine))

	require.NoError(t, engine.ClearHistory(testSidechain))
	// Clearing takes the settled rounds. The round in play is not history.
	for _, round := range mustHistory(t, engine) {
		assert.Equal(t, ResultOpen, round.Result, "a settled round is gone")
	}
}

func mustHistory(t *testing.T, engine *BmmEngine) []bmmstate.Round {
	t.Helper()
	history, err := engine.History(testSidechain)
	require.NoError(t, err)
	return history
}

// A miner took the block and the fee is already paid, so a restart must pick
// the connect back up rather than forfeit it.
func TestBmmEngineResumesAWonBlockThatNeverConnected(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	// The miner committed to our block, but the sidechain has not seen the
	// inclusion yet.
	backend.commitment = "critical"
	backend.noInclusion = true
	tip.set("block-2")
	engine.tick(ctx)

	history := mustHistory(t, engine)
	require.NotEmpty(t, history)
	require.Equal(t, ResultWon, history[len(history)-1].Result)

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
	restarted.resumeUnconnected()

	backend.noInclusion = false
	backend.connected = true
	before := backend.connects
	restarted.retryConnects(ctx, testSidechain, tip.hash, tip.height)

	assert.Greater(t, backend.connects, before, "the won block is retried after a restart")
}

func TestBmmEngineRecordsBlockHeights(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	assert.Equal(t, int32(100), engine.Current(testSidechain).PrevMainHeight)

	backend.connected = true
	tip.set("block-2")
	engine.tick(ctx)

	history := mustHistory(t, engine)
	settled := history[len(history)-1]
	assert.Equal(t, int32(100), settled.PrevMainHeight, "the tip the bids were built on")
	assert.Equal(t, int32(101), settled.IncludedInHeight, "the block that decided the round")
}

// The mempool keeps bids from earlier rounds. They can never win the current
// one, so raising against them would spend for nothing.
func TestBmmEngineIgnoresBidsFromAnotherRound(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 90_000
	backend.others = []*bmmpb.Bid{
		{Txid: "stale", CriticalHash: "stale-h", BidSats: 80_000, PrevMainHash: "block-0"},
	}
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 50_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	engine.tick(ctx)

	assert.Equal(t, 1, backend.bids, "a bid for a dead round is not competition")
	assert.Empty(t, engine.Current(testSidechain).OtherBids)
}

// Bidding is pinned to the tip the round opened on, so a sidechain that has
// not caught up cannot spend on an already-dead round.
func TestBmmEngineNamesTheTipItExpects(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	engine.tick(context.Background())

	assert.Equal(t, "block-1", backend.lastExpectTip)
}

// The cap holds an opening bid at what the block collects, when the operator
// asks for it.
func TestBmmEngineCapsTheOpeningBidToBlockWorth(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 8_000
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, true))

	engine.tick(context.Background())

	assert.Equal(t, int64(8_000), backend.lastBidSats)
	assert.Equal(t, int64(8_000), engine.Current(testSidechain).OurBids[0].BidSats)
}

// With no cap the opening bid answers the ceiling, whatever the block collects.
func TestBmmEngineOpensAtTheCeilingWithNoCap(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 8_000
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	engine.tick(context.Background())

	assert.Equal(t, int64(10_000), backend.lastBidSats)
}

// Stop ends bidding, but a bid already broadcast still has to settle.
func TestBmmEngineSettlesAfterStop(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.NotNil(t, engine.Current(testSidechain))

	require.NoError(t, engine.Stop(testSidechain))
	backend.commitment = "critical"
	backend.connected = true
	tip.set("block-2")
	engine.tick(ctx)

	history := mustHistory(t, engine)
	require.NotEmpty(t, history, "the outstanding bid still settles")
	assert.Equal(t, ResultWon, history[len(history)-1].Result)
}

// Restarting must not re-open a round already in play and double-bid it.
func TestBmmEngineRestartDoesNotDoubleBidTheSameRound(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.Equal(t, 1, backend.bids)

	require.NoError(t, engine.Stop(testSidechain))
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))
	engine.tick(ctx)

	assert.Equal(t, 1, backend.bids, "same tip, still one bid")
}

// Not knowing the winner is not the same as losing: declaring a loss would
// stop us connecting a block we may already have paid for.
func TestBmmEngineKeepsRoundPendingWhenTheCommitmentCannotBeRead(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.commitmentErr = errors.New("enforcer down")
	tip.set("block-2")
	engine.tick(ctx)

	history := mustHistory(t, engine)
	for _, r := range history {
		assert.NotEqual(t, ResultLost, r.Result, "an unreadable commitment is not a loss")
	}

	backend.commitmentErr = nil
	backend.commitment = "critical"
	backend.connected = true
	engine.retryConnects(ctx, testSidechain, tip.hash, tip.height)

	assert.Equal(t, ResultWon, roundOn(t, engine, "block-1").Result, "the retry settles it as won")
}

// Readers must never share the slices the engine keeps mutating.
func TestBmmEngineCurrentIsADeepCopy(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.others = []*bmmpb.Bid{{Txid: "rival", BidSats: 5_000, PrevMainHash: "block-1"}}
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	engine.tick(context.Background())

	snapshot := engine.Current(testSidechain)
	require.NotEmpty(t, snapshot.OurBids)
	snapshot.OurBids[0].State = "tampered"

	assert.Equal(t, BidLive, engine.Current(testSidechain).OurBids[0].State)
}

// roundOn finds the stored round for one tip. An open round is on disk beside
// the settled ones, so a test names the round it means.
func roundOn(t *testing.T, engine *BmmEngine, tip string) bmmstate.Round {
	t.Helper()
	for _, round := range mustHistory(t, engine) {
		if round.PrevMainHash == tip {
			return round
		}
	}
	t.Fatalf("no round on %s", tip)
	return bmmstate.Round{}
}

// Stopping does not decide a round that is still open: until the tip moves,
// the bid we already broadcast can still win.
func TestBmmEngineDoesNotSettleAnOpenRoundOnStop(t *testing.T) {
	engine, _, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.NoError(t, engine.Stop(testSidechain))

	engine.tick(ctx)
	assert.NotNil(t, engine.Current(testSidechain), "same tip, the round is still live")
	assert.Equal(t, ResultOpen, roundOn(t, engine, "block-1").Result, "stopping decides nothing")

	tip.set("block-2")
	engine.tick(ctx)
	assert.Nil(t, engine.Current(testSidechain))
	assert.NotEmpty(t, mustHistory(t, engine), "the tip moved, so now it settles")
}

// The sync gate the backend applies reads a snapshot that can trail the tip the
// engine just read. Skipping the block for good over a one-poll skew would cost
// a round every time the enforcer catches up mid-tick.
func TestBmmEngineRetriesAfterAPreconditionRefusal(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.bidErr = connect.NewError(connect.CodeFailedPrecondition, errors.New("enforcer is still syncing"))
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	assert.Nil(t, engine.Current(testSidechain), "a refused opening bid leaves no round behind")

	backend.mu.Lock()
	backend.bidErr = nil
	backend.mu.Unlock()

	engine.tick(ctx)
	assert.Equal(t, 1, backend.bids, "the same tip must be retried once the gate opens")
	require.NotNil(t, engine.Current(testSidechain))
}

// Any other failure keeps the round on the books, so a real error stays visible
// instead of being retried forever in silence.
func TestBmmEngineDoesNotRetryOtherFailures(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.bidErr = errors.New("no block template")
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.NotNil(t, engine.Current(testSidechain))

	backend.mu.Lock()
	backend.bidErr = nil
	backend.mu.Unlock()

	engine.tick(ctx)
	assert.Zero(t, backend.bids, "same tip, already handled")
}

// A bid stranded on an old parent can never be mined, and a later bid that
// spends its change inherits that. The next opening bid must replace it.
func TestBmmEngineReplacesAStrandedBid(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 20_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.Equal(t, 1, backend.bids)
	require.Empty(t, backend.lastReplace, "the first bid has nothing to replace")

	// The first bid stays in the mempool while the chain moves past its parent.
	backend.mu.Lock()
	backend.others = []*bmmpb.Bid{{Txid: "txid-1", PrevMainHash: "block-1"}}
	backend.mu.Unlock()

	tip.set("block-2")
	engine.tick(ctx)

	assert.Equal(t, 2, backend.bids)
	assert.Equal(t, "txid-1", backend.lastReplace, "the opening bid respends the stranded bid")
}

// Replacing needs the wallet that funded the stranded bid, because only it can
// sign those inputs. This holds for a core wallet and an electrum wallet alike.
func TestBmmEngineReplacesWithTheFundingWallet(t *testing.T) {
	for _, walletID := range []string{"core-wallet", "electrum-wallet"} {
		t.Run(walletID, func(t *testing.T) {
			engine, backend, tip, _ := newEngine(t)
			require.NoError(t, engine.Start(context.Background(), testSidechain, walletID, 20_000, false))

			ctx := context.Background()
			engine.tick(ctx)
			require.Equal(t, walletID, backend.lastWalletID)

			backend.mu.Lock()
			backend.others = []*bmmpb.Bid{{Txid: "txid-1", PrevMainHash: "block-1"}}
			backend.mu.Unlock()

			tip.set("block-2")
			engine.tick(ctx)

			assert.Equal(t, "txid-1", backend.lastReplace)
			assert.Equal(t, walletID, backend.lastWalletID, "the funding wallet signs the replacement")
		})
	}
}

// A bid the miner took leaves the mempool, so the next round must open freely
// rather than respend inputs that are already gone.
func TestBmmEngineOpensFreelyWhenNoBidIsStranded(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 20_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.Equal(t, 1, backend.bids)

	// The mempool holds none of our bids.
	tip.set("block-2")
	engine.tick(ctx)

	assert.Equal(t, 2, backend.bids)
	assert.Empty(t, backend.lastReplace)
}

// The store must say what happened to a stranded bid, so the history does not
// leave it looking live.
func TestBmmEngineRecordsAStrandedBidAsReplaced(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 20_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.mu.Lock()
	backend.others = []*bmmpb.Bid{{Txid: "txid-1", PrevMainHash: "block-1"}}
	backend.mu.Unlock()

	tip.set("block-2")
	engine.tick(ctx)

	rounds, err := store.List(int32(testSidechain))
	require.NoError(t, err)

	var found bool
	for _, round := range rounds {
		for _, bid := range round.OurBids {
			if bid.Txid == "txid-1" {
				found = true
				assert.Equal(t, BidReplaced, bid.State)
				assert.Equal(t, "txid-2", bid.ReplacedByTxid)
			}
		}
	}
	assert.True(t, found, "the stranded bid stays in the history")
}

// The deploy case: a new build inherits a mempool full of stranded bids and no
// round in memory. It must still find the oldest one on disk and replace it,
// which evicts every bid chained to it.
func TestBmmEngineReplacesAStrandedBidAfterRestart(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "core-wallet", 20_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	tip.set("block-2")
	engine.tick(ctx)
	tip.set("block-3")
	engine.tick(ctx)
	require.Equal(t, 3, backend.bids)

	// Every bid is still in the mempool, each one chained to the one before.
	backend.mu.Lock()
	backend.others = []*bmmpb.Bid{
		{Txid: "txid-1", PrevMainHash: "block-1"},
		{Txid: "txid-2", PrevMainHash: "block-2"},
		{Txid: "txid-3", PrevMainHash: "block-3"},
	}
	backend.lastReplace = ""
	backend.mu.Unlock()

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
	require.NoError(t, restarted.Start(context.Background(), testSidechain, "core-wallet", 20_000, false))

	tip.set("block-4")
	restarted.tick(ctx)

	assert.Equal(t, "txid-1", backend.lastReplace,
		"the oldest stranded bid is the root of the chain, so replacing it evicts them all")
	assert.Equal(t, "core-wallet", backend.lastWalletID)
}

// A won block the chain left far behind can never connect, because its header
// names one mainchain block. Retrying it submits through the sidechain's
// network task, which then stops answering its peers.
func TestBmmEngineAbandonsAWonBlockBehindTheTip(t *testing.T) {
	engine, backend, _, store := newEngine(t)

	round := &bmmstate.Round{
		Sidechain:        int32(testSidechain),
		PrevMainHash:     "old-round",
		PrevMainHeight:   996693,
		IncludedInHeight: 996694,
		Result:           ResultWon,
		OurBids: []bmmstate.Bid{{
			Txid: "won-txid", CriticalHash: "critical", IsOurs: true, State: BidLive,
		}},
	}
	engine.mu.Lock()
	engine.unconnected[testSidechain] = []*bmmstate.Round{round}
	engine.mu.Unlock()

	// The tip has moved 79 blocks past the block that decided the round.
	engine.retryConnects(context.Background(), testSidechain, "tip", 996773)

	assert.Zero(t, backend.connects, "a block this far behind must not be submitted")

	engine.mu.Lock()
	left := len(engine.unconnected[testSidechain])
	engine.mu.Unlock()
	assert.Zero(t, left, "the round leaves the retry list")

	// A restart must not resume it, or it gets a fresh attempt budget and the
	// node starves again.
	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, &fakeTip{}, newFakeFee(), store)
	restarted.mu.Lock()
	resumed := len(restarted.unconnected[testSidechain])
	restarted.mu.Unlock()
	assert.Zero(t, resumed, "a restart leaves the abandoned round alone")
}

// A won block within the horizon is still worth retrying: the fee is paid.
func TestBmmEngineKeepsRetryingARecentWonBlock(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.noInclusion = true

	round := unconnectedRound("recent-round", 996770)
	engine.mu.Lock()
	engine.unconnected[testSidechain] = []*bmmstate.Round{round}
	engine.mu.Unlock()

	engine.retryConnects(context.Background(), testSidechain, "tip", 996773)

	assert.Positive(t, backend.connects, "a recent won block is still submitted")
	assert.Equal(t, 1, pendingCount(engine), "the round waits for the next pass")
}

// The sidechain judged the block and said no. The next attempt sends the same
// bytes, so the round is over.
func TestBmmEngineRetiresARefusedBlock(t *testing.T) {
	engine, backend, _, store := newEngine(t)
	backend.connected = false

	round := unconnectedRound("refused-round", 996770)
	engine.mu.Lock()
	engine.unconnected[testSidechain] = []*bmmstate.Round{round}
	engine.mu.Unlock()

	ctx := context.Background()
	engine.retryConnects(ctx, testSidechain, "tip", 996773)

	assert.Equal(t, 1, backend.connects, "the refused block is offered once")
	assert.Zero(t, pendingCount(engine), "the round leaves the retry list")
	require.Len(t, round.OurBids, 1)
	assert.Equal(t, BidFailed, round.OurBids[0].State)
	assert.Equal(t, reasonRefused, round.OurBids[0].Error)

	engine.retryConnects(ctx, testSidechain, "tip", 996774)
	assert.Equal(t, 1, backend.connects, "a retired round is never offered again")

	// A restart must not resume it, or the refusal starts over.
	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, &fakeTip{}, newFakeFee(), store)
	restarted.resumeUnconnected()
	assert.Zero(t, pendingCount(restarted), "a restart leaves the retired round alone")
}

// A sidechain that has not seen the bid included names no block. The mainchain
// block that carries it may still reach the sidechain, so the round waits.
func TestBmmEngineRetriesABlockTheSidechainHasNotSeen(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.noInclusion = true

	round := unconnectedRound("unseen-round", 996770)
	engine.mu.Lock()
	engine.unconnected[testSidechain] = []*bmmstate.Round{round}
	engine.mu.Unlock()

	ctx := context.Background()
	engine.retryConnects(ctx, testSidechain, "tip", 996773)
	engine.retryConnects(ctx, testSidechain, "tip", 996773)

	assert.Equal(t, 2, backend.connects, "the block goes back to the sidechain")
	assert.Equal(t, 1, pendingCount(engine), "the round stays on the retry list")
	assert.Equal(t, BidLive, round.OurBids[0].State)

	backend.noInclusion = false
	backend.connected = true
	engine.retryConnects(ctx, testSidechain, "tip", 996773)

	assert.Zero(t, pendingCount(engine), "the connected round leaves the list")
	assert.Equal(t, BidConnected, round.OurBids[0].State)
}

// A refusal shape the engine cannot name must still end. The attempt bound
// retires the round, so it never loops without end.
func TestBmmEngineBoundsARepeatedRefusal(t *testing.T) {
	engine, backend, _, store := newEngine(t)
	backend.noInclusion = true

	round := unconnectedRound("bounded-round", 996770)
	engine.mu.Lock()
	engine.unconnected[testSidechain] = []*bmmstate.Round{round}
	engine.mu.Unlock()

	ctx := context.Background()
	for range bmmConnectAttempts {
		engine.retryConnects(ctx, testSidechain, "tip", 996773)
	}

	assert.Equal(t, bmmConnectAttempts, backend.connects)
	assert.Zero(t, pendingCount(engine), "the bound takes the round off the list")
	assert.Equal(t, BidFailed, round.OurBids[0].State)
	assert.Equal(t, reasonNoAnswer, round.OurBids[0].Error)

	engine.retryConnects(ctx, testSidechain, "tip", 996773)
	assert.Equal(t, bmmConnectAttempts, backend.connects, "the bound holds")

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, &fakeTip{}, newFakeFee(), store)
	restarted.resumeUnconnected()
	assert.Zero(t, pendingCount(restarted), "a restart hands it no fresh budget")
}

// A round that spends its attempts before anything can decide it must still
// get the whole bound for the connect, or one wait forfeits a paid block.
func TestBmmEngineGivesAWonRoundAFreshBudget(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)

	backend.blockAfterErr = errors.New("enforcer down")
	tip.jump("block-5", 4)
	engine.tick(ctx)

	for range bmmConnectAttempts - 1 {
		engine.retryConnects(ctx, testSidechain, tip.hash, tip.height)
	}

	backend.blockAfterErr = nil
	backend.blockAfter = "block-2"
	backend.commitmentByBlock = map[string]string{"block-2": "critical"}
	backend.noInclusion = true
	engine.retryConnects(ctx, testSidechain, tip.hash, tip.height)

	won := roundOn(t, engine, "block-1")
	require.Equal(t, ResultWon, won.Result)
	assert.Equal(t, 1, won.BlocksWaited, "the connect counts from one")
	assert.Equal(t, BidLive, won.OurBids[0].State, "the paid bid is not forfeited")
	assert.Equal(t, 1, pendingCount(engine), "the won round waits for the sidechain")
}

// The bound only binds if it survives a restart, so a reloaded round carries
// the attempts it already spent.
func TestBmmEngineKeepsTheAttemptCountAcrossARestart(t *testing.T) {
	engine, backend, _, store := newEngine(t)
	backend.noInclusion = true

	round := unconnectedRound("counted-round", 996770)
	engine.mu.Lock()
	engine.unconnected[testSidechain] = []*bmmstate.Round{round}
	engine.mu.Unlock()

	ctx := context.Background()
	for range 3 {
		engine.retryConnects(ctx, testSidechain, "tip", 996773)
	}

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, &fakeTip{}, newFakeFee(), store)
	restarted.resumeUnconnected()
	restarted.mu.Lock()
	resumed := restarted.unconnected[testSidechain]
	restarted.mu.Unlock()
	require.Len(t, resumed, 1)
	assert.Equal(t, 3, resumed[0].BlocksWaited, "the restart carries the spent attempts")

	for range bmmConnectAttempts - 3 {
		restarted.retryConnects(ctx, testSidechain, "tip", 996773)
	}

	assert.Zero(t, pendingCount(restarted), "the bound binds after a restart")
}

// unconnectedRound is a round a miner took, waiting on the sidechain.
func unconnectedRound(prevMainHash string, prevMainHeight int32) *bmmstate.Round {
	return &bmmstate.Round{
		Sidechain:        int32(testSidechain),
		PrevMainHash:     prevMainHash,
		PrevMainHeight:   prevMainHeight,
		IncludedInBlock:  "main-block",
		IncludedInHeight: prevMainHeight + 1,
		Result:           ResultWon,
		OurBids: []bmmstate.Bid{{
			Txid: "won-txid", CriticalHash: "critical", IsOurs: true, State: BidLive,
		}},
	}
}

func pendingCount(engine *BmmEngine) int {
	engine.mu.Lock()
	defer engine.mu.Unlock()
	return len(engine.unconnected[testSidechain])
}

// A restart before the tip moves finds the round still in play. Bidding again
// on that tip pays twice, and the engine then raises against its own bid.
func TestBmmEngineResumesWithoutBiddingTwiceOnTheSameTip(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.Equal(t, 1, backend.bids, "the first tick opens the round")

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
	restarted.resumeTargets()
	restarted.tick(ctx)

	assert.Equal(t, 1, backend.bids, "the same tip is the same round")

	tip.set("block-2")
	restarted.tick(ctx)
	assert.Equal(t, 2, backend.bids, "a new tip is a new round")
}

// A raise carries its own critical hash. A restart that reloads the old one
// reads the block it paid for as lost.
func TestBmmEngineSavesARaise(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	backend.feesSats = 50_000
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 30_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	backend.others = []*bmmpb.Bid{{Txid: "rival", CriticalHash: "rival-h", BidSats: 12_000}}
	engine.tick(ctx)
	require.Equal(t, 2, backend.bids, "outbid, so we raise")

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
	round := roundOn(t, restarted, "block-1")
	live := liveBid(&round)
	require.NotNil(t, live, "the raise reaches the disk with its own bid")
	assert.Equal(t, "txid-2", live.Txid, "the stored bid is the replacement, not the first one")
}

// The round in play has no deciding block yet. Retrying it every tick spends
// the whole budget before the tip moves, and the engine forgets a paid block.
func TestBmmEngineResumesTheLiveRoundAsCurrent(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))
	engine.tick(context.Background())

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
	restarted.resumeTargets()
	restarted.resumeUnconnected()

	current := restarted.Current(testSidechain)
	require.NotNil(t, current, "the round in play comes back as current")
	assert.Equal(t, "block-1", current.PrevMainHash)
	assert.Empty(t, restarted.unconnected[testSidechain], "it never enters the retry queue")
}

// Clear history is for history. Wiping the round in play would leave a restart
// with no tip, and its next tick would bid a second time on the same parent.
func TestBmmEngineKeepsTheLiveRoundThroughClearHistory(t *testing.T) {
	engine, backend, tip, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	tip.set("block-2")
	engine.tick(ctx)
	require.Equal(t, 2, backend.bids)

	require.NoError(t, engine.ClearHistory(testSidechain))

	history := mustHistory(t, engine)
	require.Len(t, history, 1, "only the round in play survives")
	assert.Equal(t, "block-2", history[0].PrevMainHash)

	restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
	restarted.resumeTargets()
	restarted.tick(ctx)
	assert.Equal(t, 2, backend.bids, "the same tip is the same round")
}

// A second Start only changes the wallet or the ceiling. A failed write must
// not stop the bidding the operator already asked for.
func TestBmmEngineKeepsBiddingWhenAnUpdateCannotBeSaved(t *testing.T) {
	engine, backend, _, store := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "first", 10_000, false))

	// A directory that does not exist makes every later write fail.
	store.Rebind(filepath.Join(t.TempDir(), "gone"))
	require.Error(t, engine.Start(context.Background(), testSidechain, "second", 20_000, false))

	running, wallet, maxBid := engine.Running(testSidechain)
	assert.True(t, running, "an update that cannot be saved leaves the old target bidding")
	assert.Equal(t, "first", wallet)
	assert.Equal(t, int64(10_000), maxBid)

	engine.tick(context.Background())
	assert.Positive(t, backend.bids)
}

// Stop answers, and a tick already in flight must not pay for another bid.
// The target leaves memory before the disk write, so no window stays open.
func TestBmmEngineStopsBeforeTheDiskWrite(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "", 10_000, false))

	ctx := context.Background()
	engine.tick(ctx)
	require.Equal(t, 1, backend.bids)

	require.NoError(t, engine.Stop(testSidechain))
	running, _, _ := engine.Running(testSidechain)
	require.False(t, running)

	tip.set("block-2")
	engine.tick(ctx)
	assert.Equal(t, 1, backend.bids, "a stopped engine spends nothing")
}

// A failed delete leaves the target bidding rather than half stopped.
func TestBmmEngineKeepsBiddingWhenAStopCannotBeSaved(t *testing.T) {
	engine, _, _, store := newEngine(t)
	dir := t.TempDir()
	store.Rebind(dir)
	require.NoError(t, engine.Start(context.Background(), testSidechain, "spender", 10_000, false))

	// The target is on disk and in the store's cache. Taking the directory
	// away makes the delete fail on its write.
	require.NoError(t, os.RemoveAll(dir))
	require.Error(t, engine.Stop(testSidechain))

	running, wallet, _ := engine.Running(testSidechain)
	assert.True(t, running, "the stop never reached the disk, so nothing changed")
	assert.Equal(t, "spender", wallet)
}

// The wallet must hold one bid coin per sidechain before the round opens, so a
// new sidechain gets its coin at once rather than after the next block.
func TestBmmEngineStartPreparesTheCoins(t *testing.T) {
	engine, backend, _, _ := newEngine(t)

	require.NoError(t, engine.Start(context.Background(), testSidechain, "spender", 20_000, false))

	assert.Equal(t, 1, backend.prepares)
	require.NotNil(t, backend.lastPrepare)
	require.Len(t, backend.lastPrepare.Targets, 1)
	assert.Equal(t, "spender", backend.lastPrepare.Targets[0].WalletId)
	assert.Equal(t, int64(20_000), backend.lastPrepare.Targets[0].MaxBidSats)
}

// The coin count can fall at any time, so the engine counts again on every new
// tip. A count on every tick would scan the wallet 30 times a minute.
func TestBmmEnginePreparesTheCoinsOncePerTip(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	ctx := context.Background()
	require.NoError(t, engine.Start(ctx, testSidechain, "", 20_000, false))
	backend.prepares = 0

	engine.tick(ctx)
	engine.tick(ctx)
	assert.Equal(t, 1, backend.prepares, "the same tip counts once")

	tip.set("block-2")
	engine.tick(ctx)
	assert.Equal(t, 2, backend.prepares, "a new tip counts again")
}

// Every sidechain that bids names its wallet and its ceiling, so the handler
// can join the targets that spend one wallet.
func TestBmmEngineNamesEverySidechainThatBids(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	ctx := context.Background()

	require.NoError(t, engine.Start(ctx, testSidechain, "shared", 20_000, false))
	require.NoError(t, engine.Start(ctx, pb.BinaryType_BINARY_TYPE_BITNAMES, "shared", 45_000, false))

	require.NotNil(t, backend.lastPrepare)
	require.Len(t, backend.lastPrepare.Targets, 2)
	ceilings := lo.Map(backend.lastPrepare.Targets, func(t *bmmpb.PrepareBMMTarget, _ int) int64 {
		return t.MaxBidSats
	})
	assert.ElementsMatch(t, []int64{20_000, 45_000}, ceilings)
}

// A stopped engine spends nothing, so it must not scan the wallet either.
func TestBmmEngineNeverPreparesWithoutATarget(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	ctx := context.Background()

	engine.tick(ctx)
	tip.set("block-2")
	engine.tick(ctx)

	assert.Zero(t, backend.prepares)
}

// A wallet the backend cannot prepare still bids: every round that finds no
// coin of its own says so on the round.
func TestBmmEngineKeepsBiddingWhenPrepareFails(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.prepareErr = errors.New("core is unreachable")
	ctx := context.Background()

	require.NoError(t, engine.Start(ctx, testSidechain, "", 20_000, false))
	engine.tick(ctx)

	assert.Equal(t, 1, backend.bids)
}

// A backend that fails one count must not cost the sidechains the whole block.
// The engine counts again on the same tip, a bounded number of times.
func TestBmmEngineRetriesAFailedPrepareOnTheSameTip(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.prepareErr = errors.New("core is unreachable")
	ctx := context.Background()
	require.NoError(t, engine.Start(ctx, testSidechain, "", 20_000, false))
	require.Equal(t, 1, backend.prepares, "the start counts once")

	engine.tick(ctx)
	assert.Equal(t, 2, backend.prepares, "a failed count runs again on the same tip")

	for range 5 {
		engine.tick(ctx)
	}
	assert.Equal(t, 1+bmmPrepareTries, backend.prepares,
		"the start counts once, and the tip pays for a bounded number more")

	backend.mu.Lock()
	backend.prepareErr = nil
	backend.mu.Unlock()
	engine.tick(ctx)
	assert.Equal(t, 1+bmmPrepareTries, backend.prepares, "the tip spent its counts")
}

// A split the mempool drops leaves the wallet short again. The tip counts once
// more rather than waiting for the next block.
func TestBmmEngineCountsAgainWhileTheWalletIsShort(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.shortCoins = true
	ctx := context.Background()

	require.NoError(t, engine.Start(ctx, testSidechain, "", 20_000, false))
	require.Equal(t, 1, backend.prepares, "the start counts once")

	engine.tick(ctx)
	assert.Equal(t, 2, backend.prepares, "a wallet short of coins counts again")
}

// A sidechain that starts mid-block gets its coin count, even when the tip
// already spent its counts on the sidechains that bid before it.
func TestBmmEngineStartGivesTheTipItsCountsBack(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	ctx := context.Background()
	require.NoError(t, engine.Start(ctx, testSidechain, "", 20_000, false))
	engine.tick(ctx)
	before := backend.prepares

	require.NoError(t, engine.Start(ctx, pb.BinaryType_BINARY_TYPE_BITNAMES, "", 20_000, false))
	assert.Equal(t, before+1, backend.prepares, "the new sidechain counts at once")

	backend.mu.Lock()
	backend.prepareErr = errors.New("core is unreachable")
	backend.mu.Unlock()
	engine.tick(ctx)
	assert.Equal(t, before+2, backend.prepares, "the tip counts again after the start")
}
