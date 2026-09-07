package api

import (
	"fmt"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/nodes"
)

// sidechainNode builds the RPC client for a sidechain.
func sidechainNode(cfg orchestrator.BinaryConfig, network config.Network) (sidechain.Node, error) {
	return nodes.New(cfg.Name, cfg.RPCHost(), cfg.Port, cfg.IsBitcoinCore, network)
}

// bmmNode is the same client, for a chain whose blocks the BMM engine produces.
// A chain that mines its own blocks is refused here rather than deeper down,
// where the node's own error text says nothing about why.
func bmmNode(cfg orchestrator.BinaryConfig, network config.Network) (sidechain.BMMNode, error) {
	node, err := sidechainNode(cfg, network)
	if err != nil {
		return nil, err
	}
	bmm, ok := node.(sidechain.BMMNode)
	if !ok {
		return nil, fmt.Errorf("%s produces its own blocks: the BMM engine does not drive it", cfg.DisplayName)
	}
	return bmm, nil
}

// withdrawalNode is the same client, for a chain that proposes withdrawal
// bundles. A chain that settles withdrawals elsewhere is refused here.
func withdrawalNode(node sidechain.Node, displayName string) (sidechain.WithdrawalNode, error) {
	bundles, ok := node.(sidechain.WithdrawalNode)
	if !ok {
		return nil, fmt.Errorf("%s proposes no withdrawal bundle: it settles withdrawals elsewhere", displayName)
	}
	return bundles, nil
}
