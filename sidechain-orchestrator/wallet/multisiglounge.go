package wallet

import (
	"bytes"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"sort"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
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

// keyDescriptor renders one key expression, mirroring the BitWindow Dart
// MultisigDescriptorBuilder: wallet keys get a [fingerprint/origin] prefix, all
// others are the bare xpub.
func (k MultisigLoungeKey) keyDescriptor() string {
	if k.IsWallet && k.Fingerprint != "" && k.OriginPath != "" {
		return fmt.Sprintf("[%s/%s]%s", k.Fingerprint, k.OriginPath, k.Xpub)
	}
	return k.Xpub
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
			if err := verifyInputBelongsToGroup(packet.Inputs[i], prevOutForInput(packet, i), group.M, accts, origins); err != nil {
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
// credited when one of its origin's pubkeys (fingerprint + origin-path prefix)
// carries a partial signature, so cosigners sharing a master fingerprint are
// still told apart by their derivation path.
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
	signedPub := map[string]bool{}
	for i := range packet.Inputs {
		if n := len(packet.Inputs[i].PartialSigs); n > maxSigs {
			maxSigs = n
		}
		for _, ps := range packet.Inputs[i].PartialSigs {
			signedPub[hex.EncodeToString(ps.PubKey)] = true
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
		for i := range packet.Inputs {
			for _, d := range packet.Inputs[i].Bip32Derivation {
				if !signedPub[hex.EncodeToString(d.PubKey)] {
					continue
				}
				if originMatches(d.MasterKeyFingerprint, d.Bip32Path, origins) {
					cosignerSigned[ci] = true
					break
				}
			}
			if cosignerSigned[ci] {
				break
			}
		}
	}

	return MultisigSigningStatus{Signatures: maxSigs, Finalizable: finalizable, CosignerSigned: cosignerSigned}, nil
}

// keyOrigin is one cosigner's master fingerprint plus account-level origin path,
// the (fingerprint, origin-path) pair a PSBT's BIP32 derivation records expose.
type keyOrigin struct {
	fingerprint uint32
	path        []uint32
}

// groupKeyOrigins resolves each wallet key's [fingerprint/origin] into the
// fingerprint + account path the PSBT BIP32 derivations carry. Keys without an
// origin (non-wallet xpubs) contribute nothing — a group made entirely of such
// keys cannot be verified and is rejected by the caller's per-input check.
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
	if len(origins) == 0 {
		return nil, errors.New("group has no wallet keys with derivable origins; cannot verify PSBT membership")
	}
	return origins, nil
}

// verifyInputBelongsToGroup rejects a foreign PSBT input. The binding check is
// verifyInputScript: the k-of-n script the input actually commits to must be the
// one the group's own cosigner keys re-derive, so an input the group cannot own
// is refused whatever its metadata claims. The origin allow-list is kept as an
// additional constraint, so deleting derivation records cannot weaken either.
func verifyInputBelongsToGroup(in psbt.PInput, prevOut *wire.TxOut, m int, accts []*hdkeychain.ExtendedKey, origins []keyOrigin) error {
	if err := verifyInputOrigins(in, origins); err != nil {
		return err
	}
	return verifyInputScript(in, prevOut, m, accts)
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
func verifyInputScript(in psbt.PInput, prevOut *wire.TxOut, m int, accts []*hdkeychain.ExtendedKey) error {
	if prevOut == nil {
		return errors.New("has no witness or non-witness utxo; cannot verify it belongs to the group")
	}
	change, index, ok := chainIndexFromInput(in)
	if !ok {
		return errors.New("has no derivation path; cannot verify it belongs to the group")
	}

	var kinds []ScriptKind
	var script []byte
	switch {
	case len(in.TaprootLeafScript) > 0:
		kinds, script = []ScriptKind{ScriptMultisigTaproot}, in.TaprootLeafScript[0].Script
	case in.WitnessScript != nil:
		kinds, script = []ScriptKind{ScriptMultisig, ScriptMultisigNested}, in.WitnessScript
	case in.RedeemScript != nil:
		kinds, script = []ScriptKind{ScriptMultisigP2SH}, in.RedeemScript
	default:
		return errors.New("has no witness or redeem script; cannot verify it belongs to the group")
	}

	pubs := make([]*btcec.PublicKey, len(accts))
	for i, a := range accts {
		pub, err := deriveChildPub(a, chainIndex(change), index)
		if err != nil {
			return errors.New("does not belong to the multisig group (foreign input rejected)")
		}
		pubs[i] = pub
	}

	for _, kind := range kinds {
		// The network only selects the address encoding; the script bytes
		// compared here are the same on every network.
		ds, err := multisigOutput(kind, m, pubs, &chaincfg.MainNetParams)
		if err != nil {
			return err
		}
		own := ds.witnessScript
		switch kind {
		case ScriptMultisigP2SH:
			own = ds.redeemScript
		case ScriptMultisigTaproot:
			own = ds.tapLeafScript
		}
		if bytes.Equal(script, own) && bytes.Equal(prevOut.PkScript, ds.scriptPubKey) {
			return nil
		}
	}
	return errors.New("does not belong to the multisig group (foreign input rejected)")
}

// verifyInputOrigins requires every BIP32 derivation record on the input to trace
// to one of the group's cosigner origins (fingerprint + account path prefix).
func verifyInputOrigins(in psbt.PInput, origins []keyOrigin) error {
	if len(in.TaprootBip32Derivation) > 0 {
		for _, d := range in.TaprootBip32Derivation {
			if !originMatches(d.MasterKeyFingerprint, d.Bip32Path, origins) {
				return errors.New("does not belong to the multisig group (foreign input rejected)")
			}
		}
		return nil
	}
	if len(in.Bip32Derivation) == 0 {
		return errors.New("has no BIP32 derivation records; cannot verify it belongs to the group")
	}
	for _, d := range in.Bip32Derivation {
		if !originMatches(d.MasterKeyFingerprint, d.Bip32Path, origins) {
			return errors.New("does not belong to the multisig group (foreign input rejected)")
		}
	}
	return nil
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
