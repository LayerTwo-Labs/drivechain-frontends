package orchestrator

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
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
func TestPlanNetworkChangeDatadirFollowsWalletBackend(t *testing.T) {
	for _, tc := range []struct {
		name              string
		network           string
		backend           wallet.WalletType
		datadir           string
		mustSelectDatadir bool
		needsLocal        bool
	}{
		{name: "signet electrum", network: "signet", backend: wallet.WalletTypeElectrum},
		{name: "signet core", network: "signet", backend: wallet.WalletTypeBitcoinCore, needsLocal: true},
		{name: "mainnet electrum", network: "mainnet", backend: wallet.WalletTypeElectrum},
		{name: "mainnet core", network: "mainnet", backend: wallet.WalletTypeBitcoinCore, mustSelectDatadir: true, needsLocal: true},
		{name: "mainnet core with datadir", network: "mainnet", backend: wallet.WalletTypeBitcoinCore, datadir: "set", needsLocal: true},
		{name: "drynet electrum", network: "drynet", backend: wallet.WalletTypeElectrum},
		{name: "drynet core", network: "drynet", backend: wallet.WalletTypeBitcoinCore, mustSelectDatadir: true, needsLocal: true},
		{name: "forknet core", network: "forknet", backend: wallet.WalletTypeBitcoinCore, mustSelectDatadir: true, needsLocal: true},
		{name: "regtest core", network: "regtest", backend: wallet.WalletTypeBitcoinCore, needsLocal: true},
		{name: "mainnet enforcer", network: "mainnet", backend: wallet.WalletTypeEnforcer, mustSelectDatadir: true, needsLocal: true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			o := planFixture(t, "signet")
			if tc.datadir != "" {
				require.NoError(t, o.BitcoinConf.UpdateDataDir(t.TempDir(), config.NetworkFromString(tc.network)))
			}

			plan := o.PlanNetworkChange(NetworkChangeRequest{Network: tc.network, WalletBackend: tc.backend})

			require.Equal(t, tc.mustSelectDatadir, plan.MustSelectDatadir)
			require.Equal(t, tc.needsLocal, plan.NeedsLocalBackends)
			require.Equal(t, config.NetworkFromString(tc.network), plan.Network)
		})
	}
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
func TestPlanNetworkChangeElectrumNeedsChainSource(t *testing.T) {
	for _, tc := range []struct {
		network       string
		backend       wallet.WalletType
		noChainSource bool
	}{
		{network: "mainnet", backend: wallet.WalletTypeElectrum},
		{network: "signet", backend: wallet.WalletTypeElectrum},
		{network: "forknet", backend: wallet.WalletTypeElectrum},
		{network: "testnet", backend: wallet.WalletTypeElectrum, noChainSource: true},
		{network: "regtest", backend: wallet.WalletTypeElectrum, noChainSource: true},
		// A local node serves its own chain, so the endpoint is irrelevant.
		{network: "regtest", backend: wallet.WalletTypeBitcoinCore},
	} {
		t.Run(tc.network+" "+string(tc.backend), func(t *testing.T) {
			o := planFixture(t, "signet")
			plan := o.PlanNetworkChange(NetworkChangeRequest{Network: tc.network, WalletBackend: tc.backend})
			require.Equal(t, tc.noChainSource, plan.NoChainSource)
		})
	}
}
