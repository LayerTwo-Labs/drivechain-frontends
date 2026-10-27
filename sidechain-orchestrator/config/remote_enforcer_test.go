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

	const betanetURL = "https://enforcer.beta.ecash.ninja"
	const signetURL = "https://enforcer.signet.drivechain.info"
	const ecashURL = "https://seed.ecash.eu.com/enforcer"
	liveURL := netcatalog.EmbeddedECash().Services.Enforcer.URL
	if got := RemoteEnforcerURLForNetwork(NetworkECash); got != liveURL {
		t.Fatalf("initial URL = %q, want %q", got, liveURL)
	}
	SetECashEndpoints(netcatalog.Network{ID: "ecash"})
	if got := RemoteEnforcerURLForNetwork(NetworkECash); got != ecashURL {
		t.Fatalf("ecash URL = %q, want %q", got, ecashURL)
	}
	SetECashEndpoints(netcatalog.Network{ID: "betanet"})
	if got := RemoteEnforcerURLForNetwork(NetworkECash); got != betanetURL {
		t.Fatalf("old catalog URL = %q, want %q", got, betanetURL)
	}

	entry := netcatalog.Network{ID: "betanet"}
	entry.Services.Enforcer.URL = "https://validator.example/enforcer"
	SetECashEndpoints(entry)
	if got := RemoteEnforcerURLForNetwork(NetworkECash); got != entry.Services.Enforcer.URL {
		t.Fatalf("published URL = %q, want %q", got, entry.Services.Enforcer.URL)
	}
	SetECashEndpoints(netcatalog.Network{ID: "gammanet"})
	if got := RemoteEnforcerURLForNetwork(NetworkECash); got != "" {
		t.Fatalf("a generation no catalog knows used URL %q", got)
	}

	for _, network := range []Network{NetworkMainnet, NetworkRegtest, NetworkTestnet} {
		if got := RemoteEnforcerURLForNetwork(network); got != "" {
			t.Fatalf("%s used unpublished URL %q", network, got)
		}
	}
	if got := RemoteEnforcerURLForNetwork(NetworkSignet); got != signetURL {
		t.Fatalf("compiled-in signet URL = %q, want %q", got, signetURL)
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
