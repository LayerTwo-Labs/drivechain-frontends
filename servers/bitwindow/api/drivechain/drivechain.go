package api_drivechain

import (
	"context"
	"errors"

	"connectrpc.com/connect"
	validatorpb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1/mainchainv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/drivechain/v1/drivechainv1connect"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.DrivechainServiceHandler = new(Server)

// New creates a new Server
func New(
	bitcoind *coreproxy.Bitcoind, enforcer validatorrpc.ValidatorServiceClient,

) *Server {
	s := &Server{
		bitcoind: bitcoind, enforcer: enforcer,
	}
	return s
}

type Server struct {
	bitcoind *coreproxy.Bitcoind
	enforcer validatorrpc.ValidatorServiceClient
}

// ListSidechainProposals implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListSidechainProposals(ctx context.Context, c *connect.Request[pb.ListSidechainProposalsRequest]) (*connect.Response[pb.ListSidechainProposalsResponse], error) {
	if s.enforcer == nil {
		return nil, errors.New("enforcer not connected")
	}

	sidechainProposals, err := s.enforcer.GetSidechainProposals(ctx, connect.NewRequest(&validatorpb.GetSidechainProposalsRequest{}))
	if err != nil {
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
	if s.enforcer == nil {
		return nil, errors.New("enforcer not connected")
	}

	sidechains, err := s.enforcer.GetSidechains(ctx, connect.NewRequest(&validatorpb.GetSidechainsRequest{}))
	if err != nil {
		return nil, err
	}

	// Loop over all sidechains and get their chaintiptxid using s.enforcer.GetCtip()
	sidechainList := make([]*pb.ListSidechainsResponse_Sidechain, 0, len(sidechains.Msg.Sidechains))
	for _, sidechain := range sidechains.Msg.Sidechains {
		ctipResponse, err := s.enforcer.GetCtip(ctx, connect.NewRequest(
			&validatorpb.GetCtipRequest{SidechainNumber: wrapperspb.UInt32(sidechain.SidechainNumber.Value)},
		))
		if err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Uint32("sidechain", sidechain.SidechainNumber.Value).Msg("failed to get ctip")
			continue
		}

		// Decode the txid using chainhash.NewHashFromStr
		txidHash, err := chainhash.NewHashFromStr(string(ctipResponse.Msg.Ctip.Txid.Hex.String()))
		if err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("failed to decode txid")
			continue
		}

		sidechainList = append(sidechainList, &pb.ListSidechainsResponse_Sidechain{
			Title:         sidechain.Description.String(),
			Description:   sidechain.Description.String(),
			Nversion:      uint32(ctipResponse.Msg.Ctip.SequenceNumber),
			Hashid1:       sidechain.Description.String(),
			Hashid2:       sidechain.Description.String(),
			Slot:          int32(sidechain.SidechainNumber.Value),
			AmountSatoshi: int64(ctipResponse.Msg.Ctip.Value),
			ChaintipTxid:  txidHash.String(),
			ChaintipVout:  uint32(ctipResponse.Msg.Ctip.Vout),
		})
	}

	return connect.NewResponse(&pb.ListSidechainsResponse{
		Sidechains: sidechainList,
	}), nil
}
