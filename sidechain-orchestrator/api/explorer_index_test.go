package api

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// A hosted index states no per block deposit total. The page reads each
// block's own rows, so a deposit shows even when ten newer transfers pushed
// it out of the recent list. A block never changes, so it costs one read.
func TestIndexOverviewStatesWhatEachBlockTook(t *testing.T) {
	var asked []string
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		asked = append(asked, r.URL.Path)
		w.Header().Set("Content-Type", "application/json")
		switch {
		case r.URL.Path == "/blocks":
			_, _ = w.Write([]byte(`[
				{"id":"b43","height":43,"tx_count":0,"fees":0,"mainchain_blockhash":"x43"},
				{"id":"b42","height":42,"tx_count":0,"fees":0,"mainchain_blockhash":"x42"}
			]`))
		case r.URL.Path == "/txs/recent":
			// Newer transfers pushed every deposit out of this list.
			_, _ = w.Write([]byte(`[
				{"kind":"transfer","id":"t1","value":5,"status":{"confirmed":true,"block_height":43}}
			]`))
		case r.URL.Path == "/mempool":
			_, _ = w.Write([]byte(`{"count":0,"vsize":0,"total_fee":0}`))
		case r.URL.Path == "/block/b43/activity":
			_, _ = w.Write([]byte(`[
				{"kind":"deposit","id":"d1","value":12300,"status":{"confirmed":true,"block_height":43}},
				{"kind":"deposit","id":"d2","value":200000000,"status":{"confirmed":true,"block_height":43}}
			]`))
		case strings.HasSuffix(r.URL.Path, "/activity"):
			_, _ = w.Write([]byte(`[]`))
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer server.Close()

	src := source{name: "thunder", index: sidechainesplora.New(server.URL), cache: newBlockCache()}
	out, err := indexOverview(context.Background(), src)
	if err != nil {
		t.Fatalf("read the overview: %v", err)
	}
	if len(out.GetBlocks()) != 2 {
		t.Fatalf("the strip holds %d blocks, want 2", len(out.GetBlocks()))
	}

	took := out.GetBlocks()[0]
	if took.GetDepositCount() != 2 {
		t.Errorf("block 43 took %d deposits, want 2", took.GetDepositCount())
	}
	if took.GetDepositValueSats() != 200012300 {
		t.Errorf("block 43 took %d sats, want 200012300", took.GetDepositValueSats())
	}
	if quiet := out.GetBlocks()[1]; quiet.GetDepositCount() != 0 {
		t.Errorf("block 42 took %d deposits, want none", quiet.GetDepositCount())
	}

	// A hosted index never states the value a block moved.
	if took.GetValueKnown() {
		t.Error("an index block claims to know the value it moved")
	}

	var reads int
	for _, path := range asked {
		if strings.HasSuffix(path, "/activity") {
			reads++
		}
	}
	if reads != 2 {
		t.Errorf("the page read %d block activities, want 2", reads)
	}

	// A second read answers from the cache, so the refresh costs nothing.
	asked = nil
	again, err := indexOverview(context.Background(), src)
	if err != nil {
		t.Fatalf("read the overview again: %v", err)
	}
	if again.GetBlocks()[0].GetDepositValueSats() != 200012300 {
		t.Errorf("the second read states %d sats", again.GetBlocks()[0].GetDepositValueSats())
	}
	for _, path := range asked {
		if strings.HasSuffix(path, "/activity") {
			t.Errorf("the second read asked for %s, and the cache holds it", path)
		}
	}
}

// A block that took nothing states nothing.
func TestIndexOverviewLeavesAQuietChainAlone(t *testing.T) {
	var asked []string
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		asked = append(asked, r.URL.Path)
		w.Header().Set("Content-Type", "application/json")
		switch r.URL.Path {
		case "/blocks":
			_, _ = w.Write([]byte(`[{"id":"b43","height":43,"tx_count":1,"fees":900}]`))
		case "/txs/recent":
			_, _ = w.Write([]byte(`[{"kind":"transfer","id":"t1","value":5,"status":{"confirmed":true,"block_height":43}}]`))
		case "/block/b43/activity":
			_, _ = w.Write([]byte(`[{"kind":"transfer","id":"t1","value":5,"status":{"confirmed":true,"block_height":43}}]`))
		case "/mempool":
			_, _ = w.Write([]byte(`{"count":0,"vsize":0,"total_fee":0}`))
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer server.Close()

	src := source{name: "thunder", index: sidechainesplora.New(server.URL), cache: newBlockCache()}
	out, err := indexOverview(context.Background(), src)
	if err != nil {
		t.Fatalf("read the overview: %v", err)
	}
	if out.GetBlocks()[0].GetDepositCount() != 0 {
		t.Error("a chain with no deposit states one")
	}
	if out.GetRecent()[0].GetKind() != pb.Kind_KIND_TRANSFER {
		t.Error("the row reads as something other than a transfer")
	}
}

// An index and a node answer different shapes for one block. A user who
// switches mode must never read one shape out of the other's entry.
func TestBlockCacheKeepsEachSourceApart(t *testing.T) {
	hash := "b43"
	cache := newBlockCache()

	light := source{name: "thunder", origin: "thunder:index:signet", cache: cache}
	full := source{name: "thunder", origin: "thunder:node:signet", cache: cache}
	other := source{name: "thunder", origin: "thunder:node:ecash", cache: cache}

	cache.put(light.cacheKey(hash), &pb.Block{Hash: hash, FeesSats: 900, FeesKnown: true}, nil, true)

	if _, _, _, ok := cache.get(full.cacheKey(hash)); ok {
		t.Error("the node read an index block")
	}
	if _, _, _, ok := cache.get(other.cacheKey(hash)); ok {
		t.Error("one network read another network's block")
	}
	held, _, _, ok := cache.get(light.cacheKey(hash))
	if !ok {
		t.Fatal("the index holds no block of its own")
	}
	if !held.GetFeesKnown() || held.GetFeesSats() != 900 {
		t.Errorf("the index block reads %d sats, known %v", held.GetFeesSats(), held.GetFeesKnown())
	}
}

// A caller keeps writing to the block it gave the cache. The cache holds its
// own copy, so a later write never reaches the next reader.
func TestBlockCacheHoldsNoCallerPointer(t *testing.T) {
	cache := newBlockCache()
	mine := &pb.Block{Hash: "aa", Height: 3}
	rows := []*pb.Activity{{Id: "d1"}}
	cache.put("thunder:index:signet:aa", mine, rows, true)

	// The overview stamps the mainchain fields after the cache read.
	mine.MainchainHeight = 996816
	mine.BlockTime = 9581
	rows[0].BlockTime = 9581

	held, heldRows, _, ok := cache.get("thunder:index:signet:aa")
	if !ok {
		t.Fatal("the cache holds no block")
	}
	if held.GetMainchainHeight() != 0 || held.GetBlockTime() != 0 {
		t.Errorf("the cached block took a later write: %d / %d",
			held.GetMainchainHeight(), held.GetBlockTime())
	}
	if heldRows[0].GetBlockTime() != 0 {
		t.Errorf("the cached row took a later write: %d", heldRows[0].GetBlockTime())
	}
}

// A hosted index states its mainchain height and its timestamp as optional.
// The block page reads both back from the mainchain, as every other path does.
func TestGetBlockResolvesTheMainchainForAnIndex(t *testing.T) {
	const parent = "0000000000000000c75265fa0f8f610411b7f7363d737a3189f81f7b40355e06"
	const carrier = "00000000000000009563c32a953b8a55ed4e6bc23ab4f0078d04651142442497"

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		switch r.URL.Path {
		case "/block/b43":
			// The index names the parent, and states no height or time.
			_, _ = w.Write([]byte(`{"id":"b43","height":43,"tx_count":1,"fees":900,
				"mainchain_blockhash":"` + parent + `"}`))
		case "/block/b43/activity":
			_, _ = w.Write([]byte(`[
				{"kind":"deposit","id":"d1","value":12300,"status":{"confirmed":true,"block_height":43}}
			]`))
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer server.Close()

	handler := &ExplorerHandler{blocks: newBlockCache(), mainchain: newMainchainCache()}
	handler.sources = func(string) (source, error) {
		return source{name: "thunder", index: sidechainesplora.New(server.URL), cache: newBlockCache()}, nil
	}
	handler.SetCoreCaller(func(_ context.Context, method, params, _ string) (json.RawMessage, error) {
		if method != "getblockheader" {
			return nil, fmt.Errorf("no answer for %s", method)
		}
		if strings.Contains(params, parent) {
			return json.RawMessage(`{"height":996816,"time":1000,"nextblockhash":"` + carrier + `"}`), nil
		}
		return json.RawMessage(`{"height":996817,"time":9581}`), nil
	})

	resp, err := handler.GetBlock(context.Background(), connect.NewRequest(&pb.GetBlockRequest{
		Chain: "thunder", Hash: "b43",
	}))
	if err != nil {
		t.Fatalf("read the block: %v", err)
	}
	out := resp.Msg

	if got := out.GetBlock().GetMainchainHeight(); got != 996816 {
		t.Errorf("the parent row names block %d, want 996816", got)
	}
	if got := out.GetBlock().GetBlockTime(); got != 9581 {
		t.Errorf("the block connected at %d, want the carrier time 9581", got)
	}
	if got := out.GetActivity()[0].GetBlockTime(); got != 9581 {
		t.Errorf("the row carries a time of %d, want 9581", got)
	}
	if got := out.GetBlock().GetDepositCount(); got != 1 {
		t.Errorf("the block took %d deposits, want 1", got)
	}
}

// An index row carries its own time. A block with none of its own leaves that
// row alone, rather than writing a zero over it.
func TestStampRowsKeepsATimeTheRowAlreadyHas(t *testing.T) {
	rows := []*pb.Activity{{Id: "d1", BlockTime: 9581}, {Id: "d2"}}

	stampRows(&pb.Block{Hash: "b43"}, rows)
	if rows[0].GetBlockTime() != 9581 {
		t.Errorf("the row lost its time, and reads %d", rows[0].GetBlockTime())
	}

	stampRows(&pb.Block{Hash: "b43", BlockTime: 1000}, rows)
	if rows[0].GetBlockTime() != 1000 || rows[1].GetBlockTime() != 1000 {
		t.Errorf("the rows read %d and %d, want 1000",
			rows[0].GetBlockTime(), rows[1].GetBlockTime())
	}
}

// A handler built as a plain value still answers. Every call reads its source
// through sourceOf, which falls back when no test replaced the seam.
func TestHandlerWithNoSeamAnswersAnError(t *testing.T) {
	handler := &ExplorerHandler{}
	_, err := handler.GetOverview(context.Background(), connect.NewRequest(&pb.GetOverviewRequest{
		Chain: "thunder",
	}))
	if err == nil {
		t.Fatal("a handler with no orchestrator answered a page")
	}
	if got := connect.CodeOf(err); got != connect.CodeFailedPrecondition {
		t.Errorf("the error reads %s, want failed precondition", got)
	}
}

// A source can state one field and leave the other empty. The lookup fills
// only what is missing, and a lookup that answered nothing writes nothing.
func TestResolveMainchainFillsOnlyTheEmptyFields(t *testing.T) {
	const parent = "0000000000000000c75265fa0f8f610411b7f7363d737a3189f81f7b40355e06"

	handler := &ExplorerHandler{mainchain: newMainchainCache()}
	handler.SetCoreCaller(func(_ context.Context, method, params, _ string) (json.RawMessage, error) {
		// The parent reads back, and its carrier does not.
		return json.RawMessage(`{"height":996816,"time":1000}`), nil
	})

	// The index stated the time and left the height empty.
	block := &pb.Block{Hash: "b43", MainchainHash: parent, BlockTime: 9581}
	handler.resolveMainchain(context.Background(), block)

	if got := block.GetBlockTime(); got != 9581 {
		t.Errorf("the block lost its own time, and reads %d", got)
	}
	if got := block.GetMainchainHeight(); got != 996816 {
		t.Errorf("the block names height %d, want 996816", got)
	}
}
