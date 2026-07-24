package wallet

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
)

// KeystoreSource is exactly one origin for a keystore's key: a seed mnemonic, a
// USB hardware device, or a pasted key expression / descriptor.
type KeystoreSource struct {
	Mnemonic   string
	Passphrase string
	Device     *HardwareSelector
	RawKey     string
}

// DerivedKeystore is the account-level key material the backend derives from a
// keystore's source and intent.
type DerivedKeystore struct {
	Xpub        string
	Fingerprint string
	OriginPath  string // without leading m/
	Descriptor  string // single-sig watch descriptor for device/raw sources
}

// DeriveKeystore turns a keystore's intent (source, script type, single/multi,
// account) into its account key material.
func DeriveKeystore(
	ctx context.Context,
	src KeystoreSource,
	scriptType string,
	multisig bool,
	account uint32,
	net *chaincfg.Params,
) (DerivedKeystore, error) {
	// Path for mnemonic and device sources; a raw key carries its own origin.
	path, singleKind, err := keystorePath(scriptType, multisig, account, net)
	if err != nil {
		return DerivedKeystore{}, err
	}
	originPath := strings.TrimPrefix(path, "m/")

	var out DerivedKeystore
	switch {
	case src.Mnemonic != "":
		seedHex := hex.EncodeToString(MnemonicToSeed(src.Mnemonic, src.Passphrase))
		xpub, xerr := DeriveAccountXpub(seedHex, path, net)
		if xerr != nil {
			return DerivedKeystore{}, xerr
		}
		fp, ferr := seedMasterFingerprint(seedHex, net)
		if ferr != nil {
			return DerivedKeystore{}, ferr
		}
		out = DerivedKeystore{Xpub: xpub, Fingerprint: fp, OriginPath: originPath}

	case src.Device != nil && (src.Device.Type != "" || src.Device.Fingerprint != "" || src.Device.Path != ""):
		xpub, xerr := NewHWIRunner(net).GetXpub(ctx, *src.Device, path)
		if xerr != nil {
			return DerivedKeystore{}, xerr
		}
		out = DerivedKeystore{Xpub: xpub, Fingerprint: src.Device.Fingerprint, OriginPath: originPath}

	case src.RawKey != "":
		xpub, fp, origin, rerr := parseRawKey(src.RawKey)
		if rerr != nil {
			return DerivedKeystore{}, rerr
		}
		out = DerivedKeystore{Xpub: xpub, Fingerprint: fp, OriginPath: origin}

	default:
		return DerivedKeystore{}, errors.New("no keystore source provided")
	}

	// Single-sig device/raw sources get a ready-to-import watch descriptor.
	if !multisig && out.Fingerprint != "" && out.OriginPath != "" {
		desc, derr := singleSigWatchDescriptor(singleKind, out.Fingerprint, out.OriginPath, out.Xpub)
		if derr != nil {
			return DerivedKeystore{}, derr
		}
		out.Descriptor = desc
	}
	return out, nil
}

// keystorePath resolves the derivation path for a keystore. Single-sig follows
// BIP44/49/84/86 from the script type; multisig follows BIP48/45.
func keystorePath(scriptType string, multisig bool, account uint32, net *chaincfg.Params) (path string, kind ScriptKind, err error) {
	if multisig {
		p, perr := multisigAccountPath(scriptType, account, net)
		return p, ScriptKind(0), perr
	}
	kind = HotScriptKind(scriptType)
	purpose, ok := kind.Purpose()
	if !ok {
		return "", kind, fmt.Errorf("unknown single-sig script type %q", scriptType)
	}
	coin := uint32(1)
	if net != nil {
		coin = net.HDCoinType
	}
	return AccountPath{Purpose: purpose, Coin: coin, Account: account}.String(), kind, nil
}

// seedMasterFingerprint returns the BIP32 master key fingerprint (hex) for a seed.
func seedMasterFingerprint(seedHex string, net *chaincfg.Params) (string, error) {
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return "", err
	}
	master, err := hdkeychain.NewMaster(seed, net)
	if err != nil {
		return "", err
	}
	pub, err := master.ECPubKey()
	if err != nil {
		return "", err
	}
	return hex.EncodeToString(btcutil.Hash160(pub.SerializeCompressed())[:4]), nil
}

// parseRawKey normalizes a pasted "[fp/origin]xpub", bare xpub, or single-key
// descriptor into its neutered xpub, fingerprint, and origin path.
func parseRawKey(raw string) (xpub, fingerprint, originPath string, err error) {
	d, err := ParseDescriptor(strings.TrimSpace(raw))
	if err != nil {
		return "", "", "", err
	}
	if len(d.Keys) != 1 {
		return "", "", "", fmt.Errorf("expected a single key, got %d", len(d.Keys))
	}
	pub, err := d.Keys[0].Account.Neuter()
	if err != nil {
		return "", "", "", err
	}
	xpub = pub.String()
	if origin := d.Keys[0].Origin; origin != "" {
		if slash := strings.IndexByte(origin, '/'); slash > 0 {
			fingerprint = origin[:slash]
			originPath = origin[slash+1:]
		}
	}
	return xpub, fingerprint, originPath, nil
}

// singleSigWatchDescriptor builds the canonical checksummed watch descriptor
// wrap([fp/origin]xpub/<0;1>/*) for a single-sig kind.
func singleSigWatchDescriptor(kind ScriptKind, fingerprint, originPath, xpub string) (string, error) {
	open, close, ok := coreDescriptorWrapper(kind)
	if !ok {
		return "", fmt.Errorf("no single-sig descriptor for kind %s", kind)
	}
	raw := fmt.Sprintf("%s[%s/%s]%s/<0;1>/*%s", open, fingerprint, originPath, xpub, close)
	d, err := ParseDescriptor(raw)
	if err != nil {
		return "", err
	}
	return d.String()
}
