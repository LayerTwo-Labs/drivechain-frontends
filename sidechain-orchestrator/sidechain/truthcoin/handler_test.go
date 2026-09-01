package truthcoin

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"reflect"
	"strconv"
	"sync"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/truthcoin/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// schemaMethods returns the JSON-RPC method names the node exposes, taken from
// the OpenAPI snapshot.
func schemaMethods(t *testing.T) map[string]json.RawMessage {
	t.Helper()
	raw, err := os.ReadFile("testdata/openapi_schema.json")
	require.NoError(t, err)

	var schema struct {
		Paths map[string]json.RawMessage `json:"paths"`
	}
	require.NoError(t, json.Unmarshal(raw, &schema))
	require.NotEmpty(t, schema.Paths)
	return schema.Paths
}

type nodeCall struct {
	method string
	params json.RawMessage
}

// nodeRecorder collects the JSON-RPC calls a Handler makes.
type nodeRecorder struct {
	mu    sync.Mutex
	calls []nodeCall
}

func (n *nodeRecorder) add(call nodeCall) {
	n.mu.Lock()
	defer n.mu.Unlock()
	n.calls = append(n.calls, call)
}

func (n *nodeRecorder) all() []nodeCall {
	n.mu.Lock()
	defer n.mu.Unlock()
	return append([]nodeCall(nil), n.calls...)
}

// fakeNode returns a Handler talking to a node that records every call and
// always answers with a null result.
func fakeNode(t *testing.T) (*Handler, *nodeRecorder) {
	t.Helper()
	rec := &nodeRecorder{}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			Params json.RawMessage `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Errorf("decode request: %v", err)
			return
		}
		rec.add(nodeCall{method: req.Method, params: req.Params})
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":null}`))
	}))
	t.Cleanup(srv.Close)

	host, portStr, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	port, err := strconv.Atoi(portStr)
	require.NoError(t, err)
	return NewHandler(sidechain.NewJSONRPCProxy(host, port)), rec
}

// callHandlerMethod invokes exported Handler method i with a zero request.
func callHandlerMethod(h *Handler, i int) error {
	reqType := reflect.TypeOf(h).Method(i).Type.In(2).Elem()
	req := reflect.New(reqType)
	msg := req.Elem().FieldByName("Msg")
	msg.Set(reflect.New(msg.Type().Elem()))

	out := reflect.ValueOf(h).Method(i).Call([]reflect.Value{
		reflect.ValueOf(context.Background()), req,
	})
	err, _ := out[1].Interface().(error)
	return err
}

// TestHandlerMethodsExistOnNode drives every Handler method and fails on any
// JSON-RPC method name the node's schema does not have.
func TestHandlerMethodsExistOnNode(t *testing.T) {
	methods := schemaMethods(t)

	// CallRaw forwards a caller-supplied method name; VoteRegister has no
	// backing RPC and is covered by TestVoteRegisterUnimplemented.
	skip := map[string]bool{"CallRaw": true, "VoteRegister": true}

	ht := reflect.TypeOf(&Handler{})
	for i := 0; i < ht.NumMethod(); i++ {
		name := ht.Method(i).Name
		if skip[name] {
			continue
		}
		t.Run(name, func(t *testing.T) {
			h, rec := fakeNode(t)
			require.NoError(t, callHandlerMethod(h, i))

			calls := rec.all()
			require.NotEmpty(t, calls, "%s issued no JSON-RPC call", name)
			for _, call := range calls {
				assert.Contains(t, methods, call.method, "%s calls a method the node does not expose", name)
			}
		})
	}
}

func TestSlotClaimSendsDecisionClaim(t *testing.T) {
	h, rec := fakeNode(t)

	scaled := true
	lo, hi := int32(0), int32(100)
	_, err := h.SlotClaim(context.Background(), connect.NewRequest(&pb.SlotClaimRequest{
		FeeSats:     1000,
		PeriodIndex: 3,
		SlotIndex:   7,
		Question:    "will it rain?",
		IsStandard:  true,
		IsScaled:    &scaled,
		Min:         &lo,
		Max:         &hi,
	}))
	require.NoError(t, err)

	calls := rec.all()
	require.Len(t, calls, 1)
	assert.Equal(t, "decision_claim", calls[0].method)
	assert.JSONEq(t, `[{
		"decision_type": "scaled",
		"decisions": [{"period_index": 3, "header": "will it rain?"}],
		"tx_fee_sats": 1000,
		"min": 0,
		"max": 100
	}]`, string(calls[0].params))
}

func TestSlotClaimCategorySendsDecisionClaim(t *testing.T) {
	h, rec := fakeNode(t)

	_, err := h.SlotClaimCategory(context.Background(), connect.NewRequest(&pb.SlotClaimCategoryRequest{
		SlotsJson:  `[{"period_index":1,"header":"who wins?"}]`,
		IsStandard: true,
		FeeSats:    500,
	}))
	require.NoError(t, err)

	calls := rec.all()
	require.Len(t, calls, 1)
	assert.Equal(t, "decision_claim", calls[0].method)
	assert.JSONEq(t, `[{
		"decision_type": "category",
		"decisions": [{"period_index": 1, "header": "who wins?"}],
		"tx_fee_sats": 500
	}]`, string(calls[0].params))
}

func TestSlotListSendsDecisionFilter(t *testing.T) {
	h, rec := fakeNode(t)

	period := int32(4)
	status := "Voting"
	_, err := h.SlotList(context.Background(), connect.NewRequest(&pb.SlotListRequest{
		Period: &period,
		Status: &status,
	}))
	require.NoError(t, err)

	calls := rec.all()
	require.Len(t, calls, 1)
	assert.Equal(t, "decision_list", calls[0].method)
	assert.JSONEq(t, `[{"period": 4, "status": "Voting"}]`, string(calls[0].params))
}

func TestVoteRegisterUnimplemented(t *testing.T) {
	h, rec := fakeNode(t)

	_, err := h.VoteRegister(context.Background(), connect.NewRequest(&pb.VoteRegisterRequest{FeeSats: 1000}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeUnimplemented, connect.CodeOf(err))
	assert.Empty(t, rec.all())
}
