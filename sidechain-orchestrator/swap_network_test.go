package orchestrator

import (
	"context"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// Cross-group swap (default → forknet → default) preserves both groups'
// datadirs in slots and rewrites the live datadir= line each time so
// bitcoind boots against the correct path. Re-entering the original group
// must not re-prompt — the datadir is restored from the preserved slot.
func TestSwapNetwork_CrossGroupPreservesDatadirs(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf)

	// Active network starts as signet (default group). Pre-stage both
	// group slots so the datadir guard passes for forknet/mainnet.
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, "/tmp/group-default")
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupForknet, "/tmp/group-forknet")
	o.BitcoinConf.Config.SetSetting("datadir", "/tmp/group-default")
	require.NoError(t, o.BitcoinConf.SaveConfig())
	require.NoError(t, o.BitcoinConf.LoadConfig(false))

	// Default → mainnet (within-group): live datadir keeps /tmp/group-default.
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.Equal(t, "/tmp/group-default", o.BitcoinConf.Config.GetSetting("datadir"))

	// Mainnet → forknet (cross-group): live datadir flips to forknet's,
	// default slot retains the mainnet datadir.
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkForknet))
	require.Equal(t, "/tmp/group-forknet", o.BitcoinConf.Config.GetSetting("datadir"))
	require.Equal(t, "/tmp/group-default", o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupDefault))
	require.Equal(t, "/tmp/group-forknet", o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupForknet))

	// Forknet → mainnet (cross-group back): default slot restored, forknet
	// slot retained for the next swap.
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.Equal(t, "/tmp/group-default", o.BitcoinConf.Config.GetSetting("datadir"))
	require.Equal(t, "/tmp/group-forknet", o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupForknet))
}

// Within-group swap (mainnet → signet) leaves the datadir alone — Bitcoin
// Core's chain subdirs do the per-network partitioning. No slot writes
// happen, no prompt is required.
func TestSwapNetwork_WithinDefaultGroupKeepsDatadir(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf)

	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, "/tmp/shared-default")
	o.BitcoinConf.Config.SetSetting("datadir", "/tmp/shared-default")
	require.NoError(t, o.BitcoinConf.SaveConfig())
	require.NoError(t, o.BitcoinConf.LoadConfig(false))

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.Equal(t, "/tmp/shared-default", o.BitcoinConf.Config.GetSetting("datadir"))

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkRegtest))
	require.Equal(t, "/tmp/shared-default", o.BitcoinConf.Config.GetSetting("datadir"))
	// Forknet slot was never written.
	require.Equal(t, "", o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupForknet))
}

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
