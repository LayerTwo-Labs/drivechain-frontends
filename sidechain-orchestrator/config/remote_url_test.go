package config

import "testing"

func TestRemoteOrchestratorURLForHostedNetworks(t *testing.T) {
	if got, want := RemoteOrchestratorURLForNetwork(NetworkSignet), "https://orchestrator.signet.drivechain.info"; got != want {
		t.Fatalf("signet orchestrator URL = %q, want %q", got, want)
	}
	if got, want := RemoteBitwindowURLForNetwork(NetworkSignet), "https://bitwindow.signet.drivechain.info"; got != want {
		t.Fatalf("signet bitwindow URL = %q, want %q", got, want)
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

func TestElectrumSupportedRequiresEsploraAndOrchestrator(t *testing.T) {
	supported := map[Network]bool{
		NetworkSignet:  true,
		NetworkForknet: true,
		// Mainnet has Esplora (mempool.space) but no hosted orchestrator.
		NetworkMainnet: false,
		NetworkTestnet: false,
		NetworkRegtest: false,
	}
	for n, want := range supported {
		if got := ElectrumSupportedForNetwork(n); got != want {
			t.Errorf("ElectrumSupportedForNetwork(%s) = %v, want %v", n, got, want)
		}
	}
}
