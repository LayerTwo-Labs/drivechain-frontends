package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"strconv"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/require"

	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/lease"
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

const appPID = 4242

func keep(t *testing.T, handler http.Handler, path string) int {
	q := "?owner=" + strconv.Itoa(appPID) + "&path=" + path
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequestWithContext(t.Context(), http.MethodPost, "/daemon/keep"+q, nil))
	return rec.Code
}

func newLease(t *testing.T) *lease.Lease {
	clients := lease.New(1, time.Hour, func() {})
	ctx, cancel := context.WithCancel(t.Context())
	t.Cleanup(cancel)
	go clients.Run(ctx)
	return clients
}

func TestKeepTakesBothDaemonsOfThisBuild(t *testing.T) {
	self, err := selfbuild.Path()
	require.NoError(t, err)
	orch := &fakeDrivechaind{runs: drivechaindBeside(self)}

	code := keep(t, keepHandler(orch.serve(t), "", newLease(t)), self)

	require.Equal(t, http.StatusOK, code)
	require.Equal(t, []int32{appPID}, orch.ownerPIDs)
}

func TestKeepRefusesAnotherBitwindowdBuild(t *testing.T) {
	other := filepath.Join(t.TempDir(), "bitwindowd")
	orch := &fakeDrivechaind{runs: drivechaindBeside(other)}

	code := keep(t, keepHandler(orch.serve(t), "", newLease(t)), other)

	require.Equal(t, http.StatusConflict, code)
	require.Empty(t, orch.ownerPIDs)
}

func TestKeepRefusesAnotherDrivechaindBuild(t *testing.T) {
	self, err := selfbuild.Path()
	require.NoError(t, err)
	orch := &fakeDrivechaind{runs: filepath.Join(t.TempDir(), "drivechaind")}

	code := keep(t, keepHandler(orch.serve(t), "", newLease(t)), self)

	require.Equal(t, http.StatusConflict, code)
	require.Empty(t, orch.ownerPIDs)
}

func TestKeepRefusesADrivechaindThatExits(t *testing.T) {
	self, err := selfbuild.Path()
	require.NoError(t, err)
	orch := &fakeDrivechaind{runs: drivechaindBeside(self), exiting: true}

	code := keep(t, keepHandler(orch.serve(t), "", newLease(t)), self)

	require.Equal(t, http.StatusConflict, code)
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
