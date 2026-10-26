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
			node := zside.NewNode(host, port)
			node.SeedPeer = config.SidechainSeedPeerForNetwork(name, network)
			return node, nil
		case "solana":
			return solana.NewClient(host, port), nil
		case "bitassets", "photon":
			return selfMinedNode{Proxy(name, host, port, network)}, nil
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
		if network == config.NetworkECash && config.ECashNetworkID() != "alphanet" {
			return nil, fmt.Errorf("open Elements Blue Current for the BTC to ECX sidechain wallet; the legacy Alpha wallet interface is unavailable on this network")
		}
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
	proxy.SeedPeer = config.SidechainSeedPeerForNetwork(name, network)
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
