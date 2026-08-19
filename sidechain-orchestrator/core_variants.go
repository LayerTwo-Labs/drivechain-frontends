package orchestrator

import (
	"os"
	"sort"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
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
// any time the persisted variant was forknet- or drynet-only. Knots is a niche
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

// ResolveCoreVariant returns the Core variant a network boots: the requested
// one when the network offers it, otherwise the preferred variant that network
// does offer. Every consumer of a Core path goes through here, so the launcher,
// the status check and the CLI never disagree about which build is active.
func ResolveCoreVariant(c BinaryConfig, requestedID, network string) (CoreVariantSpec, bool) {
	if !c.IsMainchainCore() {
		return CoreVariantSpec{}, false
	}
	if v, ok := c.Variants[requestedID]; ok && v.AvailableOn(network) {
		return v, true
	}
	available := FilterVariantsForNetwork(c.Variants, network)
	if len(available) == 0 {
		return CoreVariantSpec{}, false
	}
	sort.Slice(available, func(i, j int) bool {
		return preferenceLess(available[i].ID, available[j].ID)
	})
	return available[0], true
}

// ActiveCoreBinaryPath returns the on-disk path for the bitcoind variant the
// given network boots. Used by CLI commands and the testharness to find the
// active build without constructing a full Orchestrator. Non-bitcoind names
// always resolve via the legacy flat layout.
//
// drynetID is the drynet generation to resolve. Read it from the running
// daemon, not from the catalog cache: the confirm writes a new generation to
// the cache before the restart that starts to use it.
func ActiveCoreBinaryPath(dataDir, bitwindowDir string, configs []BinaryConfig, binaryName, network, drynetID string) string {
	if binaryName != "bitcoind" {
		return BinaryPath(dataDir, binaryName)
	}
	if drynetID == "" {
		// An empty id keeps the placeholder, and the path becomes bin/{drynet}.
		drynetID = netcatalog.EmbeddedDrynetID()
	}
	variantID := DefaultCoreVariantID
	if bitwindowDir != "" {
		if s, err := LoadSettings(bitwindowDir); err == nil && s.CoreVariant != "" {
			variantID = s.CoreVariant
		}
	}
	for _, c := range configs {
		if !c.IsMainchainCore() {
			continue
		}
		expanded := expandDrynetPlaceholder(c, drynetID)
		if v, ok := ResolveCoreVariant(expanded, variantID, network); ok {
			return CoreBinaryPath(dataDir, v, binaryName)
		}
	}
	return BinaryPath(dataDir, binaryName)
}
