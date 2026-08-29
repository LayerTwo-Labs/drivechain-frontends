package wallet

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync"
	"sync/atomic"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func outspendServer(t *testing.T, status int, body string) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(status)
		_, _ = w.Write([]byte(body))
	}))
	t.Cleanup(srv.Close)
	return srv
}

func TestEsploraOutspendUnspent(t *testing.T) {
	var mu sync.Mutex
	var paths []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		paths = append(paths, r.URL.Path)
		mu.Unlock()
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"spent":false}`))
	}))
	defer srv.Close()

	c := NewEsploraClient([]string{srv.URL + "/api"}, zerolog.Nop())
	c.minInterval = 0

	out, found, err := c.Outspend(context.Background(), "aa", 1)
	require.NoError(t, err)
	require.True(t, found)
	require.False(t, out.Spent)
	// One server answers both questions, so the two facts agree.
	require.Equal(t, []string{"/api/tx/aa/outspend/1", "/api/tx/aa/status"}, paths)
}

// A 404 from every server means the transaction is not on the chain.
func TestEsploraOutspendNotFoundOnAllServers(t *testing.T) {
	a := outspendServer(t, http.StatusNotFound, "")
	b := outspendServer(t, http.StatusNotFound, "")

	c := NewEsploraClient([]string{a.URL + "/api", b.URL + "/api"}, zerolog.Nop())
	c.minInterval = 0

	_, found, err := c.Outspend(context.Background(), "aa", 0)
	require.NoError(t, err)
	require.False(t, found)
}

// A 404 from one server is not authoritative — the fallback answers.
func TestEsploraOutspendFallsBackPast404(t *testing.T) {
	a := outspendServer(t, http.StatusNotFound, "")
	b := outspendServer(t, http.StatusOK, `{"spent":true,"status":{"confirmed":true}}`)

	c := NewEsploraClient([]string{a.URL + "/api", b.URL + "/api"}, zerolog.Nop())
	c.minInterval = 0

	out, found, err := c.Outspend(context.Background(), "aa", 0)
	require.NoError(t, err)
	require.True(t, found)
	require.True(t, out.Spent)
	require.True(t, out.Status.Confirmed)
}

// A 404 plus a failing fallback is an error, never a cached "absent".
func TestEsploraOutspend404PlusErrorIsError(t *testing.T) {
	a := outspendServer(t, http.StatusNotFound, "")
	b := outspendServer(t, http.StatusBadRequest, "")

	c := NewEsploraClient([]string{a.URL + "/api", b.URL + "/api"}, zerolog.Nop())
	c.minInterval = 0

	_, _, err := c.Outspend(context.Background(), "aa", 0)
	require.Error(t, err)
}

func TestEsploraOutspendServerError(t *testing.T) {
	var calls int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		atomic.AddInt32(&calls, 1)
		w.WriteHeader(http.StatusBadRequest)
	}))
	defer srv.Close()

	c := NewEsploraClient([]string{srv.URL + "/api"}, zerolog.Nop())
	c.minInterval = 0

	_, _, err := c.Outspend(context.Background(), "aa", 0)
	require.Error(t, err)
	require.Equal(t, int32(1), atomic.LoadInt32(&calls))
}

// A rate-limited primary fails over at once — no retry budget burns on it.
func TestEsploraOutspendFailsOverPastRateLimit(t *testing.T) {
	var primaryCalls int32
	a := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		atomic.AddInt32(&primaryCalls, 1)
		w.WriteHeader(http.StatusTooManyRequests)
	}))
	defer a.Close()
	b := outspendServer(t, http.StatusOK, `{"spent":false}`)

	c := NewEsploraClient([]string{a.URL + "/api", b.URL + "/api"}, zerolog.Nop())
	c.minInterval = 0

	out, found, err := c.Outspend(context.Background(), "aa", 0)
	require.NoError(t, err)
	require.True(t, found)
	require.False(t, out.Spent)
	require.Equal(t, int32(1), atomic.LoadInt32(&primaryCalls))
}
