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
	"sync"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

const (
	testSwapIDHex  = "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"
	testSwapIDJSON = "[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]"
)

type capturedCall struct {
	method string
	params string
}

func stubNode(t *testing.T, result string) (*Handler, func() capturedCall) {
	t.Helper()

	var (
		mu   sync.Mutex
		last capturedCall
	)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			Params json.RawMessage `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Errorf("decode request: %v", err)
			return
		}
		mu.Lock()
		last = capturedCall{method: req.Method, params: string(req.Params)}
		mu.Unlock()

		w.Header().Set("Content-Type", "application/json")
		if _, err := w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`)); err != nil {
			t.Errorf("write response: %v", err)
		}
	}))
	t.Cleanup(srv.Close)

	u, err := url.Parse(srv.URL)
	require.NoError(t, err)
	host, portStr, err := net.SplitHostPort(u.Host)
	require.NoError(t, err)
	port, err := strconv.Atoi(portStr)
	require.NoError(t, err)

	return NewHandler(&sidechain.JSONRPCProxy{Client: rpc.New(host, port)}), func() capturedCall {
		mu.Lock()
		defer mu.Unlock()
		return last
	}
}

func TestCreateSwap(t *testing.T) {
	h, lastCall := stubNode(t, `[`+testSwapIDJSON+`,"abc123"]`)

	l2Recipient := "cs1qrecipient"
	requiredConfirmations := int32(6)
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

	call := lastCall()
	assert.Equal(t, "create_swap", call.method)
	assert.JSONEq(t, `["Signet","bc1qrecipient",1000,"cs1qrecipient",2000,6,10]`, call.params)
	assert.Equal(t, testSwapIDHex, resp.Msg.SwapId)
	assert.Equal(t, "abc123", resp.Msg.Txid)
}

func TestClaimSwapSendsSwapIDBytes(t *testing.T) {
	h, lastCall := stubNode(t, `"txid"`)

	claimer := "cs1qclaimer"
	_, err := h.ClaimSwap(context.Background(), connect.NewRequest(&pb.ClaimSwapRequest{
		SwapId:           testSwapIDHex,
		L2ClaimerAddress: &claimer,
	}))
	require.NoError(t, err)

	call := lastCall()
	assert.Equal(t, "claim_swap", call.method)
	assert.JSONEq(t, `[`+testSwapIDJSON+`,"cs1qclaimer"]`, call.params)
}

func TestGetSwapStatusSendsSwapIDBytes(t *testing.T) {
	h, lastCall := stubNode(t, `null`)

	_, err := h.GetSwapStatus(context.Background(), connect.NewRequest(&pb.GetSwapStatusRequest{
		SwapId: testSwapIDHex,
	}))
	require.NoError(t, err)

	call := lastCall()
	assert.Equal(t, "get_swap_status", call.method)
	assert.JSONEq(t, `[`+testSwapIDJSON+`]`, call.params)
}

func TestUpdateSwapL1TxidSendsSwapIDBytes(t *testing.T) {
	h, lastCall := stubNode(t, `null`)

	_, err := h.UpdateSwapL1Txid(context.Background(), connect.NewRequest(&pb.UpdateSwapL1TxidRequest{
		SwapId:        testSwapIDHex,
		L1TxidHex:     "abcd",
		Confirmations: 3,
	}))
	require.NoError(t, err)

	call := lastCall()
	assert.Equal(t, "update_swap_l1_txid", call.method)
	assert.JSONEq(t, `[`+testSwapIDJSON+`,"abcd",3]`, call.params)
}

func TestSwapMethodsRejectInvalidSwapID(t *testing.T) {
	h, _ := stubNode(t, `null`)
	ctx := context.Background()

	for _, id := range []string{"", "deadbeef", "zz" + strings.Repeat("00", 31)} {
		_, err := h.ClaimSwap(ctx, connect.NewRequest(&pb.ClaimSwapRequest{SwapId: id}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), id)

		_, err = h.GetSwapStatus(ctx, connect.NewRequest(&pb.GetSwapStatusRequest{SwapId: id}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), id)

		_, err = h.UpdateSwapL1Txid(ctx, connect.NewRequest(&pb.UpdateSwapL1TxidRequest{SwapId: id}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), id)
	}
}
