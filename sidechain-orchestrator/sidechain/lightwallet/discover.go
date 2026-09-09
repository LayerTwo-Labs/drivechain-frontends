package lightwallet

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

const (
	// gapLimit is how many addresses in a row must be empty before a wallet
	// decides it reached its own end. Twenty is the usual choice.
	gapLimit = 20
	// discoveryTTL is how long one walk holds. A refresh reads the addresses
	// several times, and the set changes only when a new one takes a coin.
	discoveryTTL = 30 * time.Second
)

// Discovery names the addresses a wallet actually uses.
//
// It walks the derived keys in order and stops after gapLimit addresses in a
// row that never received a coin. A wallet that used more than the first few
// keys is found in full, and a fresh wallet costs gapLimit requests rather
// than one for every key it could ever hold.
type Discovery struct {
	window *Window
	client *sidechainesplora.Client

	mu         sync.Mutex
	cached     []Address
	generation uint64
	read       time.Time
}

// NewDiscovery walks one window through one index.
func NewDiscovery(window *Window, client *sidechainesplora.Client) *Discovery {
	return &Discovery{window: window, client: client}
}

// Addresses walks the derived keys and answers the ones the wallet reaches.
func (d *Discovery) Addresses(ctx context.Context) ([]Address, error) {
	generation, err := d.window.Generation()
	if err != nil {
		return nil, err
	}

	d.mu.Lock()
	if d.cached != nil && d.generation == generation && time.Since(d.read) < discoveryTTL {
		out := d.cached
		d.mu.Unlock()
		return out, nil
	}
	d.mu.Unlock()

	lastUsed := -1
	var out []Address
	for index := uint32(0); index < d.window.Limit(); index++ {
		if int(index)-lastUsed > gapLimit {
			break
		}
		address, err := d.window.At(index)
		if err != nil {
			return nil, err
		}
		out = append(out, address)
		used, err := d.used(ctx, address)
		if err != nil {
			return nil, err
		}
		if used {
			lastUsed = int(index)
		}
	}

	d.mu.Lock()
	d.cached = out
	d.generation = generation
	d.read = time.Now()
	d.mu.Unlock()
	return out, nil
}

// Unused returns an address that received nothing. skip says how many such
// addresses to pass over first.
func (d *Discovery) Unused(ctx context.Context, skip int) (Address, error) {
	for index := uint32(0); index < d.window.Limit(); index++ {
		address, err := d.window.At(index)
		if err != nil {
			return Address{}, err
		}
		used, err := d.used(ctx, address)
		if err != nil {
			return Address{}, err
		}
		if used {
			continue
		}
		if skip > 0 {
			skip--
			continue
		}
		return address, nil
	}
	return Address{}, fmt.Errorf(
		"the wallet used every one of its %d addresses", d.window.Limit())
}

// used says whether an address ever took a coin. A spent address counts, so a
// wallet that emptied its first keys still reads the ones after them.
//
// A coin that is broadcast but not yet mined counts too. Reusing that address
// would link the payments together.
func (d *Discovery) used(ctx context.Context, address Address) (bool, error) {
	stats, err := d.client.AddressStats(ctx, address.String())
	if err != nil {
		return false, fmt.Errorf("read %s: %w", address, err)
	}
	if stats.ChainStats.FundedTxoCount > 0 || stats.MempoolStats.FundedTxoCount > 0 {
		return true, nil
	}
	deposits, err := d.client.AddressDeposits(ctx, address.String())
	if err != nil {
		return false, fmt.Errorf("read deposits for %s: %w", address, err)
	}
	return len(deposits) > 0, nil
}
