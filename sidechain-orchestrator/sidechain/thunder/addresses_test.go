package thunder

import (
	"context"
	"testing"

	bip39 "github.com/tyler-smith/go-bip39"
)

// A user who switches the active wallet gets a new seed. The addresses must
// follow it, and must not answer from the wallet that came before.
func TestDerivedAddressesFollowTheSeed(t *testing.T) {
	first := bip39.NewSeed("abandon abandon abandon abandon abandon abandon "+
		"abandon abandon abandon abandon abandon about", "")
	second := bip39.NewSeed("legal winner thank year wave sausage worth "+
		"useful legal winner thank yellow", "")

	seed := first
	calls := 0
	source := newDerivedAddresses(func() ([]byte, error) {
		calls++
		return seed, nil
	}, 2)

	before, err := source.Addresses(context.Background())
	if err != nil {
		t.Fatalf("derive: %v", err)
	}

	again, err := source.Addresses(context.Background())
	if err != nil {
		t.Fatalf("derive again: %v", err)
	}
	if again[0] != before[0] {
		t.Errorf("one seed derived two answers: %q then %q", before[0], again[0])
	}

	seed = second
	after, err := source.Addresses(context.Background())
	if err != nil {
		t.Fatalf("derive after the switch: %v", err)
	}
	if after[0] == before[0] {
		t.Errorf("the second wallet kept the first wallet's address %q", after[0])
	}
	if calls != 3 {
		t.Errorf("read the seed %d times, want 3", calls)
	}
}
