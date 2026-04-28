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
	"Verifying blocks",
	"Loading block index",
	"Loading wallet",
	"Rescanning",
	"Still rescanning",
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
