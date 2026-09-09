package coinshift

import (
	"testing"

	bip39 "github.com/tyler-smith/go-bip39"
)

// testMnemonic is the BIP39 test vector.
const testMnemonic = "abandon abandon abandon abandon abandon abandon " +
	"abandon abandon abandon abandon abandon about"

// These addresses come from the derivation the coinshift node runs, over the
// mnemonic above. A wrong derivation writes a deposit to an address the node
// does not know, and nothing else shows the fault.
func TestDeriveMatchesTheNode(t *testing.T) {
	want := map[uint32]string{
		0: "38VvRdmcQREr1UAcZma98WLFVpAp",
		1: "k81Deknpsx5Zi6WxUkeMQYrohvt",
		2: "23xexovKLYvj8qWhpNBEo828eWQS",
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
