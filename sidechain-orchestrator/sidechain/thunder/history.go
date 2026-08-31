package thunder

import (
	"context"
	"fmt"
	"sort"
	"strconv"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

var _ HistorySource = (*nodeHistory)(nil)

// pointedOutput is one entry of get_utxos.
type pointedOutput struct {
	OutPoint outPoint `json:"outpoint"`
	Output   output   `json:"output"`
}

// pointedSpentOutput is one entry of get_stxos. The inpoint names what spent
// the coin.
type pointedSpentOutput struct {
	OutPoint outPoint `json:"outpoint"`
	Output   struct {
		Output  output  `json:"output"`
		InPoint inPoint `json:"inpoint"`
	} `json:"output"`
}

// outPoint names an output. A deposit carries a mainchain "txid:vout" string,
// so only the regular and coinbase forms name a sidechain transaction.
type outPoint struct {
	Regular *struct {
		Txid string `json:"txid"`
		Vout uint32 `json:"vout"`
	} `json:"Regular,omitempty"`
	Coinbase *struct {
		MerkleRoot string `json:"merkle_root"`
		Vout       uint32 `json:"vout"`
	} `json:"Coinbase,omitempty"`
	Deposit *string `json:"Deposit,omitempty"`
}

// id names the transaction, block or mainchain outpoint that made the output,
// and the output it names there.
//
// A deposit arrives as one "txid:vout" string, so it splits here. Carrying it
// whole would name a transaction no chain holds.
func (o outPoint) id() (string, uint32, bool) {
	switch {
	case o.Regular != nil:
		return o.Regular.Txid, o.Regular.Vout, true
	case o.Coinbase != nil:
		return o.Coinbase.MerkleRoot, o.Coinbase.Vout, true
	case o.Deposit != nil:
		txid, rest, found := strings.Cut(*o.Deposit, ":")
		if !found {
			return *o.Deposit, 0, true
		}
		vout, err := strconv.ParseUint(rest, 10, 32)
		if err != nil {
			return txid, 0, true
		}
		return txid, uint32(vout), true
	default:
		return "", 0, false
	}
}

// inPoint names what spent an output. A withdrawal bundle spends with no
// transaction, so it carries an m6id instead.
type inPoint struct {
	Regular *struct {
		Txid string `json:"txid"`
		Vin  uint32 `json:"vin"`
	} `json:"Regular,omitempty"`
	Withdrawal *struct {
		M6id string `json:"m6id"`
	} `json:"Withdrawal,omitempty"`
}

func (i inPoint) id() (string, bool) {
	switch {
	case i.Regular != nil:
		return i.Regular.Txid, true
	case i.Withdrawal != nil:
		return i.Withdrawal.M6id, true
	default:
		return "", false
	}
}

type output struct {
	Address string  `json:"address"`
	Content content `json:"content"`
}

// content is a thunder OutputContent.
type content struct {
	Value *int64 `json:"Value,omitempty"`
	// A withdrawal names its amounts as value and main_fee. One serializer
	// renames them, so both spellings decode.
	Withdrawal *struct {
		Value       int64 `json:"value"`
		MainFee     int64 `json:"main_fee"`
		ValueSats   int64 `json:"value_sats"`
		MainFeeSats int64 `json:"main_fee_sats"`
	} `json:"Withdrawal,omitempty"`
}

// isWithdrawal says whether the output carries money leaving the chain rather
// than a coin the wallet holds.
func (c content) isWithdrawal() bool { return c.Withdrawal != nil }

// valueSats is what a coin holds. A withdrawal holds nothing for this wallet,
// because the money is on its way to the mainchain.
func (c content) valueSats() int64 {
	if c.Value == nil {
		return 0
	}
	return *c.Value
}

// nodeHistory reads the wallet history from the node itself, with no index.
// A full node holds every coin, so its own get_utxos and get_stxos name every
// transaction that touched an address, and the addresses stay on the host.
type nodeHistory struct {
	proxy *sidechain.JSONRPCProxy
}

// newNodeHistory reads through one node.
func newNodeHistory(proxy *sidechain.JSONRPCProxy) *nodeHistory {
	return &nodeHistory{proxy: proxy}
}

// TipHeight is the node's best block. getblockcount counts the blocks, and
// genesis sits at height 0, so the tip is one less.
func (h *nodeHistory) TipHeight(ctx context.Context) (uint32, error) {
	var count int64
	if err := h.proxy.Client.Call(ctx, "getblockcount", nil, &count); err != nil {
		return 0, fmt.Errorf("read the block count: %w", err)
	}
	if count <= 0 {
		return 0, nil
	}
	return uint32(count - 1), nil
}

// nodeAddresses reads the addresses the node's own wallet holds.
type nodeAddresses struct {
	proxy *sidechain.JSONRPCProxy
}

func newNodeAddresses(proxy *sidechain.JSONRPCProxy) *nodeAddresses {
	return &nodeAddresses{proxy: proxy}
}

func (a *nodeAddresses) Addresses(ctx context.Context) ([]string, error) {
	var addresses []string
	if err := a.proxy.Client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, fmt.Errorf("read the wallet addresses: %w", err)
	}
	return addresses, nil
}

var _ AddressSource = (*nodeAddresses)(nil)

// History lists what touched a set of addresses.
//
// The node records no height for a coin, so every entry reads as confirmed
// with no height. A caller that wants heights reads an index instead.
func (h *nodeHistory) History(
	ctx context.Context, addresses []string,
) ([]sidechainesplora.Entry, error) {
	byID := make(map[string]*sidechainesplora.Entry)
	var order []string

	// ownsOutput marks the rows that already name an output of this wallet. A
	// row for the transaction that spent a coin owns none.
	ownsOutput := make(map[string]bool)

	add := func(id string, vout uint32, value int64, isDeposit, owned bool) {
		entry, seen := byID[id]
		if !seen {
			byID[id] = &sidechainesplora.Entry{
				Txid: id, Confirmed: true, IsDeposit: isDeposit,
			}
			entry = byID[id]
			order = append(order, id)
		}
		if owned && !ownsOutput[id] {
			entry.Vout = vout
			ownsOutput[id] = true
		}
		entry.ValueSats += value
	}

	owned := make(map[string]bool, len(addresses))
	for _, address := range addresses {
		owned[address] = true
	}

	var utxos []pointedOutput
	if err := h.proxy.Client.Call(ctx, "get_utxos", []any{addresses}, &utxos); err != nil {
		return nil, fmt.Errorf("read wallet utxos: %w", err)
	}
	for _, utxo := range utxos {
		// A withdrawal output is money on its way off the chain, not money the
		// wallet gained. The inputs and the change of the transaction that made
		// it already record what left.
		if utxo.Output.Content.isWithdrawal() {
			continue
		}
		id, vout, ok := utxo.OutPoint.id()
		if !ok {
			continue
		}
		add(id, vout, utxo.Output.Content.valueSats(), utxo.OutPoint.Deposit != nil, true)
	}

	var stxos []pointedSpentOutput
	if err := h.proxy.Client.Call(ctx, "get_stxos", []any{addresses}, &stxos); err != nil {
		return nil, fmt.Errorf("read wallet spent utxos: %w", err)
	}
	for _, stxo := range stxos {
		// A bundle spends a withdrawal output. Counting it here would record
		// the money leaving a second time, under the bundle.
		if stxo.Output.Output.Content.isWithdrawal() {
			continue
		}
		value := stxo.Output.Output.Content.valueSats()
		if id, vout, ok := stxo.OutPoint.id(); ok {
			add(id, vout, value, stxo.OutPoint.Deposit != nil, true)
		}
		// The spend removes the coin again, under the transaction that took it.
		// That transaction pays this wallet no output of its own.
		if id, ok := stxo.Output.InPoint.id(); ok {
			add(id, 0, -value, false, false)
		}
	}

	out := make([]sidechainesplora.Entry, 0, len(order))
	for _, id := range order {
		out = append(out, *byID[id])
	}
	sort.SliceStable(out, func(i, j int) bool { return out[i].Txid < out[j].Txid })
	return out, nil
}
