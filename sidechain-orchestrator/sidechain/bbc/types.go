package bbc

// SidechainInfo is the node's view of its link to the mainchain.
type SidechainInfo struct {
	Synced       bool   `json:"synced"`
	MainchainTip string `json:"mainchaintip"`
	LastError    string `json:"lasterror"`
}
