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
