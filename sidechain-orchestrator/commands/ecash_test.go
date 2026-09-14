package commands

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"flag"
	"io"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
	"google.golang.org/protobuf/proto"
)

type ecashMigrationServer struct {
	rpc.UnimplementedOrchestratorServiceHandler
	preview      *pb.ECashMigrationStatus
	start        *pb.ECashMigrationStatus
	statuses     []*pb.ECashMigrationStatus
	previewError error
	startError   error
	statusError  error
	previews     []*pb.PreviewECashMigrationRequest
	starts       []*pb.StartECashMigrationRequest
	statusCalls  int
}

func (s *ecashMigrationServer) PreviewECashMigration(_ context.Context, req *connect.Request[pb.PreviewECashMigrationRequest]) (*connect.Response[pb.PreviewECashMigrationResponse], error) {
	s.previews = append(s.previews, req.Msg)
	if s.previewError != nil {
		return nil, s.previewError
	}
	return connect.NewResponse(&pb.PreviewECashMigrationResponse{Status: s.preview}), nil
}

func (s *ecashMigrationServer) StartECashMigration(_ context.Context, req *connect.Request[pb.StartECashMigrationRequest]) (*connect.Response[pb.StartECashMigrationResponse], error) {
	s.starts = append(s.starts, req.Msg)
	if s.startError != nil {
		return nil, s.startError
	}
	return connect.NewResponse(&pb.StartECashMigrationResponse{Status: s.start}), nil
}

func (s *ecashMigrationServer) GetECashMigrationStatus(_ context.Context, _ *connect.Request[pb.GetECashMigrationStatusRequest]) (*connect.Response[pb.GetECashMigrationStatusResponse], error) {
	s.statusCalls++
	if s.statusError != nil {
		return nil, s.statusError
	}
	if s.statusCalls > len(s.statuses) {
		return nil, connect.NewError(connect.CodeInternal, errors.New("the test has no more status data"))
	}
	return connect.NewResponse(&pb.GetECashMigrationStatusResponse{Status: s.statuses[s.statusCalls-1]}), nil
}

func newECashMigrationClient(t *testing.T, service *ecashMigrationServer) rpc.OrchestratorServiceClient {
	t.Helper()
	_, handler := rpc.NewOrchestratorServiceHandler(service)
	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)
	return rpc.NewOrchestratorServiceClient(server.Client(), server.URL)
}

func ecashCommandContext(t *testing.T, command *cli.Command, args ...string) (*cli.Context, *bytes.Buffer) {
	t.Helper()
	flags := flag.NewFlagSet(command.Name, flag.ContinueOnError)
	for _, flag := range command.Flags {
		require.NoError(t, flag.Apply(flags))
	}
	require.NoError(t, flags.Parse(args))
	out := new(bytes.Buffer)
	app := cli.NewApp()
	app.Writer = out
	app.ErrWriter = io.Discard
	app.Reader = strings.NewReader("")
	cctx := cli.NewContext(app, flags, nil)
	cctx.Context = t.Context()
	return cctx, out
}

func ecashTestStatus() *pb.ECashMigrationStatus {
	return &pb.ECashMigrationStatus{
		JobId:        "migration-1",
		FromId:       "alphanet",
		ToId:         "betanet",
		Phase:        "convert",
		DataDir:      "/remote-node/ecash",
		CommonHeight: 963647,
		CommonHash:   strings.Repeat("a", 64),
		SourceMagic:  "eca5a104",
		TargetMagic:  "eca5a105",
		BlockFiles:   20,
		UndoFiles:    19,
		RecordsDone:  3,
		RecordsTotal: 100,
		Running:      true,
		SyncState:    "waiting",
	}
}

func ecashJSONStates(t *testing.T, out *bytes.Buffer) []map[string]any {
	t.Helper()
	decoder := json.NewDecoder(out)
	var states []map[string]any
	for decoder.More() {
		var state map[string]any
		require.NoError(t, decoder.Decode(&state))
		states = append(states, state)
	}
	return states
}

func TestECashPreviewUsesDaemonData(t *testing.T) {
	status := ecashTestStatus()
	status.JobId = ""
	status.Phase = "preview"
	status.Running = false
	status.Pruned = true
	status.PruneHeight = 960000
	service := &ecashMigrationServer{preview: status}
	cctx, out := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet", "--preview", "--json")

	require.NoError(t, runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond))

	require.Len(t, service.previews, 1)
	require.Equal(t, "alphanet", service.previews[0].FromId)
	require.Equal(t, "betanet", service.previews[0].ToId)
	require.Empty(t, service.starts)
	require.Zero(t, service.statusCalls)
	states := ecashJSONStates(t, out)
	require.Len(t, states, 1)
	require.Equal(t, "/remote-node/ecash", states[0]["data_dir"])
	require.Equal(t, "963647", states[0]["common_height"])
	require.Equal(t, "20", states[0]["block_files"])
	require.Equal(t, true, states[0]["pruned"])
	require.Equal(t, "960000", states[0]["prune_height"])
}

type ecashNoInput struct{ t *testing.T }

func (r ecashNoInput) Read([]byte) (int, error) {
	r.t.Error("the script path read terminal input")
	return 0, io.EOF
}

func TestECashMigrateWaitsForLocalChecksWithoutTerminalInput(t *testing.T) {
	first := ecashTestStatus()
	progress := proto.Clone(first).(*pb.ECashMigrationStatus)
	progress.RecordsDone = 75
	complete := proto.Clone(progress).(*pb.ECashMigrationStatus)
	complete.Phase = "complete"
	complete.RecordsDone = complete.RecordsTotal
	complete.Running = false
	complete.Complete = true
	complete.SyncState = "syncing"
	service := &ecashMigrationServer{start: first, statuses: []*pb.ECashMigrationStatus{progress, complete}}
	cctx, out := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet", "--yes", "--json")
	cctx.App.Reader = ecashNoInput{t}

	require.NoError(t, runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond))

	require.Empty(t, service.previews)
	require.Len(t, service.starts, 1)
	require.Equal(t, "alphanet", service.starts[0].FromId)
	require.Equal(t, "betanet", service.starts[0].ToId)
	require.Equal(t, 2, service.statusCalls)
	states := ecashJSONStates(t, out)
	require.Len(t, states, 3)
	require.Equal(t, false, states[0]["complete"])
	require.Equal(t, "75", states[1]["records_done"])
	require.Equal(t, true, states[2]["complete"])
	require.Equal(t, "syncing", states[2]["sync_state"])
}

func TestECashMigrateReturnsDaemonFailure(t *testing.T) {
	first := ecashTestStatus()
	failed := proto.Clone(first).(*pb.ECashMigrationStatus)
	failed.Running = false
	failed.Error = "the target block hash differs"
	service := &ecashMigrationServer{start: first, statuses: []*pb.ECashMigrationStatus{failed}}
	cctx, out := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet", "--yes", "--json")

	err := runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond)

	require.ErrorContains(t, err, failed.Error)
	states := ecashJSONStates(t, out)
	require.Len(t, states, 2)
	require.Equal(t, false, states[1]["complete"])
	require.Equal(t, failed.Error, states[1]["error"])
}

func TestECashMigrateRejectsIncompleteExit(t *testing.T) {
	first := ecashTestStatus()
	first.Running = false
	service := &ecashMigrationServer{start: first}
	cctx, _ := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet", "--yes")

	err := runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond)

	require.ErrorContains(t, err, "stopped before the local checks passed")
	require.Zero(t, service.statusCalls)
}

func TestECashMigrateRejectsDifferentJob(t *testing.T) {
	first := ecashTestStatus()
	next := proto.Clone(first).(*pb.ECashMigrationStatus)
	next.JobId = "migration-2"
	next.Running = false
	next.Complete = true
	service := &ecashMigrationServer{start: first, statuses: []*pb.ECashMigrationStatus{next}}
	cctx, _ := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet", "--yes")

	err := runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond)

	require.ErrorContains(t, err, "different migration job")
}

func TestECashPreviewRejectsDifferentNetworks(t *testing.T) {
	status := ecashTestStatus()
	status.ToId = "another-network"
	service := &ecashMigrationServer{preview: status}
	cctx, _ := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet", "--preview")

	err := runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond)

	require.ErrorContains(t, err, "different migration networks")
	require.Empty(t, service.starts)
}

func TestECashMigrateReturnsStatusRPCError(t *testing.T) {
	service := &ecashMigrationServer{
		start:       ecashTestStatus(),
		statusError: connect.NewError(connect.CodeUnavailable, errors.New("the daemon stopped")),
	}
	cctx, _ := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet", "--yes")

	err := runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond)

	require.ErrorContains(t, err, "the daemon stopped")
	require.ErrorContains(t, err, "migration-status")
}

func TestECashMigrateRefusesJSONWithoutYes(t *testing.T) {
	service := new(ecashMigrationServer)
	cctx, _ := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet", "--json")

	err := runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond)

	require.ErrorContains(t, err, "use --yes with --json")
	require.Empty(t, service.starts)
	require.Empty(t, service.previews)
}

func TestECashMigrateRefusesWithoutAnAnswer(t *testing.T) {
	service := &ecashMigrationServer{preview: ecashTestStatus()}
	cctx, _ := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet")

	err := runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond)

	require.ErrorContains(t, err, "use --yes")
	require.Empty(t, service.starts)
}

func TestECashMigrateStartsAfterTheAnswer(t *testing.T) {
	status := ecashTestStatus()
	status.Running = false
	status.Complete = true
	service := &ecashMigrationServer{preview: status, start: status}
	cctx, out := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet")
	cctx.App.Reader = strings.NewReader("yes\n")

	require.NoError(t, runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond))

	require.Len(t, service.starts, 1)
	require.Contains(t, out.String(), "Daemon data directory: /remote-node/ecash")
}

func TestECashMigrationStatusReturnsSavedErrorAsJSON(t *testing.T) {
	status := ecashTestStatus()
	status.Running = false
	status.Error = "the disk write failed"
	service := &ecashMigrationServer{statuses: []*pb.ECashMigrationStatus{status}}
	cctx, out := ecashCommandContext(t, ecashMigrationStatusCommand, "--json")

	err := runECashMigrationStatus(cctx, newECashMigrationClient(t, service))

	require.ErrorContains(t, err, status.Error)
	states := ecashJSONStates(t, out)
	require.Len(t, states, 1)
	require.Equal(t, status.JobId, states[0]["job_id"])
	require.Equal(t, status.Error, states[0]["error"])
}

func TestECashMigrateRejectsInvalidArguments(t *testing.T) {
	for _, args := range [][]string{
		{"--from", "alphanet", "--to", "alphanet", "--yes"},
		{"--from", " ", "--to", "betanet", "--yes"},
		{"--from", "alphanet", "--to", "betanet", "extra"},
	} {
		t.Run(strings.Join(args, " "), func(t *testing.T) {
			service := new(ecashMigrationServer)
			cctx, _ := ecashCommandContext(t, ecashMigrateCommand, args...)
			require.Error(t, runECashMigrate(cctx, newECashMigrationClient(t, service), time.Millisecond))
			require.Empty(t, service.starts)
			require.Empty(t, service.previews)
		})
	}
}

func TestECashCommandRegistersBothCommands(t *testing.T) {
	app := &cli.App{Commands: Commands()}
	command := app.Command("ecash")
	require.NotNil(t, command)
	require.NotNil(t, command.Command("migrate"))
	require.NotNil(t, command.Command("migration-status"))
}

func TestECashCommandUsesRPCAddressAndAuthCookie(t *testing.T) {
	cookieDir := t.TempDir()
	_, err := localauth.WriteCookie(cookieDir)
	require.NoError(t, err)
	service := &ecashMigrationServer{preview: ecashTestStatus()}
	_, handler := rpc.NewOrchestratorServiceHandler(service, connect.WithInterceptors(localauth.Interceptor(cookieDir)))
	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)
	out := new(bytes.Buffer)
	app := &cli.App{
		Name:      "drivechain-cli",
		Flags:     GlobalFlags,
		Commands:  Commands(),
		Writer:    out,
		ErrWriter: io.Discard,
		Reader:    ecashNoInput{t},
	}

	err = app.RunContext(t.Context(), []string{
		"drivechain-cli", "--rpcserver", strings.TrimPrefix(server.URL, "http://"),
		"--bitwindow-dir", cookieDir, "ecash", "migrate", "--from", "alphanet", "--to", "betanet", "--preview", "--json",
	})

	require.NoError(t, err)
	require.Len(t, service.previews, 1)
	states := ecashJSONStates(t, out)
	require.Len(t, states, 1)
	require.Equal(t, "/remote-node/ecash", states[0]["data_dir"])
}

type ecashCancelOutput struct {
	bytes.Buffer
	cancel context.CancelFunc
}

func (w *ecashCancelOutput) Write(data []byte) (int, error) {
	n, err := w.Buffer.Write(data)
	w.cancel()
	return n, err
}

func TestECashMigrateReturnsAfterClientCancellation(t *testing.T) {
	service := &ecashMigrationServer{start: ecashTestStatus()}
	cctx, _ := ecashCommandContext(t, ecashMigrateCommand, "--from", "alphanet", "--to", "betanet", "--yes", "--json")
	ctx, cancel := context.WithCancel(t.Context())
	defer cancel()
	cctx.Context = ctx
	cctx.App.Writer = &ecashCancelOutput{cancel: cancel}

	err := runECashMigrate(cctx, newECashMigrationClient(t, service), time.Hour)

	require.ErrorIs(t, err, context.Canceled)
	require.ErrorContains(t, err, "the daemon keeps the migration job")
	require.Len(t, service.starts, 1)
	require.Zero(t, service.statusCalls)
	require.True(t, service.start.Running)
}
