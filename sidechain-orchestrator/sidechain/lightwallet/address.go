// Package lightwallet reads a sidechain wallet from an Esplora index, with no
// sidechain node. Every chain here shares one address form and one index API,
// and each chain names its own key derivation.
package lightwallet

import (
	"fmt"

	"github.com/mr-tron/base58"
	"lukechampine.com/blake3"
)

// AddressSize is the width of a sidechain address.
const AddressSize = 20

// Address is a 20-byte sidechain address, shown as base58 with no checksum.
type Address [AddressSize]byte

func (a Address) String() string { return base58.Encode(a[:]) }

// ParseAddress reads the base58 form.
func ParseAddress(s string) (Address, error) {
	var a Address
	raw, err := base58.Decode(s)
	if err != nil {
		return a, fmt.Errorf("decode address %q: %w", s, err)
	}
	if len(raw) != AddressSize {
		return a, fmt.Errorf("address %q is %d bytes, want %d", s, len(raw), AddressSize)
	}
	copy(a[:], raw)
	return a, nil
}

// AddressForKey derives the address a public key owns: a blake3 extendable
// output over the key bytes, read 20 bytes wide.
func AddressForKey(key []byte) Address {
	var a Address
	hasher := blake3.New(32, nil)
	_, _ = hasher.Write(key)
	_, _ = hasher.XOF().Read(a[:])
	return a
}
