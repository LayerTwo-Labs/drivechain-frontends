package photon

import (
	"fmt"

	"lukechampine.com/blake3"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/lightwallet"
)

// coinType is the BIP44 coin type photon derives under. The node builds it
// from the Baudot-Murray code of "PHOTON".
const coinType uint32 = 0x300c31b5

// seedBytes is what the child key expands to: the signing seed, the PRF seed,
// and the public seed of one SLH-DSA key pair.
const seedBytes = 3 * slhN

// deriveAddress answers the address the photon wallet holds at one index.
func deriveAddress(seed []byte, index uint32) (lightwallet.Address, error) {
	seeds, err := keySeeds(seed, index)
	if err != nil {
		return lightwallet.Address{}, err
	}
	// The PRF seed sits between the two, and only a signature needs it.
	return lightwallet.AddressForKey(slhPublicKey(seeds[:slhN], seeds[2*slhN:])), nil
}

// keySeeds expands one wallet index into the seeds of an SLH-DSA key pair.
//
// The node derives m/44'/coin'/0'/index' over secp256k1, then reads a blake3
// extendable output over the child key as the signing seed, the PRF seed and
// the public seed, in that order.
func keySeeds(seed []byte, index uint32) ([seedBytes]byte, error) {
	var seeds [seedBytes]byte
	secret, err := lightwallet.Bip32Secp256k1Key(seed, []uint32{
		lightwallet.Hardened + 44,
		lightwallet.Hardened + coinType,
		lightwallet.Hardened,
		lightwallet.Hardened + index,
	})
	if err != nil {
		return seeds, err
	}
	hasher := blake3.New(32, nil)
	if _, err := hasher.Write(secret); err != nil {
		return seeds, fmt.Errorf("expand the child key: %w", err)
	}
	if _, err := hasher.XOF().Read(seeds[:]); err != nil {
		return seeds, fmt.Errorf("read the key seeds: %w", err)
	}
	return seeds, nil
}
