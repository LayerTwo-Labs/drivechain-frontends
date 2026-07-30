package wallet

import (
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestParseAccountPath(t *testing.T) {
	cases := []struct {
		in       string
		want     string
		standard bool
		wantErr  string
	}{
		{in: "m/84'/0'/0'", want: "m/84'/0'/0'", standard: true},
		{in: "84h/0h/3h", want: "m/84'/0'/3'", standard: true},
		{in: "m/86'/1'/2'", want: "m/86'/1'/2'", standard: true},
		// Any depth, purpose, coin type or unhardened level the user asks for.
		{in: "m/9999'/0'/0'", want: "m/9999'/0'/0'", standard: true},
		{in: "m/84'/5'/0'", want: "m/84'/5'/0'", standard: true},
		{in: "m/48'/0'/0'/2'", want: "m/48'/0'/0'/2'"},
		{in: "m/84'/0'", want: "m/84'/0'"},
		{in: "m/84/0'/0'", want: "m/84/0'/0'"},
		{in: "m/84'/0'/0'/0", want: "m/84'/0'/0'/0"},
		{in: "m/84'/0'/x'", wantErr: "not a number"},
		{in: "", wantErr: "at least one level"},
		{in: "m/0'/0'/0'/0'/0'/0'/0'/0'/0'/0'/0'", wantErr: "at most"},
	}
	for _, c := range cases {
		got, err := ParseAccountPath(c.in)
		if c.wantErr != "" {
			require.Error(t, err, c.in)
			assert.Contains(t, err.Error(), c.wantErr, c.in)
			continue
		}
		require.NoError(t, err, c.in)
		assert.Equal(t, c.want, got.String(), c.in)
		assert.Equal(t, c.standard, got.Standard(), c.in)
	}
}

func TestResolveCreateDerivationPath(t *testing.T) {
	// Explicit full path wins and zeroes the account index.
	acc, path, err := ResolveCreateDerivationPath(7, "m/86'/0'/2'")
	require.NoError(t, err)
	assert.Equal(t, uint32(0), acc)
	assert.Equal(t, "m/86'/0'/2'", path)

	// Account index only.
	acc, path, err = ResolveCreateDerivationPath(3, "")
	require.NoError(t, err)
	assert.Equal(t, uint32(3), acc)
	assert.Empty(t, path)

	// Default.
	acc, path, err = ResolveCreateDerivationPath(0, "")
	require.NoError(t, err)
	assert.Equal(t, uint32(0), acc)
	assert.Empty(t, path)

	// A custom path is kept as typed.
	acc, path, err = ResolveCreateDerivationPath(0, "m/1234'/9'/0'/7")
	require.NoError(t, err)
	assert.Equal(t, uint32(0), acc)
	assert.Equal(t, "m/1234'/9'/0'/7", path)

	// Malformed explicit path rejected.
	_, _, err = ResolveCreateDerivationPath(0, "m/84'/x")
	require.Error(t, err)
}

func TestAccountPathForOverrides(t *testing.T) {
	net := &chaincfg.MainNetParams

	// Account index shifts the standard path.
	ap, err := accountPathFor(&WalletData{AccountIndex: 5}, ScriptNativeSegwit, net)
	require.NoError(t, err)
	assert.Equal(t, "m/84'/0'/5'", ap.String())

	// Explicit path overrides purpose, ignoring AccountIndex.
	ap, err = accountPathFor(&WalletData{AccountIndex: 5, DerivationPath: "m/86'/0'/2'"}, ScriptNativeSegwit, net)
	require.NoError(t, err)
	assert.Equal(t, "m/86'/0'/2'", ap.String())

	// Default (no override) is account 0.
	ap, err = accountPathFor(&WalletData{}, ScriptNativeSegwit, net)
	require.NoError(t, err)
	assert.Equal(t, "m/84'/0'/0'", ap.String())
}

// TestCustomAccountAddressVector pins the BIP84 account-1 first receive address
// for the standard abandon mnemonic, proving a custom account index changes
// derivation to the externally-recoverable path.
func TestCustomAccountAddressVector(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams

	ap, err := accountPathFor(&WalletData{AccountIndex: 1}, ScriptNativeSegwit, net)
	require.NoError(t, err)
	acct, origin, err := accountKeyAndOrigin(seedHex, ap, net)
	require.NoError(t, err)
	assert.Equal(t, "m/84'/0'/1'", ap.String())
	assert.Regexp(t, `^[0-9a-f]{8}/84h/0h/1h$`, origin)

	d := &Descriptor{Kind: ScriptNativeSegwit, Threshold: 1, Keys: []DescriptorKey{{Origin: origin, Account: acct}}}
	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	assert.Equal(t, "bc1qku0qh0mc00y8tk0n65x2tqw4trlspak0fnjmfz", ds.address.EncodeAddress())

	// Account 0 must still be the standard BIP84 first address (unchanged default).
	ap0, err := accountPathFor(&WalletData{}, ScriptNativeSegwit, net)
	require.NoError(t, err)
	acct0, origin0, err := accountKeyAndOrigin(seedHex, ap0, net)
	require.NoError(t, err)
	d0 := &Descriptor{Kind: ScriptNativeSegwit, Threshold: 1, Keys: []DescriptorKey{{Origin: origin0, Account: acct0}}}
	ds0, _, err := d0.DeriveScript(false, 0, net)
	require.NoError(t, err)
	assert.Equal(t, "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu", ds0.address.EncodeAddress())
}

func TestCoreDescriptorWrapper(t *testing.T) {
	cases := []struct {
		kind        ScriptKind
		open, close string
	}{
		{ScriptLegacy, "pkh(", ")"},
		{ScriptNestedSegwit, "sh(wpkh(", "))"},
		{ScriptNativeSegwit, "wpkh(", ")"},
		{ScriptTaproot, "tr(", ")"},
	}
	for _, c := range cases {
		open, close, ok := coreDescriptorWrapper(c.kind)
		require.True(t, ok, c.kind)
		assert.Equal(t, c.open, open, c.kind)
		assert.Equal(t, c.close, close, c.kind)
	}
}

// A custom account path — any depth or purpose — derives the key it names, so a
// wallet created at one scans the addresses the user asked for.
func TestCustomDerivationPathDerivesThatPath(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams

	for _, path := range []string{"m/48'/0'/0'/2'", "m/9999'/7'/1'", "m/84'/0'/0'/5", "m/1'"} {
		ap, err := accountPathFor(&WalletData{DerivationPath: path}, ScriptNativeSegwit, net)
		require.NoError(t, err, path)
		assert.Equal(t, path, ap.String(), path)

		acct, origin, err := accountKeyAndOrigin(seedHex, ap, net)
		require.NoError(t, err, path)

		want, err := DeriveAccountXpub(seedHex, path, net)
		require.NoError(t, err, path)
		pub, err := acct.Neuter()
		require.NoError(t, err, path)
		assert.Equal(t, want, pub.String(), path)
		assert.Contains(t, origin, ap.Origin("h"), path)
	}
}
