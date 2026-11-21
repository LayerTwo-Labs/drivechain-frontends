package daemon

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"runtime"
	"strings"
	"testing"
	"time"

	connectv1 "connectrpc.com/connect"
	pb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/stretchr/testify/require"
)

func TestCoreProxyReusesWalletClients(t *testing.T) {
	core := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{"result":[],"error":null,"id":1}`))
	}))
	t.Cleanup(core.Close)

	ctx := context.Background()
	proxy, err := coreproxy.NewBitcoind(ctx, strings.TrimPrefix(core.URL, "http://"), "user", "pass",
		coreproxy.WithoutInitialConnectionCheck())
	require.NoError(t, err)
	t.Cleanup(func() { proxy.Shutdown(ctx) })

	call := func() {
		_, err := proxy.ListUnspent(ctx, connectv1.NewRequest(&pb.ListUnspentRequest{Wallet: "w"}))
		require.NoError(t, err)
	}
	call()
	before := runtime.NumGoroutine()
	for range 200 {
		call()
	}
	require.Eventually(t, func() bool {
		return runtime.NumGoroutine() < before+20
	}, 5*time.Second, 50*time.Millisecond, "goroutines grew from %d to %d", before, runtime.NumGoroutine())
}

// The answers in testdata are from Bitcoin Core v30.2 on regtest.
func TestCoreProxyReadsPrevoutValueAndBlockFee(t *testing.T) {
	answers := map[string][]byte{}
	for method, file := range map[string]string{
		"getblock":          "testdata/core_getblock_2.json",
		"getrawtransaction": "testdata/core_getrawtransaction_2.json",
	} {
		data, err := os.ReadFile(file)
		require.NoError(t, err)
		answers[method] = data
	}
	core := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			ID     json.RawMessage `json:"id"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		result, ok := answers[req.Method]
		if !ok {
			http.Error(w, "unexpected method "+req.Method, http.StatusBadRequest)
			return
		}
		_, _ = fmt.Fprintf(w, `{"result":%s,"error":null,"id":%s}`, result, req.ID)
	}))
	t.Cleanup(core.Close)

	ctx := context.Background()
	proxy, err := coreproxy.NewBitcoind(ctx, strings.TrimPrefix(core.URL, "http://"), "user", "pass",
		coreproxy.WithoutInitialConnectionCheck())
	require.NoError(t, err)
	t.Cleanup(func() { proxy.Shutdown(ctx) })

	const txid = "bc2cf26234cfe14affb089077edf7a801c6c05681634a6ded49d3a68b35fd920"
	tx, err := proxy.GetRawTransaction(ctx, connectv1.NewRequest(&pb.GetRawTransactionRequest{
		Txid:      txid,
		Verbosity: pb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
	}))
	require.NoError(t, err)
	require.Len(t, tx.Msg.Inputs, 1)
	require.Equal(t, 50.0, tx.Msg.Inputs[0].GetPreviousOutput().GetAmount())
	require.Equal(t, 0.0000276, tx.Msg.Fee)

	block, err := proxy.GetBlock(ctx, connectv1.NewRequest(&pb.GetBlockRequest{
		Hash:      "73c5057d474496f9d7ef0ae89e0997a6a79f98cec155f0b52548015c3c48d9dd",
		Verbosity: pb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO,
	}))
	require.NoError(t, err)
	require.Len(t, block.Msg.Transactions, 2)
	require.Equal(t, txid, block.Msg.Transactions[1].Txid)
	require.Equal(t, 0.0000276, block.Msg.Transactions[1].Fee)
	require.Equal(t, "6a0568656c6c6f", block.Msg.Transactions[1].Outputs[1].GetScriptPubKey().GetHex())
}
