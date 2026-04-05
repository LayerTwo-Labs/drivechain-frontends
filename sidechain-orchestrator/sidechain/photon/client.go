package photon

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// Client is a JSON-RPC client for the Photon sidechain node.
// It mirrors the RPC surface exposed in the Dart PhotonRPC class.
type Client struct {
	baseURL string
	http    *http.Client
}

// NewClient creates a Photon RPC client pointed at host:port.
func NewClient(host string, port int) *Client {
	return &Client{
		baseURL: fmt.Sprintf("http://%s:%d", host, port),
		http:    &http.Client{Timeout: 30 * time.Second},
	}
}

// ---------------------------------------------------------------------------
// low-level JSON-RPC plumbing
// ---------------------------------------------------------------------------

type rpcRequest struct {
	JSONRPC string      `json:"jsonrpc"`
	ID      string      `json:"id"`
	Method  string      `json:"method"`
	Params  interface{} `json:"params"`
}

type rpcResponse struct {
	Result json.RawMessage `json:"result"`
	Error  *rpcError       `json:"error"`
}

type rpcError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (e *rpcError) Error() string {
	return fmt.Sprintf("photon RPC error %d: %s", e.Code, e.Message)
}

// call executes a JSON-RPC request. params may be nil, a single value, or a
// slice — matching how the Dart client passes arguments.
func (c *Client) call(ctx context.Context, method string, params interface{}) (json.RawMessage, error) {
	body, err := json.Marshal(rpcRequest{
		JSONRPC: "2.0",
		ID:      "orchestrator",
		Method:  method,
		Params:  params,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal %s request: %w", method, err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("create %s request: %w", method, err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.http.Do(req)
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
		return nil, rpcResp.Error
	}

	return rpcResp.Result, nil
}

// unmarshal is a typed helper that calls a method and decodes into T.
func unmarshal[T any](c *Client, ctx context.Context, method string, params interface{}) (T, error) {
	var zero T
	raw, err := c.call(ctx, method, params)
	if err != nil {
		return zero, err
	}
	var v T
	if err := json.Unmarshal(raw, &v); err != nil {
		return zero, fmt.Errorf("decode %s result: %w", method, err)
	}
	return v, nil
}

// ---------------------------------------------------------------------------
// Wallet / Balance
// ---------------------------------------------------------------------------

// Balance returns the node wallet balance.
func (c *Client) Balance(ctx context.Context) (*BalanceResponse, error) {
	r, err := unmarshal[BalanceResponse](c, ctx, "balance", nil)
	if err != nil {
		return nil, err
	}
	return &r, nil
}

// GetNewAddress generates and returns a new wallet address.
func (c *Client) GetNewAddress(ctx context.Context) (string, error) {
	return unmarshal[string](c, ctx, "get_new_address", nil)
}

// GetWalletAddresses returns all wallet addresses sorted by base58.
func (c *Client) GetWalletAddresses(ctx context.Context) ([]string, error) {
	return unmarshal[[]string](c, ctx, "get_wallet_addresses", nil)
}

// GetWalletUTXOs returns wallet UTXOs as raw JSON (schema varies).
func (c *Client) GetWalletUTXOs(ctx context.Context) (json.RawMessage, error) {
	return c.call(ctx, "get_wallet_utxos", nil)
}

// ListUTXOs returns all UTXOs as raw JSON.
func (c *Client) ListUTXOs(ctx context.Context) (json.RawMessage, error) {
	return c.call(ctx, "list_utxos", nil)
}

// MyUTXOs returns the caller's owned UTXOs as raw JSON.
func (c *Client) MyUTXOs(ctx context.Context) (json.RawMessage, error) {
	return c.call(ctx, "my_utxos", nil)
}

// Transfer sends funds.
func (c *Client) Transfer(ctx context.Context, dest string, valueSats, feeSats int64, memo *string) (string, error) {
	params := []interface{}{dest, valueSats, feeSats, memo}
	return unmarshal[string](c, ctx, "transfer", params)
}

// CreateDeposit creates a deposit transaction.
func (c *Client) CreateDeposit(ctx context.Context, address string, valueSats, feeSats int64) (string, error) {
	return unmarshal[string](c, ctx, "create_deposit", []interface{}{address, valueSats, feeSats})
}

// Withdraw initiates a withdrawal to the mainchain.
func (c *Client) Withdraw(ctx context.Context, mainchainAddr string, amountSats, sidechainFeeSats, mainchainFeeSats int64) (string, error) {
	return unmarshal[string](c, ctx, "withdraw", []interface{}{mainchainAddr, amountSats, sidechainFeeSats, mainchainFeeSats})
}

// SidechainWealthSats returns the total sidechain wealth in satoshis.
func (c *Client) SidechainWealthSats(ctx context.Context) (int64, error) {
	return unmarshal[int64](c, ctx, "sidechain_wealth_sats", nil)
}

// ---------------------------------------------------------------------------
// Blockchain
// ---------------------------------------------------------------------------

// GetBlockCount returns the current block height.
func (c *Client) GetBlockCount(ctx context.Context) (int, error) {
	return unmarshal[int](c, ctx, "getblockcount", nil)
}

// GetBlock returns block data for a given hash.
func (c *Client) GetBlock(ctx context.Context, hash string) (json.RawMessage, error) {
	return c.call(ctx, "get_block", hash)
}

// GetBMMInclusions returns mainchain blocks that commit to the given block hash.
func (c *Client) GetBMMInclusions(ctx context.Context, blockHash string) (string, error) {
	return unmarshal[string](c, ctx, "get_bmm_inclusions", blockHash)
}

// GetBestMainchainBlockHash returns the best known mainchain block hash.
func (c *Client) GetBestMainchainBlockHash(ctx context.Context) (*string, error) {
	raw, err := c.call(ctx, "get_best_mainchain_block_hash", nil)
	if err != nil {
		return nil, err
	}
	if string(raw) == "null" {
		return nil, nil
	}
	var s string
	if err := json.Unmarshal(raw, &s); err != nil {
		return nil, fmt.Errorf("decode get_best_mainchain_block_hash result: %w", err)
	}
	return &s, nil
}

// GetBestSidechainBlockHash returns the best known sidechain block hash.
func (c *Client) GetBestSidechainBlockHash(ctx context.Context) (*string, error) {
	raw, err := c.call(ctx, "get_best_sidechain_block_hash", nil)
	if err != nil {
		return nil, err
	}
	if string(raw) == "null" {
		return nil, nil
	}
	var s string
	if err := json.Unmarshal(raw, &s); err != nil {
		return nil, fmt.Errorf("decode get_best_sidechain_block_hash result: %w", err)
	}
	return &s, nil
}

// LatestFailedWithdrawalBundleHeight returns the height of the most recent
// failed withdrawal bundle, or nil if none.
func (c *Client) LatestFailedWithdrawalBundleHeight(ctx context.Context) (*int, error) {
	raw, err := c.call(ctx, "latest_failed_withdrawal_bundle_height", nil)
	if err != nil {
		return nil, err
	}
	if string(raw) == "null" {
		return nil, nil
	}
	var h int
	if err := json.Unmarshal(raw, &h); err != nil {
		return nil, fmt.Errorf("decode latest_failed_withdrawal_bundle_height result: %w", err)
	}
	return &h, nil
}

// PendingWithdrawalBundle returns the current pending withdrawal bundle as raw JSON.
func (c *Client) PendingWithdrawalBundle(ctx context.Context) (json.RawMessage, error) {
	return c.call(ctx, "pending_withdrawal_bundle", nil)
}

// ---------------------------------------------------------------------------
// Peers
// ---------------------------------------------------------------------------

// ConnectPeer connects to a peer at the given address.
func (c *Client) ConnectPeer(ctx context.Context, address string) error {
	_, err := c.call(ctx, "connect_peer", address)
	return err
}

// ListPeers returns connected peers.
func (c *Client) ListPeers(ctx context.Context) ([]PeerInfo, error) {
	return unmarshal[[]PeerInfo](c, ctx, "list_peers", nil)
}

// ---------------------------------------------------------------------------
// Seed / Mnemonic
// ---------------------------------------------------------------------------

// GenerateMnemonic generates a new BIP-39 mnemonic.
func (c *Client) GenerateMnemonic(ctx context.Context) (string, error) {
	return unmarshal[string](c, ctx, "generate_mnemonic", nil)
}

// SetSeedFromMnemonic sets the wallet seed from a mnemonic phrase.
func (c *Client) SetSeedFromMnemonic(ctx context.Context, mnemonic string) error {
	_, err := c.call(ctx, "set_seed_from_mnemonic", mnemonic)
	return err
}

// ---------------------------------------------------------------------------
// Mining
// ---------------------------------------------------------------------------

// Mine attempts to create and submit a BMM block.
func (c *Client) Mine(ctx context.Context, feeSats int64) (*BmmResult, error) {
	r, err := unmarshal[BmmResult](c, ctx, "mine", feeSats)
	if err != nil {
		return nil, err
	}
	return &r, nil
}

// ---------------------------------------------------------------------------
// Schema / Lifecycle
// ---------------------------------------------------------------------------

// OpenAPISchema returns the node's OpenAPI schema.
func (c *Client) OpenAPISchema(ctx context.Context) (json.RawMessage, error) {
	return c.call(ctx, "openapi_schema", nil)
}

// Stop gracefully shuts down the Photon node.
func (c *Client) Stop(ctx context.Context) error {
	_, err := c.call(ctx, "stop", nil)
	return err
}