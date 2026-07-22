package wallet

import (
	"math"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
)

// dustRelayFeeRate is Bitcoin Core's fixed dust relay fee (sat/vB). Dust is
// feeRate-independent: an output is dust when its value is below the cost to
// relay it plus the cost to spend it later, both at this rate.
const dustRelayFeeRate = 3

// inputVsize is the vbytes to spend one single-sig input of a kind (Bitcoin Core
// / drongo estimates; witness inputs carry the segwit discount).
func inputVsize(kind ScriptKind) int {
	switch kind {
	case ScriptLegacy:
		return 148
	case ScriptNestedSegwit:
		return 91
	case ScriptTaproot:
		return 58
	default: // native segwit P2WPKH
		return 68
	}
}

// walletInputVsize returns the vbytes to spend one of a wallet's inputs, sized
// from its descriptor — accurate for m-of-n multisig, where the witness scales
// with the threshold and key count rather than a fixed 2-of-3 guess.
func walletInputVsize(d *Descriptor) int {
	switch d.Kind {
	case ScriptMultisig:
		return multisigInputVsize(d.Threshold, len(d.Keys), false)
	case ScriptMultisigNested:
		return multisigInputVsize(d.Threshold, len(d.Keys), true)
	case ScriptMultisigP2SH:
		return p2shMultisigInputVsize(d.Threshold, len(d.Keys))
	case ScriptMultisigTaproot:
		return taprootMultisigInputVsize(d.Threshold, len(d.Keys))
	default:
		return inputVsize(d.Kind)
	}
}

// taprootMultisigInputVsize estimates the vsize of spending a tr(sortedmulti_a)
// input: a P2TR base plus the witness-discounted script-path stack of m 64-byte
// schnorr sigs, (n-m) empty slots, the multi_a leaf script, and the control block.
func taprootMultisigInputVsize(threshold, nKeys int) int {
	leafScript := nKeys*33 + 3 // <32-byte key push> per key, then <m> OP_NUMEQUAL
	witness := 1 +             // stack item count
		threshold*65 + // m signatures (1-byte len + 64-byte schnorr)
		(nKeys - threshold) + // (n-m) empty slots (1 byte each)
		(1 + leafScript) + // leaf script push
		(1 + 33) // control block (single leaf: version + 32-byte internal key)
	base := 32 + 4 + 4 + 1 // outpoint + sequence + empty scriptSig len
	return base + (witness+3)/4
}

// multisigInputVsize estimates the vbytes to spend a P2WSH (or, when nested, a
// P2SH-P2WSH) sortedmulti input with the given threshold and key count.
func multisigInputVsize(threshold, nKeys int, nested bool) int {
	witnessScript := 3 + 34*nKeys // OP_m <nKeys pubkeys> OP_n OP_CHECKMULTISIG
	push := 1
	if witnessScript > 75 {
		push = 2 // OP_PUSHDATA1
	}
	// witness stack: item count + empty (OP_0) + threshold sigs (~72) + script.
	witness := 1 + 1 + threshold*(1+72) + push + witnessScript
	base := 32 + 4 + 4 + 1 // outpoint + sequence + empty scriptSig len
	if nested {
		base += 1 + 34 // scriptSig pushes the 34-byte P2WSH redeem program
	}
	return base + (witness+3)/4 // witness discounted 75%, rounded up
}

// p2shMultisigInputVsize estimates the vbytes to spend a legacy P2SH sortedmulti
// input (no witness discount).
func p2shMultisigInputVsize(threshold, nKeys int) int {
	redeem := 3 + 34*nKeys
	push := 1
	if redeem > 75 {
		push = 2 // OP_PUSHDATA1
	}
	scriptSig := 1 + threshold*(1+72) + push + redeem // OP_0 + sigs + redeemScript
	scriptSigLen := 1
	if scriptSig > 252 {
		scriptSigLen = 3
	}
	return 32 + 4 + 4 + scriptSigLen + scriptSig
}

// outputVsize is the serialized vbytes of one output.
func outputVsize(o TxOutSpec, net *chaincfg.Params) int {
	if o.OpReturnHex != "" {
		return 8 + 1 + 2 + len(o.OpReturnHex)/2 // value + scriptlen + OP_RETURN + pushlen + data
	}
	return 8 + 1 + scriptPubKeyLen(addressKind(o.Address, net))
}

// outputVsizeForKind sizes an output of a script kind (used for the wallet's
// change output, whose address isn't derived yet).
func outputVsizeForKind(kind ScriptKind) int {
	return 8 + 1 + scriptPubKeyLen(kind)
}

func scriptPubKeyLen(kind ScriptKind) int {
	switch kind {
	case ScriptLegacy:
		return 25 // P2PKH
	case ScriptNestedSegwit, ScriptMultisigP2SH, ScriptMultisigNested:
		return 23 // P2SH
	case ScriptTaproot, ScriptMultisig, ScriptMultisigTaproot:
		return 34 // P2TR / P2WSH
	default:
		return 22 // P2WPKH
	}
}

// addressKind classifies an address into the script kind whose sizing/dust it
// shares. Falls back to legacy (the most conservative dust) when undecodable.
func addressKind(address string, net *chaincfg.Params) ScriptKind {
	addr, err := btcutil.DecodeAddress(address, net)
	if err != nil {
		return ScriptLegacy
	}
	switch addr.(type) {
	case *btcutil.AddressPubKeyHash:
		return ScriptLegacy
	case *btcutil.AddressScriptHash:
		return ScriptNestedSegwit // any P2SH output
	case *btcutil.AddressWitnessScriptHash:
		return ScriptMultisig // P2WSH output
	case *btcutil.AddressTaproot:
		return ScriptTaproot
	default:
		return ScriptNativeSegwit // P2WPKH
	}
}

// dustThreshold is Bitcoin Core's per-output-type dust: dustRelayFee times the
// output's size plus the cost to spend it. Witness-program outputs use the
// discounted input estimate; P2SH and legacy outputs use the full one. This is
// the policy a node actually enforces on our broadcast, so it stays correct
// regardless of the chosen fee rate.
func dustThreshold(kind ScriptKind) int64 {
	outSize := outputVsizeForKind(kind)
	inSize := 68 // witness program spend (32+4+1+107/4+4, rounded)
	switch kind {
	case ScriptLegacy, ScriptNestedSegwit, ScriptMultisigP2SH, ScriptMultisigNested:
		inSize = 148 // P2KH / P2SH scriptPubKey: non-witness for dust purposes
	}
	return int64(dustRelayFeeRate * (outSize + inSize))
}

// dustForOutput returns the dust threshold for a send output (0 for OP_RETURN,
// which is never dust).
func dustForOutput(o TxOutSpec, net *chaincfg.Params) int64 {
	if o.OpReturnHex != "" {
		return 0
	}
	return dustThreshold(addressKind(o.Address, net))
}

// estimateFeeSats returns the fee for a tx of nIn inputs (inVsize vbytes each)
// and outVsize total output vbytes at feeRate sat/vB, plus ~11 vB of overhead.
func estimateFeeSats(nIn, inVsize, outVsize int, feeRate float64) int64 {
	vsize := 11 + nIn*inVsize + outVsize
	return int64(math.Ceil(float64(vsize) * feeRate))
}
