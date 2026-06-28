package engines

import (
	"encoding/hex"
	"strings"
	"testing"

	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// abandonSeedHex is the BIP39 seed for the standard "abandon … about" mnemonic.
const abandonSeedHex = "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4"

func mustMaster(t *testing.T) *hdkeychain.ExtendedKey {
	t.Helper()
	seed, err := hex.DecodeString(abandonSeedHex)
	require.NoError(t, err)
	master, err := hdkeychain.NewMaster(seed, &chaincfg.MainNetParams)
	require.NoError(t, err)
	return master
}

// TestCoreDescriptorsDefault asserts the local fallback derivation imports the
// standard BIP84 + BIP86 descriptors at account 0 when no override is set.
func TestCoreDescriptorsDefault(t *testing.T) {
	e := &WalletEngine{chainParams: &chaincfg.MainNetParams}
	descs, err := e.coreDescriptors(mustMaster(t), 0, "", true)
	require.NoError(t, err)
	require.Len(t, descs, 4)

	assert.True(t, strings.HasPrefix(descs[0].desc, "wpkh("))
	assert.Contains(t, descs[0].desc, "/84'/0'/0']")
	assert.False(t, descs[0].internal)
	assert.True(t, descs[1].internal)
	assert.True(t, strings.HasPrefix(descs[2].desc, "tr("))
	assert.Contains(t, descs[2].desc, "/86'/0'/0']")
}

// TestCoreDescriptorsAccountIndex asserts an account index shifts both the
// BIP84 and BIP86 descriptor origins to that account.
func TestCoreDescriptorsAccountIndex(t *testing.T) {
	e := &WalletEngine{chainParams: &chaincfg.MainNetParams}
	descs, err := e.coreDescriptors(mustMaster(t), 1, "", true)
	require.NoError(t, err)
	require.Len(t, descs, 4)
	for _, d := range descs {
		if strings.HasPrefix(d.desc, "wpkh(") {
			assert.Contains(t, d.desc, "/84'/0'/1']")
		} else {
			assert.Contains(t, d.desc, "/86'/0'/1']")
		}
	}
}

// TestCoreDescriptorsExplicitPath asserts a full path override imports the
// single descriptor for that path's purpose (here taproot).
func TestCoreDescriptorsExplicitPath(t *testing.T) {
	e := &WalletEngine{chainParams: &chaincfg.MainNetParams}
	descs, err := e.coreDescriptors(mustMaster(t), 0, "m/86'/0'/2'", true)
	require.NoError(t, err)
	require.Len(t, descs, 2)
	for _, d := range descs {
		assert.True(t, strings.HasPrefix(d.desc, "tr("))
		assert.Contains(t, d.desc, "/86'/0'/2']")
	}
}

// TestCoreDescriptorsRejectsBadPath asserts malformed override paths are rejected.
func TestCoreDescriptorsRejectsBadPath(t *testing.T) {
	e := &WalletEngine{chainParams: &chaincfg.MainNetParams}
	_, err := e.coreDescriptors(mustMaster(t), 0, "m/84'/0'", true)
	require.Error(t, err)
}
