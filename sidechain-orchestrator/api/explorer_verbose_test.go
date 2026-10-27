package api

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"slices"
	"sync"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// verboseThunderTx is thunder block f660127553ada094 of a live node: one transfer
// that get_block_index names as 5f2931894c234a14, 135 bytes.
const (
	verboseThunderTxid  = "5f2931894c234a14b620c58599a67dfc2701d6fdc3cb56c179066faf708716ac"
	verboseThunderBytes = "0x01000000008e7a7068985e1772cff8cafad4cbed50ab526c249f4c7075e391835e64f7e3f5" +
		"010000008f4a1798ddd266512cdd4ed7b86699ca71715369722385cc1ee3c5e77709974802000000d9c5a342bad8" +
		"bca44612ac14c0fd210f3403649c00a086010000000000a5e9cffb6818608dbaa7fb8629b6665d8dc3fcd300600f" +
		"630000000000"
	verboseThunderOutputs = `"outputs":[{"address":"42y9D63koh2zMtNJqGgdjZbkvTyD","content":{"Value":100000}},` +
		`{"address":"3K4iwC9SPQmFo6U548R9FgbLqjFG","content":{"Value":6492000}}]`
	verboseThunderPlain = `{"header":{"merkle_root":"m1","prev_side_hash":"aa","prev_main_hash":"x1"},` +
		`"body":{"transactions":[{` + verboseThunderOutputs + `}]}}`
	verboseThunderBlock = `{"header":{"merkle_root":"m1","prev_side_hash":"aa","prev_main_hash":"x1"},` +
		`"body":{"transactions":[{` + verboseThunderOutputs + `,"canonical_bytes":"` + verboseThunderBytes + `"}]}}`
)

// thunderTestNode answers JSON-RPC the way a thunder node does. A method it
// does not know answers -32601.
type thunderTestNode struct {
	count   int64
	tip     string
	plain   map[string]string
	verbose map[string]string
	// indexError is the code get_block_index answers with.
	indexError int

	mu     sync.Mutex
	called []string
}

func (n *thunderTestNode) serve(t *testing.T) sidechain.Node {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var request struct {
			ID     json.RawMessage   `json:"id"`
			Method string            `json:"method"`
			Params []json.RawMessage `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			t.Error(err)
			return
		}
		verbose := len(request.Params) == 2 && string(request.Params[1]) == "true"
		n.mu.Lock()
		if verbose {
			n.called = append(n.called, request.Method+" verbose")
		} else {
			n.called = append(n.called, request.Method)
		}
		n.mu.Unlock()

		var hash string
		if len(request.Params) > 0 {
			if err := json.Unmarshal(request.Params[0], &hash); err != nil {
				t.Error(err)
				return
			}
		}
		response := map[string]any{"jsonrpc": "2.0", "id": request.ID}
		notFound := map[string]any{"code": -32601, "message": "Method not found"}
		switch request.Method {
		case "getblockcount":
			response["result"] = n.count
		case "get_best_sidechain_block_hash":
			response["result"] = n.tip
		case "list_mempool":
			response["result"] = json.RawMessage(`[]`)
		case "get_block_index":
			response["error"] = map[string]any{"code": n.indexError, "message": "no block index"}
		case "get_block":
			body := n.plain[hash]
			if verbose {
				body = n.verbose[hash]
			}
			response["result"] = json.RawMessage(body)
		default:
			response["error"] = notFound
		}
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(response); err != nil {
			t.Error(err)
		}
	}))
	t.Cleanup(srv.Close)
	host, port := hostPort(t, srv)
	return sidechain.NewJSONRPCProxy(host, port)
}

func (n *thunderTestNode) calls(method string) int {
	n.mu.Lock()
	defer n.mu.Unlock()
	return len(slices.DeleteFunc(slices.Clone(n.called), func(m string) bool { return m != method }))
}

// Thunder 0.18.2 serves no get_block_index. Its verbose get_block carries the
// canonical bytes, and the txid is the blake3 hash of them.
func TestThunderBlockNamesItsTxidsWithoutABlockIndex(t *testing.T) {
	node := &thunderTestNode{
		indexError: -32601,
		plain:      map[string]string{"bb": verboseThunderPlain},
		verbose:    map[string]string{"bb": verboseThunderBlock},
	}
	src := source{name: "thunder", node: node.serve(t), cache: newBlockCache()}

	block, activity, err := nodeBlock(context.Background(), src, "bb", 7)
	if err != nil {
		t.Fatalf("read the block: %v", err)
	}
	if len(activity) != 1 {
		t.Fatalf("the block lists %d rows, want 1", len(activity))
	}
	row := activity[0]
	if row.GetId() != verboseThunderTxid {
		t.Errorf("txid = %s, want %s", row.GetId(), verboseThunderTxid)
	}
	if row.GetSizeBytes() != 135 {
		t.Errorf("size = %d, want 135", row.GetSizeBytes())
	}
	if row.GetValueSats() != 6592000 {
		t.Errorf("the row paid out %d, want 6592000", row.GetValueSats())
	}
	if row.GetBlockHeight() != 7 || !row.GetConfirmed() {
		t.Errorf("the row names height %d, confirmed %v, want 7 and true",
			row.GetBlockHeight(), row.GetConfirmed())
	}
	if block.GetSizeBytes() != 135 || block.GetValueSats() != 6592000 {
		t.Errorf("the block holds %d bytes and %d sats, want 135 and 6592000",
			block.GetSizeBytes(), block.GetValueSats())
	}
}

// The overview lists a thunder transfer when the node serves no block index.
func TestOverviewListsThunderRowsWithoutABlockIndex(t *testing.T) {
	const genesis = `{"header":{"merkle_root":"m0","prev_main_hash":"x0"},"body":{"transactions":[]}}`
	node := &thunderTestNode{
		count:      2,
		tip:        "bb",
		indexError: -32601,
		plain:      map[string]string{"bb": verboseThunderPlain, "aa": genesis},
		verbose:    map[string]string{"bb": verboseThunderBlock, "aa": genesis},
	}
	src := source{name: "thunder", node: node.serve(t), cache: newBlockCache()}

	out, err := nodeOverview(context.Background(), src)
	if err != nil {
		t.Fatalf("read the overview: %v", err)
	}
	if len(out.GetRecent()) != 1 || out.GetRecent()[0].GetId() != verboseThunderTxid {
		t.Fatalf("recent rows = %v, want the one transfer %s", out.GetRecent(), verboseThunderTxid)
	}
	if len(out.GetBlocks()) != 2 || out.GetBlocks()[0].GetTxCount() != 1 {
		t.Errorf("the strip = %v, want two blocks and one transaction at the tip", out.GetBlocks())
	}
}

// A block index that fails for another reason names no rows. The verbose block
// names no deposits, so a read from it would cache a block without them.
func TestThunderIndexFailureNeverReadsAVerboseBlock(t *testing.T) {
	node := &thunderTestNode{
		indexError: -32000,
		plain:      map[string]string{"bb": verboseThunderPlain},
		verbose:    map[string]string{"bb": verboseThunderBlock},
	}
	src := source{name: "thunder", node: node.serve(t), cache: newBlockCache()}

	_, activity, err := nodeBlock(context.Background(), src, "bb", 7)
	if err != nil {
		t.Fatalf("read the block: %v", err)
	}
	if len(activity) != 0 {
		t.Errorf("the block lists %d rows, want none", len(activity))
	}
	if n := node.calls("get_block verbose"); n != 0 {
		t.Errorf("the read asked for %d verbose blocks, want none", n)
	}
	if _, _, _, ok := src.cache.get(src.cacheKey("bb")); ok {
		t.Error("the cache holds a block that named no rows")
	}
}

// Only a thunder txid hashes the canonical bytes. A zside txid hashes other
// bytes, so that chain never asks for a verbose block.
func TestOtherChainsNeverReadTxidsFromAVerboseBlock(t *testing.T) {
	node := &thunderTestNode{
		indexError: -32601,
		plain:      map[string]string{"bb": verboseThunderPlain},
		verbose:    map[string]string{"bb": verboseThunderBlock},
	}
	src := source{name: "zside", node: node.serve(t), cache: newBlockCache()}

	_, activity, err := nodeBlock(context.Background(), src, "bb", 7)
	if err != nil {
		t.Fatalf("read the block: %v", err)
	}
	if len(activity) != 0 {
		t.Errorf("the block lists %d rows, want none", len(activity))
	}
	if n := node.calls("get_block verbose"); n != 0 {
		t.Errorf("the read asked for %d verbose blocks, want none", n)
	}
}

// A thunder release whose verbose block carries no canonical bytes names no
// txid, and the block stays uncached so a later read can name them.
func TestThunderVerboseBlockWithoutCanonicalBytesNamesNoRows(t *testing.T) {
	node := &thunderTestNode{
		indexError: -32601,
		plain:      map[string]string{"bb": verboseThunderPlain},
		verbose:    map[string]string{"bb": verboseThunderPlain},
	}
	src := source{name: "thunder", node: node.serve(t), cache: newBlockCache()}

	block, activity, err := nodeBlock(context.Background(), src, "bb", 7)
	if err != nil {
		t.Fatalf("read the block: %v", err)
	}
	if len(activity) != 0 {
		t.Errorf("the block lists %d rows, want none", len(activity))
	}
	if block.GetValueSats() != 6592000 {
		t.Errorf("the block paid out %d, want 6592000", block.GetValueSats())
	}
	if _, _, _, ok := src.cache.get(src.cacheKey("bb")); ok {
		t.Error("the cache holds a block that named no rows")
	}
}
