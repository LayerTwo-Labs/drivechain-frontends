package thunderwallet

import (
	"encoding/hex"
	"encoding/json"
	"fmt"
)

// The node takes an AuthorizedTransaction as JSON, while a signature covers the
// borsh encoding. These types carry the JSON shape.

type wireAuthorized struct {
	Transaction wireTransaction     `json:"transaction"`
	Auths       []wireAuthorization `json:"authorizations"`
}

type wireTransaction struct {
	// An input is a pair of an outpoint and its utreexo leaf hash, which the
	// node writes as an array of bytes.
	Inputs  []any            `json:"inputs"`
	Proof   wireUtreexoProof `json:"proof"`
	Outputs []any            `json:"outputs"`
}

// wireUtreexoProof is the empty proof a light wallet sends. The node
// regenerates every proof when it accepts the transaction.
type wireUtreexoProof struct {
	Targets []uint64 `json:"targets"`
	Hashes  []string `json:"hashes"`
}

// The node writes an ed25519 key and signature as arrays of bytes, not as
// hex, because serde has no hex adapter on those fields.
type wireAuthorization struct {
	VerifyingKey []byte `json:"verifying_key"`
	Signature    []byte `json:"signature"`
}

// MarshalJSON writes each byte as a number, the way the node reads them.
func (a wireAuthorization) MarshalJSON() ([]byte, error) {
	return json.Marshal(struct {
		VerifyingKey []int `json:"verifying_key"`
		Signature    []int `json:"signature"`
	}{
		VerifyingKey: byteNumbers(a.VerifyingKey),
		Signature:    byteNumbers(a.Signature),
	})
}

func byteNumbers(b []byte) []int {
	out := make([]int, len(b))
	for i, v := range b {
		out[i] = int(v)
	}
	return out
}

// encodeAuthorized builds the JSON the node's submit_transaction takes.
func encodeAuthorized(tx AuthorizedTransaction) (wireAuthorized, error) {
	out := wireAuthorized{
		Transaction: wireTransaction{
			Proof: wireUtreexoProof{Targets: []uint64{}, Hashes: []string{}},
		},
		Auths: make([]wireAuthorization, 0, len(tx.Authorizations)),
	}

	for i, in := range tx.Transaction.Inputs {
		outpoint, err := encodeOutPointJSON(in.OutPoint)
		if err != nil {
			return wireAuthorized{}, fmt.Errorf("input %d: %w", i, err)
		}
		out.Transaction.Inputs = append(out.Transaction.Inputs,
			[]any{outpoint, byteNumbers(in.LeafHash[:])})
	}

	for i, output := range tx.Transaction.Outputs {
		content, err := encodeContentJSON(output.Content)
		if err != nil {
			return wireAuthorized{}, fmt.Errorf("output %d: %w", i, err)
		}
		out.Transaction.Outputs = append(out.Transaction.Outputs, map[string]any{
			"address": output.Address.String(),
			"content": content,
		})
	}

	for _, auth := range tx.Authorizations {
		out.Auths = append(out.Auths, wireAuthorization{
			VerifyingKey: auth.VerifyingKey,
			Signature:    auth.Signature,
		})
	}
	return out, nil
}

// encodeOutPointJSON writes the externally tagged form the node reads. A
// deposit names a mainchain outpoint, in mainchain byte order.
func encodeOutPointJSON(o OutPoint) (map[string]any, error) {
	switch o.Kind {
	case KindRegular:
		return map[string]any{"Regular": map[string]any{
			"txid": o.Source.String(), "vout": o.Vout,
		}}, nil
	case KindCoinbase:
		return map[string]any{"Coinbase": map[string]any{
			"merkle_root": o.Source.String(), "vout": o.Vout,
		}}, nil
	case KindDeposit:
		var reversed [32]byte
		for i, b := range o.Source {
			reversed[31-i] = b
		}
		return map[string]any{"Deposit": fmt.Sprintf(
			"%s:%d", hex.EncodeToString(reversed[:]), o.Vout,
		)}, nil
	default:
		return nil, fmt.Errorf("outpoint kind %d is not known", o.Kind)
	}
}

func encodeContentJSON(c Content) (map[string]any, error) {
	switch {
	case c.Value != nil:
		return map[string]any{"Value": *c.Value}, nil
	case c.Withdrawal != nil:
		return map[string]any{"Withdrawal": map[string]any{
			"value":        c.Withdrawal.ValueSats,
			"main_fee":     c.Withdrawal.MainFeeSats,
			"main_address": c.Withdrawal.MainAddress,
		}}, nil
	default:
		return nil, fmt.Errorf("output content names no variant")
	}
}

// MarshalUTXOs writes coins in the shape get_wallet_utxos answers with, so a
// caller reads light mode and full mode with one parser.
func MarshalUTXOs(coins []Coin) ([]byte, error) {
	rows := make([]map[string]any, 0, len(coins))
	for _, coin := range coins {
		outpoint, err := encodeOutPointJSON(coin.OutPoint)
		if err != nil {
			return nil, fmt.Errorf("coin %s: %w", coin.OutPoint.Source, err)
		}
		rows = append(rows, map[string]any{
			"outpoint": outpoint,
			"output": map[string]any{
				"address": coin.Address.String(),
				"content": map[string]any{"Value": coin.ValueSats},
			},
		})
	}
	return json.Marshal(rows)
}
