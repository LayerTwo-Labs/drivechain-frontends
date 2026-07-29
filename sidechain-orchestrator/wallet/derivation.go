package wallet

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/chaincfg"
)

// AccountPath is a resolved BIP32 account-level derivation path
// (purpose'/coin'/account'). All three levels are hardened.
type AccountPath struct {
	Purpose uint32
	Coin    uint32
	Account uint32
}

// String renders the path in m/p'/c'/a' form.
func (a AccountPath) String() string {
	return fmt.Sprintf("m/%d'/%d'/%d'", a.Purpose, a.Coin, a.Account)
}

// Origin renders the key-origin path "p'/c'/a'" without the leading "m/", using
// the given separator for the hardened marker ("'" for descriptors, "h" for
// PSBT origins).
func (a AccountPath) Origin(hardened string) string {
	return fmt.Sprintf("%d%s/%d%s/%d%s", a.Purpose, hardened, a.Coin, hardened, a.Account, hardened)
}

// validSingleSigPurposes are the BIP-standard purposes accepted for single-sig
// account paths. Anything else is rejected so a typo can't import descriptors
// the wallet will never be able to recover from elsewhere.
var validSingleSigPurposes = map[uint32]bool{44: true, 49: true, 84: true, 86: true}

// ParseAccountPath validates and parses a full account-level derivation path of
// the form "m/purpose'/coin'/account'". All three levels must be present and
// hardened. Purpose must be a known single-sig BIP, coin must be 0 (mainnet) or
// 1 (test), and account must fit in 31 bits.
func ParseAccountPath(path string) (AccountPath, error) {
	s := strings.TrimSpace(path)
	s = strings.TrimPrefix(s, "m/")
	s = strings.TrimPrefix(s, "M/")
	parts := strings.Split(s, "/")
	if len(parts) != 3 {
		return AccountPath{}, fmt.Errorf("derivation path %q must have exactly 3 levels (purpose'/coin'/account')", path)
	}

	levels := make([]uint32, 3)
	for i, p := range parts {
		p = strings.TrimSpace(p)
		if !strings.HasSuffix(p, "'") && !strings.HasSuffix(p, "h") && !strings.HasSuffix(p, "H") {
			return AccountPath{}, fmt.Errorf("derivation path level %q must be hardened (suffix ' or h)", p)
		}
		num := strings.TrimRight(p, "'hH")
		v, err := strconv.ParseUint(num, 10, 32)
		if err != nil {
			return AccountPath{}, fmt.Errorf("derivation path level %q is not a valid index: %w", p, err)
		}
		if v >= 1<<31 {
			return AccountPath{}, fmt.Errorf("derivation path level %d out of hardened range", v)
		}
		levels[i] = uint32(v)
	}

	ap := AccountPath{Purpose: levels[0], Coin: levels[1], Account: levels[2]}
	if !validSingleSigPurposes[ap.Purpose] {
		return AccountPath{}, fmt.Errorf("unsupported derivation purpose %d' (want one of 44'/49'/84'/86')", ap.Purpose)
	}
	if ap.Coin != 0 && ap.Coin != 1 {
		return AccountPath{}, fmt.Errorf("unsupported coin type %d' (want 0' mainnet or 1' test)", ap.Coin)
	}
	return ap, nil
}

// maxDerivationDepth bounds a keystore path so a pasted mistake cannot ask the
// wallet — or a hardware device — to walk an unbounded derivation.
const maxDerivationDepth = 10

// ParseKeystorePath validates a BIP32 derivation path of any depth, hardened or
// not, and returns it canonicalised as "m/48'/1'/0'/2'".
func ParseKeystorePath(path string) (string, error) {
	s := strings.TrimSpace(path)
	s = strings.TrimPrefix(s, "m/")
	s = strings.TrimPrefix(s, "M/")
	if s == "" || s == "m" || s == "M" {
		return "", fmt.Errorf("derivation path %q needs at least one level, e.g. m/84'/0'/0'", path)
	}
	parts := strings.Split(s, "/")
	if len(parts) > maxDerivationDepth {
		return "", fmt.Errorf("derivation path has %d levels (at most %d)", len(parts), maxDerivationDepth)
	}

	levels := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p == "" {
			return "", fmt.Errorf("derivation path %q has an empty level", path)
		}
		hardened := strings.HasSuffix(p, "'") || strings.HasSuffix(p, "h") || strings.HasSuffix(p, "H")
		v, err := strconv.ParseUint(strings.TrimRight(p, "'hH"), 10, 32)
		if err != nil {
			return "", fmt.Errorf("derivation path level %q is not a number", p)
		}
		if v >= 1<<31 {
			return "", fmt.Errorf("derivation path level %q is out of range (max %d)", p, 1<<31-1)
		}
		if hardened {
			levels = append(levels, strconv.FormatUint(v, 10)+"'")
		} else {
			levels = append(levels, strconv.FormatUint(v, 10))
		}
	}
	return "m/" + strings.Join(levels, "/"), nil
}

// KeystorePathScriptType returns the script type a path is the standard account
// path for under the given policy, or "" when it is a custom path.
func KeystorePathScriptType(path string, multisig bool) string {
	normalized, err := ParseKeystorePath(path)
	if err != nil {
		return ""
	}
	levels := strings.Split(strings.TrimPrefix(normalized, "m/"), "/")
	purpose, ok := hardenedLevel(levels[0])
	if !ok {
		return ""
	}

	if multisig {
		if purpose == 45 && len(levels) == 2 {
			return "sh"
		}
		if purpose != 48 || len(levels) != 4 {
			return ""
		}
		leaf, ok := hardenedLevel(levels[3])
		if !ok {
			return ""
		}
		switch leaf {
		case 1:
			return "sh-wsh"
		case 2:
			return "wsh"
		case 3:
			return "tr"
		}
		return ""
	}

	if len(levels) != 3 {
		return ""
	}
	switch purpose {
	case 44:
		return "pkh"
	case 49:
		return "sh-wpkh"
	case 84:
		return "wpkh"
	case 86:
		return "tr"
	}
	return ""
}

// hardenedLevel parses one canonical path level, reporting false unless it is
// hardened.
func hardenedLevel(level string) (uint32, bool) {
	if !strings.HasSuffix(level, "'") {
		return 0, false
	}
	v, err := strconv.ParseUint(strings.TrimSuffix(level, "'"), 10, 32)
	if err != nil {
		return 0, false
	}
	return uint32(v), true
}

// DerivationPathOption is one standard derivation path offered for a policy.
type DerivationPathOption struct {
	Label string
	Path  string
}

// StandardDerivationPaths returns the standard account paths a keystore can
// derive at under the given policy, plus the path used when it sets none.
func StandardDerivationPaths(scriptType string, multisig bool, account uint32, net *chaincfg.Params) ([]DerivationPathOption, string, error) {
	defaultPath, _, err := keystorePath(scriptType, multisig, account, net)
	if err != nil {
		return nil, "", err
	}

	standard := []DerivationPathOption{
		{Label: "Native Segwit (BIP84)", Path: "native-segwit"},
		{Label: "Taproot (BIP86)", Path: "taproot"},
		{Label: "Nested Segwit (BIP49)", Path: "nested-segwit"},
		{Label: "Legacy (BIP44)", Path: "legacy"},
	}
	if multisig {
		standard = []DerivationPathOption{
			{Label: "Native Segwit (BIP48)", Path: "wsh"},
			{Label: "Taproot (BIP48)", Path: "tr"},
			{Label: "Nested Segwit (BIP48)", Path: "sh-wsh"},
			{Label: "Legacy (BIP45)", Path: "sh"},
		}
	}
	for i, opt := range standard {
		p, _, perr := keystorePath(opt.Path, multisig, account, net)
		if perr != nil {
			return nil, "", perr
		}
		standard[i].Path = p
	}
	return standard, defaultPath, nil
}

// ResolveCreateDerivationPath validates a create-time derivation override:
// derivationPath (an explicit full account path) takes precedence and is
// returned canonicalised with the account index forced to 0; otherwise the
// validated accountIndex is returned with an empty path. The two stored fields
// are mutually exclusive.
func ResolveCreateDerivationPath(accountIndex uint32, derivationPath string) (account uint32, path string, err error) {
	if strings.TrimSpace(derivationPath) != "" {
		ap, perr := ParseAccountPath(derivationPath)
		if perr != nil {
			return 0, "", perr
		}
		return 0, ap.String(), nil
	}
	if accountIndex >= 1<<31 {
		return 0, "", fmt.Errorf("account index %d out of hardened range", accountIndex)
	}
	return accountIndex, "", nil
}

// ResolveAccountPath resolves the account path for a stored override: an
// explicit derivationPath takes precedence; otherwise the standard path for the
// kind and network at accountIndex. Mirrors accountPathFor for callers outside
// this package (e.g. the bitwindow Core fallback) so both derive identically.
func ResolveAccountPath(accountIndex uint32, derivationPath string, kind ScriptKind, net *chaincfg.Params) (AccountPath, error) {
	return accountPathFor(&WalletData{AccountIndex: accountIndex, DerivationPath: derivationPath}, kind, net)
}

// CoreDescriptorWrapper returns the open/close fragments wrapping the key
// expression for a single-sig kind's Core descriptor. Exported for the
// bitwindow Core fallback path.
func CoreDescriptorWrapper(kind ScriptKind) (open, close string, ok bool) {
	return coreDescriptorWrapper(kind)
}

// PurposeToCoreKind maps a BIP purpose to the single-sig kind Core imports for
// it. Exported for the bitwindow Core fallback path.
func PurposeToCoreKind(purpose uint32) (ScriptKind, bool) {
	return purposeToCoreKind(purpose)
}

// accountPathFor resolves the account path a wallet derives from for a given
// script kind: its explicit DerivationPath override if present, else the
// standard path for the kind and network at the wallet's AccountIndex.
func accountPathFor(w *WalletData, kind ScriptKind, net *chaincfg.Params) (AccountPath, error) {
	if w.usesExplicitPath() {
		return ParseAccountPath(w.DerivationPath)
	}
	purpose, ok := kind.Purpose()
	if !ok {
		return AccountPath{}, fmt.Errorf("no derivation purpose for script kind %s", kind)
	}
	coin := uint32(1)
	if net != nil {
		coin = net.HDCoinType
	}
	return AccountPath{Purpose: purpose, Coin: coin, Account: w.AccountIndex}, nil
}

// multisigAccountPath returns the cosigner account path for a script type:
// BIP48 for segwit variants, BIP45 for legacy P2SH.
func multisigAccountPath(scriptType string, account uint32, net *chaincfg.Params) (string, error) {
	if account >= 1<<31 {
		return "", fmt.Errorf("account index %d out of hardened range", account)
	}
	coin := uint32(1)
	if net != nil {
		coin = net.HDCoinType
	}
	switch scriptType {
	case "sh":
		return fmt.Sprintf("m/45'/%d'", account), nil
	case "sh-wsh":
		return fmt.Sprintf("m/48'/%d'/%d'/1'", coin, account), nil
	case "tr":
		return fmt.Sprintf("m/48'/%d'/%d'/3'", coin, account), nil
	case "wsh", "":
		return fmt.Sprintf("m/48'/%d'/%d'/2'", coin, account), nil
	default:
		return "", fmt.Errorf("unknown multisig script type %q", scriptType)
	}
}

// usesExplicitPath reports whether the wallet pins a single explicit purpose via
// a full DerivationPath override (vs only shifting the account index).
func (w *WalletData) usesExplicitPath() bool {
	return strings.TrimSpace(w.DerivationPath) != ""
}
