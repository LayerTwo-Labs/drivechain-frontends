package elements

import (
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"path/filepath"
	"runtime"
	"strconv"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/corenode"
	"github.com/btcsuite/btcd/chaincfg"
)

// PolicyAsset is the Alpha asset the wallet balance counts.
const PolicyAsset = "62dce3bd80dc4b0503e7ccbb3fcfa4d7adfd64b4e0cc78fa5e1754b88f1d2da4"

const (
	p2pPort       = 7066
	bootstrapPeer = "163.192.123.236:39444"
)

// Node is an Elements Alpha RPC client.
type Node struct {
	*corenode.Client
	port    int
	datadir string
	network config.Network
}

var (
	_ sidechain.Node             = (*Node)(nil)
	_ sidechain.WalletParamsNode = (*Node)(nil)
)

// NewNode returns a client for the node that runs in datadir.
func NewNode(host string, port int, datadir string, network config.Network) *Node {
	return &Node{
		Client:  corenode.New("Elements Alpha", host, port, filepath.Join(datadir, ".cookie"), corenode.Options{}),
		port:    port,
		datadir: datadir,
		network: network,
	}
}

// Args points the node at its datadir and at the local mainchain, which it
// reads as the read-only mainchain user.
func (n *Node) Args(ctx context.Context, host sidechain.Host) ([]string, error) {
	if n.network != config.NetworkECash || config.ECashNetworkID() != "alphanet" {
		return nil, fmt.Errorf("elements alpha runs only on eCash Alphanet")
	}
	mainHost, mainPort, err := host.MainchainRPC()
	if err != nil {
		return nil, err
	}
	auth, err := parentAuth(ctx, runtime.GOOS, host)
	if err != nil {
		return nil, err
	}
	return []string{
		"-datadir=" + n.datadir,
		"-rpccookiefile=" + filepath.Join(n.datadir, ".cookie"),
		"-debuglogfile=" + filepath.Join(n.datadir, "debug.log"),
		"-chain=elements",
		"-server=1",
		"-daemon=0",
		"-rpcbind=127.0.0.1",
		"-rpcallowip=127.0.0.1",
		"-rpcport=" + strconv.Itoa(n.port),
		"-port=" + strconv.Itoa(p2pPort),
		"-mainchainrpchost=" + mainHost,
		"-mainchainrpcport=" + strconv.Itoa(mainPort),
		auth,
		"-addnode=" + bootstrapPeer,
		"-drivechainl1blocksync=0",
	}, nil
}

// parentAuth names the file the node authenticates to the mainchain with.
func parentAuth(ctx context.Context, goos string, host sidechain.Host) (string, error) {
	// This elementsd reads only Core's own cookie on Windows.
	if goos == "windows" {
		return "-mainchainrpccookiefile=" + host.MainchainCookie(), nil
	}
	reader, err := host.MainchainReader(ctx)
	if err != nil {
		return "", err
	}
	return "-mainchainrpccredentialfile=" + reader, nil
}

// WalletParams returns the Alpha address and key encodings.
func (n *Node) WalletParams() *chaincfg.Params {
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

// GetNewAddress returns an unconfidential wallet address.
func (n *Node) GetNewAddress(ctx context.Context) (string, error) {
	address, err := corenode.DecodeWallet[string](ctx, n.Client, "getnewaddress", []any{"", "bech32"})
	if err != nil {
		return "", err
	}
	info, err := corenode.DecodeWallet[struct {
		Unconfidential string `json:"unconfidential"`
		IsMine         bool   `json:"ismine"`
	}](ctx, n.Client, "getaddressinfo", []any{address})
	if err != nil {
		return "", err
	}
	if !info.IsMine || info.Unconfidential == "" {
		return "", fmt.Errorf("elements wallet did not return an owned explicit address")
	}
	return info.Unconfidential, nil
}

// GetBalance returns the policy asset balance in sats.
func (n *Node) GetBalance(ctx context.Context) (int64, int64, error) {
	labels, err := corenode.Decode[map[string]string](ctx, n.Client, "dumpassetlabels", nil)
	if err != nil {
		return 0, 0, err
	}
	assetKey := PolicyAsset
	for label, asset := range labels {
		if asset == PolicyAsset {
			if assetKey != PolicyAsset {
				return 0, 0, fmt.Errorf("ambiguous policy asset labels")
			}
			assetKey = label
		}
	}
	raw, err := n.WalletCall(ctx, "getbalances", nil)
	if err != nil {
		return 0, 0, err
	}
	var reply struct {
		Mine struct {
			Trusted  map[string]json.Number `json:"trusted"`
			Pending  map[string]json.Number `json:"untrusted_pending"`
			Immature map[string]json.Number `json:"immature"`
		} `json:"mine"`
	}
	if err := json.Unmarshal(raw, &reply); err != nil {
		return 0, 0, err
	}
	total := new(big.Int)
	var available int64
	for i, amounts := range []map[string]json.Number{reply.Mine.Trusted, reply.Mine.Pending, reply.Mine.Immature} {
		if amounts == nil {
			return 0, 0, fmt.Errorf("elements balance response missing asset map")
		}
		value, found := amounts[assetKey]
		if !found {
			return 0, 0, fmt.Errorf("elements balance is missing the policy asset")
		}
		amount, ok := new(big.Rat).SetString(string(value))
		if !ok || amount.Sign() < 0 {
			return 0, 0, fmt.Errorf("invalid Elements balance")
		}
		amount.Mul(amount, big.NewRat(100000000, 1))
		if !amount.IsInt() || !amount.Num().IsInt64() {
			return 0, 0, fmt.Errorf("elements balance is not a valid atom amount")
		}
		if i == 0 {
			available = amount.Num().Int64()
		}
		total.Add(total, amount.Num())
	}
	if !total.IsInt64() {
		return 0, 0, fmt.Errorf("elements balance overflow")
	}
	return total.Int64(), available, nil
}
