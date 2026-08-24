package netcatalog

import (
	"reflect"
	"testing"
)

// The wallet reads the best backend first, so a network that publishes all
// three kinds must hand them back fulcrum, electrum, esplora.
func TestChainSourceURLsRanksFulcrumFirst(t *testing.T) {
	n := Network{Backends: []Backend{
		{Kind: KindEsplora, URL: "https://esplora.example"},
		{Kind: KindElectrum, URL: "ssl://electrum.example:50002"},
		{Kind: KindFulcrum, URL: "ssl://fulcrum.example:50002"},
	}}
	want := []string{
		"ssl://fulcrum.example:50002",
		"ssl://electrum.example:50002",
		"https://esplora.example",
	}
	if got := n.ChainSourceURLs(); !reflect.DeepEqual(got, want) {
		t.Errorf("ChainSourceURLs() = %v, want %v", got, want)
	}
}

func TestChainSourceURLsOrdersByPriorityWithinAKind(t *testing.T) {
	n := Network{Backends: []Backend{
		{Kind: KindEsplora, URL: "https://second.example", Priority: 2},
		{Kind: KindEsplora, URL: "https://first.example", Priority: 1},
	}}
	want := []string{"https://first.example", "https://second.example"}
	if got := n.ChainSourceURLs(); !reflect.DeepEqual(got, want) {
		t.Errorf("ChainSourceURLs() = %v, want %v", got, want)
	}
}

// A kind this build does not know is not a URL the wallet can read, so it must
// not reach the chain source.
func TestChainSourceURLsDropsUnknownKindsAndEmptyURLs(t *testing.T) {
	n := Network{Backends: []Backend{
		{Kind: "quantum", URL: "https://future.example"},
		{Kind: KindEsplora, URL: ""},
		{Kind: KindEsplora, URL: "https://esplora.example"},
	}}
	want := []string{"https://esplora.example"}
	if got := n.ChainSourceURLs(); !reflect.DeepEqual(got, want) {
		t.Errorf("ChainSourceURLs() = %v, want %v", got, want)
	}
}

func TestElectrumURLPrefersFulcrum(t *testing.T) {
	n := Network{Backends: []Backend{
		{Kind: KindElectrum, URL: "ssl://electrum.example:50002"},
		{Kind: KindFulcrum, URL: "ssl://fulcrum.example:50002"},
	}}
	if got := n.ElectrumURL(); got != "ssl://fulcrum.example:50002" {
		t.Errorf("ElectrumURL() = %q, want the fulcrum backend", got)
	}
}

// A network with no fulcrum entry still gets its electrum server.
func TestElectrumURLFallsBackToElectrum(t *testing.T) {
	n := Network{Backends: []Backend{{Kind: KindElectrum, URL: "ssl://electrum.example:50002"}}}
	if got := n.ElectrumURL(); got != "ssl://electrum.example:50002" {
		t.Errorf("ElectrumURL() = %q, want the electrum backend", got)
	}
}

// The published alphanet document carries a Fulcrum server and an Esplora, and
// the wallet must read the Fulcrum one first.
func TestEmbeddedECashReadsItsElectrumServerFirst(t *testing.T) {
	urls := EmbeddedECash().ChainSourceURLs()
	if len(urls) < 2 {
		t.Fatalf("embedded eCash publishes %d chain sources, want at least 2", len(urls))
	}
	if got := urls[0]; got != EmbeddedECash().ElectrumURL() {
		t.Errorf("first chain source = %q, want the electrum server %q", got, EmbeddedECash().ElectrumURL())
	}
	if got := urls[len(urls)-1]; got != EmbeddedECash().BackendURL(KindEsplora) {
		t.Errorf("last chain source = %q, want the esplora fallback", got)
	}
}
