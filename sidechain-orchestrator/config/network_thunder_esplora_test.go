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
