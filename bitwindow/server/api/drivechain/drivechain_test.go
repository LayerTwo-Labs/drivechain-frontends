package api_drivechain_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1/drivechainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

func TestService_ListSidechains(t *testing.T) {
	t.Parallel()

	t.Run("returns sidechains from enforcer", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)

		// Mock GetChainTip
		mockValidator.EXPECT().
			GetChainTip(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetChainTipResponse]{
				Msg: &mainchainv1.GetChainTipResponse{
					BlockHeaderInfo: &mainchainv1.BlockHeaderInfo{
						Height: 100,
						BlockHash: &commonv1.ReverseHex{
							Hex: wrapperspb.String("0000000000000000000000000000000000000000000000000000000000000001"),
						},
					},
				},
			}, nil)

		// Mock GetSidechains
		mockValidator.EXPECT().
			GetSidechains(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetSidechainsResponse]{
				Msg: &mainchainv1.GetSidechainsResponse{
					Sidechains: []*mainchainv1.GetSidechainsResponse_SidechainInfo{
						{
							SidechainNumber: wrapperspb.UInt32(0),
							Declaration: &mainchainv1.SidechainDeclaration{
								SidechainDeclaration: &mainchainv1.SidechainDeclaration_V0_{
									V0: &mainchainv1.SidechainDeclaration_V0{
										Title:       wrapperspb.String("Test Sidechain"),
										Description: wrapperspb.String("A test sidechain"),
										HashId_1: &commonv1.ConsensusHex{
											Hex: wrapperspb.String("0000000000000000000000000000000000000000000000000000000000000000"),
										},
										HashId_2: &commonv1.Hex{
											Hex: wrapperspb.String("0000000000000000000000000000000000000000"),
										},
									},
								},
							},
							Description: &commonv1.ConsensusHex{
								Hex: wrapperspb.String("deadbeef"),
							},
							VoteCount:        wrapperspb.UInt32(100),
							ProposalHeight:   wrapperspb.UInt32(50),
							ActivationHeight: wrapperspb.UInt32(60),
						},
					},
				},
			}, nil)

		// Mock GetCtip for sidechain 0
		mockValidator.EXPECT().
			GetCtip(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetCtipResponse]{
				Msg: &mainchainv1.GetCtipResponse{
					Ctip: &mainchainv1.GetCtipResponse_Ctip{
						Txid: &commonv1.ReverseHex{
							Hex: wrapperspb.String("1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"),
						},
						Vout:           0,
						Value:          1000000,
						SequenceNumber: 1,
					},
				},
			}, nil)

		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db, apitests.WithValidator(mockValidator)))

		resp, err := cli.ListSidechains(context.Background(), connect.NewRequest(&pb.ListSidechainsRequest{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Sidechains, 1)
		assert.Equal(t, "Test Sidechain", resp.Msg.Sidechains[0].Title)
		assert.Equal(t, uint32(0), resp.Msg.Sidechains[0].Slot)
	})

	t.Run("handles empty sidechains", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)

		mockValidator.EXPECT().
			GetChainTip(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetChainTipResponse]{
				Msg: &mainchainv1.GetChainTipResponse{
					BlockHeaderInfo: &mainchainv1.BlockHeaderInfo{
						Height: 100,
						BlockHash: &commonv1.ReverseHex{
							Hex: wrapperspb.String("0000000000000000000000000000000000000000000000000000000000000001"),
						},
					},
				},
			}, nil)

		mockValidator.EXPECT().
			GetSidechains(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetSidechainsResponse]{
				Msg: &mainchainv1.GetSidechainsResponse{
					Sidechains: []*mainchainv1.GetSidechainsResponse_SidechainInfo{},
				},
			}, nil)

		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db, apitests.WithValidator(mockValidator)))

		resp, err := cli.ListSidechains(context.Background(), connect.NewRequest(&pb.ListSidechainsRequest{}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.Sidechains)
	})

	t.Run("handles GetChainTip error", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)

		mockValidator.EXPECT().
			GetChainTip(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, nil))

		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db, apitests.WithValidator(mockValidator)))

		_, err := cli.ListSidechains(context.Background(), connect.NewRequest(&pb.ListSidechainsRequest{}))
		require.Error(t, err)
	})
}

func TestService_ListSidechainProposals(t *testing.T) {
	t.Parallel()

	t.Run("returns proposals from enforcer", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)

		mockValidator.EXPECT().
			GetChainTip(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetChainTipResponse]{
				Msg: &mainchainv1.GetChainTipResponse{
					BlockHeaderInfo: &mainchainv1.BlockHeaderInfo{
						Height: 100,
						BlockHash: &commonv1.ReverseHex{
							Hex: wrapperspb.String("0000000000000000000000000000000000000000000000000000000000000001"),
						},
					},
				},
			}, nil)

		mockValidator.EXPECT().
			GetSidechainProposals(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetSidechainProposalsResponse]{
				Msg: &mainchainv1.GetSidechainProposalsResponse{
					SidechainProposals: []*mainchainv1.GetSidechainProposalsResponse_SidechainProposal{
						{
							SidechainNumber: wrapperspb.UInt32(5),
							Description: &commonv1.ConsensusHex{
								Hex: wrapperspb.String("deadbeef"),
							},
							DescriptionSha256DHash: &commonv1.ReverseHex{
								Hex: wrapperspb.String("abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234"),
							},
							VoteCount:      wrapperspb.UInt32(50),
							ProposalHeight: wrapperspb.UInt32(80),
							ProposalAge:    wrapperspb.UInt32(20),
						},
					},
				},
			}, nil)

		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db, apitests.WithValidator(mockValidator)))

		resp, err := cli.ListSidechainProposals(context.Background(), connect.NewRequest(&pb.ListSidechainProposalsRequest{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Proposals, 1)
		assert.Equal(t, uint32(5), resp.Msg.Proposals[0].Slot)
		assert.Equal(t, uint32(50), resp.Msg.Proposals[0].VoteCount)
	})

	t.Run("handles empty proposals", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)

		mockValidator.EXPECT().
			GetChainTip(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetChainTipResponse]{
				Msg: &mainchainv1.GetChainTipResponse{
					BlockHeaderInfo: &mainchainv1.BlockHeaderInfo{
						Height: 100,
						BlockHash: &commonv1.ReverseHex{
							Hex: wrapperspb.String("0000000000000000000000000000000000000000000000000000000000000001"),
						},
					},
				},
			}, nil)

		mockValidator.EXPECT().
			GetSidechainProposals(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetSidechainProposalsResponse]{
				Msg: &mainchainv1.GetSidechainProposalsResponse{
					SidechainProposals: []*mainchainv1.GetSidechainProposalsResponse_SidechainProposal{},
				},
			}, nil)

		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db, apitests.WithValidator(mockValidator)))

		resp, err := cli.ListSidechainProposals(context.Background(), connect.NewRequest(&pb.ListSidechainProposalsRequest{}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.Proposals)
	})
}

func TestService_ProposeSidechain(t *testing.T) {
	t.Parallel()

	t.Run("validates slot range", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db))

		_, err := cli.ProposeSidechain(context.Background(), connect.NewRequest(&pb.ProposeSidechainRequest{
			Slot:  256, // invalid, must be 0-255
			Title: "Test",
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("requires title", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db))

		_, err := cli.ProposeSidechain(context.Background(), connect.NewRequest(&pb.ProposeSidechainRequest{
			Slot:  0,
			Title: "", // empty title
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("validates hashid1 length", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db))

		_, err := cli.ProposeSidechain(context.Background(), connect.NewRequest(&pb.ProposeSidechainRequest{
			Slot:    0,
			Title:   "Test",
			Hashid1: "tooshort", // must be 64 hex chars
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("validates hashid2 length", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db))

		_, err := cli.ProposeSidechain(context.Background(), connect.NewRequest(&pb.ProposeSidechainRequest{
			Slot:    0,
			Title:   "Test",
			Hashid2: "tooshort", // must be 40 hex chars
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}

func TestService_ListWithdrawals(t *testing.T) {
	t.Parallel()

	t.Run("sidechain not found", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)

		mockValidator.EXPECT().
			GetChainTip(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetChainTipResponse]{
				Msg: &mainchainv1.GetChainTipResponse{
					BlockHeaderInfo: &mainchainv1.BlockHeaderInfo{
						Height: 100,
						BlockHash: &commonv1.ReverseHex{
							Hex: wrapperspb.String("0000000000000000000000000000000000000000000000000000000000000001"),
						},
					},
				},
			}, nil)

		mockValidator.EXPECT().
			GetSidechains(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetSidechainsResponse]{
				Msg: &mainchainv1.GetSidechainsResponse{
					Sidechains: []*mainchainv1.GetSidechainsResponse_SidechainInfo{},
				},
			}, nil)

		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db, apitests.WithValidator(mockValidator)))

		_, err := cli.ListWithdrawals(context.Background(), connect.NewRequest(&pb.ListWithdrawalsRequest{
			SidechainId: 99, // non-existent
		}))
		require.Error(t, err)
		assert.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
	})

	t.Run("returns empty withdrawals for new sidechain", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctrl := gomock.NewController(t)

		mockValidator := mocks.NewMockValidatorServiceClient(ctrl)

		mockValidator.EXPECT().
			GetChainTip(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetChainTipResponse]{
				Msg: &mainchainv1.GetChainTipResponse{
					BlockHeaderInfo: &mainchainv1.BlockHeaderInfo{
						Height: 100,
						BlockHash: &commonv1.ReverseHex{
							Hex: wrapperspb.String("0000000000000000000000000000000000000000000000000000000000000001"),
						},
					},
				},
			}, nil)

		mockValidator.EXPECT().
			GetSidechains(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetSidechainsResponse]{
				Msg: &mainchainv1.GetSidechainsResponse{
					Sidechains: []*mainchainv1.GetSidechainsResponse_SidechainInfo{
						{
							SidechainNumber:  wrapperspb.UInt32(0),
							ActivationHeight: wrapperspb.UInt32(50),
							Declaration: &mainchainv1.SidechainDeclaration{
								SidechainDeclaration: &mainchainv1.SidechainDeclaration_V0_{
									V0: &mainchainv1.SidechainDeclaration_V0{
										Title: wrapperspb.String("Test"),
									},
								},
							},
						},
					},
				},
			}, nil)

		// Mock GetBlockHeaderInfo for activation block lookup
		mockValidator.EXPECT().
			GetBlockHeaderInfo(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetBlockHeaderInfoResponse]{
				Msg: &mainchainv1.GetBlockHeaderInfoResponse{
					HeaderInfos: []*mainchainv1.BlockHeaderInfo{
						{
							Height: 50,
							BlockHash: &commonv1.ReverseHex{
								Hex: wrapperspb.String("0000000000000000000000000000000000000000000000000000000000000050"),
							},
						},
					},
				},
			}, nil)

		// Mock GetTwoWayPegData
		mockValidator.EXPECT().
			GetTwoWayPegData(gomock.Any(), gomock.Any()).
			Return(&connect.Response[mainchainv1.GetTwoWayPegDataResponse]{
				Msg: &mainchainv1.GetTwoWayPegDataResponse{
					Blocks: []*mainchainv1.GetTwoWayPegDataResponse_ResponseItem{},
				},
			}, nil)

		cli := rpc.NewDrivechainServiceClient(apitests.API(t, db, apitests.WithValidator(mockValidator)))

		resp, err := cli.ListWithdrawals(context.Background(), connect.NewRequest(&pb.ListWithdrawalsRequest{
			SidechainId: 0,
		}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.Bundles)
	})
}
