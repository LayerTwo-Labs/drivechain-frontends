package thunder

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// A node the handler cannot reach surfaces an error. Answering an empty
// history would read as "you own nothing", which is worse than a failure.
func TestListTransactionsReportsAnUnreachableNode(t *testing.T) {
	h := NewHandlerWithIndex(sidechain.NewJSONRPCProxy("127.0.0.1", 1), "")
	_, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err == nil {
		t.Fatal("want an error from an unreachable node, got none")
	}
}

// With an index the handler asks the node for its addresses, then reads the
// history for each one.
func TestListTransactionsReadsTheIndex(t *testing.T) {
	node := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			ID     any    `json:"id"`
			Method string `json:"method"`
		}
		_ = json.NewDecoder(r.Body).Decode(&req)
		if req.Method != "get_wallet_addresses" {
			http.Error(w, "unexpected method "+req.Method, http.StatusBadRequest)
			return
		}
		_ = json.NewEncoder(w).Encode(map[string]any{
			"jsonrpc": "2.0", "id": req.ID, "result": []string{"alice"},
		})
	}))
	defer node.Close()

	index := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/address/alice/txs":
			_, _ = w.Write([]byte(`[{"txid":"aa","fee":120,
				"vin":[],"vout":[{"scriptpubkey_address":"alice","value":7000}],
				"status":{"confirmed":true,"block_height":5,"block_time":99}}]`))
		case "/address/alice/txs/chain/aa", "/address/alice/deposits":
			_, _ = w.Write([]byte(`[]`))
		case "/blocks/tip/height":
			_, _ = w.Write([]byte(`12`))
		default:
			http.Error(w, "not found", http.StatusNotFound)
		}
	}))
	defer index.Close()

	host, port := splitHostPort(t, node.URL)
	h := NewHandlerWithIndex(sidechain.NewJSONRPCProxy(host, port), index.URL)

	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list transactions: %v", err)
	}
	if len(resp.Msg.Transactions) != 1 {
		t.Fatalf("got %d transactions, want 1", len(resp.Msg.Transactions))
	}
	got := resp.Msg.Transactions[0]
	if got.Txid != "aa" || got.ValueSats != 7000 || got.FeeSats != 120 {
		t.Errorf("transaction = %+v", got)
	}
	if got.BlockHeight != 5 || !got.Confirmed {
		t.Errorf("status = height %d confirmed %v", got.BlockHeight, got.Confirmed)
	}
	// The tip travels with the history, so a light caller counts confirmations
	// without a node of its own.
	if resp.Msg.TipHeight != 12 {
		t.Errorf("tip height = %d, want 12", resp.Msg.TipHeight)
	}
}

func splitHostPort(t *testing.T, rawURL string) (string, int) {
	t.Helper()
	trimmed := strings.TrimPrefix(rawURL, "http://")
	parts := strings.Split(trimmed, ":")
	if len(parts) != 2 {
		t.Fatalf("cannot split %q", rawURL)
	}
	var port int
	for _, r := range parts[1] {
		port = port*10 + int(r-'0')
	}
	return parts[0], port
}
