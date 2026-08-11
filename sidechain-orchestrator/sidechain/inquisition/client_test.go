package inquisition

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
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

func clientFor(t *testing.T, srv *httptest.Server, cookiePath string) *Client {
	t.Helper()
	return &Client{baseURL: srv.URL, cookiePath: cookiePath, http: srv.Client()}
}

func TestBalanceCountsImmatureAsPending(t *testing.T) {
	srv, _ := fakeNode(t, map[string]json.RawMessage{
		"getbalances": json.RawMessage(`{"mine":{"trusted":1.5,"untrusted_pending":0.25,"immature":50}}`),
	})
	defer srv.Close()

	total, available, err := clientFor(t, srv, cookieFile(t, "__cookie__:secret")).GetBalance(context.Background())
	require.NoError(t, err)
	// A peg-in lands in the coinbase, so it is immature for a hundred blocks.
	assert.Equal(t, int64(150_000_000), available)
	assert.Equal(t, int64(5_175_000_000), total)
}

func TestWalletCallsAreScopedToTheWallet(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{
		"getnewaddress":     json.RawMessage(`"bcrt1qexample"`),
		"getblockcount":     json.RawMessage(`42`),
		"getblockchaininfo": json.RawMessage(`{"chain":"regtest"}`),
	})
	defer srv.Close()

	client := clientFor(t, srv, cookieFile(t, "__cookie__:secret"))
	ctx := context.Background()
	_, err := client.GetNewAddress(ctx)
	require.NoError(t, err)
	_, err = client.GetBlockCount(ctx)
	require.NoError(t, err)

	require.Len(t, *seen, 2)
	assert.Equal(t, "/wallet/orchestrator", (*seen)[0].path)
	assert.Equal(t, "/", (*seen)[1].path, "node-level RPCs must not be wallet scoped")
}

func TestCallsAuthenticateWithTheCookie(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{"getblockcount": json.RawMessage(`1`)})
	defer srv.Close()

	_, err := clientFor(t, srv, cookieFile(t, "  __cookie__:s3cret\n")).GetBlockCount(context.Background())
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

	_, err := clientFor(t, srv, filepath.Join(t.TempDir(), "absent")).GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "read rpc cookie")
	assert.Empty(t, *seen, "must not reach the node without credentials")
}

func TestUnauthenticatedResponseReportsHTTPStatus(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusUnauthorized)
	}))
	defer srv.Close()

	_, err := clientFor(t, srv, cookieFile(t, "user:pass")).GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "401")
}

func TestWithdrawalsFailLoudly(t *testing.T) {
	client := clientFor(t, httptest.NewServer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) {})), "")
	_, err := client.Withdraw(context.Background(), "bc1qexample", 1, 1, 1)
	require.ErrorIs(t, err, errWithdrawalsUnwired)
}

// Regtest answers estimatesmartfee with errors and no rate; a zero rate builds
// an unrelayable transaction.
func TestFeeEstimateFallsBackWithoutHistory(t *testing.T) {
	srv, _ := fakeNode(t, map[string]json.RawMessage{
		"estimatesmartfee": json.RawMessage(`{"errors":["Insufficient data or no feerate found"],"blocks":6}`),
	})
	defer srv.Close()

	rate, err := clientFor(t, srv, cookieFile(t, "user:pass")).EstimateSmartFee(context.Background())
	require.NoError(t, err)
	assert.Equal(t, FallbackFeeRate, rate)
}
