package config

import "testing"

// A wallet reads its thunder history from the hosted index, so a wrong URL
// leaves the history empty with no other sign.
func TestThunderEsploraURLForNetwork(t *testing.T) {
	if got := ThunderEsploraURLForNetwork(NetworkECash); got != "https://seed.alpha.ecash.eu.com/thunder" {
		t.Errorf("ecash index = %q", got)
	}
	for _, n := range []Network{NetworkSignet, NetworkMainnet, NetworkRegtest} {
		if got := ThunderEsploraURLForNetwork(n); got != "" {
			t.Errorf("%s index = %q, want none hosted yet", n, got)
		}
	}
}

// A light install reads these chains from a hosted index and starts no daemon,
// so a wrong URL leaves the wallet empty with no other sign.
func TestSidechainEsploraURLForNetwork(t *testing.T) {
	for chain, want := range map[string]string{
		"thunder":   "https://seed.alpha.ecash.eu.com/thunder",
		"bitnames":  "https://seed.alpha.ecash.eu.com/bitnames",
		"bitassets": "https://seed.alpha.ecash.eu.com/bitassets",
		"photon":    "https://seed.alpha.ecash.eu.com/photon",
		"coinshift": "https://seed.alpha.ecash.eu.com/coinshift",
	} {
		if got := SidechainEsploraURLForNetwork(chain, NetworkECash); got != want {
			t.Errorf("%s ecash index = %q, want %q", chain, got, want)
		}
		for _, n := range []Network{NetworkSignet, NetworkMainnet, NetworkRegtest} {
			if got := SidechainEsploraURLForNetwork(chain, n); got != "" {
				t.Errorf("%s %s index = %q, want none hosted yet", chain, n, got)
			}
		}
	}
}

// A chain with no hosted index must answer empty, or a light install would read
// another chain's coins.
func TestSidechainEsploraURLRefusesAnUnhostedChain(t *testing.T) {
	for _, chain := range []string{"truthcoin", "zside", "bbc", ""} {
		if got := SidechainEsploraURLForNetwork(chain, NetworkECash); got != "" {
			t.Errorf("%q index = %q, want none hosted", chain, got)
		}
	}
}
