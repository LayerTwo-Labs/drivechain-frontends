package wallet

import (
	"bytes"
	"encoding/base64"
	"errors"
	"fmt"
	"sort"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

// MultisigLoungeKey is one cosigner key in a BitWindow multisig group.
type MultisigLoungeKey struct {
	Xpub        string
	Fingerprint string
	OriginPath  string
	IsWallet    bool
}

// MultisigLoungeGroup describes an m-of-n policy for descriptor building.
type MultisigLoungeGroup struct {
	M    int
	N    int
	Keys []MultisigLoungeKey
}

// keyDescriptor renders one key expression: a key with a known fingerprint gets
// a [fingerprint/origin] prefix, all others are the bare xpub. A master xpub has
// no origin path, so it gets a bare [fingerprint] prefix. Every key origin must
// reach the PSBT, or a hardware signer cannot rebuild the multisig script.
func (k MultisigLoungeKey) keyDescriptor() string {
	if !k.IsWallet || k.Fingerprint == "" {
		return k.Xpub
	}
	if k.OriginPath != "" {
		return fmt.Sprintf("[%s/%s]%s", k.Fingerprint, k.OriginPath, k.Xpub)
	}
	// Only a master key sits at the fingerprint with no path. An account key
	// with no path cannot say where it sits, so it stays a bare xpub rather
	// than claim a derivation that reaches a different child.
	if !isMasterKey(k.Xpub) {
		return k.Xpub
	}
	return fmt.Sprintf("[%s]%s", k.Fingerprint, k.Xpub)
}

func isMasterKey(xpub string) bool {
	key, err := hdkeychain.NewKeyFromString(xpub)
	return err == nil && key.Depth() == 0
}

// sortKeysByBIP67 sorts the group's keys lexicographically by xpub string,
// matching the Dart _sortKeysByBIP67 (which compares xpub strings, not
// serialized pubkeys). This ordering is what fixes the descriptor key order;
// sortedmulti itself re-sorts the derived pubkeys at address time.
func sortKeysByBIP67(keys []MultisigLoungeKey) []MultisigLoungeKey {
	sorted := append([]MultisigLoungeKey(nil), keys...)
	sort.SliceStable(sorted, func(i, j int) bool {
		return sorted[i].Xpub < sorted[j].Xpub
	})
	return sorted
}

// BuildMultisigLoungeDescriptors builds the receive (/0/*) and change (/1/*)
// watch-only wsh(sortedmulti) descriptors with checksums, in standard form: the
// range suffix is appended to EACH key after the BIP67
// (xpub-string) sort, so every cosigner ranges over the same chain/index. This
// must derive the same address set as the signing descriptor, or spends break.
func BuildMultisigLoungeDescriptors(g MultisigLoungeGroup) (receive, change string, err error) {
	return BuildMultisigLoungeDescriptorsTyped(g, "")
}

// multisigScriptKind maps a descriptor script-type string (as sent by the
// frontend) to a ScriptKind. An empty/unknown value defaults to native P2WSH.
func multisigScriptKind(scriptType string) ScriptKind {
	switch scriptType {
	case "sh", "legacy", "p2sh":
		return ScriptMultisigP2SH
	case "sh-wsh", "nested", "p2sh-p2wsh":
		return ScriptMultisigNested
	case "tr", "taproot", "p2tr":
		return ScriptMultisigTaproot
	default:
		return ScriptMultisig
	}
}

// multisigTypeString maps a multisig ScriptKind back to its descriptor
// script-type string ("wsh", "sh-wsh", or "sh").
func multisigTypeString(k ScriptKind) string {
	switch k {
	case ScriptMultisigP2SH:
		return "sh"
	case ScriptMultisigNested:
		return "sh-wsh"
	case ScriptMultisigTaproot:
		return "tr"
	default:
		return "wsh"
	}
}

// multisigDescriptorBody assembles the full descriptor body for a policy: the
// tr(NUMS,sortedmulti_a(...)) form for taproot, or the sh/wsh sortedmulti wrapper
// otherwise. parts are the per-key expressions (already including their ranges).
func multisigDescriptorBody(kind ScriptKind, m int, parts []string) string {
	joined := strings.Join(parts, ",")
	if kind == ScriptMultisigTaproot {
		return fmt.Sprintf("tr(%s,sortedmulti_a(%d,%s))", numsInternalKeyHex, m, joined)
	}
	return wrapMultisig(kind, fmt.Sprintf("sortedmulti(%d,%s)", m, joined))
}

// wrapMultisig wraps a bare "sortedmulti(...)" body in the script-kind's outer
// descriptor: sh() for legacy P2SH, sh(wsh()) for nested, wsh() for native.
func wrapMultisig(kind ScriptKind, inner string) string {
	switch kind {
	case ScriptMultisigP2SH:
		return "sh(" + inner + ")"
	case ScriptMultisigNested:
		return "sh(wsh(" + inner + "))"
	default:
		return "wsh(" + inner + ")"
	}
}

// BuildMultisigLoungeDescriptorsTyped is BuildMultisigLoungeDescriptors for a
// chosen multisig script type ("wsh", "sh-wsh", or "sh"); an empty type is
// native P2WSH.
func BuildMultisigLoungeDescriptorsTyped(g MultisigLoungeGroup, scriptType string) (receive, change string, err error) {
	if g.M < 1 {
		return "", "", fmt.Errorf("invalid threshold m=%d", g.M)
	}
	if len(g.Keys) == 0 {
		return "", "", errors.New("group has no keys")
	}

	kind := multisigScriptKind(scriptType)
	sorted := sortKeysByBIP67(g.Keys)
	receiveParts := make([]string, len(sorted))
	changeParts := make([]string, len(sorted))
	for i, k := range sorted {
		if k.Xpub == "" {
			return "", "", fmt.Errorf("key %d has empty xpub", i)
		}
		receiveParts[i] = k.keyDescriptor() + "/0/*"
		changeParts[i] = k.keyDescriptor() + "/1/*"
	}

	receiveBody := multisigDescriptorBody(kind, g.M, receiveParts)
	changeBody := multisigDescriptorBody(kind, g.M, changeParts)

	receive, err = AddDescriptorChecksum(receiveBody)
	if err != nil {
		return "", "", fmt.Errorf("checksum receive descriptor: %w", err)
	}
	change, err = AddDescriptorChecksum(changeBody)
	if err != nil {
		return "", "", fmt.Errorf("checksum change descriptor: %w", err)
	}
	return receive, change, nil
}

// BuildMultisigSigningDescriptors builds the receive (/0/*) and change (/1/*)
// signing descriptors: identical to the watch-only descriptors except the
// wallet-owned keys carry their account xprv (signWithXprv keyed by xpub) in
// place of the xpub, so bitcoind descriptorprocesspsbt can sign with them. The
// BIP67 ordering is still by xpub string, so the key order — and therefore the
// derived address set — is byte-identical to the watch-only descriptor. A
// descriptor whose signing keys are NOT a prefix-consistent substitution would
// derive different addresses and produce signatures for the wrong scripts; the
// Phase-1 receive==sign deriveaddresses test guards this invariant.
//
// signWithXprv maps a key's xpub to the xprv to substitute. Keys absent from the
// map keep their xpub (cosigners). Descriptors carry no checksum — bitcoind
// accepts unchecksummed descriptors and adds its own.
func BuildMultisigSigningDescriptors(g MultisigLoungeGroup, signWithXprv map[string]string) (receive, change string, err error) {
	return BuildMultisigSigningDescriptorsTyped(g, signWithXprv, "")
}

// BuildMultisigSigningDescriptorsTyped is BuildMultisigSigningDescriptors for a
// chosen multisig script type ("wsh", "sh-wsh", or "sh"); an empty type is
// native P2WSH.
func BuildMultisigSigningDescriptorsTyped(g MultisigLoungeGroup, signWithXprv map[string]string, scriptType string) (receive, change string, err error) {
	if g.M < 1 {
		return "", "", fmt.Errorf("invalid threshold m=%d", g.M)
	}
	if len(g.Keys) == 0 {
		return "", "", errors.New("group has no keys")
	}
	if len(signWithXprv) == 0 {
		return "", "", errors.New("no signing keys provided")
	}

	kind := multisigScriptKind(scriptType)
	sorted := sortKeysByBIP67(g.Keys)
	receiveParts := make([]string, len(sorted))
	changeParts := make([]string, len(sorted))
	substituted := 0
	for i, k := range sorted {
		if k.Xpub == "" {
			return "", "", fmt.Errorf("key %d has empty xpub", i)
		}
		expr := k.keyDescriptor()
		if xprv, ok := signWithXprv[k.Xpub]; ok && xprv != "" {
			// Substitute the xprv for the xpub, preserving any [fp/origin] prefix.
			expr = strings.Replace(expr, k.Xpub, xprv, 1)
			substituted++
		}
		receiveParts[i] = expr + "/0/*"
		changeParts[i] = expr + "/1/*"
	}
	if substituted == 0 {
		return "", "", errors.New("none of the signing keys matched a group key")
	}

	receive = multisigDescriptorBody(kind, g.M, receiveParts)
	change = multisigDescriptorBody(kind, g.M, changeParts)
	return receive, change, nil
}

// MultisigPsbtValidation reports a PSBT's signature progress.
type MultisigPsbtValidation struct {
	HasSignatures  bool
	SignatureCount int
	IsComplete     bool
	Finalizable    bool
}

// ValidateMultisigPsbt parses a base64 PSBT and reports per-input partial
// signature progress against requiredSigs. When group is non-nil, every input's
// witnessScript must match one derived from the group descriptor; a foreign
// input is rejected.
//
// SignatureCount is the maximum partial-signature count across inputs (matching
// the Dart PSBTValidator, which takes the max). IsComplete means every input has
// at least requiredSigs partial signatures; Finalizable means the btcsuite
// finalizer can produce a complete transaction.
func ValidateMultisigPsbt(psbtBase64 string, requiredSigs int, group *MultisigLoungeGroup) (MultisigPsbtValidation, error) {
	raw, err := base64.StdEncoding.DecodeString(strings.TrimSpace(psbtBase64))
	if err != nil {
		return MultisigPsbtValidation{}, fmt.Errorf("decode base64 psbt: %w", err)
	}
	packet, err := psbt.NewFromRawBytes(strings.NewReader(string(raw)), false)
	if err != nil {
		return MultisigPsbtValidation{}, fmt.Errorf("parse psbt: %w", err)
	}
	if len(packet.Inputs) == 0 {
		return MultisigPsbtValidation{}, errors.New("psbt has no inputs")
	}

	if group != nil {
		origins, err := groupKeyOrigins(*group)
		if err != nil {
			return MultisigPsbtValidation{}, err
		}
		accts, err := groupAccountKeys(*group)
		if err != nil {
			return MultisigPsbtValidation{}, err
		}
		for i := range packet.Inputs {
			prevOut, err := authenticatedPrevOut(packet, i)
			if err != nil {
				return MultisigPsbtValidation{}, fmt.Errorf("input %d %w", i, err)
			}
			if err := verifyInputBelongsToGroup(packet.Inputs[i], prevOut, group.M, accts, origins); err != nil {
				return MultisigPsbtValidation{}, fmt.Errorf("input %d %w", i, err)
			}
		}
	}

	// Taproot script-path multisig keeps signatures in TaprootScriptSpendSig and
	// is finalizable at exactly its multi_a threshold.
	for i := range packet.Inputs {
		if len(packet.Inputs[i].TaprootLeafScript) > 0 {
			return validateTaprootMultisigPsbt(packet, requiredSigs), nil
		}
	}

	maxSigs := 0
	allMeetThreshold := true
	for i := range packet.Inputs {
		n := len(packet.Inputs[i].PartialSigs)
		if n > maxSigs {
			maxSigs = n
		}
		if n < requiredSigs {
			allMeetThreshold = false
		}
	}

	finalizable := false
	if clone, err := clonePacket(packet); err == nil {
		if err := psbt.MaybeFinalizeAll(clone); err == nil {
			finalizable = clone.IsComplete()
		}
	}

	return MultisigPsbtValidation{
		HasSignatures:  maxSigs > 0,
		SignatureCount: maxSigs,
		IsComplete:     allMeetThreshold,
		Finalizable:    finalizable,
	}, nil
}

// ParseMultisigConfig parses a multisig wallet definition — an output descriptor,
// a Coldcard text config, or a Sparrow/Specter/Caravan JSON export — into its
// threshold, script type, and cosigners.
func ParseMultisigConfig(content string) (m, n int, scriptType string, cosigners []MultisigCosigner, err error) {
	trimmed := strings.TrimSpace(content)
	switch {
	case strings.HasPrefix(trimmed, "{"):
		return parseMultisigJSON(trimmed)
	case strings.HasPrefix(trimmed, "wsh(") || strings.HasPrefix(trimmed, "sh(") || strings.HasPrefix(trimmed, "tr("):
		return ParseMultisigDescriptor(trimmed)
	default:
		return parseColdcardConfig(trimmed)
	}
}

// ParseMultisigDescriptor parses a wsh/sh/sh-wsh sortedmulti descriptor into its
// threshold, script type, and watch-only cosigners (public keys + key origins).
func ParseMultisigDescriptor(descriptor string) (m, n int, scriptType string, cosigners []MultisigCosigner, err error) {
	d, err := ParseDescriptor(strings.TrimSpace(descriptor))
	if err != nil {
		return 0, 0, "", nil, err
	}
	if !d.Kind.isMultisig() && !d.Kind.isTaprootMultisig() {
		return 0, 0, "", nil, errors.New("not a multisig descriptor")
	}
	cosigners, err = descriptorCosigners(d)
	if err != nil {
		return 0, 0, "", nil, err
	}
	return d.Threshold, len(d.Keys), multisigTypeString(d.Kind), cosigners, nil
}

// DescriptorPolicy is the wallet policy an output descriptor encodes.
type DescriptorPolicy struct {
	Multisig   bool
	ScriptType string // wpkh|sh-wpkh|pkh|tr, or wsh|sh-wsh|sh|tr when multisig
	M          int    // signatures required
	N          int    // total keys
	Cosigners  []MultisigCosigner
}

// ValidateDescriptor parses any supported output descriptor — single-sig or
// sortedmulti — into the policy it encodes.
func ValidateDescriptor(descriptor string) (*DescriptorPolicy, error) {
	d, err := ParseDescriptor(strings.TrimSpace(descriptor))
	if err != nil {
		return nil, err
	}
	cosigners, err := descriptorCosigners(d)
	if err != nil {
		return nil, err
	}
	multisig := d.Kind.isMultisig() || d.Kind.isTaprootMultisig()
	scriptType := singleSigTypeString(d.Kind)
	if multisig {
		scriptType = multisigTypeString(d.Kind)
	}
	return &DescriptorPolicy{
		Multisig:   multisig,
		ScriptType: scriptType,
		M:          d.Threshold,
		N:          len(d.Keys),
		Cosigners:  cosigners,
	}, nil
}

// singleSigTypeString maps a single-sig ScriptKind back to its descriptor
// script-type string ("pkh", "sh-wpkh", "tr", or "wpkh").
func singleSigTypeString(k ScriptKind) string {
	switch k {
	case ScriptLegacy:
		return "pkh"
	case ScriptNestedSegwit:
		return "sh-wpkh"
	case ScriptTaproot:
		return "tr"
	default:
		return "wpkh"
	}
}

// descriptorCosigners turns a descriptor's keys into watch-only cosigners,
// neutering any private account key.
func descriptorCosigners(d *Descriptor) ([]MultisigCosigner, error) {
	cosigners := make([]MultisigCosigner, 0, len(d.Keys))
	for _, k := range d.Keys {
		acct := k.Account
		if acct.IsPrivate() {
			pub, err := acct.Neuter()
			if err != nil {
				return nil, fmt.Errorf("neuter key: %w", err)
			}
			acct = pub
		}
		fp, origin := splitOrigin(k.Origin)
		cosigners = append(cosigners, MultisigCosigner{
			Xpub:        acct.String(),
			Fingerprint: fp,
			OriginPath:  origin,
		})
	}
	return cosigners, nil
}

// splitOrigin splits a descriptor key origin "fingerprint/path" into its parts,
// normalizing hardened markers (h/H) to "'". Empty when there is no origin.
func splitOrigin(origin string) (fingerprint, path string) {
	if origin == "" {
		return "", ""
	}
	origin = strings.ReplaceAll(origin, "h", "'")
	origin = strings.ReplaceAll(origin, "H", "'")
	if fp, path, found := strings.Cut(origin, "/"); found {
		return fp, path
	}
	return origin, ""
}

// MultisigSigningStatus reports a PSBT's signing progress for a multisig wallet.
type MultisigSigningStatus struct {
	Signatures     int    // max partial-signature count across inputs
	Finalizable    bool   // the finalizer can produce a complete transaction
	CosignerSigned []bool // aligned to the cosigners; true where that leg signed
}

// MultisigPsbtSigningStatus decodes a PSBT and reports the signature count,
// whether it can be finalized, and which cosigners have signed. A cosigner is
// credited only when every input that lists one of its origin's pubkeys
// (fingerprint + origin-path prefix) carries that pubkey's partial signature —
// a partial signer must stay eligible to sign its remaining inputs. Cosigners
// sharing a master fingerprint are still told apart by their derivation path.
func MultisigPsbtSigningStatus(psbtBase64 string, cosigners []MultisigCosigner) (MultisigSigningStatus, error) {
	raw, err := base64.StdEncoding.DecodeString(strings.TrimSpace(psbtBase64))
	if err != nil {
		return MultisigSigningStatus{}, fmt.Errorf("decode base64 psbt: %w", err)
	}
	packet, err := psbt.NewFromRawBytes(strings.NewReader(string(raw)), false)
	if err != nil {
		return MultisigSigningStatus{}, fmt.Errorf("parse psbt: %w", err)
	}

	// Taproot script-path multisig carries its signatures in a different field set.
	for i := range packet.Inputs {
		if len(packet.Inputs[i].TaprootLeafScript) > 0 {
			return taprootMultisigStatus(packet, cosigners)
		}
	}

	maxSigs := 0
	for i := range packet.Inputs {
		if n := len(packet.Inputs[i].PartialSigs); n > maxSigs {
			maxSigs = n
		}
	}

	finalizable := false
	if clone, err := clonePacket(packet); err == nil {
		if err := psbt.MaybeFinalizeAll(clone); err == nil {
			finalizable = clone.IsComplete()
		}
	}

	cosignerSigned := make([]bool, len(cosigners))
	for ci, c := range cosigners {
		fp, path, ok := parseOrigin(c.Fingerprint + "/" + c.OriginPath)
		if !ok {
			continue
		}
		origins := []keyOrigin{{fingerprint: fp, path: path}}
		applicable, signed := 0, 0
		for i := range packet.Inputs {
			for _, d := range packet.Inputs[i].Bip32Derivation {
				if !originMatches(d.MasterKeyFingerprint, d.Bip32Path, origins) {
					continue
				}
				applicable++
				// Inputs can share a pubkey, so only this input's own
				// signatures count for this input.
				if inputHasPartialSig(packet.Inputs[i].PartialSigs, d.PubKey) {
					signed++
				}
				break
			}
		}
		cosignerSigned[ci] = applicable > 0 && signed == applicable
	}

	return MultisigSigningStatus{Signatures: maxSigs, Finalizable: finalizable, CosignerSigned: cosignerSigned}, nil
}

func inputHasPartialSig(sigs []*psbt.PartialSig, pubKey []byte) bool {
	for _, ps := range sigs {
		if bytes.Equal(ps.PubKey, pubKey) {
			return true
		}
	}
	return false
}

// keyOrigin is one cosigner's master fingerprint plus account-level origin path,
// the (fingerprint, origin-path) pair a PSBT's BIP32 derivation records expose.
type keyOrigin struct {
	fingerprint uint32
	path        []uint32
}

// groupKeyOrigins resolves each key's declared [fingerprint/origin] into the
// fingerprint + account path the PSBT BIP32 derivations carry. Keys without one
// contribute nothing: membership is proven by verifyInputScript, not by origin
// metadata, so a group of bare xpubs is still verifiable.
func groupKeyOrigins(g MultisigLoungeGroup) ([]keyOrigin, error) {
	origins := make([]keyOrigin, 0, len(g.Keys))
	for _, k := range g.Keys {
		if k.Fingerprint == "" || k.OriginPath == "" {
			continue
		}
		fp, path, ok := parseOrigin(k.Fingerprint + "/" + k.OriginPath)
		if !ok {
			return nil, fmt.Errorf("invalid key origin %q/%q", k.Fingerprint, k.OriginPath)
		}
		origins = append(origins, keyOrigin{fingerprint: fp, path: path})
	}
	return origins, nil
}

// verifyInputBelongsToGroup rejects a foreign PSBT input. The binding check is
// verifyInputScript: the k-of-n script the input actually commits to must be the
// one the group's own cosigner keys re-derive, so an input the group cannot own
// is refused whatever its metadata claims. The origin allow-list is kept as an
// additional constraint on records claiming a fingerprint the group declares.
func verifyInputBelongsToGroup(in psbt.PInput, prevOut *wire.TxOut, m int, accts []*hdkeychain.ExtendedKey, origins []keyOrigin) error {
	// The script check runs first, because it establishes which derivation
	// family the input actually uses. To pick that family from whatever
	// metadata happens to be present lets one stray taproot record stand in for
	// a whole set of missing ECDSA records.
	bound, err := verifyInputScript(in, prevOut, m, accts)
	if err != nil {
		return err
	}
	return verifyInputOrigins(in, origins, bound)
}

// boundInput is what the script check proves: the family the input spends, the
// child the group derives it at, and the cosigner keys at that child.
type boundInput struct {
	kind   ScriptKind
	change bool
	index  uint32
	pubs   []*btcec.PublicKey
}

// groupAccountKeys resolves the group's cosigner xpubs (SLIP-0132 forms included)
// into the account extended keys the group's own scripts re-derive from.
func groupAccountKeys(g MultisigLoungeGroup) ([]*hdkeychain.ExtendedKey, error) {
	if len(g.Keys) == 0 {
		return nil, errors.New("group has no keys")
	}
	accts := make([]*hdkeychain.ExtendedKey, 0, len(g.Keys))
	for i, k := range g.Keys {
		canonical, _, _, err := normalizeExtendedKey(k.Xpub)
		if err != nil {
			return nil, fmt.Errorf("group key %d: %w", i, err)
		}
		acct, err := hdkeychain.NewKeyFromString(canonical)
		if err != nil {
			return nil, fmt.Errorf("parse group key %d: %w", i, err)
		}
		accts = append(accts, acct)
	}
	return accts, nil
}

// verifyInputScript binds a PSBT input to the group by derivation: the k-of-n
// script the input commits to (witness script, redeem script for legacy P2SH, or
// multi_a tapleaf) must equal the one the group's cosigner keys derive at the
// input's chain/index, and the prevout scriptPubKey must be that script's
// wrapper. The input's derivation path is only the index hint — a wrong one
// derives a different script and is rejected.
func verifyInputScript(in psbt.PInput, prevOut *wire.TxOut, m int, accts []*hdkeychain.ExtendedKey) (boundInput, error) {
	if prevOut == nil {
		return boundInput{}, errors.New("has no witness or non-witness utxo; cannot verify it belongs to the group")
	}
	var kinds []ScriptKind
	var script []byte
	taproot := false
	switch {
	case len(in.TaprootLeafScript) > 0:
		kinds, script, taproot = []ScriptKind{ScriptMultisigTaproot}, in.TaprootLeafScript[0].Script, true
	case in.WitnessScript != nil:
		kinds, script = []ScriptKind{ScriptMultisig, ScriptMultisigNested}, in.WitnessScript
	case in.RedeemScript != nil:
		kinds, script = []ScriptKind{ScriptMultisigP2SH}, in.RedeemScript
	default:
		return boundInput{}, errors.New("has no witness or redeem script; cannot verify it belongs to the group")
	}

	// The script fields above already say which family this input uses, so read
	// the chain and index from that family alone. A stray record of the other
	// family would otherwise pick the child, and a signer that honours the
	// recorded path could not spend what this check accepts.
	change, index, ok := groupChainIndex(in, taproot)
	if !ok {
		return boundInput{}, errors.New("has no usable derivation path; cannot verify it belongs to the group")
	}

	pubs := make([]*btcec.PublicKey, len(accts))
	for i, a := range accts {
		pub, err := deriveChildPub(a, chainIndex(change), index)
		if err != nil {
			return boundInput{}, errors.New("does not belong to the multisig group (foreign input rejected)")
		}
		pubs[i] = pub
	}

	for _, kind := range kinds {
		// The network only selects the address encoding; the script bytes
		// compared here are the same on every network.
		ds, err := multisigOutput(kind, m, pubs, &chaincfg.MainNetParams)
		if err != nil {
			return boundInput{}, err
		}
		own := ds.witnessScript
		switch kind {
		case ScriptMultisigP2SH:
			own = ds.redeemScript
		case ScriptMultisigTaproot:
			own = ds.tapLeafScript
		}
		if !bytes.Equal(script, own) || !bytes.Equal(prevOut.PkScript, ds.scriptPubKey) {
			continue
		}

		// The finalizer copies these fields into the witness or the scriptSig
		// without a check of its own, so a match on the script alone still
		// leaves an input that cannot spend the prevout.
		switch kind {
		case ScriptMultisigTaproot:
			leaf := in.TaprootLeafScript[0]
			if leaf.LeafVersion != txscript.BaseLeafVersion {
				return boundInput{}, errors.New("carries a taproot leaf version the group does not use")
			}
			if !bytes.Equal(leaf.ControlBlock, ds.tapControlBlock) {
				return boundInput{}, errors.New("carries a taproot control block that does not prove the group's leaf")
			}
		case ScriptMultisigNested:
			if in.RedeemScript != nil && !bytes.Equal(in.RedeemScript, ds.redeemScript) {
				return boundInput{}, errors.New("carries a redeem script that does not wrap the group's witness script")
			}
		}
		return boundInput{kind: kind, change: change, index: index, pubs: pubs}, nil
	}
	return boundInput{}, errors.New("does not belong to the multisig group (foreign input rejected)")
}

// verifyInputOrigins requires every BIP32 derivation record that claims one of
// the group's fingerprints to trace to that fingerprint's origin (account path
// prefix). Records claiming any other fingerprint are external cosigners — the
// descriptor emits those keys bare, so Core tags them with the xpub's own
// self-root fingerprint — and are left to verifyInputScript.
func verifyInputOrigins(in psbt.PInput, origins []keyOrigin, bound boundInput) error {
	if bound.kind == ScriptMultisigTaproot {
		if len(in.TaprootBip32Derivation) == 0 {
			return errors.New("has no taproot BIP32 derivation records; cannot verify it belongs to the group")
		}
		if len(in.TaprootLeafScript) == 0 {
			return errors.New("has no taproot leaf script; cannot verify it belongs to the group")
		}
		leafHash := txscript.NewBaseTapLeaf(in.TaprootLeafScript[0].Script).TapHash()
		for _, d := range in.TaprootBip32Derivation {
			if !originAllowed(d.MasterKeyFingerprint, d.Bip32Path, origins) {
				return errors.New("does not belong to the multisig group (foreign input rejected)")
			}
			if !isCosignerRecord(d.MasterKeyFingerprint, d.Bip32Path, d.XOnlyPubKey, origins, bound, true) {
				continue
			}
			if err := verifyChildPath(d.Bip32Path, bound); err != nil {
				return err
			}
			if !referencesLeaf(d.LeafHashes, leafHash[:]) {
				return errors.New("carries a cosigner derivation that does not sign the group's leaf")
			}
		}
		return nil
	}
	if len(in.Bip32Derivation) == 0 {
		return errors.New("has no BIP32 derivation records; cannot verify it belongs to the group")
	}
	for _, d := range in.Bip32Derivation {
		if !originAllowed(d.MasterKeyFingerprint, d.Bip32Path, origins) {
			return errors.New("does not belong to the multisig group (foreign input rejected)")
		}
		if !isCosignerRecord(d.MasterKeyFingerprint, d.Bip32Path, d.PubKey, origins, bound, false) {
			continue
		}
		if err := verifyChildPath(d.Bip32Path, bound); err != nil {
			return err
		}
	}
	return nil
}

// isCosignerRecord reports whether a derivation record speaks for one of the
// group's cosigners at this input: it either traces to a declared origin, or it
// names a key the group itself derives. A bare xpub cosigner declares no origin,
// so the key match is the only thing that binds its record to the group.
func isCosignerRecord(fingerprint uint32, path []uint32, pubKey []byte, origins []keyOrigin, bound boundInput, taproot bool) bool {
	if originMatches(fingerprint, path, origins) {
		return true
	}
	for _, p := range bound.pubs {
		want := p.SerializeCompressed()
		if taproot {
			want = schnorr.SerializePubKey(p)
		}
		if bytes.Equal(pubKey, want) {
			return true
		}
	}
	return false
}

// verifyChildPath requires a cosigner record to name the child the script check
// derived. A record for another child leaves that cosigner unable to sign the
// input this gate accepts.
func verifyChildPath(path []uint32, bound boundInput) error {
	c, i, ok := chainIndexFromPath(path)
	if !ok || c != bound.change || i != bound.index {
		return errors.New("carries a cosigner derivation for another child of the group")
	}
	return nil
}

func referencesLeaf(hashes [][]byte, leafHash []byte) bool {
	for _, h := range hashes {
		if bytes.Equal(h, leafHash) {
			return true
		}
	}
	return false
}

// originAllowed reports whether a derivation record is consistent with the
// group's origins: it either matches one, or claims a fingerprint the group does
// not declare at all.
func originAllowed(fingerprint uint32, path []uint32, origins []keyOrigin) bool {
	if originMatches(fingerprint, path, origins) {
		return true
	}
	for _, o := range origins {
		if o.fingerprint == fingerprint {
			return false
		}
	}
	return true
}

// originMatches reports whether (fingerprint, path) starts with one of the
// group's account-level origins. The PSBT path is the full account path plus the
// chain/index suffix, so the origin must be a prefix.
func originMatches(fingerprint uint32, path []uint32, origins []keyOrigin) bool {
	for _, o := range origins {
		if o.fingerprint != fingerprint || len(path) < len(o.path) {
			continue
		}
		match := true
		for i := range o.path {
			if path[i] != o.path[i] {
				match = false
				break
			}
		}
		if match {
			return true
		}
	}
	return false
}

func clonePacket(p *psbt.Packet) (*psbt.Packet, error) {
	var buf strings.Builder
	if err := p.Serialize(&buf); err != nil {
		return nil, err
	}
	return psbt.NewFromRawBytes(strings.NewReader(buf.String()), false)
}

// authenticatedPrevOut returns an input's previous output, taken from data the
// PSBT itself proves where it can. A non-witness UTXO is the whole previous
// transaction, so its hash must equal the outpoint it claims; that binds the
// script below to a real output. A witness UTXO carries no such proof, so it is
// accepted only because the caller then re-derives the script from the group's
// own keys, and because a signer commits to this amount and script in the
// sighash. Full assurance for a witness input needs a trusted chain lookup.
func authenticatedPrevOut(packet *psbt.Packet, i int) (*wire.TxOut, error) {
	in := packet.Inputs[i]
	outpoint := packet.UnsignedTx.TxIn[i].PreviousOutPoint

	if in.NonWitnessUtxo != nil {
		if in.NonWitnessUtxo.TxHash() != outpoint.Hash {
			return nil, errors.New("carries a previous transaction that is not the one it spends")
		}
		if int(outpoint.Index) >= len(in.NonWitnessUtxo.TxOut) {
			return nil, errors.New("carries a previous transaction with no output at that index")
		}
		out := in.NonWitnessUtxo.TxOut[outpoint.Index]
		// A segwit signer takes the amount and script from the witness entry, so
		// the two must agree. Otherwise this check passes on one output while
		// the signature commits to another.
		if in.WitnessUtxo != nil {
			if in.WitnessUtxo.Value != out.Value || !bytes.Equal(in.WitnessUtxo.PkScript, out.PkScript) {
				return nil, errors.New("carries a witness utxo that disagrees with its previous transaction")
			}
		}
		return out, nil
	}
	if in.WitnessUtxo != nil {
		return in.WitnessUtxo, nil
	}
	return nil, nil
}

// groupChainIndex reads the chain and address index from the derivation family
// the input's script belongs to. The chain must be 0 or 1: any other value is
// not a receive or change branch of this group, and to fold it into "receive"
// would validate a path the group never derives.
func groupChainIndex(in psbt.PInput, taproot bool) (change bool, index uint32, ok bool) {
	if taproot {
		for _, d := range in.TaprootBip32Derivation {
			if c, i, valid := chainIndexFromPath(d.Bip32Path); valid {
				return c, i, true
			}
		}
		return false, 0, false
	}
	for _, d := range in.Bip32Derivation {
		if c, i, valid := chainIndexFromPath(d.Bip32Path); valid {
			return c, i, true
		}
	}
	return false, 0, false
}

func chainIndexFromPath(path []uint32) (change bool, index uint32, ok bool) {
	if len(path) < 2 {
		return false, 0, false
	}
	chain := path[len(path)-2]
	if chain != 0 && chain != 1 {
		return false, 0, false
	}
	return chain == 1, path[len(path)-1], true
}
