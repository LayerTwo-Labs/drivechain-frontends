package bbc

// Balances is Core's getbalances reply, amounts in BTC.
type Balances struct {
	Mine struct {
		Trusted          float64 `json:"trusted"`
		UntrustedPending float64 `json:"untrusted_pending"`
		Immature         float64 `json:"immature"`
	} `json:"mine"`
}

// Unspent is one wallet UTXO from listunspent, amount in BTC.
type Unspent struct {
	Txid          string  `json:"txid"`
	Vout          int64   `json:"vout"`
	Address       string  `json:"address"`
	Amount        float64 `json:"amount"`
	Confirmations int64   `json:"confirmations"`
}

// WalletTransaction is one entry from listtransactions, amount in BTC.
type WalletTransaction struct {
	Txid          string  `json:"txid"`
	Amount        float64 `json:"amount"`
	Confirmations int64   `json:"confirmations"`
	Time          int64   `json:"time"`
	Address       string  `json:"address"`
	Category      string  `json:"category"`
}

// SidechainInfo is the node's view of its link to the mainchain.
type SidechainInfo struct {
	Synced       bool   `json:"synced"`
	MainchainTip string `json:"mainchaintip"`
	LastError    string `json:"lasterror"`
}
