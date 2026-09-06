package coinshift

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// handlerFromServer builds a Handler whose JSON-RPC proxy targets srv.
func handlerFromServer(t *testing.T, srv *httptest.Server) *Handler {
	t.Helper()
	u, err := url.Parse(srv.URL)
	require.NoError(t, err)
	host, port, err := net.SplitHostPort(u.Host)
	require.NoError(t, err)
	portNum, err := strconv.Atoi(port)
	require.NoError(t, err)
	return NewHandler(&sidechain.JSONRPCProxy{Client: rpc.New(host, portNum)})
}

func TestCreateSwap(t *testing.T) {
	var gotMethod string
	var gotParams json.RawMessage
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			Params json.RawMessage `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Fatalf("decode request: %v", err)
		}
		gotMethod, gotParams = req.Method, req.Params

		// Backend returns a (SwapId, Txid) tuple; the swap id is 32 bytes.
		swapID := make([]int, 32)
		swapID[0], swapID[31] = 1, 255
		result, err := json.Marshal([]any{swapID, "abc123"})
		require.NoError(t, err)

		w.Header().Set("Content-Type", "application/json")
		require.NoError(t, json.NewEncoder(w).Encode(rpcResponse{Result: result}))
	}))
	defer srv.Close()

	l2Recipient := "cs1qrecipient"
	requiredConfirmations := int32(6)

	h := handlerFromServer(t, srv)
	resp, err := h.CreateSwap(context.Background(), connect.NewRequest(&pb.CreateSwapRequest{
		L2AmountSats:          2_000,
		L1AmountSats:          1_000,
		L1RecipientAddress:    "bc1qrecipient",
		ParentChain:           "Signet",
		L2Recipient:           &l2Recipient,
		RequiredConfirmations: &requiredConfirmations,
		FeeSats:               10,
	}))
	require.NoError(t, err)

	assert.Equal(t, "create_swap", gotMethod)
	assert.JSONEq(t,
		`["Signet","bc1qrecipient",1000,"cs1qrecipient",2000,6,10]`,
		string(gotParams))
	assert.Equal(t, "01"+strings.Repeat("00", 30)+"ff", resp.Msg.SwapId)
	assert.Equal(t, "abc123", resp.Msg.Txid)
}
