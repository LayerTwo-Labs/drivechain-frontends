package orchestrator

import (
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync/atomic"
	"syscall"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// A stop RPC that never landed must skip the graceful wait. A stop RPC that
// may have landed must not: bitcoind answers `stop`, then drops the connection
// while it flushes, and a signal there can corrupt on-disk state.
func TestUnreachableTellsAMissedStopFromAFlushingDaemon(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want bool
	}{
		{"no error", nil, false},
		{"no client", fmt.Errorf("bitcoind RPC stop: %w: down", errNoStopClient), true},
		{"no cookie yet", fmt.Errorf("read rpc cookie .cookie: %w", os.ErrNotExist), true},
		{"connection refused", fmt.Errorf("stop: %w", syscall.ECONNREFUSED), true},
		{"dial failed", &net.OpError{Op: "dial", Err: errors.New("no route")}, true},
		{"read after the ack", &net.OpError{Op: "read", Err: errors.New("reset by peer")}, false},
		{"timeout", errors.New("stop: context deadline exceeded"), false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			require.Equal(t, tt.want, unreachable(tt.err))
		})
	}
}

// A Core fork answers a call without its cookie with an empty 401, which reads
// as a stop that may have landed. Shutdown then waits out the grace period for
// an exit that never comes, so stop has to carry the cookie.
func TestACoreForkStopCarriesItsCookie(t *testing.T) {
	o := newTestOrchestrator(t)

	var stopped atomic.Bool
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if user, password, ok := r.BasicAuth(); !ok || user != "__cookie__" || password != "secret" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		var req struct {
			Method string `json:"method"`
		}
		_ = json.NewDecoder(r.Body).Decode(&req)
		stopped.Store(req.Method == "stop")
		_, _ = w.Write([]byte(`{"result":"FreeBank server stopping","error":null}`))
	}))
	t.Cleanup(srv.Close)
	setSidechainPort(t, o, "freebank", srv.URL)
	cfg, err := o.getConfig("freebank")
	require.NoError(t, err)

	// A node that has not written its cookie has no RPC server up yet.
	err = o.callSidechainStopRPC(cfg)
	require.Error(t, err)
	require.True(t, unreachable(err), "a stop that never went out must go straight to the signal: %v", err)

	datadir := config.FreebankDirs.DatadirNetwork(config.Network(o.CurrentNetwork()), "")
	require.NoError(t, os.MkdirAll(datadir, 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(datadir, ".cookie"), []byte("__cookie__:secret"), 0o600))

	require.NoError(t, o.callSidechainStopRPC(cfg))
	require.True(t, stopped.Load())
}
