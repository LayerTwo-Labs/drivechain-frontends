package orchestrator

import (
	"os"
)

// CoreVariantInstalled reports whether the variant's binary exists on disk.
func CoreVariantInstalled(dataDir string, v CoreVariantSpec, binaryName string) bool {
	_, err := os.Stat(CoreBinaryPath(dataDir, v, binaryName))
	return err == nil
}

// preferenceLess orders Bitcoin Core variants by fallback priority, used
// when the user's persisted CoreVariant isn't available on the current
// network. Knots is always last; everything else falls back to
// alphabetical so adding new variants doesn't surprise the operator.
//
// Fix for the silent-knots-default regression: the previous comparator
// was a plain alphabetical sort, which on signet ranked "knots" before
// "untouched" / "patched" and ended up downloading bitcoinknots.org
// any time the persisted variant was forknet-only. Knots is a niche
// fork that should never be picked by accident.
func preferenceLess(a, b string) bool {
	return variantPreference(a) < variantPreference(b)
}

// variantPreference assigns each variant a sort key. Lower wins. Patched is
// the safest fallback in the drivechain ecosystem (works on every chain,
// drivechain-aware), Core is next, Knots last (niche fork). Unknown
// variants sort between core and knots so they're at least visible.
func variantPreference(id string) int {
	switch id {
	case "patched":
		return 0
	case "core":
		return 1
	case "knots":
		return 3
	default:
		return 2
	}
}

// FilterVariantsForNetwork returns variants available for the given network.
// "patched" is available on every chain — including mainnet — so the
// dropdown always has at least one item the user can pick.
func FilterVariantsForNetwork(variants map[string]CoreVariantSpec, network string) []CoreVariantSpec {
	out := make([]CoreVariantSpec, 0, len(variants))
	for _, v := range variants {
		if v.AvailableOn(network) {
			out = append(out, v)
		}
	}
	return out
}

// ActiveCoreBinaryPath returns the on-disk path for the bitcoind variant
// currently selected in orchestrator_settings.json. Used by CLI commands and
// the testharness to find the active build without constructing a full
// Orchestrator. Non-bitcoind names always resolve via the legacy flat layout.
func ActiveCoreBinaryPath(dataDir, bitwindowDir string, configs []BinaryConfig, binaryName string) string {
	if binaryName != "bitcoind" {
		return BinaryPath(dataDir, binaryName)
	}
	variantID := DefaultCoreVariantID
	if bitwindowDir != "" {
		if s, err := LoadSettings(bitwindowDir); err == nil && s.CoreVariant != "" {
			variantID = s.CoreVariant
		}
	}
	for _, c := range configs {
		if !c.IsBitcoinCore {
			continue
		}
		if v, ok := c.Variants[variantID]; ok {
			return CoreBinaryPath(dataDir, v, binaryName)
		}
	}
	return BinaryPath(dataDir, binaryName)
}
