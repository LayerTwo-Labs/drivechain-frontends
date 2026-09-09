package zside

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

func nodeServer(t *testing.T, results map[string]any) *Node {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var request struct {
			ID     json.RawMessage `json:"id"`
			Method string          `json:"method"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&request))
		response := map[string]any{"jsonrpc": "2.0", "id": request.ID}
		if result, ok := results[request.Method]; ok {
			response["result"] = result
		} else {
			response["error"] = map[string]any{"code": -32601, "message": "Method not found"}
		}
		w.Header().Set("Content-Type", "application/json")
		require.NoError(t, json.NewEncoder(w).Encode(response))
	}))
	t.Cleanup(srv.Close)

	host, portText, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return NewNode(host, port)
}

// zSide serves no get_wallet_addresses. A caller that asks for it reads a
// method-not-found error, and every balance the node answers then fails.
func TestZSideListsBothAddressKinds(t *testing.T) {
	node := nodeServer(t, map[string]any{
		"get_transparent_wallet_addresses": []string{"t-one", "t-two"},
		"get_shielded_wallet_addresses":    []string{"z-one"},
	})

	owned, err := sidechain.WalletAddresses(context.Background(), node)
	require.NoError(t, err)
	assert.Equal(t, map[string]bool{"t-one": true, "t-two": true, "z-one": true}, owned)
}

// A node that answers neither method must report the fault rather than an
// empty wallet, which would read as somebody else's money.
func TestZSideAddressesReportTheFault(t *testing.T) {
	node := nodeServer(t, map[string]any{})

	_, err := sidechain.WalletAddresses(context.Background(), node)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "get_transparent_wallet_addresses")
}
