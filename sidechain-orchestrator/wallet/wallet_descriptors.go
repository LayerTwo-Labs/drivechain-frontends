package wallet

import (
	"bytes"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
)

// WalletDescriptors returns every descriptor a wallet derives, its receive
// default first.
func WalletDescriptors(w *WalletData, net *chaincfg.Params) ([]*Descriptor, error) {
	kinds := ReceiveKinds(w)
	out := make([]*Descriptor, 0, len(kinds))
	for _, kind := range kinds {
		d, err := DescriptorFor(w, kind, net)
		if err != nil {
			return nil, err
		}
		out = append(out, d)
	}
	return out, nil
}

// DescriptorFor returns the descriptor a wallet derives for one script kind. A
// multisig or watch-only wallet has one descriptor for every kind.
func DescriptorFor(w *WalletData, kind ScriptKind, net *chaincfg.Params) (*Descriptor, error) {
	if net == nil {
		return nil, errors.New("no chain params for this network; cannot derive the wallet")
	}
	switch {
	case w.Multisig != nil:
		return multisigDescriptor(w, "", net)
	case w.Master.SeedHex != "":
		ap, err := accountPathFor(w, kind, net)
		if err != nil {
			return nil, err
		}
		acct, origin, err := accountKeyAndOrigin(w.Master.SeedHex, ap, net)
		if err != nil {
			return nil, err
		}
		return &Descriptor{Kind: kind, Threshold: 1, Keys: []DescriptorKey{{Origin: origin, Account: acct}}}, nil
	default:
		desc, err := watchOnlyDescriptorString(w)
		if err != nil {
			return nil, err
		}
		// A bare xpub states no kind, so the one recorded at import decides.
		return ParseDescriptorAs(desc, w.scriptKind())
	}
}

// multisigDescriptor builds the multisig descriptor with each held cosigner as
// its account xprv, so the keys it derives can sign. A non-empty onlyXpub holds
// that one cosigner and leaves the rest as xpubs.
func multisigDescriptor(w *WalletData, onlyXpub string, net *chaincfg.Params) (*Descriptor, error) {
	ms := w.Multisig
	if ms == nil {
		return nil, errors.New("wallet has no multisig config")
	}
	group := MultisigLoungeGroup{M: ms.M, N: ms.N}
	signWithXprv := map[string]string{}
	for _, c := range ms.Cosigners {
		group.Keys = append(group.Keys, MultisigLoungeKey{
			Xpub:        c.Xpub,
			Fingerprint: c.Fingerprint,
			OriginPath:  c.OriginPath,
			// A hardware signer needs the origin of every cosigner to rebuild the
			// multisig script it signs over.
			IsWallet: c.Fingerprint != "",
		})
		if !c.Held() || (onlyXpub != "" && c.Xpub != onlyXpub) {
			continue
		}
		xprv := c.Xprv
		if xprv == "" {
			x, err := cosignerXprv(c, net)
			if err != nil {
				return nil, err
			}
			xprv = x
		}
		signWithXprv[c.Xpub] = xprv
	}

	scriptType := multisigTypeString(w.scriptKind())
	var receive string
	var err error
	if len(signWithXprv) > 0 {
		receive, _, err = BuildMultisigSigningDescriptorsTyped(group, signWithXprv, scriptType)
	} else {
		receive, _, err = BuildMultisigLoungeDescriptorsTyped(group, scriptType)
	}
	if err != nil {
		return nil, err
	}
	return ParseDescriptor(receive)
}

// cosignerXprv derives the account xprv of a cosigner held as a mnemonic. It
// must be the key the stored xpub names.
func cosignerXprv(c MultisigCosigner, net *chaincfg.Params) (string, error) {
	stored, err := parseKeyExpr(c.Xpub)
	if err != nil {
		return "", fmt.Errorf("cosigner xpub: %w", err)
	}
	seedHex := hex.EncodeToString(MnemonicToSeed(c.Mnemonic, c.Passphrase))
	key, err := deriveMultisigAccountKey(seedHex, "m/"+c.OriginPath, net)
	if err != nil {
		return "", fmt.Errorf("derive cosigner xprv: %w", err)
	}
	if !sameAccountKey(key, stored.Account) {
		return "", fmt.Errorf("the seed of cosigner %s does not derive its stored key", shortXpub(c.Xpub))
	}
	return key.String(), nil
}

// sameAccountKey reports whether two extended keys hold the same public key
// and chain code.
func sameAccountKey(a, b *hdkeychain.ExtendedKey) bool {
	pubA, errA := a.ECPubKey()
	pubB, errB := b.ECPubKey()
	if errA != nil || errB != nil {
		return false
	}
	return bytes.Equal(pubA.SerializeCompressed(), pubB.SerializeCompressed()) && bytes.Equal(a.ChainCode(), b.ChainCode())
}

// watchOnlyDescriptorString returns the descriptor (or bare xpub) stored in a
// watch-only wallet's payload, for ParseDescriptor.
func watchOnlyDescriptorString(w *WalletData) (string, error) {
	var stored struct {
		Xpub       string `json:"xpub"`
		Descriptor string `json:"descriptor"`
	}
	if len(w.WatchOnly) > 0 {
		if err := json.Unmarshal(w.WatchOnly, &stored); err != nil {
			return "", fmt.Errorf("parse watch-only data: %w", err)
		}
	}
	if stored.Descriptor != "" {
		return stored.Descriptor, nil
	}
	if stored.Xpub != "" {
		return stored.Xpub, nil
	}
	return "", errors.New("watch-only wallet has no descriptor or xpub")
}
