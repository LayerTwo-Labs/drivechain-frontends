package thunder

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

// discoveredAddresses names the addresses a wallet actually uses.
//
// It walks the derived keys in order and stops after gapLimit addresses in a
// row that never received a coin. A wallet that used more than the first few
// keys is found in full, and a fresh wallet costs gapLimit requests rather
// than one for every key it could ever hold.
type discoveredAddresses struct {
	keys   AddressSource
	client *sidechainesplora.Client

	mu     sync.Mutex
	cached []string
	read   time.Time
}

func newDiscoveredAddresses(keys AddressSource, client *sidechainesplora.Client) *discoveredAddresses {
	return &discoveredAddresses{keys: keys, client: client}
}

// Forget drops the walk. A restore hands back another wallet, and the
// addresses of the one before it name none of its coins.
func (d *discoveredAddresses) Forget() {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.cached = nil
}

// Addresses walks the derived keys and answers the ones the wallet reaches.
func (d *discoveredAddresses) Addresses(ctx context.Context) ([]string, error) {
	d.mu.Lock()
	if d.cached != nil && time.Since(d.read) < discoveryTTL {
		out := d.cached
		d.mu.Unlock()
		return out, nil
	}
	d.mu.Unlock()

	derived, err := d.keys.Addresses(ctx)
	if err != nil {
		return nil, err
	}

	lastUsed := -1
	for i, address := range derived {
		if i-lastUsed > gapLimit {
			break
		}
		used, err := d.used(ctx, address)
		if err != nil {
			return nil, err
		}
		if used {
			lastUsed = i
		}
	}

	// Keep one gap past the last used address, so the wallet still has fresh
	// addresses to receive on and to take change.
	end := lastUsed + 1 + gapLimit
	if end > len(derived) {
		end = len(derived)
	}
	out := derived[:end]

	d.mu.Lock()
	d.cached = out
	d.read = time.Now()
	d.mu.Unlock()
	return out, nil
}

// used says whether an address ever took a coin. A spent address counts, so a
// wallet that emptied its first keys still reads the ones after them.
func (d *discoveredAddresses) used(ctx context.Context, address string) (bool, error) {
	stats, err := d.client.AddressStats(ctx, address)
	if err != nil {
		return false, fmt.Errorf("read %s: %w", address, err)
	}
	if stats.ChainStats.FundedTxoCount > 0 || stats.MempoolStats.FundedTxoCount > 0 {
		return true, nil
	}
	deposits, err := d.client.AddressDeposits(ctx, address)
	if err != nil {
		return false, fmt.Errorf("read deposits for %s: %w", address, err)
	}
	return len(deposits) > 0, nil
}

var _ AddressSource = (*discoveredAddresses)(nil)
