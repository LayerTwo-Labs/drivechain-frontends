package wallet

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// A gap-limit scan bursts sequential requests and public Esplora (mempool.space)
// answers 429; the client must retry rather than fail the whole scan.
func TestEsploraRetriesOn429(t *testing.T) {
	var calls int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if atomic.AddInt32(&calls, 1) == 1 {
			w.WriteHeader(http.StatusTooManyRequests)
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"address":"abc"}`))
	}))
	defer srv.Close()

	c := NewEsploraClient(srv.URL+"/api", zerolog.Nop())
	c.minInterval = 0

	stats, err := c.AddressStats(context.Background(), "abc")
	require.NoError(t, err)
	require.Equal(t, "abc", stats.Address)
	require.Equal(t, int32(2), atomic.LoadInt32(&calls))
}

// Non-retryable statuses fail immediately without burning the retry budget.
func TestEsploraDoesNotRetryClientError(t *testing.T) {
	var calls int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		atomic.AddInt32(&calls, 1)
		w.WriteHeader(http.StatusBadRequest)
	}))
	defer srv.Close()

	c := NewEsploraClient(srv.URL+"/api", zerolog.Nop())
	c.minInterval = 0

	_, err := c.AddressStats(context.Background(), "abc")
	require.Error(t, err)
	require.Equal(t, int32(1), atomic.LoadInt32(&calls))
}
