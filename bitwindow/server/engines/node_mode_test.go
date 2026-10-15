package engines_test

import (
	"context"
	"errors"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
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

	return engines.NewNodeMode(client)
}

// The whole point of the gate: a light-mode install runs no Bitcoin Core, so
// every poller must stop before it dials one.
func TestRunsLocalNodeStopsOnLightMode(t *testing.T) {
	nodeMode := nodeModeWith(t, orchpb.NodeMode_NODE_MODE_LIGHT, nil)
	require.False(t, nodeMode.RunsLocalNode(t.Context()))
}

func TestRunsLocalNodeAllowsFullMode(t *testing.T) {
	nodeMode := nodeModeWith(t, orchpb.NodeMode_NODE_MODE_FULL, nil)
	require.True(t, nodeMode.RunsLocalNode(t.Context()))
}

// A fresh install reads an unpicked mode until the user chooses, and it starts
// no daemon meanwhile. Polling there dials a Bitcoin Core that is not there.
func TestRunsLocalNodeStopsOnAnUnpickedMode(t *testing.T) {
	nodeMode := nodeModeWith(t, orchpb.NodeMode_NODE_MODE_UNSPECIFIED, nil)
	require.False(t, nodeMode.RunsLocalNode(t.Context()))
}

// An orchestrator restart must not restart the pollers a light-mode user
// stopped. The last known answer stands until a read succeeds.
func TestRunsLocalNodeKeepsTheLastAnswer(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	nodeMode := engines.NewNodeMode(client)

	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_LIGHT},
		}, nil)
	require.False(t, nodeMode.RunsLocalNode(t.Context()))

	engines.ExpireNodeModeCache(nodeMode)
	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(nil, errors.New("orchestrator is restarting"))
	require.False(t, nodeMode.RunsLocalNode(t.Context()))
}

// A full-mode install keeps its pollers through an orchestrator restart.
func TestRunsLocalNodeKeepsAFullAnswer(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	nodeMode := engines.NewNodeMode(client)

	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_FULL},
		}, nil)
	require.True(t, nodeMode.RunsLocalNode(t.Context()))

	engines.ExpireNodeModeCache(nodeMode)
	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(nil, errors.New("orchestrator is restarting"))
	require.True(t, nodeMode.RunsLocalNode(t.Context()))
}

// One read per TTL. Every engine ticks each second, and each tick asks.
func TestModeCachesTheRead(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	nodeMode := engines.NewNodeMode(client)

	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Times(1).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_FULL},
		}, nil)

	for range 5 {
		require.True(t, nodeMode.RunsLocalNode(t.Context()))
	}
}

// A user who switches to full mode gets the pollers back without a restart.
func TestModeReReadsAfterTheCacheExpires(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	nodeMode := engines.NewNodeMode(client)

	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_LIGHT},
		}, nil)
	require.False(t, nodeMode.RunsLocalNode(t.Context()))

	engines.ExpireNodeModeCache(nodeMode)
	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_FULL},
		}, nil)
	require.True(t, nodeMode.RunsLocalNode(t.Context()))
}

// Four pollers expire the cache together. One read serves them all, and an
// older answer cannot land last and overwrite a newer one.
func TestModeCollapsesConcurrentReads(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	nodeMode := engines.NewNodeMode(client)

	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		Times(1).
		DoAndReturn(func(context.Context, *connect.Request[orchpb.GetNodeModeRequest]) (*connect.Response[orchpb.GetNodeModeResponse], error) {
			time.Sleep(100 * time.Millisecond)
			return &connect.Response[orchpb.GetNodeModeResponse]{
				Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_FULL},
			}, nil
		})

	var wg sync.WaitGroup
	answers := make([]bool, 4)
	for i := range answers {
		wg.Add(1)
		go func() {
			defer wg.Done()
			answers[i] = nodeMode.RunsLocalNode(t.Context())
		}()
	}
	wg.Wait()

	for i, answer := range answers {
		require.Truef(t, answer, "reader %d read the wrong mode", i)
	}
}
