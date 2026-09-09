package config

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

func TestRemoteEnforcerURLForNetwork(t *testing.T) {
	ecashMu.Lock()
	originalECash, originalPublished := ecashEndpoints, published
	ecashEndpoints = netcatalog.Network{}
	published = map[Network]netcatalog.Network{}
	ecashMu.Unlock()
	t.Cleanup(func() {
		ecashMu.Lock()
		ecashEndpoints, published = originalECash, originalPublished
		ecashMu.Unlock()
	})

	const alphanetURL = "https://seed.alpha.ecash.eu.com/enforcer"
	if got := RemoteEnforcerURLForNetwork(NetworkECash); got != alphanetURL {
		t.Fatalf("initial URL = %q, want %q", got, alphanetURL)
	}
	SetECashEndpoints(netcatalog.Network{ID: "alphanet"})
	if got := RemoteEnforcerURLForNetwork(NetworkECash); got != alphanetURL {
		t.Fatalf("old catalog URL = %q, want %q", got, alphanetURL)
	}

	entry := netcatalog.Network{ID: "alphanet"}
	entry.Services.Enforcer.URL = "https://validator.example/enforcer"
	SetECashEndpoints(entry)
	if got := RemoteEnforcerURLForNetwork(NetworkECash); got != entry.Services.Enforcer.URL {
		t.Fatalf("published URL = %q, want %q", got, entry.Services.Enforcer.URL)
	}
	SetECashEndpoints(netcatalog.Network{ID: "betanet"})
	if got := RemoteEnforcerURLForNetwork(NetworkECash); got != "" {
		t.Fatalf("new generation used alphanet URL %q", got)
	}

	for _, network := range []Network{NetworkMainnet, NetworkSignet, NetworkRegtest, NetworkTestnet} {
		if got := RemoteEnforcerURLForNetwork(network); got != "" {
			t.Fatalf("%s used unpublished URL %q", network, got)
		}
	}
	entry.ID = "signet"
	entry.Services.Enforcer.URL = "https://signet.example/enforcer"
	SetNetworkEndpoints(NetworkSignet, entry)
	if got := RemoteEnforcerURLForNetwork(NetworkSignet); got != entry.Services.Enforcer.URL {
		t.Fatalf("signet URL = %q, want %q", got, entry.Services.Enforcer.URL)
	}
	if got := RemoteEnforcerURLForNetwork(NetworkMainnet); got != "" {
		t.Fatalf("mainnet used signet URL %q", got)
	}
}
