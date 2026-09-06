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
	client.http.Timeout = 100 * time.Millisecond

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
