package elements

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeRPC returns an httptest.Server that replies with a pre-encoded result per
// JSON-RPC method.
func fakeRPC(t *testing.T, handlers map[string]json.RawMessage) *httptest.Server {
	t.Helper()
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req rpcRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Fatalf("decode request: %v", err)
		}
		result, ok := handlers[req.Method]
		if !ok {
			t.Fatalf("unexpected method: %s", req.Method)
		}
		w.Header().Set("Content-Type", "application/json")
		require.NoError(t, json.NewEncoder(w).Encode(rpcResponse{Result: result}))
	}))
}

func clientFromServer(srv *httptest.Server) *Client {
	return &Client{baseURL: srv.URL, http: srv.Client()}
}

func TestGetNewAddress(t *testing.T) {
	srv := fakeRPC(t, map[string]json.RawMessage{"getnewaddress": json.RawMessage(`"el1qexampleaddr"`)})
	defer srv.Close()

	addr, err := clientFromServer(srv).GetNewAddress(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "el1qexampleaddr", addr)
}

func TestGetPeginAddress(t *testing.T) {
	srv := fakeRPC(t, map[string]json.RawMessage{
		"getpeginaddress": json.RawMessage(`{"mainchain_address":"tb1qmain","claim_script":"0014abcd"}`),
	})
	defer srv.Close()

	pa, err := clientFromServer(srv).GetPeginAddress(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "tb1qmain", pa.MainchainAddress)
	assert.Equal(t, "0014abcd", pa.ClaimScript)
}

func TestSendToMainchain(t *testing.T) {
	srv := fakeRPC(t, map[string]json.RawMessage{
		"sendtomainchain": json.RawMessage(`{"txid":"deadbeef","bitcoin_address":"tb1qmain"}`),
	})
	defer srv.Close()

	txid, err := clientFromServer(srv).SendToMainchain(context.Background(), "tb1qmain", 0.01)
	require.NoError(t, err)
	assert.Equal(t, "deadbeef", txid)
}

func TestGetBlockCount(t *testing.T) {
	srv := fakeRPC(t, map[string]json.RawMessage{"getblockcount": json.RawMessage("1234")})
	defer srv.Close()

	count, err := clientFromServer(srv).GetBlockCount(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int64(1234), count)
}

// Elements getbalance returns a per-asset map; the policy asset converts to sats.
func TestGetBalancePerAssetMap(t *testing.T) {
	srv := fakeRPC(t, map[string]json.RawMessage{"getbalance": json.RawMessage(`{"bitcoin":1.5}`)})
	defer srv.Close()

	bal, err := clientFromServer(srv).GetBalance(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int64(150_000_000), bal.TotalSats)
	assert.Equal(t, int64(150_000_000), bal.AvailableSats)
}

func TestGetBalanceMissingPolicyAsset(t *testing.T) {
	srv := fakeRPC(t, map[string]json.RawMessage{"getbalance": json.RawMessage(`{"someasset":1.0}`)})
	defer srv.Close()

	_, err := clientFromServer(srv).GetBalance(context.Background())
	require.Error(t, err)
}

func TestRPCError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"result":null,"error":{"code":-28,"message":"loading wallet"}}`))
	}))
	defer srv.Close()

	_, err := clientFromServer(srv).GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "loading wallet")
}
