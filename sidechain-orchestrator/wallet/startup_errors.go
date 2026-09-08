package wallet

import "strings"

// transientWalletErrPatterns are substrings in bitcoind RPC error messages
// that mean the wallet RPC isn't usable yet but should be again soon —
// typically because Core is still loading the chainstate or already loading
// the wallet from a previous attempt. Callers should back off rather than
// retry immediately, otherwise we hammer bitcoind and exhaust the HTTP/2
// stream limit.
var transientWalletErrPatterns = []string{
	"-28:",
	"-28 -",
	"-4: Wallet already loading",
	"Wallet already loading",
	// Core lists a wallet before it finishes loading it, so a wallet RPC in
	// that window answers -18 for a wallet that is on its way up.
	"-18:",
	"does not exist or is not loaded",
	"Verifying blocks",
	"Loading block index",
	"Loading wallet",
	"Rescanning",
	"Still rescanning",
	// Core writes this one in lower case: "Wallet is currently rescanning.
	// Abort existing rescan or wait." The patterns match case, so it takes
	// its own entry.
	"currently rescanning",
}

// IsTransientWalletErr reports whether a wallet-related bitcoind error means
// "still booting, retry shortly" (e.g. -4 Wallet already loading, -28
// Verifying blocks). Exposed so the gRPC handler can downgrade the response
// code from Internal to Unavailable.
func IsTransientWalletErr(err error) bool {
	return isTransientWalletErr(err)
}

func isTransientWalletErr(err error) bool {
	if err == nil {
		return false
	}
	msg := err.Error()
	for _, p := range transientWalletErrPatterns {
		if strings.Contains(msg, p) {
			return true
		}
	}
	return false
}

// walletNotLoadedPatterns are the substrings Core answers when it does not hold
// the wallet at all. A wallet that is loaded but busy — a rescan, for one — is a
// different thing, and it stays usable.
var walletNotLoadedPatterns = []string{
	"-18:",
	"does not exist or is not loaded",
}

// isWalletNotLoadedErr reports whether Core says it does not hold this wallet.
// Narrower than isTransientWalletErr on purpose: a rescanning wallet is
// transient and loaded, so it keeps serving.
func isWalletNotLoadedErr(err error) bool {
	if err == nil {
		return false
	}
	msg := err.Error()
	for _, p := range walletNotLoadedPatterns {
		if strings.Contains(msg, p) {
			return true
		}
	}
	return false
}

// isWalletAlreadyLoadedErr reports whether Core refused a load because it
// already holds the wallet. That is the same outcome as a load that worked.
func isWalletAlreadyLoadedErr(err error) bool {
	return err != nil && strings.Contains(err.Error(), "already loaded")
}
