package nodes

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bbc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/zside"
)

// Two transports carry connect_block, and both give it its own deadline. A
// chain that arrives with a client of its own would cap connect_block at the
// ordinary 30 seconds, so it fails here first.
func TestEveryBmmSidechainTakesAnAuditedTransport(t *testing.T) {
	chains := []struct {
		name string
		core bool
	}{
		{name: "thunder"},
		{name: "bitnames"},
		{name: "bitassets"},
		{name: "photon"},
		{name: "coinshift"},
		{name: "truthcoin"},
		{name: "zside"},
		{name: "bbc", core: true},
	}

	for _, chain := range chains {
		t.Run(chain.name, func(t *testing.T) {
			node, err := New(chain.name, "127.0.0.1", 1, chain.core, config.NetworkSignet)
			require.NoError(t, err)

			bmm, ok := node.(sidechain.BMMNode)
			require.True(t, ok, "the BMM engine drives this chain")

			switch bmm.(type) {
			case *sidechain.JSONRPCProxy, *bbc.Client, *zside.Node:
			default:
				assert.Failf(t, "unaudited transport", "%s takes %T", chain.name, bmm)
			}
		})
	}
}
