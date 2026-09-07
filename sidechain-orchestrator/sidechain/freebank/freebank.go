// Package freebank is what the FreeBank sidechain adds to a plain Bitcoin Core
// fork: the wallet dialect its node speaks. Everything Core answers comes from
// the shared Core client.
package freebank

import (
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/corenode"
)

var _ sidechain.Node = (*Client)(nil)

// Client talks to a FreeBank node.
type Client struct {
	*corenode.Client
}

// NewClient creates a client pointed at host:port. cookiePath is the node's
// .cookie.
func NewClient(host string, port int, cookiePath string) *Client {
	return &Client{corenode.New("freebank", host, port, cookiePath, corenode.Options{
		// The node creates and keeps one wallet of its own, which Core answers
		// for at the root endpoint.
		WalletPath: "/",
		// The fork predates getbalances.
		LegacyBalance: true,
		// The node defaults to p2sh-segwit, but every FreeBank path that takes
		// an address is documented against legacy.
		AddressType: "legacy",
	})}
}
