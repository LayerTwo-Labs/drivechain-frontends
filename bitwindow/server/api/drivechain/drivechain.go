package api_drivechain

import (
	"context"
	"fmt"

	"connectrpc.com/connect"
	validatorpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1/drivechainv1connect"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.DrivechainServiceHandler = new(Server)

// New creates a new Server
func New(
	validator *service.Service[validatorrpc.ValidatorServiceClient],
) *Server {
	s := &Server{
		validator: validator,
	}
	return s
}

type Server struct {
	validator *service.Service[validatorrpc.ValidatorServiceClient]
}

// ListSidechainProposals implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListSidechainProposals(ctx context.Context, c *connect.Request[pb.ListSidechainProposalsRequest]) (*connect.Response[pb.ListSidechainProposalsResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}

	sidechainProposals, err := validator.GetSidechainProposals(ctx, connect.NewRequest(&validatorpb.GetSidechainProposalsRequest{}))
	if err != nil {
		err = fmt.Errorf("enforcer/validator: could not get sidechain proposals: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get sidechain proposals")
		return nil, err
	}

	return connect.NewResponse(&pb.ListSidechainProposalsResponse{
		Proposals: lo.Map(sidechainProposals.Msg.SidechainProposals, func(proposal *validatorpb.GetSidechainProposalsResponse_SidechainProposal, _ int) *pb.SidechainProposal {

			return &pb.SidechainProposal{
				Slot:           proposal.SidechainNumber.Value,
				Data:           []byte(proposal.Description.Hex.Value),
				DataHash:       proposal.DescriptionSha256DHash.Hex.Value,
				VoteCount:      proposal.VoteCount.Value,
				ProposalHeight: proposal.ProposalHeight.Value,
				ProposalAge:    proposal.ProposalAge.Value,
			}
		}),
	}), nil
}

// ListSidechains implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListSidechains(ctx context.Context, _ *connect.Request[pb.ListSidechainsRequest]) (*connect.Response[pb.ListSidechainsResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}

	sidechains, err := validator.GetSidechains(ctx, connect.NewRequest(&validatorpb.GetSidechainsRequest{}))
	if err != nil {
		err = fmt.Errorf("enforcer/validator: could not get sidechains: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get sidechains")
		return nil, err
	}

	// Loop over all sidechains and get their chaintiptxid using s.enforcer.GetCtip()
	sidechainList := make([]*pb.ListSidechainsResponse_Sidechain, 0, len(sidechains.Msg.Sidechains))
	for _, sidechain := range sidechains.Msg.Sidechains {
		ctipResponse, err := validator.GetCtip(ctx, connect.NewRequest(
			&validatorpb.GetCtipRequest{SidechainNumber: wrapperspb.UInt32(sidechain.SidechainNumber.Value)},
		))
		if err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Uint32("sidechain", sidechain.SidechainNumber.Value).Msg("could not get ctip")
			continue
		}

		if ctipResponse.Msg.Ctip == nil || ctipResponse.Msg.Ctip.Txid == nil {
			zerolog.Ctx(ctx).Warn().Uint32("sidechain", sidechain.SidechainNumber.Value).Msg("ctip txid was empty, probably just too early")
			continue
		}

		// Decode the txid using chainhash.NewHashFromStr
		txidHash, err := chainhash.NewHashFromStr(ctipResponse.Msg.Ctip.Txid.Hex.Value)
		if err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msgf("could not decode txid: %s", ctipResponse.Msg.Ctip.Txid.Hex.Value)
			continue
		}

		declaration := sidechain.Declaration.GetV0()
		sidechainList = append(sidechainList, &pb.ListSidechainsResponse_Sidechain{
			Title:            declaration.Title.Value,
			Description:      declaration.Description.Value,
			Nversion:         uint32(ctipResponse.Msg.Ctip.SequenceNumber),
			Hashid1:          declaration.HashId_1.Hex.Value,
			Hashid2:          declaration.HashId_2.Hex.Value,
			Slot:             sidechain.SidechainNumber.Value,
			VoteCount:        sidechain.VoteCount.Value,
			ProposalHeight:   sidechain.ProposalHeight.Value,
			ActivationHeight: sidechain.ActivationHeight.Value,
			DescriptionHex:   sidechain.Description.Hex.Value,
			BalanceSatoshi:   int64(ctipResponse.Msg.Ctip.Value),
			ChaintipTxid:     txidHash.String(),
			ChaintipVout:     ctipResponse.Msg.Ctip.Vout,
		})
	}

	return connect.NewResponse(&pb.ListSidechainsResponse{
		Sidechains: sidechainList,
	}), nil
}
