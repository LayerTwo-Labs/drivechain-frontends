package wallet

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os/exec"
	"strings"
	"testing"
	"time"

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
// standard-form bytes and checksum, independently confirmed against bitcoind
// getdescriptorinfo for these keys (receive checksum ha0h82uj, change jgydevv6).
// Every key carries its own /0/* (resp. /1/*) range so all cosigners derive over
// the same chain/index — the form that matches the signing descriptor. Any drift
// here would change addresses and risk funds, so the strings are hard-pinned.
func TestBuildDescriptorsGoldenParity(t *testing.T) {
	group, _ := loungeTestKeys(t)

	const wantReceive = "wsh(sortedmulti(2,[73c5da0a/48'/1'/0'/2']tpubDFH9dgzveyD8zTbPUFuLrGmCydNvxehyNdUXKJAQN8x4aZ4j6UZqGfnqFrD4NqyaTVGKbvEW54tsvPTK2UoSbCC1PJY8iCNiwTL3RWZEheQ/0/*,[73c5da0a/48'/1'/0'/3']tpubDFH9dgzveyD94P86sEzUzWtd2wxFkUoK78rSBqSWyXNuFq46dy4HbPTEZEP4fbSY4L5Vb2LFnm23JeGQppq5SPcPDNuHZU3JQwMSFXLdudh/0/*,[73c5da0a/48'/1'/0'/4']tpubDFH9dgzveyD97hF9wTbwFieMpH9LcP5HcmbBS3vu8ijqNnu8djwrD2so8GbXpAzeTw7wwPjdKwQX6BTk2o6eCSGHJggkVYnMeBC9ECe9Ufp/0/*))#ha0h82uj"
	const wantChange = "wsh(sortedmulti(2,[73c5da0a/48'/1'/0'/2']tpubDFH9dgzveyD8zTbPUFuLrGmCydNvxehyNdUXKJAQN8x4aZ4j6UZqGfnqFrD4NqyaTVGKbvEW54tsvPTK2UoSbCC1PJY8iCNiwTL3RWZEheQ/1/*,[73c5da0a/48'/1'/0'/3']tpubDFH9dgzveyD94P86sEzUzWtd2wxFkUoK78rSBqSWyXNuFq46dy4HbPTEZEP4fbSY4L5Vb2LFnm23JeGQppq5SPcPDNuHZU3JQwMSFXLdudh/1/*,[73c5da0a/48'/1'/0'/4']tpubDFH9dgzveyD97hF9wTbwFieMpH9LcP5HcmbBS3vu8ijqNnu8djwrD2so8GbXpAzeTw7wwPjdKwQX6BTk2o6eCSGHJggkVYnMeBC9ECe9Ufp/1/*))#jgydevv6"

	receive, change, err := BuildMultisigLoungeDescriptors(group)
	require.NoError(t, err)
	assert.Equal(t, wantReceive, receive)
	assert.Equal(t, wantChange, change)
}

// TestBuildDescriptorsScriptTypes verifies the typed builder emits the correct
// outer wrapper per multisig script type, and that the receive descriptor
// round-trips through ParseDescriptor (the form the watch-only path parses).
func TestBuildDescriptorsScriptTypes(t *testing.T) {
	group, _ := loungeTestKeys(t)
	cases := []struct {
		scriptType string
		prefix     string
	}{
		{"wsh", "wsh(sortedmulti("},
		{"sh-wsh", "sh(wsh(sortedmulti("},
		{"sh", "sh(sortedmulti("},
		{"tr", "tr("},
	}
	for _, tc := range cases {
		t.Run(tc.scriptType, func(t *testing.T) {
			receive, change, err := BuildMultisigLoungeDescriptorsTyped(group, tc.scriptType)
			require.NoError(t, err)
			assert.True(t, strings.HasPrefix(receive, tc.prefix), "receive %q", receive)
			assert.True(t, strings.HasPrefix(change, tc.prefix), "change %q", change)
			// The receive descriptor must parse; change (/1/*) is derived from it.
			_, err = ParseDescriptor(receive)
			require.NoError(t, err)
		})
	}
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

// loungeSiblingGroup builds a second 2-of-3 group that shares one account key
// with the lounge test group and draws its other two cosigners from a different
// seed — two groups a single member belongs to.
func loungeSiblingGroup(t *testing.T, shared MultisigLoungeKey) MultisigLoungeGroup {
	t.Helper()
	net := &chaincfg.SigNetParams
	const h = hdkeychain.HardenedKeyStart

	master, err := hdkeychain.NewMaster(MnemonicToSeed(testMnemonic, "sibling"), net)
	require.NoError(t, err)
	mpub, err := master.ECPubKey()
	require.NoError(t, err)
	fp := hex.EncodeToString(btcutil.Hash160(mpub.SerializeCompressed())[:4])

	keys := []MultisigLoungeKey{shared}
	for acct := uint32(5); acct <= 6; acct++ {
		k := master
		for _, p := range []uint32{h + 48, h + 1, h + 0, h + acct} {
			k, err = k.Derive(p)
			require.NoError(t, err)
		}
		pub, nerr := k.Neuter()
		require.NoError(t, nerr)
		keys = append(keys, MultisigLoungeKey{
			Xpub:        pub.String(),
			Fingerprint: fp,
			OriginPath:  fmt.Sprintf("48'/1'/0'/%d'", acct),
		})
	}
	return MultisigLoungeGroup{M: 2, N: 3, Keys: keys}
}

// loungeTaprootPSBT builds the tr(sortedmulti_a) spend of the lounge test group,
// the taproot twin of loungeMultisigPSBT.
func loungeTaprootPSBT(t *testing.T, accts []*hdkeychain.ExtendedKey) *psbt.Packet {
	t.Helper()
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	keys := make([]DescriptorKey, len(accts))
	for i, a := range accts {
		keys[i] = DescriptorKey{Origin: fmt.Sprintf("73c5da0a/48h/1h/0h/%dh", 2+i), Account: a}
	}
	d := &Descriptor{Kind: ScriptMultisigTaproot, Threshold: 2, Keys: keys}
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
			scriptPubKey:    ds.scriptPubKey,
			tapLeafScript:   ds.tapLeafScript,
			tapControlBlock: ds.tapControlBlock,
			tapInternal:     ds.tapInternal,
			kind:            ScriptMultisigTaproot,
			derivations:     derivs,
		},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, nil)
	require.NoError(t, err)
	return packet
}

// A cosigner record that names another child passes the account-prefix check but
// leaves that cosigner deriving a key it cannot sign the input with.
func TestValidatePsbtCosignerChildMismatch(t *testing.T) {
	group, _ := loungeTestKeys(t)
	accts := loungeTestAccts(t)

	packet := loungeMultisigPSBT(t, accts, 0)
	require.Len(t, packet.Inputs[0].Bip32Derivation, 3)
	_, err := ValidateMultisigPsbt(psbtToBase64(t, packet), 2, &group)
	require.NoError(t, err)

	d := packet.Inputs[0].Bip32Derivation[1]
	d.Bip32Path[len(d.Bip32Path)-1] = 6
	_, err = ValidateMultisigPsbt(psbtToBase64(t, packet), 2, &group)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "another child of the group")
}

// A bare-xpub cosigner declares no origin, so only its key ties its record to
// the group. A changed child on that record must still fail.
func TestValidatePsbtBareCosignerChildMismatch(t *testing.T) {
	group, _ := loungeTestKeys(t)
	for i := 1; i < len(group.Keys); i++ {
		group.Keys[i] = MultisigLoungeKey{Xpub: group.Keys[i].Xpub}
	}
	accts := loungeTestAccts(t)

	packet := loungeBareCosignerPSBT(t, accts)
	_, err := ValidateMultisigPsbt(psbtToBase64(t, packet), 2, &group)
	require.NoError(t, err)

	// The first record still carries the true child, so the script check reads
	// the right hint and the tampered record reaches the origin check.
	var bare *psbt.Bip32Derivation
	for _, d := range packet.Inputs[0].Bip32Derivation[1:] {
		if len(d.Bip32Path) == 2 {
			bare = d
		}
	}
	require.NotNil(t, bare, "the group carries a bare-xpub cosigner record")
	bare.Bip32Path[len(bare.Bip32Path)-1] = 6

	_, err = ValidateMultisigPsbt(psbtToBase64(t, packet), 2, &group)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "another child of the group")
}

// A taproot cosigner record must name the leaf it signs, or a signer cannot tell
// which tapscript its key belongs to.
func TestValidatePsbtTaprootLeafHashes(t *testing.T) {
	group, _ := loungeTestKeys(t)
	accts := loungeTestAccts(t)

	packet := loungeTaprootPSBT(t, accts)
	_, err := ValidateMultisigPsbt(psbtToBase64(t, packet), 2, &group)
	require.NoError(t, err, "the group's own taproot spend must validate")

	packet.Inputs[0].TaprootBip32Derivation[1].LeafHashes = nil
	_, err = ValidateMultisigPsbt(psbtToBase64(t, packet), 2, &group)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "does not sign the group's leaf")
}

// TestValidatePsbtStrippedOriginsCrossGroup proves an input is bound to its group
// by the script it derives, not by the derivation records it happens to carry:
// deleting group A's non-shared records leaves only the account key both groups
// hold, which satisfies group B's origin allow-list — but the input still spends
// group A's script and must be rejected.
func TestValidatePsbtStrippedOriginsCrossGroup(t *testing.T) {
	groupA, _ := loungeTestKeys(t)
	accts := loungeTestAccts(t)

	packet := loungeMultisigPSBT(t, accts, 0)
	require.Len(t, packet.Inputs[0].Bip32Derivation, 3)
	// Delete every record except the shared key's (m/48'/1'/0'/2', the first
	// cosigner) — a deletion, forging nothing.
	packet.Inputs[0].Bip32Derivation = packet.Inputs[0].Bip32Derivation[:1]
	stripped := psbtToBase64(t, packet)

	_, err := ValidateMultisigPsbt(stripped, 2, &groupA)
	require.NoError(t, err, "stripping records must not break the owning group")

	groupB := loungeSiblingGroup(t, groupA.Keys[0])
	_, err = ValidateMultisigPsbt(stripped, 2, &groupB)
	require.Error(t, err, "group A's input must not validate against group B")
	assert.Contains(t, err.Error(), "foreign input rejected")
}

// loungeBareCosignerPSBT builds the spend a group with one wallet key and two
// bare-xpub cosigners produces: only the wallet key carries a [fp/origin], so the
// other two derivation records fall back to the xpub's own self-root fingerprint
// and a chain/index-only path — what Core emits for a prefix-less descriptor key.
func loungeBareCosignerPSBT(t *testing.T, accts []*hdkeychain.ExtendedKey) *psbt.Packet {
	t.Helper()
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	keys := make([]DescriptorKey, len(accts))
	for i, a := range accts {
		keys[i] = DescriptorKey{Account: a}
	}
	keys[0].Origin = "73c5da0a/48h/1h/0h/2h"
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

// TestValidatePsbtBareXpubCosigners accepts a group's own spend when its external
// cosigners were added as bare xpubs (no fingerprint/origin, the UI default): the
// watch descriptor emits those keys without a prefix, so their derivation records
// carry a fingerprint the group's origin allow-list cannot contain. A foreign
// input is still rejected, by the script binding.
func TestValidatePsbtBareXpubCosigners(t *testing.T) {
	group, _ := loungeTestKeys(t)
	for i := 1; i < len(group.Keys); i++ {
		group.Keys[i] = MultisigLoungeKey{Xpub: group.Keys[i].Xpub}
	}
	accts := loungeTestAccts(t)

	packet := loungeBareCosignerPSBT(t, accts)
	bare := 0
	for _, d := range packet.Inputs[0].Bip32Derivation {
		if len(d.Bip32Path) == 2 {
			bare++
		}
	}
	require.Equal(t, 2, bare, "the two bare-xpub cosigners carry chain/index-only paths")

	res, err := ValidateMultisigPsbt(psbtToBase64(t, packet), 2, &group)
	require.NoError(t, err, "a group's own spend must not be rejected over external cosigner metadata")
	assert.False(t, res.HasSignatures)

	foreign := psbtToBase64(t, loungeForeignPSBT(t))
	_, err = ValidateMultisigPsbt(foreign, 2, &group)
	require.Error(t, err, "foreign PSBT must still be rejected")
	assert.Contains(t, err.Error(), "foreign input rejected")
}

func TestValidatePsbtBadBase64(t *testing.T) {
	_, err := ValidateMultisigPsbt("not-base64!!!", 2, nil)
	require.Error(t, err)
}

// loungeSigningDescriptors builds the signing-style descriptors for the test
// group: the first cosigner's key as an xprv, the others as xpubs, each ranged
// /0/* (receive) and /1/* (change) — mirroring the Dart buildSigningDescriptors
// output. This is the descriptor the wallet signs with; it must derive the same
// addresses the watch-only (all-xpub) descriptor receives to.
func loungeSigningDescriptors(t *testing.T, group MultisigLoungeGroup) (receive, change string) {
	t.Helper()
	const h = hdkeychain.HardenedKeyStart
	master, err := hdkeychain.NewMaster(MnemonicToSeed(testMnemonic, ""), &chaincfg.SigNetParams)
	require.NoError(t, err)
	signKey := master
	for _, p := range []uint32{h + 48, h + 1, h + 0, h + 2} {
		signKey, err = signKey.Derive(p)
		require.NoError(t, err)
	}
	xprv := signKey.String()

	sorted := sortKeysByBIP67(group.Keys)
	rParts := make([]string, len(sorted))
	cParts := make([]string, len(sorted))
	for i, k := range sorted {
		expr := fmt.Sprintf("[%s/%s]%s", k.Fingerprint, k.OriginPath, k.Xpub)
		if i == 0 {
			expr = fmt.Sprintf("[%s/%s]%s", k.Fingerprint, k.OriginPath, xprv)
		}
		rParts[i] = expr + "/0/*"
		cParts[i] = expr + "/1/*"
	}
	receive = fmt.Sprintf("wsh(sortedmulti(%d,%s))", group.M, strings.Join(rParts, ","))
	change = fmt.Sprintf("wsh(sortedmulti(%d,%s))", group.M, strings.Join(cParts, ","))
	return receive, change
}

// TestDescriptorReceiveEqualsSign is the load-bearing safety check: via bitcoind
// deriveaddresses, the watch-only receive/change descriptors and the signing
// receive/change descriptors must produce the identical first-N addresses. If
// they diverge, the wallet receives to addresses it cannot spend from.
//
// Skips when bitcoin-cli/bitcoind are not on PATH (CI without Core); the pinned
// golden checksums in TestBuildDescriptorsGoldenParity were validated against
// bitcoind out of band.
func TestDescriptorReceiveEqualsSign(t *testing.T) {
	cli, daemon := findBitcoinTools(t)

	group, _ := loungeTestKeys(t)
	watchReceive, watchChange, err := BuildMultisigLoungeDescriptors(group)
	require.NoError(t, err)
	signReceive, signChange := loungeSigningDescriptors(t, group)

	rt := newRegtest(t, cli, daemon)
	defer rt.stop()

	assert.Equal(t,
		rt.deriveAddresses(t, rt.withChecksum(t, signReceive), "[0,4]"),
		rt.deriveAddresses(t, watchReceive, "[0,4]"),
		"watch-only receive descriptor must derive the same addresses the signing descriptor does",
	)
	assert.Equal(t,
		rt.deriveAddresses(t, rt.withChecksum(t, signChange), "[0,4]"),
		rt.deriveAddresses(t, watchChange, "[0,4]"),
		"watch-only change descriptor must derive the same addresses the signing descriptor does",
	)
}

func findBitcoinTools(t *testing.T) (cli, daemon string) {
	t.Helper()
	cli, err := exec.LookPath("bitcoin-cli")
	if err != nil {
		t.Skip("bitcoin-cli not on PATH; skipping receive==sign consistency check")
	}
	daemon, err = exec.LookPath("bitcoind")
	if err != nil {
		t.Skip("bitcoind not on PATH; skipping receive==sign consistency check")
	}
	return cli, daemon
}

type regtest struct {
	cli     string
	dataDir string
}

func newRegtest(t *testing.T, cli, daemon string) *regtest {
	t.Helper()
	dir := t.TempDir()
	cmd := exec.Command(daemon, "-regtest", "-datadir="+dir, "-daemon", "-server=1",
		"-rpcuser=u", "-rpcpassword=p", "-fallbackfee=0.0001")
	require.NoError(t, cmd.Run())
	rt := &regtest{cli: cli, dataDir: dir}

	// Wait for the RPC to come up.
	deadline := time.Now().Add(20 * time.Second)
	for time.Now().Before(deadline) {
		if _, err := rt.call("getblockchaininfo"); err == nil {
			return rt
		}
		time.Sleep(300 * time.Millisecond)
	}
	t.Fatal("bitcoind regtest RPC did not come up")
	return nil
}

func (rt *regtest) stop() {
	_, _ = rt.call("stop")
	// Give bitcoind a moment to release its datadir before t.TempDir cleanup.
	time.Sleep(time.Second)
}

func (rt *regtest) call(args ...string) ([]byte, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	full := append([]string{"-regtest", "-datadir=" + rt.dataDir, "-rpcuser=u", "-rpcpassword=p"}, args...)
	out, err := exec.CommandContext(ctx, rt.cli, full...).Output()
	return out, err
}

func (rt *regtest) withChecksum(t *testing.T, desc string) string {
	t.Helper()
	out, err := rt.call("getdescriptorinfo", desc)
	require.NoError(t, err)
	var info struct {
		Descriptor string `json:"descriptor"`
	}
	require.NoError(t, json.Unmarshal(out, &info))
	require.NotEmpty(t, info.Descriptor)
	return info.Descriptor
}

func (rt *regtest) deriveAddresses(t *testing.T, descWithChecksum, rng string) []string {
	t.Helper()
	desc := descWithChecksum
	if !strings.Contains(desc, "#") {
		desc = rt.withChecksum(t, desc)
	}
	out, err := rt.call("deriveaddresses", desc, rng)
	require.NoError(t, err)
	var addrs []string
	require.NoError(t, json.Unmarshal(out, &addrs))
	require.NotEmpty(t, addrs)
	return addrs
}

// rpc runs a node-scoped RPC and unmarshals JSON into out (out may be nil).
// bitcoin-cli prints bare strings/numbers for scalar results, so a *string out
// receives the trimmed raw output verbatim rather than going through JSON.
func (rt *regtest) rpc(t *testing.T, out interface{}, args ...string) {
	t.Helper()
	res, err := rt.call(args...)
	require.NoError(t, err, "rpc %v", args)
	if out == nil {
		return
	}
	if sp, ok := out.(*string); ok {
		*sp = strings.TrimSpace(string(res))
		return
	}
	require.NoError(t, json.Unmarshal(res, out), "decode %v: %s", args, res)
}

// walletRPC runs a wallet-scoped RPC (-rpcwallet=name).
func (rt *regtest) walletRPC(t *testing.T, wallet string, out interface{}, args ...string) {
	t.Helper()
	rt.rpc(t, out, append([]string{"-rpcwallet=" + wallet}, args...)...)
}

// countPartialSigs decodes a PSBT and returns the max partial-signature count
// across its inputs.
func countPartialSigs(t *testing.T, rt *regtest, psbtBase64 string) int {
	t.Helper()
	var dec struct {
		Inputs []struct {
			PartialSignatures map[string]string `json:"partial_signatures"`
		} `json:"inputs"`
	}
	rt.rpc(t, &dec, "decodepsbt", psbtBase64)
	max := 0
	for _, in := range dec.Inputs {
		if n := len(in.PartialSignatures); n > max {
			max = n
		}
	}
	return max
}

// TestMultisigSignCombineBroadcastE2E is the load-bearing Phase 3 proof: it
// stands up a real regtest bitcoind, creates the 2-of-3 watch-only wallet from
// the Phase-1 descriptors, funds it, builds a spend PSBT, signs with two of the
// three keys via the server-side signing-descriptor path (the exact
// BuildMultisigSigningDescriptors + descriptorprocesspsbt the handler uses),
// combines/finalizes/broadcasts, and asserts the spend confirms and the balance
// moves. It also asserts a 1-of-2-signed PSBT is NOT finalizable (no broadcast).
func TestMultisigSignCombineBroadcastE2E(t *testing.T) {
	cli, daemon := findBitcoinTools(t)
	rt := newRegtest(t, cli, daemon)
	defer rt.stop()

	group, _ := loungeTestKeys(t)
	watchReceive, watchChange, err := BuildMultisigLoungeDescriptors(group)
	require.NoError(t, err)

	// Watch-only multisig wallet: descriptors, no private keys.
	rt.rpc(t, nil, "createwallet", "ms", "true", "true", "", "false", "true")
	importReq := func(desc string, internal bool) map[string]interface{} {
		return map[string]interface{}{
			"desc": desc, "active": true, "internal": internal, "timestamp": "now", "range": []int{0, 20},
		}
	}
	imp, _ := json.Marshal([]map[string]interface{}{importReq(watchReceive, false), importReq(watchChange, true)})
	var impRes []map[string]interface{}
	rt.walletRPC(t, "ms", &impRes, "importdescriptors", string(imp))
	for _, r := range impRes {
		require.Equal(t, true, r["success"], "importdescriptors: %v", r)
	}

	// Funding wallet with spendable coins.
	rt.rpc(t, nil, "createwallet", "fund")
	var fundAddr string
	rt.walletRPC(t, "fund", &fundAddr, "getnewaddress")
	rt.rpc(t, nil, "generatetoaddress", "101", fundAddr)

	// Fund a multisig receive address and confirm it.
	var msAddr string
	rt.walletRPC(t, "ms", &msAddr, "getnewaddress")
	rt.walletRPC(t, "fund", nil, "sendtoaddress", msAddr, "1.0")
	rt.rpc(t, nil, "generatetoaddress", "1", fundAddr)

	var msBalance float64
	rt.walletRPC(t, "ms", &msBalance, "getbalance")
	require.InDelta(t, 1.0, msBalance, 1e-8, "multisig wallet should hold the funded coin")

	// Build an unsigned spend PSBT from the multisig wallet.
	var dest string
	rt.walletRPC(t, "fund", &dest, "getnewaddress")
	outs, _ := json.Marshal([]map[string]float64{{dest: 0.5}})
	opts, _ := json.Marshal(map[string]interface{}{"includeWatching": true, "changeAddress": msAddr})
	var funded struct {
		PSBT string `json:"psbt"`
	}
	rt.walletRPC(t, "ms", &funded, "walletcreatefundedpsbt", "[]", string(outs), "0", string(opts))
	require.NotEmpty(t, funded.PSBT)

	// Sign with two of the three keys via the server-side signing-descriptor path.
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.SigNetParams // tpub network — matches the group keys
	signOnce := func(accountIndex uint32, basePsbt string) string {
		path := fmt.Sprintf("m/48'/1'/0'/%d'", accountIndex)
		xprv, xpub, derr := DeriveAccountXprv(seedHex, path, net)
		require.NoError(t, derr)
		recv, chg, berr := BuildMultisigSigningDescriptors(group, map[string]string{xpub: xprv})
		require.NoError(t, berr)
		descs, _ := json.Marshal([]string{recv, chg})
		var res struct {
			PSBT     string `json:"psbt"`
			Complete bool   `json:"complete"`
		}
		rt.rpc(t, &res, "descriptorprocesspsbt", basePsbt, string(descs), "ALL", "true", "false")
		require.NotEmpty(t, res.PSBT)
		return res.PSBT
	}

	signedA := signOnce(2, funded.PSBT)
	signedB := signOnce(3, funded.PSBT)

	// Negative: one signature alone must NOT finalize a 2-of-3.
	var finOne struct {
		Complete bool `json:"complete"`
	}
	rt.rpc(t, &finOne, "finalizepsbt", signedA)
	require.False(t, finOne.Complete, "a single signature must not finalize a 2-of-3 (no broadcast)")

	// Combine the two partials, finalize, broadcast.
	combineArg, _ := json.Marshal([]string{signedA, signedB})
	var combined string
	rt.rpc(t, &combined, "combinepsbt", string(combineArg))
	var fin struct {
		Hex      string `json:"hex"`
		Complete bool   `json:"complete"`
	}
	rt.rpc(t, &fin, "finalizepsbt", combined)
	require.True(t, fin.Complete, "two of three signatures must finalize")
	require.NotEmpty(t, fin.Hex)

	var txid string
	rt.rpc(t, &txid, "sendrawtransaction", fin.Hex)
	require.Len(t, txid, 64, "broadcast should return a txid")

	// Confirm and assert the balance moved off the multisig wallet.
	rt.rpc(t, nil, "generatetoaddress", "1", fundAddr)
	var afterBalance float64
	rt.walletRPC(t, "ms", &afterBalance, "getbalance")
	require.Less(t, afterBalance, msBalance, "multisig balance must drop after the spend confirms")
}

// multiOwnedKeyGroup builds a 2-of-3 group where the local wallet (abandon seed)
// owns keys at m/48'/1'/0'/{2',3'} and the third cosigner is foreign (a
// different seed the wallet cannot derive). Returns the group plus the two owned
// xprvs keyed by xpub — the exact signWithXprv map the handler assembles when the
// wallet owns multiple keys.
func multiOwnedKeyGroup(t *testing.T) (MultisigLoungeGroup, map[string]string) {
	t.Helper()
	net := &chaincfg.SigNetParams
	const h = hdkeychain.HardenedKeyStart

	ownMaster, err := hdkeychain.NewMaster(MnemonicToSeed(testMnemonic, ""), net)
	require.NoError(t, err)
	ownPub, err := ownMaster.ECPubKey()
	require.NoError(t, err)
	ownFp := hex.EncodeToString(btcutil.Hash160(ownPub.SerializeCompressed())[:4])

	foreignMaster, err := hdkeychain.NewMaster(MnemonicToSeed(testMnemonic, "foreign"), net)
	require.NoError(t, err)
	foreignPub, err := foreignMaster.ECPubKey()
	require.NoError(t, err)
	foreignFp := hex.EncodeToString(btcutil.Hash160(foreignPub.SerializeCompressed())[:4])

	derive := func(master *hdkeychain.ExtendedKey, acct uint32) *hdkeychain.ExtendedKey {
		k := master
		for _, p := range []uint32{h + 48, h + 1, h + 0, h + acct} {
			k, err = k.Derive(p)
			require.NoError(t, err)
		}
		return k
	}

	keys := make([]MultisigLoungeKey, 0, 3)
	signWithXprv := map[string]string{}

	// Two owned keys (the wallet holds both private keys).
	for _, acct := range []uint32{2, 3} {
		priv := derive(ownMaster, acct)
		pub, nerr := priv.Neuter()
		require.NoError(t, nerr)
		keys = append(keys, MultisigLoungeKey{
			Xpub:        pub.String(),
			Fingerprint: ownFp,
			OriginPath:  fmt.Sprintf("48'/1'/0'/%d'", acct),
			IsWallet:    true,
		})
		signWithXprv[pub.String()] = priv.String()
	}

	// One foreign cosigner (wallet cannot derive this xprv).
	foreignPriv := derive(foreignMaster, 2)
	foreignXpub, err := foreignPriv.Neuter()
	require.NoError(t, err)
	keys = append(keys, MultisigLoungeKey{
		Xpub:        foreignXpub.String(),
		Fingerprint: foreignFp,
		OriginPath:  "48'/1'/0'/2'",
		IsWallet:    false,
	})

	return MultisigLoungeGroup{M: 2, N: 3, Keys: keys}, signWithXprv
}

// TestMultisigSignMultiOwnedKeyE2E proves the multi-owned-key path: a 2-of-3
// where ONE wallet holds two of the three keys can fully sign in a SINGLE
// SignTransaction call (no other cosigner), because BuildMultisigSigningDescriptors
// substitutes the xprv for every owned key and descriptorprocesspsbt adds all of
// them at once. Signs once, finalizes, broadcasts, and asserts the spend confirms.
func TestMultisigSignMultiOwnedKeyE2E(t *testing.T) {
	cli, daemon := findBitcoinTools(t)
	rt := newRegtest(t, cli, daemon)
	defer rt.stop()

	group, signWithXprv := multiOwnedKeyGroup(t)
	require.Len(t, signWithXprv, 2, "wallet must own exactly two keys for this test")

	watchReceive, watchChange, err := BuildMultisigLoungeDescriptors(group)
	require.NoError(t, err)

	rt.rpc(t, nil, "createwallet", "ms", "true", "true", "", "false", "true")
	importReq := func(desc string, internal bool) map[string]interface{} {
		return map[string]interface{}{
			"desc": desc, "active": true, "internal": internal, "timestamp": "now", "range": []int{0, 20},
		}
	}
	imp, _ := json.Marshal([]map[string]interface{}{importReq(watchReceive, false), importReq(watchChange, true)})
	var impRes []map[string]interface{}
	rt.walletRPC(t, "ms", &impRes, "importdescriptors", string(imp))
	for _, r := range impRes {
		require.Equal(t, true, r["success"], "importdescriptors: %v", r)
	}

	rt.rpc(t, nil, "createwallet", "fund")
	var fundAddr string
	rt.walletRPC(t, "fund", &fundAddr, "getnewaddress")
	rt.rpc(t, nil, "generatetoaddress", "101", fundAddr)

	var msAddr string
	rt.walletRPC(t, "ms", &msAddr, "getnewaddress")
	rt.walletRPC(t, "fund", nil, "sendtoaddress", msAddr, "1.0")
	rt.rpc(t, nil, "generatetoaddress", "1", fundAddr)

	var msBalance float64
	rt.walletRPC(t, "ms", &msBalance, "getbalance")
	require.InDelta(t, 1.0, msBalance, 1e-8)

	var dest string
	rt.walletRPC(t, "fund", &dest, "getnewaddress")
	outs, _ := json.Marshal([]map[string]float64{{dest: 0.5}})
	opts, _ := json.Marshal(map[string]interface{}{"includeWatching": true, "changeAddress": msAddr})
	var funded struct {
		PSBT string `json:"psbt"`
	}
	rt.walletRPC(t, "ms", &funded, "walletcreatefundedpsbt", "[]", string(outs), "0", string(opts))
	require.NotEmpty(t, funded.PSBT)

	// Build the signing descriptors with BOTH owned xprvs and sign once.
	recv, chg, berr := BuildMultisigSigningDescriptors(group, signWithXprv)
	require.NoError(t, berr)
	descs, _ := json.Marshal([]string{recv, chg})
	var signed struct {
		PSBT string `json:"psbt"`
	}
	rt.rpc(t, &signed, "descriptorprocesspsbt", funded.PSBT, string(descs), "ALL", "true", "false")
	require.NotEmpty(t, signed.PSBT)

	// The single call must have added BOTH owned signatures (the load-bearing
	// check): one descriptorprocesspsbt call signs every owned key.
	sigCount := countPartialSigs(t, rt, signed.PSBT)
	require.Equal(t, 2, sigCount, "a single call must add both owned-key signatures to a 2-of-3")

	// The single signed PSBT finalizes alone — no other cosigner needed.
	var fin struct {
		Hex      string `json:"hex"`
		Complete bool   `json:"complete"`
	}
	rt.rpc(t, &fin, "finalizepsbt", signed.PSBT)
	require.True(t, fin.Complete, "two owned signatures from one call must finalize a 2-of-3")
	require.NotEmpty(t, fin.Hex)

	var txid string
	rt.rpc(t, &txid, "sendrawtransaction", fin.Hex)
	require.Len(t, txid, 64)

	rt.rpc(t, nil, "generatetoaddress", "1", fundAddr)
	var afterBalance float64
	rt.walletRPC(t, "ms", &afterBalance, "getbalance")
	require.Less(t, afterBalance, msBalance, "balance must drop after the single-call multi-key spend")
}

// TestParseMultisigDescriptorRoundTrip parses a built watch-only descriptor back
// into its policy + cosigners, matching the original group.
func TestParseMultisigDescriptorRoundTrip(t *testing.T) {
	group, _ := loungeTestKeys(t)
	receive, _, err := BuildMultisigLoungeDescriptorsTyped(group, "wsh")
	require.NoError(t, err)

	m, n, scriptType, cosigners, err := ParseMultisigConfig(receive)
	require.NoError(t, err)
	assert.Equal(t, 2, m)
	assert.Equal(t, 3, n)
	assert.Equal(t, "wsh", scriptType)
	require.Len(t, cosigners, 3)
	// Every parsed cosigner xpub must be one of the group's keys, with its origin.
	groupXpubs := map[string]bool{}
	for _, k := range group.Keys {
		groupXpubs[k.Xpub] = true
	}
	for _, c := range cosigners {
		assert.True(t, groupXpubs[c.Xpub], "parsed xpub %s must be a group key", c.Xpub)
		assert.Equal(t, "73c5da0a", c.Fingerprint)
		assert.Contains(t, c.OriginPath, "48'/1'/0'/")
	}
}

// TestParseColdcardAndCaravanConfig parses a Coldcard text config and a Caravan
// JSON export into the same 2-of-3 policy + cosigners, normalizing SLIP-132 keys.
func TestParseColdcardAndCaravanConfig(t *testing.T) {
	group, _ := loungeTestKeys(t) // tpub cosigners at 48'/1'/0'/{2,3,4}'
	k := group.Keys

	coldcard := "# Coldcard Multisig setup file\n" +
		"Name: Test\n" +
		"Policy: 2 of 3\n" +
		"Derivation: m/48'/1'/0'/2'\n" +
		"Format: P2WSH\n\n" +
		"73C5DA0A: " + k[0].Xpub + "\n" +
		"73C5DA0A: " + k[1].Xpub + "\n" +
		"73C5DA0A: " + k[2].Xpub + "\n"

	m, n, scriptType, cosigners, err := ParseMultisigConfig(coldcard)
	require.NoError(t, err)
	assert.Equal(t, 2, m)
	assert.Equal(t, 3, n)
	assert.Equal(t, "wsh", scriptType)
	require.Len(t, cosigners, 3)
	assert.Equal(t, k[0].Xpub, cosigners[0].Xpub)
	assert.Equal(t, "73c5da0a", cosigners[0].Fingerprint)
	assert.Equal(t, "48'/1'/0'/2'", cosigners[0].OriginPath)

	caravan := fmt.Sprintf(`{"name":"t","addressType":"P2WSH",`+
		`"quorum":{"requiredSigners":2,"totalSigners":3},`+
		`"extendedPublicKeys":[`+
		`{"xfp":"73C5DA0A","bip32Path":"m/48'/1'/0'/2'","xpub":"%s"},`+
		`{"xfp":"73C5DA0A","bip32Path":"m/48'/1'/0'/3'","xpub":"%s"},`+
		`{"xfp":"73C5DA0A","bip32Path":"m/48'/1'/0'/4'","xpub":"%s"}]}`,
		k[0].Xpub, k[1].Xpub, k[2].Xpub)

	m2, n2, st2, cos2, err := ParseMultisigConfig(caravan)
	require.NoError(t, err)
	assert.Equal(t, 2, m2)
	assert.Equal(t, 3, n2)
	assert.Equal(t, "wsh", st2)
	require.Len(t, cos2, 3)
	assert.Equal(t, "48'/1'/0'/4'", cos2[2].OriginPath)
}

// TestValidateDescriptor reads single-sig and multisig descriptors into their
// policies, and rejects incomplete ones.
func TestValidateDescriptor(t *testing.T) {
	group, _ := loungeTestKeys(t)
	k := group.Keys

	single := fmt.Sprintf("wpkh([%s/%s]%s/0/*)", k[0].Fingerprint, k[0].OriginPath, k[0].Xpub)
	p, err := ValidateDescriptor(single)
	require.NoError(t, err)
	assert.False(t, p.Multisig)
	assert.Equal(t, "wpkh", p.ScriptType)
	assert.Equal(t, 1, p.M)
	assert.Equal(t, 1, p.N)
	require.Len(t, p.Cosigners, 1)
	assert.Equal(t, k[0].Xpub, p.Cosigners[0].Xpub)
	assert.Equal(t, k[0].Fingerprint, p.Cosigners[0].Fingerprint)
	assert.Equal(t, k[0].OriginPath, p.Cosigners[0].OriginPath)

	for _, tc := range []struct{ descriptor, scriptType string }{
		{fmt.Sprintf("pkh(%s)", k[0].Xpub), "pkh"},
		{fmt.Sprintf("sh(wpkh(%s))", k[0].Xpub), "sh-wpkh"},
		{fmt.Sprintf("tr(%s)", k[0].Xpub), "tr"},
	} {
		p, err := ValidateDescriptor(tc.descriptor)
		require.NoError(t, err)
		assert.False(t, p.Multisig)
		assert.Equal(t, tc.scriptType, p.ScriptType)
	}

	receive, _, err := BuildMultisigLoungeDescriptorsTyped(group, "sh-wsh")
	require.NoError(t, err)
	p, err = ValidateDescriptor(receive)
	require.NoError(t, err)
	assert.True(t, p.Multisig)
	assert.Equal(t, "sh-wsh", p.ScriptType)
	assert.Equal(t, 2, p.M)
	assert.Equal(t, 3, p.N)
	require.Len(t, p.Cosigners, 3)

	for _, bad := range []string{
		"",
		"wpkh(Keystore1)",
		fmt.Sprintf("wsh(sortedmulti(4,%s,%s,%s))", k[0].Xpub, k[1].Xpub, k[2].Xpub),
		fmt.Sprintf("combo(%s)", k[0].Xpub),
		fmt.Sprintf("wpkh(%s)#aaaaaaaa", k[0].Xpub),
	} {
		_, err := ValidateDescriptor(bad)
		assert.Error(t, err, "descriptor %q must be rejected", bad)
	}
}

// TestMasterKeyCosignerKeepsOrigin: a cosigner whose xpub is a master key has no
// origin path, but it still needs its [fingerprint] prefix. Without the prefix
// the PSBT carries no global xpub for that leg, and a hardware signer cannot
// rebuild the multisig script it must sign over. The prefix must not move a
// single address.
func TestMasterKeyCosignerKeepsOrigin(t *testing.T) {
	net := &chaincfg.SigNetParams
	group, _ := loungeTestKeys(t)

	master, err := hdkeychain.NewMaster(MnemonicToSeed(testMnemonic, "master"), net)
	require.NoError(t, err)
	pub, err := master.Neuter()
	require.NoError(t, err)
	mpub, err := master.ECPubKey()
	require.NoError(t, err)
	fp := hex.EncodeToString(btcutil.Hash160(mpub.SerializeCompressed())[:4])

	group.Keys[0] = MultisigLoungeKey{Xpub: pub.String(), Fingerprint: fp, IsWallet: true}

	receive, _, err := BuildMultisigLoungeDescriptorsTyped(group, "wsh")
	require.NoError(t, err)
	assert.Contains(t, receive, "["+fp+"]"+pub.String())

	d, err := ParseDescriptor(receive)
	require.NoError(t, err)
	assert.Len(t, multisigGlobalXpubs(d), 3, "every cosigner must reach the PSBT as a global xpub")

	bare := group
	bare.Keys = append([]MultisigLoungeKey(nil), group.Keys...)
	bare.Keys[0].IsWallet = false
	bareReceive, _, err := BuildMultisigLoungeDescriptorsTyped(bare, "wsh")
	require.NoError(t, err)
	bareDesc, err := ParseDescriptor(bareReceive)
	require.NoError(t, err)

	for i := uint32(0); i < 3; i++ {
		with, _, err := d.DeriveScript(false, i, net)
		require.NoError(t, err)
		without, _, err := bareDesc.DeriveScript(false, i, net)
		require.NoError(t, err)
		assert.Equal(t, without.address.String(), with.address.String())
	}
}

// TestAccountKeyWithoutOriginStaysBare: an account key with a fingerprint but no
// path must not claim a master origin. That origin names a child the device
// never derives, and every input then fails on the device.
func TestAccountKeyWithoutOriginStaysBare(t *testing.T) {
	group, accts := loungeTestKeys(t)
	require.Greater(t, accts[0].Depth(), uint8(0))

	group.Keys[0] = MultisigLoungeKey{
		Xpub:        accts[0].String(),
		Fingerprint: group.Keys[0].Fingerprint,
		IsWallet:    true,
	}

	receive, _, err := BuildMultisigLoungeDescriptorsTyped(group, "wsh")
	require.NoError(t, err)
	assert.NotContains(t, receive, "["+group.Keys[0].Fingerprint+"]"+accts[0].String())
	assert.Contains(t, receive, accts[0].String()+"/0/*")

	d, err := ParseDescriptor(receive)
	require.NoError(t, err)
	assert.Len(t, multisigGlobalXpubs(d), 2)
}
