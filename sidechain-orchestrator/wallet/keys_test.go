package wallet

import (
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/tyler-smith/go-bip39"
)

// BIP84 official test vectors: the "abandon ... about" mnemonic and its
// first two mainnet receive addresses (m/84'/0'/0'/0/0 and /0/1).
func TestDeriveBIP84Addresses(t *testing.T) {
	seed := bip39.NewSeed(
		"abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
		"",
	)

	addrs, err := DeriveBIP84Addresses(hex.EncodeToString(seed), &chaincfg.MainNetParams, 0, 2)
	if err != nil {
		t.Fatalf("DeriveBIP84Addresses: %v", err)
	}

	want := []string{
		"bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu",
		"bc1qnjg0jd8228aq7egyzacy8cys3knf9xvrerkf9g",
	}
	for i, w := range want {
		if addrs[i] != w {
			t.Errorf("address %d = %s, want %s", i, addrs[i], w)
		}
	}
}

func TestDeriveBIP84AddressesStartOffset(t *testing.T) {
	seed := bip39.NewSeed(
		"abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
		"",
	)
	seedHex := hex.EncodeToString(seed)

	first, err := DeriveBIP84Addresses(seedHex, &chaincfg.MainNetParams, 0, 3)
	if err != nil {
		t.Fatalf("derive 0..2: %v", err)
	}
	offset, err := DeriveBIP84Addresses(seedHex, &chaincfg.MainNetParams, 2, 1)
	if err != nil {
		t.Fatalf("derive 2..2: %v", err)
	}
	if offset[0] != first[2] {
		t.Errorf("offset derivation mismatch: %s != %s", offset[0], first[2])
	}
}
