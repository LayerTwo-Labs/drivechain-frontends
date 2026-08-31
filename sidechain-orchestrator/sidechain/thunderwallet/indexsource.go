package thunderwallet

import (
	"context"
	"encoding/hex"
	"fmt"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// IndexCoins reads spendable coins from an Esplora index. This is the
// light-mode half of the wallet's low-level seams, and it runs no node.
type IndexCoins struct {
	client *sidechainesplora.Client
}

// NewIndexCoins reads through one index.
func NewIndexCoins(client *sidechainesplora.Client) *IndexCoins {
	return &IndexCoins{client: client}
}

// Coins lists what a set of addresses can spend.
func (i *IndexCoins) Coins(ctx context.Context, addresses []Address) ([]Coin, error) {
	var out []Coin
	for _, address := range addresses {
		utxos, err := i.client.AddressUTXOs(ctx, address.String())
		if err != nil {
			return nil, fmt.Errorf("read utxos for %s: %w", address, err)
		}
		for _, utxo := range utxos {
			// A withdrawal output is leaving the chain. Counting it inflates
			// the balance, and its leaf hash covers a withdrawal rather than a
			// value, so spending it builds a transaction no node accepts.
			if !utxo.Spendable() {
				continue
			}
			// A coin the chain has not mined yet is neither a balance nor a
			// coin to spend.
			if !utxo.Status.Confirmed {
				continue
			}
			outpoint, err := outPointFromIndex(utxo)
			if err != nil {
				return nil, err
			}
			if utxo.Value < 0 {
				return nil, fmt.Errorf("%s holds a coin worth %d sats", address, utxo.Value)
			}
			value := uint64(utxo.Value)
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
	}
	return out, nil
}

// outPointFromIndex reads the outpoint an index row names. A deposit txid is a
// mainchain txid, so it reads in mainchain byte order.
func outPointFromIndex(utxo sidechainesplora.UTXO) (OutPoint, error) {
	raw, err := hex.DecodeString(strings.TrimSpace(utxo.Txid))
	if err != nil || len(raw) != 32 {
		return OutPoint{}, fmt.Errorf("utxo names txid %q", utxo.Txid)
	}

	var source Hash
	switch utxo.OutpointKind {
	case "regular", "":
		copy(source[:], raw)
		return OutPoint{Kind: KindRegular, Source: source, Vout: utxo.Vout}, nil
	case "coinbase":
		copy(source[:], raw)
		return OutPoint{Kind: KindCoinbase, Source: source, Vout: utxo.Vout}, nil
	case "deposit":
		for i, b := range raw {
			source[31-i] = b
		}
		return OutPoint{Kind: KindDeposit, Source: source, Vout: utxo.Vout}, nil
	default:
		return OutPoint{}, fmt.Errorf("utxo names outpoint kind %q", utxo.OutpointKind)
	}
}

var _ CoinSource = (*IndexCoins)(nil)
