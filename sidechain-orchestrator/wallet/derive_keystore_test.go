package wallet

import (
	"context"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

func TestMultisigAccountPath(t *testing.T) {
	net := &chaincfg.MainNetParams // coin 0
	cases := map[string]string{
		"wsh":    "m/48'/0'/0'/2'",
		"sh-wsh": "m/48'/0'/0'/1'",
		"tr":     "m/48'/0'/0'/3'",
		"sh":     "m/45'/0'",
	}
	for st, want := range cases {
		got, err := multisigAccountPath(st, 0, net)
		require.NoError(t, err)
		require.Equal(t, want, got, st)
	}
	// Testnet coin 1 for a different account.
	got, err := multisigAccountPath("wsh", 3, &chaincfg.TestNet3Params)
	require.NoError(t, err)
	require.Equal(t, "m/48'/1'/3'/2'", got)

	_, err = multisigAccountPath("bogus", 0, net)
	require.Error(t, err)
}

func TestDeriveKeystoreSingleSigMnemonic(t *testing.T) {
	net := &chaincfg.MainNetParams
	out, err := DeriveKeystore(context.Background(), KeystoreSource{Mnemonic: testMnemonic}, "native-segwit", false, 0, net)
	require.NoError(t, err)

	// Matches the primitive it wraps.
	ap := AccountPath{Purpose: 84, Coin: 0, Account: 0}
	acct, origin, err := accountKeyAndOrigin(hexSeed(testMnemonic), ap, net)
	require.NoError(t, err)
	require.Equal(t, neuter(t, acct), out.Xpub)
	require.Equal(t, fingerprintOnly(origin), out.Fingerprint)
	require.Equal(t, "84'/0'/0'", out.OriginPath) // AccountPath renders hardened with '
}

func TestDeriveKeystoreMultisigMnemonic(t *testing.T) {
	net := &chaincfg.MainNetParams
	out, err := DeriveKeystore(context.Background(), KeystoreSource{Mnemonic: testMnemonic}, "wsh", true, 0, net)
	require.NoError(t, err)
	want, err := DeriveAccountXpub(hexSeed(testMnemonic), "m/48'/0'/0'/2'", net)
	require.NoError(t, err)
	require.Equal(t, want, out.Xpub)
	require.Equal(t, "48'/0'/0'/2'", out.OriginPath)
	require.NotEmpty(t, out.Fingerprint)
	require.Empty(t, out.Descriptor, "multisig returns no single-sig descriptor")
}

// A pasted key-expression keeps its own origin and yields a canonical descriptor
// with the master fingerprint + full path.
func TestDeriveKeystoreRawAndDescriptor(t *testing.T) {
	net := &chaincfg.MainNetParams
	acct, origin, err := accountKeyAndOrigin(hexSeed(testMnemonic), AccountPath{Purpose: 84, Coin: 0, Account: 0}, net)
	require.NoError(t, err)
	raw := "[" + origin + "]" + neuter(t, acct)

	out, err := DeriveKeystore(context.Background(), KeystoreSource{RawKey: raw}, "native-segwit", false, 0, net)
	require.NoError(t, err)
	require.Equal(t, neuter(t, acct), out.Xpub)
	require.Equal(t, fingerprintOnly(origin), out.Fingerprint)

	d, err := ParseDescriptor(out.Descriptor)
	require.NoError(t, err)
	ds, err := d.derivations(false, 0)
	require.NoError(t, err)
	require.Len(t, ds[0].path, 5) // 84'/0'/0'/0/0
}

func hexSeed(mnemonic string) string { return hex.EncodeToString(MnemonicToSeed(mnemonic, "")) }

func fingerprintOnly(origin string) string {
	for i := 0; i < len(origin); i++ {
		if origin[i] == '/' {
			return origin[:i]
		}
	}
	return origin
}
