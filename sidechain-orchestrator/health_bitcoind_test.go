package orchestrator

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// rpcStub turns httptest.NewServer into a tiny JSON-RPC fake. The Method field
// of every incoming request is dispatched to the supplied handlers — anything
// unknown returns an error so a test that forgets to register a method fails
// loudly instead of silently looking healthy.
type rpcStub struct {
	getblockchaininfo func() (interface{}, *jsonRPCErrorBody)
	getpeerinfo       func() (interface{}, *jsonRPCErrorBody)

	getblockchaininfoCalls atomic.Int32
	getpeerinfoCalls       atomic.Int32
}

type jsonRPCErrorBody struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (s *rpcStub) handler(t *testing.T) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		body, err := io.ReadAll(r.Body)
		require.NoError(t, err)
		var req struct {
			Method string `json:"method"`
		}
		require.NoError(t, json.Unmarshal(body, &req))

		var (
			result interface{}
			rpcErr *jsonRPCErrorBody
		)
		switch req.Method {
		case "getblockchaininfo":
			s.getblockchaininfoCalls.Add(1)
			require.NotNil(t, s.getblockchaininfo, "test forgot to stub getblockchaininfo")
			result, rpcErr = s.getblockchaininfo()
		case "getpeerinfo":
			s.getpeerinfoCalls.Add(1)
			require.NotNil(t, s.getpeerinfo, "test forgot to stub getpeerinfo")
			result, rpcErr = s.getpeerinfo()
		default:
			t.Fatalf("unexpected RPC method: %s", req.Method)
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]interface{}{
			"id":     "health",
			"result": result,
			"error":  rpcErr,
		})
	}
}

func newBitcoindHealthCheck(url string) *BitcoindHealthCheck {
	return &BitcoindHealthCheck{
		URL:     url,
		Timeout: 2 * time.Second,
	}
}

// Past presync, blocks > 0 — the daemon is healthy and getpeerinfo must not
// be polled (avoids extra RPC traffic on every 1s tick).
func TestBitcoindHealthCheck_HealthyWhenBlocksAdvanced(t *testing.T) {
	stub := &rpcStub{
		getblockchaininfo: func() (interface{}, *jsonRPCErrorBody) {
			return map[string]interface{}{"blocks": 100, "headers": 100}, nil
		},
	}
	srv := httptest.NewServer(stub.handler(t))
	defer srv.Close()

	err := newBitcoindHealthCheck(srv.URL).Check(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int32(0), stub.getpeerinfoCalls.Load(), "getpeerinfo must not be called when blocks > 0")
}

// During the regular header-sync phase headers > 0 even if blocks == 0.
// We're past presync so no startup error should be raised.
func TestBitcoindHealthCheck_HealthyWhenHeadersAdvanced(t *testing.T) {
	stub := &rpcStub{
		getblockchaininfo: func() (interface{}, *jsonRPCErrorBody) {
			return map[string]interface{}{"blocks": 0, "headers": 500}, nil
		},
	}
	srv := httptest.NewServer(stub.handler(t))
	defer srv.Close()

	err := newBitcoindHealthCheck(srv.URL).Check(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int32(0), stub.getpeerinfoCalls.Load())
}

// The headline fix: getblockchaininfo reports 0/0 but a peer is feeding us
// headers via the BIP324 presync mechanism. The check must surface that as
// an error message containing "Pre-synchronizing blockheaders" and the peer's
// reported height so the connection monitor can route it to startupError.
func TestBitcoindHealthCheck_PresyncDetected(t *testing.T) {
	stub := &rpcStub{
		getblockchaininfo: func() (interface{}, *jsonRPCErrorBody) {
			return map[string]interface{}{"blocks": 0, "headers": 0}, nil
		},
		getpeerinfo: func() (interface{}, *jsonRPCErrorBody) {
			return []map[string]interface{}{
				{"presynced_headers": 226000},
				{"presynced_headers": -1},
			}, nil
		},
	}
	srv := httptest.NewServer(stub.handler(t))
	defer srv.Close()

	err := newBitcoindHealthCheck(srv.URL).Check(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "Pre-synchronizing blockheaders")
	assert.Contains(t, err.Error(), "226000")
}

// When several peers are mid-presync we report the highest height — that's
// the one closest to the actual chain tip.
func TestBitcoindHealthCheck_PresyncMaxAcrossPeers(t *testing.T) {
	stub := &rpcStub{
		getblockchaininfo: func() (interface{}, *jsonRPCErrorBody) {
			return map[string]interface{}{"blocks": 0, "headers": 0}, nil
		},
		getpeerinfo: func() (interface{}, *jsonRPCErrorBody) {
			return []map[string]interface{}{
				{"presynced_headers": 100000},
				{"presynced_headers": 226000},
				{"presynced_headers": 50000},
			}, nil
		},
	}
	srv := httptest.NewServer(stub.handler(t))
	defer srv.Close()

	err := newBitcoindHealthCheck(srv.URL).Check(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "226000")
	assert.NotContains(t, err.Error(), "100000")
}

// Brand-new node, RPC up, no peers yet. We must NOT raise a fake startup
// error here — that would mark the daemon as still booting indefinitely if
// the user has no internet. Returning nil keeps connected=true and lets the
// existing flow play out naturally.
func TestBitcoindHealthCheck_NoPeersIsHealthy(t *testing.T) {
	stub := &rpcStub{
		getblockchaininfo: func() (interface{}, *jsonRPCErrorBody) {
			return map[string]interface{}{"blocks": 0, "headers": 0}, nil
		},
		getpeerinfo: func() (interface{}, *jsonRPCErrorBody) {
			return []map[string]interface{}{}, nil
		},
	}
	srv := httptest.NewServer(stub.handler(t))
	defer srv.Close()

	err := newBitcoindHealthCheck(srv.URL).Check(context.Background())
	require.NoError(t, err)
}

// Peers connected but none of them are mid-presync (presynced_headers == -1
// is Bitcoin Core's "not in presync" sentinel). Same outcome as no peers:
// don't synthesise a startup error from nothing.
func TestBitcoindHealthCheck_PeersNotInPresyncIsHealthy(t *testing.T) {
	stub := &rpcStub{
		getblockchaininfo: func() (interface{}, *jsonRPCErrorBody) {
			return map[string]interface{}{"blocks": 0, "headers": 0}, nil
		},
		getpeerinfo: func() (interface{}, *jsonRPCErrorBody) {
			return []map[string]interface{}{
				{"presynced_headers": -1},
				{"presynced_headers": -1},
			}, nil
		},
	}
	srv := httptest.NewServer(stub.handler(t))
	defer srv.Close()

	err := newBitcoindHealthCheck(srv.URL).Check(context.Background())
	require.NoError(t, err)
}

// Bitcoin Core's RPC warmup phase (-28) must keep the existing flow: the
// monitor's extractStartupError pulls the message after " - " and routes it
// to startupError. We must not swallow that error in the new check.
func TestBitcoindHealthCheck_WarmupErrorPropagates(t *testing.T) {
	stub := &rpcStub{
		getblockchaininfo: func() (interface{}, *jsonRPCErrorBody) {
			return nil, &jsonRPCErrorBody{Code: -28, Message: "Loading block index..."}
		},
	}
	srv := httptest.NewServer(stub.handler(t))
	defer srv.Close()

	err := newBitcoindHealthCheck(srv.URL).Check(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "Loading block index")
}

// If getpeerinfo errors out (e.g. an older bitcoind that doesn't expose the
// field) we must not crash the health check — fall through and report the
// daemon as connected. Worse to break sync detection than to miss presync.
func TestBitcoindHealthCheck_PeerinfoErrorIsHealthy(t *testing.T) {
	stub := &rpcStub{
		getblockchaininfo: func() (interface{}, *jsonRPCErrorBody) {
			return map[string]interface{}{"blocks": 0, "headers": 0}, nil
		},
		getpeerinfo: func() (interface{}, *jsonRPCErrorBody) {
			return nil, &jsonRPCErrorBody{Code: -32601, Message: "method not found"}
		},
	}
	srv := httptest.NewServer(stub.handler(t))
	defer srv.Close()

	err := newBitcoindHealthCheck(srv.URL).Check(context.Background())
	require.NoError(t, err)
}

// The presync message must be on bitcoind's startup-pattern list so the
// connection monitor classifies it as startupError, not connectionError.
// This guards the contract between BitcoindHealthCheck and ConnectionMonitor.
func TestBitcoindStartupPatterns_MatchesSyntheticPresyncMessage(t *testing.T) {
	msg := "Pre-synchronizing blockheaders, height: 226000"
	matched := false
	for _, p := range bitcoindStartupPatterns {
		if strings.Contains(msg, p) {
			matched = true
			break
		}
	}
	assert.True(t, matched, "bitcoindStartupPatterns must contain a substring that matches %q", msg)
}

// End-to-end through the connection monitor: a checker that returns the
// presync error must land in startupError, not connectionError, and the
// monitor must report connected=false (the daemon isn't actually usable
// yet — same semantics as -28 warmup).
func TestConnectionMonitor_PresyncFlowsToStartupError(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	checker := &startupErrorChecker{errMsg: "Pre-synchronizing blockheaders, height: 226000"}
	mon := NewConnectionMonitor("bitcoind", checker, bitcoindStartupPatterns, testLogger(t))
	mon.testConnection(ctx)

	assert.False(t, mon.Connected(), "presync means RPC is up but chain isn't")
	assert.Empty(t, mon.ConnectionError(), "presync must not be classified as a connection error")
	assert.Contains(t, mon.StartupError(), "Pre-synchronizing blockheaders")
	assert.Contains(t, mon.StartupError(), "226000")
}
