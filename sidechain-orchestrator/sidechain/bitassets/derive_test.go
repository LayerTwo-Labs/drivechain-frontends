package bitassets

import (
	"testing"

	bip39 "github.com/tyler-smith/go-bip39"
)

// testMnemonic is the BIP39 test vector.
const testMnemonic = "abandon abandon abandon abandon abandon abandon " +
	"abandon abandon abandon abandon abandon about"

// A scratch bitassets node on regtest, over the BIP39 test mnemonic above,
// answers get_new_address with these three addresses. A wrong derivation
// writes a deposit to an address the node does not watch, and nothing shows it.
func TestDeriveMatchesTheNode(t *testing.T) {
	want := map[uint32]string{
		0: "2ynmtLyBPcYLJgn8PiUWFHkRmYky",
		1: "4GcksoeY2SnXarj6KWwy4zh6Jvds",
		2: "3AZCBo7Z9tvAeupctUsdioFoQnP5",
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
