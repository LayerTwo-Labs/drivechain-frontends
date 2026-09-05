package api

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

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
