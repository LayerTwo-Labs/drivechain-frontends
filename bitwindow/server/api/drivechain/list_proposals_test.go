package api_drivechain

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	v1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

// fakeValidator stubs the two RPCs ListSidechainProposals reads. The embedded
// interface covers the rest, which this test never calls.
type fakeValidator struct {
	validatorrpc.ValidatorServiceClient
	chainTipCalls int
	proposalCalls int
}

func (f *fakeValidator) GetChainTip(context.Context, *connect.Request[v1.GetChainTipRequest]) (*connect.Response[v1.GetChainTipResponse], error) {
	f.chainTipCalls++
	return connect.NewResponse(&v1.GetChainTipResponse{
		BlockHeaderInfo: &v1.BlockHeaderInfo{
			BlockHash: &commonpb.ReverseHex{Hex: wrapperspb.String("deadbeef")},
		},
	}), nil
}

func (f *fakeValidator) GetSidechainProposals(context.Context, *connect.Request[v1.GetSidechainProposalsRequest]) (*connect.Response[v1.GetSidechainProposalsResponse], error) {
	f.proposalCalls++
	return connect.NewResponse(&v1.GetSidechainProposalsResponse{}), nil
}

func TestListSidechainProposalsReadsTheEnforcer(t *testing.T) {
	fake := &fakeValidator{}
	s := &Server{
		enforcer: service.New("test-enforcer", func(context.Context) (validatorrpc.ValidatorServiceClient, error) {
			return fake, nil
		}),
	}

	resp, err := s.ListSidechainProposals(context.Background(), connect.NewRequest(&pb.ListSidechainProposalsRequest{}))
	require.NoError(t, err)
	require.NotNil(t, resp)
	require.Empty(t, resp.Msg.Proposals)
	require.Equal(t, 1, fake.chainTipCalls)
	require.Equal(t, 1, fake.proposalCalls)
}
