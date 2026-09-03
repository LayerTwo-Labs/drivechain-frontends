package config

import "testing"

// Core's estimator reads a mempool that carries transactions no miner takes,
// so the eCash network reads its own explorer instead.
func TestFeeExplorerURLForNetwork(t *testing.T) {
	if got := FeeExplorerURLForNetwork(NetworkECash); got != "https://explorer.alpha.ecash.ninja" {
		t.Errorf("ecash explorer = %q", got)
	}
	for _, n := range []Network{NetworkMainnet, NetworkSignet, NetworkRegtest} {
		if got := FeeExplorerURLForNetwork(n); got != "" {
			t.Errorf("%s explorer = %q, want none", n, got)
		}
	}
}
