package rpc

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func fakeRPCServer(t *testing.T, handler func(method string, params json.RawMessage) (any, *rpcError)) *Client {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req request
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Fatalf("decode request: %v", err)
		}

		var rawParams json.RawMessage
		if req.Params != nil {
			raw, _ := json.Marshal(req.Params)
			rawParams = raw
		}

		result, rpcErr := handler(req.Method, rawParams)

		resp := map[string]any{
			"jsonrpc": "2.0",
			"id":      req.ID,
		}
		if rpcErr != nil {
			resp["error"] = rpcErr
		} else {
			resp["result"] = result
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
	}))
	t.Cleanup(srv.Close)

	parts := strings.Split(srv.URL, ":")
	port, _ := strconv.Atoi(parts[len(parts)-1])
	host := strings.TrimPrefix(strings.Join(parts[:len(parts)-1], ":"), "http://")
	return New(host, port)
}

func TestCall_ScalarResult(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		assert.Equal(t, "getblockcount", method)
		return 42, nil
	})

	var count int
	err := client.Call(context.Background(), "getblockcount", nil, &count)
	require.NoError(t, err)
	assert.Equal(t, 42, count)
}

func TestCall_StringResult(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		assert.Equal(t, "get_new_address", method)
		return "tb1qtest123", nil
	})

	var addr string
	err := client.Call(context.Background(), "get_new_address", nil, &addr)
	require.NoError(t, err)
	assert.Equal(t, "tb1qtest123", addr)
}

func TestCall_StructResult(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		assert.Equal(t, "balance", method)
		return map[string]any{"total_sats": 100000, "available_sats": 90000}, nil
	})

	var result struct {
		TotalSats     int `json:"total_sats"`
		AvailableSats int `json:"available_sats"`
	}
	err := client.Call(context.Background(), "balance", nil, &result)
	require.NoError(t, err)
	assert.Equal(t, 100000, result.TotalSats)
	assert.Equal(t, 90000, result.AvailableSats)
}

func TestCall_WithPositionalParams(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		assert.Equal(t, "withdraw", method)
		var p []json.RawMessage
		require.NoError(t, json.Unmarshal(params, &p))
		assert.Len(t, p, 4)
		return "txid123", nil
	})

	var txid string
	err := client.Call(context.Background(), "withdraw", []any{"addr", 1000, 100, 50}, &txid)
	require.NoError(t, err)
	assert.Equal(t, "txid123", txid)
}

func TestCall_WithNamedParams(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		assert.Equal(t, "create_deposit", method)
		var p map[string]any
		require.NoError(t, json.Unmarshal(params, &p))
		assert.Equal(t, "myaddr", p["address"])
		return "dep_txid", nil
	})

	var txid string
	err := client.Call(context.Background(), "create_deposit", map[string]any{
		"address":    "myaddr",
		"value_sats": 50000,
		"fee_sats":   1000,
	}, &txid)
	require.NoError(t, err)
	assert.Equal(t, "dep_txid", txid)
}

func TestCall_RPCError(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		return nil, &rpcError{Code: -32601, Message: "Method not found"}
	})

	err := client.Call(context.Background(), "nonexistent", nil, nil)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "Method not found")
}

func TestCall_NilOutput(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		return nil, nil
	})

	err := client.Call(context.Background(), "stop", nil, nil)
	require.NoError(t, err)
}

func TestCallRaw_ReturnsRawJSON(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		return map[string]any{"key": "value", "nested": map[string]any{"a": 1}}, nil
	})

	raw, err := client.CallRaw(context.Background(), "some_method", nil)
	require.NoError(t, err)

	var parsed map[string]any
	require.NoError(t, json.Unmarshal(raw, &parsed))
	assert.Equal(t, "value", parsed["key"])
}

func TestCallRaw_RPCError(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		return nil, &rpcError{Code: -100, Message: "no bundle"}
	})

	_, err := client.CallRaw(context.Background(), "pending_withdrawal_bundle", nil)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "no bundle")
}

func TestCall_ContextCancellation(t *testing.T) {
	client := fakeRPCServer(t, func(method string, params json.RawMessage) (any, *rpcError) {
		return 1, nil
	})

	ctx, cancel := context.WithCancel(context.Background())
	cancel()

	err := client.Call(ctx, "getblockcount", nil, nil)
	require.Error(t, err)
}
