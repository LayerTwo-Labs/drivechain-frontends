package wallet

import (
	"encoding/binary"
	"encoding/hex"
	"strings"
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
	mustKind(t, "sh(wpkh("+xpub+"/0/*))", ScriptNestedSegwit)
	mustKind(t, "tr("+xpub+"/<0;1>/*)", ScriptTaproot)
	mustKind(t, "wsh(sortedmulti(2,"+xpub+"/0/*,"+xpub+"/0/*))", ScriptMultisig)
	mustKind(t, "sh(wsh(sortedmulti(2,"+xpub+"/0/*,"+xpub+"/0/*)))", ScriptMultisigNested)
	mustKind(t, "sh(sortedmulti(2,"+xpub+"/0/*,"+xpub+"/0/*))", ScriptMultisigP2SH)

	// Rejections.
	for _, bad := range []string{
		"tr(" + xpub + ",{pk(" + xpub + ")})", // script tree
		"wpkh(" + xpub + "/1/*)",              // change-only branch: derivation ignores it, receive addresses would be from chain 0
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

// TestDescriptorAcceptsMultisigSLIP132: Zpub cosigner keys (Sparrow multisig
// exports) are accepted inside wsh(sortedmulti) and derive the same P2WSH
// address as the canonical xpub form.
func TestDescriptorAcceptsMultisigSLIP132(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams
	acct, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, net)
	require.NoError(t, err)
	xpub := neuter(t, acct)
	zpub := reencodeVersion(t, xpub, 0x02AA7ED3) // Zpub (P2WSH multisig)

	zDesc := "wsh(sortedmulti(2," + zpub + "/0/*," + zpub + "/0/*))"
	d, err := ParseDescriptor(zDesc)
	require.NoError(t, err)
	require.Equal(t, ScriptMultisig, d.Kind, "wrapper sets the kind, not the Zpub header")
	zScript, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)

	xDesc := "wsh(sortedmulti(2," + xpub + "/0/*," + xpub + "/0/*))"
	dx, err := ParseDescriptor(xDesc)
	require.NoError(t, err)
	xScript, _, err := dx.DeriveScript(false, 0, net)
	require.NoError(t, err)
	assert.Equal(t, xScript.address.EncodeAddress(), zScript.address.EncodeAddress(),
		"Zpub remaps to the same key as xpub")
}

// TestHotWalletOriginPath: a seeded wallet's PSBT derivation carries the real
// master fingerprint and full BIP path (purpose'/coin'/0'/change/index), not the
// account key's own fingerprint, so Sparrow/hardware signers match the key.
func TestHotWalletOriginPath(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.MainNetParams
	acct, origin, err := accountKeyAndOrigin(seedHex, AccountPath{Purpose: 84, Coin: 0, Account: 0}, net)
	require.NoError(t, err)
	assert.Regexp(t, `^[0-9a-f]{8}/84h/0h/0h$`, origin)

	d := &Descriptor{Kind: ScriptNativeSegwit, Threshold: 1, Keys: []DescriptorKey{{Origin: origin, Account: acct}}}
	derivs, err := d.derivations(false, 7)
	require.NoError(t, err)
	require.Len(t, derivs, 1)

	h := uint32(hdkeychain.HardenedKeyStart)
	assert.Equal(t, []uint32{84 + h, 0 + h, 0 + h, 0, 7}, derivs[0].path)

	seed, _ := hex.DecodeString(seedHex)
	master, _ := hdkeychain.NewMaster(seed, net)
	masterPub, _ := master.ECPubKey()
	wantFp := binary.LittleEndian.Uint32(btcutil.Hash160(masterPub.SerializeCompressed())[:4])
	assert.Equal(t, wantFp, derivs[0].fingerprint, "uses the master fingerprint")
	assert.NotEqual(t, keyFingerprint(acct), derivs[0].fingerprint, "not the account fingerprint")
}

// TestDeriveWalletReceiveAddresses proves the address preview derives against the
// wallet's REAL kind and account: a taproot wallet yields P2TR receive addresses
// (matching its descriptor), and a custom-account wallet yields that account's
// addresses (not BIP84 account 0).
func TestDeriveWalletReceiveAddresses(t *testing.T) {
	net := &chaincfg.SigNetParams
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))

	// realReceiveAddrs derives the descriptor's first count receive addresses for
	// the given kind/account — the addresses the wallet actually receives to.
	realReceiveAddrs := func(t *testing.T, w *WalletData, kind ScriptKind, count int) []string {
		ap, err := accountPathFor(w, kind, net)
		require.NoError(t, err)
		acct, _, err := accountKeyAndOrigin(seedHex, ap, net)
		require.NoError(t, err)
		d := &Descriptor{Kind: kind, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
		out := make([]string, count)
		for i := 0; i < count; i++ {
			ds, _, err := d.DeriveScript(false, uint32(i), net)
			require.NoError(t, err)
			out[i] = ds.address.EncodeAddress()
		}
		return out
	}

	t.Run("taproot wallet yields P2TR addresses", func(t *testing.T) {
		svc := newTestService(t)
		w, err := svc.CreateElectrumWallet("Taproot", nil, nil, testMnemonic, "", "taproot", 0, "")
		require.NoError(t, err)

		got, err := DeriveWalletReceiveAddresses(w, net, 0, 3)
		require.NoError(t, err)
		require.Len(t, got, 3)
		for _, a := range got {
			assert.True(t, strings.HasPrefix(a, "tb1p"), "taproot receive address must be bech32m, got %s", a)
		}
		assert.Equal(t, realReceiveAddrs(t, w, ScriptTaproot, 3), got, "must match the wallet's real taproot receive addresses")

		// And it must NOT equal the hardcoded BIP84 native-segwit derivation.
		bip84, err := DeriveBIP84Addresses(seedHex, net, 0, 3)
		require.NoError(t, err)
		assert.NotEqual(t, bip84, got, "taproot preview must differ from BIP84")
	})

	t.Run("custom account yields that account's addresses", func(t *testing.T) {
		svc := newTestService(t)
		const acctIndex = uint32(5)
		w, err := svc.CreateElectrumWallet("Acct5", nil, nil, testMnemonic, "", "", acctIndex, "")
		require.NoError(t, err)
		require.Equal(t, acctIndex, w.AccountIndex)

		got, err := DeriveWalletReceiveAddresses(w, net, 0, 3)
		require.NoError(t, err)
		assert.Equal(t, realReceiveAddrs(t, w, ScriptNativeSegwit, 3), got, "must match account-5 receive addresses")

		// Account 5 differs from account 0 (the old hardcoded behavior).
		acct0, err := DeriveBIP84Addresses(seedHex, net, 0, 3)
		require.NoError(t, err)
		assert.NotEqual(t, acct0, got, "custom-account preview must differ from account 0")
	})
}
