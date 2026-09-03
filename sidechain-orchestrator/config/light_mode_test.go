package config

import "testing"

// Regtest and testnet have no Esplora server, so light mode cannot read a chain
// for them. Offering it there gives the user a wallet that never syncs.
func TestSupportsLightMode(t *testing.T) {
	for _, n := range []Network{NetworkMainnet, NetworkSignet, NetworkECash} {
		if !SupportsLightMode(n) {
			t.Errorf("%s serves esplora, so light mode must work", n)
		}
	}
	for _, n := range []Network{NetworkRegtest, NetworkTestnet} {
		if SupportsLightMode(n) {
			t.Errorf("%s serves no esplora, so light mode must be unavailable", n)
		}
	}
}

func TestLightModeNetworksExcludesRegtest(t *testing.T) {
	for _, n := range LightModeNetworks() {
		if n == NetworkRegtest || n == NetworkTestnet {
			t.Errorf("%s must not appear in the light mode network list", n)
		}
	}
	if len(LightModeNetworks()) == 0 {
		t.Error("at least one network must serve light mode")
	}
}
