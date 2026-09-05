package api

import (
	"fmt"
	"path/filepath"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bbc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/freebank"
)

// sidechainNode builds the RPC client for a sidechain. A Core derived chain
// speaks Core's JSON-RPC authenticated by the cookie its node writes on start;
// the CUSF chains speak a bare JSON-RPC with no credentials.
func sidechainNode(cfg orchestrator.BinaryConfig, network config.Network) (sidechain.Node, error) {
	if !cfg.IsBitcoinCore {
		return sidechain.NewJSONRPCProxy(cfg.RPCHost(), cfg.Port), nil
	}
	dirs, ok := config.DirConfigByName(cfg.Name)
	if !ok {
		return nil, fmt.Errorf("no directory config for %s", cfg.Name)
	}
	cookie := filepath.Join(dirs.DatadirNetwork(network, ""), ".cookie")
	if cfg.Name == "freebank" {
		return freebank.NewClient(cfg.RPCHost(), cfg.Port, cookie), nil
	}
	return bbc.NewClient(cfg.RPCHost(), cfg.Port, cookie), nil
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
