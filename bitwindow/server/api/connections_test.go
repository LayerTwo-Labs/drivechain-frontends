package api

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	orchctlpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchctlrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

type connectionsSource struct {
	orchctlrpc.UnimplementedOrchestratorServiceHandler
	frames chan []*orchctlpb.BinaryConnection
}

func (s *connectionsSource) WatchConnections(ctx context.Context, _ *orchctlpb.WatchConnectionsRequest, stream orchctlrpc.OrchestratorServiceWatchConnectionsServerStream) error {
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case frame := <-s.frames:
			if err := stream.Send(&orchctlpb.WatchConnectionsResponse{Connections: frame}); err != nil {
				return err
			}
		}
	}
}

func TestServicesFollowTheDrivechaindConnections(t *testing.T) {
	source := &connectionsSource{frames: make(chan []*orchctlpb.BinaryConnection, 1)}
	mux := http.NewServeMux()
	rpcServer := connect.NewServer()
	orchctlrpc.RegisterOrchestratorServiceHandler(rpcServer, source)
	connecthttp.Mount(mux, rpcServer)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)

	var dials atomic.Int32
	var reachable atomic.Bool
	enforcer := service.New("enforcer", func(context.Context) (string, error) {
		dials.Add(1)
		if !reachable.Load() {
			return "", errors.New("refused")
		}
		return "client", nil
	})
	ctx, cancel := context.WithCancel(t.Context())
	t.Cleanup(cancel)
	targets := connectionTargets{}
	targets.add(ctx, "enforcer", enforcer)
	go followConnections(ctx, dial.Orchestrator(srv.URL, ""), targets)

	send := func(connected bool) {
		source.frames <- []*orchctlpb.BinaryConnection{{Name: "bitcoincore", Connected: true}, {Name: "enforcer", Connected: connected}}
	}
	reachable.Store(true)
	send(true)
	require.Eventually(t, enforcer.IsConnected, 2*time.Second, 5*time.Millisecond)
	require.EqualValues(t, 1, dials.Load())

	time.Sleep(1500 * time.Millisecond)
	require.EqualValues(t, 1, dials.Load(), "a connected service sent a probe")

	reachable.Store(false)
	send(false)
	require.Eventually(t, func() bool { return !enforcer.IsConnected() }, time.Second, 5*time.Millisecond)
	require.EqualValues(t, 1, dials.Load(), "a stop dialed the service")

	reachable.Store(true)
	send(true)
	require.Eventually(t, enforcer.IsConnected, time.Second, 5*time.Millisecond)
	require.EqualValues(t, 2, dials.Load())
}
