package engines

import "strings"

// bitcoindStartupPatterns are substrings that mean "bitcoind is still booting,
// not actually broken". -28 is the JSON-RPC code Core returns from any RPC
// while it's not yet ready (Loading block index, Verifying blocks, Rescanning,
// etc). The wallet errors -4 (already loading) and -18 (not loaded) show up
// during the same window once the wallet starts being touched.
var bitcoindStartupPatterns = []string{
	"-28:",
	"-28 -",
	"-4: Wallet already loading",
	"Loading block index",
	"Verifying blocks",
	"Loading wallet",
	"Wallet loading",
	"Wallet already loading",
	"Rescanning",
	"Still rescanning",
	"Loading P2P addresses",
	"Loading banlist",
	"Replaying blocks",
}

// IsBitcoinCoreStartupError reports whether the error originated from Bitcoin
// Core being mid-startup (block index load, verify, rescan, wallet load).
// Callers use this to back off instead of treating the failure as terminal.
func IsBitcoinCoreStartupError(errMsg string) bool {
	for _, p := range bitcoindStartupPatterns {
		if strings.Contains(errMsg, p) {
			return true
		}
	}
	return false
}

// ExtractBitcoindStartupMessage returns a human-readable message from a -28
// JSON-RPC error (e.g. "Verifying blocks…"), or "" if the error isn't a
// recognised startup error. Used to surface the actual phase to the UI
// instead of "0 / 0 blocks".
func ExtractBitcoindStartupMessage(errMsg string) string {
	if errMsg == "" {
		return ""
	}
	if !IsBitcoinCoreStartupError(errMsg) {
		return ""
	}

	// Common shapes:
	//   "internal: -28: Verifying blocks…"
	//   "getblockcount([]): -28 - Loading block index…"
	//   "loadwallet RPC error -4: Wallet already loading."
	for _, sep := range []string{"-28:", "-28 -", "-4:", "-18:"} {
		if idx := strings.Index(errMsg, sep); idx >= 0 {
			return strings.TrimSpace(errMsg[idx+len(sep):])
		}
	}

	for _, p := range bitcoindStartupPatterns {
		if idx := strings.Index(errMsg, p); idx >= 0 {
			return strings.TrimSpace(errMsg[idx:])
		}
	}
	return strings.TrimSpace(errMsg)
}
