package wallet

import "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"

// ReplayProtect reports whether a send gets the magic nLockTime. Only a patched
// eCash node reads that locktime as final, so no other network stamps it. A
// caller that wants the transaction on both chains sets allowReplay.
func ReplayProtect(network string, allowReplay bool) bool {
	return config.NetworkFromString(network) == config.NetworkECash && !allowReplay
}
