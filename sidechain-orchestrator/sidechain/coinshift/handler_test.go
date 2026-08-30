package coinshift

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"sync"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

const testSwapIDHex = "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"

// captureRPC returns a Handler proxying to a server that answers every method
// with result, plus an accessor for the params of the most recent call.
func captureRPC(t *testing.T, result any) (*Handler, func() []any) {
	t.Helper()

	var (
		mu     sync.Mutex
		params []any
	)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Params []any `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Errorf("decode request: %v", err)
			return
		}
		mu.Lock()
		params = req.Params
		mu.Unlock()

		raw, err := json.Marshal(result)
		if err != nil {
			t.Errorf("marshal result: %v", err)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(map[string]any{
			"jsonrpc": "2.0",
			"id":      1,
			"result":  json.RawMessage(raw),
		}); err != nil {
			t.Errorf("encode response: %v", err)
		}
	}))
	t.Cleanup(srv.Close)

	u, err := url.Parse(srv.URL)
	require.NoError(t, err)
	host, portStr, err := net.SplitHostPort(u.Host)
	require.NoError(t, err)
	port, err := strconv.Atoi(portStr)
	require.NoError(t, err)

	lastParams := func() []any {
		mu.Lock()
		defer mu.Unlock()
		return params
	}
	return NewHandler(&sidechain.JSONRPCProxy{Client: rpc.New(host, port)}), lastParams
}

// assertSwapIDParam checks the param is a 32-element JSON array of the id bytes.
func assertSwapIDParam(t *testing.T, param any) {
	t.Helper()

	want, err := hex.DecodeString(testSwapIDHex)
	require.NoError(t, err)

	elems, ok := param.([]any)
	require.True(t, ok, "swap_id should be a JSON array, got %T", param)
	require.Len(t, elems, 32)

	got := make([]byte, len(elems))
	for i, e := range elems {
		n, ok := e.(float64)
		require.True(t, ok, "swap_id element %d should be a number, got %T", i, e)
		got[i] = byte(n)
	}
	assert.Equal(t, want, got)
}

func TestClaimSwapSendsSwapIDBytes(t *testing.T) {
	h, lastParams := captureRPC(t, "txid")

	_, err := h.ClaimSwap(context.Background(), connect.NewRequest(&pb.ClaimSwapRequest{
		SwapId: testSwapIDHex,
	}))
	require.NoError(t, err)

	params := lastParams()
	require.Len(t, params, 2)
	assertSwapIDParam(t, params[0])
}

func TestGetSwapStatusSendsSwapIDBytes(t *testing.T) {
	h, lastParams := captureRPC(t, nil)

	_, err := h.GetSwapStatus(context.Background(), connect.NewRequest(&pb.GetSwapStatusRequest{
		SwapId: testSwapIDHex,
	}))
	require.NoError(t, err)

	params := lastParams()
	require.Len(t, params, 1)
	assertSwapIDParam(t, params[0])
}

func TestUpdateSwapL1TxidSendsSwapIDBytes(t *testing.T) {
	h, lastParams := captureRPC(t, nil)

	_, err := h.UpdateSwapL1Txid(context.Background(), connect.NewRequest(&pb.UpdateSwapL1TxidRequest{
		SwapId:        testSwapIDHex,
		L1TxidHex:     "abcd",
		Confirmations: 3,
	}))
	require.NoError(t, err)

	params := lastParams()
	require.Len(t, params, 3)
	assertSwapIDParam(t, params[0])
}

func TestSwapMethodsRejectInvalidSwapID(t *testing.T) {
	for _, id := range []string{"", "deadbeef", "zz" + testSwapIDHex[2:]} {
		h, _ := captureRPC(t, nil)
		ctx := context.Background()

		_, err := h.ClaimSwap(ctx, connect.NewRequest(&pb.ClaimSwapRequest{SwapId: id}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		_, err = h.GetSwapStatus(ctx, connect.NewRequest(&pb.GetSwapStatusRequest{SwapId: id}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		_, err = h.UpdateSwapL1Txid(ctx, connect.NewRequest(&pb.UpdateSwapL1TxidRequest{SwapId: id}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	}
}
