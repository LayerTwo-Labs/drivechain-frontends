package wallet

import (
	"encoding/hex"
	"fmt"
	"testing"

	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// A multisig PSBT must carry a global xpub per cosigner or a device won't sign.
func TestMultisigGlobalXpubs(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams

	acct0, origin0, err := accountKeyAndOrigin(seedHex, AccountPath{Purpose: 48, Coin: 0, Account: 0}, net)
	require.NoError(t, err)
	acct1, origin1, err := accountKeyAndOrigin(seedHex, AccountPath{Purpose: 48, Coin: 0, Account: 1}, net)
	require.NoError(t, err)
	xpub0, xpub1 := neuter(t, acct0), neuter(t, acct1)

	desc := fmt.Sprintf("wsh(sortedmulti(2,[%s]%s/0/*,[%s]%s/0/*))", origin0, xpub0, origin1, xpub1)
	d, err := ParseDescriptor(desc)
	require.NoError(t, err)

	xpubs := multisigGlobalXpubs(d)
	require.Len(t, xpubs, 2)

	got := map[string]bool{}
	for _, x := range xpubs {
		require.NotZero(t, x.MasterKeyFingerprint)
		require.NotEmpty(t, x.Bip32Path)
		k, err := psbt.DecodeExtendedKey(x.ExtendedKey)
		require.NoError(t, err)
		require.Equal(t, len(x.Bip32Path), int(k.Depth()))
		got[k.String()] = true
	}
	require.True(t, got[xpub0] && got[xpub1], "both cosigner xpubs present")
}

// A device-imported single-sig wallet's PSBT needs the master fingerprint and
// full path, or the device can't match its key.
func TestDeviceImportDescriptorHasMasterOrigin(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams
	acct, origin, err := accountKeyAndOrigin(seedHex, AccountPath{Purpose: 84, Coin: 0, Account: 0}, net)
	require.NoError(t, err)

	// The exact form the frontend builds when reading an xpub from a device.
	desc := fmt.Sprintf("wpkh([%s]%s/<0;1>/*)", origin, neuter(t, acct))
	d, err := ParseDescriptor(desc)
	require.NoError(t, err)

	ds, err := d.derivations(false, 0)
	require.NoError(t, err)
	require.Len(t, ds, 1)

	// Master fingerprint from the origin, not the account key's own fingerprint.
	master := parseFingerprintForTest(t, origin)
	require.Equal(t, master, ds[0].fingerprint)
	// Full path: 84'/0'/0'/0/0 (five elements), not the truncated [0,0] fallback.
	require.Len(t, ds[0].path, 5)
}

func parseFingerprintForTest(t *testing.T, origin string) uint32 {
	fp, _, ok := parseOrigin(origin)
	require.True(t, ok)
	return fp
}

func TestSingleSigHasNoGlobalXpubs(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams
	acct, origin, err := accountKeyAndOrigin(seedHex, AccountPath{Purpose: 84, Coin: 0, Account: 0}, net)
	require.NoError(t, err)
	d, err := ParseDescriptor(fmt.Sprintf("wpkh([%s]%s/0/*)", origin, neuter(t, acct)))
	require.NoError(t, err)
	require.Nil(t, multisigGlobalXpubs(d))
}
