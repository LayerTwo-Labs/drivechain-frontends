package orchestrator

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// bitcoind during warmup returns HTTP 200 with a JSON-RPC error body
// (code -28 "Loading block index…"). The health check must surface that as
// an error so the monitor can route it to startupError instead of flipping
// connected=true.
func TestJSONRPCHealthCheck_WarmupError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"result":null,"error":{"code":-28,"message":"Loading block index..."},"id":1}`))
	}))
	defer srv.Close()

	h := &JSONRPCHealthCheck{
		URL:     srv.URL,
		Method:  "getblockcount",
		Timeout: 2 * time.Second,
	}

	err := h.Check(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "Loading block index")
}

func TestJSONRPCHealthCheck_Happy(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"result":123,"error":null,"id":1}`))
	}))
	defer srv.Close()

	h := &JSONRPCHealthCheck{
		URL:     srv.URL,
		Method:  "getblockcount",
		Timeout: 2 * time.Second,
	}

	err := h.Check(context.Background())
	require.NoError(t, err)
}

// The enforcer reports warmup via Connect error "Validator is not synced"
// while still catching up. The health check must return that message verbatim
// so the connection monitor pattern-matches it into startupError.
func TestConnectRPCHealthCheck_WarmupError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodPost, r.Method)
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusServiceUnavailable)
		_, _ = w.Write([]byte(`{"code":"unavailable","message":"Validator is not synced"}`))
	}))
	defer srv.Close()

	h := &ConnectRPCHealthCheck{
		URL:     srv.URL + "/cusf.mainchain.v1.ValidatorService/GetChainTip",
		Timeout: 2 * time.Second,
	}

	err := h.Check(context.Background())
	require.Error(t, err)
	assert.Equal(t, "Validator is not synced", err.Error())
}

func TestConnectRPCHealthCheck_Happy(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodPost, r.Method)
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"blockHeaderInfo":{"height":"800000"}}`))
	}))
	defer srv.Close()

	h := &ConnectRPCHealthCheck{
		URL:     srv.URL + "/cusf.mainchain.v1.ValidatorService/GetChainTip",
		Timeout: 2 * time.Second,
	}

	err := h.Check(context.Background())
	require.NoError(t, err)
}

// Unparseable HTTP error responses should still surface a useful error so the
// UI doesn't silently hold on to a stale "connected" state.
func TestConnectRPCHealthCheck_OpaqueHTTPError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		_, _ = w.Write([]byte("nginx: bad gateway"))
	}))
	defer srv.Close()

	h := &ConnectRPCHealthCheck{
		URL:     srv.URL + "/cusf.mainchain.v1.ValidatorService/GetChainTip",
		Timeout: 2 * time.Second,
	}

	err := h.Check(context.Background())
	require.Error(t, err)
	assert.True(t, strings.Contains(err.Error(), "HTTP 500"))
}

// Regtest sits at 0/0/IBD=true with no peers. Must report complete so the
// enforcer is allowed to start instead of being stuck disconnected forever.
func TestIsHeaderSyncComplete_RegtestEmpty(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"result":{"chain":"regtest","blocks":0,"headers":0,"initialblockdownload":true},"error":null,"id":1}`))
	}))
	defer srv.Close()

	c := &CoreStatusClient{url: srv.URL}
	complete, err := c.IsHeaderSyncComplete(context.Background())
	require.NoError(t, err)
	assert.True(t, complete, "regtest with 0 blocks and IBD=true must report header-sync complete")
}

// Non-regtest with <10 headers must still report incomplete — guard exists
// to avoid false positives before any peer connects.
func TestIsHeaderSyncComplete_MainnetFewHeaders(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"result":{"chain":"main","blocks":0,"headers":3,"initialblockdownload":true},"error":null,"id":1}`))
	}))
	defer srv.Close()

	c := &CoreStatusClient{url: srv.URL}
	complete, err := c.IsHeaderSyncComplete(context.Background())
	require.NoError(t, err)
	assert.False(t, complete, "mainnet with <10 headers must report incomplete")
}

// Once the user mines a regtest block, IBD flips false. Must keep reporting
// complete so the enforcer stays up.
func TestIsHeaderSyncComplete_RegtestMined(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"result":{"chain":"regtest","blocks":1,"headers":1,"initialblockdownload":false},"error":null,"id":1}`))
	}))
	defer srv.Close()

	c := &CoreStatusClient{url: srv.URL}
	complete, err := c.IsHeaderSyncComplete(context.Background())
	require.NoError(t, err)
	assert.True(t, complete)
}
