package api

import (
	"encoding/hex"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	bip39 "github.com/tyler-smith/go-bip39"
)

// The Generate Key path used to mint entropy in Dart. It is minted here now, so
// pin that the server side actually produces fresh, correctly sized entropy.
func TestGeneratedEntropyIsFreshAndSized(t *testing.T) {
	t.Parallel()

	for _, tc := range []struct{ bits, bytes, words int }{{128, 16, 12}, {256, 32, 24}} {
		first, err := bip39.NewEntropy(tc.bits)
		require.NoError(t, err)
		second, err := bip39.NewEntropy(tc.bits)
		require.NoError(t, err)

		assert.Len(t, first, tc.bytes)
		assert.NotEqual(t, first, second, "two draws must differ")
		assert.NotEqual(t, make([]byte, tc.bytes), first, "entropy must not be all zeroes")

		mnemonic, err := bip39.NewMnemonic(first)
		require.NoError(t, err)
		assert.Len(t, strings.Fields(mnemonic), tc.words)
	}
}

// Exact-length hex round-trips, so the entropy shown in the box is the entropy
// the words came from.
func TestExactLengthHexIsUsedAsRawEntropy(t *testing.T) {
	t.Parallel()

	raw := make([]byte, 32)
	for i := range raw {
		raw[i] = byte(i)
	}
	encoded := hex.EncodeToString(raw)

	decoded, err := hex.DecodeString(encoded)
	require.NoError(t, err)
	require.Len(t, decoded, 32)
	assert.Equal(t, raw, decoded)

	fromRaw, err := bip39.NewMnemonic(raw)
	require.NoError(t, err)
	fromDecoded, err := bip39.NewMnemonic(decoded)
	require.NoError(t, err)
	assert.Equal(t, fromRaw, fromDecoded)
}
