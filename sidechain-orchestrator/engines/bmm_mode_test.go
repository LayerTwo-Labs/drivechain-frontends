package engines

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestBmmEnginePausesWhenBackendIsUnavailable(t *testing.T) {
	for _, resume := range []bool{false, true} {
		name := "active"
		if resume {
			name = "resumed"
		}
		t.Run(name, func(t *testing.T) {
			engine, backend, tip, store := newEngine(t)
			fee := newFakeFee()
			engine.fee = fee
			ctx := context.Background()
			require.NoError(t, engine.Start(ctx, testSidechain, "wallet", 20000, false))
			engine.tick(ctx)
			backend.commitment = "critical"
			backend.noInclusion = true
			tip.set("block-2")
			engine.tick(ctx)
			history := mustHistory(t, engine)
			require.Equal(t, ResultWon, history[len(history)-1].Result)
			current := engine.Current(testSidechain)
			targets, err := store.Targets()
			require.NoError(t, err)
			bids, connects, tipCalls, feeCalls := backend.bids, backend.connects, tip.calls, fee.calls
			backend.disabled = true
			if resume {
				engine = NewBmmEngine(engine.log, backend, tip, fee, store)
				engine.resumeTargets()
				engine.resumeUnconnected()
			}
			tip.set("block-3")
			for range 2 {
				engine.tick(ctx)
			}
			require.Equal(t, bids, backend.bids)
			require.Equal(t, connects, backend.connects)
			require.Equal(t, tipCalls, tip.calls)
			require.Zero(t, engine.NextBlockRate(ctx))
			require.Equal(t, feeCalls, fee.calls)
			require.Equal(t, history, mustHistory(t, engine))
			require.Equal(t, current, engine.Current(testSidechain))
			savedTargets, err := store.Targets()
			require.NoError(t, err)
			require.Equal(t, targets, savedTargets)
			running, _, _ := engine.Running(testSidechain)
			require.True(t, running)

			backend.disabled = false
			backend.noInclusion = false
			backend.connected = true
			engine.tick(ctx)
			require.Greater(t, backend.bids, bids)
			require.Greater(t, backend.connects, connects)
			require.Equal(t, BidConnected, roundOn(t, engine, "block-1").OurBids[0].State)
		})
	}
}
