package thunderwallet

import (
	"crypto/ed25519"
	"testing"

	bip39 "github.com/tyler-smith/go-bip39"
)

// testMnemonic is the BIP39 test vector.
const testMnemonic = "abandon abandon abandon abandon abandon abandon " +
	"abandon abandon abandon abandon abandon about"

// These addresses come from a real thunder node, seeded with the mnemonic
// above. A wrong derivation writes coins to an address the node does not know,
// and nothing else shows the fault.
//
// The node's get_new_address starts at index 1, so its first two addresses are
// index 1 and index 2 here.
func TestDeriveMatchesTheNode(t *testing.T) {
	want := map[uint32]string{
		0: "38VvRdmcQREr1UAcZma98WLFVpAp",
		1: "k81Deknpsx5Zi6WxUkeMQYrohvt",
		2: "23xexovKLYvj8qWhpNBEo828eWQS",
	}

	seed := bip39.NewSeed(testMnemonic, "")
	for index, address := range want {
		key, err := DeriveKey(seed, index)
		if err != nil {
			t.Fatalf("derive %d: %v", index, err)
		}
		got := AddressForKey(key.Public().(ed25519.PublicKey))
		if got.String() != address {
			t.Errorf("index %d = %s, want %s", index, got, address)
		}
	}
}

// A different index derives a different key, or every address would collide.
func TestDeriveIsPerIndex(t *testing.T) {
	seed := bip39.NewSeed(testMnemonic, "")
	first, err := DeriveKey(seed, 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	second, err := DeriveKey(seed, 1)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	if first.Equal(second) {
		t.Error("two indexes derive the same key")
	}
}

// A different seed derives a different wallet.
func TestDeriveIsPerSeed(t *testing.T) {
	mine, err := DeriveKey(bip39.NewSeed(testMnemonic, ""), 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	other, err := DeriveKey(bip39.NewSeed(testMnemonic, "passphrase"), 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	if mine.Equal(other) {
		t.Error("a passphrase changes nothing")
	}
}

func TestDeriveRejectsAnEmptySeed(t *testing.T) {
	if _, err := DeriveKey(nil, 0); err == nil {
		t.Fatal("want an error for an empty seed, got none")
	}
}

// A keyring covers a run of indexes, which is what a wallet with no node needs
// to know its own addresses.
func TestDeriveKeyring(t *testing.T) {
	ring, err := DeriveKeyring(bip39.NewSeed(testMnemonic, ""), 3)
	if err != nil {
		t.Fatalf("derive keyring: %v", err)
	}
	if got := len(ring.Addresses()); got != 3 {
		t.Fatalf("keyring holds %d addresses, want 3", got)
	}
	first, err := ParseAddress("38VvRdmcQREr1UAcZma98WLFVpAp")
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	if _, err := ring.SigningKey(first); err != nil {
		t.Errorf("the keyring does not hold index 0: %v", err)
	}
}
