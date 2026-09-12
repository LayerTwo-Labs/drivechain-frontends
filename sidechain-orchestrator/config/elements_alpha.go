package config

import (
	"errors"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/chaincfg"
)

const ElementsAlphaGenesis = "672af009bd90bfc6527a5a9dda4c83aba0048c15cff3697d07e89a7f96fa5bcd"
const ElementsAlphaPolicyAsset = "62dce3bd80dc4b0503e7ccbb3fcfa4d7adfd64b4e0cc78fa5e1754b88f1d2da4"
const ElementsAlphaChainDir = "elements-v11"
const ElementsAlphaConfigFilename = "bitwindow-elements-alpha.conf"
const ElementsAlphaBootstrapPeer = "163.192.123.236:39444"

// ElementsAlphaWalletParams pins key encodings from elements_drivechain_identity.h.
func ElementsAlphaWalletParams() *chaincfg.Params {
	p := chaincfg.MainNetParams
	p.Name = "elements-alpha"
	p.PubKeyHashAddrID = 68
	p.ScriptHashAddrID = 13
	p.PrivateKeyID = 0x37
	p.HDPublicKeyID = [4]byte{0x18, 0x71, 0x7d, 0xf5}
	p.HDPrivateKeyID = [4]byte{0xb2, 0x63, 0xbd, 0x77}
	p.Bech32HRPSegwit = "elements"
	return &p
}

// ElementsAlphaOptions configures a validation-only node without copying credentials.
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

// Install preserves existing configuration and accepts identical bytes on restart.
func (o ElementsAlphaOptions) Install() ([]string, error) {
	content, err := o.Config()
	if err != nil {
		return nil, err
	}
	if err := os.MkdirAll(o.DataDir, 0700); err != nil {
		return nil, err
	}
	path := filepath.Join(o.DataDir, ElementsAlphaConfigFilename)
	f, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0600)
	if os.IsExist(err) {
		info, statErr := os.Lstat(path)
		if statErr != nil || !info.Mode().IsRegular() {
			return nil, fmt.Errorf("elements managed config must be a regular file: %s", path)
		}
		previous, readErr := os.ReadFile(path)
		if readErr != nil || string(previous) != content {
			return nil, fmt.Errorf("existing Elements managed config differs; review %s before restarting", path)
		}
	} else if err != nil {
		return nil, err
	} else {
		_, writeErr := f.WriteString(content)
		syncErr := f.Sync()
		closeErr := f.Close()
		if writeErr != nil || syncErr != nil || closeErr != nil {
			return nil, fmt.Errorf("persist Elements configuration: %w", errors.Join(writeErr, syncErr, closeErr))
		}
	}
	return []string{"-datadir=" + o.DataDir, "-conf=" + path}, nil
}

// Config validates settings; authenticated runtime readiness is checked separately.
func (o ElementsAlphaOptions) Config() (string, error) {
	if o.Network != NetworkECash || ECashNetworkID() != "alphanet" {
		return "", fmt.Errorf("elements alpha requires the eCash Alphanet parent")
	}
	ip := net.ParseIP(o.ParentHost)
	if ip == nil || !ip.IsLoopback() {
		return "", fmt.Errorf("elements parent RPC must use a numeric loopback address")
	}
	for _, p := range []string{o.DataDir, o.ParentCookie} {
		if !filepath.IsAbs(p) || strings.ContainsAny(p, "\r\n\x00#") {
			return "", fmt.Errorf("elements paths must be absolute and contain no config delimiters")
		}
	}
	seen := map[int]bool{}
	for _, port := range []int{o.ParentPort, o.RPCPort, o.P2PPort} {
		if port < 1 || port > 65535 || seen[port] {
			return "", fmt.Errorf("elements requires distinct valid parent, RPC and peer ports")
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
		"addnode=" + ElementsAlphaBootstrapPeer,
		"drivechainl1blocksync=0", "",
	}, "\n"), nil
}
