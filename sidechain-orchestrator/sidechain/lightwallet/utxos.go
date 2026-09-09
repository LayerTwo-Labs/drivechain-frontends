package lightwallet

import (
	"encoding/json"
	"fmt"
)

// A chain names the value of a plain coin under one of these keys. The forks
// that can hold more than bitcoin in an output name it BitcoinSats.
const (
	ValueKeyValue       = "Value"
	ValueKeyBitcoinSats = "BitcoinSats"
)

// MarshalUTXOs writes coins in the shape get_wallet_utxos answers with, so a
// caller reads light mode and full mode with one parser. The confirmed coins
// come first, then the ones no block carries yet.
func MarshalUTXOs(valueKey string, confirmed, pending []Coin) ([]byte, error) {
	rows := make([]map[string]any, 0, len(confirmed)+len(pending))
	for _, group := range []struct {
		coins    []Coin
		inABlock bool
	}{{confirmed, true}, {pending, false}} {
		for _, coin := range group.coins {
			outpoint, err := encodeOutPoint(coin.OutPoint)
			if err != nil {
				return nil, fmt.Errorf("coin %s: %w", coin.OutPoint.Txid, err)
			}
			rows = append(rows, map[string]any{
				"outpoint": outpoint,
				"output": map[string]any{
					"address": coin.Address.String(),
					"content": map[string]any{valueKey: coin.ValueSats},
				},
				"confirmed": group.inABlock,
			})
		}
	}
	return json.Marshal(rows)
}

// encodeOutPoint writes the externally tagged form the node answers with. A
// deposit names a mainchain outpoint, which reads as one string.
func encodeOutPoint(o OutPoint) (map[string]any, error) {
	switch o.Kind {
	case KindRegular:
		return map[string]any{"Regular": map[string]any{
			"txid": o.Txid, "vout": o.Vout,
		}}, nil
	case KindCoinbase:
		return map[string]any{"Coinbase": map[string]any{
			"merkle_root": o.Txid, "vout": o.Vout,
		}}, nil
	case KindDeposit:
		return map[string]any{"Deposit": fmt.Sprintf("%s:%d", o.Txid, o.Vout)}, nil
	default:
		return nil, fmt.Errorf("outpoint kind %q is not known", o.Kind)
	}
}
