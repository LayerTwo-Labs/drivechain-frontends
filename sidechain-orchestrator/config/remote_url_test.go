package config

import "testing"

func TestElectrumChainURLPrefersHostedOrchestrator(t *testing.T) {
	// Signet has a hosted orchestrator → route through it, not public esplora.
	got := ElectrumChainURLForNetwork(NetworkSignet)
	want := "https://orchestrator.signet.drivechain.info/api"
	if got != want {
		t.Fatalf("signet electrum chain URL = %q, want %q", got, want)
	}
}

func TestElectrumChainURLFallsBackToEsplora(t *testing.T) {
	// Mainnet has no hosted orchestrator yet → fall back to the esplora URL.
	if RemoteOrchestratorURLForNetwork(NetworkMainnet) != "" {
		t.Skip("mainnet now has a hosted orchestrator; update this test")
	}
	got := ElectrumChainURLForNetwork(NetworkMainnet)
	if got != EsploraURLForNetwork(NetworkMainnet) {
		t.Fatalf("mainnet electrum chain URL = %q, want esplora fallback %q", got, EsploraURLForNetwork(NetworkMainnet))
	}
}

func TestRemoteURLsEmptyForUnhostedNetworks(t *testing.T) {
	for _, n := range []Network{NetworkRegtest, NetworkTestnet} {
		if got := RemoteOrchestratorURLForNetwork(n); got != "" {
			t.Errorf("RemoteOrchestratorURLForNetwork(%s) = %q, want empty", n, got)
		}
		if got := RemoteBitwindowURLForNetwork(n); got != "" {
			t.Errorf("RemoteBitwindowURLForNetwork(%s) = %q, want empty", n, got)
		}
	}
}
