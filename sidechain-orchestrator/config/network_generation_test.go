package config

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// The eCash id is free-form, so the endpoints come from the published backends
// rather than a hostname built out of the id.
func TestECashURLsFollowTheCatalog(t *testing.T) {
	original := ECashEndpoints()
	t.Cleanup(func() { SetECashEndpoints(original) })

	SetECashEndpoints(netcatalog.Network{
		ID: "betanet",
		Backends: []netcatalog.Backend{
			{Kind: "esplora", URL: "https://esplora.beta.example"},
			{Kind: "electrum", URL: "ssl://electrum.beta.example:50012"},
		},
		ExplorerTxTemplate: "https://explorer.beta.example/tx/{txid}",
	})

	urls := EsploraURLsForNetwork(NetworkECash)
	if len(urls) != 1 || urls[0] != "https://esplora.beta.example" {
		t.Errorf("EsploraURLsForNetwork(eCash) = %v, want the published esplora backend", urls)
	}
	host, port := ElectrumHostPortForNetwork(NetworkECash)
	if host != "ssl://electrum.beta.example" || port != 50012 {
		t.Errorf("ElectrumHostPortForNetwork(eCash) = %q, %d, want the published electrum backend", host, port)
	}
	if got := ECashExplorerHost(); got != "explorer.beta.example" {
		t.Errorf("ECashExplorerHost() = %q, want the published explorer host", got)
	}
}

// An eCash network that publishes no electrum backend must yield no host, so
// the enforcer fallback skips it instead of dialling a made-up name.
func TestECashWithoutElectrumBackendYieldsNoHost(t *testing.T) {
	original := ECashEndpoints()
	t.Cleanup(func() { SetECashEndpoints(original) })

	SetECashEndpoints(netcatalog.Network{ID: "betanet"})
	if host, port := ElectrumHostPortForNetwork(NetworkECash); host != "" || port != 0 {
		t.Errorf("ElectrumHostPortForNetwork(eCash) = %q, %d, want no host", host, port)
	}
}

// The eCash networks do not share one port: alphanet seeds on 8533. A built
// name would send bitcoind to a port nothing listens on, and it would find no
// peers.
func TestECashPeerUsesThePublishedAddress(t *testing.T) {
	original := ECashNetworkID()
	t.Cleanup(func() { SetECashNetworkID(original) })

	SetECashNetworkID("betanet")
	SetECashPeer("betanet", "seed.beta.example:8533")

	m := &BitcoinConfManager{Network: NetworkECash}
	if got := m.ECashPeer(); got != "seed.beta.example:8533" {
		t.Errorf("ECashPeer() = %q, want the published address", got)
	}
}

// Before the catalog resolves, the embedded generation keeps the URLs valid.
func TestECashGenerationFallsBackToEmbedded(t *testing.T) {
	original := ECashNetworkID()
	t.Cleanup(func() { SetECashNetworkID(original) })

	SetECashNetworkID("")
	if got := ECashNetworkID(); got == "" {
		t.Fatal("ECashNetworkID() must fall back to the embedded catalog")
	}
	if urls := EsploraURLsForNetwork(NetworkECash); len(urls) == 0 {
		t.Error("eCash must still resolve an esplora URL before the catalog loads")
	}
}
