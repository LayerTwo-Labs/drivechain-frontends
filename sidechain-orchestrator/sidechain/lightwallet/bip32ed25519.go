package lightwallet

import (
	"crypto/hmac"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/binary"
	"fmt"

	"filippo.io/edwards25519"
)

// XPrv is a BIP32-Ed25519 extended key: a 64-byte extended secret key and a
// 32-byte chain code. The scheme is the V2 one of the Ed25519_BIP paper.
type XPrv struct {
	key   [64]byte
	chain [32]byte
}

// masterRetryLimit bounds the walk to a usable master key. Each round has an
// even chance, so a seed that needs more than a few is beyond belief.
const masterRetryLimit = 64

// Bip32Ed25519Master builds the master key of a BIP39 seed. The paper takes a
// 256-bit secret, so the seed hashes down first, and a secret that expands to
// an unusable key hashes again.
func Bip32Ed25519Master(seed []byte) (XPrv, error) {
	if len(seed) == 0 {
		return XPrv{}, fmt.Errorf("the seed is empty")
	}
	secret := sha256.Sum256(seed)
	for range masterRetryLimit {
		chain := sha256.Sum256(append([]byte{0x01}, secret[:]...))
		extended := sha512.Sum512(secret[:])
		key := normalizeEd25519(extended)
		// The paper needs the third highest bit clear. Forcing it clear would
		// derive a key the node never holds.
		if key[31]&0b0010_0000 == 0 {
			return XPrv{key: key, chain: chain}, nil
		}
		secret = sha256.Sum256(secret[:])
	}
	return XPrv{}, fmt.Errorf("no master key after %d rounds", masterRetryLimit)
}

// normalizeEd25519 prunes the extended key the way ed25519 prunes a hashed
// seed: clear the low three bits, clear the top two, and set bit 254.
func normalizeEd25519(extended [64]byte) [64]byte {
	extended[0] &= 0b1111_1000
	extended[31] &= 0b0011_1111
	extended[31] |= 0b0100_0000
	return extended
}

// Child derives one child key. An index at or above Hardened derives a
// hardened child, which hashes the parent key rather than its public key.
func (x XPrv) Child(index uint32) (XPrv, error) {
	var serialized [4]byte
	binary.LittleEndian.PutUint32(serialized[:], index)

	z := hmac.New(sha512.New, x.chain[:])
	next := hmac.New(sha512.New, x.chain[:])
	if index >= Hardened {
		z.Write([]byte{0x00})
		z.Write(x.key[:])
		next.Write([]byte{0x01})
		next.Write(x.key[:])
	} else {
		public, err := x.PublicKey()
		if err != nil {
			return XPrv{}, err
		}
		z.Write([]byte{0x02})
		z.Write(public)
		next.Write([]byte{0x03})
		next.Write(public)
	}
	z.Write(serialized[:])
	next.Write(serialized[:])

	zout := z.Sum(nil)
	var child XPrv
	copy(child.key[:32], addTruncatedMul8(x.key[:32], zout[:32]))
	copy(child.key[32:], add256(x.key[32:], zout[32:]))
	copy(child.chain[:], next.Sum(nil)[32:])
	return child, nil
}

// Derive walks a path of child indexes.
func (x XPrv) Derive(path []uint32) (XPrv, error) {
	for _, index := range path {
		child, err := x.Child(index)
		if err != nil {
			return XPrv{}, err
		}
		x = child
	}
	return x, nil
}

// PublicKey is the ed25519 verifying key of the extended secret key.
func (x XPrv) PublicKey() ([]byte, error) {
	scalar, err := edwards25519.NewScalar().SetBytesWithClamping(x.key[:32])
	if err != nil {
		return nil, fmt.Errorf("read the extended key: %w", err)
	}
	return new(edwards25519.Point).ScalarBaseMult(scalar).Bytes(), nil
}

// addTruncatedMul8 is left = kl + 8 * trunc28(zl), over 32 little-endian bytes.
func addTruncatedMul8(left, z []byte) []byte {
	out := make([]byte, 32)
	var carry uint16
	for i := range 28 {
		sum := uint16(left[i]) + uint16(z[i])<<3 + carry
		out[i] = byte(sum)
		carry = sum >> 8
	}
	for i := 28; i < 32; i++ {
		sum := uint16(left[i]) + carry
		out[i] = byte(sum)
		carry = sum >> 8
	}
	return out
}

// add256 adds two 32-byte little-endian numbers and drops the carry out.
func add256(right, z []byte) []byte {
	out := make([]byte, 32)
	var carry uint16
	for i := range 32 {
		sum := uint16(right[i]) + uint16(z[i]) + carry
		out[i] = byte(sum)
		carry = sum >> 8
	}
	return out
}
