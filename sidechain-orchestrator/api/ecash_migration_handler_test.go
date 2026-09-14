package api

import (
	"context"
	"encoding/json"
	"io"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestECashMigrationHandlersRejectInvalidNetworks(t *testing.T) {
	handler := NewHandler(nil)
	for _, test := range []struct {
		name   string
		fromID string
		toID   string
	}{
		{name: "no source", toID: "betanet"},
		{name: "no target", fromID: "alphanet"},
		{name: "blank source", fromID: " ", toID: "betanet"},
		{name: "same network", fromID: "alphanet", toID: " alphanet "},
	} {
		t.Run(test.name, func(t *testing.T) {
			_, err := handler.PreviewECashMigration(context.Background(), connect.NewRequest(&pb.PreviewECashMigrationRequest{
				FromId: test.fromID,
				ToId:   test.toID,
			}))
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
			_, err = handler.StartECashMigration(context.Background(), connect.NewRequest(&pb.StartECashMigrationRequest{
				FromId: test.fromID,
				ToId:   test.toID,
			}))
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		})
	}
}

func TestECashMigrationStatusReadsTheSavedDaemonRecord(t *testing.T) {
	for _, test := range []struct {
		name      string
		complete  bool
		errorText string
		syncState string
	}{
		{name: "failed conversion", errorText: "the disk write failed", syncState: "waiting"},
		{name: "local checks passed", complete: true, syncState: "syncing"},
	} {
		t.Run(test.name, func(t *testing.T) {
			dir := t.TempDir()
			data, err := json.Marshal(map[string]any{
				"status": orchestrator.ECashMigrationStatus{
					JobID:        "migration-1",
					FromID:       "alphanet",
					ToID:         "betanet",
					DataDir:      "/remote-node/ecash",
					RecordsDone:  20,
					RecordsTotal: 100,
					Running:      true,
					Complete:     test.complete,
					Error:        test.errorText,
					SyncState:    test.syncState,
				},
				"step": 2,
			})
			require.NoError(t, err)
			require.NoError(t, os.WriteFile(filepath.Join(dir, "ecash-migration.json"), data, 0o600))
			orch := orchestrator.New(t.TempDir(), "signet", dir, nil, zerolog.New(io.Discard))
			_, handler := rpc.NewOrchestratorServiceHandler(NewHandler(orch))
			server := httptest.NewServer(handler)
			t.Cleanup(server.Close)
			client := rpc.NewOrchestratorServiceClient(server.Client(), server.URL)

			resp, err := client.GetECashMigrationStatus(t.Context(), connect.NewRequest(&pb.GetECashMigrationStatusRequest{}))

			require.NoError(t, err)
			status := resp.Msg.Status
			require.Equal(t, "migration-1", status.JobId)
			require.Equal(t, "alphanet", status.FromId)
			require.Equal(t, "betanet", status.ToId)
			require.Equal(t, "/remote-node/ecash", status.DataDir)
			require.EqualValues(t, 20, status.RecordsDone)
			require.EqualValues(t, 100, status.RecordsTotal)
			require.False(t, status.Running)
			require.Equal(t, test.complete, status.Complete)
			require.Equal(t, test.errorText, status.Error)
			require.Equal(t, test.syncState, status.SyncState)
		})
	}
}

func TestECashMigrationStatusReturnsReadFailure(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, "ecash-migration.json"), []byte("invalid"), 0o600))
	orch := orchestrator.New(t.TempDir(), "signet", dir, nil, zerolog.New(io.Discard))

	_, err := NewHandler(orch).GetECashMigrationStatus(t.Context(), connect.NewRequest(&pb.GetECashMigrationStatusRequest{}))

	require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	require.ErrorContains(t, err, "decode ECX migration")
}
