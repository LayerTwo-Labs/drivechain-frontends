package api

import (
	"context"
	"io"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

func TestBitcoinLightModeWithoutRemoteEnforcer(t *testing.T) {
	for _, network := range []config.Network{config.NetworkMainnet, config.NetworkSignet} {
		t.Run(string(network), func(t *testing.T) {
			orch := orchestrator.New(t.TempDir(), string(network), t.TempDir(), nil, zerolog.New(io.Discard))
			require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeLight))
			handler := &WalletHandler{orch: orch}

			response, err := handler.GetNodeMode(context.Background(), connect.NewRequest(&pb.GetNodeModeRequest{}))

			require.NoError(t, err)
			require.Equal(t, pb.NodeMode_NODE_MODE_LIGHT, response.Msg.Mode)
			require.True(t, response.Msg.LightModeAvailable)
			require.False(t, response.Msg.RemoteEnforcerAvailable)
		})
	}
}

func TestNodeModeUsesThePublishedRemoteEnforcer(t *testing.T) {
	network := config.NetworkSignet
	original := config.PublishedEndpoints(network)
	t.Cleanup(func() { config.SetNetworkEndpoints(network, original) })
	orch := orchestrator.New(t.TempDir(), string(network), t.TempDir(), nil, zerolog.New(io.Discard))
	handler := &WalletHandler{orch: orch}

	for _, endpoint := range []string{"https://validator.example/enforcer", ""} {
		entry := original
		entry.Services.Enforcer.URL = endpoint
		config.SetNetworkEndpoints(network, entry)

		response, err := handler.GetNodeMode(context.Background(), connect.NewRequest(&pb.GetNodeModeRequest{}))

		require.NoError(t, err)
		require.Equal(t, endpoint != "", response.Msg.RemoteEnforcerAvailable)
	}
}
