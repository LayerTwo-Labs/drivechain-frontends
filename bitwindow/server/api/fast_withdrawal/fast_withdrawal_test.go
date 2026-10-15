package fast_withdrawal

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func withdrawServer(t *testing.T, response string) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "/withdraw", r.URL.Path)
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))

		var req map[string]any
		assert.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		assert.Equal(t, "bc1qtest123", req["withdrawal_destination"])
		assert.Equal(t, 0.001, req["withdrawal_amount"])
		assert.Equal(t, "thunder", req["layer_2_chain_name"])

		_, err := w.Write([]byte(response))
		assert.NoError(t, err)
	}))
	t.Cleanup(srv.Close)
	return srv
}

func TestInitiateSidechainWithdrawal(t *testing.T) {
	t.Parallel()

	newServer := func() *Server {
		return New(engines.NewSidechainMonitorEngine(nil, nil, nil, nil, nil, nil, nil))
	}

	t.Run("success registers the pending withdrawal", func(t *testing.T) {
		t.Parallel()

		srv := withdrawServer(t, `{"status":"success","data":{"hash":"withdrawal-hash-123",`+
			`"server_l2_address":{"info":"thunder1serveraddress456"},"server_fee_sats":5000}}`)
		s := newServer()

		hash, err := s.initiateSidechainWithdrawal(t.Context(), srv.URL, "thunder", 100000, "bc1qtest123")
		require.NoError(t, err)
		assert.Equal(t, "withdrawal-hash-123", hash)

		pending, err := s.monitor.GetPendingFastWithdrawals(t.Context())
		require.NoError(t, err)
		require.Len(t, pending, 1)
		assert.Equal(t, "withdrawal-hash-123", pending[0].Hash)
		assert.Equal(t, "thunder", pending[0].Sidechain)
		assert.Equal(t, "thunder1serveraddress456", pending[0].ServerAddress)
		assert.Equal(t, int64(105000), pending[0].ExpectedAmount)
	})

	t.Run("server error registers nothing", func(t *testing.T) {
		t.Parallel()

		srv := withdrawServer(t, `{"status":"error","error":"insufficient server funds"}`)
		s := newServer()

		hash, err := s.initiateSidechainWithdrawal(t.Context(), srv.URL, "thunder", 100000, "bc1qtest123")
		require.ErrorContains(t, err, "insufficient server funds")
		assert.Empty(t, hash)

		pending, err := s.monitor.GetPendingFastWithdrawals(t.Context())
		require.NoError(t, err)
		assert.Empty(t, pending)
	})

	t.Run("missing fields fail", func(t *testing.T) {
		t.Parallel()

		srv := withdrawServer(t, `{"status":"success","data":{"hash":"test-hash"}}`)

		_, err := newServer().initiateSidechainWithdrawal(t.Context(), srv.URL, "thunder", 100000, "bc1qtest123")
		require.ErrorContains(t, err, "missing server_l2_address")
	})

	t.Run("a fractional fee fails", func(t *testing.T) {
		t.Parallel()

		srv := withdrawServer(t, `{"status":"success","data":{"hash":"test-hash",`+
			`"server_l2_address":{"info":"thunder1serveraddress456"},"server_fee_sats":5000.5}}`)

		_, err := newServer().initiateSidechainWithdrawal(t.Context(), srv.URL, "thunder", 100000, "bc1qtest123")
		require.ErrorContains(t, err, "decode response")
	})

	t.Run("a cancelled context stops the request", func(t *testing.T) {
		t.Parallel()

		ctx, cancel := context.WithCancel(t.Context())
		cancel()

		_, err := newServer().initiateSidechainWithdrawal(ctx, "http://127.0.0.1:1", "thunder", 100000, "bc1qtest123")
		require.ErrorIs(t, err, context.Canceled)
	})
}
