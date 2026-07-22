package config

import "testing"

// Every drynet hostname is built from the generation, so a new drynet is an
// endpoint change rather than a code change.
func TestDrynetURLsFollowTheGeneration(t *testing.T) {
	original := DrynetGeneration()
	t.Cleanup(func() { SetDrynetGeneration(original) })

	SetDrynetGeneration("drynet3")
	urls := EsploraURLsForNetwork(NetworkDrynet)
	if len(urls) != 1 || urls[0] != "https://esplora.drynet3.drivechain.dev" {
		t.Errorf("EsploraURLsForNetwork(drynet) = %v, want the drynet3 host", urls)
	}

	m := &BitcoinConfManager{Network: NetworkDrynet}
	if got := m.DrynetPeer(); got != "drynet3.drivechain.dev:8335" {
		t.Errorf("DrynetPeer() = %q, want the drynet3 peer", got)
	}
}

// Before the catalog resolves, the embedded generation keeps the URLs valid.
func TestDrynetGenerationFallsBackToEmbedded(t *testing.T) {
	original := DrynetGeneration()
	t.Cleanup(func() { SetDrynetGeneration(original) })

	SetDrynetGeneration("")
	if got := DrynetGeneration(); got == "" {
		t.Fatal("DrynetGeneration() must fall back to the embedded catalog")
	}
	if urls := EsploraURLsForNetwork(NetworkDrynet); len(urls) == 0 {
		t.Error("drynet must still resolve an esplora URL before the catalog loads")
	}
}
