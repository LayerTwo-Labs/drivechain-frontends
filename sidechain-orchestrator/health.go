package orchestrator

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
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
	conn.Close()
	return nil
}

// JSONRPCHealthCheck sends a JSON-RPC request to verify the service is responding.
type JSONRPCHealthCheck struct {
	URL     string
	Method  string
	Timeout time.Duration
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

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("JSON-RPC %s: %w", h.Method, err)
	}
	defer resp.Body.Close()
	io.Copy(io.Discard, resp.Body)

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("JSON-RPC %s returned HTTP %d", h.Method, resp.StatusCode)
	}

	return nil
}

// NewHealthChecker creates the appropriate health checker for a binary config.
func NewHealthChecker(config BinaryConfig) HealthChecker {
	timeout := 2 * time.Second
	host := "localhost"

	switch config.HealthCheckType {
	case HealthCheckJSONRPC:
		method := config.HealthCheckRPC
		if method == "" {
			method = "getblockcount"
		}
		return &JSONRPCHealthCheck{
			URL:     fmt.Sprintf("http://%s:%d", host, config.Port),
			Method:  method,
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
