package wallet

import (
	"encoding/binary"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// reencodeVersion rewrites an extended key's 4-byte version (for SLIP-0132 test
// vectors), recomputing the base58check checksum.
func reencodeVersion(t *testing.T, xkey string, version uint32) string {
	t.Helper()
	raw := base58.Decode(xkey)
	require.Len(t, raw, 82)
	binary.BigEndian.PutUint32(raw[:4], version)
	copy(raw[78:82], chainhash.DoubleHashB(raw[:78])[:4])
	return base58.Encode(raw)
}

// TestDescriptorAcceptsSLIP132: a bare ypub/zpub account key is accepted, infers
// its script kind from the header, and derives the same address as the xpub form.
func TestDescriptorAcceptsSLIP132(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams

	acct84, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, net)
	require.NoError(t, err)
	zpub := reencodeVersion(t, neuter(t, acct84), 0x04B24746)
	d, err := ParseDescriptor(zpub)
	require.NoError(t, err)
	assert.Equal(t, ScriptNativeSegwit, d.Kind, "zpub must infer native segwit")
	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	assert.Equal(t, "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu", ds.address.EncodeAddress())

	acct49, err := accountKeyFromSeed(seedHex, ScriptNestedSegwit, net)
	require.NoError(t, err)
	ypub := reencodeVersion(t, neuter(t, acct49), 0x049D7CB2)
	d2, err := ParseDescriptor(ypub)
	require.NoError(t, err)
	assert.Equal(t, ScriptNestedSegwit, d2.Kind, "ypub must infer nested segwit")
	ds2, _, err := d2.DeriveScript(false, 0, net)
	require.NoError(t, err)
	assert.Equal(t, "37VucYSaXLCAsxYyAPfbSi9eh4iEcbShgf", ds2.address.EncodeAddress())
}

func neuter(t *testing.T, k *hdkeychain.ExtendedKey) string {
	t.Helper()
	pub, err := k.Neuter()
	require.NoError(t, err)
	return pub.String()
}

// mainnet first-receive vectors for the standard "abandon … about" mnemonic
// (== testMnemonic), from BIP49 / BIP84 / BIP86.
func TestDescriptorEngineBIPVectors(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams

	cases := []struct {
		kind ScriptKind
		want string
	}{
		{ScriptNestedSegwit, "37VucYSaXLCAsxYyAPfbSi9eh4iEcbShgf"},                        // BIP49 m/49'/0'/0'/0/0
		{ScriptNativeSegwit, "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu"},                // BIP84 m/84'/0'/0'/0/0
		{ScriptTaproot, "bc1p5cyxnuxmeuwuvkwfem96lqzszd02n6xdcjrs20cac6yqjjwudpxqkedrcr"}, // BIP86 m/86'/0'/0'/0/0
	}
	for _, c := range cases {
		t.Run(c.kind.String(), func(t *testing.T) {
			acct, err := accountKeyFromSeed(seedHex, c.kind, net)
			require.NoError(t, err)
			d := &Descriptor{Kind: c.kind, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}

			ds, _, err := d.DeriveScript(false, 0, net)
			require.NoError(t, err)
			assert.Equal(t, c.want, ds.address.EncodeAddress())

			// scriptPubKey must round-trip to the same address.
			class, addrs, _, err := txscript.ExtractPkScriptAddrs(ds.scriptPubKey, net)
			require.NoError(t, err)
			require.Len(t, addrs, 1)
			assert.Equal(t, c.want, addrs[0].EncodeAddress(), "scriptPubKey decodes to the address (class %v)", class)
		})
	}
}

// Legacy P2PKH has no authoritative single-vector here; assert the type +
// determinism + scriptPubKey round-trip.
func TestDescriptorLegacyType(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams
	acct, err := accountKeyFromSeed(seedHex, ScriptLegacy, net)
	require.NoError(t, err)
	d := &Descriptor{Kind: ScriptLegacy, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}

	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	_, ok := ds.address.(*btcutil.AddressPubKeyHash)
	assert.True(t, ok, "legacy must derive a P2PKH address, got %T", ds.address)

	ds2, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	assert.Equal(t, ds.address.EncodeAddress(), ds2.address.EncodeAddress(), "derivation must be deterministic")
}

// A wpkh descriptor with origin + branch must parse and derive the same address
// as deriving from the seed directly (proves the parse→derive path).
func TestParseDescriptorRoundTrip(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams
	acct, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, net)
	require.NoError(t, err)
	xpub := neuter(t, acct)

	desc := "wpkh([abcd1234/84h/0h/0h]" + xpub + "/0/*)"
	parsed, err := ParseDescriptor(desc)
	require.NoError(t, err)
	require.Equal(t, ScriptNativeSegwit, parsed.Kind)

	ds, _, err := parsed.DeriveScript(false, 0, net)
	require.NoError(t, err)
	assert.Equal(t, "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu", ds.address.EncodeAddress())
}

func TestParseDescriptorForms(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	acct, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, &chaincfg.MainNetParams)
	require.NoError(t, err)
	xpub := neuter(t, acct)

	mustKind := func(t *testing.T, desc string, want ScriptKind) {
		t.Helper()
		d, err := ParseDescriptor(desc)
		require.NoError(t, err, desc)
		assert.Equal(t, want, d.Kind, desc)
	}
	mustKind(t, xpub, ScriptNativeSegwit) // bare key
	mustKind(t, "pkh("+xpub+"/0/*)", ScriptLegacy)
	mustKind(t, "wpkh("+xpub+"/1/*)", ScriptNativeSegwit)
	mustKind(t, "sh(wpkh("+xpub+"/0/*))", ScriptNestedSegwit)
	mustKind(t, "tr("+xpub+"/<0;1>/*)", ScriptTaproot)
	mustKind(t, "wsh(sortedmulti(2,"+xpub+"/0/*,"+xpub+"/0/*))", ScriptMultisig)
	mustKind(t, "sh(wsh(sortedmulti(2,"+xpub+"/0/*,"+xpub+"/0/*)))", ScriptMultisigNested)
	mustKind(t, "sh(sortedmulti(2,"+xpub+"/0/*,"+xpub+"/0/*))", ScriptMultisigP2SH)

	// Rejections.
	for _, bad := range []string{
		"tr(" + xpub + ",{pk(" + xpub + ")})", // script tree
		"wpkh(" + xpub + "/2/*)",              // non-standard branch
		"wpkh(" + xpub + "/*)",                // branchless wildcard
		"combo(" + xpub + ")",
		"raw(deadbeef)",
		"",
	} {
		_, err := ParseDescriptor(bad)
		assert.Error(t, err, "must reject %q", bad)
	}
}

func TestParseMultisigDerivesP2WSH(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams
	acct, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, net)
	require.NoError(t, err)
	xpub := neuter(t, acct)

	// A 2-of-3 with three copies of the same key is fine for an address-shape test.
	desc := "wsh(sortedmulti(2," + xpub + "/0/*," + xpub + "/0/*," + xpub + "/0/*))"
	d, err := ParseDescriptor(desc)
	require.NoError(t, err)
	require.Equal(t, ScriptMultisig, d.Kind)
	require.Equal(t, 2, d.Threshold)
	require.Len(t, d.Keys, 3)

	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	_, ok := ds.address.(*btcutil.AddressWitnessScriptHash)
	assert.True(t, ok, "multisig must derive a P2WSH address, got %T", ds.address)
}
