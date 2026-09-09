package rpc

import (
	"context"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func clientFor(t *testing.T, srv *httptest.Server) *Client {
	t.Helper()
	parsed, err := url.Parse(srv.URL)
	require.NoError(t, err)
	host, portText, err := net.SplitHostPort(parsed.Host)
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return New(host, port)
}

// A node that accepts the connection and then answers nothing must not hold the
// caller. The client carries its own deadline, so a caller with no context
// deadline still returns.
func TestCallStopsOnASilentNode(t *testing.T) {
	release := make(chan struct{})
	srv := httptest.NewServer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) {
		<-release
	}))
	defer func() {
		close(release)
		srv.Close()
	}()

	client := clientFor(t, srv)
	client.timeout = func(string) time.Duration { return 100 * time.Millisecond }

	err := client.Call(context.Background(), "balance", nil, nil)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "http post")
}

func TestCallReadsTheResult(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":{"total_sats":7}}`))
	}))
	defer srv.Close()

	var out struct {
		TotalSats int64 `json:"total_sats"`
	}
	require.NoError(t, clientFor(t, srv).Call(context.Background(), "balance", nil, &out))
	assert.Equal(t, int64(7), out.TotalSats)
}

// slowServer answers after delay. release stops a handler still waiting, so a
// test that never gets an answer still returns.
func slowServer(t *testing.T, delay time.Duration) *httptest.Server {
	t.Helper()
	release := make(chan struct{})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		select {
		case <-time.After(delay):
		case <-release:
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":true}`))
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
	client := clientFor(t, slowServer(t, 200*time.Millisecond))
	client.timeout = func(method string) time.Duration {
		if method == "connect_block" {
			return 5 * time.Second
		}
		return 50 * time.Millisecond
	}

	var connected bool
	require.NoError(t, client.Call(context.Background(), "connect_block", []any{"{}", "hash"}, &connected))
	assert.True(t, connected)

	err := client.Call(context.Background(), "getblockcount", nil, nil)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "http post")
}

// The longer deadline still ends the call. A node that hangs must not hold the
// BMM engine for as long as it runs.
func TestConnectBlockStopsAtItsOwnDeadline(t *testing.T) {
	client := clientFor(t, slowServer(t, time.Hour))
	client.timeout = func(string) time.Duration { return 100 * time.Millisecond }

	err := client.Call(context.Background(), "connect_block", []any{"{}", "hash"}, nil)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "http post")
}

func TestCallRawStopsAtTheMethodDeadline(t *testing.T) {
	client := clientFor(t, slowServer(t, time.Hour))
	client.timeout = func(string) time.Duration { return 100 * time.Millisecond }

	_, err := client.CallRaw(context.Background(), "mine", []any{1000})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "http post")
}

// A caller that asks for less than the method allows gets what it asked for.
func TestACallerDeadlineShorterThanTheMethodWins(t *testing.T) {
	client := clientFor(t, slowServer(t, time.Hour))
	client.timeout = func(string) time.Duration { return time.Hour }

	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()

	start := time.Now()
	err := client.Call(ctx, "connect_block", []any{"{}", "hash"}, nil)
	require.Error(t, err)
	assert.Less(t, time.Since(start), 30*time.Second)
}

func TestMethodTimeoutGivesConnectBlockTheLongOne(t *testing.T) {
	assert.Equal(t, ConnectBlockTimeout, MethodTimeout("connect_block"))
	assert.Equal(t, CallTimeout, MethodTimeout("get_block_template"))
	assert.Equal(t, CallTimeout, MethodTimeout("balance"))
	assert.Greater(t, ConnectBlockTimeout, CallTimeout)
}
