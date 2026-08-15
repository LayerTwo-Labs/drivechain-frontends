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

// fakeCore answers the three RPCs a rollback makes. tips is read one entry per
// getblockcount, so a test can move the tip after the invalidation.
type fakeCore struct {
	tips    []int64
	hashes  map[int64]string
	methods []string
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

	hash, err := rollBackCore(context.Background(), core.start(t), 979000)
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

	_, err := rollBackCore(context.Background(), core.start(t), 979000)
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

	if _, err := rollBackCore(context.Background(), core.start(t), 979000); err == nil {
		t.Fatal("rollBackCore reported success with an unchanged tip")
	}
}
