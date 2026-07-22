package wallet

import (
	"bytes"
	"encoding/hex"
	"errors"
	"fmt"
	"sort"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

// numsInternalKeyHex is the BIP341 nothing-up-my-sleeve point H (x-only), used
// as the unspendable taproot internal key for script-path-only multisig wallets,
// matching Bitcoin Core's tr(sortedmulti_a) convention.
const numsInternalKeyHex = "50929b74c1a04954b78b4b6035e97a5e078a5a0f28ec96d547bfee9ace803ac0"

func numsInternalKey() (*btcec.PublicKey, error) {
	b, err := hex.DecodeString(numsInternalKeyHex)
	if err != nil {
		return nil, err
	}
	return schnorr.ParsePubKey(b)
}

// multiAScript builds a BIP342 sortedmulti_a tapleaf script for a k-of-n policy:
// x-only pubkeys sorted lexicographically, checked with CHECKSIG/CHECKSIGADD,
// then <k> OP_NUMEQUAL.
func multiAScript(threshold int, pubs []*btcec.PublicKey) ([]byte, error) {
	xonly := make([][]byte, len(pubs))
	for i, p := range pubs {
		xonly[i] = schnorr.SerializePubKey(p)
	}
	sort.Slice(xonly, func(i, j int) bool { return bytesLess(xonly[i], xonly[j]) })

	b := txscript.NewScriptBuilder()
	for i, x := range xonly {
		b.AddData(x)
		if i == 0 {
			b.AddOp(txscript.OP_CHECKSIG)
		} else {
			b.AddOp(txscript.OP_CHECKSIGADD)
		}
	}
	b.AddInt64(int64(threshold))
	b.AddOp(txscript.OP_NUMEQUAL)
	return b.Script()
}

// taprootMultisigOutput builds the P2TR output for a sortedmulti_a policy: the
// tapleaf multi_a script committed under the NUMS internal key. The returned
// derivedScript carries the leaf script + control block needed to sign/finalize.
func taprootMultisigOutput(threshold int, pubs []*btcec.PublicKey, net *chaincfg.Params) (derivedScript, error) {
	internal, err := numsInternalKey()
	if err != nil {
		return derivedScript{}, err
	}
	leafScript, err := multiAScript(threshold, pubs)
	if err != nil {
		return derivedScript{}, err
	}
	leaf := txscript.NewBaseTapLeaf(leafScript)
	tree := txscript.AssembleTaprootScriptTree(leaf)
	root := tree.RootNode.TapHash()
	outputKey := txscript.ComputeTaprootOutputKey(internal, root[:])
	addr, err := btcutil.NewAddressTaproot(schnorr.SerializePubKey(outputKey), net)
	if err != nil {
		return derivedScript{}, err
	}
	script, err := txscript.PayToAddrScript(addr)
	if err != nil {
		return derivedScript{}, err
	}
	ctrl := tree.LeafMerkleProofs[0].ToControlBlock(internal)
	ctrlBytes, err := ctrl.ToBytes()
	if err != nil {
		return derivedScript{}, err
	}
	return derivedScript{
		address:         addr,
		scriptPubKey:    script,
		tapInternal:     internal,
		tapLeafScript:   leafScript,
		tapControlBlock: ctrlBytes,
	}, nil
}

// parseMultiAPubkeys extracts the ordered 32-byte x-only pubkeys from a multi_a
// tapleaf script (each pushed before its CHECKSIG/CHECKSIGADD).
func parseMultiAPubkeys(script []byte) ([][]byte, error) {
	tokenizer := txscript.MakeScriptTokenizer(0, script)
	var pubs [][]byte
	for tokenizer.Next() {
		if len(tokenizer.Data()) == 32 {
			pubs = append(pubs, tokenizer.Data())
		}
	}
	if err := tokenizer.Err(); err != nil {
		return nil, err
	}
	if len(pubs) == 0 {
		return nil, errors.New("no pubkeys in multi_a script")
	}
	return pubs, nil
}

// validateTaprootMultisigPsbt reports a taproot multisig PSBT's signature
// progress for the lounge validator: count from TaprootScriptSpendSig, complete
// at requiredSigs, finalizable when every input reaches its multi_a threshold.
func validateTaprootMultisigPsbt(packet *psbt.Packet, requiredSigs int) MultisigPsbtValidation {
	maxSigs := 0
	allMeet := true
	finalizable := true
	anyTaproot := false
	for i := range packet.Inputs {
		n := len(packet.Inputs[i].TaprootScriptSpendSig)
		if n > maxSigs {
			maxSigs = n
		}
		if n < requiredSigs {
			allMeet = false
		}
		if len(packet.Inputs[i].TaprootLeafScript) > 0 {
			anyTaproot = true
			m, err := multiAThreshold(packet.Inputs[i].TaprootLeafScript[0].Script)
			if err != nil || n < m {
				finalizable = false
			}
		}
	}
	if !anyTaproot {
		finalizable = false
	}
	return MultisigPsbtValidation{
		HasSignatures:  maxSigs > 0,
		SignatureCount: maxSigs,
		IsComplete:     allMeet,
		Finalizable:    finalizable,
	}
}

// multiAThreshold reads the k threshold from a multi_a tapleaf script (the value
// pushed just before OP_NUMEQUAL). Only small-int thresholds (1..16) are used.
func multiAThreshold(script []byte) (int, error) {
	tokenizer := txscript.MakeScriptTokenizer(0, script)
	var prevOpcode byte
	var prevData []byte
	havePrev := false
	for tokenizer.Next() {
		if tokenizer.Opcode() == txscript.OP_NUMEQUAL {
			if !havePrev {
				return 0, errors.New("cannot read multi_a threshold")
			}
			if prevOpcode >= txscript.OP_1 && prevOpcode <= txscript.OP_16 {
				return int(prevOpcode-txscript.OP_1) + 1, nil
			}
			// Thresholds above 16 are encoded as a script-number data push.
			if n := scriptNumToInt(prevData); n >= 1 {
				return n, nil
			}
			return 0, errors.New("cannot read multi_a threshold")
		}
		prevOpcode = tokenizer.Opcode()
		prevData = tokenizer.Data()
		havePrev = true
	}
	if err := tokenizer.Err(); err != nil {
		return 0, err
	}
	return 0, errors.New("multi_a script missing OP_NUMEQUAL")
}

// scriptNumToInt decodes a minimal little-endian script number (as pushed by the
// script builder for thresholds > 16). Returns 0 for an empty or over-long push.
func scriptNumToInt(b []byte) int {
	if len(b) == 0 || len(b) > 4 {
		return 0
	}
	n := 0
	for i, c := range b {
		n |= int(c) << (8 * i)
	}
	if b[len(b)-1]&0x80 != 0 { // negative — not a valid threshold
		return 0
	}
	return n
}

// hasTapScriptSig reports whether a tapscript signature for the given x-only
// pubkey and leaf already exists on the input.
func hasTapScriptSig(sigs []*psbt.TaprootScriptSpendSig, xonly, leafHash []byte) bool {
	for _, s := range sigs {
		if bytes.Equal(s.XOnlyPubKey, xonly) && bytes.Equal(s.LeafHash, leafHash) {
			return true
		}
	}
	return false
}

// signTaprootMultisigInput adds this wallet's BIP342 tapscript signature(s) to a
// tr(sortedmulti_a) input for each held key. Returns 1 if it contributed a
// signature, 0 if it holds none of the input's keys.
func signTaprootMultisigInput(
	packet *psbt.Packet,
	i int,
	in psbtInput,
	tx *wire.MsgTx,
	sigHashes *txscript.TxSigHashes,
) (int, error) {
	if len(in.addr.multisigPrivs) == 0 {
		return 0, nil
	}
	if in.addr.tapLeafScript == nil {
		return 0, errors.New("taproot multisig input missing its leaf script")
	}
	leaf := txscript.NewBaseTapLeaf(in.addr.tapLeafScript)
	leafHash := leaf.TapHash()
	added := false
	for _, priv := range in.addr.multisigPrivs {
		xonly := schnorr.SerializePubKey(priv.PubKey())
		if hasTapScriptSig(packet.Inputs[i].TaprootScriptSpendSig, xonly, leafHash[:]) {
			continue
		}
		sig, err := txscript.RawTxInTapscriptSignature(
			tx, sigHashes, i, in.amount, in.addr.scriptPubKey, leaf, txscript.SigHashDefault, priv,
		)
		if err != nil {
			return 0, err
		}
		packet.Inputs[i].TaprootScriptSpendSig = append(packet.Inputs[i].TaprootScriptSpendSig, &psbt.TaprootScriptSpendSig{
			XOnlyPubKey: xonly,
			LeafHash:    leafHash[:],
			Signature:   sig,
			SigHash:     txscript.SigHashDefault,
		})
		added = true
	}
	if added {
		return 1, nil
	}
	return 0, nil
}

// finalizeTaprootMultisigInput assembles the witness for a tr(sortedmulti_a)
// input from its collected tapscript signatures and marks the input final. The
// witness stack is the signatures in reverse pubkey order (empty where a
// cosigner has not signed), then the leaf script, then the control block.
func finalizeTaprootMultisigInput(packet *psbt.Packet, i int) error {
	in := &packet.Inputs[i]
	if len(in.TaprootLeafScript) == 0 {
		return errors.New("taproot multisig input missing its leaf script")
	}
	leafScript := in.TaprootLeafScript[0].Script
	controlBlock := in.TaprootLeafScript[0].ControlBlock
	pubs, err := parseMultiAPubkeys(leafScript)
	if err != nil {
		return err
	}
	threshold, err := multiAThreshold(leafScript)
	if err != nil {
		return err
	}
	sigByPub := make(map[string][]byte, len(in.TaprootScriptSpendSig))
	for _, s := range in.TaprootScriptSpendSig {
		sigByPub[hex.EncodeToString(s.XOnlyPubKey)] = s.Signature
	}

	// A multi_a leaf ends in <m> OP_NUMEQUAL — the witness must carry EXACTLY m
	// signatures. Refuse an under-signed input, and cap an over-signed one at m
	// (empty the extra slots), or the script evaluates false and the tx is dead.
	available := 0
	for _, p := range pubs {
		if _, ok := sigByPub[hex.EncodeToString(p)]; ok {
			available++
		}
	}
	if available < threshold {
		return fmt.Errorf("taproot multisig input has %d of %d required signatures", available, threshold)
	}

	used := 0
	stack := make([][]byte, 0, len(pubs)+2)
	for k := len(pubs) - 1; k >= 0; k-- {
		if sig, ok := sigByPub[hex.EncodeToString(pubs[k])]; ok && used < threshold {
			stack = append(stack, sig)
			used++
		} else {
			stack = append(stack, []byte{})
		}
	}
	stack = append(stack, leafScript, controlBlock)

	var buf bytes.Buffer
	if err := wire.WriteVarInt(&buf, 0, uint64(len(stack))); err != nil {
		return err
	}
	for _, item := range stack {
		if err := wire.WriteVarBytes(&buf, 0, item); err != nil {
			return err
		}
	}
	in.FinalScriptWitness = buf.Bytes()
	return nil
}

// addTaprootMultisigInputFields populates the PSBT taproot script-path fields for
// a tr(sortedmulti_a) input: internal key, merkle root, the leaf script + control
// block, and each cosigner's x-only BIP32 derivation (so signatures can be
// attributed and external signers can match their key).
func addTaprootMultisigInputFields(in *psbt.PInput, sa scannedAddr) {
	in.TaprootInternalKey = schnorr.SerializePubKey(sa.tapInternal)
	leaf := txscript.NewBaseTapLeaf(sa.tapLeafScript)
	leafHash := leaf.TapHash()
	in.TaprootMerkleRoot = leafHash[:]
	in.TaprootLeafScript = []*psbt.TaprootTapLeafScript{{
		ControlBlock: sa.tapControlBlock,
		Script:       sa.tapLeafScript,
		LeafVersion:  txscript.BaseLeafVersion,
	}}
	for _, d := range sa.derivations {
		in.TaprootBip32Derivation = append(in.TaprootBip32Derivation, &psbt.TaprootBip32Derivation{
			XOnlyPubKey:          schnorr.SerializePubKey(d.pub),
			LeafHashes:           [][]byte{leafHash[:]},
			MasterKeyFingerprint: d.fingerprint,
			Bip32Path:            d.path,
		})
	}
}

// taprootMultisigStatus reports a tr(sortedmulti_a) PSBT's signature count,
// finalizability, and which cosigners (by x-only pubkey + fingerprint/origin)
// have signed. Mirrors MultisigPsbtSigningStatus for the taproot path.
func taprootMultisigStatus(packet *psbt.Packet, cosigners []MultisigCosigner) (MultisigSigningStatus, error) {
	maxSigs := 0
	signedPub := map[string]bool{}
	for i := range packet.Inputs {
		if n := len(packet.Inputs[i].TaprootScriptSpendSig); n > maxSigs {
			maxSigs = n
		}
		for _, s := range packet.Inputs[i].TaprootScriptSpendSig {
			signedPub[hex.EncodeToString(s.XOnlyPubKey)] = true
		}
	}

	// Finalizable means every taproot input has at least its threshold of
	// tapscript signatures (an assembled witness with empty slots always
	// serializes, so a threshold check is what matters).
	finalizable := true
	anyTaproot := false
	for i := range packet.Inputs {
		if len(packet.Inputs[i].TaprootLeafScript) == 0 {
			continue
		}
		anyTaproot = true
		m, err := multiAThreshold(packet.Inputs[i].TaprootLeafScript[0].Script)
		if err != nil || len(packet.Inputs[i].TaprootScriptSpendSig) < m {
			finalizable = false
		}
	}
	if !anyTaproot {
		finalizable = false
	}

	cosignerSigned := make([]bool, len(cosigners))
	for ci, c := range cosigners {
		fp, path, ok := parseOrigin(c.Fingerprint + "/" + c.OriginPath)
		if !ok {
			continue
		}
		origins := []keyOrigin{{fingerprint: fp, path: path}}
	inputs:
		for i := range packet.Inputs {
			for _, d := range packet.Inputs[i].TaprootBip32Derivation {
				if !signedPub[hex.EncodeToString(d.XOnlyPubKey)] {
					continue
				}
				if originMatches(d.MasterKeyFingerprint, d.Bip32Path, origins) {
					cosignerSigned[ci] = true
					break inputs
				}
			}
		}
	}
	return MultisigSigningStatus{Signatures: maxSigs, Finalizable: finalizable, CosignerSigned: cosignerSigned}, nil
}
