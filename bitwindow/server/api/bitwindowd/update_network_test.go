package api_bitwindowd_test

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"
	api_bitwindowd "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/bitwindowd"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/stretchr/testify/require"
)

type migrationNetworkServer struct {
	orchrpc.UnimplementedBitcoinConfServiceHandler
	orchrpc.UnimplementedOrchestratorServiceHandler
	plan        *orchpb.PlanECashSwitchResponse
	status      *orchpb.ECashMigrationStatus
	statusError error
	calls       chan string
}

func (s *migrationNetworkServer) PlanECashSwitch(_ context.Context, req *connect.Request[orchpb.PlanECashSwitchRequest]) (*connect.Response[orchpb.PlanECashSwitchResponse], error) {
	s.calls <- "plan:" + req.Msg.NetworkId
	return connect.NewResponse(s.plan), nil
}

func (s *migrationNetworkServer) GetECashMigrationStatus(context.Context, *connect.Request[orchpb.GetECashMigrationStatusRequest]) (*connect.Response[orchpb.GetECashMigrationStatusResponse], error) {
	s.calls <- "status"
	if s.statusError != nil {
		return nil, s.statusError
	}
	return connect.NewResponse(&orchpb.GetECashMigrationStatusResponse{Status: s.status}), nil
}

func (s *migrationNetworkServer) SetBitcoinConfigNetwork(_ context.Context, req *connect.Request[orchpb.SetBitcoinConfigNetworkRequest]) (*connect.Response[orchpb.SetBitcoinConfigNetworkResponse], error) {
	s.calls <- "select:" + req.Msg.Network
	return connect.NewResponse(&orchpb.SetBitcoinConfigNetworkResponse{}), nil
}

func newMigrationNetworkServer(t *testing.T, handler *migrationNetworkServer) string {
	t.Helper()
	handler.calls = make(chan string, 10)
	mux := http.NewServeMux()
	mux.Handle(orchrpc.NewBitcoinConfServiceHandler(handler))
	mux.Handle(orchrpc.NewOrchestratorServiceHandler(handler))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)
	return server.URL
}

func TestUpdateNetworkKeepsCompletedMigrationRows(t *testing.T) {
	for _, test := range []struct {
		name      string
		plan      *orchpb.PlanECashSwitchResponse
		status    *orchpb.ECashMigrationStatus
		resetFrom uint32
		heights   string
	}{
		{
			name: "completed migration",
			status: &orchpb.ECashMigrationStatus{
				FromId: "alphanet", ToId: "betanet", Complete: true, CommonHeight: 100,
			},
			resetFrom: 101, heights: "99,100",
		},
		{
			name: "wallet migration",
			status: &orchpb.ECashMigrationStatus{
				FromId: "alphanet", ToId: "betanet", Complete: true, WalletOnly: true,
			},
		},
		{
			name: "incomplete migration",
			status: &orchpb.ECashMigrationStatus{
				FromId: "alphanet", ToId: "betanet", Running: true, CommonHeight: 100,
			},
		},
		{
			name: "another target",
			status: &orchpb.ECashMigrationStatus{
				FromId: "alphanet", ToId: "gammanet", Complete: true, CommonHeight: 100,
			},
		},
		{name: "no migration"},
		{
			name: "planned rollback",
			plan: &orchpb.PlanECashSwitchResponse{NeedsRollback: true, RewindHeight: 99},
			status: &orchpb.ECashMigrationStatus{
				FromId: "alphanet", ToId: "betanet", Complete: true, CommonHeight: 100,
			},
			resetFrom: 100, heights: "99",
		},
	} {
		t.Run(test.name, func(t *testing.T) {
			if test.plan == nil {
				test.plan = &orchpb.PlanECashSwitchResponse{FromId: "betanet", ToId: "betanet"}
			}
			handler := &migrationNetworkServer{plan: test.plan, status: test.status}
			conf := config.Config{Datadir: t.TempDir(), OrchestratorAddr: newMigrationNetworkServer(t, handler)}
			require.NoError(t, conf.Finalize(config.NetworkECash))
			db, err := database.New(t.Context(), conf)
			require.NoError(t, err)
			t.Cleanup(func() { require.NoError(t, db.Close()) })
			for _, height := range []int{99, 100, 101} {
				_, err := db.ExecContext(t.Context(), `INSERT INTO processed_blocks (height, block_hash, txids, block_time) VALUES (?, ?, '[]', CURRENT_TIMESTAMP)`, height, fmt.Sprintf("block-%d", height))
				require.NoError(t, err)
				_, err = db.ExecContext(t.Context(), `INSERT INTO op_returns (txid, vout, op_return_data, fee_sats, height) VALUES (?, 0, '00', 1, ?)`, fmt.Sprintf("tx-%d", height), height)
				require.NoError(t, err)
			}
			var resetFrom uint32
			server := api_bitwindowd.New(nil, db, nil, nil, conf, func(ctx context.Context, network config.Network, id string, height uint32) error {
				handler.calls <- "recycle:" + id
				require.Equal(t, config.NetworkECash, network)
				resetFrom = height
				return engines.ResetChainData(ctx, db, height)
			})

			_, err = server.UpdateNetwork(t.Context(), connect.NewRequest(&pb.UpdateNetworkRequest{Network: "ecash", NetworkId: "betanet"}))
			require.NoError(t, err)
			for _, table := range []string{"processed_blocks", "op_returns"} {
				var heights string
				require.NoError(t, db.QueryRowContext(t.Context(), `SELECT COALESCE(GROUP_CONCAT(height, ','), '') FROM (SELECT height FROM `+table+` ORDER BY height)`).Scan(&heights))
				require.Equal(t, test.heights, heights, table)
			}
			require.Equal(t, test.resetFrom, resetFrom)
			want := []string{"plan:betanet", "status", "select:betanet", "recycle:betanet"}
			if test.plan.NeedsRollback {
				want = []string{"plan:betanet", "select:betanet", "recycle:betanet"}
			}
			var calls []string
			for len(handler.calls) > 0 {
				calls = append(calls, <-handler.calls)
			}
			require.Equal(t, want, calls)
		})
	}
}

func TestUpdateNetworkReturnsMigrationStatusError(t *testing.T) {
	handler := &migrationNetworkServer{
		plan:        &orchpb.PlanECashSwitchResponse{FromId: "betanet", ToId: "betanet"},
		statusError: connect.NewError(connect.CodeUnavailable, errors.New("The migration status is unavailable.")),
	}
	conf := config.Config{Datadir: t.TempDir(), OrchestratorAddr: newMigrationNetworkServer(t, handler)}
	server := api_bitwindowd.New(nil, nil, nil, nil, conf, func(context.Context, config.Network, string, uint32) error {
		t.Fatal("The failed status call must stop the network update.")
		return nil
	})

	_, err := server.UpdateNetwork(t.Context(), connect.NewRequest(&pb.UpdateNetworkRequest{Network: "ecash", NetworkId: "betanet"}))
	require.ErrorContains(t, err, "The migration status is unavailable.")
	require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
	var calls []string
	for len(handler.calls) > 0 {
		calls = append(calls, <-handler.calls)
	}
	require.Equal(t, []string{"plan:betanet", "status"}, calls)
}
