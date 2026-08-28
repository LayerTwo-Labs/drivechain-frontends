package wallet

import (
	"bytes"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"math/big"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/ecdsa"
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

// TestPSBTSignSidechainDeposit builds a BIP300/301 M5 deposit: it spends the
// previous treasury (CTIP) output — an anyone-can-spend drivechain output,
// OP_DRIVECHAIN(=OP_NOP5) OP_PUSHBYTES_1 <S> OP_TRUE — together with an electrum
// wallet input, and creates the new larger treasury at index 0 plus wallet
// change. Only the wallet input is signed; the spend of both inputs must verify
// through txscript.Engine.
func TestPSBTSignSidechainDeposit(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.SigNetParams
	const (
		walletAmount  = int64(1_000_000)
		oldCtip       = int64(500_000)
		depositAmount = int64(400_000)
		fee           = int64(1_000)
	)
	const sidechainNum = byte(1)

	acct, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, net)
	require.NoError(t, err)
	d := &Descriptor{Kind: ScriptNativeSegwit, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
	ds, pub, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	priv, ok, err := deriveChildPrivIfPossible(acct, 0, 0)
	require.NoError(t, err)
	require.True(t, ok)

	// Treasury scriptPubKey, byte-for-byte per the enforcer's create_m5_deposit_output:
	// OP_DRIVECHAIN OP_PUSHBYTES_1 <S> OP_TRUE.
	drivechainScript := []byte{txscript.OP_NOP5, txscript.OP_DATA_1, sidechainNum, txscript.OP_TRUE}

	// Previous treasury (CTIP) UTXO, and the wallet's funding UTXO.
	treasuryPrev := wire.NewMsgTx(2)
	treasuryPrev.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	treasuryPrev.AddTxOut(wire.NewTxOut(oldCtip, drivechainScript))

	walletPrev := wire.NewMsgTx(2)
	walletPrev.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x01}, nil))
	walletPrev.AddTxOut(wire.NewTxOut(walletAmount, ds.scriptPubKey))

	// M5 deposit: in0 = old treasury, in1 = wallet UTXO; out0 = new treasury
	// (old + deposit), out1 = wallet change.
	newCtip := oldCtip + depositAmount
	change := walletAmount - depositAmount - fee
	tx := wire.NewMsgTx(2)
	tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Hash: treasuryPrev.TxHash(), Index: 0}, nil, nil))
	tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Hash: walletPrev.TxHash(), Index: 0}, nil, nil))
	tx.AddTxOut(wire.NewTxOut(newCtip, drivechainScript))
	tx.AddTxOut(wire.NewTxOut(change, ds.scriptPubKey))

	packet, err := psbt.NewFromUnsignedTx(tx)
	require.NoError(t, err)
	updater, err := psbt.NewUpdater(packet)
	require.NoError(t, err)

	// Treasury input: bare anyone-can-spend, no signature — pre-finalize empty.
	require.NoError(t, updater.AddInNonWitnessUtxo(treasuryPrev, 0))
	packet.Inputs[0].FinalScriptSig = []byte{}

	// Wallet input: signed by the electrum wallet.
	require.NoError(t, updater.AddInWitnessUtxo(wire.NewTxOut(walletAmount, ds.scriptPubKey), 1))
	require.NoError(t, updater.AddInSighashType(txscript.SigHashAll, 1))

	inputs := []psbtInput{
		{outpoint: tx.TxIn[0].PreviousOutPoint, amount: oldCtip, addr: scannedAddr{scriptPubKey: drivechainScript}},
		{outpoint: tx.TxIn[1].PreviousOutPoint, amount: walletAmount, addr: scannedAddr{
			address: ds.address.EncodeAddress(), priv: priv, pub: pub,
			scriptPubKey: ds.scriptPubKey, kind: ScriptNativeSegwit,
		}},
	}
	n, err := signPSBT(packet, inputs, net)
	require.NoError(t, err)
	require.Equal(t, 1, n, "only the wallet input is signed")

	rawHex, err := finalizeAndExtract(packet)
	require.NoError(t, err)
	var final wire.MsgTx
	raw, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	require.NoError(t, final.Deserialize(bytes.NewReader(raw)))

	// New treasury sits at index 0 with the increased value.
	require.Equal(t, drivechainScript, final.TxOut[0].PkScript)
	require.Equal(t, newCtip, final.TxOut[0].Value)

	prevOuts := txscript.NewMultiPrevOutFetcher(map[wire.OutPoint]*wire.TxOut{
		final.TxIn[0].PreviousOutPoint: wire.NewTxOut(oldCtip, drivechainScript),
		final.TxIn[1].PreviousOutPoint: wire.NewTxOut(walletAmount, ds.scriptPubKey),
	})
	sigHashes := txscript.NewTxSigHashes(&final, prevOuts)

	// Treasury input: OP_DRIVECHAIN is a NOP under base script rules, so the
	// output is anyone-can-spend; verify without the upgradable-NOP/cleanstack
	// policy flags (the drivechain node enforces BIP300 separately).
	vmTreasury, err := txscript.NewEngine(drivechainScript, &final, 0, txscript.ScriptBip16, nil, sigHashes, oldCtip, prevOuts)
	require.NoError(t, err)
	require.NoError(t, vmTreasury.Execute(), "treasury input must be spendable")

	// Wallet input: the electrum signature must verify.
	vmWallet, err := txscript.NewEngine(ds.scriptPubKey, &final, 1,
		txscript.StandardVerifyFlags|txscript.ScriptVerifyTaproot, nil, sigHashes, walletAmount, prevOuts)
	require.NoError(t, err)
	require.NoError(t, vmWallet.Execute(), "wallet must validly sign the sidechain deposit")
}

// multisigPacket builds a 2-of-3 P2WSH spend signed by two of the three keys.
func multisigPacket(t *testing.T) (*psbt.Packet, derivedScript, int64) {
	t.Helper()
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acct := func(pass string) *hdkeychain.ExtendedKey {
		a, err := accountKeyFromSeed(hex.EncodeToString(MnemonicToSeed(testMnemonic, pass)), ScriptNativeSegwit, net)
		require.NoError(t, err)
		return a
	}
	priv := func(a *hdkeychain.ExtendedKey) *btcec.PrivateKey {
		p, ok, err := deriveChildPrivIfPossible(a, 0, 0)
		require.NoError(t, err)
		require.True(t, ok)
		return p
	}
	a, b, c := acct("a"), acct("b"), acct("c")
	d := &Descriptor{Kind: ScriptMultisig, Threshold: 2, Keys: []DescriptorKey{{Account: a}, {Account: b}, {Account: c}}}
	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)

	prevTx := wire.NewMsgTx(2)
	prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
	in := psbtInput{
		outpoint: wire.OutPoint{Hash: prevTx.TxHash(), Index: 0},
		amount:   amount,
		addr: scannedAddr{
			scriptPubKey: ds.scriptPubKey, witnessScript: ds.witnessScript,
			kind: ScriptMultisig, multisigPrivs: []*btcec.PrivateKey{priv(a), priv(b)},
		},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, func(string) (*wire.MsgTx, error) { return prevTx, nil })
	require.NoError(t, err)
	_, err = signPSBT(packet, []psbtInput{in}, net)
	require.NoError(t, err)
	return packet, ds, amount
}

// TestFinalizeRejectsSignatureForAnotherTx: a partial signature that covers a
// different transaction must fail before the broadcast, naming the key. Without
// this the finalizer builds a witness the network rejects for a failed
// CHECKMULTISIG, and the user only learns of it from the node.
func TestFinalizeRejectsSignatureForAnotherTx(t *testing.T) {
	packet, _, _ := multisigPacket(t)
	require.Len(t, packet.Inputs[0].PartialSigs, 2)

	packet.UnsignedTx.TxOut[0].Value -= 1

	_, err := finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "signed a different transaction")
}

// TestFinalizeRejectsSignatureOverAnotherScript: a signer that covers the wrong
// k-of-n script — the shape a hardware wallet produces when it rebuilds the
// multisig from incomplete PSBT metadata — is caught before the broadcast.
func TestFinalizeRejectsSignatureOverAnotherScript(t *testing.T) {
	net := &chaincfg.SigNetParams
	packet, ds, amount := multisigPacket(t)

	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	fetcher := txscript.NewCannedPrevOutputFetcher(ds.scriptPubKey, amount)
	sigHashes := txscript.NewTxSigHashes(packet.UnsignedTx, fetcher)
	wrong, err := multisigWitnessScript(2, []*btcec.PublicKey{priv.PubKey(), priv.PubKey()}, net)
	require.NoError(t, err)
	sig, err := txscript.RawTxInWitnessSignature(packet.UnsignedTx, sigHashes, 0, amount, wrong, txscript.SigHashAll, priv)
	require.NoError(t, err)
	packet.Inputs[0].PartialSigs[1] = &psbt.PartialSig{PubKey: priv.PubKey().SerializeCompressed(), Signature: sig}

	_, err = finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "signed a different transaction")
}

// TestCombinePSBTRejectsDifferentTx: an imported cosigner PSBT for another
// transaction must not donate its signatures to this one.
func TestCombinePSBTRejectsDifferentTx(t *testing.T) {
	base, _, _ := multisigPacket(t)
	other, _, _ := multisigPacket(t)
	other.UnsignedTx.TxOut[0].Value -= 1

	err := combinePSBT(base, other)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "different transactions")
}

// TestFinalizeRejectsForeignWitnessScript: an imported PSBT can carry any
// witness script. The check must bind it to the output it spends, or a signer
// that signed the wrong script passes.
func TestFinalizeRejectsForeignWitnessScript(t *testing.T) {
	net := &chaincfg.SigNetParams
	packet, _, _ := multisigPacket(t)

	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	foreign, err := multisigWitnessScript(2, []*btcec.PublicKey{priv.PubKey(), priv.PubKey()}, net)
	require.NoError(t, err)
	packet.Inputs[0].WitnessScript = foreign

	_, err = finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "does not match the output it spends")
}

// TestFinalizeRejectsForeignRedeemScript: the same binding must hold for the
// P2SH redeem script a nested or legacy input carries.
func TestFinalizeRejectsForeignRedeemScript(t *testing.T) {
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acct := func(pass string) *hdkeychain.ExtendedKey {
		a, err := accountKeyFromSeed(hex.EncodeToString(MnemonicToSeed(testMnemonic, pass)), ScriptNativeSegwit, net)
		require.NoError(t, err)
		return a
	}
	priv := func(a *hdkeychain.ExtendedKey) *btcec.PrivateKey {
		p, ok, err := deriveChildPrivIfPossible(a, 0, 0)
		require.NoError(t, err)
		require.True(t, ok)
		return p
	}
	a, b, c := acct("a"), acct("b"), acct("c")
	d := &Descriptor{Kind: ScriptMultisigNested, Threshold: 2, Keys: []DescriptorKey{{Account: a}, {Account: b}, {Account: c}}}
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
			kind: ScriptMultisigNested, multisigPrivs: []*btcec.PrivateKey{priv(a), priv(b)},
		},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, func(string) (*wire.MsgTx, error) { return prevTx, nil })
	require.NoError(t, err)
	_, err = signPSBT(packet, []psbtInput{in}, net)
	require.NoError(t, err)

	other, _, err := (&Descriptor{Kind: ScriptMultisigNested, Threshold: 2, Keys: []DescriptorKey{{Account: b}, {Account: c}, {Account: a}}}).DeriveScript(true, 7, net)
	require.NoError(t, err)
	packet.Inputs[0].RedeemScript = other.redeemScript

	_, err = finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "redeem script does not match the output it spends")
}

// taprootMultisigPacket builds a 2-of-3 tr(sortedmulti_a) spend signed by two keys.
func taprootMultisigPacket(t *testing.T) *psbt.Packet {
	t.Helper()
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acct := func(pass string) *hdkeychain.ExtendedKey {
		a, err := accountKeyFromSeed(hex.EncodeToString(MnemonicToSeed(testMnemonic, pass)), ScriptTaproot, net)
		require.NoError(t, err)
		return a
	}
	priv := func(a *hdkeychain.ExtendedKey) *btcec.PrivateKey {
		p, ok, err := deriveChildPrivIfPossible(a, 0, 0)
		require.NoError(t, err)
		require.True(t, ok)
		return p
	}
	a, b, c := acct("a"), acct("b"), acct("c")
	d := &Descriptor{Kind: ScriptMultisigTaproot, Threshold: 2, Keys: []DescriptorKey{{Account: a}, {Account: b}, {Account: c}}}
	ds, _, err := d.DeriveScript(false, 0, net)
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
			multisigPrivs:   []*btcec.PrivateKey{priv(a), priv(b)},
		},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, nil)
	require.NoError(t, err)
	_, err = signPSBT(packet, []psbtInput{in}, net)
	require.NoError(t, err)
	require.Len(t, packet.Inputs[0].TaprootScriptSpendSig, 2)
	return packet
}

// TestFinalizeTaprootMultisig: the good path still extracts and verifies through
// txscript, with the signature check in place.
func TestFinalizeTaprootMultisig(t *testing.T) {
	packet := taprootMultisigPacket(t)
	prevOut := prevOutForInput(packet, 0)
	require.NotNil(t, prevOut)

	rawHex, err := finalizeAndExtract(packet)
	require.NoError(t, err)

	var final wire.MsgTx
	raw, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	require.NoError(t, final.Deserialize(bytes.NewReader(raw)))
	fetcher := txscript.NewCannedPrevOutputFetcher(prevOut.PkScript, prevOut.Value)
	vm, err := txscript.NewEngine(prevOut.PkScript, &final, 0, txscript.StandardVerifyFlags, nil,
		txscript.NewTxSigHashes(&final, fetcher), prevOut.Value, fetcher)
	require.NoError(t, err)
	require.NoError(t, vm.Execute())
}

// TestFinalizeRejectsTaprootSignatureForAnotherTx: a schnorr signature over
// another transaction must fail before the broadcast, like an ECDSA one.
func TestFinalizeRejectsTaprootSignatureForAnotherTx(t *testing.T) {
	packet := taprootMultisigPacket(t)
	packet.UnsignedTx.TxOut[0].Value -= 1

	_, err := finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "signed a different transaction")
}

// TestFinalizeRejectsForeignLeafScript: an imported PSBT can name any leaf. The
// control block must commit to the output the input spends.
func TestFinalizeRejectsForeignLeafScript(t *testing.T) {
	packet := taprootMultisigPacket(t)
	other := taprootMultisigPacket(t)
	other.Inputs[0].TaprootLeafScript[0].Script = append([]byte{txscript.OP_1, txscript.OP_DROP}, other.Inputs[0].TaprootLeafScript[0].Script...)
	packet.Inputs[0].TaprootLeafScript = other.Inputs[0].TaprootLeafScript

	_, err := finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "does not match the output it spends")
}

// TestFinalizeRejectsForeignKeyForP2PKH: a legacy signature from a key that does
// not hash to the output it spends must fail before the broadcast.
func TestFinalizeRejectsForeignKeyForP2PKH(t *testing.T) {
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acct, err := accountKeyFromSeed(hex.EncodeToString(MnemonicToSeed(testMnemonic, "")), ScriptLegacy, net)
	require.NoError(t, err)
	d := &Descriptor{Kind: ScriptLegacy, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	priv, ok, err := deriveChildPrivIfPossible(acct, 0, 0)
	require.NoError(t, err)
	require.True(t, ok)

	prevTx := wire.NewMsgTx(2)
	prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
	in := psbtInput{
		outpoint: wire.OutPoint{Hash: prevTx.TxHash(), Index: 0},
		amount:   amount,
		addr:     scannedAddr{scriptPubKey: ds.scriptPubKey, priv: priv, pub: priv.PubKey(), kind: ScriptLegacy},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, func(string) (*wire.MsgTx, error) { return prevTx, nil })
	require.NoError(t, err)
	_, err = signPSBT(packet, []psbtInput{in}, net)
	require.NoError(t, err)
	require.Len(t, packet.Inputs[0].PartialSigs, 1)

	foreign, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	sig, err := txscript.RawTxInSignature(packet.UnsignedTx, 0, ds.scriptPubKey, txscript.SigHashAll, foreign)
	require.NoError(t, err)
	packet.Inputs[0].PartialSigs[0] = &psbt.PartialSig{PubKey: foreign.PubKey().SerializeCompressed(), Signature: sig}

	_, err = finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "the key does not match the output it spends")
}

// TestFinalizeRejectsLeafVersionMismatch: the network hashes with the control
// block's leaf version, so a leaf that names another version is refused.
func TestFinalizeRejectsLeafVersionMismatch(t *testing.T) {
	packet := taprootMultisigPacket(t)
	packet.Inputs[0].TaprootLeafScript[0].LeafVersion = txscript.BaseLeafVersion + 2

	_, err := finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "leaf version does not match its control block")
}

// TestFinalizeRejectsForeignPreviousTx: an imported PSBT can carry any previous
// transaction. It must be the one the input spends.
func TestFinalizeRejectsForeignPreviousTx(t *testing.T) {
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acct, err := accountKeyFromSeed(hex.EncodeToString(MnemonicToSeed(testMnemonic, "")), ScriptLegacy, net)
	require.NoError(t, err)
	d := &Descriptor{Kind: ScriptLegacy, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	priv, ok, err := deriveChildPrivIfPossible(acct, 0, 0)
	require.NoError(t, err)
	require.True(t, ok)

	prevTx := wire.NewMsgTx(2)
	prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
	in := psbtInput{
		outpoint: wire.OutPoint{Hash: prevTx.TxHash(), Index: 0},
		amount:   amount,
		addr:     scannedAddr{scriptPubKey: ds.scriptPubKey, priv: priv, pub: priv.PubKey(), kind: ScriptLegacy},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, func(string) (*wire.MsgTx, error) { return prevTx, nil })
	require.NoError(t, err)
	_, err = signPSBT(packet, []psbtInput{in}, net)
	require.NoError(t, err)

	foreign := wire.NewMsgTx(2)
	foreign.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xfffffffe}, []byte{0x01}, nil))
	foreign.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
	packet.Inputs[0].NonWitnessUtxo = foreign

	_, err = finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "not the one it spends")
}

// TestFinalizeTaprootSigHashAll: an external signer can use a non-default
// sighash type. The check must honour it, and the witness must carry the byte.
func TestFinalizeTaprootSigHashAll(t *testing.T) {
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acct := func(pass string) *hdkeychain.ExtendedKey {
		a, err := accountKeyFromSeed(hex.EncodeToString(MnemonicToSeed(testMnemonic, pass)), ScriptTaproot, net)
		require.NoError(t, err)
		return a
	}
	priv := func(a *hdkeychain.ExtendedKey) *btcec.PrivateKey {
		p, ok, err := deriveChildPrivIfPossible(a, 0, 0)
		require.NoError(t, err)
		require.True(t, ok)
		return p
	}
	a, b, c := acct("a"), acct("b"), acct("c")
	d := &Descriptor{Kind: ScriptMultisigTaproot, Threshold: 2, Keys: []DescriptorKey{{Account: a}, {Account: b}, {Account: c}}}
	ds, _, err := d.DeriveScript(false, 0, net)
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
		},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, nil)
	require.NoError(t, err)

	leaf := txscript.NewBaseTapLeaf(ds.tapLeafScript)
	leafHash := leaf.TapHash()
	fetcher := txscript.NewCannedPrevOutputFetcher(ds.scriptPubKey, amount)
	sigHashes := txscript.NewTxSigHashes(packet.UnsignedTx, fetcher)
	for _, p := range []*btcec.PrivateKey{priv(a), priv(b)} {
		// Store it the way the PSBT decoder does: 64 bytes plus the type apart.
		raw, err := txscript.RawTxInTapscriptSignature(
			packet.UnsignedTx, sigHashes, 0, amount, ds.scriptPubKey, leaf, txscript.SigHashAll, p,
		)
		require.NoError(t, err)
		require.Len(t, raw, 65)
		packet.Inputs[0].TaprootScriptSpendSig = append(packet.Inputs[0].TaprootScriptSpendSig, &psbt.TaprootScriptSpendSig{
			XOnlyPubKey: schnorr.SerializePubKey(p.PubKey()),
			LeafHash:    leafHash[:],
			Signature:   raw[:64],
			SigHash:     txscript.SigHashAll,
		})
	}

	rawHex, err := finalizeAndExtract(packet)
	require.NoError(t, err)

	var final wire.MsgTx
	decoded, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	require.NoError(t, final.Deserialize(bytes.NewReader(decoded)))
	vm, err := txscript.NewEngine(ds.scriptPubKey, &final, 0, txscript.StandardVerifyFlags, nil,
		txscript.NewTxSigHashes(&final, fetcher), amount, fetcher)
	require.NoError(t, err)
	require.NoError(t, vm.Execute())
}

// taprootKeySpendPacket builds a signed single-key taproot spend.
func taprootKeySpendPacket(t *testing.T) (*psbt.Packet, derivedScript, int64) {
	t.Helper()
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acct, err := accountKeyFromSeed(hex.EncodeToString(MnemonicToSeed(testMnemonic, "")), ScriptTaproot, net)
	require.NoError(t, err)
	d := &Descriptor{Kind: ScriptTaproot, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
	ds, pub, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	priv, ok, err := deriveChildPrivIfPossible(acct, 0, 0)
	require.NoError(t, err)
	require.True(t, ok)

	prevTx := wire.NewMsgTx(2)
	prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
	in := psbtInput{
		outpoint: wire.OutPoint{Hash: prevTx.TxHash(), Index: 0},
		amount:   amount,
		addr:     scannedAddr{scriptPubKey: ds.scriptPubKey, priv: priv, pub: pub, tapInternal: pub, kind: ScriptTaproot},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, nil)
	require.NoError(t, err)
	_, err = signPSBT(packet, []psbtInput{in}, net)
	require.NoError(t, err)
	require.Len(t, packet.Inputs[0].TaprootKeySpendSig, 64)
	return packet, ds, amount
}

// TestFinalizeTaprootKeySpend: the good path extracts and verifies.
func TestFinalizeTaprootKeySpend(t *testing.T) {
	packet, ds, amount := taprootKeySpendPacket(t)

	rawHex, err := finalizeAndExtract(packet)
	require.NoError(t, err)

	var final wire.MsgTx
	raw, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	require.NoError(t, final.Deserialize(bytes.NewReader(raw)))
	fetcher := txscript.NewCannedPrevOutputFetcher(ds.scriptPubKey, amount)
	vm, err := txscript.NewEngine(ds.scriptPubKey, &final, 0, txscript.StandardVerifyFlags, nil,
		txscript.NewTxSigHashes(&final, fetcher), amount, fetcher)
	require.NoError(t, err)
	require.NoError(t, vm.Execute())
}

// TestFinalizeRejectsKeySpendSigHashMismatch: the finalizer appends the input's
// sighash type to a bare signature, so a disagreement must fail here.
func TestFinalizeRejectsKeySpendSigHashMismatch(t *testing.T) {
	packet, _, _ := taprootKeySpendPacket(t)
	packet.Inputs[0].SighashType = txscript.SigHashAll

	_, err := finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "input sighash type disagree")
}

// TestFinalizeRejectsWrongControlBlockParity: script execution reads the parity
// bit, so a flipped bit must fail here and not at the broadcast.
func TestFinalizeRejectsWrongControlBlockParity(t *testing.T) {
	packet := taprootMultisigPacket(t)
	packet.Inputs[0].TaprootLeafScript[0].ControlBlock[0] ^= 1

	_, err := finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "wrong output key parity")
}

// TestFinalizeRejectsExplicitDefaultSigHash: script verification takes the
// default taproot sighash only in the 64-byte form.
func TestFinalizeRejectsExplicitDefaultSigHash(t *testing.T) {
	packet, _, _ := taprootKeySpendPacket(t)
	packet.Inputs[0].TaprootKeySpendSig = append(packet.Inputs[0].TaprootKeySpendSig, 0x00)

	_, err := finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "drop the default sighash byte")
}

// TestFinalizeRejectsUnknownSigHashType: a standard node refuses an undefined
// sighash byte, so the check must refuse it first.
func TestFinalizeRejectsUnknownSigHashType(t *testing.T) {
	packet, _, _ := multisigPacket(t)
	sig := packet.Inputs[0].PartialSigs[0].Signature
	packet.Inputs[0].PartialSigs[0].Signature = append(append([]byte(nil), sig[:len(sig)-1]...), 0x04)

	_, err := finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "unknown sighash type 0x4")
}

// TestFinalizeRejectsForeignFinalWitness: a cosigner can hand back a PSBT it
// finalized itself. That witness must still spend this transaction's input.
func TestFinalizeRejectsForeignFinalWitness(t *testing.T) {
	packet, _, _ := multisigPacket(t)
	require.NoError(t, psbt.MaybeFinalizeAll(packet))
	require.NotEmpty(t, packet.Inputs[0].FinalScriptWitness)

	packet.UnsignedTx.TxOut[0].Value -= 1

	_, err := finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "does not spend this output")
}

// TestFinalizeAcceptsOwnFinalWitness: the good path stays green once an input
// carries its final witness.
func TestFinalizeAcceptsOwnFinalWitness(t *testing.T) {
	packet, _, _ := multisigPacket(t)
	require.NoError(t, psbt.MaybeFinalizeAll(packet))

	_, err := finalizeAndExtract(packet)
	require.NoError(t, err)
}

// TestFinalizeRejectsLegacyInputWithoutPreviousTx: the finalizer takes its
// witness path whenever a witness utxo is set, so a legacy input signed against
// one lands in the wrong field.
func TestFinalizeRejectsLegacyInputWithoutPreviousTx(t *testing.T) {
	net := &chaincfg.SigNetParams
	const amount = int64(100_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	acct, err := accountKeyFromSeed(hex.EncodeToString(MnemonicToSeed(testMnemonic, "")), ScriptLegacy, net)
	require.NoError(t, err)
	d := &Descriptor{Kind: ScriptLegacy, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
	ds, _, err := d.DeriveScript(false, 0, net)
	require.NoError(t, err)
	priv, ok, err := deriveChildPrivIfPossible(acct, 0, 0)
	require.NoError(t, err)
	require.True(t, ok)

	prevTx := wire.NewMsgTx(2)
	prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
	in := psbtInput{
		outpoint: wire.OutPoint{Hash: prevTx.TxHash(), Index: 0},
		amount:   amount,
		addr:     scannedAddr{scriptPubKey: ds.scriptPubKey, priv: priv, pub: priv.PubKey(), kind: ScriptLegacy},
	}
	out := []TxOutSpec{{Address: dest, AmountBTC: float64(amount-1000) / 1e8}}
	packet, err := buildPSBT([]psbtInput{in}, out, net, func(string) (*wire.MsgTx, error) { return prevTx, nil })
	require.NoError(t, err)
	_, err = signPSBT(packet, []psbtInput{in}, net)
	require.NoError(t, err)

	packet.Inputs[0].NonWitnessUtxo = nil
	packet.Inputs[0].WitnessUtxo = wire.NewTxOut(amount, ds.scriptPubKey)

	_, err = finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "needs its previous transaction")
}

// TestFinalizeVerifiesBarePubKeyScript: a bare standard output is verified like
// any other, so a final scriptSig that does not spend it fails here.
func TestFinalizeVerifiesBarePubKeyScript(t *testing.T) {
	const amount = int64(100_000)

	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	pkScript, err := txscript.NewScriptBuilder().
		AddData(priv.PubKey().SerializeCompressed()).
		AddOp(txscript.OP_CHECKSIG).
		Script()
	require.NoError(t, err)

	prevTx := wire.NewMsgTx(2)
	prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	prevTx.AddTxOut(wire.NewTxOut(amount, pkScript))

	tx := wire.NewMsgTx(2)
	tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Hash: prevTx.TxHash(), Index: 0}, nil, nil))
	tx.AddTxOut(wire.NewTxOut(amount-1000, pkScript))
	packet, err := psbt.NewFromUnsignedTx(tx)
	require.NoError(t, err)
	packet.Inputs[0].NonWitnessUtxo = prevTx

	other, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	sig, err := txscript.RawTxInSignature(tx, 0, pkScript, txscript.SigHashAll, other)
	require.NoError(t, err)
	packet.Inputs[0].FinalScriptSig, err = txscript.NewScriptBuilder().AddData(sig).Script()
	require.NoError(t, err)

	_, err = finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "does not spend this output")
}

// TestFinalizeRejectsHighSSignature: a high-S signature still verifies by
// mathematics, but a standard node refuses it, and the finalizer copies the
// bytes through unchanged.
func TestFinalizeRejectsHighSSignature(t *testing.T) {
	packet, _, _ := multisigPacket(t)
	ps := packet.Inputs[0].PartialSigs[0]
	der := ps.Signature[:len(ps.Signature)-1]
	sig, err := ecdsa.ParseDERSignature(der)
	require.NoError(t, err)

	require.NoError(t, ecdsa.VerifyLowS(der))
	high := highSDER(t, sig)
	require.Error(t, ecdsa.VerifyLowS(high))
	packet.Inputs[0].PartialSigs[0].Signature = append(high, ps.Signature[len(ps.Signature)-1])

	_, err = finalizeAndExtract(packet)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "a standard node refuses")
}

// highSDER re-encodes a signature with the mirrored s value, the form a
// standard node refuses. The library serializer always writes the low form, so
// the DER is built by hand.
func highSDER(t *testing.T, sig *ecdsa.Signature) []byte {
	t.Helper()
	order, ok := new(big.Int).SetString(
		"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", 16,
	)
	require.True(t, ok)
	r := sig.R()
	s := sig.S()
	rBytes := r.Bytes()
	sBytes := s.Bytes()
	high := new(big.Int).Sub(order, new(big.Int).SetBytes(sBytes[:]))

	body := append(derInt(rBytes[:]), derInt(high.Bytes())...)
	return append([]byte{0x30, byte(len(body))}, body...)
}

func derInt(value []byte) []byte {
	for len(value) > 1 && value[0] == 0 {
		value = value[1:]
	}
	if value[0]&0x80 != 0 {
		value = append([]byte{0x00}, value...)
	}
	return append([]byte{0x02, byte(len(value))}, value...)
}
