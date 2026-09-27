package wallet

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

// txIndexChain serves getrawtransaction with one RPC code, and reports whether
// the node keeps a synced txindex. The shared fake always answers code -1, and
// the gate under test reads -5.
func txIndexChain(t *testing.T, synced bool, rawTxCode int, rawTxMessage string) coreChain {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string `json:"method"`
		}
		_ = json.NewDecoder(r.Body).Decode(&req)
		switch req.Method {
		case "getindexinfo":
			body := map[string]any{}
			if synced {
				body["txindex"] = map[string]any{"synced": true}
			}
			_ = json.NewEncoder(w).Encode(map[string]any{"result": body})
		default:
			_ = json.NewEncoder(w).Encode(map[string]any{
				"error": map[string]any{"code": rawTxCode, "message": rawTxMessage},
			})
		}
	}))
	t.Cleanup(srv.Close)

	host, portStr, err := net.SplitHostPort(strings.TrimPrefix(srv.URL, "http://"))
	require.NoError(t, err)
	port, err := strconv.Atoi(portStr)
	require.NoError(t, err)
	return coreChain{rpc: NewCoreRPCClient(StaticCoreEndpoint(host, port, "user", "pass"))}
}

// A node with a synced txindex can say a transaction is absent.
func TestCoreReportsAMissingTransaction(t *testing.T) {
	chain := txIndexChain(t, true, coreTxNotFound, "No such mempool or blockchain transaction")

	_, err := chain.GetRawTransaction(context.Background(), "gone")

	require.ErrorIs(t, err, ErrTxNotFound)
}

// Without a txindex, Core answers -5 for a confirmed transaction it cannot
// look up. Reading that as proof stamps a live deposit as dropped.
func TestCoreWithoutATxIndexProvesNothing(t *testing.T) {
	chain := txIndexChain(t, false, coreTxNotFound, "No such mempool or blockchain transaction")

	_, err := chain.GetRawTransaction(context.Background(), "confirmed-elsewhere")

	require.Error(t, err)
	require.NotErrorIs(t, err, ErrTxNotFound)
}

// Any other RPC failure stays what it was, whatever the index says.
func TestCoreKeepsAnOtherFailureGeneric(t *testing.T) {
	chain := txIndexChain(t, true, -28, "Loading block index")

	_, err := chain.GetRawTransaction(context.Background(), "abc")

	require.Error(t, err)
	require.NotErrorIs(t, err, ErrTxNotFound)
}
