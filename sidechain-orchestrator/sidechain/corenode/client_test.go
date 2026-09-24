package corenode

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
)

type recordedRequest struct {
	path   string
	user   string
	pass   string
	method string
	params json.RawMessage
}

// fakeNode replies with a pre-encoded result per method and records what it was
// asked, so a test can assert on the endpoint and credentials too.
func fakeNode(t *testing.T, results map[string]json.RawMessage) (*httptest.Server, *[]recordedRequest) {
	t.Helper()
	var seen []recordedRequest
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			Params json.RawMessage `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		user, pass, _ := r.BasicAuth()
		seen = append(seen, recordedRequest{path: r.URL.Path, user: user, pass: pass, method: req.Method, params: req.Params})

		result, ok := results[req.Method]
		if !ok {
			t.Fatalf("unexpected method: %s", req.Method)
		}
		w.Header().Set("Content-Type", "application/json")
		require.NoError(t, json.NewEncoder(w).Encode(rpcResponse{Result: result}))
	}))
	return srv, &seen
}

func cookieFile(t *testing.T, contents string) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), ".cookie")
	require.NoError(t, os.WriteFile(path, []byte(contents), 0o600))
	return path
}

func clientFor(t *testing.T, srv *httptest.Server, cookiePath string, opts Options) *Client {
	t.Helper()
	c := New("testchain", "127.0.0.1", 0, cookiePath, opts)
	c.baseURL = srv.URL
	c.http = srv.Client()
	return c
}

func TestBalanceCountsImmatureAsPending(t *testing.T) {
	srv, _ := fakeNode(t, map[string]json.RawMessage{
		"getbalances": json.RawMessage(`{"mine":{"trusted":1.5,"untrusted_pending":0.25,"immature":50}}`),
	})
	defer srv.Close()

	total, available, err := clientFor(t, srv, cookieFile(t, "__cookie__:secret"), Options{}).GetBalance(context.Background())
	require.NoError(t, err)
	// A peg-in lands in the coinbase, so it is immature for a hundred blocks.
	assert.Equal(t, int64(150_000_000), available)
	assert.Equal(t, int64(5_175_000_000), total)
}

// A fork that predates getbalances carries the same split in getwalletinfo.
func TestLegacyBalanceReadsGetWalletInfo(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{
		"getwalletinfo": json.RawMessage(`{"balance":1.0,"unconfirmed_balance":0.25,"immature_balance":0.5}`),
	})
	defer srv.Close()

	client := clientFor(t, srv, cookieFile(t, "__cookie__:secret"), Options{LegacyBalance: true})
	total, available, err := client.GetBalance(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int64(100_000_000), available)
	assert.Equal(t, int64(175_000_000), total)
	require.Len(t, *seen, 1)
	assert.Equal(t, "getwalletinfo", (*seen)[0].method)
}

func TestWalletCallsAreScopedToTheWallet(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{
		"getnewaddress": json.RawMessage(`"bcrt1qexample"`),
		"getblockcount": json.RawMessage(`42`),
	})
	defer srv.Close()

	client := clientFor(t, srv, cookieFile(t, "__cookie__:secret"), Options{})
	ctx := context.Background()
	_, err := client.GetNewAddress(ctx)
	require.NoError(t, err)
	_, err = client.GetBlockCount(ctx)
	require.NoError(t, err)

	require.Len(t, *seen, 2)
	assert.Equal(t, "/wallet/orchestrator", (*seen)[0].path)
	assert.Equal(t, "/", (*seen)[1].path, "node-level RPCs must not be wallet scoped")
}

// A fork that keeps one wallet of its own answers at the root endpoint, and
// takes the address type it documents.
func TestWalletPathAndAddressTypeFollowTheOptions(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{
		"getnewaddress": json.RawMessage(`"XaUJwsK9hTY7m4GdKqvfTELDrtZA9Kokhm"`),
	})
	defer srv.Close()

	client := clientFor(t, srv, cookieFile(t, "__cookie__:secret"), Options{WalletPath: "/", AddressType: "legacy"})
	_, err := client.GetNewAddress(context.Background())
	require.NoError(t, err)

	require.Len(t, *seen, 1)
	assert.Equal(t, "/", (*seen)[0].path)
	assert.JSONEq(t, `["","legacy"]`, string((*seen)[0].params))
}

func TestCallsAuthenticateWithTheCookie(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{"getblockcount": json.RawMessage(`1`)})
	defer srv.Close()

	_, err := clientFor(t, srv, cookieFile(t, "  __cookie__:s3cret\n"), Options{}).GetBlockCount(context.Background())
	require.NoError(t, err)
	require.Len(t, *seen, 1)
	assert.Equal(t, "__cookie__", (*seen)[0].user)
	assert.Equal(t, "s3cret", (*seen)[0].pass)
}

// A missing cookie used to fall through as an unauthenticated call, which Core
// answers with an empty 401 that surfaces as a decode error.
func TestMissingCookieFailsBeforeCalling(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{})
	defer srv.Close()

	_, err := clientFor(t, srv, filepath.Join(t.TempDir(), "absent"), Options{}).GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "read rpc cookie")
	assert.Empty(t, *seen, "must not reach the node without credentials")
}

func TestUnauthenticatedResponseReportsHTTPStatus(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusUnauthorized)
	}))
	defer srv.Close()

	_, err := clientFor(t, srv, cookieFile(t, "user:pass"), Options{}).GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "401")
}

// An RPC error names the chain, so a log with several nodes in it stays
// readable.
func TestRPCErrorNamesTheChain(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"result":null,"error":{"code":-32601,"message":"Method not found"}}`))
	}))
	defer srv.Close()

	_, err := clientFor(t, srv, cookieFile(t, "user:pass"), Options{}).GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "testchain RPC error -32601")
}

// Regtest answers estimatesmartfee with errors and no rate; a zero rate builds
// an unrelayable transaction.
func TestFeeEstimateFallsBackWithoutHistory(t *testing.T) {
	srv, _ := fakeNode(t, map[string]json.RawMessage{
		"estimatesmartfee": json.RawMessage(`{"errors":["Insufficient data or no feerate found"],"blocks":6}`),
	})
	defer srv.Close()

	rate, err := clientFor(t, srv, cookieFile(t, "user:pass"), Options{}).EstimateSmartFee(context.Background())
	require.NoError(t, err)
	assert.Equal(t, FallbackFeeRate, rate)
}

// slowNode answers after delay. release stops a handler still waiting, so a
// test that never gets an answer still returns.
func slowNode(t *testing.T, delay time.Duration) *httptest.Server {
	t.Helper()
	release := make(chan struct{})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		select {
		case <-time.After(delay):
		case <-release:
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"result":true,"error":null}`))
	}))
	t.Cleanup(func() {
		close(release)
		srv.Close()
	})
	return srv
}

// connect_block stores the mainchain ancestors of the block before it answers,
// so it takes a deadline the ordinary calls never get.
func TestConnectBlockOutlastsAnOrdinaryCall(t *testing.T) {
	client := clientFor(t, slowNode(t, 200*time.Millisecond), cookieFile(t, "user:pass"), Options{})
	client.timeout = func(method string) time.Duration {
		if method == "connect_block" {
			return 5 * time.Second
		}
		return 50 * time.Millisecond
	}

	connected, err := Decode[bool](context.Background(), client, "connect_block", []any{"{}", "hash"})
	require.NoError(t, err)
	assert.True(t, connected)

	_, err = client.GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "getblockcount call")
}

// The longer deadline still ends the call. A node that hangs must not hold the
// BMM engine for as long as it runs.
func TestConnectBlockStopsAtItsOwnDeadline(t *testing.T) {
	client := clientFor(t, slowNode(t, time.Hour), cookieFile(t, "user:pass"), Options{})
	client.timeout = func(string) time.Duration { return 100 * time.Millisecond }

	_, err := Decode[bool](context.Background(), client, "connect_block", []any{"{}", "hash"})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "connect_block call")
}

func TestMethodTimeoutBindsTheCoreTransport(t *testing.T) {
	client := New("testchain", "127.0.0.1", 0, "", Options{})
	assert.Equal(t, rpc.ConnectBlockTimeout, client.timeout("connect_block"))
	assert.Equal(t, rpc.CallTimeout, client.timeout("getblockcount"))
}
