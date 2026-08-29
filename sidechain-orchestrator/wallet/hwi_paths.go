package wallet

import (
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"strings"

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
