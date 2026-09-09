package api_drivechain

import (
	"context"
	"fmt"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	walletpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

func TestLightModeReadsTheRemoteValidator(t *testing.T) {
	ctrl := gomock.NewController(t)
	walletClient := mocks.NewMockWalletManagerServiceClient(ctrl)
	walletClient.EXPECT().GetNodeMode(gomock.Any(), gomock.Any()).AnyTimes().Return(
		connect.NewResponse(&walletpb.GetNodeModeResponse{Mode: walletpb.NodeMode_NODE_MODE_LIGHT}), nil,
	)
	walletEngine := engines.NewWalletEngine(nil, t.TempDir(), &chaincfg.RegressionNetParams)
	walletEngine.SetOrchestratorClient(walletClient)
	mode, err := walletEngine.NodeMode().Mode(t.Context())
	require.NoError(t, err)
	require.Equal(t, walletpb.NodeMode_NODE_MODE_LIGHT, mode)

	validator := mocks.NewMockValidatorServiceClient(ctrl)
	validator.EXPECT().GetChainTip(gomock.Any(), gomock.Any()).Times(3).Return(
		nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("remote validator is unavailable")),
	)
	client := service.New("validator", func(context.Context) (enforcerrpc.ValidatorServiceClient, error) {
		return validator, nil
	})
	server := New(client, nil, walletEngine)

	_, err = server.ListSidechains(t.Context(), connect.NewRequest(&pb.ListSidechainsRequest{}))
	require.ErrorContains(t, err, "remote validator is unavailable")
	_, err = server.ListSidechainProposals(t.Context(), connect.NewRequest(&pb.ListSidechainProposalsRequest{}))
	require.ErrorContains(t, err, "remote validator is unavailable")
	_, err = server.ListWithdrawals(t.Context(), connect.NewRequest(&pb.ListWithdrawalsRequest{SidechainId: 9}))
	require.ErrorContains(t, err, "remote validator is unavailable")
}
