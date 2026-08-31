package thunderwallet

import (
	"context"
	"sync"
	"time"
)

// reserveHold is how long a spent coin stays hidden. An index catches up in
// one sync pass, and the coin is then gone from its own answer.
const reserveHold = 2 * time.Minute

// ReservedCoins hides the coins a broadcast already spent.
//
// An index lags the node, so it keeps offering a spent coin until it syncs.
// Two sends in a row would then pick the same coin, and the node would refuse
// the second one as a conflict.
type ReservedCoins struct {
	source CoinSource

	mu     sync.Mutex
	spent  map[OutPoint]time.Time
	change map[OutPoint]pendingCoin
}

// pendingCoin is change the wallet made and the index has not seen yet.
type pendingCoin struct {
	coin Coin
	at   time.Time
}

// NewReservedCoins wraps a source that lags what the wallet spends.
func NewReservedCoins(source CoinSource) *ReservedCoins {
	return &ReservedCoins{
		source: source,
		spent:  make(map[OutPoint]time.Time),
		change: make(map[OutPoint]pendingCoin),
	}
}

// Reserve records what one broadcast spent, and the change it made.
func (r *ReservedCoins) Reserve(spent []OutPoint, change []Coin) {
	now := time.Now()
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, outpoint := range spent {
		r.spent[outpoint] = now
		delete(r.change, outpoint)
	}
	for _, coin := range change {
		r.change[coin.OutPoint] = pendingCoin{coin: coin, at: now}
	}
}

// Coins lists what the source offers, less the coins the wallet spent.
func (r *ReservedCoins) Coins(ctx context.Context, addresses []Address) ([]Coin, error) {
	coins, err := r.source.Coins(ctx, addresses)
	if err != nil {
		return nil, err
	}

	r.mu.Lock()
	defer r.mu.Unlock()
	now := time.Now()
	for key, at := range r.spent {
		if now.Sub(at) > reserveHold {
			delete(r.spent, key)
		}
	}
	for key, pending := range r.change {
		if now.Sub(pending.at) > reserveHold {
			delete(r.change, key)
		}
	}

	wanted := make(map[Address]bool, len(addresses))
	for _, address := range addresses {
		wanted[address] = true
	}

	out := make([]Coin, 0, len(coins)+len(r.change))
	seen := make(map[OutPoint]bool, len(coins))
	for _, coin := range coins {
		if _, held := r.spent[coin.OutPoint]; held {
			continue
		}
		seen[coin.OutPoint] = true
		out = append(out, coin)
	}
	// The index does not name the change yet, so the wallet carries it until
	// one sync pass brings it back.
	for key, pending := range r.change {
		if seen[key] || !wanted[pending.coin.Address] {
			continue
		}
		if _, held := r.spent[key]; held {
			continue
		}
		out = append(out, pending.coin)
	}
	return out, nil
}

var (
	_ CoinSource = (*ReservedCoins)(nil)
	_ Reserver   = (*ReservedCoins)(nil)
)
