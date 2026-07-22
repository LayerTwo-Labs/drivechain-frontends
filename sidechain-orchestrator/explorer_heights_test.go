package orchestrator

import (
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// Networks with no hosted explorer must not dial a hostname that has never
// existed. Drynet is the case that matters: its infrastructure lives on
// drivechain.dev under a per-generation host and publishes no tip endpoint.
func TestExplorerHeightsSkipsNetworksWithoutHostedInfra(t *testing.T) {
	for _, network := range []string{"drynet", "mainnet", "regtest", "testnet"} {
		t.Run(network, func(t *testing.T) {
			c := &explorerHeightsConnection{o: &Orchestrator{Network: network}}
			_, err := c.Fetch(t.Context())
			if err == nil {
				t.Fatal("expected the fetch to be skipped")
			}
			if !strings.Contains(err.Error(), "no public explorer") {
				t.Errorf("err = %v, want the skip reason", err)
			}
		})
	}

	// Signet does have one, so it must not be skipped.
	if config.RemoteOrchestratorURLForNetwork(config.NetworkSignet) == "" {
		t.Error("signet is expected to have hosted infrastructure")
	}
}
