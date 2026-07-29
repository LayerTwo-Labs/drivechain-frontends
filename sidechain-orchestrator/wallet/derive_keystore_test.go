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
	out, err := DeriveKeystore(context.Background(), KeystoreSource{Mnemonic: testMnemonic}, "native-segwit", false, 0, "", net)
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
	out, err := DeriveKeystore(context.Background(), KeystoreSource{Mnemonic: testMnemonic}, "wsh", true, 0, "", net)
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

	out, err := DeriveKeystore(context.Background(), KeystoreSource{RawKey: raw}, "native-segwit", false, 0, "", net)
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

// A custom derivation path overrides the standard one for the script type, and
// the derived key material matches deriving at that path directly.
func TestDeriveKeystoreCustomPath(t *testing.T) {
	net := &chaincfg.MainNetParams
	out, err := DeriveKeystore(context.Background(), KeystoreSource{Mnemonic: testMnemonic}, "native-segwit", false, 0, "m/84'/0'/7'", net)
	require.NoError(t, err)
	want, err := DeriveAccountXpub(hexSeed(testMnemonic), "m/84'/0'/7'", net)
	require.NoError(t, err)
	require.Equal(t, want, out.Xpub)
	require.Equal(t, "84'/0'/7'", out.OriginPath)

	_, err = DeriveKeystore(context.Background(), KeystoreSource{Mnemonic: testMnemonic}, "native-segwit", false, 0, "m/84'/x'/0'", net)
	require.Error(t, err)
}

func TestParseKeystorePath(t *testing.T) {
	for in, want := range map[string]string{
		"m/84'/0'/0'":     "m/84'/0'/0'",
		"84h/0h/0h":       "m/84'/0'/0'",
		"M/48H/1H/0H/2H":  "m/48'/1'/0'/2'",
		" m/45'/0' ":      "m/45'/0'",
		"m/9999'/0'/0'/5": "m/9999'/0'/0'/5",
	} {
		got, err := ParseKeystorePath(in)
		require.NoError(t, err, in)
		require.Equal(t, want, got, in)
	}

	for _, bad := range []string{"", "m", "m/", "m/84'//0'", "m/84'/x'/0'", "m/-1'/0'", "m/2147483648'", "m/0'/0'/0'/0'/0'/0'/0'/0'/0'/0'/0'"} {
		_, err := ParseKeystorePath(bad)
		require.Error(t, err, "path %q must be rejected", bad)
	}
}

func TestStandardDerivationPaths(t *testing.T) {
	opts, def, err := StandardDerivationPaths("wsh", true, 1, &chaincfg.SigNetParams)
	require.NoError(t, err)
	require.Equal(t, "m/48'/1'/1'/2'", def)
	require.Len(t, opts, 4)
	require.Equal(t, "m/48'/1'/1'/2'", opts[0].Path)
	require.Equal(t, "m/45'/1'", opts[3].Path)

	opts, def, err = StandardDerivationPaths("taproot", false, 0, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.Equal(t, "m/86'/0'/0'", def)
	require.Equal(t, "m/84'/0'/0'", opts[0].Path)

	_, _, err = StandardDerivationPaths("bogus", true, 0, &chaincfg.MainNetParams)
	require.Error(t, err)
}

func TestKeystorePathScriptType(t *testing.T) {
	for _, tc := range []struct {
		path     string
		multisig bool
		want     string
	}{
		{"m/84'/0'/0'", false, "wpkh"},
		{"m/86'/1'/3'", false, "tr"},
		{"m/49'/0'/0'", false, "sh-wpkh"},
		{"m/44'/0'/0'", false, "pkh"},
		{"m/48'/1'/0'/2'", true, "wsh"},
		{"m/48'/1'/0'/1'", true, "sh-wsh"},
		{"m/48'/1'/0'/3'", true, "tr"},
		{"m/45'/0'", true, "sh"},
		// A path that is standard for the other policy, or custom, has no type.
		{"m/84'/0'/0'", true, ""},
		{"m/48'/1'/0'/2'", false, ""},
		{"m/1234'/0'/0'", false, ""},
		{"m/84'/0'/0'/0", false, ""},
		{"nonsense", false, ""},
	} {
		require.Equal(t, tc.want, KeystorePathScriptType(tc.path, tc.multisig), "path %q", tc.path)
	}
}
