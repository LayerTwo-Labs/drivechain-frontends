package lightwallet

import (
	"crypto/ed25519"
	"crypto/hmac"
	"crypto/sha512"
	"encoding/binary"
	"fmt"
)

// Hardened marks a hardened child index. SLIP-0010 over ed25519 has no
// unhardened form, so every index of such a path carries it.
const Hardened uint32 = 0x80000000

var slip10Curve = []byte("ed25519 seed")

// Slip10Key derives the ed25519 key one SLIP-0010 path names, from a BIP39
// seed. A wrong path derives an address the node does not know, and the coins
// then read as someone else's.
func Slip10Key(seed []byte, path []uint32) (ed25519.PrivateKey, error) {
	if len(seed) == 0 {
		return nil, fmt.Errorf("the seed is empty")
	}

	mac := hmac.New(sha512.New, slip10Curve)
	if _, err := mac.Write(seed); err != nil {
		return nil, fmt.Errorf("seed the master node: %w", err)
	}
	sum := mac.Sum(nil)
	key, chainCode := sum[:32], sum[32:]

	for _, child := range path {
		if child < Hardened {
			return nil, fmt.Errorf("child %d is not hardened", child)
		}
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
