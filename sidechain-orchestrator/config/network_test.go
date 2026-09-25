package config

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// Core's estimator reads a mempool that carries transactions no miner takes,
// so the eCash network reads its own explorer instead. Each generation runs
// its own, and a bid priced off another one loses the round.
func TestFeeExplorerURLForNetwork(t *testing.T) {
	previous := ECashEndpoints()
	t.Cleanup(func() { SetECashEndpoints(previous) })

	for _, id := range []string{"betanet", "alphanet"} {
		entry, ok := netcatalog.Embedded().ByID(id)
		if !ok {
			t.Fatalf("the embedded catalog lists no %s", id)
		}
		SetECashEndpoints(entry)
		want := "https://explorer." + map[string]string{"betanet": "beta", "alphanet": "alpha"}[id] + ".ecash.ninja"
		if got := FeeExplorerURLForNetwork(NetworkECash); got != want {
			t.Errorf("%s explorer = %q, want %q", id, got, want)
		}
	}
	for _, n := range []Network{NetworkMainnet, NetworkSignet, NetworkRegtest} {
		if got := FeeExplorerURLForNetwork(n); got != "" {
			t.Errorf("%s explorer = %q, want none", n, got)
		}
	}
}
