package api_drivechain

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/datasource"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	v1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

// fakeReader is an injectable datasource.DrivechainReader. The embedded
// interface satisfies the unused methods (they panic if called, which they
// aren't here), so the test only has to stub what the handler reads.
type fakeReader struct {
	datasource.DrivechainReader
	chainTipCalls int
	proposalCalls int
}

func (f *fakeReader) ChainTip(context.Context, *v1.GetChainTipRequest) (*v1.GetChainTipResponse, error) {
	f.chainTipCalls++
	return &v1.GetChainTipResponse{
		BlockHeaderInfo: &v1.BlockHeaderInfo{
			BlockHash: &commonpb.ReverseHex{Hex: wrapperspb.String("deadbeef")},
		},
	}, nil
}

func (f *fakeReader) SidechainProposals(context.Context, *v1.GetSidechainProposalsRequest) (*v1.GetSidechainProposalsResponse, error) {
	f.proposalCalls++
	return &v1.GetSidechainProposalsResponse{}, nil
}

// TestHandlerReadsThroughDataSource proves the handler no longer depends on raw
// Core/enforcer clients — a fake DrivechainReader fully drives it. This is the
// seam a future remote DataSource implementation drops into.
func TestHandlerReadsThroughDataSource(t *testing.T) {
	fake := &fakeReader{}
	s := &Server{data: fake}

	resp, err := s.ListSidechainProposals(context.Background(), connect.NewRequest(&pb.ListSidechainProposalsRequest{}))
	require.NoError(t, err)
	require.NotNil(t, resp)
	require.Empty(t, resp.Msg.Proposals)
	require.Equal(t, 1, fake.chainTipCalls, "handler must read chain tip via the injected DataSource")
	require.Equal(t, 1, fake.proposalCalls, "handler must read proposals via the injected DataSource")
}
