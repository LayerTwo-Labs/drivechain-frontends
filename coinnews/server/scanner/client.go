// Package scanner walks Bitcoin Core blocks and feeds CoinNews
// payloads into the store. The bitcoind RPC client here is
// intentionally small: only the four methods the indexer needs.
package scanner

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"sync/atomic"
)

// Client is a minimal Bitcoin Core JSON-RPC client. Concurrent-safe.
type Client struct {
	URL  string // "http://localhost:38332"
	User string
	Pass string

	HTTP *http.Client
	id   atomic.Uint64
}

type rpcRequest struct {
	JSONRPC string `json:"jsonrpc"`
	ID      uint64 `json:"id"`
	Method  string `json:"method"`
	Params  any    `json:"params"`
}

type rpcResponse struct {
	Result json.RawMessage `json:"result"`
	Error  *struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

func (c *Client) call(ctx context.Context, method string, params any, out any) error {
	body, err := json.Marshal(rpcRequest{
		JSONRPC: "1.0",
		ID:      c.id.Add(1),
		Method:  method,
		Params:  params,
	})
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, "POST", c.URL, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.SetBasicAuth(c.User, c.Pass)
	req.Header.Set("content-type", "application/json")

	httpClient := c.HTTP
	if httpClient == nil {
		httpClient = http.DefaultClient
	}
	resp, err := httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("rpc %s: %w", method, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	var r rpcResponse
	if err := json.NewDecoder(resp.Body).Decode(&r); err != nil {
		return fmt.Errorf("rpc %s decode: %w", method, err)
	}
	if r.Error != nil {
		return fmt.Errorf("rpc %s: %s (code %d)", method, r.Error.Message, r.Error.Code)
	}
	if out == nil {
		return nil
	}
	return json.Unmarshal(r.Result, out)
}

// GetBlockCount returns the current chain tip height.
func (c *Client) GetBlockCount(ctx context.Context) (uint32, error) {
	var n uint32
	return n, c.call(ctx, "getblockcount", []any{}, &n)
}

// GetBlockHash returns the block hash at the given height (display hex).
func (c *Client) GetBlockHash(ctx context.Context, height uint32) (string, error) {
	var s string
	return s, c.call(ctx, "getblockhash", []any{height}, &s)
}

// Block is the verbose=2 representation we care about. Only fields
// the scanner reads are unmarshalled.
type Block struct {
	Hash         string `json:"hash"`
	Height       uint32 `json:"height"`
	Time         int64  `json:"time"`
	Mediantime   int64  `json:"mediantime"`
	Tx           []struct {
		Txid string `json:"txid"`
		Vout []struct {
			ScriptPubKey struct {
				Hex string `json:"hex"`
				Type string `json:"type"`
			} `json:"scriptPubKey"`
		} `json:"vout"`
	} `json:"tx"`
}

// GetBlock fetches a block by hash with verbose=2 (full tx data).
func (c *Client) GetBlock(ctx context.Context, hash string) (*Block, error) {
	var b Block
	return &b, c.call(ctx, "getblock", []any{hash, 2}, &b)
}
