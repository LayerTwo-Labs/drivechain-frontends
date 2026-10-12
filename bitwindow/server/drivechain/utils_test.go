package drivechain

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func depositChecksum(slot int64, address string) string {
	sum := sha256.Sum256(fmt.Appendf(nil, "s%d_%s_", slot, address))
	return hex.EncodeToString(sum[:3])
}

func TestDecodeDepositAddress(t *testing.T) {
	const thunder = "sBRLCn1Jw8Mdpyx6LqDnUffcMdk"
	const solana = "4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T"

	valid := []struct {
		name        string
		destination string
		wantSlot    *int64
		wantAddress string
	}{
		{"bare thunder address", thunder, nil, thunder},
		{"bare solana pubkey", solana, nil, solana},
		{"slot form", "s9_" + thunder, new(int64(9)), thunder},
		{"thunder checksum form", "s9_" + thunder + "_" + depositChecksum(9, thunder), new(int64(9)), thunder},
		{"solana checksum form", "s8_" + solana + "_" + depositChecksum(8, solana), new(int64(8)), solana},
	}
	for _, tc := range valid {
		t.Run(tc.name, func(t *testing.T) {
			slot, address, _, err := DecodeDepositAddress(tc.destination)
			require.NoError(t, err)
			assert.Equal(t, tc.wantSlot, slot)
			assert.Equal(t, tc.wantAddress, address)
		})
	}

	invalid := []struct {
		name        string
		destination string
		wantErr     string
	}{
		{"client error text", "Exception: Solana is not running. Paste a deposit address.", "only letters"},
		{"empty", "", "empty"},
		{"too long", strings.Repeat("a", 81), "limit is 80"},
		{"trailing newline", thunder + "\n", "only letters"},
		{"inner space", "s9_ " + thunder, "only letters"},
		{"wrong checksum", "s9_" + thunder + "_ffffff", "checksum mismatch"},
		{"bad slot", "sx_" + thunder, "slot must be"},
		{"too many parts", "s9_a_b_c", "invalid format"},
	}
	for _, tc := range invalid {
		t.Run(tc.name, func(t *testing.T) {
			_, _, _, err := DecodeDepositAddress(tc.destination)
			assert.ErrorContains(t, err, tc.wantErr)
		})
	}
}
