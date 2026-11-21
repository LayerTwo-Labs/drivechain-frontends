package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/require"

	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/selfbuild"
)

type fakeDrivechaind struct {
	orchrpc.UnimplementedOrchestratorServiceHandler
	runs      string
	exiting   bool
	ownerPIDs []int32
}

func (f *fakeDrivechaind) AdoptOwner(_ context.Context, req *orchpb.AdoptOwnerRequest) (*orchpb.AdoptOwnerResponse, error) {
	if f.exiting {
		return nil, connect.NewError(connect.CodeUnavailable, "the daemon exit already started")
	}
	f.ownerPIDs = append(f.ownerPIDs, req.GetOwnerPid())
	return &orchpb.AdoptOwnerResponse{}, nil
}

// serve starts a drivechaind that runs the file at runs.
func (f *fakeDrivechaind) serve(t *testing.T) string {
	mux := http.NewServeMux()
	mux.HandleFunc(selfbuild.RunsPath, func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("path") == f.runs {
			_, _ = w.Write([]byte("yes"))
			return
		}
		_, _ = w.Write([]byte("no"))
	})
	rpcServer := connect.NewServer()
	orchrpc.RegisterOrchestratorServiceHandler(rpcServer, f)
	connecthttp.Mount(mux, rpcServer)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	return srv.URL
}

// A drivechaind of the same build stays, and only takes the new owner.
func TestAdoptOrchestratorKeepsTheSameBuild(t *testing.T) {
	orch := &fakeDrivechaind{runs: "/app/drivechaind"}
	addr := orch.serve(t)

	adopted, err := adoptOrchestrator(t.Context(), addr, "", "/app/drivechaind", 7)
	require.NoError(t, err)
	require.True(t, adopted)
	require.Equal(t, []int32{7}, orch.ownerPIDs)

	adopted, err = adoptOrchestrator(t.Context(), addr, "", "/new/drivechaind", 8)
	require.NoError(t, err)
	require.False(t, adopted)
	require.Equal(t, []int32{7}, orch.ownerPIDs)
}

func TestAdoptOrchestratorLeavesADrivechaindThatExits(t *testing.T) {
	orch := &fakeDrivechaind{runs: "/app/drivechaind", exiting: true}

	adopted, err := adoptOrchestrator(t.Context(), orch.serve(t), "", "/app/drivechaind", 7)
	require.NoError(t, err)
	require.False(t, adopted)
}
