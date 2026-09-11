package sidechain

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
)

// chainServer answers a tip and the blocks under it. A nil blocks map fails
// every get_block.
func chainServer(t *testing.T, tip string, blocks map[string]string) *JSONRPCProxy {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string   `json:"method"`
			Params []string `json:"params"`
		}
		assert.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		w.Header().Set("Content-Type", "application/json")
		result := tip
		if req.Method == "get_block" {
			if blocks == nil {
				_, err := w.Write([]byte(`{"jsonrpc":"2.0","id":1,"error":{"code":-32603,"message":"archive read failed"}}`))
				assert.NoError(t, err)
				return
			}
			result = blocks[req.Params[0]]
		}
		_, err := w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`))
		assert.NoError(t, err)
	}))
	t.Cleanup(srv.Close)
	host, portText, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return NewJSONRPCProxy(host, port)
}

var nestedChain = map[string]string{
	"d": `{"header":{"prev_side_hash":"c"},"body":{}}`,
	"c": `{"header":{"prev_side_hash":"b"},"body":{}}`,
	"b": `{"header":{"prev_side_hash":"a"},"body":{}}`,
	"a": `{"header":{"prev_side_hash":null},"body":{}}`,
}

var flatChain = map[string]string{
	"d": `{"prev_side_hash":"c","height":3}`,
	"c": `{"prev_side_hash":"b","height":2}`,
	"b": `{"prev_side_hash":"a","height":1}`,
	"a": `{"prev_side_hash":null,"height":0}`,
}

func TestChainHoldsTheTip(t *testing.T) {
	held, err := chainServer(t, `"d"`, nestedChain).ChainHolds(context.Background(), "d", 11)
	require.NoError(t, err)
	assert.True(t, held)
}

func TestChainHoldsABlockUnderANestedHeader(t *testing.T) {
	held, err := chainServer(t, `"d"`, nestedChain).ChainHolds(context.Background(), "a", 11)
	require.NoError(t, err)
	assert.True(t, held)
}

func TestChainHoldsABlockUnderAFlatHeader(t *testing.T) {
	held, err := chainServer(t, `"d"`, flatChain).ChainHolds(context.Background(), "a", 11)
	require.NoError(t, err)
	assert.True(t, held)
}

func TestChainHoldsStopsAtTheDepth(t *testing.T) {
	held, err := chainServer(t, `"d"`, nestedChain).ChainHolds(context.Background(), "a", 3)
	require.NoError(t, err)
	assert.False(t, held, "a is 3 blocks under the tip, so a walk of 3 blocks misses it")
}

func TestChainHoldsNothingOnAnEmptyChain(t *testing.T) {
	held, err := chainServer(t, `null`, nestedChain).ChainHolds(context.Background(), "a", 11)
	require.NoError(t, err)
	assert.False(t, held)
}

func TestChainHoldsReportsABlockReadFault(t *testing.T) {
	_, err := chainServer(t, `"d"`, nil).ChainHolds(context.Background(), "a", 11)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "archive read failed")
}
