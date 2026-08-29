package wallet

import (
	"bytes"
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"errors"
	"fmt"
	"math"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/ecdsa"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

// psbtInput is one input to spend: its outpoint, amount, and the wallet
// derivation/signing metadata (scriptPubKey, redeem/tap material, keys, kind).
type psbtInput struct {
	outpoint wire.OutPoint
	amount   int64
	addr     scannedAddr
	// external marks a non-wallet input spent with an empty scriptSig (no
	// signing); it is added via its previous transaction and pre-finalized.
	external bool
}

// keyDerivation is a PSBT BIP32/taproot derivation record: a pubkey, the master
// key fingerprint, and the full path to it, so an external signer (Sparrow,
// hardware) can match the key it holds to this input or output.
type keyDerivation struct {
	pub         *btcec.PublicKey
	fingerprint uint32
	path        []uint32
}

// addBip32Derivations writes a script kind's derivation records onto a PSBT
// input or output; taproot uses the dedicated taproot field. Exactly one of
// in/out is non-nil.
func addBip32Derivations(in *psbt.PInput, out *psbt.POutput, kind ScriptKind, ds []keyDerivation) {
	for _, kd := range ds {
		if kind == ScriptTaproot || kind.isTaprootMultisig() {
			tap := &psbt.TaprootBip32Derivation{
				XOnlyPubKey:          schnorr.SerializePubKey(kd.pub),
				LeafHashes:           [][]byte{},
				MasterKeyFingerprint: kd.fingerprint,
				Bip32Path:            kd.path,
			}
			if in != nil {
				in.TaprootBip32Derivation = append(in.TaprootBip32Derivation, tap)
			} else {
				out.TaprootBip32Derivation = append(out.TaprootBip32Derivation, tap)
			}
			continue
		}
		bip32 := &psbt.Bip32Derivation{
			PubKey:               kd.pub.SerializeCompressed(),
			MasterKeyFingerprint: kd.fingerprint,
			Bip32Path:            kd.path,
		}
		if in != nil {
			in.Bip32Derivation = append(in.Bip32Derivation, bip32)
		} else {
			out.Bip32Derivation = append(out.Bip32Derivation, bip32)
		}
	}
}

// multisigGlobalXpubs returns PSBT global xpub records for every cosigner, which
// hardware signers need to register the multisig. Nil for single-key descriptors.
func multisigGlobalXpubs(d *Descriptor) []psbt.XPub {
	if len(d.Keys) < 2 {
		return nil
	}
	xpubs := make([]psbt.XPub, 0, len(d.Keys))
	for _, k := range d.Keys {
		fp, path, ok := parseOrigin(k.Origin)
		if !ok {
			continue
		}
		pub, err := k.Account.Neuter()
		if err != nil {
			continue
		}
		xpubs = append(xpubs, psbt.XPub{
			ExtendedKey:          psbt.EncodeExtendedKey(pub),
			MasterKeyFingerprint: fp,
			Bip32Path:            path,
		})
	}
	return xpubs
}

// prevTxFunc fetches a previous transaction by txid — needed to populate the
// non-witness UTXO for legacy (P2PKH) inputs.
type prevTxFunc func(txid string) (*wire.MsgTx, error)

// buildPSBT assembles an unsigned PSBT spending the given inputs to the given
// outputs, populated with the witness/non-witness UTXO, redeem/witness scripts,
// taproot internal keys, and sighash type each input needs to be signed.
func buildPSBT(inputs []psbtInput, outputs []TxOutSpec, net *chaincfg.Params, prevTx prevTxFunc) (*psbt.Packet, error) {
	tx := wire.NewMsgTx(2)
	for _, in := range inputs {
		txIn := wire.NewTxIn(&in.outpoint, nil, nil)
		txIn.Sequence = bip125Sequence
		tx.AddTxIn(txIn)
	}
	for _, out := range outputs {
		txOut, err := outputToTxOut(out, net)
		if err != nil {
			return nil, err
		}
		tx.AddTxOut(txOut)
	}

	packet, err := psbt.NewFromUnsignedTx(tx)
	if err != nil {
		return nil, fmt.Errorf("new psbt: %w", err)
	}
	updater, err := psbt.NewUpdater(packet)
	if err != nil {
		return nil, fmt.Errorf("psbt updater: %w", err)
	}

	for i, in := range inputs {
		// External inputs (e.g. an anyone-can-spend sidechain CTIP) are added
		// via their previous transaction and pre-finalized with an empty
		// scriptSig — they carry no keys and are never signed.
		if in.external {
			if prevTx == nil {
				return nil, fmt.Errorf("external input %d needs the previous transaction", i)
			}
			pt, err := prevTx(in.outpoint.Hash.String())
			if err != nil {
				return nil, fmt.Errorf("fetch prev tx for external input %d: %w", i, err)
			}
			if err := updater.AddInNonWitnessUtxo(pt, i); err != nil {
				return nil, err
			}
			packet.Inputs[i].FinalScriptSig = []byte{}
			continue
		}
		if in.addr.kind.isNonWitness() {
			if prevTx == nil {
				return nil, fmt.Errorf("legacy input %d needs the previous transaction", i)
			}
			pt, err := prevTx(in.outpoint.Hash.String())
			if err != nil {
				return nil, fmt.Errorf("fetch prev tx for input %d: %w", i, err)
			}
			if err := updater.AddInNonWitnessUtxo(pt, i); err != nil {
				return nil, err
			}
		} else {
			if err := updater.AddInWitnessUtxo(wire.NewTxOut(in.amount, in.addr.scriptPubKey), i); err != nil {
				return nil, err
			}
			// Trezor verifies every input against its full previous transaction.
			if prevTx != nil {
				if pt, err := prevTx(in.outpoint.Hash.String()); err == nil {
					_ = updater.AddInNonWitnessUtxo(pt, i)
				}
			}
		}

		if in.addr.redeem != nil {
			if err := updater.AddInRedeemScript(in.addr.redeem, i); err != nil {
				return nil, err
			}
		}
		if in.addr.witnessScript != nil {
			if err := updater.AddInWitnessScript(in.addr.witnessScript, i); err != nil {
				return nil, err
			}
		}
		if in.addr.kind == ScriptTaproot {
			packet.Inputs[i].TaprootInternalKey = schnorr.SerializePubKey(in.addr.tapInternal)
			addBip32Derivations(&packet.Inputs[i], nil, in.addr.kind, in.addr.derivations)
		} else if in.addr.kind.isTaprootMultisig() {
			addTaprootMultisigInputFields(&packet.Inputs[i], in.addr)
		} else {
			if err := updater.AddInSighashType(txscript.SigHashAll, i); err != nil {
				return nil, err
			}
			addBip32Derivations(&packet.Inputs[i], nil, in.addr.kind, in.addr.derivations)
		}
	}

	// Mark owned change outputs so a signer can verify them as its own. The
	// scripts go with the paths: a signer that gets a change path alone rebuilds
	// the output as a single-key one, and it then signs a transaction that pays
	// somewhere else.
	for i, out := range outputs {
		addBip32Derivations(nil, &packet.Outputs[i], out.Kind, out.Derivations)
		if len(out.RedeemScript) > 0 {
			if err := updater.AddOutRedeemScript(out.RedeemScript, i); err != nil {
				return nil, err
			}
		}
		if len(out.WitnessScript) > 0 {
			if err := updater.AddOutWitnessScript(out.WitnessScript, i); err != nil {
				return nil, err
			}
		}
	}
	return packet, nil
}

// signPSBT signs each input the wallet holds the key for, in place. inputs is
// aligned by index with packet.Inputs and carries the per-input key + script
// kind. It returns the number of inputs signed; inputs without a private key
// (a cosigner's, or watch-only) are left for another signer.
func signPSBT(packet *psbt.Packet, inputs []psbtInput, net *chaincfg.Params) (int, error) {
	tx := packet.UnsignedTx
	fetcher := txscript.NewMultiPrevOutFetcher(nil)
	for i := range packet.Inputs {
		out := prevOutForInput(packet, i)
		if out == nil {
			return 0, fmt.Errorf("input %d missing prevout", i)
		}
		fetcher.AddPrevOut(tx.TxIn[i].PreviousOutPoint, out)
	}
	sigHashes := txscript.NewTxSigHashes(tx, fetcher)

	updater, err := psbt.NewUpdater(packet)
	if err != nil {
		return 0, err
	}

	signed := 0
	for i := range inputs {
		if inputs[i].external {
			continue // pre-finalized, anyone-can-spend; nothing to sign
		}
		n, err := signPSBTInput(packet, updater, i, inputs[i], tx, sigHashes, net)
		if err != nil {
			return signed, fmt.Errorf("sign input %d: %w", i, err)
		}
		signed += n
	}
	return signed, nil
}

func signPSBTInput(
	packet *psbt.Packet,
	updater *psbt.Updater,
	i int,
	in psbtInput,
	tx *wire.MsgTx,
	sigHashes *txscript.TxSigHashes,
	net *chaincfg.Params,
) (int, error) {
	if in.addr.kind.isMultisig() {
		return signMultisigInput(packet, i, in, tx, sigHashes, net)
	}
	if in.addr.kind.isTaprootMultisig() {
		return signTaprootMultisigInput(packet, i, in, tx, sigHashes)
	}
	priv := in.addr.priv
	if priv == nil {
		return 0, nil // key not held here
	}
	pub := in.addr.pub.SerializeCompressed()

	switch in.addr.kind {
	case ScriptLegacy:
		sig, err := txscript.RawTxInSignature(tx, i, in.addr.scriptPubKey, txscript.SigHashAll, priv)
		if err != nil {
			return 0, err
		}
		if _, err := updater.Sign(i, sig, pub, nil, nil); err != nil {
			return 0, err
		}
	case ScriptNativeSegwit:
		sig, err := txscript.RawTxInWitnessSignature(tx, sigHashes, i, in.amount, in.addr.scriptPubKey, txscript.SigHashAll, priv)
		if err != nil {
			return 0, err
		}
		if _, err := updater.Sign(i, sig, pub, nil, nil); err != nil {
			return 0, err
		}
	case ScriptNestedSegwit:
		// The P2SH redeem script is the P2WPKH witness program; the BIP143
		// sighash derives the P2PKH scriptCode from it internally.
		sig, err := txscript.RawTxInWitnessSignature(tx, sigHashes, i, in.amount, in.addr.redeem, txscript.SigHashAll, priv)
		if err != nil {
			return 0, err
		}
		if _, err := updater.Sign(i, sig, pub, in.addr.redeem, nil); err != nil {
			return 0, err
		}
	case ScriptTaproot:
		witness, err := txscript.TaprootWitnessSignature(tx, sigHashes, i, in.amount, in.addr.scriptPubKey, txscript.SigHashDefault, priv)
		if err != nil {
			return 0, err
		}
		packet.Inputs[i].TaprootKeySpendSig = witness[0]
	default:
		return 0, fmt.Errorf("cannot sign script kind %s", in.addr.kind)
	}
	return 1, nil
}

func prevOutForInput(packet *psbt.Packet, i int) *wire.TxOut {
	in := packet.Inputs[i]
	if in.WitnessUtxo != nil {
		return in.WitnessUtxo
	}
	if in.NonWitnessUtxo != nil {
		vout := packet.UnsignedTx.TxIn[i].PreviousOutPoint.Index
		if int(vout) < len(in.NonWitnessUtxo.TxOut) {
			return in.NonWitnessUtxo.TxOut[int(vout)]
		}
	}
	return nil
}

// finalizeAndExtract finalizes a fully-signed PSBT and returns the raw tx hex.
func finalizeAndExtract(packet *psbt.Packet) (string, error) {
	if err := verifySignatures(packet); err != nil {
		return "", err
	}
	// tr(sortedmulti_a) inputs are finalized by assembling the tapscript witness
	// ourselves; the generic finalizer then sees them as already final.
	for i := range packet.Inputs {
		if len(packet.Inputs[i].TaprootLeafScript) > 0 {
			if err := finalizeTaprootMultisigInput(packet, i); err != nil {
				return "", fmt.Errorf("finalize taproot multisig input %d: %w", i, err)
			}
		}
	}
	if err := psbt.MaybeFinalizeAll(packet); err != nil {
		return "", fmt.Errorf("finalize psbt: %w", err)
	}
	final, err := psbt.Extract(packet)
	if err != nil {
		return "", fmt.Errorf("extract psbt: %w", err)
	}
	var buf bytes.Buffer
	if err := final.Serialize(&buf); err != nil {
		return "", fmt.Errorf("serialize final tx: %w", err)
	}
	return hex.EncodeToString(buf.Bytes()), nil
}

// verifySignatures checks every signature against the sighash it must cover. A
// signer that covers the wrong transaction, script, or amount still returns a
// well-formed signature, and the network then rejects the spend for a failed
// script check. Catch it here and name the key that produced it.
func verifySignatures(packet *psbt.Packet) error {
	tx := packet.UnsignedTx
	prevOuts := make(map[wire.OutPoint]*wire.TxOut, len(packet.Inputs))
	for i := range packet.Inputs {
		out, err := authenticatedPrevOut(packet, i)
		if err != nil {
			return fmt.Errorf("psbt input %d %w", i, err)
		}
		if out == nil {
			return fmt.Errorf("psbt input %d missing prevout", i)
		}
		prevOuts[tx.TxIn[i].PreviousOutPoint] = out
	}
	fetcher := txscript.NewMultiPrevOutFetcher(prevOuts)
	sigHashes := txscript.NewTxSigHashes(tx, fetcher)
	for i := range packet.Inputs {
		in := &packet.Inputs[i]
		prevOut := prevOuts[tx.TxIn[i].PreviousOutPoint]
		if in.FinalScriptSig != nil || in.FinalScriptWitness != nil {
			if err := verifyFinalInput(tx, fetcher, i, in, prevOut); err != nil {
				return fmt.Errorf("psbt input %d: %w", i, err)
			}
			continue
		}
		for _, ps := range in.PartialSigs {
			if err := verifyPartialSig(tx, sigHashes, i, in, prevOut, ps); err != nil {
				return fmt.Errorf("psbt input %d: %w", i, err)
			}
		}
		if err := verifyTaprootSigs(tx, sigHashes, fetcher, i, in, prevOut); err != nil {
			return fmt.Errorf("psbt input %d: %w", i, err)
		}
	}
	return nil
}

// verifyFinalInput runs script verification over an input that already carries a
// final scriptSig or witness, so a cosigner that finalized for another
// transaction cannot reach the network. A prevout the standard rules do not
// describe — a BIP300 treasury output — is left to the chain.
func verifyFinalInput(
	tx *wire.MsgTx,
	fetcher txscript.PrevOutputFetcher,
	i int,
	in *psbt.PInput,
	prevOut *wire.TxOut,
) error {
	if !standardPrevOut(prevOut.PkScript) {
		return nil
	}
	final := tx.Copy()
	final.TxIn[i].SignatureScript = in.FinalScriptSig
	if len(in.FinalScriptWitness) > 0 {
		witness, err := readWitnessStack(in.FinalScriptWitness)
		if err != nil {
			return err
		}
		final.TxIn[i].Witness = witness
	}
	vm, err := txscript.NewEngine(
		prevOut.PkScript, final, i, txscript.StandardVerifyFlags, nil,
		txscript.NewTxSigHashes(final, fetcher), prevOut.Value, fetcher,
	)
	if err != nil {
		return fmt.Errorf("the final script is not spendable: %w", err)
	}
	if err := vm.Execute(); err != nil {
		return fmt.Errorf("the final script does not spend this output: %w", err)
	}
	return nil
}

func standardPrevOut(pkScript []byte) bool {
	switch txscript.GetScriptClass(pkScript) {
	case txscript.PubKeyTy, txscript.PubKeyHashTy, txscript.MultiSigTy, txscript.ScriptHashTy,
		txscript.WitnessV0PubKeyHashTy, txscript.WitnessV0ScriptHashTy, txscript.WitnessV1TaprootTy:
		return true
	}
	return false
}

// maxWitnessItems caps a witness stack read from an imported PSBT.
const maxWitnessItems = 1000

func readWitnessStack(raw []byte) (wire.TxWitness, error) {
	r := bytes.NewReader(raw)
	count, err := wire.ReadVarInt(r, 0)
	if err != nil {
		return nil, fmt.Errorf("read witness count: %w", err)
	}
	if count > maxWitnessItems {
		return nil, fmt.Errorf("the witness holds %d items", count)
	}
	stack := make(wire.TxWitness, count)
	for j := range stack {
		item, err := wire.ReadVarBytes(r, 0, txscript.MaxScriptSize, "witness item")
		if err != nil {
			return nil, fmt.Errorf("read witness item %d: %w", j, err)
		}
		stack[j] = item
	}
	return stack, nil
}

// verifyTaprootSigs checks a taproot input's schnorr signatures, key-path and
// script-path alike, and binds every revealed leaf to the output it spends.
func verifyTaprootSigs(
	tx *wire.MsgTx,
	sigHashes *txscript.TxSigHashes,
	fetcher txscript.PrevOutputFetcher,
	i int,
	in *psbt.PInput,
	prevOut *wire.TxOut,
) error {
	if len(in.TaprootKeySpendSig) == 0 && len(in.TaprootScriptSpendSig) == 0 {
		return nil
	}
	if !txscript.IsPayToTaproot(prevOut.PkScript) {
		return errors.New("the input carries a taproot signature but spends no taproot output")
	}
	outputKey := prevOut.PkScript[2:34]
	if err := verifyTaprootLeaves(in, outputKey); err != nil {
		return err
	}
	if len(in.TaprootKeySpendSig) > 0 {
		pub, err := schnorr.ParsePubKey(outputKey)
		if err != nil {
			return fmt.Errorf("the output key is not a public key: %w", err)
		}
		sig, hashType, err := splitSchnorrSig(in.TaprootKeySpendSig)
		if err != nil {
			return err
		}
		// The finalizer appends the input's sighash type to a bare 64-byte
		// signature, so the two must agree or the witness commits to another
		// hash than the signer covered.
		if len(in.TaprootKeySpendSig) == schnorr.SignatureSize && in.SighashType != txscript.SigHashDefault {
			return errors.New("the key-spend signature and the input sighash type disagree")
		}
		hash, err := txscript.CalcTaprootSignatureHash(sigHashes, hashType, tx, i, fetcher)
		if err != nil {
			return err
		}
		if !sig.Verify(hash, pub) {
			return fmt.Errorf("key %x signed a different transaction", outputKey)
		}
	}
	for _, s := range in.TaprootScriptSpendSig {
		leaf, err := tapLeafForHash(in, s.LeafHash)
		if err != nil {
			return err
		}
		pub, err := schnorr.ParsePubKey(s.XOnlyPubKey)
		if err != nil {
			return fmt.Errorf("key %x is not a public key: %w", s.XOnlyPubKey, err)
		}
		// The decoder splits a tapscript signature: 64 bytes here, the sighash
		// type in its own field.
		sig, err := schnorr.ParseSignature(s.Signature)
		if err != nil {
			return fmt.Errorf("key %x gave a malformed signature: %w", s.XOnlyPubKey, err)
		}
		if !validTaprootSigHashType(s.SigHash) {
			return fmt.Errorf("key %x used an unknown sighash type %#x", s.XOnlyPubKey, byte(s.SigHash))
		}
		hash, err := txscript.CalcTapscriptSignaturehash(sigHashes, s.SigHash, tx, i, fetcher, leaf)
		if err != nil {
			return err
		}
		if !sig.Verify(hash, pub) {
			return fmt.Errorf("key %x signed a different transaction", s.XOnlyPubKey)
		}
	}
	return nil
}

// The header bytes of a compressed public key, by the parity of its y coordinate.
const (
	evenYPrefix = 0x02
	oddYPrefix  = 0x03
)

// isCompressedPubKey reports whether a key carries the 33-byte compressed form,
// the only one segwit v0 accepts.
func isCompressedPubKey(pubKey []byte) bool {
	return len(pubKey) == 33 && (pubKey[0] == evenYPrefix || pubKey[0] == oddYPrefix)
}

// verifyTaprootLeaves makes sure each revealed leaf and its control block commit
// to the output key the input spends.
func verifyTaprootLeaves(in *psbt.PInput, outputKey []byte) error {
	for _, l := range in.TaprootLeafScript {
		cb, err := txscript.ParseControlBlock(l.ControlBlock)
		if err != nil {
			return fmt.Errorf("parse taproot control block: %w", err)
		}
		// The witness carries the control block, so its leaf version is the one
		// the network hashes with. A leaf that names another version signs one
		// script and spends another.
		if l.LeafVersion != cb.LeafVersion {
			return errors.New("the leaf version does not match its control block")
		}
		key := txscript.ComputeTaprootOutputKey(cb.InternalKey, cb.RootHash(l.Script))
		if !bytes.Equal(schnorr.SerializePubKey(key), outputKey) {
			return errors.New("the leaf script does not match the output it spends")
		}
		// Script execution also reads the parity bit, so the control block must
		// state the parity of the key it commits to.
		if cb.OutputKeyYIsOdd != (key.SerializeCompressed()[0] == oddYPrefix) {
			return errors.New("the control block states the wrong output key parity")
		}
	}
	return nil
}

func tapLeafForHash(in *psbt.PInput, leafHash []byte) (txscript.TapLeaf, error) {
	for _, l := range in.TaprootLeafScript {
		leaf := txscript.NewTapLeaf(l.LeafVersion, l.Script)
		hash := leaf.TapHash()
		if bytes.Equal(hash[:], leafHash) {
			return leaf, nil
		}
	}
	return txscript.TapLeaf{}, errors.New("the signature names a leaf script the input does not carry")
}

// validSigHashType reports whether a sighash byte is one script verification
// accepts: a base type of ALL, NONE, or SINGLE, plus the optional ANYONECANPAY bit.
func validSigHashType(t txscript.SigHashType) bool {
	switch t &^ txscript.SigHashAnyOneCanPay {
	case txscript.SigHashAll, txscript.SigHashNone, txscript.SigHashSingle:
		return true
	}
	return false
}

// validTaprootSigHashType is validSigHashType plus the BIP341 default type.
func validTaprootSigHashType(t txscript.SigHashType) bool {
	return t == txscript.SigHashDefault || validSigHashType(t)
}

// splitSchnorrSig separates a key-path signature from its optional sighash byte.
func splitSchnorrSig(raw []byte) (*schnorr.Signature, txscript.SigHashType, error) {
	hashType := txscript.SigHashDefault
	switch len(raw) {
	case schnorr.SignatureSize:
	case schnorr.SignatureSize + 1:
		hashType = txscript.SigHashType(raw[schnorr.SignatureSize])
		// Script verification takes the default type only in the 64-byte form.
		if hashType == txscript.SigHashDefault {
			return nil, 0, errors.New("a signature must drop the default sighash byte")
		}
		raw = raw[:schnorr.SignatureSize]
	default:
		return nil, 0, fmt.Errorf("a schnorr signature is not %d bytes long", len(raw))
	}
	if !validTaprootSigHashType(hashType) {
		return nil, 0, fmt.Errorf("unknown sighash type %#x", byte(hashType))
	}
	sig, err := schnorr.ParseSignature(raw)
	if err != nil {
		return nil, 0, fmt.Errorf("malformed schnorr signature: %w", err)
	}
	return sig, hashType, nil
}

func verifyPartialSig(
	tx *wire.MsgTx,
	sigHashes *txscript.TxSigHashes,
	i int,
	in *psbt.PInput,
	prevOut *wire.TxOut,
	ps *psbt.PartialSig,
) error {
	if len(ps.Signature) < 2 {
		return fmt.Errorf("key %s gave an empty signature", signerName(in, ps.PubKey))
	}
	pub, err := btcec.ParsePubKey(ps.PubKey)
	if err != nil {
		return fmt.Errorf("key %s is not a public key: %w", signerName(in, ps.PubKey), err)
	}
	der := ps.Signature[:len(ps.Signature)-1]
	sig, err := ecdsa.ParseDERSignature(der)
	if err != nil {
		return fmt.Errorf("key %s gave a malformed signature: %w", signerName(in, ps.PubKey), err)
	}
	// A standard node refuses a high-S signature, and the finalizer copies these
	// bytes through unchanged.
	if err := ecdsa.VerifyLowS(der); err != nil {
		return fmt.Errorf("key %s gave a signature a standard node refuses: %w", signerName(in, ps.PubKey), err)
	}
	hashType := txscript.SigHashType(ps.Signature[len(ps.Signature)-1])
	if !validSigHashType(hashType) {
		return fmt.Errorf("key %s used an unknown sighash type %#x", signerName(in, ps.PubKey), byte(hashType))
	}
	hash, err := partialSigHash(tx, sigHashes, i, in, prevOut, ps.PubKey, hashType)
	if err != nil {
		return err
	}
	if !sig.Verify(hash, pub) {
		// A hardware signer rebuilds a multisig script from the packet's
		// derivation records, so a key it cannot place gives it a script nobody
		// else holds. Name what the signature covers, or the report says only
		// that a key is wrong.
		return fmt.Errorf("key %s signed a different transaction: %s; %d of %d keys in this input carry a key origin, witness script %x",
			signerName(in, ps.PubKey), signedInstead(tx, sigHashes, i, in, prevOut, ps.PubKey, sig, pub, hashType),
			keysWithOrigin(in), len(in.Bip32Derivation), sha256.Sum256(in.WitnessScript))
	}
	return nil
}

// signedInstead names what a rejected signature covers. A hardware signer builds
// its own sighash from the packet, so the way its result differs from this
// packet identifies the fault: a signer that treats a multisig input as
// single-sig, one that keeps the cosigner order the descriptor sorts, one that
// takes a different amount or a different sighash type.
func signedInstead(
	tx *wire.MsgTx,
	sigHashes *txscript.TxSigHashes,
	i int,
	in *psbt.PInput,
	prevOut *wire.TxOut,
	pubKey []byte,
	sig *ecdsa.Signature,
	pub *btcec.PublicKey,
	hashType txscript.SigHashType,
) string {
	covers := func(hash []byte, err error) bool {
		return err == nil && sig.Verify(hash, pub)
	}

	if code, err := p2wpkhScriptCode(btcutil.Hash160(pubKey)); err == nil {
		if covers(txscript.CalcWitnessSigHash(code, sigHashes, hashType, tx, i, prevOut.Value)) {
			return "it signed this input as single-key p2wpkh, not as multisig"
		}
	}
	if covers(txscript.CalcSignatureHash(in.WitnessScript, hashType, tx, i)) {
		return "it signed the legacy sighash, which omits the input amount"
	}
	if order, ok := multisigKeyOrderThatMatches(tx, sigHashes, i, in, prevOut, hashType, covers); ok {
		return fmt.Sprintf("it built the multisig script with the keys in the order %v; this wallet sorts them", order)
	}
	if name, ok := anotherKeyInScript(in, pubKey, sig, tx, sigHashes, i, prevOut, hashType); ok {
		return fmt.Sprintf("the signature belongs to %s, another key in this script", name)
	}
	for _, t := range []txscript.SigHashType{
		txscript.SigHashAll, txscript.SigHashNone, txscript.SigHashSingle,
		txscript.SigHashAll | txscript.SigHashAnyOneCanPay,
		txscript.SigHashNone | txscript.SigHashAnyOneCanPay,
		txscript.SigHashSingle | txscript.SigHashAnyOneCanPay,
	} {
		if t == hashType {
			continue
		}
		if covers(txscript.CalcWitnessSigHash(in.WitnessScript, sigHashes, t, tx, i, prevOut.Value)) {
			return fmt.Sprintf("it signed sighash type %#x and reported %#x", byte(t), byte(hashType))
		}
	}
	var paid int64
	for _, o := range tx.TxOut {
		paid += o.Value
	}
	for _, v := range []int64{0, paid} {
		if v == prevOut.Value {
			continue
		}
		if covers(txscript.CalcWitnessSigHash(in.WitnessScript, sigHashes, hashType, tx, i, v)) {
			return fmt.Sprintf("it signed the amount %d, and this input holds %d", v, prevOut.Value)
		}
	}
	return "no known signer fault matches the signature"
}

// multisigKeyOrderThatMatches finds a key order whose script the signature
// covers. A descriptor with sortedmulti sorts its keys; a signer that builds
// the script in any other order signs a script this wallet never holds.
func multisigKeyOrderThatMatches(
	tx *wire.MsgTx,
	sigHashes *txscript.TxSigHashes,
	i int,
	in *psbt.PInput,
	prevOut *wire.TxOut,
	hashType txscript.SigHashType,
	covers func([]byte, error) bool,
) ([]int, bool) {
	m, n, ok := multisigLimits(in.WitnessScript)
	if !ok || n != len(in.Bip32Derivation) || n > 6 {
		return nil, false
	}
	keys := make([][]byte, n)
	for k, d := range in.Bip32Derivation {
		keys[k] = d.PubKey
	}
	order := make([]int, n)
	for k := range order {
		order[k] = k
	}
	var found []int
	permute(order, 0, func(p []int) bool {
		b := txscript.NewScriptBuilder().AddInt64(int64(m))
		for _, k := range p {
			b.AddData(keys[k])
		}
		script, err := b.AddInt64(int64(n)).AddOp(txscript.OP_CHECKMULTISIG).Script()
		if err != nil || bytes.Equal(script, in.WitnessScript) {
			return false
		}
		if !covers(txscript.CalcWitnessSigHash(script, sigHashes, hashType, tx, i, prevOut.Value)) {
			return false
		}
		found = append([]int(nil), p...)
		return true
	})
	return found, found != nil
}

// permute calls fn for each order of xs and stops at the first true answer.
func permute(xs []int, k int, fn func([]int) bool) bool {
	if k == len(xs) {
		return fn(xs)
	}
	for j := k; j < len(xs); j++ {
		xs[k], xs[j] = xs[j], xs[k]
		if permute(xs, k+1, fn) {
			return true
		}
		xs[k], xs[j] = xs[j], xs[k]
	}
	return false
}

// anotherKeyInScript names the key a signature really covers when the packet
// files it under a different one. A signer that derives one key and reports
// another gives a signature no key in the packet explains.
func anotherKeyInScript(
	in *psbt.PInput,
	pubKey []byte,
	sig *ecdsa.Signature,
	tx *wire.MsgTx,
	sigHashes *txscript.TxSigHashes,
	i int,
	prevOut *wire.TxOut,
	hashType txscript.SigHashType,
) (string, bool) {
	hash, err := txscript.CalcWitnessSigHash(in.WitnessScript, sigHashes, hashType, tx, i, prevOut.Value)
	if err != nil {
		return "", false
	}
	for _, d := range in.Bip32Derivation {
		if bytes.Equal(d.PubKey, pubKey) {
			continue
		}
		pub, err := btcec.ParsePubKey(d.PubKey)
		if err != nil || !sig.Verify(hash, pub) {
			continue
		}
		return signerName(in, d.PubKey), true
	}
	return "", false
}

// multisigInRecordOrder rebuilds a bare multisig script from an input's
// derivation records, keeping the order the packet lists them in. A descriptor
// with sortedmulti sorts its keys, so a signer that keeps packet order builds
// this script instead.
func multisigInRecordOrder(in *psbt.PInput) ([]byte, bool) {
	m, n, ok := multisigLimits(in.WitnessScript)
	if !ok || n != len(in.Bip32Derivation) {
		return nil, false
	}
	b := txscript.NewScriptBuilder().AddInt64(int64(m))
	for _, d := range in.Bip32Derivation {
		b.AddData(d.PubKey)
	}
	script, err := b.AddInt64(int64(n)).AddOp(txscript.OP_CHECKMULTISIG).Script()
	if err != nil {
		return nil, false
	}
	return script, true
}

// multisigLimits reads the m and the n of a bare multisig script.
func multisigLimits(script []byte) (int, int, bool) {
	if len(script) < 3 || script[len(script)-1] != txscript.OP_CHECKMULTISIG {
		return 0, 0, false
	}
	small := func(op byte) (int, bool) {
		if op < txscript.OP_1 || op > txscript.OP_16 {
			return 0, false
		}
		return int(op-txscript.OP_1) + 1, true
	}
	m, ok := small(script[0])
	if !ok {
		return 0, 0, false
	}
	n, ok := small(script[len(script)-2])
	if !ok {
		return 0, 0, false
	}
	return m, n, true
}

// keysWithOrigin counts an input's derivation records that name a real path. A
// bare xpub cosigner has none, and a signer cannot place that key.
func keysWithOrigin(in *psbt.PInput) int {
	n := 0
	for _, d := range in.Bip32Derivation {
		if len(d.Bip32Path) > 2 {
			n++
		}
	}
	return n
}

// signerName identifies a partial signature's signer the way the key table
// shows it: the master fingerprint when the input records one, else the pubkey.
func signerName(in *psbt.PInput, pubKey []byte) string {
	for _, d := range in.Bip32Derivation {
		if !bytes.Equal(d.PubKey, pubKey) {
			continue
		}
		var fp [4]byte
		binary.LittleEndian.PutUint32(fp[:], d.MasterKeyFingerprint)
		return hex.EncodeToString(fp[:])
	}
	return hex.EncodeToString(pubKey)
}

// partialSigHash recomputes the sighash one partial signature must cover. Every
// script the PSBT supplies must hash to the output it spends, so an imported
// PSBT cannot point the check at a script of its own choice.
func partialSigHash(
	tx *wire.MsgTx,
	sigHashes *txscript.TxSigHashes,
	i int,
	in *psbt.PInput,
	prevOut *wire.TxOut,
	pubKey []byte,
	hashType txscript.SigHashType,
) ([]byte, error) {
	script := prevOut.PkScript
	if len(in.RedeemScript) > 0 {
		if !txscript.IsPayToScriptHash(script) {
			return nil, errors.New("the input carries a redeem script but spends no script hash")
		}
		if !bytes.Equal(btcutil.Hash160(in.RedeemScript), script[2:22]) {
			return nil, errors.New("the redeem script does not match the output it spends")
		}
		script = in.RedeemScript
	}
	// Segwit v0 takes only a compressed key, and the finalizer copies this one
	// into the witness.
	if txscript.IsPayToWitnessScriptHash(script) || txscript.IsPayToWitnessPubKeyHash(script) {
		if !isCompressedPubKey(pubKey) {
			return nil, errors.New("a segwit input needs a compressed public key")
		}
	}
	switch {
	case txscript.IsPayToWitnessScriptHash(script):
		hash := sha256.Sum256(in.WitnessScript)
		if len(in.WitnessScript) == 0 || !bytes.Equal(hash[:], script[2:34]) {
			return nil, errors.New("the witness script does not match the output it spends")
		}
		return txscript.CalcWitnessSigHash(in.WitnessScript, sigHashes, hashType, tx, i, prevOut.Value)
	case txscript.IsPayToWitnessPubKeyHash(script):
		hash := btcutil.Hash160(pubKey)
		if !bytes.Equal(hash, script[2:22]) {
			return nil, errors.New("the key does not match the output it spends")
		}
		code, err := p2wpkhScriptCode(hash)
		if err != nil {
			return nil, err
		}
		return txscript.CalcWitnessSigHash(code, sigHashes, hashType, tx, i, prevOut.Value)
	default:
		// The finalizer picks its witness path whenever a witness utxo is set,
		// so a legacy input signed against one lands in the wrong field.
		if in.NonWitnessUtxo == nil {
			return nil, errors.New("a legacy input needs its previous transaction")
		}
		if txscript.IsPayToPubKeyHash(script) && !bytes.Equal(btcutil.Hash160(pubKey), script[3:23]) {
			return nil, errors.New("the key does not match the output it spends")
		}
		return txscript.CalcSignatureHash(script, hashType, tx, i)
	}
}

func p2wpkhScriptCode(keyHash []byte) ([]byte, error) {
	return txscript.NewScriptBuilder().
		AddOp(txscript.OP_DUP).
		AddOp(txscript.OP_HASH160).
		AddData(keyHash).
		AddOp(txscript.OP_EQUALVERIFY).
		AddOp(txscript.OP_CHECKSIG).
		Script()
}

// signMultisigInput adds this wallet's partial signature(s) to a P2WSH multisig
// input. Returns 1 if it contributed a signature, 0 if it holds none of the
// input's keys (a cosigner will sign). Finalization happens once the threshold
// of partial sigs is reached.
func signMultisigInput(
	packet *psbt.Packet,
	i int,
	in psbtInput,
	tx *wire.MsgTx,
	sigHashes *txscript.TxSigHashes,
	_ *chaincfg.Params,
) (int, error) {
	// The k-of-n script is the scriptCode signed over: the redeem script for
	// legacy P2SH, the witness script for P2WSH and P2SH-P2WSH.
	legacy := in.addr.kind == ScriptMultisigP2SH
	script := in.addr.witnessScript
	if legacy {
		script = in.addr.redeem
	}
	if script == nil {
		return 0, errors.New("multisig input missing its k-of-n script")
	}
	if len(in.addr.multisigPrivs) == 0 {
		return 0, nil
	}

	added := false
	for _, priv := range in.addr.multisigPrivs {
		pub := priv.PubKey().SerializeCompressed()
		if hasPartialSig(packet.Inputs[i].PartialSigs, pub) {
			continue
		}
		var sig []byte
		var err error
		if legacy {
			sig, err = txscript.RawTxInSignature(tx, i, script, txscript.SigHashAll, priv)
		} else {
			sig, err = txscript.RawTxInWitnessSignature(tx, sigHashes, i, in.amount, script, txscript.SigHashAll, priv)
		}
		if err != nil {
			return 0, err
		}
		packet.Inputs[i].PartialSigs = append(packet.Inputs[i].PartialSigs, &psbt.PartialSig{
			PubKey:    pub,
			Signature: sig,
		})
		added = true
	}
	if added {
		return 1, nil
	}
	return 0, nil
}

func hasPartialSig(sigs []*psbt.PartialSig, pub []byte) bool {
	for _, s := range sigs {
		if bytes.Equal(s.PubKey, pub) {
			return true
		}
	}
	return false
}

// combinePSBT merges partial signatures and scripts from cosigner packets into
// base. All packets must describe the same unsigned transaction.
func combinePSBT(base *psbt.Packet, others ...*psbt.Packet) error {
	for _, o := range others {
		if o.UnsignedTx == nil || base.UnsignedTx == nil {
			return errors.New("psbt has no unsigned transaction")
		}
		if o.UnsignedTx.TxHash() != base.UnsignedTx.TxHash() {
			return errors.New("the psbts describe different transactions")
		}
		if len(o.Inputs) != len(base.Inputs) {
			return errors.New("psbt input count mismatch")
		}
		for i := range base.Inputs {
			bi := &base.Inputs[i]
			oi := o.Inputs[i]
			if bi.WitnessScript == nil {
				bi.WitnessScript = oi.WitnessScript
			}
			if bi.RedeemScript == nil {
				bi.RedeemScript = oi.RedeemScript
			}
			if bi.WitnessUtxo == nil {
				bi.WitnessUtxo = oi.WitnessUtxo
			}
			if bi.NonWitnessUtxo == nil {
				bi.NonWitnessUtxo = oi.NonWitnessUtxo
			}
			for _, ps := range oi.PartialSigs {
				if !hasPartialSig(bi.PartialSigs, ps.PubKey) {
					bi.PartialSigs = append(bi.PartialSigs, ps)
				}
			}
			if bi.TaprootKeySpendSig == nil && len(oi.TaprootKeySpendSig) > 0 {
				bi.TaprootKeySpendSig = oi.TaprootKeySpendSig
			}
			// Taproot script-path (multi_a) multisig: merge each cosigner's
			// tapscript signature and the leaf/derivation metadata, so the
			// sign-a-copy-each-then-combine flow reaches the threshold.
			for _, s := range oi.TaprootScriptSpendSig {
				if !hasTapScriptSig(bi.TaprootScriptSpendSig, s.XOnlyPubKey, s.LeafHash) {
					bi.TaprootScriptSpendSig = append(bi.TaprootScriptSpendSig, s)
				}
			}
			if len(bi.TaprootLeafScript) == 0 {
				bi.TaprootLeafScript = oi.TaprootLeafScript
			}
			if len(bi.TaprootInternalKey) == 0 {
				bi.TaprootInternalKey = oi.TaprootInternalKey
			}
			if len(bi.TaprootMerkleRoot) == 0 {
				bi.TaprootMerkleRoot = oi.TaprootMerkleRoot
			}
			for _, d := range oi.TaprootBip32Derivation {
				found := false
				for _, e := range bi.TaprootBip32Derivation {
					if bytes.Equal(e.XOnlyPubKey, d.XOnlyPubKey) {
						found = true
						break
					}
				}
				if !found {
					bi.TaprootBip32Derivation = append(bi.TaprootBip32Derivation, d)
				}
			}
		}
	}
	return nil
}

func outputToTxOut(out TxOutSpec, net *chaincfg.Params) (*wire.TxOut, error) {
	if out.RawScriptHex != "" {
		script, err := hex.DecodeString(out.RawScriptHex)
		if err != nil {
			return nil, fmt.Errorf("decode raw output script: %w", err)
		}
		return wire.NewTxOut(out.AmountSats, script), nil
	}
	if out.OpReturnHex != "" {
		data, err := hex.DecodeString(out.OpReturnHex)
		if err != nil {
			return nil, fmt.Errorf("decode op_return hex: %w", err)
		}
		script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData(data).Script()
		if err != nil {
			return nil, fmt.Errorf("build op_return script: %w", err)
		}
		return wire.NewTxOut(0, script), nil
	}
	addr, err := btcutil.DecodeAddress(out.Address, net)
	if err != nil {
		return nil, fmt.Errorf("decode address %q: %w", out.Address, err)
	}
	script, err := txscript.PayToAddrScript(addr)
	if err != nil {
		return nil, fmt.Errorf("script for %q: %w", out.Address, err)
	}
	return wire.NewTxOut(int64(math.Round(out.AmountBTC*1e8)), script), nil
}
