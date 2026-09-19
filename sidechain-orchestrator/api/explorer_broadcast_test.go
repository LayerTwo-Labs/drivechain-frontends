package api

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1/explorerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

const broadcastTestID = "ec28b4ae39901902690bbe36a06e5e3088aab1fa2871a82cd70efa91c7b48bfc"

const broadcastTestJSON = `{
	"transaction": {"inputs": [], "outputs": [{"content": {"Value": 9007199254740993}}], "memo": "00"},
	"authorizations": [{"verifying_key": "012345", "signature": "abcdef"}]
}`

func TestExplorerBroadcastKeepsSignedJSON(t *testing.T) {
	for _, chain := range []string{"bitnames", "bitassets", "freebank"} {
		t.Run(chain, func(t *testing.T) {
			node := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				var req struct {
					ID     uint64            `json:"id"`
					Method string            `json:"method"`
					Params []json.RawMessage `json:"params"`
				}
				if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
					t.Errorf("read the node request: %v", err)
					http.Error(w, err.Error(), http.StatusBadRequest)
					return
				}
				if len(req.Params) != 1 {
					t.Errorf("parameter count = %d, want 1", len(req.Params))
					http.Error(w, "invalid parameter count", http.StatusBadRequest)
					return
				}
				var result any
				switch req.Method {
				case "get_authorized_transaction":
					result = json.RawMessage(broadcastTestJSON)
				case "broadcast_transaction":
					var got, want bytes.Buffer
					if err := json.Compact(&got, req.Params[0]); err != nil {
						t.Errorf("read the signed transaction: %v", err)
						http.Error(w, err.Error(), http.StatusBadRequest)
						return
					}
					if err := json.Compact(&want, []byte(broadcastTestJSON)); err != nil {
						t.Errorf("read the test transaction: %v", err)
						http.Error(w, err.Error(), http.StatusInternalServerError)
						return
					}
					if got.String() != want.String() {
						t.Errorf("the signed transaction changed: %s", got.String())
					}
					result = broadcastResult{Txid: broadcastTestID, PeerCount: 3}
				case "rebroadcast_transaction":
					result = broadcastResult{Txid: broadcastTestID, PeerCount: 0}
				default:
					t.Errorf("unexpected node method %s", req.Method)
					http.Error(w, "unexpected node method", http.StatusBadRequest)
					return
				}
				if req.Method != "broadcast_transaction" && string(req.Params[0]) != `"`+broadcastTestID+`"` {
					t.Errorf("the transaction ID changed: %s", req.Params[0])
				}
				if err := json.NewEncoder(w).Encode(map[string]any{
					"jsonrpc": "2.0", "id": req.ID, "result": result,
				}); err != nil {
					t.Errorf("write the node reply: %v", err)
					return
				}
			}))
			defer node.Close()
			host, port := hostPort(t, node)
			h := &ExplorerHandler{sources: func(name string) (source, error) {
				return source{name: name, node: sidechain.NewJSONRPCProxy(host, port)}, nil
			}}
			_, handler := explorerv1connect.NewExplorerServiceHandler(h)
			server := httptest.NewServer(handler)
			defer server.Close()
			client := explorerv1connect.NewExplorerServiceClient(server.Client(), server.URL)
			ctx := context.Background()
			signed, err := client.GetSignedTransaction(ctx, connect.NewRequest(&pb.GetSignedTransactionRequest{
				Chain: chain, Txid: broadcastTestID,
			}))
			require.NoError(t, err)
			require.JSONEq(t, broadcastTestJSON, signed.Msg.SignedTransaction)
			out, err := client.BroadcastTransaction(ctx, connect.NewRequest(&pb.BroadcastTransactionRequest{
				Chain: chain, SignedTransaction: signed.Msg.SignedTransaction,
			}))
			require.NoError(t, err)
			require.Equal(t, broadcastTestID, out.Msg.Txid)
			require.Equal(t, uint32(3), out.Msg.PeerCount)
			repeat, err := client.RebroadcastTransaction(ctx, connect.NewRequest(&pb.RebroadcastTransactionRequest{
				Chain: chain, Txid: " " + broadcastTestID + " ",
			}))
			require.NoError(t, err)
			require.Equal(t, broadcastTestID, repeat.Msg.Txid)
			require.Zero(t, repeat.Msg.PeerCount)
		})
	}
}

func TestExplorerBroadcastRejectsInvalidJSON(t *testing.T) {
	for name, raw := range map[string]string{
		"empty": "", "malformed": "{", "array": "[]", "null": "null", "unsigned": `{"inputs":[]}`,
		"no signatures": `{"transaction":{}}`, "no transaction": `{"authorizations":[]}`,
		"null signatures":   `{"transaction":{},"authorizations":null}`,
		"null transaction":  `{"transaction":null,"authorizations":[]}`,
		"object signatures": `{"transaction":{},"authorizations":{}}`,
	} {
		t.Run(name, func(t *testing.T) {
			node := &recordingNode{}
			h := &ExplorerHandler{sources: func(chain string) (source, error) {
				return source{name: chain, node: node}, nil
			}}
			_, err := h.BroadcastTransaction(context.Background(), connect.NewRequest(&pb.BroadcastTransactionRequest{
				Chain: "bitnames", SignedTransaction: raw,
			}))
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
			require.Empty(t, node.called)
		})
	}
}

func TestExplorerBroadcastRejectsOtherChains(t *testing.T) {
	h := &ExplorerHandler{sources: func(string) (source, error) {
		t.Error("the handler requested an unsupported node")
		return source{}, fmt.Errorf("unsupported node")
	}}
	for _, chain := range []string{"", "thunder", "bbc", "photon"} {
		_, err := h.BroadcastTransaction(context.Background(), connect.NewRequest(&pb.BroadcastTransactionRequest{
			Chain: chain, SignedTransaction: broadcastTestJSON,
		}))
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	}
}

func TestExplorerRebroadcastRejectsInvalidID(t *testing.T) {
	h := &ExplorerHandler{}
	for _, id := range []string{"", "abc", strings.Repeat("z", 64), strings.Repeat("a", 66)} {
		_, err := h.RebroadcastTransaction(context.Background(), connect.NewRequest(&pb.RebroadcastTransactionRequest{
			Chain: "bitnames", Txid: id,
		}))
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		_, err = h.GetSignedTransaction(context.Background(), connect.NewRequest(&pb.GetSignedTransactionRequest{
			Chain: "bitnames", Txid: id,
		}))
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	}
}

func TestExplorerSignedTransactionAbsent(t *testing.T) {
	node := &recordingNode{answers: map[string]string{"get_authorized_transaction": "null"}}
	h := &ExplorerHandler{sources: func(chain string) (source, error) {
		return source{name: chain, node: node}, nil
	}}
	_, err := h.GetSignedTransaction(context.Background(), connect.NewRequest(&pb.GetSignedTransactionRequest{
		Chain: "bitassets", Txid: broadcastTestID,
	}))
	require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
}

func TestExplorerBroadcastReportsNodeErrors(t *testing.T) {
	for _, code := range []int{-32601, -32000} {
		t.Run(fmt.Sprint(code), func(t *testing.T) {
			node := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
				if err := json.NewEncoder(w).Encode(map[string]any{
					"jsonrpc": "2.0", "id": 1,
					"error": map[string]any{"code": code, "message": "invalid signature"},
				}); err != nil {
					t.Errorf("write the node error: %v", err)
					return
				}
			}))
			defer node.Close()
			host, port := hostPort(t, node)
			h := &ExplorerHandler{sources: func(chain string) (source, error) {
				return source{name: chain, node: sidechain.NewJSONRPCProxy(host, port)}, nil
			}}
			_, err := h.RebroadcastTransaction(context.Background(), connect.NewRequest(&pb.RebroadcastTransactionRequest{
				Chain: "bitnames", Txid: broadcastTestID,
			}))
			if code == -32601 {
				require.Equal(t, connect.CodeUnimplemented, connect.CodeOf(err))
				require.ErrorContains(t, err, "update the sidechain node")
			} else {
				require.ErrorContains(t, err, "invalid signature")
			}
		})
	}
}
