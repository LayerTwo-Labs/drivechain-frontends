package wallet

import (
	"bytes"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// loungeTestKeys derives a reproducible 2-of-3 group from the abandon test
// mnemonic at m/48'/1'/0'/{2,3,4}', the BIP48 multisig account layout. Returned
// keys are already in the order their xpubs sort, so tests can also assert the
// BIP67 string ordering is a no-op here and the descriptor stays stable.
func loungeTestKeys(t *testing.T) (MultisigLoungeGroup, []*hdkeychain.ExtendedKey) {
	t.Helper()
	seed := MnemonicToSeed(testMnemonic, "")
	net := &chaincfg.SigNetParams
	master, err := hdkeychain.NewMaster(seed, net)
	require.NoError(t, err)
	mpub, err := master.ECPubKey()
	require.NoError(t, err)
	fp := hex.EncodeToString(btcutil.Hash160(mpub.SerializeCompressed())[:4])

	const h = hdkeychain.HardenedKeyStart
	keys := make([]MultisigLoungeKey, 0, 3)
	accts := make([]*hdkeychain.ExtendedKey, 0, 3)
	for acct := uint32(2); acct <= 4; acct++ {
		k := master
		for _, p := range []uint32{h + 48, h + 1, h + 0, h + acct} {
			k, err = k.Derive(p)
			require.NoError(t, err)
		}
		pub, err := k.Neuter()
		require.NoError(t, err)
		keys = append(keys, MultisigLoungeKey{
			Xpub:        pub.String(),
			Fingerprint: fp,
			OriginPath:  fmt.Sprintf("48'/1'/0'/%d'", acct),
			IsWallet:    true,
		})
		accts = append(accts, pub)
	}
	return MultisigLoungeGroup{M: 2, N: 3, Keys: keys}, accts
}

// TestBuildDescriptorsGoldenParity pins the Go descriptor output to the exact
// bytes (and checksum) BitWindow's Dart buildWatchOnlyDescriptors produces, which
// was independently confirmed against bitcoind getdescriptorinfo for these keys.
// The single trailing /0/* (resp. /1/*) on the last key is intentional: it
// reproduces the Dart string assembly byte-for-byte. Any drift here would change
// addresses and risk funds, so the strings are hard-pinned.
func TestBuildDescriptorsGoldenParity(t *testing.T) {
	group, _ := loungeTestKeys(t)

	const wantReceive = "wsh(sortedmulti(2,[73c5da0a/48'/1'/0'/2']tpubDFH9dgzveyD8zTbPUFuLrGmCydNvxehyNdUXKJAQN8x4aZ4j6UZqGfnqFrD4NqyaTVGKbvEW54tsvPTK2UoSbCC1PJY8iCNiwTL3RWZEheQ,[73c5da0a/48'/1'/0'/3']tpubDFH9dgzveyD94P86sEzUzWtd2wxFkUoK78rSBqSWyXNuFq46dy4HbPTEZEP4fbSY4L5Vb2LFnm23JeGQppq5SPcPDNuHZU3JQwMSFXLdudh,[73c5da0a/48'/1'/0'/4']tpubDFH9dgzveyD97hF9wTbwFieMpH9LcP5HcmbBS3vu8ijqNnu8djwrD2so8GbXpAzeTw7wwPjdKwQX6BTk2o6eCSGHJggkVYnMeBC9ECe9Ufp/0/*))#0mez4m89"
	const wantChange = "wsh(sortedmulti(2,[73c5da0a/48'/1'/0'/2']tpubDFH9dgzveyD8zTbPUFuLrGmCydNvxehyNdUXKJAQN8x4aZ4j6UZqGfnqFrD4NqyaTVGKbvEW54tsvPTK2UoSbCC1PJY8iCNiwTL3RWZEheQ,[73c5da0a/48'/1'/0'/3']tpubDFH9dgzveyD94P86sEzUzWtd2wxFkUoK78rSBqSWyXNuFq46dy4HbPTEZEP4fbSY4L5Vb2LFnm23JeGQppq5SPcPDNuHZU3JQwMSFXLdudh,[73c5da0a/48'/1'/0'/4']tpubDFH9dgzveyD97hF9wTbwFieMpH9LcP5HcmbBS3vu8ijqNnu8djwrD2so8GbXpAzeTw7wwPjdKwQX6BTk2o6eCSGHJggkVYnMeBC9ECe9Ufp/1/*))#fc38wkv3"

	receive, change, err := BuildMultisigLoungeDescriptors(group)
	require.NoError(t, err)
	assert.Equal(t, wantReceive, receive)
	assert.Equal(t, wantChange, change)
}

// TestBuildDescriptorsBIP67Order asserts the key descriptors are emitted in
// ascending xpub-string order regardless of input order, matching the Dart
// _sortKeysByBIP67 (which sorts by xpub string, not serialized pubkey).
func TestBuildDescriptorsBIP67Order(t *testing.T) {
	group, _ := loungeTestKeys(t)
	// Reverse the input order; the output must be unchanged.
	reversed := MultisigLoungeGroup{M: group.M, N: group.N}
	for i := len(group.Keys) - 1; i >= 0; i-- {
		reversed.Keys = append(reversed.Keys, group.Keys[i])
	}

	r1, c1, err := BuildMultisigLoungeDescriptors(group)
	require.NoError(t, err)
	r2, c2, err := BuildMultisigLoungeDescriptors(reversed)
	require.NoError(t, err)
	assert.Equal(t, r1, r2)
	assert.Equal(t, c1, c2)
}

// loungeMultisigPSBT builds a 2-of-3 P2WSH multisig spend with BIP32 derivation
// records matching the group, then signs it with the given account keys to
// produce the requested number of partial signatures.
func loungeMultisigPSBT(t *testing.T, accts []*hdkeychain.ExtendedKey, signWith int) *psbt.Packet {
	t.Helper()
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	const h = hdkeychain.HardenedKeyStart
	keys := make([]DescriptorKey, len(accts))
	for i, a := range accts {
		keys[i] = DescriptorKey{Origin: fmt.Sprintf("73c5da0a/48h/1h/0h/%dh", 2+i), Account: a}
	}
	d := &Descriptor{Kind: ScriptMultisig, Threshold: 2, Keys: keys}
	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	derivs, err := d.derivations(false, 0)
	require.NoError(t, err)

	prevTx := wire.NewMsgTx(2)
	prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))

	privs := make([]*btcec.PrivateKey, 0, signWith)
	for i := 0; i < signWith; i++ {
		p, ok, err := deriveChildPrivIfPossible(accts[i], 0, 0)
		require.NoError(t, err)
		require.True(t, ok)
		privs = append(privs, p)
	}

	in := psbtInput{
		outpoint: wire.OutPoint{Hash: prevTx.TxHash(), Index: 0},
		amount:   amount,
		addr: scannedAddr{
			scriptPubKey: ds.scriptPubKey, witnessScript: ds.witnessScript,
			kind: ScriptMultisig, multisigPrivs: privs, derivations: derivs,
		},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, nil)
	require.NoError(t, err)
	if signWith > 0 {
		_, err = signPSBT(packet, []psbtInput{in}, net)
		require.NoError(t, err)
	}
	return packet
}

// loungeTestAccts derives the private account keys (xprv) for the same
// m/48'/1'/0'/{2,3,4}' paths loungeTestKeys exposes as xpubs, so the PSBTs are
// signed by the very keys the group descriptor commits to.
func loungeTestAccts(t *testing.T) []*hdkeychain.ExtendedKey {
	t.Helper()
	seed := MnemonicToSeed(testMnemonic, "")
	master, err := hdkeychain.NewMaster(seed, &chaincfg.SigNetParams)
	require.NoError(t, err)
	const h = hdkeychain.HardenedKeyStart
	out := make([]*hdkeychain.ExtendedKey, 0, 3)
	for acct := uint32(2); acct <= 4; acct++ {
		k := master
		for _, p := range []uint32{h + 48, h + 1, h + 0, h + acct} {
			k, err = k.Derive(p)
			require.NoError(t, err)
		}
		out = append(out, k)
	}
	return out
}

func psbtToBase64(t *testing.T, p *psbt.Packet) string {
	t.Helper()
	var buf bytes.Buffer
	require.NoError(t, p.Serialize(&buf))
	return base64.StdEncoding.EncodeToString(buf.Bytes())
}

func TestValidatePsbtUnsigned(t *testing.T) {
	accts := loungeTestAccts(t)
	b64 := psbtToBase64(t, loungeMultisigPSBT(t, accts, 0))

	res, err := ValidateMultisigPsbt(b64, 2, nil)
	require.NoError(t, err)
	assert.False(t, res.HasSignatures)
	assert.Equal(t, 0, res.SignatureCount)
	assert.False(t, res.IsComplete)
	assert.False(t, res.Finalizable)
}

func TestValidatePsbtPartial(t *testing.T) {
	accts := loungeTestAccts(t)
	b64 := psbtToBase64(t, loungeMultisigPSBT(t, accts, 1))

	res, err := ValidateMultisigPsbt(b64, 2, nil)
	require.NoError(t, err)
	assert.True(t, res.HasSignatures)
	assert.Equal(t, 1, res.SignatureCount)
	assert.False(t, res.IsComplete, "1 of 2 required must not be complete")
	assert.False(t, res.Finalizable)
}

func TestValidatePsbtComplete(t *testing.T) {
	accts := loungeTestAccts(t)
	b64 := psbtToBase64(t, loungeMultisigPSBT(t, accts, 2))

	res, err := ValidateMultisigPsbt(b64, 2, nil)
	require.NoError(t, err)
	assert.True(t, res.HasSignatures)
	assert.Equal(t, 2, res.SignatureCount)
	assert.True(t, res.IsComplete)
	assert.True(t, res.Finalizable, "2 of 2 required must finalize")
}

// TestValidatePsbtGroupMatch accepts a PSBT whose inputs carry the group's
// cosigner origins, and rejects a foreign PSBT built from unrelated keys.
func TestValidatePsbtGroupMatch(t *testing.T) {
	group, _ := loungeTestKeys(t)
	accts := loungeTestAccts(t)

	own := psbtToBase64(t, loungeMultisigPSBT(t, accts, 1))
	res, err := ValidateMultisigPsbt(own, 2, &group)
	require.NoError(t, err)
	assert.True(t, res.HasSignatures)

	foreign := psbtToBase64(t, loungeForeignPSBT(t))
	_, err = ValidateMultisigPsbt(foreign, 2, &group)
	require.Error(t, err, "foreign PSBT must be rejected")
	assert.Contains(t, err.Error(), "foreign input rejected")
}

// loungeForeignPSBT builds a 2-of-3 multisig PSBT from a different mnemonic, so
// its BIP32 origins do not match the lounge test group.
func loungeForeignPSBT(t *testing.T) *psbt.Packet {
	t.Helper()
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	const h = hdkeychain.HardenedKeyStart

	master, err := hdkeychain.NewMaster(MnemonicToSeed(testMnemonic, "foreign"), net)
	require.NoError(t, err)
	mpub, err := master.ECPubKey()
	require.NoError(t, err)
	fp := hex.EncodeToString(btcutil.Hash160(mpub.SerializeCompressed())[:4])

	keys := make([]DescriptorKey, 0, 3)
	for acct := uint32(2); acct <= 4; acct++ {
		k := master
		for _, p := range []uint32{h + 48, h + 1, h + 0, h + acct} {
			k, err = k.Derive(p)
			require.NoError(t, err)
		}
		keys = append(keys, DescriptorKey{Origin: fmt.Sprintf("%s/48h/1h/0h/%dh", fp, acct), Account: k})
	}
	d := &Descriptor{Kind: ScriptMultisig, Threshold: 2, Keys: keys}
	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	derivs, err := d.derivations(false, 0)
	require.NoError(t, err)

	prevTx := wire.NewMsgTx(2)
	prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
	in := psbtInput{
		outpoint: wire.OutPoint{Hash: prevTx.TxHash(), Index: 0},
		amount:   amount,
		addr: scannedAddr{
			scriptPubKey: ds.scriptPubKey, witnessScript: ds.witnessScript,
			kind: ScriptMultisig, derivations: derivs,
		},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, nil)
	require.NoError(t, err)
	return packet
}

func TestValidatePsbtBadBase64(t *testing.T) {
	_, err := ValidateMultisigPsbt("not-base64!!!", 2, nil)
	require.Error(t, err)
}
