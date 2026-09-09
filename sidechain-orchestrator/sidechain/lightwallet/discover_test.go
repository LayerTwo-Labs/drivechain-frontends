package lightwallet

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// expire drops the cached walk without moving the seed, which is what the TTL
// does between two balance polls.
func expire(d *Discovery) {
	d.mu.Lock()
	d.read = time.Time{}
	d.mu.Unlock()
}

// The first walk of a seed reads the whole window, so a wallet that ran a node
// first finds its later coins. Every walk after it reads what the first one
// reached, or a balance poll would spend the whole window on every refresh.
func TestDiscoveryReadsTheWholeWindowOnlyOnce(t *testing.T) {
	index := newFakeIndex(t)
	index.deposit(testAddress(t, 2*gapLimit).String(), depositTxid, 7000, true)

	window := testWallet(testSeed)
	discovery := NewDiscovery(window, sidechainesplora.New(index.server.URL))

	first, err := discovery.Addresses(context.Background())
	if err != nil {
		t.Fatalf("addresses: %v", err)
	}
	if got, want := index.reads(), int(window.Limit()); got != want {
		t.Errorf("the first walk read %d addresses, want the whole window of %d", got, want)
	}
	if want := 2*gapLimit + 1 + gapLimit; len(first) != want {
		t.Fatalf("the wallet holds %d addresses, want %d", len(first), want)
	}

	expire(discovery)
	second, err := discovery.Addresses(context.Background())
	if err != nil {
		t.Fatalf("addresses: %v", err)
	}
	if got := index.reads(); got != len(first) {
		t.Errorf("the second walk read %d addresses, want the %d it reached", got, len(first))
	}
	if len(second) != len(first) {
		t.Errorf("the wallet holds %d addresses, want the %d it held", len(second), len(first))
	}
}

// A coin on the last address the wallet reached moves its end, so the next
// walk holds one whole gap after it again.
func TestDiscoveryGrowsWhenTheLastAddressTakesACoin(t *testing.T) {
	index := newFakeIndex(t)
	window := testWallet(testSeed)
	discovery := NewDiscovery(window, sidechainesplora.New(index.server.URL))

	first, err := discovery.Addresses(context.Background())
	if err != nil {
		t.Fatalf("addresses: %v", err)
	}
	if len(first) != gapLimit {
		t.Fatalf("a fresh wallet holds %d addresses, want %d", len(first), gapLimit)
	}

	last := uint32(len(first) - 1)
	index.deposit(testAddress(t, last).String(), depositTxid, 7000, true)
	expire(discovery)

	second, err := discovery.Addresses(context.Background())
	if err != nil {
		t.Fatalf("addresses: %v", err)
	}
	if want := int(last) + 1 + gapLimit; len(second) != want {
		t.Errorf("the wallet holds %d addresses, want %d", len(second), want)
	}
}

// A restore names another wallet, so the walk must read the whole window again
// rather than trust what the seed before it reached.
func TestDiscoveryReadsTheWholeWindowAgainAfterARestore(t *testing.T) {
	index := newFakeIndex(t)
	seed := testSeed
	window := NewWindow(func() ([]byte, error) { return seed, nil }, testDerive, AddressWindow)
	discovery := NewDiscovery(window, sidechainesplora.New(index.server.URL))

	if _, err := discovery.Addresses(context.Background()); err != nil {
		t.Fatalf("addresses: %v", err)
	}
	index.reads()

	seed = []byte("another wallet seed, of a restore that named another wallet")
	expire(discovery)
	if _, err := discovery.Addresses(context.Background()); err != nil {
		t.Fatalf("addresses: %v", err)
	}
	if got, want := index.reads(), int(window.Limit()); got != want {
		t.Errorf("the walk read %d addresses, want the whole window of %d", got, want)
	}
}
