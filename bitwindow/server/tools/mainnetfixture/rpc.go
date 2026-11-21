package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

type rpcClient struct {
	url  string
	user string
	pass string
	http *http.Client
}

func newRPCClient(url, cookieFile string) (*rpcClient, error) {
	cookie, err := os.ReadFile(cookieFile)
	if err != nil {
		return nil, fmt.Errorf("read cookie: %w", err)
	}
	user, pass, ok := strings.Cut(strings.TrimSpace(string(cookie)), ":")
	if !ok {
		return nil, fmt.Errorf("cookie %s has no user:password", cookieFile)
	}
	return &rpcClient{url: url, user: user, pass: pass, http: &http.Client{Timeout: 10 * time.Minute, Transport: &http.Transport{MaxIdleConnsPerHost: 16}}}, nil
}

type rpcCall struct {
	Method string
	Params any
}

type rpcReply struct {
	ID     int             `json:"id"`
	Result json.RawMessage `json:"result"`
	Error  *struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

func (c *rpcClient) post(wallet string, body any) ([]byte, error) {
	payload, err := json.Marshal(body)
	if err != nil {
		return nil, err
	}
	url := c.url
	if wallet != "" {
		url += "/wallet/" + wallet
	}
	var resp *http.Response
	for attempt := 0; ; attempt++ {
		req, err := http.NewRequestWithContext(context.Background(), http.MethodPost, url, bytes.NewReader(payload))
		if err != nil {
			return nil, err
		}
		req.SetBasicAuth(c.user, c.pass)
		req.Header.Set("Content-Type", "application/json")
		resp, err = c.http.Do(req)
		// A host short of local ports fails the dial, so the request never left.
		if err != nil && strings.Contains(err.Error(), "can't assign requested address") && attempt < 60 {
			time.Sleep(time.Second)
			continue
		}
		if err != nil {
			return nil, err
		}
		break
	}
	defer resp.Body.Close() //nolint:errcheck
	return io.ReadAll(resp.Body)
}

// batch sends all calls in one JSON-RPC batch. It fails on the first call that Core rejects.
func (c *rpcClient) batch(wallet string, calls []rpcCall) ([]json.RawMessage, error) {
	if len(calls) == 0 {
		return nil, nil
	}
	reqs := make([]map[string]any, len(calls))
	for i, call := range calls {
		params := call.Params
		if params == nil {
			params = []any{}
		}
		reqs[i] = map[string]any{"jsonrpc": "2.0", "id": i, "method": call.Method, "params": params}
	}
	raw, err := c.post(wallet, reqs)
	if err != nil {
		return nil, fmt.Errorf("batch of %d %s: %w", len(calls), calls[0].Method, err)
	}
	var replies []rpcReply
	if err := json.Unmarshal(raw, &replies); err != nil {
		return nil, fmt.Errorf("decode batch of %d %s: %w: %.300s", len(calls), calls[0].Method, err, raw)
	}
	out := make([]json.RawMessage, len(calls))
	for _, r := range replies {
		if r.Error != nil {
			return nil, fmt.Errorf("%s (call %d): %d %s", calls[r.ID].Method, r.ID, r.Error.Code, r.Error.Message)
		}
		out[r.ID] = r.Result
	}
	return out, nil
}

func (c *rpcClient) call(wallet, method string, params ...any) (json.RawMessage, error) {
	res, err := c.batch(wallet, []rpcCall{{Method: method, Params: params}})
	if err != nil {
		return nil, err
	}
	return res[0], nil
}

// callInto calls a node method and decodes the result into out.
func (c *rpcClient) callInto(out any, method string, params ...any) error {
	raw, err := c.call("", method, params...)
	if err != nil {
		return err
	}
	return json.Unmarshal(raw, out)
}
