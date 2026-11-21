package config

import "testing"

func setRegtestEndpoints(t *testing.T, e RegtestEndpoints) {
	t.Helper()
	if err := SetRegtestEndpoints(e); err != nil {
		t.Fatalf("set regtest endpoints: %v", err)
	}
	t.Cleanup(func() {
		if err := SetRegtestEndpoints(RegtestEndpoints{}); err != nil {
			t.Fatalf("clear regtest endpoints: %v", err)
		}
	})
}

func TestRegtestEndpointsServeLightMode(t *testing.T) {
	setRegtestEndpoints(t, RegtestEndpoints{
		EsploraURL:  "http://127.0.0.1:19460",
		EnforcerURL: "http://127.0.0.1:19450",
	})

	if !SupportsLightMode(NetworkRegtest) {
		t.Fatal("regtest with a self-hosted Esplora must serve light mode")
	}
	if got := EsploraURLForNetwork(NetworkRegtest); got != "http://127.0.0.1:19460" {
		t.Errorf("esplora URL = %q", got)
	}
	if got := WalletChainSourceURLsForNetwork(NetworkRegtest); len(got) != 1 || got[0] != "http://127.0.0.1:19460" {
		t.Errorf("wallet chain source URLs = %v", got)
	}
	if got := RemoteEnforcerURLForNetwork(NetworkRegtest); got != "http://127.0.0.1:19450" {
		t.Errorf("remote enforcer URL = %q", got)
	}
	if SupportsLightMode(NetworkTestnet) {
		t.Error("the regtest servers must not serve testnet")
	}
}

func TestRegtestEndpointsClear(t *testing.T) {
	setRegtestEndpoints(t, RegtestEndpoints{EsploraURL: "http://127.0.0.1:19460"})
	if err := SetRegtestEndpoints(RegtestEndpoints{}); err != nil {
		t.Fatal(err)
	}
	if SupportsLightMode(NetworkRegtest) {
		t.Error("regtest with no self-hosted Esplora must run full mode only")
	}
	if got := RemoteEnforcerURLForNetwork(NetworkRegtest); got != "" {
		t.Errorf("remote enforcer URL = %q, want none", got)
	}
}

func TestRegtestEndpointsRejectBadURLs(t *testing.T) {
	for _, e := range []RegtestEndpoints{
		{EsploraURL: "ftp://127.0.0.1:19460"},
		{EsploraURL: "127.0.0.1:19460"},
		{EnforcerURL: "http://user:pass@127.0.0.1:19450"},
		{EnforcerURL: "http://"},
	} {
		if err := SetRegtestEndpoints(e); err == nil {
			t.Errorf("SetRegtestEndpoints(%+v) took a bad URL", e)
		}
	}
	if got := CurrentRegtestEndpoints(); got != (RegtestEndpoints{}) {
		t.Errorf("a rejected URL changed the endpoints to %+v", got)
	}
}
