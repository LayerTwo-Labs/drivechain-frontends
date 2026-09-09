package lightwallet

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

const (
	// gapLimit is how many unused addresses a wallet holds ready after the
	// last one that took a coin. Twenty is the usual choice.
	gapLimit = 20
	// discoveryTTL is how long one walk holds. A refresh reads the addresses
	// several times, and the set changes only when a new one takes a coin.
	discoveryTTL = 30 * time.Second
	// scanAhead is how many addresses one walk reads at the same time. The
	// first walk of a seed reads the whole window, and a narrower walk would
	// outlast the balance timeout the frontend holds.
	scanAhead = 32
)

// Discovery names the addresses a wallet actually uses.
//
// The first walk of a seed reads every key of the window, because a wallet that
// ran a node first may hold a funded address after a long run of addresses the
// node issued and nobody paid. It answers each key up to the last one that took
// a coin, and gapLimit more after it for a receive page to hand out.
type Discovery struct {
	window *Window
	client *sidechainesplora.Client

	mu         sync.Mutex
	cached     []Address
	generation uint64
	read       time.Time
	// scanned names the seed whose whole window this discovery already walked.
	scanned uint64
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
	cached, held, scanned := d.cached, d.generation, d.scanned
	if cached != nil && held == generation && time.Since(d.read) < discoveryTTL {
		d.mu.Unlock()
		return cached, nil
	}
	d.mu.Unlock()

	// Only the first walk of a seed reads the whole window. After it the wallet
	// hands out its own addresses, and Unused never reaches past the gap, so a
	// refresh reads what the walk already reached.
	count := d.window.Limit()
	if cached != nil && held == generation && scanned == generation {
		count = uint32(len(cached))
	}

	used, err := d.usedWindow(ctx, count)
	if err != nil {
		return nil, err
	}
	lastUsed := -1
	for index, took := range used {
		if took {
			lastUsed = index
		}
	}
	reach := min(uint32(lastUsed+1+gapLimit), d.window.Limit())

	out := make([]Address, 0, reach)
	for index := uint32(0); index < reach; index++ {
		address, err := d.window.At(index)
		if err != nil {
			return nil, err
		}
		out = append(out, address)
	}

	d.mu.Lock()
	d.cached = out
	d.generation = generation
	d.scanned = generation
	d.read = time.Now()
	d.mu.Unlock()
	return out, nil
}

// usedWindow reads the first count keys and says which ones took a coin.
func (d *Discovery) usedWindow(ctx context.Context, count uint32) ([]bool, error) {
	addresses := make([]Address, count)
	for index := range addresses {
		address, err := d.window.At(uint32(index))
		if err != nil {
			return nil, err
		}
		addresses[index] = address
	}

	used := make([]bool, len(addresses))
	errs := make([]error, len(addresses))
	var wg sync.WaitGroup
	limit := make(chan struct{}, scanAhead)
	for at, address := range addresses {
		wg.Add(1)
		limit <- struct{}{}
		go func() {
			defer wg.Done()
			defer func() { <-limit }()
			used[at], errs[at] = d.used(ctx, address)
		}()
	}
	wg.Wait()

	for _, err := range errs {
		if err != nil {
			return nil, err
		}
	}
	return used, nil
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
