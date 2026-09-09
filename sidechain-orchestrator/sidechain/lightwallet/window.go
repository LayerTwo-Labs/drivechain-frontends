package lightwallet

import (
	"bytes"
	"fmt"
	"sync"
)

// Seed answers with the BIP39 seed a chain derives its wallet keys from.
type Seed func() ([]byte, error)

// Deriver answers the address one seed holds at one index. Each chain names
// its own, because the derivation path and the key type are the chain's own.
type Deriver func(seed []byte, index uint32) (Address, error)

// Window holds the addresses one seed reaches. It derives an address once and
// keeps it, because a post-quantum key costs a great deal to derive.
type Window struct {
	seed   Seed
	derive Deriver
	limit  uint32

	mu sync.Mutex
	// generation counts the seeds this window saw. A restore hands back
	// another wallet, and everything derived from the one before it is stale.
	generation uint64
	held       []byte
	cached     map[uint32]Address
}

// NewWindow derives up to limit addresses of one seed.
func NewWindow(seed Seed, derive Deriver, limit uint32) *Window {
	return &Window{seed: seed, derive: derive, limit: limit}
}

// Limit is how many addresses this window can derive.
func (w *Window) Limit() uint32 { return w.limit }

// Generation names the wallet this window holds. It moves when the seed does.
func (w *Window) Generation() (uint64, error) {
	w.mu.Lock()
	defer w.mu.Unlock()
	if err := w.resolveLocked(); err != nil {
		return 0, err
	}
	return w.generation, nil
}

// At derives the address of one index.
func (w *Window) At(index uint32) (Address, error) {
	if index >= w.limit {
		return Address{}, fmt.Errorf("index %d is past the window of %d", index, w.limit)
	}
	w.mu.Lock()
	defer w.mu.Unlock()
	if err := w.resolveLocked(); err != nil {
		return Address{}, err
	}
	if address, held := w.cached[index]; held {
		return address, nil
	}
	address, err := w.derive(w.held, index)
	if err != nil {
		return Address{}, fmt.Errorf("derive address %d: %w", index, err)
	}
	w.cached[index] = address
	return address, nil
}

// resolveLocked reads the seed and drops what another seed derived. The caller
// holds the lock.
func (w *Window) resolveLocked() error {
	seed, err := w.seed()
	if err != nil {
		return fmt.Errorf("read the wallet seed: %w", err)
	}
	if len(seed) == 0 {
		return fmt.Errorf("the wallet holds no seed")
	}
	if w.cached != nil && bytes.Equal(w.held, seed) {
		return nil
	}
	w.held = seed
	w.cached = map[uint32]Address{}
	w.generation++
	return nil
}
