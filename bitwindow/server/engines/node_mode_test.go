package engines_test

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

func nodeModeWith(t *testing.T, mode orchpb.NodeMode, err error) *engines.NodeMode {
	t.Helper()
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: mode},
		}, err)

	nodeMode := engines.NewNodeMode()
	nodeMode.SetClient(client)
	return nodeMode
}

// The whole point of the gate: a light-mode install runs no Bitcoin Core, so
// every poller must stop before it dials one.
func TestRunsLocalNodeStopsOnLightMode(t *testing.T) {
	nodeMode := nodeModeWith(t, orchpb.NodeMode_NODE_MODE_LIGHT, nil)
	require.False(t, nodeMode.RunsLocalNode(context.Background()))
}

func TestRunsLocalNodeAllowsFullMode(t *testing.T) {
	nodeMode := nodeModeWith(t, orchpb.NodeMode_NODE_MODE_FULL, nil)
	require.True(t, nodeMode.RunsLocalNode(context.Background()))
}

// A fresh install reads an unpicked mode until the user chooses, and it starts
// no daemon meanwhile. Polling there dials a Bitcoin Core that is not there.
func TestRunsLocalNodeStopsOnAnUnpickedMode(t *testing.T) {
	nodeMode := nodeModeWith(t, orchpb.NodeMode_NODE_MODE_UNSPECIFIED, nil)
	require.False(t, nodeMode.RunsLocalNode(context.Background()))
}

// An engine with no source has no mode to obey. It keeps its old behaviour.
func TestRunsLocalNodeAllowsANilSource(t *testing.T) {
	var nodeMode *engines.NodeMode
	require.True(t, nodeMode.RunsLocalNode(context.Background()))
}

// An orchestrator restart must not restart the pollers a light-mode user
// stopped. The last known answer stands until a read succeeds.
func TestRunsLocalNodeKeepsTheLastAnswer(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	nodeMode := engines.NewNodeMode()
	nodeMode.SetClient(client)

	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_LIGHT},
		}, nil)
	require.False(t, nodeMode.RunsLocalNode(context.Background()))

	engines.ExpireNodeModeCache(nodeMode)
	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(nil, errors.New("orchestrator is restarting"))
	require.False(t, nodeMode.RunsLocalNode(context.Background()))
}

// A full-mode install keeps its pollers through an orchestrator restart.
func TestRunsLocalNodeKeepsAFullAnswer(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	nodeMode := engines.NewNodeMode()
	nodeMode.SetClient(client)

	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_FULL},
		}, nil)
	require.True(t, nodeMode.RunsLocalNode(context.Background()))

	engines.ExpireNodeModeCache(nodeMode)
	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(nil, errors.New("orchestrator is restarting"))
	require.True(t, nodeMode.RunsLocalNode(context.Background()))
}

// One read per TTL. Every engine ticks each second, and each tick asks.
func TestModeCachesTheRead(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	nodeMode := engines.NewNodeMode()
	nodeMode.SetClient(client)

	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Times(1).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_FULL},
		}, nil)

	for range 5 {
		require.True(t, nodeMode.RunsLocalNode(context.Background()))
	}
}

// A user who switches to full mode gets the pollers back without a restart.
func TestModeReReadsAfterTheCacheExpires(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	nodeMode := engines.NewNodeMode()
	nodeMode.SetClient(client)

	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_LIGHT},
		}, nil)
	require.False(t, nodeMode.RunsLocalNode(context.Background()))

	engines.ExpireNodeModeCache(nodeMode)
	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_FULL},
		}, nil)
	require.True(t, nodeMode.RunsLocalNode(context.Background()))
}

// A source with no client cannot answer, so a gated RPC must refuse.
func TestRequireFullNodeNeedsAClient(t *testing.T) {
	nodeMode := engines.NewNodeMode()
	err := nodeMode.RequireFullNode(context.Background(), "proposing a sidechain")
	require.Error(t, err)
	require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
}
