package main

import (
	"context"
	"net/http"
	"net/http/httptest"
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
