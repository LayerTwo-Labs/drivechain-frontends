package api

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func depositChecksum(slot uint8, address string) string {
	sum := sha256.Sum256(fmt.Appendf(nil, "s%d_%s_", slot, address))
	return hex.EncodeToString(sum[:3])
}

func TestDepositDestination(t *testing.T) {
	const addr = "sBRLCn1Jw8Mdpyx6LqDnUffcMdk"

	t.Run("bare address passes through", func(t *testing.T) {
		got, err := depositDestination(9, addr)
		require.NoError(t, err)
		assert.Equal(t, addr, got)
	})

	t.Run("slot form unwraps", func(t *testing.T) {
		got, err := depositDestination(9, "s9_"+addr)
		require.NoError(t, err)
		assert.Equal(t, addr, got)
	})

	t.Run("checksum form unwraps", func(t *testing.T) {
		got, err := depositDestination(9, "s9_"+addr+"_"+depositChecksum(9, addr))
		require.NoError(t, err)
		assert.Equal(t, addr, got)
	})

	t.Run("wrong checksum fails", func(t *testing.T) {
		_, err := depositDestination(9, "s9_"+addr+"_ffffff")
		assert.ErrorContains(t, err, "checksum mismatch")
	})

	t.Run("long checksum fails", func(t *testing.T) {
		_, err := depositDestination(9, "s9_"+addr+"_15d2709cfa25")
		assert.ErrorContains(t, err, "checksum mismatch")
	})

	t.Run("wrong slot fails", func(t *testing.T) {
		_, err := depositDestination(9, "s5_"+addr)
		assert.ErrorContains(t, err, "slot")
	})

	t.Run("empty address fails", func(t *testing.T) {
		_, err := depositDestination(9, "s9__abcdef")
		assert.ErrorContains(t, err, "no address")
	})

	t.Run("underscore with no prefix fails", func(t *testing.T) {
		_, err := depositDestination(9, "hello_sidechain")
		assert.Error(t, err)
	})

	t.Run("too many parts fails", func(t *testing.T) {
		_, err := depositDestination(9, "s9_a_b_c")
		assert.Error(t, err)
	})

	t.Run("client error text fails", func(t *testing.T) {
		_, err := depositDestination(8, "Exception: Solana is not running. Paste a deposit address.")
		assert.ErrorContains(t, err, "only letters")
	})

	t.Run("bare solana pubkey passes through", func(t *testing.T) {
		const pubkey = "4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T"
		got, err := depositDestination(8, pubkey)
		require.NoError(t, err)
		assert.Equal(t, pubkey, got)
	})

	t.Run("whitespace around a valid form fails", func(t *testing.T) {
		_, err := depositDestination(9, " s9_"+addr+"\n")
		assert.ErrorContains(t, err, "only letters")
	})
}
