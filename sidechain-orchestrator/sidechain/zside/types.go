// Package zside provides a JSON-RPC client for the Zside sidechain.
package zside

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
