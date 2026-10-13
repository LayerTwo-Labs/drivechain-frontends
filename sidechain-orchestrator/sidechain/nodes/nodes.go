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
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/elements"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/freebank"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/solana"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/zside"
)

// New returns the client for a sidechain. A Core derived chain speaks Core's
// JSON-RPC authenticated by the cookie its node writes on start; the CUSF
// chains speak the JSON-RPC that Proxy builds.
func New(name, host string, port int, isBitcoinCore bool, network config.Network) (sidechain.Node, error) {
	if !isBitcoinCore {
		switch name {
		case "zside":
			return zside.NewNode(host, port), nil
		case "thunder":
			return thunder.NewNode(host, port, config.CusfNetworkName(network, config.ECashNetworkID())), nil
		case "solana":
			return solana.NewClient(host, port), nil
		case "bitassets", "photon":
			return selfMinedNode{sidechain.NewJSONRPCProxy(host, port)}, nil
		default:
			return Proxy(name, host, port, network), nil
		}
	}
	dirs, ok := config.DirConfigByName(name)
	if !ok {
		return nil, fmt.Errorf("no directory config for %s", name)
	}
	datadir := dirs.DatadirNetwork(network, "")
	cookie := filepath.Join(datadir, ".cookie")

	switch name {
	case "liquid-signet":
		return elements.NewNode(host, port, datadir, network), nil
	case "freebank":
		return freebank.NewClient(host, port, cookie), nil
	default:
		return bbc.NewClient(host, port, cookie), nil
	}
}

// Proxy returns the JSON-RPC proxy of a CUSF sidechain. Truthcoin and
// coinshift send the cookie their node writes.
func Proxy(name, host string, port int, network config.Network) *sidechain.JSONRPCProxy {
	proxy := sidechain.NewJSONRPCProxy(host, port)
	switch name {
	case "truthcoin":
		proxy.Client.WithCookie(truthcoin.CookieFile(network))
	case "coinshift":
		proxy.Client.WithCookie(coinshift.CookieFile(network))
	}
	return proxy
}

// selfMinedNode is a chain that serves no block template and mines its own
// blocks, so the BMM engine does not drive it.
type selfMinedNode struct {
	sidechain.WithdrawalNode
}
