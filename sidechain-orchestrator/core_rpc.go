package orchestrator

// Extended Bitcoin Core JSON-RPC methods for wallet operations.
// Ported from bitwindow/server — uses raw JSON-RPC instead of btc-buf Connect.

import (
	"context"
	"encoding/json"
	"fmt"
)

// --- Balance ---

type CoreBalances struct {
	Mine struct {
		Trusted          float64 `json:"trusted"`
		UntrustedPending float64 `json:"untrusted_pending"`
		Immature         float64 `json:"immature"`
	} `json:"mine"`
	Watchonly *struct {
		Trusted          float64 `json:"trusted"`
		UntrustedPending float64 `json:"untrusted_pending"`
		Immature         float64 `json:"immature"`
	} `json:"watchonly,omitempty"`
}

func (c *CoreStatusClient) GetBalances(ctx context.Context, walletName string) (*CoreBalances, error) {
	result, err := c.callWallet(ctx, walletName, "getbalances")
	if err != nil {
		return nil, err
	}
	var balances CoreBalances
	if err := json.Unmarshal(result, &balances); err != nil {
		return nil, fmt.Errorf("decode getbalances: %w", err)
	}
	return &balances, nil
}

// --- Addresses ---

func (c *CoreStatusClient) GetNewAddress(ctx context.Context, walletName string) (string, error) {
	result, err := c.callWallet(ctx, walletName, "getnewaddress")
	if err != nil {
		return "", err
	}
	var address string
	if err := json.Unmarshal(result, &address); err != nil {
		return "", fmt.Errorf("decode getnewaddress: %w", err)
	}
	return address, nil
}

type AddressInfo struct {
	Address    string `json:"address"`
	IsMine     bool   `json:"ismine"`
	IsWatchOnly bool  `json:"iswatchonly"`
	IsScript   bool   `json:"isscript"`
	IsWitness  bool   `json:"iswitness"`
	HdKeyPath  string `json:"hdkeypath,omitempty"`
}

func (c *CoreStatusClient) GetAddressInfo(ctx context.Context, walletName, address string) (*AddressInfo, error) {
	result, err := c.callWallet(ctx, walletName, "getaddressinfo", address)
	if err != nil {
		return nil, err
	}
	var info AddressInfo
	if err := json.Unmarshal(result, &info); err != nil {
		return nil, fmt.Errorf("decode getaddressinfo: %w", err)
	}
	return &info, nil
}

// --- Transactions ---

type CoreTransaction struct {
	Txid          string  `json:"txid"`
	Amount        float64 `json:"amount"`
	Fee           float64 `json:"fee"`
	Confirmations int64   `json:"confirmations"`
	BlockHash     string  `json:"blockhash,omitempty"`
	BlockTime     int64   `json:"blocktime,omitempty"`
	Time          int64   `json:"time"`
	TimeReceived  int64   `json:"timereceived"`
	Category      string  `json:"category"` // send, receive, generate, immature, orphan
	Address       string  `json:"address,omitempty"`
	Label         string  `json:"label,omitempty"`
	Vout          uint32  `json:"vout"`
}

func (c *CoreStatusClient) ListTransactionsWallet(ctx context.Context, walletName string, count int) ([]CoreTransaction, error) {
	if count <= 0 {
		count = 100
	}
	result, err := c.callWallet(ctx, walletName, "listtransactions", "*", count, 0, true)
	if err != nil {
		return nil, err
	}
	var txs []CoreTransaction
	if err := json.Unmarshal(result, &txs); err != nil {
		return nil, fmt.Errorf("decode listtransactions: %w", err)
	}
	return txs, nil
}

type CoreTransactionDetail struct {
	Txid          string  `json:"txid"`
	Amount        float64 `json:"amount"`
	Fee           float64 `json:"fee"`
	Confirmations int64   `json:"confirmations"`
	BlockHash     string  `json:"blockhash,omitempty"`
	BlockTime     int64   `json:"blocktime,omitempty"`
	Time          int64   `json:"time"`
	TimeReceived  int64   `json:"timereceived"`
	Hex           string  `json:"hex"`
	Details       []struct {
		Address  string  `json:"address"`
		Category string  `json:"category"`
		Amount   float64 `json:"amount"`
		Vout     uint32  `json:"vout"`
		Fee      float64 `json:"fee,omitempty"`
	} `json:"details"`
}

func (c *CoreStatusClient) GetTransaction(ctx context.Context, walletName, txid string) (*CoreTransactionDetail, error) {
	result, err := c.callWallet(ctx, walletName, "gettransaction", txid, true)
	if err != nil {
		return nil, err
	}
	var tx CoreTransactionDetail
	if err := json.Unmarshal(result, &tx); err != nil {
		return nil, fmt.Errorf("decode gettransaction: %w", err)
	}
	return &tx, nil
}

// --- UTXOs ---

type CoreUnspent struct {
	Txid          string  `json:"txid"`
	Vout          uint32  `json:"vout"`
	Address       string  `json:"address"`
	Amount        float64 `json:"amount"`
	Confirmations int64   `json:"confirmations"`
	ScriptPubKey  string  `json:"scriptPubKey"`
	Spendable     bool    `json:"spendable"`
	Solvable      bool    `json:"solvable"`
	Safe          bool    `json:"safe"`
}

func (c *CoreStatusClient) ListUnspentWallet(ctx context.Context, walletName string) ([]CoreUnspent, error) {
	result, err := c.callWallet(ctx, walletName, "listunspent", 0)
	if err != nil {
		return nil, err
	}
	var utxos []CoreUnspent
	if err := json.Unmarshal(result, &utxos); err != nil {
		return nil, fmt.Errorf("decode listunspent: %w", err)
	}
	return utxos, nil
}

func (c *CoreStatusClient) ListUnspentForAddresses(ctx context.Context, walletName string, minConf int, addresses []string) ([]CoreUnspent, error) {
	if minConf < 0 {
		minConf = 0
	}
	result, err := c.callWallet(ctx, walletName, "listunspent", minConf, 9999999, addresses)
	if err != nil {
		return nil, err
	}
	var utxos []CoreUnspent
	if err := json.Unmarshal(result, &utxos); err != nil {
		return nil, fmt.Errorf("decode listunspent: %w", err)
	}
	return utxos, nil
}

// --- Send ---

// SendToAddress sends BTC from the given wallet. Returns txid.
func (c *CoreStatusClient) SendToAddress(ctx context.Context, walletName, address string, amountBTC float64) (string, error) {
	result, err := c.callWallet(ctx, walletName, "sendtoaddress", address, amountBTC)
	if err != nil {
		return "", err
	}
	var txid string
	if err := json.Unmarshal(result, &txid); err != nil {
		return "", fmt.Errorf("decode sendtoaddress: %w", err)
	}
	return txid, nil
}

// Send uses the "send" RPC (Core 22+) with multiple destinations.
func (c *CoreStatusClient) Send(ctx context.Context, walletName string, destinations map[string]float64, feeRate float64) (string, error) {
	args := []interface{}{destinations}
	// conf_target (null), estimate_mode (null), fee_rate
	if feeRate > 0 {
		args = append(args, nil, nil, feeRate)
	}
	result, err := c.callWallet(ctx, walletName, "send", args...)
	if err != nil {
		return "", err
	}
	var resp struct {
		Txid     string `json:"txid"`
		Complete bool   `json:"complete"`
	}
	if err := json.Unmarshal(result, &resp); err != nil {
		return "", fmt.Errorf("decode send: %w", err)
	}
	if !resp.Complete {
		return "", fmt.Errorf("send transaction incomplete")
	}
	return resp.Txid, nil
}

// --- Raw transactions ---

func (c *CoreStatusClient) CreateRawTransaction(ctx context.Context, inputs []map[string]interface{}, outputs []map[string]interface{}) (string, error) {
	result, err := c.call(ctx, "createrawtransaction", inputs, outputs)
	if err != nil {
		return "", err
	}
	var hex string
	if err := json.Unmarshal(result, &hex); err != nil {
		return "", fmt.Errorf("decode createrawtransaction: %w", err)
	}
	return hex, nil
}

type SignRawResult struct {
	Hex      string `json:"hex"`
	Complete bool   `json:"complete"`
}

func (c *CoreStatusClient) SignRawTransactionWithWallet(ctx context.Context, walletName, hexString string) (*SignRawResult, error) {
	result, err := c.callWallet(ctx, walletName, "signrawtransactionwithwallet", hexString)
	if err != nil {
		return nil, err
	}
	var signResult SignRawResult
	if err := json.Unmarshal(result, &signResult); err != nil {
		return nil, fmt.Errorf("decode signrawtransactionwithwallet: %w", err)
	}
	return &signResult, nil
}

func (c *CoreStatusClient) SendRawTransaction(ctx context.Context, hexString string) (string, error) {
	result, err := c.call(ctx, "sendrawtransaction", hexString)
	if err != nil {
		return "", err
	}
	var txid string
	if err := json.Unmarshal(result, &txid); err != nil {
		return "", fmt.Errorf("decode sendrawtransaction: %w", err)
	}
	return txid, nil
}

// --- RBF ---

type BumpFeeResult struct {
	Txid        string  `json:"txid"`
	OriginalFee float64 `json:"origfee"`
	NewFee      float64 `json:"fee"`
	Errors      []string `json:"errors,omitempty"`
}

func (c *CoreStatusClient) BumpFee(ctx context.Context, walletName, txid string) (*BumpFeeResult, error) {
	result, err := c.callWallet(ctx, walletName, "bumpfee", txid)
	if err != nil {
		return nil, err
	}
	var bumpResult BumpFeeResult
	if err := json.Unmarshal(result, &bumpResult); err != nil {
		return nil, fmt.Errorf("decode bumpfee: %w", err)
	}
	return &bumpResult, nil
}

// --- Raw transaction decoding ---

type RawTransaction struct {
	Txid     string `json:"txid"`
	Hash     string `json:"hash"`
	Size     int64  `json:"size"`
	Vsize    int64  `json:"vsize"`
	Weight   int64  `json:"weight"`
	Version  int32  `json:"version"`
	Locktime uint32 `json:"locktime"`
	Vin      []struct {
		Txid      string   `json:"txid"`
		Vout      uint32   `json:"vout"`
		Coinbase  string   `json:"coinbase,omitempty"`
		ScriptSig *struct {
			Asm string `json:"asm"`
			Hex string `json:"hex"`
		} `json:"scriptSig,omitempty"`
		Witness  []string `json:"txinwitness,omitempty"`
		Sequence uint32   `json:"sequence"`
	} `json:"vin"`
	Vout []struct {
		Value        float64 `json:"value"`
		N            uint32  `json:"n"`
		ScriptPubKey struct {
			Asm     string `json:"asm"`
			Hex     string `json:"hex"`
			Type    string `json:"type"`
			Address string `json:"address,omitempty"`
		} `json:"scriptPubKey"`
	} `json:"vout"`
	Blockhash     string `json:"blockhash,omitempty"`
	Confirmations int64  `json:"confirmations"`
	BlockTime     int64  `json:"blocktime,omitempty"`
}

func (c *CoreStatusClient) GetRawTransaction(ctx context.Context, txid string, verbose bool) (*RawTransaction, error) {
	verbosity := 0
	if verbose {
		verbosity = 2 // with prevout info
	}
	result, err := c.call(ctx, "getrawtransaction", txid, verbosity)
	if err != nil {
		return nil, err
	}
	if !verbose {
		return nil, fmt.Errorf("non-verbose mode returns hex, use verbose=true")
	}
	var tx RawTransaction
	if err := json.Unmarshal(result, &tx); err != nil {
		return nil, fmt.Errorf("decode getrawtransaction: %w", err)
	}
	return &tx, nil
}

// --- Wallet info ---

type WalletInfo struct {
	WalletName string `json:"walletname"`
	Format     string `json:"format"`
	TxCount    int64  `json:"txcount"`
}

func (c *CoreStatusClient) GetWalletInfo(ctx context.Context, walletName string) (*WalletInfo, error) {
	result, err := c.callWallet(ctx, walletName, "getwalletinfo")
	if err != nil {
		return nil, err
	}
	var info WalletInfo
	if err := json.Unmarshal(result, &info); err != nil {
		return nil, fmt.Errorf("decode getwalletinfo: %w", err)
	}
	return &info, nil
}

// --- Descriptor listing ---

type ListDescriptorsResult struct {
	WalletName  string `json:"wallet_name"`
	Descriptors []struct {
		Desc   string `json:"desc"`
		Active bool   `json:"active"`
		Range  []int  `json:"range,omitempty"`
	} `json:"descriptors"`
}

func (c *CoreStatusClient) ListDescriptors(ctx context.Context, walletName string) (*ListDescriptorsResult, error) {
	result, err := c.callWallet(ctx, walletName, "listdescriptors")
	if err != nil {
		return nil, err
	}
	var desc ListDescriptorsResult
	if err := json.Unmarshal(result, &desc); err != nil {
		return nil, fmt.Errorf("decode listdescriptors: %w", err)
	}
	return &desc, nil
}

// --- Helpers ---

// callWallet calls a method on a specific wallet using the /wallet/<name> URL path.
func (c *CoreStatusClient) callWallet(ctx context.Context, walletName, method string, params ...interface{}) (json.RawMessage, error) {
	origURL := c.url
	c.url = fmt.Sprintf("%s/wallet/%s", origURL, walletName)
	defer func() { c.url = origURL }()

	if params == nil {
		params = []interface{}{}
	}
	return c.call(ctx, method, params...)
}
