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

// cookieMissingReasons are the stat texts for a file that is not there, one
// per platform. The failure arrives as a string inside an RPC message, so the
// error value os.IsNotExist would read is already gone by this point.
var cookieMissingReasons = []string{
	"no such file or directory",
	"The system cannot find the file specified",
	"The system cannot find the path specified",
}

// cookieMessage reads back to the user in place of the raw stat failure.
const cookieMessage = "Starting Bitcoin Core"

// cookiePathMarkers name an auth cookie inside an error. The wrapper text
// carries the first one whatever the file is called, because rpccookiefile
// renames it; the second catches a bare stat of the default name.
var cookiePathMarkers = []string{
	"read rpc cookie ",
	".cookie",
}

// isMissingCookie reports whether an RPC failed because Core has no auth
// cookie on disk. Core deletes the cookie when it stops and writes a fresh one
// a moment after it starts, so the whole restart window fails on this.
func isMissingCookie(errMsg string) bool {
	named := false
	for _, marker := range cookiePathMarkers {
		if strings.Contains(errMsg, marker) {
			named = true
			break
		}
	}
	if !named {
		return false
	}
	for _, reason := range cookieMissingReasons {
		if strings.Contains(errMsg, reason) {
			return true
		}
	}
	return false
}

// IsBitcoinCoreStartupError reports whether the error originated from Bitcoin
// Core being mid-startup (block index load, verify, rescan, wallet load).
// Callers use this to back off instead of treating the failure as terminal.
func IsBitcoinCoreStartupError(errMsg string) bool {
	if isMissingCookie(errMsg) {
		return true
	}
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

	if isMissingCookie(errMsg) {
		return cookieMessage
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
