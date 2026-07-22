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
	for _, n := range []Network{NetworkRegtest, NetworkTestnet, NetworkDrynet} {
		if got := RemoteOrchestratorURLForNetwork(n); got != "" {
			t.Errorf("RemoteOrchestratorURLForNetwork(%s) = %q, want empty", n, got)
		}
		if got := RemoteBitwindowURLForNetwork(n); got != "" {
			t.Errorf("RemoteBitwindowURLForNetwork(%s) = %q, want empty", n, got)
		}
	}
}

func TestElectrumWalletSupportedNeedsOnlyEsplora(t *testing.T) {
	// Mainnet and drynet run electrum wallet-only: they have Esplora but no
	// hosted orchestrator, so the wallet works while drivechain reads are gated off.
	wallet := map[Network]bool{
		NetworkSignet:  true,
		NetworkForknet: true,
		NetworkDrynet:  true,
		NetworkMainnet: true,
		NetworkTestnet: false,
		NetworkRegtest: false,
	}
	for n, want := range wallet {
		if got := ElectrumWalletSupportedForNetwork(n); got != want {
			t.Errorf("ElectrumWalletSupportedForNetwork(%s) = %v, want %v", n, got, want)
		}
		if got, hasOrch := RemoteOrchestratorURLForNetwork(n) != "", (n == NetworkSignet || n == NetworkForknet); got != hasOrch {
			t.Errorf("RemoteOrchestratorURLForNetwork(%s) present = %v, want %v", n, got, hasOrch)
		}
	}
}
