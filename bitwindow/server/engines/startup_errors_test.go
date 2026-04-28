package engines

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestIsBitcoinCoreStartupError(t *testing.T) {
	cases := []struct {
		err  string
		want bool
		name string
	}{
		{"-28: Verifying blocks…", true, "verify"},
		{"loadwallet RPC error -4: Wallet already loading.", true, "wallet-already-loading"},
		{"Still rescanning. At block 470818", true, "still-rescanning"},
		{"some other unrelated error", false, "unrelated"},
		{"", false, "empty"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, IsBitcoinCoreStartupError(tc.err))
		})
	}
}

func TestExtractBitcoindStartupMessage(t *testing.T) {
	cases := []struct {
		name  string
		input string
		want  string
	}{
		{"connect-go internal -28", "internal: -28: Verifying blocks…", "Verifying blocks…"},
		{"dash separator", "getblockcount([]): -28 - Loading block index…", "Loading block index…"},
		{"wallet -4", "loadwallet RPC error -4: Wallet already loading.", "Wallet already loading."},
		{"plain pattern fallthrough", "Rescanning at height 100", "Rescanning at height 100"},
		{"non-startup error returns empty", "permission denied", ""},
		{"empty input returns empty", "", ""},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, ExtractBitcoindStartupMessage(tc.input))
		})
	}
}
