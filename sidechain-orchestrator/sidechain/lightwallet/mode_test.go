package lightwallet

import (
	"context"
	"testing"
)

func testChain() Chain {
	return Chain{
		Seed:   func() ([]byte, error) { return testSeed, nil },
		Derive: testDerive,
		Output: OutputShape{ValueKey: ValueKeyValue},
	}
}

// A local node issues and funds addresses while it runs. A wallet that comes
// back to the index must build a new backend, because the one before it walked
// its window and would read none of what the node did.
func TestWalletDropsTheBackendWhileANodeRuns(t *testing.T) {
	index := newFakeIndex(t)
	light := true
	wallet := NewWallet(
		func() Mode { return NewMode(light, index.server.URL) }, testChain())

	first := wallet.Backend()
	if first == nil {
		t.Fatal("light mode reads no index")
	}
	if wallet.Backend() != first {
		t.Error("one light session builds more than one backend")
	}

	light = false
	if wallet.Backend() != nil {
		t.Fatal("a chain with a local node still reads the index")
	}

	light = true
	second := wallet.Backend()
	if second == nil {
		t.Fatal("light mode reads no index after the node stops")
	}
	if second == first {
		t.Error("the wallet kept the backend the node ran behind")
	}
}

// The whole point of the new backend: a coin the node took past the walk the
// light wallet already made must still count.
func TestWalletReadsACoinTheNodeTookPastTheOldWalk(t *testing.T) {
	index := newFakeIndex(t)
	light := true
	wallet := NewWallet(
		func() Mode { return NewMode(light, index.server.URL) }, testChain())

	total, _, err := wallet.Backend().Balance(context.Background())
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if total != 0 {
		t.Fatalf("a fresh wallet holds %d sats, want 0", total)
	}

	// The node runs, and it funds an address far past what the walk reached.
	light = false
	wallet.Backend()
	index.deposit(testAddress(t, 3*gapLimit).String(), depositTxid, 7000, true)

	light = true
	total, available, err := wallet.Backend().Balance(context.Background())
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if total != 7000 || available != 7000 {
		t.Errorf("balance = %d total and %d available, want 7000 of each", total, available)
	}
}
