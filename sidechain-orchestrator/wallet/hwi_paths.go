package wallet

import (
	"bytes"
	"context"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"strings"

	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/btcsuite/btcd/btcutil/psbt"
)

const hardenedKey uint32 = 0x80000000

// checkDeviceCanSignPaths rejects a packet a hardware device refuses. Trezor
// firmware accepts only BIP45 and BIP48 paths for a multisig input, and it
// reports every other path as a forbidden key path. The device names neither the
// input nor the path, so this check names both before the device sees them.
func checkDeviceCanSignPaths(packet *psbt.Packet, fingerprint string) error {
	want, ok := parseFingerprint(fingerprint)
	if !ok {
		return nil
	}
	for i := range packet.Inputs {
		in := &packet.Inputs[i]
		if len(in.WitnessScript) == 0 {
			continue
		}
		for _, d := range in.Bip32Derivation {
			if d.MasterKeyFingerprint != want {
				continue
			}
			if multisigPathIsStandard(d.Bip32Path) {
				continue
			}
			return fmt.Errorf(
				"the device holds key %s at %s in psbt input %d, and a hardware signer signs a multisig input only at m/48'/coin'/account'/2'/change/index or m/45'/…; re-import this cosigner with its key origin",
				fingerprint, pathString(d.Bip32Path), i)
		}
	}
	return nil
}

// multisigPathIsStandard reports whether a path is one a hardware signer accepts
// for a multisig input: BIP48 (…/48'/coin'/account'/script'/change/index) or
// BIP45 (…/45'/cosigner/change/index).
func multisigPathIsStandard(path []uint32) bool {
	hard := func(n uint32) bool { return n >= hardenedKey }
	switch len(path) {
	case 6:
		return path[0] == 48|hardenedKey && hard(path[1]) && hard(path[2]) && hard(path[3]) &&
			!hard(path[4]) && !hard(path[5])
	case 4:
		return path[0] == 45|hardenedKey && !hard(path[1]) && !hard(path[2]) && !hard(path[3])
	default:
		return false
	}
}

// pathString writes a derivation path the way a descriptor does.
func pathString(path []uint32) string {
	if len(path) == 0 {
		return "m (no path)"
	}
	parts := make([]string, 0, len(path)+1)
	parts = append(parts, "m")
	for _, n := range path {
		if n >= hardenedKey {
			parts = append(parts, fmt.Sprintf("%d'", n-hardenedKey))
			continue
		}
		parts = append(parts, fmt.Sprintf("%d", n))
	}
	return strings.Join(parts, "/")
}

// parseFingerprint reads a master key fingerprint written as 8 hex characters.
func parseFingerprint(s string) (uint32, bool) {
	raw, err := hex.DecodeString(strings.TrimSpace(s))
	if err != nil || len(raw) != 4 {
		return 0, false
	}
	return binary.LittleEndian.Uint32(raw), true
}

// checkDeviceHoldsWalletKeys makes sure the device carries the keys this packet
// files under its fingerprint. A signer returns a signature for the key it
// derives, and the caller files that signature under the key the packet names.
// A device whose seed or passphrase differs gives a valid signature for a key
// this wallet does not hold, and only a check of the keys names that cause.
func (r *HWIRunner) checkDeviceHoldsWalletKeys(
	ctx context.Context,
	sel HardwareSelector,
	packet *psbt.Packet,
) error {
	want, ok := parseFingerprint(sel.Fingerprint)
	if !ok {
		return nil
	}
	for _, x := range packet.XPubs {
		if x.MasterKeyFingerprint != want || len(x.ExtendedKey) < 78 {
			continue
		}
		path := pathString(x.Bip32Path)
		got, err := r.GetXpub(ctx, sel, path)
		if err != nil {
			return fmt.Errorf("read the device key at %s: %w", path, err)
		}
		raw := base58.Decode(got)
		if len(raw) < 82 {
			return fmt.Errorf("the device gave a key at %s this wallet cannot read", path)
		}
		if bytes.Equal(raw[13:78], x.ExtendedKey[13:78]) {
			continue
		}
		if real, ok := r.findKeyOnDevice(ctx, sel, x.Bip32Path, x.ExtendedKey); ok {
			return fmt.Errorf(
				"this wallet records cosigner %s at %s, but the device holds that key at %s; the wallet stored the wrong path when it imported the key, so correct the cosigner origin to %s and the device signs the same script",
				sel.Fingerprint, path, real, real)
		}
		return fmt.Errorf(
			"the device holds a different key at %s than wallet fingerprint %s names, and no nearby account holds it either; the device seed or passphrase does not match the key this wallet stored",
			path, sel.Fingerprint)
	}
	return nil
}

// findKeyOnDevice names the path a stored key really lives at. A wallet that
// imports a cosigner at one path and records another gives a signer a key it
// cannot derive, and the script stays correct, so the path alone needs a fix.
// The search stays near the recorded path: the account and the script type.
func (r *HWIRunner) findKeyOnDevice(
	ctx context.Context,
	sel HardwareSelector,
	recorded []uint32,
	want []byte,
) (string, bool) {
	if len(recorded) != 4 || len(want) < 78 {
		return "", false
	}
	for account := uint32(0); account < 6; account++ {
		for kind := uint32(0); kind < 4; kind++ {
			try := []uint32{recorded[0], recorded[1], account | hardenedKey, kind | hardenedKey}
			if try[2] == recorded[2] && try[3] == recorded[3] {
				continue
			}
			path := pathString(try)
			got, err := r.GetXpub(ctx, sel, path)
			if err != nil {
				continue
			}
			raw := base58.Decode(got)
			if len(raw) >= 78 && bytes.Equal(raw[13:78], want[13:78]) {
				return path, true
			}
		}
	}
	return "", false
}
