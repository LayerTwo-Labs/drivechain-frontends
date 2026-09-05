package freebank

// WalletInfo is the subset of Core's getwalletinfo reply FreeBank exposes,
// amounts in BTC. FreeBank predates getbalances, so this split carries the
// trusted / unconfirmed / immature amounts.
type WalletInfo struct {
	Balance            float64 `json:"balance"`
	UnconfirmedBalance float64 `json:"unconfirmed_balance"`
	ImmatureBalance    float64 `json:"immature_balance"`
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
