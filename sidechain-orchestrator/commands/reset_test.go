package commands

import (
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
)

type resetTestServer struct {
	rpc.UnimplementedOrchestratorServiceHandler
	results []*pb.DeleteFilesResponse
}

func (s *resetTestServer) GatherFilesToDelete(context.Context, *pb.GatherFilesToDeleteRequest) (*pb.GatherFilesToDeleteResponse, error) {
	return &pb.GatherFilesToDeleteResponse{Files: []*pb.ResetFileInfo{{Path: "/data/a"}, {Path: "/data/b"}}}, nil
}

func (s *resetTestServer) DeleteFiles(_ context.Context, _ *pb.DeleteFilesRequest, stream rpc.OrchestratorServiceDeleteFilesServerStream) error {
	for _, result := range s.results {
		if err := stream.Send(result); err != nil {
			return err
		}
	}
	return nil
}

func runResetForTest(t *testing.T, results ...*pb.DeleteFilesResponse) error {
	t.Helper()
	rpcServer := connect.NewServer()
	rpc.RegisterOrchestratorServiceHandler(rpcServer, &resetTestServer{results: results})
	handler := http.NewServeMux()
	connecthttp.Mount(handler, rpcServer, connecthttp.WithReadMaxBytes(0))
	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)
	app := &cli.App{
		Name:      "drivechain-cli",
		Flags:     GlobalFlags,
		Commands:  Commands(),
		Writer:    io.Discard,
		ErrWriter: io.Discard,
	}
	return app.RunContext(t.Context(), []string{
		"drivechain-cli", "--rpcserver", strings.TrimPrefix(server.URL, "http://"),
		"--bitwindow-dir", t.TempDir(),
		"reset", "run", "--logs", "--yes",
	})
}

func TestResetRunSucceedsWhenEveryDeletionSucceeds(t *testing.T) {
	require.NoError(t, runResetForTest(t, &pb.DeleteFilesResponse{Path: "/data/a"}, &pb.DeleteFilesResponse{Path: "/data/b"}))
}

func TestResetRunFailsWhenADeletionFails(t *testing.T) {
	err := runResetForTest(t, &pb.DeleteFilesResponse{Path: "/data/a"}, &pb.DeleteFilesResponse{Path: "/data/b", Error: "permission denied"})
	require.ErrorContains(t, err, "1 of 2 deletions failed")
}
