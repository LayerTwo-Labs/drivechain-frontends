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

func TestECashReplayLockTimeFollowsTheLiveNetwork(t *testing.T) {
	previous, previousID := ECashEndpoints(), ECashNetworkID()
	t.Cleanup(func() { SetECashEndpoints(previous); SetECashNetworkID(previousID) })

	lockTime := func(t *testing.T) uint32 {
		t.Helper()
		got, err := ECashReplayLockTime()
		if err != nil {
			t.Fatalf("ECashReplayLockTime: %v", err)
		}
		return got
	}

	SetECashNetworkID("ecash-mainnet")
	SetECashEndpoints(netcatalog.Network{ID: "ecash-mainnet", ReplayLockTime: 499999998})
	if got := lockTime(t); got != 499999998 {
		t.Errorf("ECashReplayLockTime() = %d, want 499999998", got)
	}

	// An entry without the field keeps the default.
	SetECashNetworkID("betanet")
	SetECashEndpoints(netcatalog.Network{ID: "betanet"})
	if got := lockTime(t); got != 499999999 {
		t.Errorf("ECashReplayLockTime() = %d, want 499999999", got)
	}

	// Before the catalog loads, the compiled-in row of the live id decides.
	SetECashEndpoints(netcatalog.Network{})
	embedded, ok := netcatalog.Embedded().ByID("betanet")
	if !ok {
		t.Fatal("the compiled-in catalog lists no betanet")
	}
	if got := lockTime(t); got != embedded.ReplayLockTimeOrDefault() {
		t.Errorf("ECashReplayLockTime() = %d, want %d", got, embedded.ReplayLockTimeOrDefault())
	}
}

// A restart on a network that only the published catalog lists must not take
// the compiled-in network's locktime before the catalog loads.
func TestECashReplayLockTimeRefusesAnUnloadedNetwork(t *testing.T) {
	previous, previousID := ECashEndpoints(), ECashNetworkID()
	t.Cleanup(func() { SetECashEndpoints(previous); SetECashNetworkID(previousID) })

	SetECashNetworkID("ecash-mainnet")
	SetECashEndpoints(netcatalog.Network{})
	if got, err := ECashReplayLockTime(); err == nil {
		t.Fatalf("ECashReplayLockTime() = %d, want an error for an unloaded network", got)
	}

	// A row for another network does not answer for the live one.
	SetECashEndpoints(netcatalog.Network{ID: "betanet"})
	if got, err := ECashReplayLockTime(); err == nil {
		t.Fatalf("ECashReplayLockTime() = %d, want an error while only betanet is loaded", got)
	}

	SetECashEndpoints(netcatalog.Network{ID: "ecash-mainnet", ReplayLockTime: 499999998})
	if got, err := ECashReplayLockTime(); err != nil || got != 499999998 {
		t.Fatalf("ECashReplayLockTime() = %d, %v, want 499999998", got, err)
	}
}
