package orchestrator

import (
	"context"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// TestSwapNetwork_FiresOnNetworkChanged is the orchestrator-level regression
// guard for the in-process bitcoin proxy rebuild flow:
//
//	bitwindowd.UpdateNetwork → orch.SwapNetwork
//	  → BitcoinConf.UpdateNetwork(n)
//	    → BitcoinConf.OnNetworkChanged()  ← orch wires this in main.go
//	      → swappableHandler.swap(rebuilt proxy)
//
// If SwapNetwork ever stops firing OnNetworkChanged, the orch's BitcoinService
// proxy keeps pointing at the old bitcoind and every Flutter / sidechain
// caller silently talks to the wrong chain. Critical regression target.
func TestSwapNetwork_FiresOnNetworkChanged(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf, "bitcoin conf manager must be initialised")

	var called int32
	o.BitcoinConf.OnNetworkChanged = func() {
		atomic.AddInt32(&called, 1)
	}

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkRegtest))

	assert.Equal(t, int32(1), atomic.LoadInt32(&called), "OnNetworkChanged must fire exactly once for an actual network change")
	assert.Equal(t, string(config.NetworkRegtest), o.Network, "orch.Network must reflect the new network after swap")
	assert.Equal(t, config.NetworkRegtest, o.BitcoinConf.Network, "BitcoinConf.Network must reflect the new network after swap")
}

// TestSwapNetwork_SameNetworkIsNoOp guards the early-return branch — if the
// orch ever drops it, every swap-to-current-network triggers a needless proxy
// rebuild storm and a bitcoind restart.
func TestSwapNetwork_SameNetworkIsNoOp(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf)

	var called int32
	o.BitcoinConf.OnNetworkChanged = func() {
		atomic.AddInt32(&called, 1)
	}

	// newTestOrchestrator boots in signet. Swap to signet must be inert.
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkSignet))

	assert.Equal(t, int32(0), atomic.LoadInt32(&called), "OnNetworkChanged must not fire when target network equals current")
	assert.Equal(t, string(config.NetworkSignet), o.Network)
}

// TestSwapNetwork_MultipleSwapsFireCallbackEachTime guards against e.g. a
// future "fire-once" optimization that would break repeated network changes
// in the same session. Every actual change must fire the callback so the
// proxy can rebuild.
func TestSwapNetwork_MultipleSwapsFireCallbackEachTime(t *testing.T) {
	o := newTestOrchestrator(t)

	var called int32
	o.BitcoinConf.OnNetworkChanged = func() {
		atomic.AddInt32(&called, 1)
	}

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkRegtest))
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkSignet))
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkRegtest))

	assert.Equal(t, int32(3), atomic.LoadInt32(&called), "OnNetworkChanged must fire on each actual network change")
}
