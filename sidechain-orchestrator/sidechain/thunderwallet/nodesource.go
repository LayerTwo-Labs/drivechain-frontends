package thunderwallet

import (
	"context"
	"encoding/hex"
	"fmt"
	"strconv"
	"strings"
)

// Caller runs one JSON-RPC method against a thunder node.
type Caller interface {
	Call(ctx context.Context, method string, params any, out any) error
}

// NodeCoins reads spendable coins from a node, and broadcasts through it.
// This is the full-mode half of the wallet's low-level seams.
type NodeCoins struct {
	rpc Caller
}

// NewNodeCoins reads through one node.
func NewNodeCoins(rpc Caller) *NodeCoins { return &NodeCoins{rpc: rpc} }

type wirePointedOutput struct {
	OutPoint wireOutPoint `json:"outpoint"`
	Output   wireOutput   `json:"output"`
}

type wireOutPoint struct {
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

type wireOutput struct {
	Address string `json:"address"`
	Content struct {
		Value *uint64 `json:"Value,omitempty"`
		// A withdrawal names its amounts as value and main_fee. One
		// serializer renames them, so both spellings decode.
		Withdrawal *struct {
			Value       uint64 `json:"value"`
			MainFee     uint64 `json:"main_fee"`
			ValueSats   uint64 `json:"value_sats"`
			MainFeeSats uint64 `json:"main_fee_sats"`
		} `json:"Withdrawal,omitempty"`
	} `json:"content"`
}

// outPoint reads the wire form into the typed one.
func (w wireOutPoint) outPoint() (OutPoint, error) {
	parseHash := func(s string) (Hash, error) {
		var h Hash
		raw, err := hex.DecodeString(s)
		if err != nil {
			return h, fmt.Errorf("decode %q: %w", s, err)
		}
		if len(raw) != len(h) {
			return h, fmt.Errorf("%q is %d bytes, want %d", s, len(raw), len(h))
		}
		copy(h[:], raw)
		return h, nil
	}

	switch {
	case w.Regular != nil:
		source, err := parseHash(w.Regular.Txid)
		return OutPoint{Kind: KindRegular, Source: source, Vout: w.Regular.Vout}, err
	case w.Coinbase != nil:
		source, err := parseHash(w.Coinbase.MerkleRoot)
		return OutPoint{Kind: KindCoinbase, Source: source, Vout: w.Coinbase.Vout}, err
	case w.Deposit != nil:
		// A mainchain outpoint reads as "txid:vout", in mainchain byte order.
		txidHex, voutText, found := strings.Cut(*w.Deposit, ":")
		if !found {
			return OutPoint{}, fmt.Errorf("deposit %q names no vout", *w.Deposit)
		}
		vout, err := strconv.ParseUint(voutText, 10, 32)
		if err != nil {
			return OutPoint{}, fmt.Errorf("deposit %q has a bad vout: %w", *w.Deposit, err)
		}
		raw, err := hex.DecodeString(txidHex)
		if err != nil || len(raw) != 32 {
			return OutPoint{}, fmt.Errorf("deposit %q has a bad txid", *w.Deposit)
		}
		var source Hash
		for i, b := range raw {
			source[31-i] = b
		}
		return OutPoint{Kind: KindDeposit, Source: source, Vout: uint32(vout)}, nil
	default:
		return OutPoint{}, fmt.Errorf("outpoint names no known variant")
	}
}

// Coins lists what a set of addresses can spend.
//
// A withdrawal output cannot be spent again, so it never reaches the caller.
func (n *NodeCoins) Coins(ctx context.Context, addresses []Address) ([]Coin, error) {
	text := make([]string, 0, len(addresses))
	for _, address := range addresses {
		text = append(text, address.String())
	}

	var utxos []wirePointedOutput
	if err := n.rpc.Call(ctx, "get_utxos", []any{text}, &utxos); err != nil {
		return nil, fmt.Errorf("read utxos: %w", err)
	}

	out := make([]Coin, 0, len(utxos))
	for _, utxo := range utxos {
		// A withdrawal output cannot be spent again, so it is not a coin.
		if utxo.Output.Content.Value == nil {
			continue
		}
		outpoint, err := utxo.OutPoint.outPoint()
		if err != nil {
			return nil, err
		}
		address, err := ParseAddress(utxo.Output.Address)
		if err != nil {
			return nil, err
		}
		value := *utxo.Output.Content.Value
		leaf, err := LeafHash(outpoint, Output{
			Address: address,
			Content: Content{Value: &value},
		})
		if err != nil {
			return nil, err
		}
		out = append(out, Coin{
			OutPoint:  outpoint,
			LeafHash:  leaf,
			Address:   address,
			ValueSats: value,
		})
	}
	return out, nil
}

// Broadcast submits a signed transaction and returns its txid.
func (n *NodeCoins) Broadcast(ctx context.Context, tx AuthorizedTransaction) (Hash, error) {
	wire, err := encodeAuthorized(tx)
	if err != nil {
		return Hash{}, err
	}
	var txid string
	if err := n.rpc.Call(ctx, "submit_transaction", []any{wire}, &txid); err != nil {
		return Hash{}, fmt.Errorf("submit transaction: %w", err)
	}
	var out Hash
	raw, err := hex.DecodeString(txid)
	if err != nil || len(raw) != len(out) {
		return Hash{}, fmt.Errorf("the node answered with txid %q", txid)
	}
	copy(out[:], raw)
	return out, nil
}

var (
	_ CoinSource  = (*NodeCoins)(nil)
	_ Broadcaster = (*NodeCoins)(nil)
)
