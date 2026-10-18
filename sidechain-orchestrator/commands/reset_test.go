package commands

import (
	"context"
	"io"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
)

type resetTestServer struct {
	rpc.UnimplementedOrchestratorServiceHandler
	results []*pb.DeleteFilesResponse
}

func (s *resetTestServer) GatherFilesToDelete(context.Context, *connect.Request[pb.GatherFilesToDeleteRequest]) (*connect.Response[pb.GatherFilesToDeleteResponse], error) {
	return connect.NewResponse(&pb.GatherFilesToDeleteResponse{Files: []*pb.ResetFileInfo{{Path: "/data/a"}, {Path: "/data/b"}}}), nil
}

func (s *resetTestServer) DeleteFiles(_ context.Context, _ *connect.Request[pb.DeleteFilesRequest], stream *connect.ServerStream[pb.DeleteFilesResponse]) error {
	for _, result := range s.results {
		if err := stream.Send(result); err != nil {
			return err
		}
	}
	return nil
}

func runResetForTest(t *testing.T, results ...*pb.DeleteFilesResponse) error {
	t.Helper()
	_, handler := rpc.NewOrchestratorServiceHandler(&resetTestServer{results: results})
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
