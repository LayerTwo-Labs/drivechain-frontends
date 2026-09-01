package bitassets

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"sync"
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
		"bitcoin_balance": BalanceResponse{TotalSats: 100_000, AvailableSats: 80_000},
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
		"get_new_address": "bNxyz123",
	})
	defer srv.Close()

	c := clientFromServer(srv)
	addr, err := c.GetNewAddress(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "bNxyz123", addr)
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

// TestClientMethodsInSchema drives every Client method against a recording
// server and asserts each wire method is a path in the schema snapshot.
func TestClientMethodsInSchema(t *testing.T) {
	var mu sync.Mutex
	var methods []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req rpcRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Errorf("decode request: %v", err)
			return
		}
		mu.Lock()
		methods = append(methods, req.Method)
		mu.Unlock()
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"result":null}`))
	}))
	defer srv.Close()

	c := clientFromServer(srv)
	ctx := context.Background()
	calls := []func(){
		func() { _, _ = c.Balance(ctx) },
		func() { _, _ = c.GetNewAddress(ctx) },
		func() { _, _ = c.GetWalletAddresses(ctx) },
		func() { _, _ = c.GetWalletUTXOs(ctx) },
		func() { _, _ = c.ListUTXOs(ctx) },
		func() { _, _ = c.MyUTXOs(ctx) },
		func() { _, _ = c.Transfer(ctx, "addr", 1, 2, nil) },
		func() { _, _ = c.CreateDeposit(ctx, "addr", 1, 2) },
		func() { _, _ = c.Withdraw(ctx, "addr", 1, 2, 3) },
		func() { _, _ = c.SidechainWealthSats(ctx) },
		func() { _, _ = c.GetBlockCount(ctx) },
		func() { _, _ = c.GetBlock(ctx, "hash") },
		func() { _, _ = c.GetBMMInclusions(ctx, "hash") },
		func() { _, _ = c.GetBestMainchainBlockHash(ctx) },
		func() { _, _ = c.GetBestSidechainBlockHash(ctx) },
		func() { _, _ = c.LatestFailedWithdrawalBundleHeight(ctx) },
		func() { _, _ = c.PendingWithdrawalBundle(ctx) },
		func() { _ = c.ConnectPeer(ctx, "1.2.3.4:8333") },
		func() { _, _ = c.ListPeers(ctx) },
		func() { _, _ = c.GenerateMnemonic(ctx) },
		func() { _ = c.SetSeedFromMnemonic(ctx, "mnemonic") },
		func() { _, _ = c.Mine(ctx, 1) },
		func() { _, _ = c.OpenAPISchema(ctx) },
		func() { _ = c.Stop(ctx) },
	}
	for _, call := range calls {
		call()
	}
	mu.Lock()
	defer mu.Unlock()
	require.Len(t, methods, len(calls))

	raw, err := os.ReadFile("testdata/openapi_schema.json")
	require.NoError(t, err)
	var schema struct {
		Paths map[string]json.RawMessage `json:"paths"`
	}
	require.NoError(t, json.Unmarshal(raw, &schema))

	for _, method := range methods {
		assert.Contains(t, schema.Paths, method, "method not exposed by the bitassets node")
	}
}

func TestNullableResults(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"get_best_mainchain_block_hash":          nil,
		"get_best_sidechain_block_hash":          "deadbeef",
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
