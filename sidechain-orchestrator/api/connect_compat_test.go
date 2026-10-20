package api

import (
	"net/http"
	"net/http/httptest"
	"testing"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestV1ClientReadsNetworkPlanError(t *testing.T) {
	home := config.HomeDir()
	if home == config.UserHomeDir() {
		home = ""
	}
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir(home) })
	orch := orchestrator.New(t.TempDir(), "signet", t.TempDir(), nil, zerolog.Nop())
	orch.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, "")
	server := connect.NewServer()
	rpc.RegisterBitcoinConfServiceHandler(server, NewBitcoinConfHandler(orch))
	mux := http.NewServeMux()
	connecthttp.Mount(mux, server, connecthttp.WithReadMaxBytes(0))
	httpServer := httptest.NewUnstartedServer(mux)
	httpServer.EnableHTTP2 = true
	httpServer.StartTLS()
	t.Cleanup(httpServer.Close)

	for _, protocol := range []struct {
		name    string
		options []connectv1.ClientOption
	}{
		{name: "Connect"},
		{name: "gRPC", options: []connectv1.ClientOption{connectv1.WithGRPC()}},
		{name: "gRPC-Web", options: []connectv1.ClientOption{connectv1.WithGRPCWeb()}},
	} {
		t.Run(protocol.name, func(t *testing.T) {
			client := connectv1.NewClient[pb.SetBitcoinConfigNetworkRequest, pb.SetBitcoinConfigNetworkResponse](
				httpServer.Client(), httpServer.URL+rpc.BitcoinConfServiceSetBitcoinConfigNetworkProcedure, protocol.options...,
			)
			_, err := client.CallUnary(t.Context(), connectv1.NewRequest(&pb.SetBitcoinConfigNetworkRequest{Network: "ecash"}))
			var rpcErr *connectv1.Error
			require.ErrorAs(t, err, &rpcErr)
			require.Equal(t, connectv1.CodeFailedPrecondition, rpcErr.Code())
			require.Equal(t, "datadir not configured for ecash", rpcErr.Message())
			require.Len(t, rpcErr.Details(), 1)
			detail, err := rpcErr.Details()[0].Value()
			require.NoError(t, err)
			plan, ok := detail.(*pb.NetworkChangePlan)
			require.True(t, ok)
			require.Equal(t, "ecash", plan.Network)
			require.True(t, plan.MustSelectDatadir)
			require.Equal(t, string(config.DatadirGroupECash), plan.DatadirGroup)
		})
	}
}
