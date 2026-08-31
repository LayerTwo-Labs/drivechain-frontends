package thunderwallet

import (
	"crypto/ed25519"
	"crypto/hmac"
	"crypto/sha512"
	"encoding/binary"
	"fmt"
)

// hardenedOffset marks a hardened child index. SLIP-0010 over ed25519 has no
// unhardened form, so every index carries it.
const hardenedOffset uint32 = 0x80000000

// slip10Curve is the key SLIP-0010 seeds its master node with for ed25519.
var slip10Curve = []byte("ed25519 seed")

// thunderPath is where thunder keeps its keys: m/1'/0'/0'/index'. Every index
// is hardened, and a different path derives a different wallet.
func thunderPath(index uint32) []uint32 {
	return []uint32{
		hardenedOffset + 1,
		hardenedOffset + 0,
		hardenedOffset + 0,
		hardenedOffset + index,
	}
}

// DeriveKey returns the thunder signing key at one index, from a BIP39 seed.
//
// The seed comes from a mnemonic with an empty passphrase, which is what
// set_seed_from_mnemonic writes. A wrong path derives an address the node does
// not know, and the coins then read as someone else's.
func DeriveKey(seed []byte, index uint32) (ed25519.PrivateKey, error) {
	if len(seed) == 0 {
		return nil, fmt.Errorf("the seed is empty")
	}

	mac := hmac.New(sha512.New, slip10Curve)
	if _, err := mac.Write(seed); err != nil {
		return nil, fmt.Errorf("seed the master node: %w", err)
	}
	sum := mac.Sum(nil)
	key, chainCode := sum[:32], sum[32:]

	for _, child := range thunderPath(index) {
		var data [37]byte
		// A hardened child hashes a zero byte, then the parent key.
		copy(data[1:33], key)
		binary.BigEndian.PutUint32(data[33:], child)

		mac := hmac.New(sha512.New, chainCode)
		if _, err := mac.Write(data[:]); err != nil {
			return nil, fmt.Errorf("derive child %d: %w", child, err)
		}
		sum := mac.Sum(nil)
		key, chainCode = sum[:32], sum[32:]
	}

	return ed25519.NewKeyFromSeed(key), nil
}

// DeriveKeyring builds a keyring over the first count keys of a seed. A wallet
// with no node derives its own addresses this way.
func DeriveKeyring(seed []byte, count uint32) (*MemoryKeyring, error) {
	ring := NewMemoryKeyring()
	for index := uint32(0); index < count; index++ {
		key, err := DeriveKey(seed, index)
		if err != nil {
			return nil, fmt.Errorf("derive key %d: %w", index, err)
		}
		ring.Add(key)
	}
	return ring, nil
}
