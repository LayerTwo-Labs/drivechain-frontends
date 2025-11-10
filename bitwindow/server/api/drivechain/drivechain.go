package api_drivechain

import (
	"context"
	"fmt"
	"io"

	"connectrpc.com/connect"
	commonpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
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
	wallet *service.Service[validatorrpc.WalletServiceClient],
) *Server {
	s := &Server{
		validator: validator,
		wallet:    wallet,
	}
	return s
}

type Server struct {
	validator *service.Service[validatorrpc.ValidatorServiceClient]
	wallet    *service.Service[validatorrpc.WalletServiceClient]
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

// ProposeSidechain implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ProposeSidechain(
	ctx context.Context,
	c *connect.Request[pb.ProposeSidechainRequest],
) (*connect.Response[pb.ProposeSidechainResponse], error) {
	// Validation
	if c.Msg.Slot > 255 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("slot must be 0-255"))
	}
	if c.Msg.Title == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("title required"))
	}
	if c.Msg.Hashid1 != "" && len(c.Msg.Hashid1) != 64 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("hashid1 must be 64 hex chars (256 bits)"))
	}
	if c.Msg.Hashid2 != "" && len(c.Msg.Hashid2) != 40 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("hashid2 must be 40 hex chars (160 bits)"))
	}

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable,
			fmt.Errorf("wallet unavailable: %w", err))
	}

	// Build SidechainDeclaration V0
	declarationV0 := &validatorpb.SidechainDeclaration_V0{
		Title:       wrapperspb.String(c.Msg.Title),
		Description: wrapperspb.String(c.Msg.Description),
	}

	// Add hash IDs if provided
	if c.Msg.Hashid1 != "" {
		declarationV0.HashId_1 = &commonpb.ConsensusHex{
			Hex: wrapperspb.String(c.Msg.Hashid1),
		}
	}
	if c.Msg.Hashid2 != "" {
		declarationV0.HashId_2 = &commonpb.Hex{
			Hex: wrapperspb.String(c.Msg.Hashid2),
		}
	}

	declaration := &validatorpb.SidechainDeclaration{
		SidechainDeclaration: &validatorpb.SidechainDeclaration_V0_{
			V0: declarationV0,
		},
	}

	// Call wallet's CreateSidechainProposal - this returns a stream
	proposalReq := &validatorpb.CreateSidechainProposalRequest{
		SidechainId: wrapperspb.UInt32(c.Msg.Slot),
		Declaration: declaration,
	}

	stream, err := wallet.CreateSidechainProposal(ctx, connect.NewRequest(proposalReq))
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("propose sidechain failed")
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("propose sidechain: %w", err))
	}

	// Read the first response from the stream to confirm it was accepted
	// The stream will continue sending updates as the proposal gets mined
	if stream.Receive() {
		response := stream.Msg()
		zerolog.Ctx(ctx).Info().
			Uint32("slot", c.Msg.Slot).
			Interface("response", response).
			Msg("sidechain proposal created")
	}

	// Close the stream since we only need confirmation
	if err := stream.Close(); err != nil && err != io.EOF {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("error closing proposal stream")
	}

	return connect.NewResponse(&pb.ProposeSidechainResponse{
		Success: true,
		Message: fmt.Sprintf("Sidechain %d proposal created. Will be included in the next mined block.", c.Msg.Slot),
	}), nil
}

// ListWithdrawals implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListWithdrawals(
	ctx context.Context,
	c *connect.Request[pb.ListWithdrawalsRequest],
) (*connect.Response[pb.ListWithdrawalsResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable,
			fmt.Errorf("validator unavailable: %w", err))
	}

	pegData, err := validator.GetTwoWayPegData(ctx, connect.NewRequest(&validatorpb.GetTwoWayPegDataRequest{
		SidechainId: wrapperspb.UInt32(c.Msg.SidechainId),
	}))
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get two-way peg data")
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("get two-way peg data: %w", err))
	}

	bundles := make([]*pb.WithdrawalBundle, 0)

	// Process blocks and extract withdrawal bundle events
	for _, block := range pegData.Msg.Blocks {
		if block.BlockInfo == nil || block.BlockHeaderInfo == nil {
			continue
		}

		blockHeight := block.BlockHeaderInfo.Height

		// Iterate through events and find withdrawal bundles
		for _, event := range block.BlockInfo.Events {
			withdrawalEvent := event.GetWithdrawalBundle()
			if withdrawalEvent == nil {
				continue
			}

			bundle := &pb.WithdrawalBundle{
				M6Id:        withdrawalEvent.M6Id.Hex.Value,
				SidechainId: c.Msg.SidechainId,
				BlockHeight: blockHeight,
			}

			// Determine status based on event type
			switch e := withdrawalEvent.Event.Event.(type) {
			case *validatorpb.WithdrawalBundleEvent_Event_Succeeded_:
				bundle.Status = "succeeded"
				if e.Succeeded.SequenceNumber != nil {
					bundle.SequenceNumber = e.Succeeded.SequenceNumber.Value
				}
				if e.Succeeded.Transaction != nil {
					bundle.TransactionHex = e.Succeeded.Transaction.Hex.Value
				}
			case *validatorpb.WithdrawalBundleEvent_Event_Failed_:
				bundle.Status = "failed"
			default:
				bundle.Status = "pending"
			}

			bundles = append(bundles, bundle)
		}
	}

	return connect.NewResponse(&pb.ListWithdrawalsResponse{
		Bundles: bundles,
	}), nil
}
