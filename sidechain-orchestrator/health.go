package orchestrator

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
	"strings"
	"time"
)

// HealthChecker checks if a binary is healthy.
type HealthChecker interface {
	Check(ctx context.Context) error
}

// TCPHealthCheck verifies a port is accepting connections.
type TCPHealthCheck struct {
	Host    string
	Port    int
	Timeout time.Duration
}

func (h *TCPHealthCheck) Check(ctx context.Context) error {
	addr := fmt.Sprintf("%s:%d", h.Host, h.Port)
	dialer := net.Dialer{Timeout: h.Timeout}
	conn, err := dialer.DialContext(ctx, "tcp", addr)
	if err != nil {
		return fmt.Errorf("TCP connect to %s: %w", addr, err)
	}
	_ = conn.Close()
	return nil
}

// JSONRPCHealthCheck sends a JSON-RPC request to verify the service is responding.
type JSONRPCHealthCheck struct {
	URL      string
	Method   string
	User     string
	Password string
	Timeout  time.Duration
}

func (h *JSONRPCHealthCheck) Check(ctx context.Context) error {
	body, err := json.Marshal(map[string]interface{}{
		"jsonrpc": "1.0",
		"id":      "health",
		"method":  h.Method,
		"params":  []interface{}{},
	})
	if err != nil {
		return fmt.Errorf("marshal request: %w", err)
	}

	ctx, cancel := context.WithTimeout(ctx, h.Timeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, h.URL, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	if h.User != "" {
		req.SetBasicAuth(h.User, h.Password)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("JSON-RPC %s: %w", h.Method, err)
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read JSON-RPC %s response: %w", h.Method, err)
	}

	// bitcoind during warmup returns HTTP 200 with an embedded JSON-RPC error
	// (e.g. code -28 "Loading block index…"). We must parse the body rather
	// than trust the HTTP status, otherwise the orchestrator flips
	// connected=true while the daemon is still booting.
	var rpcResp jsonRPCResponse
	if jerr := json.Unmarshal(respBody, &rpcResp); jerr == nil && rpcResp.Error != nil {
		return fmt.Errorf("%s: %s", h.Method, rpcResp.Error.Message)
	}

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("JSON-RPC %s returned HTTP %d", h.Method, resp.StatusCode)
	}

	return nil
}

// ConnectRPCHealthCheck POSTs an empty JSON body to a Connect-JSON endpoint and
// inspects the response. On Connect-JSON, success is HTTP 200 with a JSON body
// that has no `code` field; failure is HTTP 4xx/5xx with
// `{"code":"...","message":"..."}`. Warmup errors (daemon up, not ready) come
// back here as an error message that the connection monitor pattern-matches
// into startupError — e.g. the enforcer returning "Validator is not synced"
// while still catching up to the mainchain tip.
type ConnectRPCHealthCheck struct {
	URL     string // e.g. "http://localhost:50051/cusf.mainchain.v1.ValidatorService/GetChainTip"
	Timeout time.Duration
}

func (h *ConnectRPCHealthCheck) Check(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, h.Timeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, h.URL, strings.NewReader("{}"))
	if err != nil {
		return fmt.Errorf("build connect request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("connect %s: %w", h.URL, err)
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read connect response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		var cerr struct {
			Code    string `json:"code"`
			Message string `json:"message"`
		}
		if json.Unmarshal(body, &cerr) == nil && cerr.Message != "" {
			return fmt.Errorf("%s", cerr.Message)
		}
		return fmt.Errorf("connect HTTP %d: %s", resp.StatusCode, string(body))
	}

	return nil
}

// HealthCheckOpts provides optional configuration for health checkers.
type HealthCheckOpts struct {
	User     string
	Password string
}

// NewHealthChecker creates the appropriate health checker for a binary config.
func NewHealthChecker(config BinaryConfig, opts ...HealthCheckOpts) HealthChecker {
	timeout := 2 * time.Second
	host := "localhost"

	var opt HealthCheckOpts
	if len(opts) > 0 {
		opt = opts[0]
	}

	switch config.HealthCheckType {
	case HealthCheckJSONRPC:
		method := config.HealthCheckRPC
		if method == "" {
			method = "getblockcount"
		}
		return &JSONRPCHealthCheck{
			URL:      fmt.Sprintf("http://%s:%d", host, config.Port),
			Method:   method,
			User:     opt.User,
			Password: opt.Password,
			Timeout:  timeout,
		}
	case HealthCheckConnectRPC:
		path := strings.TrimPrefix(config.HealthCheckRPC, "/")
		return &ConnectRPCHealthCheck{
			URL:     fmt.Sprintf("http://%s:%d/%s", host, config.Port, path),
			Timeout: timeout,
		}
	default:
		return &TCPHealthCheck{
			Host:    host,
			Port:    config.Port,
			Timeout: timeout,
		}
	}
}

// WaitForHealthy polls the health checker until it succeeds or the context is canceled.
func WaitForHealthy(ctx context.Context, checker HealthChecker, interval time.Duration) error {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		if err := checker.Check(ctx); err == nil {
			return nil
		}

		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
		}
	}
}

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
	defer resp.Body.Close() //nolint:errcheck // cleanup

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

// IsHeaderSyncComplete reports whether Bitcoin Core has finished downloading
// headers — block IBD may still be in progress. Enforcer only needs headers
// to start validating BIP300/301 activity (it syncs blocks alongside Core),
// so gating on IBD forces users to wait for the full chain when they don't
// have to. Signal: headers > 0 AND headers >= blocks AND we're past the
// "still connecting / no chain" bootstrap phase (headers > 10).
func (c *CoreStatusClient) IsHeaderSyncComplete(ctx context.Context) (bool, error) {
	result, err := c.call(ctx, "getblockchaininfo")
	if err != nil {
		return false, err
	}

	var info struct {
		Blocks  int64 `json:"blocks"`
		Headers int64 `json:"headers"`
	}
	if err := json.Unmarshal(result, &info); err != nil {
		return false, fmt.Errorf("decode getblockchaininfo: %w", err)
	}

	// Header sync happens ahead of block validation: headers >= blocks during
	// IBD, and both equal at tip. A fresh node reports 0/0 until peers start
	// feeding headers — require at least 10 headers to avoid false positives
	// before any peer connects.
	if info.Headers < 10 {
		return false, nil
	}
	return info.Headers >= info.Blocks, nil
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
