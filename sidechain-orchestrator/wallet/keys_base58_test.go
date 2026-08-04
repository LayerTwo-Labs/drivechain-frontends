package wallet

import (
	"testing"

	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// BIP32 test vector 1. Decoding then re-encoding must return the same string,
// which pins Base58CheckEncode against the library's decoder.
func TestBase58CheckEncodeRoundTripsBIP32Vector(t *testing.T) {
	t.Parallel()

	const xpub = "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"

	decoded := base58.Decode(xpub)
	require.Len(t, decoded, 82)

	assert.Equal(t, xpub, Base58CheckEncode(decoded[:78]))
}

func TestBase58CheckEncodeKeepsLeadingZeros(t *testing.T) {
	t.Parallel()

	out := Base58CheckEncode([]byte{0x00, 0x00, 0x01})
	assert.Equal(t, []byte{0x00, 0x00, 0x01}, base58.Decode(out)[:3])
	assert.Equal(t, "11", out[:2])
}

func TestBase58CheckEncodeDoesNotMutateInput(t *testing.T) {
	t.Parallel()

	backing := make([]byte, 10, 20)
	for i := range backing {
		backing[i] = byte(i)
	}
	before := append([]byte(nil), backing...)

	Base58CheckEncode(backing)

	assert.Equal(t, before, backing)
}
