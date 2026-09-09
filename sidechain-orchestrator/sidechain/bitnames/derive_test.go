package bitnames

import (
	"testing"

	bip39 "github.com/tyler-smith/go-bip39"
)

// testMnemonic is the BIP39 test vector.
const testMnemonic = "abandon abandon abandon abandon abandon abandon " +
	"abandon abandon abandon abandon abandon about"

// A scratch bitnames node on regtest, over the BIP39 test mnemonic above,
// answers get_new_address with these three addresses. A wrong derivation
// writes a deposit to an address the node does not watch, and nothing shows it.
func TestDeriveMatchesTheNode(t *testing.T) {
	want := map[uint32]string{
		0: "2HiuRi3EisjqPfsM6DVa4S3gkEVe",
		1: "oQYeM3SKuJs1or8414W57MrpJqn",
		2: "TXkb8G7pXY8NnETKroYzwP64xim",
	}

	seed := bip39.NewSeed(testMnemonic, "")
	for index, address := range want {
		got, err := deriveAddress(seed, index)
		if err != nil {
			t.Fatalf("derive %d: %v", index, err)
		}
		if got.String() != address {
			t.Errorf("index %d = %s, want %s", index, got, address)
		}
	}
}

// A different seed derives a different wallet.
func TestDeriveIsPerSeed(t *testing.T) {
	mine, err := deriveAddress(bip39.NewSeed(testMnemonic, ""), 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	other, err := deriveAddress(bip39.NewSeed(testMnemonic, "passphrase"), 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	if mine == other {
		t.Error("a passphrase changes nothing")
	}
}

func TestDeriveRejectsAnEmptySeed(t *testing.T) {
	if _, err := deriveAddress(nil, 0); err == nil {
		t.Fatal("want an error for an empty seed, got none")
	}
}
