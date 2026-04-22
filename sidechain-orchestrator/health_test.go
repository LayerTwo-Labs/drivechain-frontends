package orchestrator

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// bitcoind during warmup returns HTTP 200 with a JSON-RPC error body
// (code -28 "Loading block index…"). The health check must surface that as
// an error so the monitor can route it to startupError instead of flipping
// connected=true.
func TestJSONRPCHealthCheck_WarmupError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"result":null,"error":{"code":-28,"message":"Loading block index..."},"id":1}`))
	}))
	defer srv.Close()

	h := &JSONRPCHealthCheck{
		URL:     srv.URL,
		Method:  "getblockcount",
		Timeout: 2 * time.Second,
	}

	err := h.Check(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "Loading block index")
}

func TestJSONRPCHealthCheck_Happy(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"result":123,"error":null,"id":1}`))
	}))
	defer srv.Close()

	h := &JSONRPCHealthCheck{
		URL:     srv.URL,
		Method:  "getblockcount",
		Timeout: 2 * time.Second,
	}

	err := h.Check(context.Background())
	require.NoError(t, err)
}
