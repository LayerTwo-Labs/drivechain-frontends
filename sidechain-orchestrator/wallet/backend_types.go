package wallet

// Shared types crossing the Backend interface. Field semantics follow
// Bitcoin Core's wallet RPC conventions and every backend must honor them:
// amounts are BTC floats, send amounts and fees are negative.

// UTXO is one unspent wallet output (listunspent shape). ReceivedAt is the
// unix time the wallet first saw or confirmed the output when the backend
// knows it directly; 0 means callers resolve it via GetWalletTransaction.
type UTXO struct {
	TxID          string  `json:"txid"`
	Vout          int     `json:"vout"`
	Address       string  `json:"address"`
	Label         string  `json:"label"`
	Amount        float64 `json:"amount"`
	Confirmations int     `json:"confirmations"`
	Spendable     bool    `json:"spendable"`
	Solvable      bool    `json:"solvable"`
	ReceivedAt    int64   `json:"-"`
}

// WalletTransaction is one listtransactions entry: one row per affected
// wallet address per direction. Category is "send" or "receive" ("generate"
// / "immature" for coinbase). Amount is negative for sends; Fee is set on
// send entries only, as a negative BTC value.
type WalletTransaction struct {
	Address       string  `json:"address"`
	Category      string  `json:"category"`
	Amount        float64 `json:"amount"`
	Vout          int     `json:"vout"`
	Fee           float64 `json:"fee"`
	Confirmations int     `json:"confirmations"`
	BlockTime     int64   `json:"blocktime"`
	Time          int64   `json:"time"`
	TxID          string  `json:"txid"`
	Label         string  `json:"label"`
}

// ReceivedByAddress aggregates what one wallet address has received,
// including zero-amount entries for known-but-unused addresses (minconf 0,
// so mempool receives count).
type ReceivedByAddress struct {
	Address       string   `json:"address"`
	Amount        float64  `json:"amount"`
	Confirmations int      `json:"confirmations"`
	Label         string   `json:"label"`
	TxIDs         []string `json:"txids"`
}

// WalletTx is the wallet's view of one of its own transactions
// (gettransaction shape). TimeReceived is when this wallet first saw the
// tx; 0 when unknown (e.g. a freshly restored wallet).
type WalletTx struct {
	TxID          string  `json:"txid"`
	Amount        float64 `json:"amount"`
	Fee           float64 `json:"fee"`
	Confirmations int32   `json:"confirmations"`
	BlockTime     int64   `json:"blocktime"`
	Time          int64   `json:"time"`
	TimeReceived  int64   `json:"timereceived"`
	Hex           string  `json:"hex"`
}

// RawTransaction is a fully decoded transaction with chain context
// (verbose getrawtransaction shape). Confirmations is 0 for mempool txs.
type RawTransaction struct {
	TxID          string     `json:"txid"`
	Hash          string     `json:"hash"`
	Hex           string     `json:"hex"`
	Size          int32      `json:"size"`
	Vsize         int32      `json:"vsize"`
	Weight        int32      `json:"weight"`
	Version       int32      `json:"version"`
	Locktime      int32      `json:"locktime"`
	Blockhash     string     `json:"blockhash,omitempty"`
	Confirmations int32      `json:"confirmations"`
	BlockTime     int64      `json:"blocktime,omitempty"`
	Time          int64      `json:"time,omitempty"`
	Vin           []RawTxIn  `json:"vin"`
	Vout          []RawTxOut `json:"vout"`
}

// RawTxIn is one input of a decoded transaction. Coinbase is set (and TxID
// empty) for coinbase inputs.
type RawTxIn struct {
	TxID      string     `json:"txid,omitempty"`
	Vout      int        `json:"vout,omitempty"`
	Coinbase  string     `json:"coinbase,omitempty"`
	ScriptSig *ScriptSig `json:"scriptSig,omitempty"`
	Witness   []string   `json:"txinwitness,omitempty"`
	Sequence  int64      `json:"sequence"`
}

// ScriptSig is a decoded input script.
type ScriptSig struct {
	Asm string `json:"asm"`
	Hex string `json:"hex"`
}

// RawTxOut is one output of a decoded transaction.
type RawTxOut struct {
	Value        float64      `json:"value"`
	N            int          `json:"n"`
	ScriptPubKey ScriptPubKey `json:"scriptPubKey"`
}

// ScriptPubKey is a decoded output script. Address is empty for
// non-standard and OP_RETURN ("nulldata") outputs.
type ScriptPubKey struct {
	Asm     string `json:"asm"`
	Hex     string `json:"hex"`
	Type    string `json:"type"`
	Address string `json:"address,omitempty"`
}

// RawInput identifies an outpoint to spend in a transaction under
// construction.
type RawInput struct {
	TxID string `json:"txid"`
	Vout int    `json:"vout"`
}

// FundRawTransactionResult is the funded tx. ChangePos is -1 when no
// change output was added.
type FundRawTransactionResult struct {
	Hex       string  `json:"hex"`
	Fee       float64 `json:"fee"`
	ChangePos int     `json:"changepos"`
}

// SignRawTransactionResult is the signed tx. Complete is true only when
// every input carries a valid signature.
type SignRawTransactionResult struct {
	Hex      string `json:"hex"`
	Complete bool   `json:"complete"`
}

// SendRequest is everything a backend needs to pay destinations: amounts,
// fee control (rate or fixed), an optional OP_RETURN payload, pinned inputs,
// and replay protection. Backends reject fields they cannot honor.
type SendRequest struct {
	DestinationsSats      map[string]int64
	FeeRateSatPerVB       int64 // 0 = backend's own fee estimation
	FixedFeeSats          int64 // mutually exclusive with FeeRateSatPerVB
	OpReturnHex           string
	RequiredInputs        []RequiredInput
	SubtractFeeFromAmount bool
	ReplayProtect         bool
}

// RequiredInput pins one outpoint that the transaction must spend.
type RequiredInput struct {
	TxID       string
	Vout       int
	AmountSats int64
}

// WatchKey is one private key whose address the backend must track.
type WatchKey struct {
	WIF        string // compressed-pubkey WIF private key
	RescanFrom int64  // unix time to scan from; 0 = genesis
}
