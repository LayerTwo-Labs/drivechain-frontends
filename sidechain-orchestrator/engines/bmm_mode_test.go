package engines

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
)

// A backend with no mempool read still opens a bid and connects the block it
// wins. Only the raise and the rival list depend on the mempool.
func TestBmmEngineBidsWithNoMempoolRead(t *testing.T) {
	engine, backend, tip, _ := newEngine(t)
	backend.noMempool = true
	backend.feesSats = 50_000
	backend.connected = true
	ctx := context.Background()
	require.NoError(t, engine.Start(ctx, testSidechain, "wallet", 30_000, false))

	engine.tick(ctx)
	require.Equal(t, 1, backend.bids, "the opening bid goes out")

	backend.commitment = "critical"
	tip.set("block-2")
	engine.tick(ctx)

	require.Equal(t, 1, backend.connects, "the won block connects")
	assert.Equal(t, BidConnected, roundOn(t, engine, "block-1").OurBids[0].State)
}

// A rival never reaches a backend with no mempool read, so it never raises.
func TestBmmEngineNeverRaisesWithNoMempoolRead(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.noMempool = true
	backend.feesSats = 50_000
	ctx := context.Background()
	require.NoError(t, engine.Start(ctx, testSidechain, "", 30_000, false))

	engine.tick(ctx)
	require.Equal(t, 1, backend.bids)

	backend.others = []*bmmpb.Bid{{Txid: "rival", CriticalHash: "rival-h", BidSats: 12_000}}
	engine.tick(ctx)

	assert.Equal(t, 1, backend.bids, "the bid stands at its opening price")
	round := engine.Current(testSidechain)
	require.Len(t, round.OurBids, 1)
	assert.Equal(t, BidLive, round.OurBids[0].State)
	assert.Empty(t, round.OtherBids, "an unread mempool names no rival")
}

// The same backend with a mempool read raises against that rival.
func TestBmmEngineRaisesWithAMempoolRead(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.feesSats = 50_000
	ctx := context.Background()
	require.NoError(t, engine.Start(ctx, testSidechain, "", 30_000, false))

	engine.tick(ctx)
	backend.others = []*bmmpb.Bid{{Txid: "rival", CriticalHash: "rival-h", BidSats: 12_000}}
	engine.tick(ctx)

	require.Equal(t, 2, backend.bids, "outbid, so we raise")
	assert.Equal(t, int64(13_000), backend.lastBidSats)
	assert.Equal(t, "txid-1", backend.lastReplace)
}

// The opening rate comes from the fee source, not from the mempool.
func TestBmmEngineRatesWithNoMempoolRead(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.noMempool = true
	fee := newFakeFee()
	engine.fee = fee

	assert.Positive(t, engine.NextBlockRate(context.Background()))
	assert.Equal(t, 1, fee.calls)
}
