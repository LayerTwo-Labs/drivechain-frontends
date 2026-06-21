package elements

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"time"
)

// Client is a Bitcoin Core-style JSON-RPC client for the Elements/Liquid node.
// It mirrors the shape of the other sidechain clients (thunder.Client etc.) but
// adds HTTP basic auth, which Elements requires.
type Client struct {
	baseURL  string
	user     string
	password string
	http     *http.Client
}

// NewClient creates an Elements RPC client pointed at host:port.
//
// user/password are the rpcuser/rpcpassword the node was started with. For
// cookie auth, read <datadir>/<network>/.cookie (format "user:password") and
// split it before calling this. The orchestrator generates liquid-signet.conf
// via config.SidechainConfManager — resolve the creds from there.
func NewClient(host string, port int, user, password string) *Client {
	return &Client{
		baseURL:  fmt.Sprintf("http://%s:%d", host, port),
		user:     user,
		password: password,
		http:     &http.Client{Timeout: 30 * time.Second},
	}
}

type rpcRequest struct {
	JSONRPC string            `json:"jsonrpc"`
	ID      string            `json:"id"`
	Method  string            `json:"method"`
	Params  []json.RawMessage `json:"params"`
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
	return fmt.Sprintf("elements RPC error %d: %s", e.Code, e.Message)
}

// call executes a Bitcoin Core-style JSON-RPC request with basic auth.
// params is empty for every method we expose today; when a method needs
// positional arguments, pass them pre-encoded as json.RawMessage.
func (c *Client) call(ctx context.Context, method string, params []json.RawMessage) (json.RawMessage, error) {
	if params == nil {
		params = []json.RawMessage{}
	}
	body, err := json.Marshal(rpcRequest{JSONRPC: "1.0", ID: "orchestrator", Method: method, Params: params})
	if err != nil {
		return nil, fmt.Errorf("marshal %s request: %w", method, err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("create %s request: %w", method, err)
	}
	req.Header.Set("Content-Type", "application/json")
	if c.user != "" || c.password != "" {
		req.SetBasicAuth(c.user, c.password)
	}

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

// GetNewAddress returns a fresh wallet address for a Liquid deposit.
func (c *Client) GetNewAddress(ctx context.Context) (string, error) {
	raw, err := c.call(ctx, "getnewaddress", nil)
	if err != nil {
		return "", err
	}
	var addr string
	if err := json.Unmarshal(raw, &addr); err != nil {
		return "", fmt.Errorf("decode getnewaddress result: %w", err)
	}
	return addr, nil
}

// GetBlockCount returns the node's current block height.
func (c *Client) GetBlockCount(ctx context.Context) (int64, error) {
	raw, err := c.call(ctx, "getblockcount", nil)
	if err != nil {
		return 0, err
	}
	var height int64
	if err := json.Unmarshal(raw, &height); err != nil {
		return 0, fmt.Errorf("decode getblockcount result: %w", err)
	}
	return height, nil
}

// GetBalance returns the wallet balance.
//
// Elements is multi-asset, so `getbalance` returns a per-asset map
// ({assetLabelOrHex: amount}), not a bare number like Bitcoin Core. We pull the
// policy asset and convert to sats.
//
// TODO(contributor): confirm the policy-asset key on liquid-signet. It's
// "bitcoin" when the asset is labelled, but an unlabelled chain returns the
// 64-char asset hex instead — set policyAsset accordingly. Elements has no
// confirmed/available split like the CUSF chains, so AvailableSats mirrors
// TotalSats. NOT yet verified against a live node — see liquid-signet-integration.md.
func (c *Client) GetBalance(ctx context.Context) (*BalanceResponse, error) {
	const policyAsset = "bitcoin"

	raw, err := c.call(ctx, "getbalance", nil)
	if err != nil {
		return nil, err
	}
	var byAsset map[string]float64
	if err := json.Unmarshal(raw, &byAsset); err != nil {
		return nil, fmt.Errorf("decode getbalance (Elements returns a per-asset map): %w", err)
	}
	btc, ok := byAsset[policyAsset]
	if !ok {
		return nil, fmt.Errorf("getbalance: policy asset %q not present — set the correct asset key (see liquid-signet-integration.md)", policyAsset)
	}
	sats := int64(math.Round(btc * 1e8))
	return &BalanceResponse{TotalSats: sats, AvailableSats: sats}, nil
}
