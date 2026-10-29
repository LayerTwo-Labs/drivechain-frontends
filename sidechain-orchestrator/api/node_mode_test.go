package api

import (
	"context"
	"io"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

func TestBitcoinLightModeWithOrWithoutRemoteEnforcer(t *testing.T) {
	for network, remoteEnforcer := range map[config.Network]bool{config.NetworkMainnet: false, config.NetworkSignet: true} {
		t.Run(string(network), func(t *testing.T) {
			orch := orchestrator.New(t.TempDir(), string(network), t.TempDir(), nil, zerolog.New(io.Discard))
			require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeLight))
			handler := &WalletHandler{orch: orch}

			response, err := handler.GetNodeMode(context.Background(), &pb.GetNodeModeRequest{})

			require.NoError(t, err)
			require.Equal(t, pb.NodeMode_NODE_MODE_LIGHT, response.Mode)
			require.True(t, response.LightModeAvailable)
			require.Equal(t, remoteEnforcer, response.RemoteEnforcerAvailable)
		})
	}
}

func TestNodeModeUsesThePublishedRemoteEnforcer(t *testing.T) {
	network := config.NetworkMainnet
	original := config.PublishedEndpoints(network)
	t.Cleanup(func() { config.SetNetworkEndpoints(network, original) })
	orch := orchestrator.New(t.TempDir(), string(network), t.TempDir(), nil, zerolog.New(io.Discard))
	handler := &WalletHandler{orch: orch}

	for _, endpoint := range []string{"https://validator.example/enforcer", ""} {
		entry := original
		entry.Services.Enforcer = netcatalog.Endpoints{{URL: endpoint}}
		config.SetNetworkEndpoints(network, entry)

		response, err := handler.GetNodeMode(context.Background(), &pb.GetNodeModeRequest{})

		require.NoError(t, err)
		require.Equal(t, endpoint != "", response.RemoteEnforcerAvailable)
	}
}
