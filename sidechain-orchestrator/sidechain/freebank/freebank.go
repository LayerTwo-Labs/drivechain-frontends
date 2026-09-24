// Package freebank is what the FreeBank sidechain adds to a plain Bitcoin Core
// fork: the wallet dialect its node speaks, and the mainchain identity it pins
// itself to at boot. Everything Core answers comes from the shared Core client.
package freebank

import (
	"context"
	"fmt"

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

// Args pins the node to one mainchain. freebankd refuses to boot without an L1
// identity, so it takes the transport, the REST port and the fork block that
// names the chain it belongs to.
func (c *Client) Args(ctx context.Context, host sidechain.Host) ([]string, error) {
	height := host.ForkHeight()
	if height <= 0 {
		return nil, fmt.Errorf("FreeBank pins its L1 identity to the eCash fork block, and this network publishes no fork height")
	}
	rest := host.MainchainREST()
	if rest == "" {
		return nil, fmt.Errorf("FreeBank reads the mainchain REST port from bitwindow-bitcoin.conf, which failed to load")
	}
	hash, err := host.MainchainBlockHash(ctx, height)
	if err != nil {
		return nil, fmt.Errorf("the mainchain has not reached the FreeBank fork height %d: %w", height, err)
	}

	args := []string{
		"-mainchaintransport=enforcer",
		"-mainchainrest=" + rest,
		"-mainchainchain=main",
		fmt.Sprintf("-mainchainblockpin=%d:%s", height, hash),
	}
	// An absent grpcurl is not fatal: the node looks for one on PATH.
	if grpcurl := host.ToolPath("grpcurl"); grpcurl != "" {
		args = append(args, "-grpcurlbin="+grpcurl)
	}
	return args, nil
}
