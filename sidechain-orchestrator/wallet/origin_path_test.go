package wallet

import (
	"testing"

	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/stretchr/testify/require"
)

func TestParseOrigin(t *testing.T) {
	h := func(n uint32) uint32 { return n + hdkeychain.HardenedKeyStart }

	fp, path, ok := parseOrigin("abcd1234/84h/0'/0H/1/2")
	require.True(t, ok)
	require.Equal(t, uint32(0x3412cdab), fp, "the fingerprint reads little-endian")
	require.Equal(t, []uint32{h(84), h(0), h(0), 1, 2}, path)

	_, path, ok = parseOrigin("abcd1234")
	require.True(t, ok, "a fingerprint with no path is an account key")
	require.Empty(t, path)

	for _, bad := range []string{"", "abcd12/0", "abcd1234/x", "abcd1234/m/0", "zzzz1234/0"} {
		_, _, ok = parseOrigin(bad)
		require.False(t, ok, bad)
	}
}

func TestParseOriginPath(t *testing.T) {
	h := func(n uint32) uint32 { return n + hdkeychain.HardenedKeyStart }

	for _, in := range []string{"48'/0'/0'/2'", "m/48'/0'/0'/2'", "M/48h/0h/0h/2h"} {
		path, ok := parseOriginPath(in)
		require.True(t, ok, in)
		require.Equal(t, []uint32{h(48), h(0), h(0), h(2)}, path)
	}

	for _, in := range []string{"", "m", "m/", "/"} {
		path, ok := parseOriginPath(in)
		require.True(t, ok, in)
		require.Empty(t, path, in)
	}

	// A trailing separator names no step, the way a descriptor origin reads it.
	path, ok := parseOriginPath("48'/0'/")
	require.True(t, ok)
	require.Len(t, path, 2)

	// A path that reads as a path only after a stripped "m" is malformed, and
	// the wallet cannot store it.
	for _, bad := range []string{"m48'/0'/0'/2'", "48'/x", "48''", "48'/-1"} {
		_, ok := parseOriginPath(bad)
		require.False(t, ok, bad)
	}
}
