package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	connectv1 "connectrpc.com/connect"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"
)

func TestOnCoreUpCallsOncePerUp(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	states := []bool{false, true, true, false, true}
	var reads atomic.Int32
	connected := func() bool { return states[reads.Add(1)-1] }
	var ups atomic.Int32
	changed := make(chan struct{})
	done := make(chan struct{})
	go func() {
		onCoreUp(ctx, changed, connected, func() { ups.Add(1) })
		close(done)
	}()

	for range states {
		changed <- struct{}{}
	}
	require.Eventually(t, func() bool { return reads.Load() == int32(len(states)) }, time.Second, time.Millisecond)
	cancel()
	<-done
	require.Equal(t, int32(2), ups.Load())
}

func TestCoreProxyKeepsAMissingCookie(t *testing.T) {
	core := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{"result":[],"error":null,"id":1}`))
	}))
	t.Cleanup(core.Close)
	cookie := filepath.Join(t.TempDir(), ".cookie")
	ctx := context.Background()
	newProxy := func() *coreproxy.Bitcoind {
		proxy, err := coreproxy.NewBitcoind(ctx, strings.TrimPrefix(core.URL, "http://"), "", "",
			coreproxy.WithCookiePath(cookie), coreproxy.WithoutInitialConnectionCheck())
		require.NoError(t, err)
		return proxy
	}
	call := func(proxy *coreproxy.Bitcoind) error {
		_, err := proxy.ListWallets(ctx, connectv1.NewRequest(&emptypb.Empty{}))
		return err
	}

	proxy := newProxy()
	require.Error(t, call(proxy), "Core wrote no cookie yet")
	require.NoError(t, os.WriteFile(cookie, []byte("__cookie__:secret"), 0o600))
	require.Error(t, call(proxy), "the proxy keeps the failed read")
	require.NoError(t, call(newProxy()), "a new proxy reads the cookie")
}
