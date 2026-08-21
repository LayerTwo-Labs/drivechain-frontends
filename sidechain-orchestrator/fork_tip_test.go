package orchestrator

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
)

type stubChainTip struct {
	height int
	err    error
	calls  int
}

func (s *stubChainTip) TipHeight(context.Context) (int, error) {
	s.calls++
	return s.height, s.err
}

// An electrum wallet runs no local Core, so the countdown and the block count
// both come from the chain source. Without the fallback they stay empty.
func TestForkTipFallsBackToTheChainSource(t *testing.T) {
	o := newTestOrchestrator(t)
	tip := &stubChainTip{height: 963476}
	o.SetChainTipSource(tip)

	got, err := o.ForkTip(context.Background())

	require.NoError(t, err)
	require.Equal(t, 963476, got.Blocks)
	require.Equal(t, 963476, got.Headers)
	require.Equal(t, o.Network, got.Network)
}

// A chain source that cannot answer leaves the caller with Core's error, which
// names the daemon that is actually down.
func TestForkTipReportsCoreErrorWhenTheChainSourceFailsToo(t *testing.T) {
	o := newTestOrchestrator(t)
	o.SetChainTipSource(&stubChainTip{err: fmt.Errorf("esplora unreachable")})

	_, err := o.ForkTip(context.Background())

	require.Error(t, err)
	require.NotContains(t, err.Error(), "esplora unreachable")
}

// Without a chain source there is nothing to fall back to.
func TestForkTipWithoutAChainSourceFails(t *testing.T) {
	o := newTestOrchestrator(t)

	_, err := o.ForkTip(context.Background())

	require.Error(t, err)
}

// The bottom nav reads this slot, so an electrum wallet shows a block count
// with no local daemon running.
func TestSyncStatusCarriesTheChainSourceHeight(t *testing.T) {
	o := newTestOrchestrator(t)
	o.SetChainTipSource(&stubChainTip{height: 963476})

	status, err := o.GetSyncStatus(context.Background())

	require.NoError(t, err)
	require.Equal(t, int64(963476), status.ChainSource.Blocks)
	require.Empty(t, status.ChainSource.Error)
}

// One cached read per TTL, however many callers ask: the height goes over the
// network, and the nav polls once a second.
func TestChainSourceHeightReadsOncePerTTL(t *testing.T) {
	o := newTestOrchestrator(t)
	tip := &stubChainTip{height: 963476}
	o.SetChainTipSource(tip)

	for range 5 {
		_, err := o.ChainSourceHeight(context.Background())
		require.NoError(t, err)
	}

	require.Equal(t, 1, tip.calls)
}

// A network swap throws the cache away, so the new network's height never
// reads as the old one's.
func TestChainSourceHeightResetsOnANetworkSwap(t *testing.T) {
	o := newTestOrchestrator(t)
	tip := &stubChainTip{height: 963476}
	o.SetChainTipSource(tip)
	_, err := o.ChainSourceHeight(context.Background())
	require.NoError(t, err)

	o.clearNetworkSwapCaches()
	tip.height = 200
	got, err := o.ChainSourceHeight(context.Background())

	require.NoError(t, err)
	require.Equal(t, 200, got)
	require.Equal(t, 2, tip.calls)
}
