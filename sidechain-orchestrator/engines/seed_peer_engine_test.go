package engines

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"sync"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

type fakePeerNode struct {
	mu       sync.Mutex
	answers  map[string]string
	errors   map[string]int
	calls    []string
	dialedTo []any
}

func (f *fakePeerNode) serve(t *testing.T) sidechain.Node {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			ID     json.RawMessage `json:"id"`
			Method string          `json:"method"`
			Params []any           `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		f.mu.Lock()
		f.calls = append(f.calls, req.Method)
		if req.Method == "connect_peer" {
			f.dialedTo = append(f.dialedTo, req.Params...)
		}
		answer, code := f.answers[req.Method], f.errors[req.Method]
		f.mu.Unlock()

		w.Header().Set("Content-Type", "application/json")
		if code != 0 {
			_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":` + string(req.ID) + `,"error":{"code":` + strconv.Itoa(code) + `,"message":"refused"}}`))
			return
		}
		if answer == "" {
			answer = "null"
		}
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":` + string(req.ID) + `,"result":` + answer + `}`))
	}))
	t.Cleanup(srv.Close)

	host, portText, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return sidechain.NewJSONRPCProxy(host, port)
}

func newTestSeedEngine() *SeedPeerEngine {
	e := NewSeedPeerEngine(zerolog.Nop(), nil)
	e.resolve = func(context.Context, string) ([]string, error) {
		return []string{"204.168.254.113"}, nil
	}
	return e
}

const idleSync = `{"phase":"idle","done":0,"total":0,"tip_height":0}`

func TestSeedPeerDialsALostSeed(t *testing.T) {
	f := &fakePeerNode{answers: map[string]string{
		"mainchain_sync_progress": idleSync,
		"list_peers":              `[{"address":"37.27.102.58:4255","status":"Connecting"}]`,
	}}
	node := SeededNode{Name: "coinshift", Seed: "seed.beta.ecash.eu.com:4255", Node: f.serve(t)}

	dialed, err := newTestSeedEngine().keepSeed(context.Background(), node)
	require.NoError(t, err)
	require.Equal(t, "204.168.254.113:4255", dialed)
	require.Equal(t, []any{"204.168.254.113:4255"}, f.dialedTo)
}

func TestSeedPeerLeavesAHeldSeed(t *testing.T) {
	f := &fakePeerNode{answers: map[string]string{
		"mainchain_sync_progress": idleSync,
		"list_peers":              `[{"address":"204.168.254.113:4013","status":"Connected"}]`,
	}}
	node := SeededNode{Name: "truthcoin", Seed: "seed.beta.ecash.eu.com:4013", Node: f.serve(t)}

	dialed, err := newTestSeedEngine().keepSeed(context.Background(), node)
	require.NoError(t, err)
	require.Empty(t, dialed)
	require.Empty(t, f.dialedTo)
}

func TestSeedPeerWaitsForTheMainchainSync(t *testing.T) {
	f := &fakePeerNode{answers: map[string]string{
		"mainchain_sync_progress": `{"phase":"headers","done":880000,"total":973833,"tip_height":973833}`,
	}}
	node := SeededNode{Name: "bitassets", Seed: "seed.beta.ecash.eu.com:4004", Node: f.serve(t)}

	dialed, err := newTestSeedEngine().keepSeed(context.Background(), node)
	require.NoError(t, err)
	require.Empty(t, dialed)
	require.Equal(t, []string{"mainchain_sync_progress"}, f.calls)
}

func TestSeedPeerDialsANodeWithNoSyncProgress(t *testing.T) {
	f := &fakePeerNode{
		answers: map[string]string{"list_peers": `[]`},
		errors:  map[string]int{"mainchain_sync_progress": -32601},
	}
	node := SeededNode{Name: "zside", Seed: "seed.beta.ecash.eu.com:4098", Node: f.serve(t)}

	dialed, err := newTestSeedEngine().keepSeed(context.Background(), node)
	require.NoError(t, err)
	require.Equal(t, "204.168.254.113:4098", dialed)
}

func TestSeedPeerReturnsADialError(t *testing.T) {
	f := &fakePeerNode{
		answers: map[string]string{"mainchain_sync_progress": idleSync, "list_peers": `[]`},
		errors:  map[string]int{"connect_peer": -1},
	}
	node := SeededNode{Name: "thunder", Seed: "seed.beta.ecash.eu.com:4009", Node: f.serve(t)}

	_, err := newTestSeedEngine().keepSeed(context.Background(), node)
	require.ErrorContains(t, err, "connect to 204.168.254.113:4009")
}
