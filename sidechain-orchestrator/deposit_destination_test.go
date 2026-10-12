package orchestrator

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestCheckDepositDestination(t *testing.T) {
	valid := []struct {
		name        string
		destination string
	}{
		{"thunder base58", "sBRLCn1Jw8Mdpyx6LqDnUffcMdk"},
		{"slot form", "s9_sBRLCn1Jw8Mdpyx6LqDnUffcMdk"},
		{"checksum form", "s9_sBRLCn1Jw8Mdpyx6LqDnUffcMdk_3f2a1b"},
		{"solana pubkey", "4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T"},
		{"solana checksum form", "s8_4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T_a1b2c3"},
		{"zside transparent", "tmBsTi2xWTjUdEXnuTceL7fecEQKeWaPDJd"},
		{"bech32", "bcrt1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080"},
		{"taproot", "bc1p5d7rjq7g6rdk2yhzks9smlaqtedr4dekq08ge8ztwac72sfr9rusxg3297"},
		{"evm hex", "0x52908400098527886E0F7030069857D2E4169EE7"},
		{"longest", strings.Repeat("a", MaxDepositDestinationLen)},
	}
	for _, tc := range valid {
		t.Run(tc.name, func(t *testing.T) {
			require.NoError(t, CheckDepositDestination(tc.destination))
		})
	}

	invalid := []struct {
		name        string
		destination string
		wantErr     string
	}{
		{"client error text", "Exception: Solana is not running. Paste a deposit address.", "only letters"},
		{"empty", "", "empty"},
		{"too long", strings.Repeat("a", MaxDepositDestinationLen+1), "limit is 80"},
		{"inner space", "sBRLCn1Jw8 Mdpyx6LqDnUffcMdk", "only letters"},
		{"leading space", " sBRLCn1Jw8Mdpyx6LqDnUffcMdk", "only letters"},
		{"trailing newline", "sBRLCn1Jw8Mdpyx6LqDnUffcMdk\n", "only letters"},
		{"tab", "s9_\tsBRLCn1Jw8Mdpyx6LqDnUffcMdk", "only letters"},
		{"colon", "bitcoin:sBRLCn1Jw8Mdpyx6LqDnUffcMdk", "only letters"},
		{"period", "sBRLCn1Jw8Mdpyx6LqDnUffcMdk.", "only letters"},
		{"non-ascii", "sBRLCn1Jw8Mdpyx6LqDnUffcMdkø", "only letters"},
		{"nul byte", "sBRLCn1Jw8Mdpyx6LqDnUffcMdk\x00", "only letters"},
	}
	for _, tc := range invalid {
		t.Run(tc.name, func(t *testing.T) {
			assert.ErrorContains(t, CheckDepositDestination(tc.destination), tc.wantErr)
		})
	}
}
