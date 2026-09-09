package lightwallet

import (
	"fmt"
	"sync/atomic"
	"testing"
)

// A post-quantum key costs a great deal to derive, so one index derives one
// time.
func TestWindowDerivesEachIndexOnce(t *testing.T) {
	var derived atomic.Int64
	window := NewWindow(
		func() ([]byte, error) { return testSeed, nil },
		func(seed []byte, index uint32) (Address, error) {
			derived.Add(1)
			return testDerive(seed, index)
		},
		AddressWindow,
	)

	for range 3 {
		if _, err := window.At(0); err != nil {
			t.Fatalf("at 0: %v", err)
		}
	}
	if _, err := window.At(1); err != nil {
		t.Fatalf("at 1: %v", err)
	}
	if got := derived.Load(); got != 2 {
		t.Errorf("the window derived %d times, want 2", got)
	}
}

// A restore hands back another wallet. The addresses of the one before it name
// none of its coins, so the window must derive again.
func TestWindowFollowsANewSeed(t *testing.T) {
	seed := testSeed
	window := NewWindow(func() ([]byte, error) { return seed, nil }, testDerive, AddressWindow)

	first, err := window.At(0)
	if err != nil {
		t.Fatalf("at 0: %v", err)
	}
	generation, err := window.Generation()
	if err != nil {
		t.Fatalf("generation: %v", err)
	}

	seed = []byte("another wallet seed, of a restore that named another wallet")
	second, err := window.At(0)
	if err != nil {
		t.Fatalf("at 0: %v", err)
	}
	if first == second {
		t.Error("a new seed derives the address of the old wallet")
	}
	next, err := window.Generation()
	if err != nil {
		t.Fatalf("generation: %v", err)
	}
	if next == generation {
		t.Error("the generation held over a new seed")
	}
}

// A wallet with no seed reads no addresses, and it must say so rather than
// answer the addresses of an empty seed.
func TestWindowRefusesAnEmptySeed(t *testing.T) {
	window := NewWindow(func() ([]byte, error) { return nil, nil }, testDerive, AddressWindow)
	if _, err := window.At(0); err == nil {
		t.Fatal("want an error for an empty seed, got none")
	}

	window = NewWindow(
		func() ([]byte, error) { return nil, fmt.Errorf("the wallet is locked") },
		testDerive, AddressWindow)
	if _, err := window.At(0); err == nil {
		t.Fatal("want the seed error, got none")
	}
}

func TestWindowRefusesAnIndexPastItsEnd(t *testing.T) {
	window := testWallet(testSeed)
	if _, err := window.At(AddressWindow); err == nil {
		t.Fatal("want an error past the window, got none")
	}
}
