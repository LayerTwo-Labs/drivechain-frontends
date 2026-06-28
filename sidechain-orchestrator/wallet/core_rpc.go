package wallet

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"runtime"
	"time"
)

// CoreRPCClient is a Bitcoin Core JSON-RPC client that supports wallet-specific endpoints.
type CoreRPCClient struct {
	baseURL  string
	user     string
	password string
	client   *http.Client
}

// NewCoreRPCClient creates a new Bitcoin Core RPC client.
func NewCoreRPCClient(host string, port int, user, password string) *CoreRPCClient {
	// Use longer timeout on Windows due to slower disk I/O in CI environments
	timeout := 30 * time.Second
	if runtime.GOOS == "windows" {
		timeout = 60 * time.Second
	}

	return &CoreRPCClient{
		baseURL:  fmt.Sprintf("http://%s:%d", host, port),
		user:     user,
		password: password,
		client:   &http.Client{Timeout: timeout},
	}
}

type rpcRequest struct {
	JSONRPC string        `json:"jsonrpc"`
	ID      string        `json:"id"`
	Method  string        `json:"method"`
	Params  []interface{} `json:"params"`
}

type rpcResponse struct {
	Result json.RawMessage `json:"result"`
	Error  *rpcError       `json:"error"`
}

type rpcError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

// call makes a JSON-RPC call to Bitcoin Core.
// If walletName is non-empty, routes to /wallet/<name>.
func (c *CoreRPCClient) call(ctx context.Context, walletName, method string, params ...interface{}) (json.RawMessage, error) {
	if params == nil {
		params = []interface{}{}
	}

	body, err := json.Marshal(rpcRequest{
		JSONRPC: "1.0",
		ID:      "orchestrator",
		Method:  method,
		Params:  params,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal %s request: %w", method, err)
	}

	url := c.baseURL
	if walletName != "" {
		url = fmt.Sprintf("%s/wallet/%s", c.baseURL, walletName)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("create %s request: %w", method, err)
	}
	req.Header.Set("Content-Type", "application/json")
	if c.user != "" {
		req.SetBasicAuth(c.user, c.password)
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("%s call: %w", method, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read %s response: %w", method, err)
	}

	var rpcResp rpcResponse
	if err := json.Unmarshal(respBody, &rpcResp); err != nil {
		return nil, fmt.Errorf("decode %s response (status %d): %w", method, resp.StatusCode, err)
	}

	if rpcResp.Error != nil {
		return nil, fmt.Errorf("%s RPC error %d: %s", method, rpcResp.Error.Code, rpcResp.Error.Message)
	}

	return rpcResp.Result, nil
}

// ============================================================================
// Wallet management RPCs
// ============================================================================

// CreateWallet creates a new Bitcoin Core wallet.
func (c *CoreRPCClient) CreateWallet(ctx context.Context, name string, disablePrivateKeys, blank bool) error {
	_, err := c.call(ctx, "", "createwallet", name, disablePrivateKeys, blank)
	return err
}

// LoadWallet loads an existing Bitcoin Core wallet.
func (c *CoreRPCClient) LoadWallet(ctx context.Context, name string) error {
	_, err := c.call(ctx, "", "loadwallet", name)
	return err
}

// ListWallets returns loaded wallet names.
func (c *CoreRPCClient) ListWallets(ctx context.Context) ([]string, error) {
	result, err := c.call(ctx, "", "listwallets")
	if err != nil {
		return nil, err
	}
	var wallets []string
	if err := json.Unmarshal(result, &wallets); err != nil {
		return nil, fmt.Errorf("decode listwallets: %w", err)
	}
	return wallets, nil
}

// ImportDescriptor represents a descriptor import request.
type ImportDescriptor struct {
	Desc   string `json:"desc"`
	Active bool   `json:"active"`
	// Timestamp accepts the string "now" or an int64 unix timestamp. Core's
	// importdescriptors rejects "0" as a string; pass int64(0) instead to
	// request a rescan from genesis.
	Timestamp any   `json:"timestamp"`
	Internal  bool  `json:"internal,omitempty"`
	Range     []int `json:"range,omitempty"`
}

// ImportDescriptorResult is the result of an importdescriptors call.
type ImportDescriptorResult struct {
	Success bool `json:"success"`
	Error   *struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error,omitempty"`
}

// ImportDescriptors imports descriptors into a Bitcoin Core wallet.
func (c *CoreRPCClient) ImportDescriptors(ctx context.Context, walletName string, descriptors []ImportDescriptor) ([]ImportDescriptorResult, error) {
	result, err := c.call(ctx, walletName, "importdescriptors", descriptors)
	if err != nil {
		return nil, err
	}
	var results []ImportDescriptorResult
	if err := json.Unmarshal(result, &results); err != nil {
		return nil, fmt.Errorf("decode importdescriptors: %w", err)
	}
	return results, nil
}

// ============================================================================
// Balance/Address/Transaction RPCs
// ============================================================================

// GetBalance returns the wallet balance.
func (c *CoreRPCClient) GetBalance(ctx context.Context, walletName string) (float64, error) {
	result, err := c.call(ctx, walletName, "getbalance")
	if err != nil {
		return 0, err
	}
	var balance float64
	if err := json.Unmarshal(result, &balance); err != nil {
		return 0, fmt.Errorf("decode getbalance: %w", err)
	}
	return balance, nil
}

// GetUnconfirmedBalance returns the unconfirmed balance.
// Falls back to getbalances RPC if the deprecated getunconfirmedbalance is
// not available (removed in Bitcoin Core v30+).
func (c *CoreRPCClient) GetUnconfirmedBalance(ctx context.Context, walletName string) (float64, error) {
	result, err := c.call(ctx, walletName, "getunconfirmedbalance")
	if err == nil {
		var balance float64
		if err := json.Unmarshal(result, &balance); err != nil {
			return 0, fmt.Errorf("decode getunconfirmedbalance: %w", err)
		}
		return balance, nil
	}

	// Fallback: use getbalances (available since Core v0.19).
	result, err = c.call(ctx, walletName, "getbalances")
	if err != nil {
		return 0, fmt.Errorf("getbalances fallback: %w", err)
	}
	var balances struct {
		Mine struct {
			UntrustedPending float64 `json:"untrusted_pending"`
		} `json:"mine"`
	}
	if err := json.Unmarshal(result, &balances); err != nil {
		return 0, fmt.Errorf("decode getbalances: %w", err)
	}
	return balances.Mine.UntrustedPending, nil
}

// GetNewAddress generates a new address.
func (c *CoreRPCClient) GetNewAddress(ctx context.Context, walletName, label, addressType string) (string, error) {
	params := []interface{}{label}
	if addressType != "" {
		params = append(params, addressType)
	}
	result, err := c.call(ctx, walletName, "getnewaddress", params...)
	if err != nil {
		return "", err
	}
	var address string
	if err := json.Unmarshal(result, &address); err != nil {
		return "", fmt.Errorf("decode getnewaddress: %w", err)
	}
	return address, nil
}

// SendToAddress sends bitcoin to an address.
func (c *CoreRPCClient) SendToAddress(ctx context.Context, walletName, address string, amount float64, subtractFee bool) (string, error) {
	// sendtoaddress "address" amount "comment" "comment_to" subtractfeefromamount
	result, err := c.call(ctx, walletName, "sendtoaddress", address, amount, "", "", subtractFee)
	if err != nil {
		return "", err
	}
	var txid string
	if err := json.Unmarshal(result, &txid); err != nil {
		return "", fmt.Errorf("decode sendtoaddress: %w", err)
	}
	return txid, nil
}

// SendMany sends to multiple addresses.
func (c *CoreRPCClient) SendMany(ctx context.Context, walletName string, amounts map[string]float64) (string, error) {
	result, err := c.call(ctx, walletName, "sendmany", "", amounts)
	if err != nil {
		return "", err
	}
	var txid string
	if err := json.Unmarshal(result, &txid); err != nil {
		return "", fmt.Errorf("decode sendmany: %w", err)
	}
	return txid, nil
}

// WalletTransaction represents a transaction from listtransactions.
// ListTransactions returns recent transactions.
func (c *CoreRPCClient) ListTransactions(ctx context.Context, walletName string, count int) ([]WalletTransaction, error) {
	return c.ListTransactionsRange(ctx, walletName, count, 0)
}

// ListTransactionsRange returns wallet transactions in a sliding window,
// skipping the first `skip` entries (cursor-based scan). Use to incrementally
// process new wallet activity without re-walking the entire history each tick.
func (c *CoreRPCClient) ListTransactionsRange(ctx context.Context, walletName string, count, skip int) ([]WalletTransaction, error) {
	if count <= 0 {
		count = 100
	}
	if skip < 0 {
		skip = 0
	}
	result, err := c.call(ctx, walletName, "listtransactions", "*", count, skip)
	if err != nil {
		return nil, err
	}
	var txs []WalletTransaction
	if err := json.Unmarshal(result, &txs); err != nil {
		return nil, fmt.Errorf("decode listtransactions: %w", err)
	}
	return txs, nil
}

// ListUnspent returns unspent outputs.
func (c *CoreRPCClient) ListUnspent(ctx context.Context, walletName string) ([]UTXO, error) {
	result, err := c.call(ctx, walletName, "listunspent")
	if err != nil {
		return nil, err
	}
	var utxos []UTXO
	if err := json.Unmarshal(result, &utxos); err != nil {
		return nil, fmt.Errorf("decode listunspent: %w", err)
	}
	return utxos, nil
}

// ListUnspentMinConf is ListUnspent with an explicit minconf. CPFP passes 0 so
// the unconfirmed parent output it must spend is visible (default minconf 1
// hides it).
func (c *CoreRPCClient) ListUnspentMinConf(ctx context.Context, walletName string, minConf int) ([]UTXO, error) {
	result, err := c.call(ctx, walletName, "listunspent", minConf)
	if err != nil {
		return nil, err
	}
	var utxos []UTXO
	if err := json.Unmarshal(result, &utxos); err != nil {
		return nil, fmt.Errorf("decode listunspent: %w", err)
	}
	return utxos, nil
}

// CreateRawTransaction builds an unsigned transaction node-side. Outputs
// keep their given order; each entry is {address: btc} or {"data": hex}.
func (c *CoreRPCClient) CreateRawTransaction(
	ctx context.Context,
	inputs []RawInput,
	outputs []map[string]interface{},
) (string, error) {
	result, err := c.call(ctx, "", "createrawtransaction", inputs, outputs)
	if err != nil {
		return "", err
	}
	var hex string
	if err := json.Unmarshal(result, &hex); err != nil {
		return "", fmt.Errorf("decode createrawtransaction: %w", err)
	}
	return hex, nil
}

func (c *CoreRPCClient) FundRawTransaction(
	ctx context.Context,
	walletName, hexString string,
	options map[string]interface{},
) (*FundRawTransactionResult, error) {
	result, err := c.call(ctx, walletName, "fundrawtransaction", hexString, options)
	if err != nil {
		return nil, err
	}
	var resp FundRawTransactionResult
	if err := json.Unmarshal(result, &resp); err != nil {
		return nil, fmt.Errorf("decode fundrawtransaction: %w", err)
	}
	return &resp, nil
}

func (c *CoreRPCClient) SignRawTransactionWithWallet(
	ctx context.Context,
	walletName, hexString string,
) (*SignRawTransactionResult, error) {
	result, err := c.call(ctx, walletName, "signrawtransactionwithwallet", hexString)
	if err != nil {
		return nil, err
	}
	var resp SignRawTransactionResult
	if err := json.Unmarshal(result, &resp); err != nil {
		return nil, fmt.Errorf("decode signrawtransactionwithwallet: %w", err)
	}
	return &resp, nil
}

func (c *CoreRPCClient) SendRawTransaction(ctx context.Context, hexString string) (string, error) {
	result, err := c.call(ctx, "", "sendrawtransaction", hexString)
	if err != nil {
		return "", err
	}
	var txid string
	if err := json.Unmarshal(result, &txid); err != nil {
		return "", fmt.Errorf("decode sendrawtransaction: %w", err)
	}
	return txid, nil
}

func (c *CoreRPCClient) GetRawChangeAddress(ctx context.Context, walletName string) (string, error) {
	result, err := c.call(ctx, walletName, "getrawchangeaddress", "bech32")
	if err != nil {
		return "", err
	}
	var address string
	if err := json.Unmarshal(result, &address); err != nil {
		return "", fmt.Errorf("decode getrawchangeaddress: %w", err)
	}
	return address, nil
}

func (c *CoreRPCClient) GetRawTransaction(ctx context.Context, txid string) (*RawTransaction, error) {
	result, err := c.call(ctx, "", "getrawtransaction", txid, 2)
	if err != nil {
		return nil, err
	}
	var tx RawTransaction
	if err := json.Unmarshal(result, &tx); err != nil {
		return nil, fmt.Errorf("decode getrawtransaction: %w", err)
	}
	return &tx, nil
}

// ListReceivedByAddress returns addresses that have received funds.
func (c *CoreRPCClient) ListReceivedByAddress(ctx context.Context, walletName string) ([]ReceivedByAddress, error) {
	// listreceivedbyaddress minconf include_empty include_watchonly
	result, err := c.call(ctx, walletName, "listreceivedbyaddress", 0, true)
	if err != nil {
		return nil, err
	}
	var addrs []ReceivedByAddress
	if err := json.Unmarshal(result, &addrs); err != nil {
		return nil, fmt.Errorf("decode listreceivedbyaddress: %w", err)
	}
	return addrs, nil
}

// GetTransaction returns details about a specific transaction.
func (c *CoreRPCClient) GetTransaction(ctx context.Context, walletName, txid string) (json.RawMessage, error) {
	return c.call(ctx, walletName, "gettransaction", txid, true)
}

// BumpFee bumps the fee on an unconfirmed transaction.
func (c *CoreRPCClient) BumpFee(ctx context.Context, walletName, txid string, newFeeRate int64) (string, error) {
	var options map[string]interface{}
	if newFeeRate > 0 {
		options = map[string]interface{}{"fee_rate": newFeeRate}
	}

	var result json.RawMessage
	var err error
	if options != nil {
		result, err = c.call(ctx, walletName, "bumpfee", txid, options)
	} else {
		result, err = c.call(ctx, walletName, "bumpfee", txid)
	}
	if err != nil {
		return "", err
	}

	var resp struct {
		TxID string `json:"txid"`
	}
	if err := json.Unmarshal(result, &resp); err != nil {
		return "", fmt.Errorf("decode bumpfee: %w", err)
	}
	return resp.TxID, nil
}

// MempoolEntry is the subset of getmempoolentry we use: the tx's virtual size
// and its absolute base fee in BTC.
type MempoolEntry struct {
	Vsize int64 `json:"vsize"`
	Fees  struct {
		Base float64 `json:"base"`
	} `json:"fees"`
}

// GetMempoolEntry returns mempool metadata for an unconfirmed txid, including
// its vsize and base fee. Errors if the tx is not in the mempool.
func (c *CoreRPCClient) GetMempoolEntry(ctx context.Context, txid string) (*MempoolEntry, error) {
	result, err := c.call(ctx, "", "getmempoolentry", txid)
	if err != nil {
		return nil, err
	}
	var entry MempoolEntry
	if err := json.Unmarshal(result, &entry); err != nil {
		return nil, fmt.Errorf("decode getmempoolentry: %w", err)
	}
	return &entry, nil
}

// GetBlockchainInfo returns blockchain info (used for health checks and sync).
func (c *CoreRPCClient) GetBlockchainInfo(ctx context.Context) (json.RawMessage, error) {
	return c.call(ctx, "", "getblockchaininfo")
}

// GenerateToAddress mines blocks to a given address (regtest only).
func (c *CoreRPCClient) GenerateToAddress(ctx context.Context, nblocks int, address string) ([]string, error) {
	result, err := c.call(ctx, "", "generatetoaddress", nblocks, address)
	if err != nil {
		return nil, err
	}
	var hashes []string
	if err := json.Unmarshal(result, &hashes); err != nil {
		return nil, fmt.Errorf("decode generatetoaddress: %w", err)
	}
	return hashes, nil
}

// AddNode adds a peer for p2p connection.
func (c *CoreRPCClient) AddNode(ctx context.Context, addr, command string) error {
	_, err := c.call(ctx, "", "addnode", addr, command)
	return err
}

// GetBlockCount returns the current block height.
func (c *CoreRPCClient) GetBlockCount(ctx context.Context) (int, error) {
	result, err := c.call(ctx, "", "getblockcount")
	if err != nil {
		return 0, err
	}
	var count int
	if err := json.Unmarshal(result, &count); err != nil {
		return 0, fmt.Errorf("decode getblockcount: %w", err)
	}
	return count, nil
}

// AddressInfo is a subset of getaddressinfo's response. We only need the
// HD derivation path so the orchestrator can rebuild the privkey from its
// seed for BIP47 ECDH blinding.
type AddressInfo struct {
	Address    string `json:"address"`
	HDKeyPath  string `json:"hdkeypath"`
	HDSeedID   string `json:"hdseedid"`
	IsMine     bool   `json:"ismine"`
	Solvable   bool   `json:"solvable"`
	IsScript   bool   `json:"isscript"`
	IsWitness  bool   `json:"iswitness"`
	WitnessVer int    `json:"witness_version"`
	PubKey     string `json:"pubkey"`
}

// GetAddressInfo returns information about an address in the wallet, including
// the HD derivation path when known.
func (c *CoreRPCClient) GetAddressInfo(ctx context.Context, walletName, address string) (*AddressInfo, error) {
	result, err := c.call(ctx, walletName, "getaddressinfo", address)
	if err != nil {
		return nil, err
	}
	var info AddressInfo
	if err := json.Unmarshal(result, &info); err != nil {
		return nil, fmt.Errorf("decode getaddressinfo: %w", err)
	}
	return &info, nil
}
