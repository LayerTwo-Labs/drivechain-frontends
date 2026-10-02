package thunder

import (
	"context"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// betanetSeed answers on betanet. The two seeds the node holds do not, so a
// node with no known peer syncs no block without this one.
const betanetSeed = "seed.beta.ecash.eu.com:4009"

// Node speaks the Thunder JSON-RPC. It is the plain sidechain client plus the
// seed peer the node dials on betanet.
type Node struct {
	*sidechain.JSONRPCProxy
	network string
}

// NewNode builds the Thunder node client. The network is the name the node
// takes on its command line.
func NewNode(host string, port int, network string) *Node {
	return &Node{JSONRPCProxy: sidechain.NewJSONRPCProxy(host, port), network: network}
}

// Args adds the betanet seed to the arguments of a bare node.
func (n *Node) Args(ctx context.Context, host sidechain.Host) ([]string, error) {
	args, err := n.JSONRPCProxy.Args(ctx, host)
	if err != nil {
		return nil, err
	}
	if !host.BackendOnly() || n.network != "betanet" {
		return args, nil
	}
	return append(args, "--add-peer="+betanetSeed), nil
}
