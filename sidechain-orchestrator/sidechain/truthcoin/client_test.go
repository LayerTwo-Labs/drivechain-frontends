package truthcoin

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeRPC returns an httptest.Server that dispatches on the JSON-RPC method.
func fakeRPC(t *testing.T, handlers map[string]interface{}) *httptest.Server {
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

		resp := rpcResponse{}
		raw, err := json.Marshal(result)
		require.NoError(t, err)
		resp.Result = raw

		w.Header().Set("Content-Type", "application/json")
		require.NoError(t, json.NewEncoder(w).Encode(resp))
	}))
}

func clientFromServer(srv *httptest.Server) *Client {
	return &Client{baseURL: srv.URL, http: srv.Client()}
}

func TestBalance(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"balance": BalanceResponse{TotalSats: 100_000, AvailableSats: 80_000},
	})
	defer srv.Close()

	c := clientFromServer(srv)
	bal, err := c.Balance(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int64(100_000), bal.TotalSats)
	assert.Equal(t, int64(80_000), bal.AvailableSats)
}

func TestGetBlockCount(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"getblockcount": 42,
	})
	defer srv.Close()

	c := clientFromServer(srv)
	count, err := c.GetBlockCount(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 42, count)
}

func TestListPeers(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"list_peers": []PeerInfo{{Address: "1.2.3.4:8333", Status: "connected"}},
	})
	defer srv.Close()

	c := clientFromServer(srv)
	peers, err := c.ListPeers(context.Background())
	require.NoError(t, err)
	require.Len(t, peers, 1)
	assert.Equal(t, "1.2.3.4:8333", peers[0].Address)
}

func TestGetNewAddress(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"get_new_address": "tNxyz123",
	})
	defer srv.Close()

	c := clientFromServer(srv)
	addr, err := c.GetNewAddress(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "tNxyz123", addr)
}

func TestRPCError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"result":null,"error":{"code":-1,"message":"not ready"}}`))
	}))
	defer srv.Close()

	c := clientFromServer(srv)
	_, err := c.GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "not ready")
}

func TestNullableResults(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"get_best_mainchain_block_hash":  nil,
		"get_best_sidechain_block_hash":  "deadbeef",
		"latest_failed_withdrawal_bundle_height": nil,
	})
	defer srv.Close()

	c := clientFromServer(srv)

	mainHash, err := c.GetBestMainchainBlockHash(context.Background())
	require.NoError(t, err)
	assert.Nil(t, mainHash)

	sideHash, err := c.GetBestSidechainBlockHash(context.Background())
	require.NoError(t, err)
	require.NotNil(t, sideHash)
	assert.Equal(t, "deadbeef", *sideHash)

	height, err := c.LatestFailedWithdrawalBundleHeight(context.Background())
	require.NoError(t, err)
	assert.Nil(t, height)
}
