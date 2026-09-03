package thunderwallet

import (
	"context"
	"encoding/hex"
	"fmt"
	"strings"
	"sync"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// readAhead is how many addresses the wallet reads at the same time. A balance
// covers the whole derived window, and one address after another costs a round
// trip each.
const readAhead = 8

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
	confirmed, _, err := i.Split(ctx, addresses)
	return confirmed, err
}

// Split lists what a set of addresses holds, in two halves: the coins a block
// carries, and the coins no block carries yet. A wallet spends the first half
// and shows both.
func (i *IndexCoins) Split(
	ctx context.Context, addresses []Address,
) (confirmed, pending []Coin, err error) {
	mined := make([][]Coin, len(addresses))
	waiting := make([][]Coin, len(addresses))
	errs := make([]error, len(addresses))

	var wg sync.WaitGroup
	limit := make(chan struct{}, readAhead)
	for at, address := range addresses {
		wg.Add(1)
		limit <- struct{}{}
		go func() {
			defer wg.Done()
			defer func() { <-limit }()
			mined[at], waiting[at], errs[at] = i.readAddress(ctx, address)
		}()
	}
	wg.Wait()

	for at, err := range errs {
		if err != nil {
			return nil, nil, err
		}
		confirmed = append(confirmed, mined[at]...)
		pending = append(pending, waiting[at]...)
	}
	return confirmed, pending, nil
}

func (i *IndexCoins) readAddress(
	ctx context.Context, address Address,
) (confirmed, pending []Coin, err error) {
	utxos, err := i.client.AddressUTXOs(ctx, address.String())
	if err != nil {
		return nil, nil, fmt.Errorf("read utxos for %s: %w", address, err)
	}
	for _, utxo := range utxos {
		// A withdrawal output is leaving the chain. Counting it inflates the
		// balance, and its leaf hash covers a withdrawal rather than a value,
		// so spending it builds a transaction no node accepts.
		if !utxo.Spendable() {
			continue
		}
		coin, err := newCoin(address, utxo)
		if err != nil {
			return nil, nil, err
		}
		if utxo.Status.Confirmed {
			confirmed = append(confirmed, coin)
			continue
		}
		pending = append(pending, coin)
	}
	return confirmed, pending, nil
}

func newCoin(address Address, utxo sidechainesplora.UTXO) (Coin, error) {
	outpoint, err := outPointFromIndex(utxo)
	if err != nil {
		return Coin{}, err
	}
	if utxo.Value < 0 {
		return Coin{}, fmt.Errorf("%s holds a coin worth %d sats", address, utxo.Value)
	}
	value := uint64(utxo.Value)
	leaf, err := LeafHash(outpoint, Output{
		Address: address,
		Content: Content{Value: &value},
	})
	if err != nil {
		return Coin{}, err
	}
	return Coin{
		OutPoint:  outpoint,
		LeafHash:  leaf,
		Address:   address,
		ValueSats: value,
	}, nil
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
