package rpc

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"sync/atomic"
	"time"
)

// Client is a minimal JSON-RPC 2.0 HTTP client.
type Client struct {
	url  string
	http *http.Client
	// timeout is the deadline one method gets. http.Client.Timeout would cap
	// every method at the shortest of them.
	timeout func(method string) time.Duration
	nextID  atomic.Int64
}

// New creates a JSON-RPC client targeting the given host and port.
func New(host string, port int) *Client {
	return &Client{
		url:     fmt.Sprintf("http://%s:%d", host, port),
		http:    &http.Client{},
		timeout: MethodTimeout,
	}
}

type request struct {
	JSONRPC string `json:"jsonrpc"`
	Method  string `json:"method"`
	Params  any    `json:"params,omitempty"`
	ID      int64  `json:"id"`
}

type response struct {
	JSONRPC string          `json:"jsonrpc"`
	Result  json.RawMessage `json:"result"`
	Error   *rpcError       `json:"error"`
	ID      int64           `json:"id"`
}

type rpcError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (e *rpcError) Error() string {
	return fmt.Sprintf("rpc error %d: %s", e.Code, e.Message)
}

const methodNotFound = -32601

// LacksMethod reports an error that says the node serves no such method.
func LacksMethod(err error) bool {
	var rpcErr *rpcError
	return errors.As(err, &rpcErr) && rpcErr.Code == methodNotFound
}

// Call invokes a JSON-RPC method. params can be nil, a slice, a map, or a
// single value. out can be nil if the caller doesn't need the result.
func (c *Client) Call(ctx context.Context, method string, params any, out any) error {
	reqBody := request{
		JSONRPC: "2.0",
		Method:  method,
		Params:  params,
		ID:      c.nextID.Add(1),
	}

	body, err := json.Marshal(reqBody)
	if err != nil {
		return fmt.Errorf("marshal request: %w", err)
	}

	ctx, cancel := context.WithTimeout(ctx, c.timeout(method))
	defer cancel()

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.url, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	httpResp, err := c.http.Do(httpReq)
	if err != nil {
		return fmt.Errorf("http post: %w", err)
	}
	defer func() { _ = httpResp.Body.Close() }()

	var resp response
	if err := json.NewDecoder(httpResp.Body).Decode(&resp); err != nil {
		return fmt.Errorf("decode response: %w", err)
	}

	if resp.Error != nil {
		return resp.Error
	}

	if out != nil && resp.Result != nil {
		if err := json.Unmarshal(resp.Result, out); err != nil {
			return fmt.Errorf("unmarshal result: %w", err)
		}
	}

	return nil
}

// CallRaw invokes a JSON-RPC method and returns the raw result bytes.
func (c *Client) CallRaw(ctx context.Context, method string, params any) (json.RawMessage, error) {
	reqBody := request{
		JSONRPC: "2.0",
		Method:  method,
		Params:  params,
		ID:      c.nextID.Add(1),
	}

	body, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	ctx, cancel := context.WithTimeout(ctx, c.timeout(method))
	defer cancel()

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.url, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	httpResp, err := c.http.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("http post: %w", err)
	}
	defer func() { _ = httpResp.Body.Close() }()

	var resp response
	if err := json.NewDecoder(httpResp.Body).Decode(&resp); err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}

	if resp.Error != nil {
		return nil, resp.Error
	}

	return resp.Result, nil
}
