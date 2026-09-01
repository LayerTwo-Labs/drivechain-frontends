package orchestrator

import (
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// A network with no public explorer must not dial a hostname that has never
// existed. Its sidechains read a hosted address index instead, and a chain
// with neither reports no tip.
func TestExplorerHeightsSkipsNetworksWithoutHostedInfra(t *testing.T) {
	// No public explorer and no chain configured, so nothing reports a tip.
	for _, network := range []string{"ecash", "mainnet", "regtest", "testnet"} {
		t.Run(network, func(t *testing.T) {
			c := &explorerHeightsConnection{o: &Orchestrator{Network: network}}
			_, err := c.Fetch(t.Context())
			if err == nil {
				t.Fatal("expected the fetch to be skipped")
			}
			if !strings.Contains(err.Error(), "no chain tip") {
				t.Errorf("err = %v, want the skip reason", err)
			}
		})
	}

	// Signet has a public explorer, so it must not be skipped.
	if !config.PublicExplorerNetwork(config.NetworkSignet) {
		t.Error("signet is expected to have a public explorer")
	}

	// eCash has no public explorer, and a hosted index answers for it instead.
	if config.PublicExplorerNetwork(config.NetworkECash) {
		t.Error("ecash is not expected to have a public explorer")
	}
	if config.SidechainEsploraURLForNetwork("thunder", config.NetworkECash) == "" {
		t.Error("thunder on ecash is expected to have a hosted index")
	}
}
