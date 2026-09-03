package orchestrator

import (
	"context"
	"path/filepath"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// Cross-group swap (default → eCash → default) preserves both groups'
// datadirs in slots and rewrites the live datadir= line each time so
// bitcoind boots against the correct path. Re-entering the original group
// must not re-prompt — the datadir is restored from the preserved slot.
func TestSwapNetwork_CrossGroupPreservesDatadirs(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf)

	// Active network starts as signet (default group). Pre-stage both
	// group slots so the datadir guard passes for eCash/mainnet.
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, "/tmp/group-default")
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, "/tmp/group-ecash")
	o.BitcoinConf.Config.SetSetting("datadir", "/tmp/group-default")
	require.NoError(t, o.BitcoinConf.SaveConfig())
	require.NoError(t, o.BitcoinConf.LoadConfig(false))

	// Default → mainnet (within-group): live datadir keeps /tmp/group-default.
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.Equal(t, "/tmp/group-default", o.BitcoinConf.Config.GetSetting("datadir"))

	// Mainnet → eCash (cross-group): live datadir flips to eCash's,
	// default slot retains the mainnet datadir.
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	require.Equal(t, "/tmp/group-ecash", o.BitcoinConf.Config.GetSetting("datadir"))
	require.Equal(t, "/tmp/group-default", o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupDefault))
	require.Equal(t, "/tmp/group-ecash", o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupECash))

	// ECash → mainnet (cross-group back): default slot restored, eCash
	// slot retained for the next swap.
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.Equal(t, "/tmp/group-default", o.BitcoinConf.Config.GetSetting("datadir"))
	require.Equal(t, "/tmp/group-ecash", o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupECash))
}

// Regression: mainnet and eCash both run on chain=main, so Core
// writes blocks/ and chainstate/ to the root of the datadir for each of them.
// A user who picks the same folder for every group used to have bitcoind boot
// one chain on top of another's chainstate and reindex over it. The per-group
// suffix is what keeps them apart.
func TestSwapNetwork_SamePickedPathKeepsChainsApart(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf)

	const picked = "/tmp/one-and-only-datadir"
	for _, g := range []config.DatadirGroup{config.DatadirGroupDefault, config.DatadirGroupECash} {
		o.BitcoinConf.Config.SetGroupDatadir(g, config.GroupDatadirForPick(g, picked))
	}
	o.BitcoinConf.Config.SetSetting("datadir", picked)
	require.NoError(t, o.BitcoinConf.SaveConfig())
	require.NoError(t, o.BitcoinConf.LoadConfig(false))

	resolve := func(n config.Network) string {
		require.NoError(t, o.SwapNetwork(context.Background(), n))
		return config.BitcoinCoreDirs.DatadirNetwork(n, o.BitcoinConf.Config.GetSetting("datadir"))
	}

	mainnetDir := resolve(config.NetworkMainnet)
	ecashDir := resolve(config.NetworkECash)

	require.Equal(t, picked, mainnetDir)
	require.Equal(t, filepath.Join(picked, "ecash"), ecashDir)
	require.Len(t, map[string]bool{mainnetDir: true, ecashDir: true}, 2,
		"no two chain=main networks may share bitcoind's datadir")

	// Swapping back must restore mainnet's root, not leave it under a subdir.
	require.Equal(t, picked, resolve(config.NetworkMainnet))
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
	// ECash slot was never written.
	require.Equal(t, "", o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupECash))
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

func TestSwapNetwork_MissingDatadirStopsBeforeNetworkChange(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf)

	var called int32
	o.BitcoinConf.OnNetworkChanged = func() {
		atomic.AddInt32(&called, 1)
	}

	err := o.SwapNetwork(context.Background(), config.NetworkECash)

	require.Error(t, err)
	assert.Contains(t, err.Error(), "datadir not configured for ecash")
	assert.Equal(t, int32(0), atomic.LoadInt32(&called), "OnNetworkChanged must not fire without target datadir")
	assert.Equal(t, string(config.NetworkSignet), o.Network)
	assert.Equal(t, config.NetworkSignet, o.BitcoinConf.Network)
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

// Networks the enforcer files separately keep their validator chain across a
// swap: wiping them cost the user a full resync every time they looked at
// another network and came back.
func TestEnforcerNetworkSwapStatePathsSpareSeparateNetworks(t *testing.T) {
	for _, tc := range []struct{ from, to config.Network }{
		{config.NetworkSignet, config.NetworkRegtest},
		{config.NetworkRegtest, config.NetworkSignet},
		{config.NetworkSignet, config.NetworkMainnet},
		{config.NetworkTestnet, config.NetworkSignet},
		{config.NetworkSignet, config.NetworkSignet},
	} {
		assert.Empty(t, enforcerNetworkSwapStatePaths(tc.from, tc.to),
			"%s -> %s must keep both networks' enforcer state", tc.from, tc.to)
	}
}

// Networks that share the enforcer's directories are the one case where the
// outgoing chain sits where the incoming one will look for its own.
func TestEnforcerNetworkSwapStatePathsClearCollidingNetworks(t *testing.T) {
	paths := enforcerNetworkSwapStatePaths(config.NetworkMainnet, config.NetworkECash)

	require.NotEmpty(t, paths)
	assert.Contains(t, paths, config.EnforcerValidatorDir(config.NetworkMainnet))
	assert.Contains(t, paths, config.EnforcerWalletDir(config.NetworkMainnet))
}
