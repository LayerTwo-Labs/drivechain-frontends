// Package photon provides a JSON-RPC client for the Photon sidechain.
package photon

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

// BmmResult is the response from the "mine" RPC.
type BmmResult struct {
	HashLastMainBlock     string  `json:"hash_last_main_block"`
	BmmBlockCreated       *string `json:"bmm_block_created,omitempty"`
	BmmBlockSubmitted     *string `json:"bmm_block_submitted,omitempty"`
	BmmBlockSubmittedBlind *string `json:"bmm_block_submitted_blind,omitempty"`
	Ntxn                  int     `json:"ntxn"`
	Nfees                 int     `json:"nfees"`
	Txid                  string  `json:"txid"`
	Error                 *string `json:"error,omitempty"`
}