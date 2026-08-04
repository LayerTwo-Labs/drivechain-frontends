package wallet

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const allZeroMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

// Canonical BIP39 vector. This used to be asserted in Dart; key derivation now
// lives here, so the vector does too.
func TestGenerateWalletFromEntropyAllZeros(t *testing.T) {
	t.Parallel()

	svc := &Service{}
	w, err := svc.GenerateWalletFromEntropy(make([]byte, 16), "", true, nil)
	require.NoError(t, err)

	assert.Equal(t, allZeroMnemonic, w.Master.Mnemonic)
	assert.Equal(t, strings.Repeat("0", 128), w.Master.BIP39Binary)
	assert.Equal(t, "0011", w.Master.BIP39Checksum)
	assert.Len(t, w.Master.SeedHex, 128)
}

func TestGenerateWalletFromEntropyWordCounts(t *testing.T) {
	t.Parallel()

	svc := &Service{}

	twelve, err := svc.GenerateWalletFromEntropy(make([]byte, 16), "", true, nil)
	require.NoError(t, err)
	assert.Len(t, strings.Fields(twelve.Master.Mnemonic), 12)

	twentyFour, err := svc.GenerateWalletFromEntropy(make([]byte, 32), "", true, nil)
	require.NoError(t, err)
	assert.Len(t, strings.Fields(twentyFour.Master.Mnemonic), 24)
}

// A passphrase must change the seed while leaving the words alone — the trap the
// old Dart generator walked into by baking one in.
func TestGenerateWalletFromEntropyPassphraseChangesOnlyTheSeed(t *testing.T) {
	t.Parallel()

	svc := &Service{}

	plain, err := svc.GenerateWalletFromEntropy(make([]byte, 16), "", true, nil)
	require.NoError(t, err)
	withPass, err := svc.GenerateWalletFromEntropy(make([]byte, 16), "layertwolabs", true, nil)
	require.NoError(t, err)

	assert.Equal(t, plain.Master.Mnemonic, withPass.Master.Mnemonic)
	assert.NotEqual(t, plain.Master.SeedHex, withPass.Master.SeedHex)
}

func TestGenerateWalletFromEntropyRejectsBadLength(t *testing.T) {
	t.Parallel()

	svc := &Service{}
	_, err := svc.GenerateWalletFromEntropy(make([]byte, 7), "", true, nil)
	require.Error(t, err)
}
