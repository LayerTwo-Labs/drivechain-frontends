// Package freebank is the client for the FreeBank sidechain, a Bitcoin Core
// 0.16 fork.
package freebank

import (
	"context"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/corenode"
)

var (
	_ sidechain.Node          = (*Client)(nil)
	_ sidechain.OwnWalletNode = (*Client)(nil)
)

// Client talks to a FreeBank node.
type Client struct {
	*corenode.Client
}

// NewClient creates a client pointed at host:port. cookiePath is the node's
// .cookie.
func NewClient(host string, port int, cookiePath string) *Client {
	return &Client{corenode.New("freebank", host, port, cookiePath)}
}

// OwnWallet marks FreeBank as a node that creates and keeps its own wallet.
func (c *Client) OwnWallet() {}

// GetBalance returns the wallet balance in satoshis. The node predates
// getbalances.
func (c *Client) GetBalance(ctx context.Context) (totalSats, availableSats int64, err error) {
	info, err := corenode.Decode[struct {
		Balance            float64 `json:"balance"`
		UnconfirmedBalance float64 `json:"unconfirmed_balance"`
		ImmatureBalance    float64 `json:"immature_balance"`
	}](ctx, c.Client, "getwalletinfo", nil)
	if err != nil {
		return 0, 0, err
	}
	available := corenode.BTCToSats(info.Balance)
	return available + corenode.BTCToSats(info.UnconfirmedBalance+info.ImmatureBalance), available, nil
}

// GetNewAddress returns a fresh legacy address.
func (c *Client) GetNewAddress(ctx context.Context) (string, error) {
	return corenode.Decode[string](ctx, c.Client, "getnewaddress", []any{"", "legacy"})
}

// Args pins the node to the mainchain fork block, without which it refuses to
// boot.
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
	// Without the flag, the node looks for grpcurl on PATH.
	if grpcurl := host.ToolPath("grpcurl"); grpcurl != "" {
		args = append(args, "-grpcurlbin="+grpcurl)
	}
	return args, nil
}
