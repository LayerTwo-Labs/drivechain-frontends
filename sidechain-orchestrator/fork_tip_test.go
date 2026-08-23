package orchestrator

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
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

// A multisig wallet whose cosigners all sign elsewhere still reaches a claim:
// the split leaves as a PSBT for those signers.
func TestForkScannableWallets(t *testing.T) {
	held := wallet.WalletData{Master: wallet.MasterWallet{}}
	require.True(t, forkScannable(held), "a wallet with a seed holds a key")

	watchOnly := wallet.WalletData{WatchOnly: []byte(`{"xpub":"xpub661"}`)}
	require.False(t, forkScannable(watchOnly), "a watch-only wallet can never sign")

	externalMultisig := wallet.WalletData{
		Multisig: &wallet.MultisigWalletData{
			M: 2, N: 3,
			Cosigners: []wallet.MultisigCosigner{{Xpub: "xpub1"}, {Xpub: "xpub2"}, {Xpub: "xpub3"}},
		},
	}
	require.True(t, externalMultisig.IsWatchOnly())
	require.True(t, forkScannable(externalMultisig), "the cosigners sign the psbt elsewhere")
}

func TestForkSpendableCoins(t *testing.T) {
	require.True(t, forkSpendable(true, false), "a wallet key signs it")
	require.False(t, forkSpendable(false, false), "no key, no signature")
	require.True(t, forkSpendable(false, true), "the cosigners sign the psbt")
}
