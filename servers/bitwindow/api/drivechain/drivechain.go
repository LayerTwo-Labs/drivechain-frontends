package api_drivechain

import (
	"context"
	"encoding/hex"
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
		txidHash, err := chainhash.NewHashFromStr(ctipResponse.Msg.Ctip.Txid.Hex.Value)
		if err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msgf("failed to decode txid: %s", ctipResponse.Msg.Ctip.Txid.Hex.Value)
			continue
		}

		// Decode the hex string description
		descBytes, err := hex.DecodeString(sidechain.Description.Hex.Value)
		if err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not decode sidechain description hex")
			continue
		}

		// First byte is length (80)
		if len(descBytes) < 1 {
			zerolog.Ctx(ctx).Error().Msg("description too short")
			continue
		}
		totalLen := int(descBytes[0])
		if totalLen != 80 {
			zerolog.Ctx(ctx).Error().Msgf("unsupported length: %d", totalLen)
			continue
		}
		descBytes = descBytes[1:] // Skip length byte

		// Parse the description bytes according to format:
		// <VERSION_0><TITLE_LENGTH><TITLE_UTF8_BYTES><DESCRIPTION_UTF8_BYTES><HASH_1><HASH_2>
		if len(descBytes) < 2 { // Need at least version and title length
			zerolog.Ctx(ctx).Error().Msg("description too short")
			continue
		}

		version := descBytes[0]
		if version != 0 {
			zerolog.Ctx(ctx).Error().Msgf("unsupported version: %d", version)
			continue
		}

		titleLen := int(descBytes[1])
		if len(descBytes) < 2+titleLen {
			zerolog.Ctx(ctx).Error().Msg("description too short for title")
			continue
		}
		title := string(descBytes[2 : 2+titleLen])

		// Description is the remaining bytes before the hashes
		// Total length is 80, minus:
		// - 1 byte version
		// - 1 byte title length
		// - titleLen bytes title
		// - 32 bytes hash1
		// - 20 bytes hash2
		descLen := 80 - (1 + 1 + titleLen + 32 + 20)
		if descLen < 0 {
			zerolog.Ctx(ctx).Error().Msg("invalid description length")
			continue
		}

		description := string(descBytes[2+titleLen : 2+titleLen+descLen])

		sidechainList = append(sidechainList, &pb.ListSidechainsResponse_Sidechain{
			Title:         title,
			Description:   description,
			Nversion:      uint32(ctipResponse.Msg.Ctip.SequenceNumber),
			Hashid1:       sidechain.Description.Hex.Value,
			Hashid2:       sidechain.Description.Hex.Value,
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
