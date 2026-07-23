package jsonrpc

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync/atomic"
	"time"
)

// Request represents a JSON-RPC request
type Request struct {
	JSONRPC string `json:"jsonrpc"`
	Method  string `json:"method"`
	Params  []any  `json:"params"`
	ID      string `json:"id"`
}

// Response represents a JSON-RPC response
type Response struct {
	JSONRPC string          `json:"jsonrpc"`
	Result  json.RawMessage `json:"result,omitempty"`
	Error   *Error          `json:"error,omitempty"`
	ID      string          `json:"id"`
}

// Error represents a JSON-RPC error
type Error struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

// Client is a simple JSON-RPC client
type Client struct {
	url      string
	username string
	password string
	client   *http.Client
}

// NewClient creates a new JSON-RPC client
func NewClient(url, username, password string) *Client {
	return &Client{
		url:      url,
		username: username,
		password: password,
		client:   &http.Client{Timeout: 30 * time.Second},
	}
}

var idCounter atomic.Uint32

func newCallConfig(opts ...CallOption) *callConfig {
	config := callConfig{
		// important: nil leads to `null` instead `[]`, which is an error
		params: []any{},
	}
	for _, opt := range opts {
		opt(&config)
	}

	if config.id == 0 {
		config.id = int(idCounter.Add(1))
	}

	return &config
}

type callConfig struct {
	id     int
	params []any
}

type CallOption func(*callConfig)

func WithID(id int) CallOption {
	return func(c *callConfig) {
		c.id = id
	}
}

func WithParams(params ...any) CallOption {
	return func(c *callConfig) {
		c.params = params
	}
}

// Call makes a JSON-RPC call with the specified method and parameters
func (c *Client) Call(ctx context.Context, method string, opts ...CallOption) (json.RawMessage, error) {
	config := newCallConfig()
	for _, opt := range opts {
		opt(config)
	}

	request := Request{
		JSONRPC: "2.0",
		Method:  method,
		Params:  config.params,
		ID:      fmt.Sprintf("%d", config.id),
	}

	requestBody, err := json.Marshal(request)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(
		ctx, http.MethodPost,
		c.url, bytes.NewReader(requestBody),
	)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	if c.username != "" || c.password != "" {
		req.SetBasicAuth(c.username, c.password)
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("do request: %w", err)
	}
	// nolint:errcheck
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	fullBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response: %w", err)
	}

	var response Response
	if err := json.Unmarshal(fullBody, &response); err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}

	if response.Error != nil {
		return nil, fmt.Errorf("rpc error: %q: %d: %s", request.Method, response.Error.Code, string(fullBody))
	}

	return response.Result, nil
}
