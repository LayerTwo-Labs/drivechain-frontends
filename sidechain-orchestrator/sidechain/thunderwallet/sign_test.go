package thunderwallet

import (
	"crypto/ed25519"
	"errors"
	"testing"
)

func testKey(t *testing.T, seed byte) ed25519.PrivateKey {
	t.Helper()
	raw := make([]byte, ed25519.SeedSize)
	for i := range raw {
		raw[i] = seed
	}
	return ed25519.NewKeyFromSeed(raw)
}

func valueOutput(address Address, sats uint64) Output {
	return Output{Address: address, Content: Content{Value: &sats}}
}

// Every input carries its own signature, and the same bytes get signed once
// per input. The node counts them and rejects any other number.
func TestSignOnePerInput(t *testing.T) {
	key := testKey(t, 1)
	ring := NewMemoryKeyring(key)
	address := ring.Addresses()[0]

	tx := Transaction{
		Inputs: []Input{
			{OutPoint: OutPoint{Kind: KindRegular, Vout: 0}},
			{OutPoint: OutPoint{Kind: KindRegular, Vout: 1}},
		},
		Outputs: []Output{valueOutput(address, 500)},
	}

	signed, err := Sign(tx, []Address{address, address}, ring)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	if len(signed.Authorizations) != 2 {
		t.Fatalf("got %d signatures for 2 inputs", len(signed.Authorizations))
	}
	if err := Verify(signed); err != nil {
		t.Errorf("verify: %v", err)
	}
}

// A wallet that cannot open a coin says so, rather than sending a transaction
// the node refuses.
func TestSignWithoutTheKey(t *testing.T) {
	ring := NewMemoryKeyring(testKey(t, 1))
	stranger := AddressForKey(testKey(t, 9).Public().(ed25519.PublicKey))

	tx := Transaction{Inputs: []Input{{}}}
	_, err := Sign(tx, []Address{stranger}, ring)
	if !errors.Is(err, ErrNoKeyForAddress) {
		t.Fatalf("error = %v, want ErrNoKeyForAddress", err)
	}
}

func TestSignRejectsAnOwnerCountMismatch(t *testing.T) {
	ring := NewMemoryKeyring(testKey(t, 1))
	tx := Transaction{Inputs: []Input{{}, {}}}
	if _, err := Sign(tx, []Address{ring.Addresses()[0]}, ring); err == nil {
		t.Fatal("want an error for one owner and two inputs, got none")
	}
}

// A changed transaction invalidates every signature, because each one covers
// the whole encoding.
func TestVerifyCatchesAChangedTransaction(t *testing.T) {
	key := testKey(t, 3)
	ring := NewMemoryKeyring(key)
	address := ring.Addresses()[0]

	tx := Transaction{
		Inputs:  []Input{{OutPoint: OutPoint{Kind: KindRegular}}},
		Outputs: []Output{valueOutput(address, 1000)},
	}
	signed, err := Sign(tx, []Address{address}, ring)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}

	changed := uint64(999999)
	signed.Transaction.Outputs[0].Content.Value = &changed
	if err := Verify(signed); err == nil {
		t.Fatal("want a verify failure after the amount changed, got none")
	}
}

// An address is a blake3 extendable output over the key, read 20 bytes wide.
// A wrong derivation sends coins to an address nobody owns.
func TestAddressForKeyIsStable(t *testing.T) {
	key := testKey(t, 7)
	first := AddressForKey(key.Public().(ed25519.PublicKey))
	second := AddressForKey(key.Public().(ed25519.PublicKey))
	if first != second {
		t.Fatalf("derivation is not stable: %s then %s", first, second)
	}

	parsed, err := ParseAddress(first.String())
	if err != nil {
		t.Fatalf("parse %s: %v", first, err)
	}
	if parsed != first {
		t.Errorf("round trip = %s, want %s", parsed, first)
	}

	other := AddressForKey(testKey(t, 8).Public().(ed25519.PublicKey))
	if other == first {
		t.Error("two keys derive the same address")
	}
}

// A wallet picks its receive address by position, so the keyring must answer
// in derivation order and not in a map order.
func TestKeyringKeepsDerivationOrder(t *testing.T) {
	seed := make([]byte, 32)
	for i := range seed {
		seed[i] = byte(i)
	}
	ring, err := DeriveKeyring(seed, 8)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}

	want := make([]Address, 8)
	for i := range want {
		key, err := DeriveKey(seed, uint32(i))
		if err != nil {
			t.Fatalf("derive key %d: %v", i, err)
		}
		want[i] = AddressForKey(key.Public().(ed25519.PublicKey))
	}

	for round := 0; round < 5; round++ {
		got := ring.Addresses()
		for i := range want {
			if got[i] != want[i] {
				t.Fatalf("address %d = %s, want %s", i, got[i], want[i])
			}
		}
	}
}
