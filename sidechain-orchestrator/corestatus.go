package orchestrator

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// CoreStatusClient is a minimal Bitcoin Core JSON-RPC client for startup sequencing checks.
// It only implements the 2-3 calls needed to check wallet unlock and IBD status.
type CoreStatusClient struct {
	url      string
	user     string
	password string
	client   *http.Client
}

func NewCoreStatusClient(host string, port int, user, password string) *CoreStatusClient {
	return &CoreStatusClient{
		url:      fmt.Sprintf("http://%s:%d", host, port),
		user:     user,
		password: password,
		client:   &http.Client{Timeout: 5 * time.Second},
	}
}

type jsonRPCRequest struct {
	JSONRPC string        `json:"jsonrpc"`
	ID      string        `json:"id"`
	Method  string        `json:"method"`
	Params  []interface{} `json:"params"`
}

type jsonRPCResponse struct {
	Result json.RawMessage `json:"result"`
	Error  *struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

func (c *CoreStatusClient) call(ctx context.Context, method string, params ...interface{}) (json.RawMessage, error) {
	if params == nil {
		params = []interface{}{}
	}
	body, err := json.Marshal(jsonRPCRequest{
		JSONRPC: "1.0",
		ID:      "orchestrator",
		Method:  method,
		Params:  params,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal %s request: %w", method, err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.url, bytes.NewReader(body))
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
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read %s response: %w", method, err)
	}

	var rpcResp jsonRPCResponse
	if err := json.Unmarshal(respBody, &rpcResp); err != nil {
		return nil, fmt.Errorf("decode %s response: %w", method, err)
	}

	if rpcResp.Error != nil {
		return nil, fmt.Errorf("%s RPC error %d: %s", method, rpcResp.Error.Code, rpcResp.Error.Message)
	}

	return rpcResp.Result, nil
}

// IsIBDComplete checks if Bitcoin Core has finished initial block download.
func (c *CoreStatusClient) IsIBDComplete(ctx context.Context) (bool, error) {
	result, err := c.call(ctx, "getblockchaininfo")
	if err != nil {
		return false, err
	}

	var info struct {
		InitialBlockDownload bool `json:"initialblockdownload"`
	}
	if err := json.Unmarshal(result, &info); err != nil {
		return false, fmt.Errorf("decode getblockchaininfo: %w", err)
	}

	return !info.InitialBlockDownload, nil
}

// IsWalletLoaded checks if a wallet is loaded in Bitcoin Core.
func (c *CoreStatusClient) IsWalletLoaded(ctx context.Context) (bool, error) {
	result, err := c.call(ctx, "getwalletinfo")
	if err != nil {
		// -18 means no wallet is loaded
		return false, nil
	}

	var info struct {
		WalletName string `json:"walletname"`
	}
	if err := json.Unmarshal(result, &info); err != nil {
		return false, fmt.Errorf("decode getwalletinfo: %w", err)
	}

	return true, nil
}

// GetBlockCount returns the current block height.
func (c *CoreStatusClient) GetBlockCount(ctx context.Context) (int64, error) {
	result, err := c.call(ctx, "getblockcount")
	if err != nil {
		return 0, err
	}

	var count int64
	if err := json.Unmarshal(result, &count); err != nil {
		return 0, fmt.Errorf("decode getblockcount: %w", err)
	}

	return count, nil
}
