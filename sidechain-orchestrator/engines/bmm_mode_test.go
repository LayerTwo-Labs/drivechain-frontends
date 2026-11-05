package engines

import (
	"context"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
)

// A backend with no mempool read still opens a bid and connects the block it
// wins.
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

// The rival list comes from the enforcer, so a backend with no mempool read
// raises like any other.
func TestBmmEngineRaisesWithNoMempoolRead(t *testing.T) {
	engine, backend, _, _ := newEngine(t)
	backend.noMempool = true
	backend.feesSats = 50_000
	ctx := context.Background()
	require.NoError(t, engine.Start(ctx, testSidechain, "", 30_000, false))

	engine.tick(ctx)
	require.Equal(t, 1, backend.bids)

	backend.others = []*bmmpb.Bid{{Txid: "rival", CriticalHash: "rival-h", BidSats: 12_000}}
	engine.tick(ctx)

	require.Equal(t, 2, backend.bids, "outbid, so we raise")
	assert.Equal(t, int64(13_000), backend.lastBidSats)
	assert.Equal(t, "txid-1", backend.lastReplace)
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

// A light install cannot spend from a Core wallet, so a start that names one
// saves no target and bids nothing.
func TestBmmEngineRefusesACoreWalletInLightMode(t *testing.T) {
	engine, backend, _, store := newEngine(t)
	backend.noMempool = true
	backend.coreWallet = "core"
	ctx := context.Background()

	require.Error(t, engine.Start(ctx, testSidechain, "core", 30_000, false))

	targets, err := store.Targets()
	require.NoError(t, err)
	assert.Empty(t, targets)
	running, _, _ := engine.Running(testSidechain)
	assert.False(t, running)
	engine.tick(ctx)
	assert.Zero(t, backend.bids)
}

// A target saved in full mode resumes after a switch to light mode. The engine
// stops it when it names a Core wallet, and keeps bidding for an Electrum one.
func TestBmmEngineStopsASavedCoreTargetInLightMode(t *testing.T) {
	for walletID, keeps := range map[string]bool{"core": false, "electrum": true} {
		t.Run(walletID, func(t *testing.T) {
			engine, backend, tip, store := newEngine(t)
			backend.coreWallet = "core"
			ctx := context.Background()
			require.NoError(t, engine.Start(ctx, testSidechain, walletID, 30_000, false))
			engine.tick(ctx)
			require.Equal(t, 1, backend.bids)

			backend.noMempool = true
			restarted := NewBmmEngine(zerolog.New(zerolog.NewTestWriter(t)), backend, tip, newFakeFee(), store)
			restarted.resumeTargets()
			tip.set("block-2")
			restarted.tick(ctx)

			running, _, _ := restarted.Running(testSidechain)
			assert.Equal(t, keeps, running)
			targets, err := store.Targets()
			require.NoError(t, err)
			if keeps {
				assert.Len(t, targets, 1)
				assert.Equal(t, 2, backend.bids)
			} else {
				assert.Empty(t, targets)
				assert.Equal(t, 1, backend.bids)
			}
		})
	}
}
