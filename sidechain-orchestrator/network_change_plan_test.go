package orchestrator

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

func planFixture(t *testing.T, network string) *Orchestrator {
	t.Helper()
	home := redirectHome(t)
	bitwindowDir := bitwindowRoot(home)
	require.NoError(t, os.MkdirAll(bitwindowDir, 0o755))

	o := New(t.TempDir(), network, bitwindowDir, AllDefaults(), testLogger(t))
	conf, err := config.NewBitcoinConfManager(bitwindowDir, config.NetworkFromString(network), testLogger(t))
	require.NoError(t, err)
	o.BitcoinConf = conf
	return o
}

// The datadir prompt must key on the wallet backend, not the network alone:
// an electrum wallet downloads no chain, so it never needs a datadir.
// The plan follows the node mode, not the wallet backend: full mode runs Core
// whatever wallet is active, and light mode runs nothing.
func TestPlanNetworkChangeDatadirFollowsNodeMode(t *testing.T) {
	for _, tc := range []struct {
		name              string
		network           string
		mode              NodeMode
		datadir           string
		mustSelectDatadir bool
		needsLocal        bool
	}{
		{name: "signet light", network: "signet", mode: NodeModeLight},
		{name: "signet full", network: "signet", mode: NodeModeFull, needsLocal: true},
		{name: "mainnet light", network: "mainnet", mode: NodeModeLight},
		{name: "mainnet full", network: "mainnet", mode: NodeModeFull, mustSelectDatadir: true, needsLocal: true},
		{name: "mainnet full with datadir", network: "mainnet", mode: NodeModeFull, datadir: "set", needsLocal: true},
		{name: "eCash light", network: "ecash", mode: NodeModeLight},
		{name: "eCash full", network: "ecash", mode: NodeModeFull, mustSelectDatadir: true, needsLocal: true},
		{name: "forknet full", network: "forknet", mode: NodeModeFull, mustSelectDatadir: true, needsLocal: true},
		// Regtest serves no Esplora, so light mode narrows to full there.
		{name: "regtest light narrows to full", network: "regtest", mode: NodeModeLight, needsLocal: true},
		{name: "regtest full", network: "regtest", mode: NodeModeFull, needsLocal: true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			o := planFixture(t, "signet")
			require.NoError(t, WriteNodeMode(o.BitwindowDir, tc.mode))
			if tc.datadir != "" {
				require.NoError(t, o.BitcoinConf.UpdateDataDir(t.TempDir(), config.NetworkFromString(tc.network)))
			}

			plan := o.PlanNetworkChange(NetworkChangeRequest{Network: tc.network})

			require.Equal(t, tc.mustSelectDatadir, plan.MustSelectDatadir)
			require.Equal(t, tc.needsLocal, plan.NeedsLocalBackends)
			require.Equal(t, config.NetworkFromString(tc.network), plan.Network)
		})
	}
}

// An explicit swap onto a network is a move onto its local node, so it still
// has to have somewhere to put the chain.
func TestPlanNetworkChangeWithoutWalletStillGuardsAnExplicitSwap(t *testing.T) {
	o := planFixture(t, "signet")
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))

	plan := o.PlanNetworkChange(NetworkChangeRequest{Network: "ecash"})

	require.True(t, plan.MustSelectDatadir)
	require.True(t, plan.NeedsLocalBackends)
}

// Staying put must not be reported as a change, or the frontend tears down
// providers for nothing.
func TestPlanNetworkChangeNoOp(t *testing.T) {
	o := planFixture(t, "signet")

	plan := o.PlanNetworkChange(NetworkChangeRequest{Network: "signet"})
	require.True(t, plan.NoOp)

	plan = o.PlanNetworkChange(NetworkChangeRequest{Network: "mainnet"})
	require.False(t, plan.NoOp)
}

// An electrum wallet reads the chain from a hosted endpoint, so a network with
// none would leave every wallet read failing once the swap applied.
// Light mode reads the chain from a remote server, so a network with none is
// unusable there. Full mode serves its own chain, so the endpoint is moot.
func TestPlanNetworkChangeLightModeNeedsChainSource(t *testing.T) {
	for _, tc := range []struct {
		network       string
		mode          NodeMode
		noChainSource bool
	}{
		{network: "mainnet", mode: NodeModeLight},
		{network: "signet", mode: NodeModeLight},
		{network: "forknet", mode: NodeModeLight},
		{network: "regtest", mode: NodeModeFull},
	} {
		t.Run(tc.network+" "+string(tc.mode), func(t *testing.T) {
			o := planFixture(t, "signet")
			require.NoError(t, WriteNodeMode(o.BitwindowDir, tc.mode))

			plan := o.PlanNetworkChange(NetworkChangeRequest{Network: tc.network})

			require.Equal(t, tc.noChainSource, plan.NoChainSource)
		})
	}
}
