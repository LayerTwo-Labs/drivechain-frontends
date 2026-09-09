package photon

import (
	"encoding/hex"
	"testing"

	bip39 "github.com/tyler-smith/go-bip39"
)

// testMnemonic is the BIP39 test vector.
const testMnemonic = "abandon abandon abandon abandon abandon abandon " +
	"abandon abandon abandon abandon abandon about"

// These addresses come from the derivation the photon node runs, over the
// mnemonic above. A wrong derivation writes a deposit to an address the node
// does not know, and nothing else shows the fault.
func TestDeriveMatchesTheNode(t *testing.T) {
	want := map[uint32]string{
		0: "35XpDukLaoW75h6ywAabTQDn6mvg",
		1: "4WAmJim5HWRbAFhJcB7tjsMymk6h",
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

// The address hashes the SLH-DSA public key, so the key itself must match the
// node byte for byte.
func TestPublicKeyMatchesTheNode(t *testing.T) {
	const want = "f01def4f3ecdd47faa5bd905571fd1bd20d593a38d8b1dc07852df444e1b8ac1" +
		"fe2375fa017aced5dbe2928d150595f39b9e2b01b25b74a2114b899bed2d16db"

	seeds, err := keySeeds(bip39.NewSeed(testMnemonic, ""), 0)
	if err != nil {
		t.Fatalf("derive the key seeds: %v", err)
	}
	got := hex.EncodeToString(slhPublicKey(seeds[:slhN], seeds[2*slhN:]))
	if got != want {
		t.Errorf("public key = %s, want %s", got, want)
	}
}

// A different index derives a different address, or every deposit would land
// on one key.
func TestDeriveIsPerIndex(t *testing.T) {
	seed := bip39.NewSeed(testMnemonic, "")
	first, err := deriveAddress(seed, 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	second, err := deriveAddress(seed, 1)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	if first == second {
		t.Error("two indexes derive the same address")
	}
}

func TestDeriveRejectsAnEmptySeed(t *testing.T) {
	if _, err := deriveAddress(nil, 0); err == nil {
		t.Fatal("want an error for an empty seed, got none")
	}
}
