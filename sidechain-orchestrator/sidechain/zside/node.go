package zside

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ sidechain.AddressLister = (*Node)(nil)

// Node speaks the zSide JSON-RPC. It is the plain sidechain client plus the
// address listing zSide serves under two names of its own.
type Node struct {
	*sidechain.JSONRPCProxy
}

// NewNode builds the zSide node client.
func NewNode(host string, port int) *Node {
	return &Node{JSONRPCProxy: sidechain.NewJSONRPCProxy(host, port)}
}

// WalletAddressList joins both kinds of address the wallet holds. zSide keeps
// its transparent and its shielded addresses apart, and serves no combined
// method.
func (n *Node) WalletAddressList(ctx context.Context) ([]string, error) {
	transparent, err := n.addresses(ctx, "get_transparent_wallet_addresses")
	if err != nil {
		return nil, err
	}
	shielded, err := n.addresses(ctx, "get_shielded_wallet_addresses")
	if err != nil {
		return nil, err
	}
	return append(transparent, shielded...), nil
}

func (n *Node) addresses(ctx context.Context, method string) ([]string, error) {
	raw, err := n.CallRaw(ctx, method, nil)
	if err != nil {
		return nil, fmt.Errorf("read the zSide wallet addresses with %s: %w", method, err)
	}
	var list []string
	if err := json.Unmarshal(raw, &list); err != nil {
		return nil, fmt.Errorf("read the zSide wallet addresses with %s: %w", method, err)
	}
	return list, nil
}
