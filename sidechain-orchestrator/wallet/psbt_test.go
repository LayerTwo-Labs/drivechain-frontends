package wallet

import (
	"bytes"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestPSBTSignAllSingleSigTypes builds, signs, finalizes, and extracts a spend
// for each single-sig address type, then executes the spending input through
// txscript.Engine — the authoritative check that the signature is valid for
// that scriptPubKey (legacy ECDSA, segwit BIP143, taproot BIP341 key-spend).
func TestPSBTSignAllSingleSigTypes(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	for _, kind := range []ScriptKind{ScriptLegacy, ScriptNestedSegwit, ScriptNativeSegwit, ScriptTaproot} {
		t.Run(kind.String(), func(t *testing.T) {
			acct, err := accountKeyFromSeed(seedHex, kind, net)
			require.NoError(t, err)
			d := &Descriptor{Kind: kind, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
			ds, pub, err := d.DeriveScript(false, 0, net)
			require.NoError(t, err)
			priv, ok, err := deriveChildPrivIfPossible(acct, 0, 0)
			require.NoError(t, err)
			require.True(t, ok)

			addr := scannedAddr{
				address:      ds.address.EncodeAddress(),
				priv:         priv,
				pub:          pub,
				scriptPubKey: ds.scriptPubKey,
				redeem:       ds.redeemScript,
				tapInternal:  ds.tapInternal,
				kind:         kind,
			}

			// Synthetic prev tx whose output 0 funds our address.
			prevTx := wire.NewMsgTx(2)
			prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
			prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
			prevHash := prevTx.TxHash()

			in := psbtInput{
				outpoint: wire.OutPoint{Hash: prevHash, Index: 0},
				amount:   amount,
				addr:     addr,
			}
			out := TxOutSpec{Address: dest, AmountBTC: float64(amount-1000) / 1e8}

			packet, err := buildPSBT([]psbtInput{in}, []TxOutSpec{out}, net,
				func(string) (*wire.MsgTx, error) { return prevTx, nil })
			require.NoError(t, err)

			n, err := signPSBT(packet, []psbtInput{in}, net)
			require.NoError(t, err)
			require.Equal(t, 1, n)

			rawHex, err := finalizeAndExtract(packet)
			require.NoError(t, err)

			// Execute the spending input against the funding scriptPubKey.
			var final wire.MsgTx
			raw, err := hex.DecodeString(rawHex)
			require.NoError(t, err)
			require.NoError(t, final.Deserialize(bytes.NewReader(raw)))

			fetcher := txscript.NewCannedPrevOutputFetcher(ds.scriptPubKey, amount)
			sigHashes := txscript.NewTxSigHashes(&final, fetcher)
			vm, err := txscript.NewEngine(
				ds.scriptPubKey, &final, 0,
				txscript.StandardVerifyFlags|txscript.ScriptVerifyTaproot,
				nil, sigHashes, amount, fetcher,
			)
			require.NoError(t, err)
			require.NoError(t, vm.Execute(), "%s spend must verify", kind)
		})
	}
}

// TestPSBTMultisig2of3SignCombineFinalize covers the multi-party flow: two
// independent signers each add a partial signature, the packets are combined,
// and the 2-of-3 P2WSH spend finalizes and verifies — while one signature
// alone must not finalize.
func TestPSBTMultisig2of3SignCombineFinalize(t *testing.T) {
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acctXprv := func(pass string) *hdkeychain.ExtendedKey {
		seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, pass))
		acct, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, net)
		require.NoError(t, err)
		return acct
	}
	a, b, c := acctXprv("a"), acctXprv("b"), acctXprv("c")

	d := &Descriptor{Kind: ScriptMultisig, Threshold: 2, Keys: []DescriptorKey{{Account: a}, {Account: b}, {Account: c}}}
	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)

	privAt := func(acct *hdkeychain.ExtendedKey) *btcec.PrivateKey {
		priv, ok, err := deriveChildPrivIfPossible(acct, 0, 0)
		require.NoError(t, err)
		require.True(t, ok)
		return priv
	}

	prevTx := wire.NewMsgTx(2)
	prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
	outpoint := wire.OutPoint{Hash: prevTx.TxHash(), Index: 0}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}

	makeInput := func(privs ...*btcec.PrivateKey) psbtInput {
		return psbtInput{outpoint: outpoint, amount: amount, addr: scannedAddr{
			scriptPubKey: ds.scriptPubKey, witnessScript: ds.witnessScript,
			kind: ScriptMultisig, multisigPrivs: privs,
		}}
	}
	signed := func(privs ...*btcec.PrivateKey) *psbt.Packet {
		in := makeInput(privs...)
		packet, err := buildPSBT([]psbtInput{in}, out, net, nil)
		require.NoError(t, err)
		_, err = signPSBT(packet, []psbtInput{in}, net)
		require.NoError(t, err)
		return packet
	}

	// One signature alone must not finalize a 2-of-3.
	_, err = finalizeAndExtract(signed(privAt(a)))
	require.Error(t, err, "2-of-3 must not finalize with one signature")

	// Two independent signers, combined, finalize and verify.
	packetA, packetB := signed(privAt(a)), signed(privAt(b))
	require.NoError(t, combinePSBT(packetA, packetB))
	rawHex, err := finalizeAndExtract(packetA)
	require.NoError(t, err)

	var final wire.MsgTx
	raw, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	require.NoError(t, final.Deserialize(bytes.NewReader(raw)))
	fetcher := txscript.NewCannedPrevOutputFetcher(ds.scriptPubKey, amount)
	sigHashes := txscript.NewTxSigHashes(&final, fetcher)
	vm, err := txscript.NewEngine(ds.scriptPubKey, &final, 0, txscript.StandardVerifyFlags, nil, sigHashes, amount, fetcher)
	require.NoError(t, err)
	require.NoError(t, vm.Execute(), "2-of-3 multisig spend must verify")
}

// TestPSBTBip32Derivations: the PSBT carries per-input (and change-output)
// BIP32/taproot derivation records — master fingerprint, full path, pubkey —
// so an external signer (Sparrow/hardware) can match its keys. Asserts they
// survive a serialize→reparse round-trip with the correct little-endian
// fingerprint and hardened path.
func TestPSBTBip32Derivations(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	hard := uint32(hdkeychain.HardenedKeyStart)
	wantFp := binary.LittleEndian.Uint32([]byte{0xab, 0xcd, 0x12, 0x34})

	for _, tc := range []struct {
		kind    ScriptKind
		purpose uint32
	}{
		{ScriptNativeSegwit, 84},
		{ScriptTaproot, 86},
	} {
		t.Run(tc.kind.String(), func(t *testing.T) {
			acct, err := accountKeyFromSeed(seedHex, tc.kind, net)
			require.NoError(t, err)
			origin := fmt.Sprintf("abcd1234/%dh/1h/0h", tc.purpose)
			d := &Descriptor{Kind: tc.kind, Threshold: 1, Keys: []DescriptorKey{{Origin: origin, Account: acct}}}

			ds, _, err := d.DeriveScript(false, 3, net)
			require.NoError(t, err)
			derivs, err := d.derivations(false, 3)
			require.NoError(t, err)
			childPub, err := deriveChildPub(acct, 0, 3)
			require.NoError(t, err)

			prevTx := wire.NewMsgTx(2)
			prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
			prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
			in := psbtInput{
				outpoint: wire.OutPoint{Hash: prevTx.TxHash(), Index: 0},
				amount:   amount,
				addr: scannedAddr{
					address: ds.address.EncodeAddress(), pub: childPub,
					scriptPubKey: ds.scriptPubKey, tapInternal: ds.tapInternal,
					kind: tc.kind, derivations: derivs,
				},
			}
			out := TxOutSpec{Address: dest, AmountBTC: float64(amount-1000) / 1e8}

			packet, err := buildPSBT([]psbtInput{in}, []TxOutSpec{out}, net,
				func(string) (*wire.MsgTx, error) { return prevTx, nil })
			require.NoError(t, err)

			var buf bytes.Buffer
			require.NoError(t, packet.Serialize(&buf))
			parsed, err := psbt.NewFromRawBytes(&buf, false)
			require.NoError(t, err)

			wantPath := []uint32{tc.purpose + hard, 1 + hard, 0 + hard, 0, 3}
			if tc.kind == ScriptTaproot {
				require.Len(t, parsed.Inputs[0].TaprootBip32Derivation, 1)
				der := parsed.Inputs[0].TaprootBip32Derivation[0]
				assert.Equal(t, wantFp, der.MasterKeyFingerprint)
				assert.Equal(t, wantPath, der.Bip32Path)
				assert.Equal(t, schnorr.SerializePubKey(childPub), der.XOnlyPubKey)
			} else {
				require.Len(t, parsed.Inputs[0].Bip32Derivation, 1)
				der := parsed.Inputs[0].Bip32Derivation[0]
				assert.Equal(t, wantFp, der.MasterKeyFingerprint)
				assert.Equal(t, wantPath, der.Bip32Path)
				assert.Equal(t, childPub.SerializeCompressed(), der.PubKey)
			}
		})
	}
}

// TestPSBTMultisigWrappers: each sortedmulti wrapper — P2WSH, P2SH-P2WSH, and
// legacy P2SH — builds, signs with 2 of 3 keys, finalizes, and the spend
// verifies through txscript.Engine.
func TestPSBTMultisigWrappers(t *testing.T) {
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acct := func(pass string) *hdkeychain.ExtendedKey {
		acct, err := accountKeyFromSeed(hex.EncodeToString(MnemonicToSeed(testMnemonic, pass)), ScriptNativeSegwit, net)
		require.NoError(t, err)
		return acct
	}
	priv := func(a *hdkeychain.ExtendedKey) *btcec.PrivateKey {
		p, ok, err := deriveChildPrivIfPossible(a, 0, 0)
		require.NoError(t, err)
		require.True(t, ok)
		return p
	}
	a, b, c := acct("a"), acct("b"), acct("c")

	for _, kind := range []ScriptKind{ScriptMultisig, ScriptMultisigNested, ScriptMultisigP2SH} {
		t.Run(kind.String(), func(t *testing.T) {
			d := &Descriptor{Kind: kind, Threshold: 2, Keys: []DescriptorKey{{Account: a}, {Account: b}, {Account: c}}}
			ds, _, err := d.DeriveScript(false, 0, net)
			require.NoError(t, err)

			prevTx := wire.NewMsgTx(2)
			prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
			prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
			in := psbtInput{
				outpoint: wire.OutPoint{Hash: prevTx.TxHash(), Index: 0},
				amount:   amount,
				addr: scannedAddr{
					scriptPubKey: ds.scriptPubKey, redeem: ds.redeemScript, witnessScript: ds.witnessScript,
					kind: kind, multisigPrivs: []*btcec.PrivateKey{priv(a), priv(b)},
				},
			}
			out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}

			packet, err := buildPSBT([]psbtInput{in}, out, net,
				func(string) (*wire.MsgTx, error) { return prevTx, nil })
			require.NoError(t, err)
			_, err = signPSBT(packet, []psbtInput{in}, net)
			require.NoError(t, err)
			rawHex, err := finalizeAndExtract(packet)
			require.NoError(t, err)

			var final wire.MsgTx
			raw, err := hex.DecodeString(rawHex)
			require.NoError(t, err)
			require.NoError(t, final.Deserialize(bytes.NewReader(raw)))
			fetcher := txscript.NewCannedPrevOutputFetcher(ds.scriptPubKey, amount)
			sigHashes := txscript.NewTxSigHashes(&final, fetcher)
			vm, err := txscript.NewEngine(ds.scriptPubKey, &final, 0, txscript.StandardVerifyFlags, nil, sigHashes, amount, fetcher)
			require.NoError(t, err)
			require.NoError(t, vm.Execute(), "%s 2-of-3 spend must verify", kind)
		})
	}
}
