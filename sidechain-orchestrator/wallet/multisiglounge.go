package wallet

import (
	"encoding/base64"
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
	if g.M < 1 {
		return "", "", fmt.Errorf("invalid threshold m=%d", g.M)
	}
	if len(g.Keys) == 0 {
		return "", "", errors.New("group has no keys")
	}

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

	receiveBody := fmt.Sprintf("wsh(sortedmulti(%d,%s))", g.M, strings.Join(receiveParts, ","))
	changeBody := fmt.Sprintf("wsh(sortedmulti(%d,%s))", g.M, strings.Join(changeParts, ","))

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
	if g.M < 1 {
		return "", "", fmt.Errorf("invalid threshold m=%d", g.M)
	}
	if len(g.Keys) == 0 {
		return "", "", errors.New("group has no keys")
	}
	if len(signWithXprv) == 0 {
		return "", "", errors.New("no signing keys provided")
	}

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

	receive = fmt.Sprintf("wsh(sortedmulti(%d,%s))", g.M, strings.Join(receiveParts, ","))
	change = fmt.Sprintf("wsh(sortedmulti(%d,%s))", g.M, strings.Join(changeParts, ","))
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
