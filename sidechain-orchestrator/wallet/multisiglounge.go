package wallet

import (
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"sort"
	"strings"

	"github.com/btcsuite/btcd/btcutil/psbt"
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
		for i := range packet.Inputs {
			if err := verifyInputBelongsToGroup(packet.Inputs[i], origins); err != nil {
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
	cosigners = make([]MultisigCosigner, 0, len(d.Keys))
	for _, k := range d.Keys {
		acct := k.Account
		if acct.IsPrivate() {
			pub, nerr := acct.Neuter()
			if nerr != nil {
				return 0, 0, "", nil, fmt.Errorf("neuter key: %w", nerr)
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
	return d.Threshold, len(d.Keys), multisigTypeString(d.Kind), cosigners, nil
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

// verifyInputBelongsToGroup rejects a foreign PSBT input: every BIP32 derivation
// record on the input must trace to one of the group's cosigner origins
// (fingerprint + account path prefix). Derivation-independent — it matches on the
// origin metadata the PSBT carries, not on re-derived addresses.
func verifyInputBelongsToGroup(in psbt.PInput, origins []keyOrigin) error {
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
