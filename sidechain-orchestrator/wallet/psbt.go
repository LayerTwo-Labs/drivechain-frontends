package wallet

import (
	"bytes"
	"encoding/hex"
	"errors"
	"fmt"
	"math"

	"github.com/btcsuite/btcd/btcec/v2"
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
		if kind == ScriptTaproot {
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
		} else if err := updater.AddInWitnessUtxo(wire.NewTxOut(in.amount, in.addr.scriptPubKey), i); err != nil {
			return nil, err
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
		} else if err := updater.AddInSighashType(txscript.SigHashAll, i); err != nil {
			return nil, err
		}
		addBip32Derivations(&packet.Inputs[i], nil, in.addr.kind, in.addr.derivations)
	}

	// Mark owned change outputs so a signer can verify them as its own.
	for i, out := range outputs {
		addBip32Derivations(nil, &packet.Outputs[i], out.Kind, out.Derivations)
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
		}
	}
	return nil
}

func outputToTxOut(out TxOutSpec, net *chaincfg.Params) (*wire.TxOut, error) {
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
