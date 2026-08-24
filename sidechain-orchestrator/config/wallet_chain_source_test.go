package config

import (
	"reflect"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// The eCash wallet reads its Fulcrum server first and keeps the Esplora as the
// fallback, so one server going down does not stop the wallet.
func TestECashWalletChainSourceRanksFulcrumFirst(t *testing.T) {
	original := ECashEndpoints()
	t.Cleanup(func() { SetECashEndpoints(original) })

	SetECashEndpoints(netcatalog.Network{
		ID: "betanet",
		Backends: []netcatalog.Backend{
			{Kind: netcatalog.KindEsplora, URL: "https://esplora.beta.example"},
			{Kind: netcatalog.KindFulcrum, URL: "ssl://fulcrum.beta.example:50002"},
		},
	})

	want := []string{"ssl://fulcrum.beta.example:50002", "https://esplora.beta.example"}
	if got := WalletChainSourceURLsForNetwork(NetworkECash); !reflect.DeepEqual(got, want) {
		t.Errorf("WalletChainSourceURLsForNetwork(eCash) = %v, want %v", got, want)
	}
}

// The catalog decides which networks read an Electrum-protocol server, so a
// signet that publishes a Fulcrum backend reads it without a code change.
func TestPublishedElectrumBackendServesAnyNetwork(t *testing.T) {
	original := PublishedEndpoints(NetworkSignet)
	t.Cleanup(func() { SetNetworkEndpoints(NetworkSignet, original) })

	SetNetworkEndpoints(NetworkSignet, netcatalog.Network{
		ID: "signet",
		Backends: []netcatalog.Backend{
			{Kind: netcatalog.KindEsplora, URL: "https://esplora.signet.example"},
			{Kind: netcatalog.KindFulcrum, URL: "ssl://fulcrum.signet.example:50002"},
		},
	})

	want := []string{"ssl://fulcrum.signet.example:50002", "https://esplora.signet.example"}
	if got := WalletChainSourceURLsForNetwork(NetworkSignet); !reflect.DeepEqual(got, want) {
		t.Errorf("WalletChainSourceURLsForNetwork(signet) = %v, want %v", got, want)
	}
}

// A network that publishes only an Esplora keeps the built-in endpoints, so
// the catalog never drops mainnet off its Electrum server.
func TestPublishedEsploraOnlyKeepsTheBuiltInEndpoints(t *testing.T) {
	original := PublishedEndpoints(NetworkMainnet)
	t.Cleanup(func() { SetNetworkEndpoints(NetworkMainnet, original) })

	SetNetworkEndpoints(NetworkMainnet, netcatalog.Network{
		ID:       "bitcoin",
		Backends: []netcatalog.Backend{{Kind: netcatalog.KindEsplora, URL: "https://esplora.mainnet.example"}},
	})

	want := []string{"ssl://explorer.mainnet.drivechain.info:50002"}
	if got := WalletChainSourceURLsForNetwork(NetworkMainnet); !reflect.DeepEqual(got, want) {
		t.Errorf("WalletChainSourceURLsForNetwork(mainnet) = %v, want %v", got, want)
	}
}

// A published fulcrum backend also serves the enforcer, which speaks the same
// wire protocol.
func TestECashElectrumHostPrefersFulcrum(t *testing.T) {
	original := ECashEndpoints()
	t.Cleanup(func() { SetECashEndpoints(original) })

	SetECashEndpoints(netcatalog.Network{
		ID: "betanet",
		Backends: []netcatalog.Backend{
			{Kind: netcatalog.KindElectrum, URL: "ssl://electrum.beta.example:50012"},
			{Kind: netcatalog.KindFulcrum, URL: "ssl://fulcrum.beta.example:50002"},
		},
	})

	host, port := ElectrumHostPortForNetwork(NetworkECash)
	if host != "ssl://fulcrum.beta.example" || port != 50002 {
		t.Errorf("ElectrumHostPortForNetwork(eCash) = %q, %d, want the fulcrum backend", host, port)
	}
}

// An eCash network that publishes no backend at all must still fall back to
// the esplora list, so a stale catalog does not leave the wallet with nothing.
func TestECashWalletChainSourceFallsBackToEsplora(t *testing.T) {
	original := ECashEndpoints()
	t.Cleanup(func() { SetECashEndpoints(original) })

	SetECashEndpoints(netcatalog.Network{ID: "betanet"})
	if got := WalletChainSourceURLsForNetwork(NetworkECash); len(got) != 0 {
		t.Errorf("WalletChainSourceURLsForNetwork(eCash) = %v, want none", got)
	}
}
