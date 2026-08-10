package multisig

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestExtractAccountIndexHardenedMarkers(t *testing.T) {
	// BIP32 writes the hardened marker as ', h or H.
	for _, path := range []string{"m/84'/1'/8005'", "m/84h/1h/8005h", "m/84H/1H/8005H"} {
		require.Equal(t, 8005, extractAccountIndex(path), path)
	}
	require.Equal(t, 0, extractAccountIndex("m/84'/1'/not-a-number'"))

	// The keystore parser accepts a rootless path too.
	require.Equal(t, 8005, extractAccountIndex("48'/1'/8005'/2'"))
	require.Equal(t, 8005, extractAccountIndex("m/48'/1'/8005'/2'"))
}
