package wallet

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
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
	return &CoreRPCClient{
		baseURL:  fmt.Sprintf("http://%s:%d", host, port),
		user:     user,
		password: password,
		client:   &http.Client{Timeout: 30 * time.Second},
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
	Desc      string `json:"desc"`
	Active    bool   `json:"active"`
	Timestamp string `json:"timestamp"` // "now" or unix timestamp
	Internal  bool   `json:"internal,omitempty"`
	Range     []int  `json:"range,omitempty"`
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

// CoreTransaction represents a transaction from listtransactions.
type CoreTransaction struct {
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

// ListTransactions returns recent transactions.
func (c *CoreRPCClient) ListTransactions(ctx context.Context, walletName string, count int) ([]CoreTransaction, error) {
	if count <= 0 {
		count = 100
	}
	result, err := c.call(ctx, walletName, "listtransactions", "*", count)
	if err != nil {
		return nil, err
	}
	var txs []CoreTransaction
	if err := json.Unmarshal(result, &txs); err != nil {
		return nil, fmt.Errorf("decode listtransactions: %w", err)
	}
	return txs, nil
}

// CoreUTXO represents an unspent output from listunspent.
type CoreUTXO struct {
	TxID          string  `json:"txid"`
	Vout          int     `json:"vout"`
	Address       string  `json:"address"`
	Label         string  `json:"label"`
	Amount        float64 `json:"amount"`
	Confirmations int     `json:"confirmations"`
	Spendable     bool    `json:"spendable"`
	Solvable      bool    `json:"solvable"`
}

// ListUnspent returns unspent outputs.
func (c *CoreRPCClient) ListUnspent(ctx context.Context, walletName string) ([]CoreUTXO, error) {
	result, err := c.call(ctx, walletName, "listunspent")
	if err != nil {
		return nil, err
	}
	var utxos []CoreUTXO
	if err := json.Unmarshal(result, &utxos); err != nil {
		return nil, fmt.Errorf("decode listunspent: %w", err)
	}
	return utxos, nil
}

// CoreReceivedByAddress represents a result from listreceivedbyaddress.
type CoreReceivedByAddress struct {
	Address       string  `json:"address"`
	Amount        float64 `json:"amount"`
	Confirmations int     `json:"confirmations"`
	Label         string  `json:"label"`
	TxIDs         []string `json:"txids"`
}

// ListReceivedByAddress returns addresses that have received funds.
func (c *CoreRPCClient) ListReceivedByAddress(ctx context.Context, walletName string) ([]CoreReceivedByAddress, error) {
	// listreceivedbyaddress minconf include_empty include_watchonly
	result, err := c.call(ctx, walletName, "listreceivedbyaddress", 0, true)
	if err != nil {
		return nil, err
	}
	var addrs []CoreReceivedByAddress
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

// DeriveAddresses derives addresses from a descriptor.
func (c *CoreRPCClient) DeriveAddresses(ctx context.Context, descriptor string, rangeStart, rangeEnd int) ([]string, error) {
	result, err := c.call(ctx, "", "deriveaddresses", descriptor, []int{rangeStart, rangeEnd})
	if err != nil {
		return nil, err
	}
	var addresses []string
	if err := json.Unmarshal(result, &addresses); err != nil {
		return nil, fmt.Errorf("decode deriveaddresses: %w", err)
	}
	return addresses, nil
}
