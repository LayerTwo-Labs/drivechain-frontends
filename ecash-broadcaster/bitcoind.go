package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

// bitcoindClient is a minimal JSON-RPC client — just enough to broadcast.
type bitcoindClient struct {
	url  string
	user string
	pass string
	http *http.Client
}

func newBitcoindClient(host string, port int, user, pass string) *bitcoindClient {
	return &bitcoindClient{
		url:  fmt.Sprintf("http://%s:%d", host, port),
		user: user,
		pass: pass,
		http: &http.Client{},
	}
}

// sendRawTransaction submits a raw tx hex to the (eCash) node and returns its txid.
func (c *bitcoindClient) sendRawTransaction(ctx context.Context, txHex string) (string, error) {
	body, err := json.Marshal(map[string]any{
		"jsonrpc": "1.0",
		"id":      "ecash-broadcaster",
		"method":  "sendrawtransaction",
		"params":  []any{txHex},
	})
	if err != nil {
		return "", err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.url, bytes.NewReader(body))
	if err != nil {
		return "", err
	}
	req.SetBasicAuth(c.user, c.pass)
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return "", fmt.Errorf("call bitcoind: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()

	var out struct {
		Result string `json:"result"`
		Error  *struct {
			Code    int    `json:"code"`
			Message string `json:"message"`
		} `json:"error"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return "", fmt.Errorf("decode bitcoind response: %w", err)
	}
	if out.Error != nil {
		return "", fmt.Errorf("bitcoind error %d: %s", out.Error.Code, out.Error.Message)
	}
	return out.Result, nil
}
