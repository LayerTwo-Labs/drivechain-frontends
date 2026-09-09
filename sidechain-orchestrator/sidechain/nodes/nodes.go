// Package nodes builds the RPC client one sidechain speaks. The orchestrator
// and the API both read it, so they can never disagree about which client a
// chain gets.
package nodes

import (
	"fmt"
	"path/filepath"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bbc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/freebank"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/zside"
)

// New returns the client for a sidechain. A Core derived chain speaks Core's
// JSON-RPC authenticated by the cookie its node writes on start; the CUSF
// chains speak a bare JSON-RPC with no credentials.
func New(name, host string, port int, isBitcoinCore bool, network config.Network) (sidechain.Node, error) {
	if !isBitcoinCore {
		if name == "zside" {
			return zside.NewNode(host, port), nil
		}
		return sidechain.NewJSONRPCProxy(host, port), nil
	}
	dirs, ok := config.DirConfigByName(name)
	if !ok {
		return nil, fmt.Errorf("no directory config for %s", name)
	}
	cookie := filepath.Join(dirs.DatadirNetwork(network, ""), ".cookie")

	switch name {
	case "freebank":
		return freebank.NewClient(host, port, cookie), nil
	default:
		return bbc.NewClient(host, port, cookie), nil
	}
}
