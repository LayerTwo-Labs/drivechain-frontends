package lightwallet

import (
	"context"
	"encoding/json"
	"slices"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// Backend answers the read half of a wallet from an index. It starts no
// sidechain node, and it holds no key: a deposit shows here as soon as the
// index carries it.
type Backend struct {
	client    *sidechainesplora.Client
	discovery *Discovery
	coins     *IndexCoins
	// shape is how this chain writes a wallet output.
	shape OutputShape
}

// NewBackend reads one window of addresses through one index.
func NewBackend(client *sidechainesplora.Client, window *Window, shape OutputShape) *Backend {
	return &Backend{
		client:    client,
		discovery: NewDiscovery(window, client),
		coins:     NewIndexCoins(client),
		shape:     shape,
	}
}

// Balance sums the bitcoin the index holds for this wallet. A coin no block
// carries yet counts in the total and not in what the wallet can spend, so a
// deposit shows the moment the index sees it. An asset output holds no
// bitcoin, so it counts in neither.
func (b *Backend) Balance(ctx context.Context) (total, available int64, err error) {
	confirmed, pending, err := b.walletCoins(ctx)
	if err != nil {
		return 0, 0, err
	}
	for _, coin := range confirmed {
		if coin.Spendable {
			available += int64(coin.ValueSats)
		}
	}
	total = available
	for _, coin := range pending {
		if coin.Spendable {
			total += int64(coin.ValueSats)
		}
	}
	return total, available, nil
}

// UTXOs lists every coin the wallet holds, including the ones no block carries
// yet.
func (b *Backend) UTXOs(ctx context.Context) (json.RawMessage, error) {
	confirmed, pending, err := b.walletCoins(ctx)
	if err != nil {
		return nil, err
	}
	return MarshalUTXOs(b.shape, confirmed, pending)
}

// NewAddress hands out the first address that never received a coin. Asking
// twice answers the same address until that one is paid, which is what a
// receive page shows.
func (b *Backend) NewAddress(ctx context.Context) (string, error) {
	address, err := b.discovery.Unused(ctx, 0)
	if err != nil {
		return "", err
	}
	return address.String(), nil
}

// Addresses names the wallet addresses the index knows about.
func (b *Backend) Addresses(ctx context.Context) ([]string, error) {
	addresses, err := b.discovery.Addresses(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]string, 0, len(addresses))
	for _, address := range addresses {
		out = append(out, address.String())
	}
	return out, nil
}

func (b *Backend) walletCoins(ctx context.Context) (confirmed, pending []Coin, err error) {
	addresses, err := b.discovery.Addresses(ctx)
	if err != nil {
		return nil, nil, err
	}
	confirmed, pending, err = b.coins.Split(ctx, addresses)
	if err != nil {
		return nil, nil, err
	}
	return b.listed(confirmed), b.listed(pending), nil
}

// listed drops the outputs this chain's wallet does not show. A withdrawal is
// leaving the chain, and the treasury already pays it out.
func (b *Backend) listed(coins []Coin) []Coin {
	out := make([]Coin, 0, len(coins))
	for _, coin := range coins {
		if coin.Spendable || slices.Contains(b.shape.Holdings, coin.ContentType) {
			out = append(out, coin)
		}
	}
	return out
}
