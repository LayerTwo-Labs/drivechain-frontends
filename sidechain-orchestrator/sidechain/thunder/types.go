// Package thunder provides a JSON-RPC client for the Thunder sidechain.
package thunder

// BalanceResponse is the reply from the "balance" RPC.
type BalanceResponse struct {
	TotalSats     int64 `json:"total_sats"`
	AvailableSats int64 `json:"available_sats"`
}

// PeerInfo describes a connected peer.
type PeerInfo struct {
	Address string `json:"address"`
	Status  string `json:"status"`
}
