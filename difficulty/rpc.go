package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
)

// Core reads block headers from an eCash node over JSON-RPC, with cookie auth.
type Core struct {
	url        string
	cookiePath string
	http       *http.Client
}

type rpcRequest struct {
	JSONRPC string `json:"jsonrpc"`
	ID      int    `json:"id"`
	Method  string `json:"method"`
	Params  []any  `json:"params"`
}

type rpcReply struct {
	ID     int             `json:"id"`
	Result json.RawMessage `json:"result"`
	Error  *struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

// batch sends calls in one request and returns each result in call order.
func (c *Core) batch(ctx context.Context, calls []rpcRequest) ([]json.RawMessage, error) {
	if len(calls) == 0 {
		return nil, nil
	}
	for i := range calls {
		calls[i].JSONRPC, calls[i].ID = "1.0", i
	}
	body, err := json.Marshal(calls)
	if err != nil {
		return nil, fmt.Errorf("encode rpc batch: %w", err)
	}
	cookie, err := os.ReadFile(c.cookiePath)
	if err != nil {
		return nil, fmt.Errorf("read rpc cookie: %w", err)
	}
	user, pass, ok := strings.Cut(strings.TrimSpace(string(cookie)), ":")
	if !ok {
		return nil, fmt.Errorf("rpc cookie %s has no user:password", c.cookiePath)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.url, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("build rpc request: %w", err)
	}
	req.SetBasicAuth(user, pass)
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("rpc %s: %w", calls[0].Method, err)
	}
	if resp.StatusCode == http.StatusUnauthorized {
		return nil, errors.Join(fmt.Errorf("rpc %s: unauthorized", calls[0].Method), resp.Body.Close())
	}
	var replies []rpcReply
	decodeErr := json.NewDecoder(resp.Body).Decode(&replies)
	if err := resp.Body.Close(); err != nil {
		return nil, fmt.Errorf("close rpc reply: %w", err)
	}
	if decodeErr != nil {
		return nil, fmt.Errorf("decode rpc %s: %s: %w", calls[0].Method, resp.Status, decodeErr)
	}
	results := make([]json.RawMessage, len(calls))
	for _, r := range replies {
		if r.ID < 0 || r.ID >= len(calls) {
			return nil, fmt.Errorf("rpc reply id %d out of range", r.ID)
		}
		if r.Error != nil {
			return nil, fmt.Errorf("rpc %s: %d %s", calls[r.ID].Method, r.Error.Code, r.Error.Message)
		}
		results[r.ID] = r.Result
	}
	return results, nil
}

// Tip returns the height and hash of the node's best block, both read from
// that block's own header.
func (c *Core) Tip(ctx context.Context) (int64, string, error) {
	res, err := c.batch(ctx, []rpcRequest{{Method: "getbestblockhash", Params: []any{}}})
	if err != nil {
		return 0, "", err
	}
	var hash string
	if err := json.Unmarshal(res[0], &hash); err != nil {
		return 0, "", fmt.Errorf("decode getbestblockhash: %w", err)
	}
	res, err = c.batch(ctx, []rpcRequest{{Method: "getblockheader", Params: []any{hash}}})
	if err != nil {
		return 0, "", err
	}
	var hdr struct {
		Height int64 `json:"height"`
	}
	if err := json.Unmarshal(res[0], &hdr); err != nil {
		return 0, "", fmt.Errorf("decode getblockheader %s: %w", hash, err)
	}
	return hdr.Height, hash, nil
}

// Headers returns the best-chain header at each height.
func (c *Core) Headers(ctx context.Context, heights []int64) (map[int64]Header, error) {
	calls := make([]rpcRequest, len(heights))
	for i, h := range heights {
		calls[i] = rpcRequest{Method: "getblockhash", Params: []any{h}}
	}
	hashes, err := c.batch(ctx, calls)
	if err != nil {
		return nil, err
	}
	for i, raw := range hashes {
		var hash string
		if err := json.Unmarshal(raw, &hash); err != nil {
			return nil, fmt.Errorf("decode getblockhash %d: %w", heights[i], err)
		}
		calls[i] = rpcRequest{Method: "getblockheader", Params: []any{hash}}
	}
	raws, err := c.batch(ctx, calls)
	if err != nil {
		return nil, err
	}
	headers := make(map[int64]Header, len(heights))
	for i, raw := range raws {
		var h struct {
			Height int64  `json:"height"`
			Time   int64  `json:"time"`
			Bits   string `json:"bits"`
		}
		if err := json.Unmarshal(raw, &h); err != nil {
			return nil, fmt.Errorf("decode getblockheader %d: %w", heights[i], err)
		}
		bits, err := strconv.ParseUint(h.Bits, 16, 32)
		if err != nil {
			return nil, fmt.Errorf("parse bits of block %d: %w", h.Height, err)
		}
		headers[h.Height] = Header{Height: h.Height, Time: h.Time, Bits: uint32(bits)}
	}
	return headers, nil
}
