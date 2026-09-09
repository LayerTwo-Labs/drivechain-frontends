package bitassets

import (
	"crypto/ed25519"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/lightwallet"
)

// deriveAddress answers the address the bitassets wallet holds at one index.
//
// The node derives m/0'/index over secp256k1 and reads the child key as an
// ed25519 seed. The index is not hardened, which is what the node does.
func deriveAddress(seed []byte, index uint32) (lightwallet.Address, error) {
	if index >= lightwallet.Hardened {
		return lightwallet.Address{}, fmt.Errorf("index %d is past the soft range", index)
	}
	secret, err := lightwallet.Bip32Secp256k1Key(seed, []uint32{lightwallet.Hardened, index})
	if err != nil {
		return lightwallet.Address{}, err
	}
	if len(secret) != ed25519.SeedSize {
		return lightwallet.Address{}, fmt.Errorf(
			"the child key is %d bytes, want %d", len(secret), ed25519.SeedSize)
	}
	public := ed25519.NewKeyFromSeed(secret).Public().(ed25519.PublicKey)
	return lightwallet.AddressForKey(public), nil
}
