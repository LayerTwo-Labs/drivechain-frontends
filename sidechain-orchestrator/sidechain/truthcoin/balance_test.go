package truthcoin

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

func TestWalletBalanceReadsBitcoinBalance(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string `json:"method"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Errorf("decode request: %v", err)
			return
		}
		if req.Method != "bitcoin_balance" {
			http.Error(w, "Method not found: "+req.Method, http.StatusBadRequest)
			return
		}
		if _, err := w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":{"total_sats":100000,"available_sats":80000}}`)); err != nil {
			t.Errorf("write response: %v", err)
		}
	}))
	t.Cleanup(server.Close)

	host, portText, found := strings.Cut(strings.TrimPrefix(server.URL, "http://"), ":")
	require.True(t, found, "cannot split %q", server.URL)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)

	total, available, err := NewHandler(sidechain.NewJSONRPCProxy(host, port)).WalletBalance(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int64(100_000), total)
	assert.Equal(t, int64(80_000), available)
}
