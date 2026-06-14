package wallet

import (
	"encoding/hex"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2"
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

	// Bare extended key — no script wrapper. Treat as native segwit (BIP84).
	if !strings.Contains(body, "(") {
		key, err := parseKeyExpr(body)
		if err != nil {
			return nil, err
		}
		return &Descriptor{Kind: ScriptNativeSegwit, Threshold: 1, Keys: []DescriptorKey{key}}, nil
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
	case strings.HasPrefix(body, "wsh(sortedmulti(") || strings.HasPrefix(body, "sh(sortedmulti("):
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
// to be a standard external/change layout (/0/*, /1/*, or /<0;1>/*) but the
// chains are always derived as account/0 and account/1 per BIP.
func parseKeyExpr(expr string) (DescriptorKey, error) {
	expr = strings.TrimSpace(expr)
	var origin string
	if strings.HasPrefix(expr, "[") {
		end := strings.Index(expr, "]")
		if end < 0 {
			return DescriptorKey{}, fmt.Errorf("unterminated key origin in %q", expr)
		}
		origin = expr[1:end]
		expr = expr[end+1:]
	}

	keyToken := expr
	if i := strings.Index(expr, "/"); i >= 0 {
		keyToken = expr[:i]
		if err := validateBranchSuffix(expr[i:]); err != nil {
			return DescriptorKey{}, err
		}
	}

	acct, err := hdkeychain.NewKeyFromString(keyToken)
	if err != nil {
		return DescriptorKey{}, fmt.Errorf("parse extended key %q: %w", keyToken, err)
	}
	return DescriptorKey{Origin: origin, Account: acct}, nil
}

// validateBranchSuffix accepts only the standard wallet layouts so we never
// silently mis-derive: /0/*, /1/*, or the multipath /<0;1>/*. A bare /* is
// rejected because derivation always appends the external/change branch.
func validateBranchSuffix(suffix string) error {
	switch suffix {
	case "/0/*", "/1/*", "/<0;1>/*":
		return nil
	default:
		return fmt.Errorf("unsupported derivation branch %q (expected /0/*, /1/*, or /<0;1>/*)", suffix)
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

	if d.Kind == ScriptMultisig {
		pubs := make([]*btcec.PublicKey, len(d.Keys))
		for i, k := range d.Keys {
			pub, err := deriveChildPub(k.Account, chain, index)
			if err != nil {
				return derivedScript{}, nil, err
			}
			pubs[i] = pub
		}
		ds, _, err := multisigOutput(d.Threshold, pubs, net)
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

// parseMultisig parses wsh(sortedmulti(k,KEY,...)) and the legacy
// sh(sortedmulti(...)) form into a multisig descriptor.
func parseMultisig(body string) (*Descriptor, error) {
	// Only wsh(sortedmulti(...)) is supported; the multisig builder emits P2WSH,
	// so a legacy sh(sortedmulti(...)) would scan the wrong (P2SH) addresses.
	if !strings.HasPrefix(body, "wsh(") {
		return nil, errors.New("only wsh(sortedmulti(...)) multisig is supported")
	}
	inner, err := unwrap(body, "wsh(")
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
	return &Descriptor{Kind: ScriptMultisig, Threshold: threshold, Keys: keys}, nil
}

// accountKeyFromSeed derives the BIP-standard account extended key
// (m/purpose'/coin'/0') for a script kind from a hex seed, via hdkeychain.
func accountKeyFromSeed(seedHex string, kind ScriptKind, net *chaincfg.Params) (*hdkeychain.ExtendedKey, error) {
	if net == nil {
		return nil, errors.New("no chain params for this network; cannot derive electrum wallet")
	}
	purpose, ok := kind.Purpose()
	if !ok {
		return nil, fmt.Errorf("no derivation purpose for kind %s", kind)
	}
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return nil, fmt.Errorf("decode seed hex: %w", err)
	}
	master, err := hdkeychain.NewMaster(seed, net)
	if err != nil {
		return nil, fmt.Errorf("create master key: %w", err)
	}
	const h = hdkeychain.HardenedKeyStart
	acct, err := deriveHardened(master, h+purpose, h+net.HDCoinType, h+0)
	if err != nil {
		return nil, err
	}
	return acct, nil
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
