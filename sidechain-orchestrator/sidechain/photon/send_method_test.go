package photon

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

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/photon/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// sendMethodNode answers only the named methods, and records every method it
// sees. A wrong name gets an error, which is what the real node answers.
func sendMethodNode(t *testing.T, answers map[string]string) (*sidechain.JSONRPCProxy, *[]string) {
	t.Helper()
	seen := []string{}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			Params json.RawMessage `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		entry := req.Method
		if len(req.Params) > 0 {
			entry += " " + string(req.Params)
		}
		seen = append(seen, entry)
		result, ok := answers[req.Method]
		if !ok {
			http.Error(w, "Method not found: "+req.Method, http.StatusBadRequest)
			return
		}
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`))
	}))
	t.Cleanup(server.Close)

	host, portText, found := strings.Cut(strings.TrimPrefix(server.URL, "http://"), ":")
	require.True(t, found, "cannot split %q", server.URL)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return sidechain.NewJSONRPCProxy(host, port), &seen
}

func TestTransferCallsCreateTransfer(t *testing.T) {
	proxy, seen := sendMethodNode(t, map[string]string{"create_transfer": `"txid1"`})

	resp, err := NewHandler(proxy).Transfer(context.Background(),
		connect.NewRequest(&pb.TransferRequest{
			Address: "sidechain-address", AmountSats: 50_000_000, FeeSats: 1000,
		}))
	require.NoError(t, err)
	assert.Equal(t, "txid1", resp.Msg.Txid)
	assert.Equal(t, []string{`create_transfer ["sidechain-address",50000000,1000]`}, *seen)
}

func TestWithdrawCallsCreateWithdrawal(t *testing.T) {
	proxy, seen := sendMethodNode(t, map[string]string{"create_withdrawal": `"txid2"`})

	resp, err := NewHandler(proxy).Withdraw(context.Background(),
		connect.NewRequest(&pb.WithdrawRequest{
			Address: "bc1qexample", AmountSats: 10_000, SideFeeSats: 1000, MainFeeSats: 2000,
		}))
	require.NoError(t, err)
	assert.Equal(t, "txid2", resp.Msg.Txid)
	assert.Equal(t, []string{`create_withdrawal ["bc1qexample",10000,1000,2000]`}, *seen)
}

func TestSidechainWealthCallsSidechainWealth(t *testing.T) {
	proxy, seen := sendMethodNode(t, map[string]string{"sidechain_wealth": `10603007000`})

	resp, err := NewHandler(proxy).GetSidechainWealth(context.Background(),
		connect.NewRequest(&pb.GetSidechainWealthRequest{}))
	require.NoError(t, err)
	assert.Equal(t, int64(10603007000), resp.Msg.Sats)
	assert.Equal(t, []string{"sidechain_wealth"}, *seen)
}
