package zside

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// wealthNode answers only sidechain_wealth, and records every method it sees.
// A wrong name gets an error, which is what the real node answers.
func wealthNode(t *testing.T, sats string) (*sidechain.JSONRPCProxy, *[]string) {
	t.Helper()
	seen := []string{}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string `json:"method"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		seen = append(seen, req.Method)
		if req.Method != "sidechain_wealth" {
			http.Error(w, "Method not found: "+req.Method, http.StatusBadRequest)
			return
		}
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + sats + `}`))
	}))
	t.Cleanup(server.Close)

	host, portText, found := strings.Cut(strings.TrimPrefix(server.URL, "http://"), ":")
	require.True(t, found, "cannot split %q", server.URL)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return sidechain.NewJSONRPCProxy(host, port), &seen
}

func TestSidechainWealthCallsSidechainWealth(t *testing.T) {
	proxy, seen := wealthNode(t, "10603007000")

	resp, err := NewHandler(proxy).GetSidechainWealth(context.Background(),
		connect.NewRequest(&pb.GetSidechainWealthRequest{}))
	require.NoError(t, err)
	assert.Equal(t, int64(10603007000), resp.Msg.Sats)
	assert.Equal(t, []string{"sidechain_wealth"}, *seen)
}
