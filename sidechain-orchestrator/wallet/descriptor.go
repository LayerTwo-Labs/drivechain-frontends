package wallet

import (
	"encoding/binary"
	"encoding/hex"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
)

// Descriptor is a parsed output descriptor describing how an electrum wallet's
// addresses derive. It carries the script kind and the account-level extended
// keys; the external (0) and internal (1) chains derive from each account key
// per BIP. Single-sig descriptors have one key and Threshold 1; multisig
// (wsh sortedmulti) has N keys and a k-of-N threshold.
//
// All cryptographic derivation runs through btcsuite/hdkeychain; this file only
// parses the textual descriptor grammar.
type Descriptor struct {
	Kind      ScriptKind
	Threshold int
	Keys      []DescriptorKey
}

// DescriptorKey is one key expression: an optional [origin] annotation and the
// account-level extended public key the chains derive from.
type DescriptorKey struct {
	Origin  string // e.g. "abcd1234/84h/0h/0h", optional
	Account *hdkeychain.ExtendedKey
}

// ParseDescriptor parses and checksum-validates an output descriptor. A bare
// extended key (no script function) is accepted as native segwit for backward
// compatibility. Multisig descriptors are handled by parseMultisig.
func ParseDescriptor(s string) (*Descriptor, error) {
	body, err := stripDescriptorChecksum(s)
	if err != nil {
		return nil, err
	}
	body = strings.TrimSpace(body)
	if body == "" {
		return nil, errors.New("empty descriptor")
	}

	// Bare extended key — no script wrapper. A SLIP-0132 header (ypub/zpub/…)
	// sets the kind; a plain xpub/tpub defaults to native segwit (BIP84).
	if !strings.Contains(body, "(") {
		key, kind, hasKind, err := parseKeyExprKind(body)
		if err != nil {
			return nil, err
		}
		if !hasKind {
			kind = ScriptNativeSegwit
		}
		return &Descriptor{Kind: kind, Threshold: 1, Keys: []DescriptorKey{key}}, nil
	}

	switch {
	case strings.HasPrefix(body, "pkh("):
		return parseSingleSig(ScriptLegacy, body, "pkh(")
	case strings.HasPrefix(body, "wpkh("):
		return parseSingleSig(ScriptNativeSegwit, body, "wpkh(")
	case strings.HasPrefix(body, "sh(wpkh("):
		inner, err := unwrap(body, "sh(")
		if err != nil {
			return nil, err
		}
		return parseSingleSig(ScriptNestedSegwit, inner, "wpkh(")
	case strings.HasPrefix(body, "tr("):
		// Key-path only: a script tree (comma or brace inside) is unsupported.
		inner, err := unwrap(body, "tr(")
		if err != nil {
			return nil, err
		}
		if strings.ContainsAny(inner, ",{") {
			return nil, errors.New("tr() with a script tree is not supported (key-path only)")
		}
		key, err := parseKeyExpr(inner)
		if err != nil {
			return nil, err
		}
		return &Descriptor{Kind: ScriptTaproot, Threshold: 1, Keys: []DescriptorKey{key}}, nil
	case strings.HasPrefix(body, "wsh(sortedmulti(") ||
		strings.HasPrefix(body, "sh(wsh(sortedmulti(") ||
		strings.HasPrefix(body, "sh(sortedmulti("):
		return parseMultisig(body)
	case strings.HasPrefix(body, "wsh(") || strings.HasPrefix(body, "multi(") || strings.HasPrefix(body, "combo("):
		return nil, errors.New("unsupported descriptor: only single-sig and sortedmulti are supported")
	default:
		return nil, fmt.Errorf("unrecognized descriptor: %q", firstToken(body))
	}
}

func parseSingleSig(kind ScriptKind, body, prefix string) (*Descriptor, error) {
	inner, err := unwrap(body, prefix)
	if err != nil {
		return nil, err
	}
	key, err := parseKeyExpr(inner)
	if err != nil {
		return nil, err
	}
	return &Descriptor{Kind: kind, Threshold: 1, Keys: []DescriptorKey{key}}, nil
}

// unwrap strips a single function wrapper, e.g. unwrap("wpkh(xpub)", "wpkh(")
// returns "xpub". It requires the body to start with prefix and end with ")".
func unwrap(body, prefix string) (string, error) {
	if !strings.HasPrefix(body, prefix) || !strings.HasSuffix(body, ")") {
		return "", fmt.Errorf("malformed descriptor fragment: %q", body)
	}
	return body[len(prefix) : len(body)-1], nil
}

// parseKeyExpr parses "[origin]xpub[/branch/*]". The branch suffix is validated
// to be /0/* or /<0;1>/*; derivation always produces both account/0 and
// account/1 chains per BIP.
func parseKeyExpr(expr string) (DescriptorKey, error) {
	key, _, _, err := parseKeyExprKind(expr)
	return key, err
}

// parseKeyExprKind parses "[origin]xpub[/branch/*]", normalizing SLIP-0132
// extended keys, and additionally reports the script kind a SLIP-0132 header
// implies (hasKind=false for plain xpub/tpub, where the caller keeps its default).
func parseKeyExprKind(expr string) (DescriptorKey, ScriptKind, bool, error) {
	expr = strings.TrimSpace(expr)
	var origin string
	if strings.HasPrefix(expr, "[") {
		end := strings.Index(expr, "]")
		if end < 0 {
			return DescriptorKey{}, 0, false, fmt.Errorf("unterminated key origin in %q", expr)
		}
		origin = expr[1:end]
		expr = expr[end+1:]
	}

	keyToken := expr
	if i := strings.Index(expr, "/"); i >= 0 {
		keyToken = expr[:i]
		if err := validateBranchSuffix(expr[i:]); err != nil {
			return DescriptorKey{}, 0, false, err
		}
	}

	canonical, kind, hasKind, err := normalizeExtendedKey(keyToken)
	if err != nil {
		return DescriptorKey{}, 0, false, err
	}
	acct, err := hdkeychain.NewKeyFromString(canonical)
	if err != nil {
		return DescriptorKey{}, 0, false, fmt.Errorf("parse extended key %q: %w", keyToken, err)
	}
	return DescriptorKey{Origin: origin, Account: acct}, kind, hasKind, nil
}

// validateBranchSuffix accepts only the standard wallet layouts so we never
// silently mis-derive: /0/*, or the multipath /<0;1>/*. A bare /* is
// rejected because derivation always appends the external/change branch.
// /1/* (change-only) is rejected: derivation always produces both chains,
// so receive addresses would come from account/0 — outside the descriptor.
func validateBranchSuffix(suffix string) error {
	switch suffix {
	case "/0/*", "/<0;1>/*":
		return nil
	default:
		return fmt.Errorf("unsupported derivation branch %q (expected /0/* or /<0;1>/*)", suffix)
	}
}

// String renders the descriptor in canonical form with a checksum, using the
// multipath /<0;1>/* branch and neutering any private account keys.
func (d *Descriptor) String() (string, error) {
	exprs := make([]string, len(d.Keys))
	for i, k := range d.Keys {
		acct := k.Account
		if acct.IsPrivate() {
			pub, err := acct.Neuter()
			if err != nil {
				return "", err
			}
			acct = pub
		}
		expr := acct.String()
		if k.Origin != "" {
			expr = "[" + k.Origin + "]" + expr
		}
		exprs[i] = expr + "/<0;1>/*"
	}

	var body string
	switch d.Kind {
	case ScriptLegacy:
		body = "pkh(" + exprs[0] + ")"
	case ScriptNativeSegwit:
		body = "wpkh(" + exprs[0] + ")"
	case ScriptNestedSegwit:
		body = "sh(wpkh(" + exprs[0] + "))"
	case ScriptTaproot:
		body = "tr(" + exprs[0] + ")"
	case ScriptMultisig:
		body = fmt.Sprintf("wsh(sortedmulti(%d,%s))", d.Threshold, strings.Join(exprs, ","))
	case ScriptMultisigP2SH:
		body = fmt.Sprintf("sh(sortedmulti(%d,%s))", d.Threshold, strings.Join(exprs, ","))
	case ScriptMultisigNested:
		body = fmt.Sprintf("sh(wsh(sortedmulti(%d,%s)))", d.Threshold, strings.Join(exprs, ","))
	default:
		return "", fmt.Errorf("cannot serialize script kind %s", d.Kind)
	}
	sum, err := DescriptorChecksum(body)
	if err != nil {
		return "", err
	}
	return body + "#" + sum, nil
}

// DeriveScript resolves the address + scripts at (change, index). For single-sig
// it also returns the child public key; for multisig the per-key pubkeys are
// resolved internally and the returned pubkey is nil.
func (d *Descriptor) DeriveScript(change bool, index uint32, net *chaincfg.Params) (derivedScript, *btcec.PublicKey, error) {
	chain := uint32(0)
	if change {
		chain = 1
	}

	if d.Kind.isMultisig() {
		pubs := make([]*btcec.PublicKey, len(d.Keys))
		for i, k := range d.Keys {
			pub, err := deriveChildPub(k.Account, chain, index)
			if err != nil {
				return derivedScript{}, nil, err
			}
			pubs[i] = pub
		}
		ds, err := multisigOutput(d.Kind, d.Threshold, pubs, net)
		return ds, nil, err
	}

	pub, err := deriveChildPub(d.Keys[0].Account, chain, index)
	if err != nil {
		return derivedScript{}, nil, err
	}
	ds, err := singleSigOutput(d.Kind, pub, net)
	return ds, pub, err
}

// deriveChildPub derives account/chain/index and returns the child public key.
// derivations returns the PSBT key-derivation records for the address at
// (change, index): one per descriptor key, each with the child pubkey, master
// fingerprint, and full path. Keys with no parseable origin fall back to the
// account key's own fingerprint and a path of just [chain, index].
func (d *Descriptor) derivations(change bool, index uint32) ([]keyDerivation, error) {
	chain := chainIndex(change)
	out := make([]keyDerivation, 0, len(d.Keys))
	for _, k := range d.Keys {
		pub, err := deriveChildPub(k.Account, chain, index)
		if err != nil {
			return nil, err
		}
		fp, path, ok := parseOrigin(k.Origin)
		if ok {
			path = append(path, chain, index)
		} else {
			fp = keyFingerprint(k.Account)
			path = []uint32{chain, index}
		}
		out = append(out, keyDerivation{pub: pub, fingerprint: fp, path: path})
	}
	return out, nil
}

// parseOrigin parses a descriptor key origin "fingerprint/path", e.g.
// "abcd1234/84h/0h/0h", into the master fingerprint (as the little-endian uint32
// the PSBT layer serializes) and the hardened-aware account path.
func parseOrigin(origin string) (uint32, []uint32, bool) {
	if origin == "" {
		return 0, nil, false
	}
	parts := strings.Split(origin, "/")
	fpBytes, err := hex.DecodeString(parts[0])
	if err != nil || len(fpBytes) != 4 {
		return 0, nil, false
	}
	path := make([]uint32, 0, len(parts)-1)
	for _, seg := range parts[1:] {
		if seg == "" {
			continue
		}
		hardened := false
		if s := seg[len(seg)-1]; s == 'h' || s == 'H' || s == '\'' {
			hardened = true
			seg = seg[:len(seg)-1]
		}
		n, err := strconv.ParseUint(seg, 10, 32)
		if err != nil {
			return 0, nil, false
		}
		v := uint32(n)
		if hardened {
			v += hdkeychain.HardenedKeyStart
		}
		path = append(path, v)
	}
	return binary.LittleEndian.Uint32(fpBytes), path, true
}

// keyFingerprint computes an extended key's own fingerprint (hash160 of its
// compressed pubkey, first 4 bytes) as the little-endian uint32 the PSBT layer
// serializes. Used as the master fingerprint when a key carries no origin.
func keyFingerprint(key *hdkeychain.ExtendedKey) uint32 {
	pub, err := key.ECPubKey()
	if err != nil {
		return 0
	}
	return binary.LittleEndian.Uint32(btcutil.Hash160(pub.SerializeCompressed())[:4])
}

func deriveChildPub(account *hdkeychain.ExtendedKey, chain, index uint32) (*btcec.PublicKey, error) {
	child, err := deriveChild(account, chain, index)
	if err != nil {
		return nil, err
	}
	return child.ECPubKey()
}

// deriveChildPrivIfPossible derives the child private key at account/chain/index
// when the account key is private (hot wallet); returns ok=false for a public
// account key (watch-only).
func deriveChildPrivIfPossible(account *hdkeychain.ExtendedKey, chain, index uint32) (*btcec.PrivateKey, bool, error) {
	if !account.IsPrivate() {
		return nil, false, nil
	}
	child, err := deriveChild(account, chain, index)
	if err != nil {
		return nil, false, err
	}
	priv, err := child.ECPrivKey()
	if err != nil {
		return nil, false, err
	}
	return priv, true, nil
}

func deriveChild(account *hdkeychain.ExtendedKey, chain, index uint32) (*hdkeychain.ExtendedKey, error) {
	chainKey, err := account.Derive(chain)
	if err != nil {
		return nil, fmt.Errorf("derive chain %d: %w", chain, err)
	}
	child, err := chainKey.Derive(index)
	if err != nil {
		return nil, fmt.Errorf("derive index %d: %w", index, err)
	}
	return child, nil
}

// parseMultisig parses the sortedmulti wrappers — wsh (P2WSH), sh(wsh (P2SH-P2WSH),
// and sh (legacy P2SH) — into a multisig descriptor with the matching kind.
func parseMultisig(body string) (*Descriptor, error) {
	var kind ScriptKind
	var inner string
	var err error
	switch {
	case strings.HasPrefix(body, "wsh(sortedmulti("):
		kind = ScriptMultisig
		inner, err = unwrap(body, "wsh(")
	case strings.HasPrefix(body, "sh(wsh(sortedmulti("):
		kind = ScriptMultisigNested
		inner, err = unwrap(body, "sh(")
		if err == nil {
			inner, err = unwrap(inner, "wsh(")
		}
	case strings.HasPrefix(body, "sh(sortedmulti("):
		kind = ScriptMultisigP2SH
		inner, err = unwrap(body, "sh(")
	default:
		return nil, errors.New("unsupported multisig descriptor")
	}
	if err != nil {
		return nil, err
	}
	args, err := unwrap(inner, "sortedmulti(")
	if err != nil {
		return nil, err
	}
	parts := strings.Split(args, ",")
	if len(parts) < 2 {
		return nil, errors.New("sortedmulti needs a threshold and at least one key")
	}
	threshold, err := strconv.Atoi(strings.TrimSpace(parts[0]))
	if err != nil {
		return nil, fmt.Errorf("multisig threshold: %w", err)
	}
	keys := make([]DescriptorKey, 0, len(parts)-1)
	for _, p := range parts[1:] {
		k, err := parseKeyExpr(p)
		if err != nil {
			return nil, err
		}
		keys = append(keys, k)
	}
	if threshold < 1 || threshold > len(keys) {
		return nil, fmt.Errorf("multisig threshold %d out of range for %d keys", threshold, len(keys))
	}
	return &Descriptor{Kind: kind, Threshold: threshold, Keys: keys}, nil
}

// accountKeyFromSeed derives the BIP-standard account extended key
// (m/purpose'/coin'/0') for a script kind from a hex seed, via hdkeychain.
func accountKeyFromSeed(seedHex string, kind ScriptKind, net *chaincfg.Params) (*hdkeychain.ExtendedKey, error) {
	acct, _, err := accountKeyAndOrigin(seedHex, kind, net)
	return acct, err
}

// accountKeyAndOrigin derives the account extended key and the matching key
// origin ("masterFingerprint/purpose'/coin'/0'"), so a hot wallet's PSBTs carry
// the real master fingerprint and full derivation path for external signers.
func accountKeyAndOrigin(seedHex string, kind ScriptKind, net *chaincfg.Params) (*hdkeychain.ExtendedKey, string, error) {
	if net == nil {
		return nil, "", errors.New("no chain params for this network; cannot derive electrum wallet")
	}
	purpose, ok := kind.Purpose()
	if !ok {
		return nil, "", fmt.Errorf("no derivation purpose for kind %s", kind)
	}
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return nil, "", fmt.Errorf("decode seed hex: %w", err)
	}
	master, err := hdkeychain.NewMaster(seed, net)
	if err != nil {
		return nil, "", fmt.Errorf("create master key: %w", err)
	}
	masterPub, err := master.ECPubKey()
	if err != nil {
		return nil, "", err
	}
	fingerprint := hex.EncodeToString(btcutil.Hash160(masterPub.SerializeCompressed())[:4])

	const h = hdkeychain.HardenedKeyStart
	acct, err := deriveHardened(master, h+purpose, h+net.HDCoinType, h+0)
	if err != nil {
		return nil, "", err
	}
	origin := fmt.Sprintf("%s/%dh/%dh/0h", fingerprint, purpose, net.HDCoinType)
	return acct, origin, nil
}

func deriveHardened(key *hdkeychain.ExtendedKey, path ...uint32) (*hdkeychain.ExtendedKey, error) {
	cur := key
	for _, p := range path {
		next, err := cur.Derive(p)
		if err != nil {
			return nil, fmt.Errorf("derive %d: %w", p, err)
		}
		cur = next
	}
	return cur, nil
}

// stripDescriptorChecksum validates and removes a trailing "#checksum" if
// present. A descriptor without a checksum is accepted (users paste both forms).
func stripDescriptorChecksum(s string) (string, error) {
	s = strings.TrimSpace(s)
	i := strings.LastIndex(s, "#")
	if i < 0 {
		return s, nil
	}
	body, sum := s[:i], s[i+1:]
	want, err := DescriptorChecksum(body)
	if err != nil {
		return "", fmt.Errorf("compute descriptor checksum: %w", err)
	}
	if want != sum {
		return "", fmt.Errorf("descriptor checksum mismatch: have %q, want %q", sum, want)
	}
	return body, nil
}

func firstToken(s string) string {
	if i := strings.IndexAny(s, "([,"); i >= 0 {
		return s[:i]
	}
	return s
}
