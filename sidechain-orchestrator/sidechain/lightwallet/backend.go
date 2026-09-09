package lightwallet

import (
	"context"
	"encoding/json"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// Backend answers the read half of a wallet from an index. It starts no
// sidechain node, and it holds no key: a deposit shows here as soon as the
// index carries it.
type Backend struct {
	client    *sidechainesplora.Client
	discovery *Discovery
	coins     *IndexCoins
	// valueKey is the JSON key this chain names a plain coin value under.
	valueKey string
}

// NewBackend reads one window of addresses through one index.
func NewBackend(client *sidechainesplora.Client, window *Window, valueKey string) *Backend {
	return &Backend{
		client:    client,
		discovery: NewDiscovery(window, client),
		coins:     NewIndexCoins(client),
		valueKey:  valueKey,
	}
}

// Balance sums the coins the index holds for this wallet. A coin no block
// carries yet counts in the total and not in what the wallet can spend, so a
// deposit shows the moment the index sees it.
func (b *Backend) Balance(ctx context.Context) (total, available int64, err error) {
	confirmed, pending, err := b.walletCoins(ctx)
	if err != nil {
		return 0, 0, err
	}
	for _, coin := range confirmed {
		available += int64(coin.ValueSats)
	}
	total = available
	for _, coin := range pending {
		total += int64(coin.ValueSats)
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
	return MarshalUTXOs(b.valueKey, confirmed, pending)
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
	return b.coins.Split(ctx, addresses)
}
