// Package zside provides a JSON-RPC client for the Zside sidechain.
package zside

// BalanceResponse is the reply from the "balance" RPC. ZSide splits the wallet
// into a shielded and a transparent pool.
type BalanceResponse struct {
	TotalShieldedSats        int64 `json:"total_shielded_sats"`
	TotalTransparentSats     int64 `json:"total_transparent_sats"`
	AvailableShieldedSats    int64 `json:"available_shielded_sats"`
	AvailableTransparentSats int64 `json:"available_transparent_sats"`
}

// TotalSats is the total balance across both pools.
func (b BalanceResponse) TotalSats() int64 {
	return b.TotalShieldedSats + b.TotalTransparentSats
}

// AvailableSats is the available balance across both pools.
func (b BalanceResponse) AvailableSats() int64 {
	return b.AvailableShieldedSats + b.AvailableTransparentSats
}

// PeerInfo describes a connected peer.
type PeerInfo struct {
	Address string `json:"address"`
	Status  string `json:"status"`
}

// BmmResult is the response from the "mine" RPC.
type BmmResult struct {
	HashLastMainBlock      string  `json:"hash_last_main_block"`
	BmmBlockCreated        *string `json:"bmm_block_created,omitempty"`
	BmmBlockSubmitted      *string `json:"bmm_block_submitted,omitempty"`
	BmmBlockSubmittedBlind *string `json:"bmm_block_submitted_blind,omitempty"`
	Ntxn                   int     `json:"ntxn"`
	Nfees                  int     `json:"nfees"`
	Txid                   string  `json:"txid"`
	Error                  *string `json:"error,omitempty"`
}
