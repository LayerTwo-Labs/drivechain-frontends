package orchestrator

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/rs/zerolog"
)

type seedCall struct {
	Method string   `json:"method"`
	Params []string `json:"params"`
}

func fakeThunder(t *testing.T, calls chan<- seedCall) (string, int) {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var got seedCall
		if err := json.NewDecoder(r.Body).Decode(&got); err != nil {
			t.Errorf("decode the request: %v", err)
		}
		calls <- got
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":null}`))
	}))
	t.Cleanup(srv.Close)

	host, portStr, err := net.SplitHostPort(strings.TrimPrefix(srv.URL, "http://"))
	if err != nil {
		t.Fatalf("split the address: %v", err)
	}
	port, err := strconv.Atoi(portStr)
	if err != nil {
		t.Fatalf("read the port: %v", err)
	}
	return host, port
}

func neverGiveUp() bool { return false }

func testLog(t *testing.T) zerolog.Logger {
	t.Helper()
	return zerolog.New(zerolog.NewTestWriter(t))
}

// Both seeds thunder names are down, so the launcher names one that answers.
func TestDialThunderSeedAsksTheChain(t *testing.T) {
	calls := make(chan seedCall, 2)
	host, port := fakeThunder(t, calls)

	dialSeedWhenSynced(context.Background(), testLog(t),
		BinaryConfig{Name: "thunder", Host: host, Port: port},
		time.Millisecond, func() bool { return true }, neverGiveUp)

	select {
	case got := <-calls:
		if got.Method != "connect_peer" {
			t.Errorf("method = %q, want connect_peer", got.Method)
		}
		if len(got.Params) != 1 || got.Params[0] != alphanetThunderSeed {
			t.Errorf("params = %v, want [%s]", got.Params, alphanetThunderSeed)
		}
	default:
		t.Fatal("the launcher asked thunder nothing")
	}
}

// Thunder asks its enforcer for the peer tip's mainchain ancestors on the first
// exchange, so a dial before the enforcer holds them wastes the peer.
func TestDialThunderSeedWaitsForTheEnforcer(t *testing.T) {
	calls := make(chan seedCall, 2)
	host, port := fakeThunder(t, calls)

	var reads atomic.Int32
	dialSeedWhenSynced(context.Background(), testLog(t),
		BinaryConfig{Name: "thunder", Host: host, Port: port},
		time.Millisecond, func() bool { return reads.Add(1) >= 3 }, neverGiveUp)

	if got := reads.Load(); got != 3 {
		t.Errorf("read the sync status %d times, want 3", got)
	}
	select {
	case got := <-calls:
		if got.Method != "connect_peer" {
			t.Errorf("method = %q, want connect_peer", got.Method)
		}
	default:
		t.Fatal("the launcher never dialled the seed")
	}
}

// A shutdown stops the wait, and nothing dials a chain that is going down.
func TestDialThunderSeedStopsWithTheContext(t *testing.T) {
	calls := make(chan seedCall, 2)
	host, port := fakeThunder(t, calls)

	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	dialSeedWhenSynced(ctx, testLog(t),
		BinaryConfig{Name: "thunder", Host: host, Port: port},
		time.Millisecond, func() bool { return false }, neverGiveUp)

	select {
	case got := <-calls:
		t.Errorf("the launcher asked for %v", got)
	default:
	}
}

// The seed answers on alphanet alone, and for thunder alone.
func TestDialThunderSeedLeavesEveryOtherChainAlone(t *testing.T) {
	for _, test := range []struct {
		name    string
		network string
		binary  string
	}{
		{name: "another network", network: "signet", binary: "thunder"},
		{name: "another chain", network: "ecash", binary: "bitnames"},
		{name: "the mainchain", network: "ecash", binary: "bitcoind"},
	} {
		t.Run(test.name, func(t *testing.T) {
			calls := make(chan seedCall, 2)
			host, port := fakeThunder(t, calls)

			o := &Orchestrator{Network: test.network, log: testLog(t)}
			o.dialThunderSeed(context.Background(), BinaryConfig{Name: test.binary, Host: host, Port: port})

			select {
			case got := <-calls:
				t.Errorf("the launcher asked for %v", got)
			default:
			}
		})
	}
}

func TestEnforcerAtTip(t *testing.T) {
	for _, test := range []struct {
		name   string
		result *ChainSyncResult
		want   bool
	}{
		{name: "at the tip", result: &ChainSyncResult{Blocks: 100, Headers: 100}, want: true},
		{name: "behind", result: &ChainSyncResult{Blocks: 99, Headers: 100}},
		{name: "no headers", result: &ChainSyncResult{}},
		{name: "an error", result: &ChainSyncResult{Blocks: 100, Headers: 100, Error: "down"}},
		{name: "no result", result: nil},
	} {
		t.Run(test.name, func(t *testing.T) {
			if got := enforcerAtTip(test.result); got != test.want {
				t.Errorf("enforcerAtTip = %v, want %v", got, test.want)
			}
		})
	}
}

// A drain must end the wait, or the goroutine outlives the daemon it serves.
func TestDialThunderSeedStopsWhenTheDrainBegins(t *testing.T) {
	calls := make(chan seedCall, 2)
	host, port := fakeThunder(t, calls)

	var reads atomic.Int32
	dialSeedWhenSynced(context.Background(), testLog(t),
		BinaryConfig{Name: "thunder", Host: host, Port: port},
		time.Millisecond,
		func() bool { reads.Add(1); return false },
		func() bool { return reads.Load() >= 2 })

	select {
	case got := <-calls:
		t.Errorf("the launcher asked for %v", got)
	default:
	}
}

// A reset cancels each item's context as soon as the binary answers, so the
// dial must not take that context.
func TestSeedDialContextOutlivesTheCaller(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	dialCtx := seedDialContext(ctx)
	cancel()

	if dialCtx.Err() != nil {
		t.Errorf("the dial context ended with the caller: %v", dialCtx.Err())
	}
}
