package config

import (
	"fmt"
	"net"
	"path/filepath"
	"strconv"
	"strings"
)

const ElementsAlphaGenesis = "672af009bd90bfc6527a5a9dda4c83aba0048c15cff3697d07e89a7f96fa5bcd"
const ElementsAlphaPolicyAsset = "62dce3bd80dc4b0503e7ccbb3fcfa4d7adfd64b4e0cc78fa5e1754b88f1d2da4"
const ElementsAlphaChainDir = "elements-v11"

// ElementsAlphaOptions describes a validation-only native node. ParentCookie
// points to the parent's rotating cookie; its contents never enter this config.
// This is deliberately separate from the Rust sidechain config materializer.
type ElementsAlphaOptions struct {
	Network      Network
	DataDir      string
	ParentHost   string
	ParentPort   int
	ParentCookie string
	RPCPort      int
	P2PPort      int
}

func (o ElementsAlphaOptions) CookiePath() string {
	return filepath.Join(o.DataDir, ElementsAlphaChainDir, ".cookie")
}

// Config returns native Elements configuration without mutating existing data.
// Network identity, parent txindex and authenticated readiness still need live
// RPC verification by the installer; a valid configuration alone is not ready.
func (o ElementsAlphaOptions) Config() (string, error) {
	if o.Network != NetworkECash || ECashNetworkID() != "alphanet" {
		return "", fmt.Errorf("Elements Alpha requires the eCash Alphanet parent")
	}
	ip := net.ParseIP(o.ParentHost)
	if ip == nil || !ip.IsLoopback() {
		return "", fmt.Errorf("Elements parent RPC must use a numeric loopback address")
	}
	for _, p := range []string{o.DataDir, o.ParentCookie} {
		if !filepath.IsAbs(p) || strings.ContainsAny(p, "\r\n\x00#") {
			return "", fmt.Errorf("Elements paths must be absolute and contain no config delimiters")
		}
	}
	seen := map[int]bool{}
	for _, port := range []int{o.ParentPort, o.RPCPort, o.P2PPort} {
		if port < 1 || port > 65535 || seen[port] {
			return "", fmt.Errorf("Elements requires distinct valid parent, RPC and peer ports")
		}
		seen[port] = true
	}
	return strings.Join([]string{
		"chain=elements", "server=1", "daemon=0",
		"rpcbind=127.0.0.1", "rpcallowip=127.0.0.1",
		"rpcport=" + strconv.Itoa(o.RPCPort),
		"port=" + strconv.Itoa(o.P2PPort),
		"mainchainrpchost=" + o.ParentHost,
		"mainchainrpcport=" + strconv.Itoa(o.ParentPort),
		"mainchainrpccookiefile=" + o.ParentCookie,
		"drivechainl1blocksync=0", "",
	}, "\n"), nil
}
