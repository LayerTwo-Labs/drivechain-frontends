package orchestrator

import (
	"os"
)

// CoreVariantInstalled reports whether the variant's binary exists on disk.
func CoreVariantInstalled(dataDir string, v CoreVariantSpec, binaryName string) bool {
	_, err := os.Stat(CoreBinaryPath(dataDir, v, binaryName))
	return err == nil
}

// FilterVariantsForNetwork returns variants available for the given network.
// Mainnet always returns nil so the UI hides itself.
func FilterVariantsForNetwork(variants map[string]CoreVariantSpec, network string) []CoreVariantSpec {
	if network == "mainnet" {
		return nil
	}
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
