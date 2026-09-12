package elements

import (
	"context"
	"encoding/json"
	"fmt"
	"math/big"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/corenode"
)

// Node speaks native Alpha RPC and reloads cookie credentials on each call.
// It intentionally does not implement BMMNode: installation is not permission
// to open bids or to use the Rust chains' block-template RPC dialect.
type Node struct{ *corenode.Client }

var _ sidechain.Node = (*Node)(nil)

func NewNode(host string, port int, cookiePath string) *Node {
	return &Node{corenode.New("Elements Alpha", host, port, cookiePath, corenode.Options{})}
}

// VerifyAlpha checks authenticated chain identity, not merely an open TCP port.
// Parent replay/synchronization must be checked separately before reporting
// that a freshly installed node has caught up.
func (n *Node) VerifyAlpha(ctx context.Context) error {
	genesis, err := corenode.Decode[string](ctx, n.Client, "getblockhash", []any{0})
	if err != nil {
		return err
	}
	if genesis != config.ElementsAlphaGenesis {
		return fmt.Errorf("Elements Alpha genesis mismatch: %s", genesis)
	}
	return nil
}

// GetNewAddress returns the explicit address required by Alpha consensus.
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
		return "", fmt.Errorf("Elements wallet did not return an owned explicit address")
	}
	return info.Unconfidential, nil
}

// GetBalance resolves the node's asset labels before selecting the pinned
// policy asset. It never sums unrelated tokens or assumes a "bitcoin" label.
func (n *Node) GetBalance(ctx context.Context) (int64, int64, error) {
	labels, err := corenode.Decode[map[string]string](ctx, n.Client, "dumpassetlabels", nil)
	if err != nil {
		return 0, 0, err
	}
	assetKey := config.ElementsAlphaPolicyAsset
	for label, asset := range labels {
		if asset == config.ElementsAlphaPolicyAsset {
			if assetKey != config.ElementsAlphaPolicyAsset {
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
			return 0, 0, fmt.Errorf("Elements balance response missing asset map")
		}
		value, found := amounts[assetKey]
		if !found {
			return 0, 0, fmt.Errorf("Elements balance is missing the policy asset")
		}
		amount, ok := new(big.Rat).SetString(string(value))
		if !ok || amount.Sign() < 0 {
			return 0, 0, fmt.Errorf("invalid Elements balance")
		}
		amount.Mul(amount, big.NewRat(100000000, 1))
		if !amount.IsInt() || !amount.Num().IsInt64() {
			return 0, 0, fmt.Errorf("Elements balance is not a valid atom amount")
		}
		if i == 0 {
			available = amount.Num().Int64()
		}
		total.Add(total, amount.Num())
	}
	if !total.IsInt64() {
		return 0, 0, fmt.Errorf("Elements balance overflow")
	}
	return total.Int64(), available, nil
}
