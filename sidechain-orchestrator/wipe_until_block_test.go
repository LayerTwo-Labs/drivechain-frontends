package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

// fakeCore answers the RPCs a rollback makes. tips is read one entry per
// getblockcount, so a test can move the tip after the invalidation.
type fakeCore struct {
	tips    []int64
	hashes  map[int64]string
	methods []string
	// headers answers getblockheader by hash: height and confirmations.
	headers map[string][2]int64
	// parents answers getblockheader by hash with a previousblockhash.
	parents map[string]string
}

func (f *fakeCore) start(t *testing.T) *CoreStatusClient {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string            `json:"method"`
			Params []json.RawMessage `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Errorf("decode rpc request: %v", err)
			return
		}
		f.methods = append(f.methods, req.Method)

		var result string
		switch req.Method {
		case "getblockcount":
			result = fmt.Sprintf("%d", f.tips[0])
			if len(f.tips) > 1 {
				f.tips = f.tips[1:]
			}
		case "getblockhash":
			var height int64
			if err := json.Unmarshal(req.Params[0], &height); err != nil {
				t.Errorf("decode getblockhash height: %v", err)
				return
			}
			hash, ok := f.hashes[height]
			if !ok {
				t.Errorf("no block hash at height %d", height)
				return
			}
			result = `"` + hash + `"`
		case "getblockheader":
			var hash string
			if err := json.Unmarshal(req.Params[0], &hash); err != nil {
				t.Errorf("decode getblockheader hash: %v", err)
				return
			}
			if parent, ok := f.parents[hash]; ok {
				result = fmt.Sprintf(`{"previousblockhash":%q}`, parent)
				break
			}
			header, ok := f.headers[hash]
			if !ok {
				http.Error(w, `{"result":null,"error":{"code":-5,"message":"Block not found"}}`, http.StatusOK)
				return
			}
			result = fmt.Sprintf(`{"height":%d,"confirmations":%d}`, header[0], header[1])
		case "invalidateblock":
			result = "null"
		default:
			t.Errorf("unexpected rpc method %q", req.Method)
			return
		}
		_, _ = w.Write([]byte(`{"result":` + result + `,"error":null,"id":"test"}`))
	}))
	t.Cleanup(srv.Close)

	return &CoreStatusClient{url: srv.URL}
}

func TestRollBackCoreInvalidatesTheBlockAboveTheHeight(t *testing.T) {
	core := &fakeCore{
		tips:   []int64{979472, 979000},
		hashes: map[int64]string{979001: "0000000000000000000abc"},
	}

	hash, err := rollBackCore(context.Background(), core.start(t), 979000, "")
	if err != nil {
		t.Fatalf("rollBackCore: %v", err)
	}
	if hash != "0000000000000000000abc" {
		t.Errorf("hash = %q, want the block at 979001", hash)
	}
	if got := strings.Join(core.methods, ","); got != "getblockcount,getblockhash,invalidateblock,getblockcount" {
		t.Errorf("rpc calls = %s", got)
	}
}

func TestRollBackCoreRejectsAHeightAtOrAboveTheTip(t *testing.T) {
	core := &fakeCore{tips: []int64{979000}}

	_, err := rollBackCore(context.Background(), core.start(t), 979000, "")
	if err == nil {
		t.Fatal("rollBackCore accepted the tip height, want an error")
	}
	if len(core.methods) != 1 {
		t.Errorf("rpc calls = %v, want the tip read alone", core.methods)
	}
}

// A tip that does not move means Core kept the branch, so the caller must not
// go on to rebuild the enforcer against a chain that never rolled back.
func TestRollBackCoreFailsWhenTheTipDoesNotMove(t *testing.T) {
	core := &fakeCore{
		tips:   []int64{979472, 979472},
		hashes: map[int64]string{979001: "0000000000000000000abc"},
	}

	if _, err := rollBackCore(context.Background(), core.start(t), 979000, ""); err == nil {
		t.Fatal("rollBackCore reported success with an unchanged tip")
	}
}

func TestResolveRollbackHeightReadsTheHeightOfAHash(t *testing.T) {
	const hash = "0000000000000000000abc"
	core := &fakeCore{headers: map[string][2]int64{hash: {979000, 473}}}

	got, err := resolveRollbackHeight(context.Background(), core.start(t), RollbackTarget{Hash: hash})
	if err != nil {
		t.Fatalf("resolveRollbackHeight: %v", err)
	}
	if got != 979000 {
		t.Errorf("height = %d, want 979000", got)
	}
}

// A hash off the active chain names no height to keep, so rolling back to it
// would land the node on a branch the user never asked for.
func TestResolveRollbackHeightRejectsAHashOffTheChain(t *testing.T) {
	const hash = "0000000000000000000dead"
	core := &fakeCore{headers: map[string][2]int64{hash: {979000, -1}}}

	if _, err := resolveRollbackHeight(context.Background(), core.start(t), RollbackTarget{Hash: hash}); err == nil {
		t.Fatal("resolveRollbackHeight accepted a block off the active chain")
	}
}

func TestResolveRollbackHeightRefusesBothInputs(t *testing.T) {
	core := &fakeCore{}
	target := RollbackTarget{Height: 979000, Hash: "0000000000000000000abc"}

	if _, err := resolveRollbackHeight(context.Background(), core.start(t), target); err == nil {
		t.Fatal("resolveRollbackHeight accepted a height and a hash together")
	}
}

func TestResolveRollbackHeightPassesAPlainHeight(t *testing.T) {
	core := &fakeCore{}

	got, err := resolveRollbackHeight(context.Background(), core.start(t), RollbackTarget{Height: 979000})
	if err != nil {
		t.Fatalf("resolveRollbackHeight: %v", err)
	}
	if got != 979000 {
		t.Errorf("height = %d, want 979000", got)
	}
	if len(core.methods) != 0 {
		t.Errorf("rpc calls = %v, want none for a plain height", core.methods)
	}
}

// A reorg can put another block at the height between the header read and the
// invalidation, and its child is not the block the caller named.
func TestRollBackCoreRefusesWhenTheNamedBlockMoved(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979472, 979000},
		hashes:  map[int64]string{979001: "0000000000000000000abc"},
		headers: map[string][2]int64{},
		parents: map[string]string{"0000000000000000000abc": "0000000000000000000fff"},
	}

	_, err := rollBackCore(context.Background(), core.start(t), 979000, "0000000000000000000eee")
	if err == nil {
		t.Fatal("rollBackCore invalidated a block whose parent is not the named one")
	}
}

// Core takes an upper case hash but answers in lower case, so a hash the CLI
// and the UI both accept must reach the comparison in Core's own form.
func TestRollbackTargetNormalizesTheHash(t *testing.T) {
	target := RollbackTarget{Hash: "  0000000000000000000ABC  "}

	if got := target.normalized().Hash; got != "0000000000000000000abc" {
		t.Errorf("normalized hash = %q, want the trimmed lower case form", got)
	}
}
