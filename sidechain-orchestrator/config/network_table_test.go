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
		{NetworkDrynet, "main", 18302, DatadirGroupDrynet},
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
	for _, n := range []Network{NetworkMainnet, NetworkForknet, NetworkDrynet} {
		g := DatadirGroupForNetwork(n)
		if prev, dup := groups[g]; dup {
			t.Errorf("%s and %s share datadir group %q; their chain data would collide", prev, n, g)
		}
		groups[g] = n
	}
}
