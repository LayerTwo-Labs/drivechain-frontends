package api

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/stretchr/testify/require"
)

func TestGetForkStatusReportsTheNetworkReplayLockTime(t *testing.T) {
	for _, lockTime := range []uint32{499999999, 499999998} {
		previous := config.ECashEndpoints()
		entry := previous
		entry.ReplayLockTime = lockTime
		config.SetECashEndpoints(entry)

		response, err := NewHandler(&orchestrator.Orchestrator{Network: "ecash"}).
			GetForkStatus(context.Background(), connect.NewRequest(&pb.GetForkStatusRequest{}))
		config.SetECashEndpoints(previous)
		require.NoError(t, err)
		require.Equal(t, lockTime, response.Msg.ReplayLockTime)
	}
}
