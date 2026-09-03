package orchestrator

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

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

// Both seeds thunder names are down, so the launcher names one that answers.
func TestDialThunderSeedAsksTheChain(t *testing.T) {
	calls := make(chan seedCall, 2)
	host, port := fakeThunder(t, calls)

	o := &Orchestrator{Network: "ecash", log: zerolog.New(zerolog.NewTestWriter(t))}
	o.dialThunderSeed(context.Background(), BinaryConfig{Name: "thunder", Host: host, Port: port})

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

			o := &Orchestrator{Network: test.network, log: zerolog.New(zerolog.NewTestWriter(t))}
			o.dialThunderSeed(context.Background(), BinaryConfig{Name: test.binary, Host: host, Port: port})

			select {
			case got := <-calls:
				t.Errorf("the launcher asked for %v", got)
			default:
			}
		})
	}
}
