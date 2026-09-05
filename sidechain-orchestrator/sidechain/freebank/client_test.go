package freebank

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
		"getwalletinfo": json.RawMessage(`{"balance":1.0,"unconfirmed_balance":0.25,"immature_balance":0.5}`),
	})
	defer srv.Close()

	total, available, err := clientFor(t, srv, cookieFile(t, "__cookie__:secret")).GetBalance(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int64(175_000_000), total)
	assert.Equal(t, int64(100_000_000), available)
}

// A legacy-wallet fork keeps the one wallet it creates itself, so wallet RPCs
// go to the root endpoint, and addresses are asked for as legacy P2PKH.
func TestWalletCallsUseTheRootEndpointAndLegacyAddresses(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{
		"getnewaddress": json.RawMessage(`"XaUJwsK9hTY7m4GdKqvfTELDrtZA9Kokhm"`),
		"getblockcount": json.RawMessage(`65`),
	})
	defer srv.Close()

	client := clientFor(t, srv, cookieFile(t, "__cookie__:secret"))
	ctx := context.Background()
	addr, err := client.GetNewAddress(ctx)
	require.NoError(t, err)
	assert.Equal(t, "XaUJwsK9hTY7m4GdKqvfTELDrtZA9Kokhm", addr)
	height, err := client.GetBlockCount(ctx)
	require.NoError(t, err)
	assert.Equal(t, int64(65), height)

	require.Len(t, *seen, 2)
	assert.Equal(t, "/", (*seen)[0].path)
	assert.JSONEq(t, `["","legacy"]`, string((*seen)[0].params))
	assert.Equal(t, "/", (*seen)[1].path)
}

func TestCallsAuthenticateWithTheCookie(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{
		"getblockcount": json.RawMessage(`1`),
	})
	defer srv.Close()

	_, err := clientFor(t, srv, cookieFile(t, "__cookie__:secret")).GetBlockCount(context.Background())
	require.NoError(t, err)
	require.Len(t, *seen, 1)
	assert.Equal(t, "__cookie__", (*seen)[0].user)
	assert.Equal(t, "secret", (*seen)[0].pass)
}

func TestMissingCookieFailsBeforeCalling(t *testing.T) {
	srv, seen := fakeNode(t, map[string]json.RawMessage{
		"getblockcount": json.RawMessage(`1`),
	})
	defer srv.Close()

	_, err := clientFor(t, srv, filepath.Join(t.TempDir(), "absent")).GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Empty(t, *seen, "no request may leave without credentials")
}

// FreeBank blind merge mines with its own refreshbmm ticker and settles
// withdrawals on its own paths; the stubs must say so rather than read as a
// working chain with nothing pending.
func TestMiningAndWithdrawalsReportNotDrivenFromHere(t *testing.T) {
	srv, seen := fakeNode(t, nil)
	defer srv.Close()
	client := clientFor(t, srv, cookieFile(t, "__cookie__:secret"))
	ctx := context.Background()

	_, err := client.GetBlockTemplate(ctx)
	require.ErrorIs(t, err, errBMMExternal)
	_, err = client.Mine(ctx, 1)
	require.ErrorIs(t, err, errBMMExternal)
	_, err = client.Withdraw(ctx, "", 1, 1, 1)
	require.ErrorIs(t, err, errWithdrawalsUnwired)
	_, err = client.GetPendingWithdrawalBundle(ctx)
	require.ErrorIs(t, err, errWithdrawalsUnwired)
	assert.Empty(t, *seen, "stubs must not reach the node")
}
