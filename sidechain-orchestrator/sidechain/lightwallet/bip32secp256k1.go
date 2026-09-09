package lightwallet

import (
	"fmt"

	"github.com/tyler-smith/go-bip32"
)

// Bip32Secp256k1Key derives the private key one BIP32 path names, over
// secp256k1. Two of these chains read that key as the seed of another key
// type, so the caller decides what the bytes become.
func Bip32Secp256k1Key(seed []byte, path []uint32) ([]byte, error) {
	if len(seed) == 0 {
		return nil, fmt.Errorf("the seed is empty")
	}
	key, err := bip32.NewMasterKey(seed)
	if err != nil {
		return nil, fmt.Errorf("build the master key: %w", err)
	}
	for _, index := range path {
		key, err = key.NewChildKey(index)
		if err != nil {
			return nil, fmt.Errorf("derive child %d: %w", index, err)
		}
	}
	return key.Key, nil
}
