package thunder

import (
	"bytes"
	"context"
	"fmt"
	"sync"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunderwallet"
)

// lightAddressWindow is how many addresses a light wallet can derive. Gap
// discovery decides how many of them it reads, so this is only the ceiling: a
// wallet that ran a node first may sit well past the first few keys.
const lightAddressWindow = 500

// Seed answers with the BIP39 seed the thunder wallet derives its keys from.
type Seed func() ([]byte, error)

// derivedAddresses derives the wallet addresses from the seed. Light mode runs
// no node, so it cannot ask one for its own addresses.
type derivedAddresses struct {
	seed  Seed
	count uint32

	mu         sync.Mutex
	cachedSeed []byte
	cached     []string
	ring       *thunderwallet.MemoryKeyring
}

func newDerivedAddresses(seed Seed, count uint32) *derivedAddresses {
	return &derivedAddresses{seed: seed, count: count}
}

// Addresses derives the window once per seed. A new seed names a new wallet,
// so the addresses are derived again.
func (d *derivedAddresses) Addresses(_ context.Context) ([]string, error) {
	seed, err := d.seed()
	if err != nil {
		return nil, fmt.Errorf("read the wallet seed: %w", err)
	}

	d.mu.Lock()
	defer d.mu.Unlock()
	if d.cached != nil && bytes.Equal(d.cachedSeed, seed) {
		return d.cached, nil
	}

	if _, err := d.deriveLocked(seed); err != nil {
		return nil, err
	}
	return d.cached, nil
}

// Keyring holds the keys of the derived window. A light wallet signs with it.
func (d *derivedAddresses) Keyring() (*thunderwallet.MemoryKeyring, error) {
	seed, err := d.seed()
	if err != nil {
		return nil, fmt.Errorf("read the wallet seed: %w", err)
	}

	d.mu.Lock()
	defer d.mu.Unlock()
	if d.ring != nil && bytes.Equal(d.cachedSeed, seed) {
		return d.ring, nil
	}
	return d.deriveLocked(seed)
}

// deriveLocked builds the window for one seed. The caller holds the lock.
func (d *derivedAddresses) deriveLocked(seed []byte) (*thunderwallet.MemoryKeyring, error) {
	ring, err := thunderwallet.DeriveKeyring(seed, d.count)
	if err != nil {
		return nil, fmt.Errorf("derive the wallet keys: %w", err)
	}

	addresses := make([]string, 0, d.count)
	for _, address := range ring.Addresses() {
		addresses = append(addresses, address.String())
	}
	d.cachedSeed = seed
	d.cached = addresses
	d.ring = ring
	return ring, nil
}

var _ LightKeys = (*derivedAddresses)(nil)
