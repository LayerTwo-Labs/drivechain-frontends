package config

import "testing"

// Pins the per-network table. A rename or collapse that drops a network from
// one switch but not another shows up here rather than as a wrong-chain boot.
func TestNetworkTable(t *testing.T) {
	cases := []struct {
		n       Network
		section string
		rpcPort int
		group   DatadirGroup
	}{
		{NetworkMainnet, "main", 8332, DatadirGroupDefault},
		{NetworkForknet, "main", 18301, DatadirGroupForknet},
		{NetworkECash, "main", 18302, DatadirGroupECash},
		{NetworkSignet, "signet", 38332, DatadirGroupDefault},
		{NetworkTestnet, "test", 18332, DatadirGroupDefault},
		{NetworkRegtest, "regtest", 18443, DatadirGroupDefault},
	}

	seenPorts := map[int]Network{}
	for _, tc := range cases {
		t.Run(string(tc.n), func(t *testing.T) {
			if got := CoreSectionForNetwork(tc.n); got != tc.section {
				t.Errorf("CoreSection = %q, want %q", got, tc.section)
			}
			if got := RPCPortForNetwork(tc.n); got != tc.rpcPort {
				t.Errorf("RPCPort = %d, want %d", got, tc.rpcPort)
			}
			if got := DatadirGroupForNetwork(tc.n); got != tc.group {
				t.Errorf("DatadirGroup = %q, want %q", got, tc.group)
			}
			if got := NetworkFromString(string(tc.n)); got != tc.n {
				t.Errorf("NetworkFromString round trip = %q", got)
			}
		})
		if prev, dup := seenPorts[tc.rpcPort]; dup {
			t.Errorf("%s and %s share RPC port %d", prev, tc.n, tc.rpcPort)
		}
		seenPorts[tc.rpcPort] = tc.n
	}
}

// The chain=main networks each need their own datadir, since Core writes them
// all to the root of the datadir and would otherwise mix three chains.
func TestChainMainNetworksHaveDistinctDatadirGroups(t *testing.T) {
	groups := map[DatadirGroup]Network{}
	for _, n := range []Network{NetworkMainnet, NetworkForknet, NetworkECash} {
		g := DatadirGroupForNetwork(n)
		if prev, dup := groups[g]; dup {
			t.Errorf("%s and %s share datadir group %q; their chain data would collide", prev, n, g)
		}
		groups[g] = n
	}
}

// Forknet runs the eCash fork flow but has its own genesis, so it shares no
// outpoint with Bitcoin. Collapsing the two predicates sends its txids to the
// public BTC explorers.
func TestSharesBitcoinHistory(t *testing.T) {
	cases := []struct {
		n      Network
		fork   bool
		shares bool
	}{
		{NetworkMainnet, false, false},
		{NetworkForknet, true, false},
		{NetworkECash, true, true},
		{NetworkSignet, false, false},
		{NetworkTestnet, false, false},
		{NetworkRegtest, false, false},
	}
	for _, tc := range cases {
		t.Run(string(tc.n), func(t *testing.T) {
			if got := IsEcashFork(tc.n); got != tc.fork {
				t.Errorf("IsEcashFork = %v, want %v", got, tc.fork)
			}
			if got := SharesBitcoinHistory(tc.n); got != tc.shares {
				t.Errorf("SharesBitcoinHistory = %v, want %v", got, tc.shares)
			}
		})
	}
}

// Launch scripts and ORCHESTRATOR_NETWORK still carry the name the slot went
// out with. Falling through to signet would boot a network nobody asked for.
func TestLookupNetworkAcceptsTheLegacyECashName(t *testing.T) {
	for _, name := range []string{"ecash", "drynet", "DRYNET"} {
		got, ok := LookupNetwork(name)
		if !ok || got != NetworkECash {
			t.Errorf("LookupNetwork(%q) = %q/%v, want ecash/true", name, got, ok)
		}
	}
}
