package orchestrator

import (
	"context"
	"fmt"
	"sync"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"

	"github.com/stretchr/testify/require"
)

type stubChainTip struct {
	mu     sync.Mutex
	height int
	err    error
	calls  int
	block  time.Duration
}

func (s *stubChainTip) TipHeight(ctx context.Context) (int, error) {
	s.mu.Lock()
	block, height, err := s.block, s.height, s.err
	s.calls++
	s.mu.Unlock()
	if block > 0 {
		select {
		case <-time.After(block):
		case <-ctx.Done():
			return 0, ctx.Err()
		}
	}
	return height, err
}

func (s *stubChainTip) callCount() int {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.calls
}

func (s *stubChainTip) setHeight(h int) {
	s.mu.Lock()
	s.height = h
	s.mu.Unlock()
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
	_, err := o.ChainSourceHeight(context.Background())
	require.NoError(t, err)

	status, err := o.GetSyncStatus(context.Background())

	require.NoError(t, err)
	require.Equal(t, int64(963476), status.ChainSource.Blocks)
	require.Equal(t, int64(963476), status.ChainSource.Headers)
	require.Empty(t, status.ChainSource.Error)
}

// The chain source is a remote server. A slow one must not hold back the
// status of the daemons on this machine.
func TestSyncStatusDoesNotWaitForTheChainSource(t *testing.T) {
	o := newTestOrchestrator(t)
	o.SetChainTipSource(&stubChainTip{height: 963476, block: 3 * time.Second})

	start := time.Now()
	_, err := o.GetSyncStatus(context.Background())

	require.NoError(t, err)
	require.Less(t, time.Since(start), 2*time.Second, "the response must not wait on the chain source")
}

// The height goes over the network, so a wallet with a local node must not
// make the app ask a remote server for it.
func TestChainSourceRefreshSkipsAWalletWithALocalNode(t *testing.T) {
	o := newTestOrchestrator(t)
	tip := &stubChainTip{height: 963476}
	o.SetChainTipSource(tip)
	svc := wallet.NewService(t.TempDir(), testLogger(t))
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	_, err := svc.GenerateWallet("Core Wallet", "", "", nil)
	require.NoError(t, err)
	o.WalletSvc = svc
	require.True(t, svc.ActiveWalletNeedsBitcoinBackends())

	require.False(t, o.activeWalletReadsChainSource())

	_, err = o.GetSyncStatus(context.Background())
	require.NoError(t, err)
	require.Equal(t, 0, tip.callCount())
}

// An electrum wallet has no other height, so the refresh must run for it.
func TestChainSourceRefreshRunsForAnElectrumWallet(t *testing.T) {
	o := newTestOrchestrator(t)
	tip := &stubChainTip{height: 963476}
	o.SetChainTipSource(tip)
	svc := wallet.NewService(t.TempDir(), testLogger(t))
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	_, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)
	o.WalletSvc = svc

	require.True(t, o.activeWalletReadsChainSource())

	_, err = o.GetSyncStatus(context.Background())
	require.NoError(t, err)
	require.Eventually(t, func() bool { return tip.callCount() > 0 }, 3*time.Second, 20*time.Millisecond)
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

	require.Equal(t, 1, tip.callCount())
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
	tip.setHeight(200)
	got, err := o.ChainSourceHeight(context.Background())

	require.NoError(t, err)
	require.Equal(t, 200, got)
	require.Equal(t, 2, tip.callCount())
}
