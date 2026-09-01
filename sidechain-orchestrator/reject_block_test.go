package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

// fakeCore answers the RPCs a reject makes. tips is read one entry per
// getblockcount, so a test can move the tip after the invalidation.
type fakeCore struct {
	tips    []int64
	hashes  map[int64]string
	headers map[string]blockHeader
	methods []string
	// params records the argument each call carried, in call order.
	params []string
	// reconsiderNo makes reconsiderblock fail for a transient reason.
	reconsiderNo bool
	// reconsiderUnknown makes reconsiderblock report that Core holds no such
	// block, which is what a wiped datadir looks like.
	reconsiderUnknown bool
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
		if len(req.Params) > 0 {
			f.params = append(f.params, strings.Trim(string(req.Params[0]), `"`))
		} else {
			f.params = append(f.params, "")
		}

		var result string
		switch req.Method {
		case "getblockcount":
			// An empty list stands for a Core that refuses the read.
			if len(f.tips) == 0 {
				http.Error(w, `{"result":null,"error":{"code":-28,"message":"Loading block index"}}`, http.StatusOK)
				return
			}
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
			header, ok := f.headers[hash]
			if !ok {
				http.Error(w, `{"result":null,"error":{"code":-5,"message":"Block not found"}}`, http.StatusOK)
				return
			}
			result = fmt.Sprintf(`{"height":%d,"confirmations":%d,"previousblockhash":%q}`,
				header.Height, header.Confirmations, header.PreviousBlockHash)
		case "reconsiderblock":
			if f.reconsiderUnknown {
				http.Error(w, `{"result":null,"error":{"code":-5,"message":"Block not found"}}`, http.StatusOK)
				return
			}
			if f.reconsiderNo {
				http.Error(w, `{"result":null,"error":{"code":-8,"message":"busy"}}`, http.StatusOK)
				return
			}
			result = "null"
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

const (
	bad    = "000000000000000000000000000000000000000000000000000000000000bad0"
	parent = "000000000000000000000000000000000000000000000000000000000000par0"
	other  = "000000000000000000000000000000000000000000000000000000000000oth0"
)

// The caller names the block to drop, so that exact hash reaches Core. The
// height it sits at names nothing when two branches share it.
func TestRejectBlockInvalidatesTheNamedHash(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979024},
		hashes:  map[int64]string{979024: parent},
		headers: map[string]blockHeader{bad: {Height: 979025, Confirmations: 583, PreviousBlockHash: parent}},
	}

	got, err := rejectBlockOnCore(context.Background(), core.start(t), bad)
	if err != nil {
		t.Fatalf("rejectBlockOnCore: %v", err)
	}
	if got.CoreHeight != 979024 || got.CoreTipHash != parent {
		t.Errorf("tip = %d/%s, want 979024/%s", got.CoreHeight, got.CoreTipHash, parent)
	}
	if got.Outcome != RejectOutcomeParkedOnParent {
		t.Errorf("Outcome = %v, want ParkedOnParent", got.Outcome)
	}
	if calls := strings.Join(core.methods, ","); calls != "getblockheader,invalidateblock,getblockcount,getblockhash" {
		t.Errorf("rpc calls = %s", calls)
	}
	if core.params[1] != bad {
		t.Errorf("invalidateblock got %q, want the named block %q", core.params[1], bad)
	}
}

// Regression: two blocks shared height 979001 on eCash. Rejecting one let
// Core re-org to its sibling at the same height, and the caller has to be told
// that the chain moved sideways rather than down.
func TestRejectBlockReportsASiblingBranch(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979025},
		hashes:  map[int64]string{979025: other},
		headers: map[string]blockHeader{bad: {Height: 979025, Confirmations: 583, PreviousBlockHash: parent}},
	}

	got, err := rejectBlockOnCore(context.Background(), core.start(t), bad)
	if err != nil {
		t.Fatalf("rejectBlockOnCore: %v", err)
	}
	if got.Outcome != RejectOutcomeSwitchedBranch {
		t.Errorf("Outcome = %v, want SwitchedBranch", got.Outcome)
	}
	if got.CoreTipHash != other {
		t.Errorf("tip = %s, want the sibling %s", got.CoreTipHash, other)
	}
}

// Rejecting a block Core already left moves nothing, so the tip differing from
// that block's parent proves only that the two were never related.
func TestRejectBlockReportsNoSwitchForAnInactiveBlock(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979607},
		hashes:  map[int64]string{979607: other},
		headers: map[string]blockHeader{bad: {Height: 979025, Confirmations: -1, PreviousBlockHash: parent}},
	}

	got, err := rejectBlockOnCore(context.Background(), core.start(t), bad)
	if err != nil {
		t.Fatalf("rejectBlockOnCore: %v", err)
	}
	if got.Outcome != RejectOutcomeAlreadyInactive {
		t.Errorf("Outcome = %v, want AlreadyInactive", got.Outcome)
	}
}

// Core keeping the rejected block as its tip means the reject did not take, so
// the caller must not go on to rebuild the enforcer against an unchanged chain.
func TestRejectBlockFailsWhenCoreKeepsTheBlock(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979025},
		hashes:  map[int64]string{979025: bad},
		headers: map[string]blockHeader{bad: {Height: 979025, Confirmations: 583, PreviousBlockHash: parent}},
	}

	if _, err := rejectBlockOnCore(context.Background(), core.start(t), bad); err == nil {
		t.Fatal("rejectBlockOnCore reported success while Core kept the block")
	}
}

func TestRejectBlockRefusesAnEmptyHash(t *testing.T) {
	core := &fakeCore{}

	if _, err := rejectBlockOnCore(context.Background(), core.start(t), "   "); err == nil {
		t.Fatal("rejectBlockOnCore accepted a blank hash")
	}
	if len(core.methods) != 0 {
		t.Errorf("rpc calls = %v, want none for a blank hash", core.methods)
	}
}

func TestRejectBlockRefusesAnUnknownBlock(t *testing.T) {
	core := &fakeCore{headers: map[string]blockHeader{}}

	if _, err := rejectBlockOnCore(context.Background(), core.start(t), bad); err == nil {
		t.Fatal("rejectBlockOnCore accepted a block Core does not have")
	}
	if calls := strings.Join(core.methods, ","); calls != "getblockheader" {
		t.Errorf("rpc calls = %s, want the header read alone", calls)
	}
}

// Core takes an upper case hash but answers in lower case, so a hash pasted
// from a block explorer has to reach the tip comparison in Core's own form.
func TestRejectBlockNormalizesTheHash(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979024},
		hashes:  map[int64]string{979024: parent},
		headers: map[string]blockHeader{bad: {Height: 979025, Confirmations: 583, PreviousBlockHash: parent}},
	}

	if _, err := rejectBlockOnCore(context.Background(), core.start(t), "  "+strings.ToUpper(bad)+"  "); err != nil {
		t.Fatalf("rejectBlockOnCore: %v", err)
	}
	if core.params[0] != bad {
		t.Errorf("getblockheader got %q, want the trimmed lower case form", core.params[0])
	}
}

// A height names no branch: the enforcer can sit at Core's height on the branch
// Core just dropped, or climb past Core while on Core's own chain. Core's
// confirmation count is what tells the two apart.
func TestBlockOnActiveChainReadsCoreNotAHeight(t *testing.T) {
	for _, tc := range []struct {
		name string
		hash string
		want bool
	}{
		{"core's own tip", other, true},
		{"an older block on core's chain", parent, true},
		{"upper case reaches core lower case", strings.ToUpper(parent), true},
		{"a block on the branch core dropped", bad, false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			core := &fakeCore{headers: map[string]blockHeader{
				other:  {Height: 979025, Confirmations: 1},
				parent: {Height: 979024, Confirmations: 2},
				bad:    {Height: 979025, Confirmations: -1},
			}}

			got, err := blockOnActiveChain(context.Background(), core.start(t), tc.hash)
			if err != nil {
				t.Fatalf("blockOnActiveChain: %v", err)
			}
			if got != tc.want {
				t.Errorf("blockOnActiveChain = %v, want %v", got, tc.want)
			}
		})
	}
}

func TestBlockOnActiveChainRefusesAnEmptyHash(t *testing.T) {
	core := &fakeCore{}

	if _, err := blockOnActiveChain(context.Background(), core.start(t), ""); err == nil {
		t.Fatal("blockOnActiveChain accepted a blank hash")
	}
	if len(core.methods) != 0 {
		t.Errorf("rpc calls = %v, want none for a blank hash", core.methods)
	}
}

func TestAcceptBlockClearsTheRejectAndReadsTheTip(t *testing.T) {
	core := &fakeCore{
		tips:   []int64{979607},
		hashes: map[int64]string{979607: other},
	}

	got, err := acceptBlockOnCore(context.Background(), core.start(t), bad)
	if err != nil {
		t.Fatalf("acceptBlockOnCore: %v", err)
	}
	if got.CoreHeight != 979607 || got.CoreTipHash != other {
		t.Errorf("tip = %d/%s, want 979607/%s", got.CoreHeight, got.CoreTipHash, other)
	}
	if calls := strings.Join(core.methods, ","); calls != "reconsiderblock,getblockcount,getblockhash" {
		t.Errorf("rpc calls = %s", calls)
	}
	if core.params[0] != bad {
		t.Errorf("reconsiderblock got %q, want %q", core.params[0], bad)
	}
}

func TestAcceptBlockRefusesAnEmptyHash(t *testing.T) {
	core := &fakeCore{}

	if _, err := acceptBlockOnCore(context.Background(), core.start(t), ""); err == nil {
		t.Fatal("acceptBlockOnCore accepted a blank hash")
	}
	if len(core.methods) != 0 {
		t.Errorf("rpc calls = %v, want none for a blank hash", core.methods)
	}
}

// A boot stream that ends without an error says the start path ran, not that
// the enforcer came back. Reporting a rebuild there leaves the user with an
// enforcer that is both stopped and wiped, and no error to say so.
func TestAwaitEnforcerBootReportsADaemonThatNeverCameBack(t *testing.T) {
	o := newTestOrchestrator(t)

	bootCh := make(chan StartupProgress, 1)
	bootCh <- StartupProgress{Stage: "done", Message: "enforcer started", Done: true}
	close(bootCh)

	err := o.awaitEnforcerBoot(bootCh, time.Second)
	if err == nil {
		t.Fatal("awaitEnforcerBoot reported a restart while the enforcer sat stopped")
	}
	if !strings.Contains(err.Error(), "not running") {
		t.Errorf("err = %v, want the stopped enforcer named", err)
	}
}

func TestAwaitEnforcerBootAcceptsALiveEnforcer(t *testing.T) {
	o := newTestOrchestrator(t)
	enforcerCfg, err := o.getConfig("enforcer")
	if err != nil {
		t.Fatalf("getConfig: %v", err)
	}
	o.process.AdoptProcess(enforcerCfg, 1234)

	bootCh := make(chan StartupProgress, 1)
	bootCh <- StartupProgress{Stage: "done", Done: true}
	close(bootCh)

	if err := o.awaitEnforcerBoot(bootCh, time.Second); err != nil {
		t.Fatalf("awaitEnforcerBoot: %v", err)
	}
}

func TestAwaitEnforcerBootReturnsTheBootFailure(t *testing.T) {
	o := newTestOrchestrator(t)

	bootCh := make(chan StartupProgress, 1)
	bootCh <- StartupProgress{Error: fmt.Errorf("cannot start the enforcer without a payout address")}
	close(bootCh)

	err := o.awaitEnforcerBoot(bootCh, time.Second)
	if err == nil {
		t.Fatal("awaitEnforcerBoot swallowed the boot failure")
	}
	if !strings.Contains(err.Error(), "payout address") {
		t.Errorf("err = %v, want the boot failure", err)
	}
}

// A restart that never finishes must not hold the reject lock for good.
func TestAwaitEnforcerBootGivesUpOnAStalledRestart(t *testing.T) {
	o := newTestOrchestrator(t)

	if err := o.awaitEnforcerBoot(make(chan StartupProgress), 20*time.Millisecond); err == nil {
		t.Fatal("awaitEnforcerBoot waited out a restart that never finished")
	}
}
