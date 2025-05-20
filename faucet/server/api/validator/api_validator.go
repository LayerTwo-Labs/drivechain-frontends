package validator

import (
	"context"
	"errors"

	"connectrpc.com/connect"

	"github.com/LayerTwo-Labs/sidesail/faucet/server/connector"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/cusf/mainchain/v1"
	mainchainv1connect "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/cusf/mainchain/v1/mainchainv1connect"
)

var _ mainchainv1connect.ValidatorServiceHandler = new(Server)

type RpcClients struct {
	Validator *connector.Service[mainchainv1connect.ValidatorServiceClient]
}

func New(
	validator *connector.Service[mainchainv1connect.ValidatorServiceClient],
) *Server {
	return &Server{
		validator,
	}
}

type Server struct {
	validator *connector.Service[mainchainv1connect.ValidatorServiceClient]
}

// GetBlockHeaderInfo implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetBlockHeaderInfo(ctx context.Context, req *connect.Request[mainchainv1.GetBlockHeaderInfoRequest]) (*connect.Response[mainchainv1.GetBlockHeaderInfoResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetBlockHeaderInfo(ctx, req)
}

// GetBlockInfo implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetBlockInfo(ctx context.Context, req *connect.Request[mainchainv1.GetBlockInfoRequest]) (*connect.Response[mainchainv1.GetBlockInfoResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetBlockInfo(ctx, req)
}

// GetBmmHStarCommitment implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetBmmHStarCommitment(ctx context.Context, req *connect.Request[mainchainv1.GetBmmHStarCommitmentRequest]) (*connect.Response[mainchainv1.GetBmmHStarCommitmentResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetBmmHStarCommitment(ctx, req)
}

// GetChainInfo implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetChainInfo(ctx context.Context, req *connect.Request[mainchainv1.GetChainInfoRequest]) (*connect.Response[mainchainv1.GetChainInfoResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetChainInfo(ctx, req)
}

// GetChainTip implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetChainTip(ctx context.Context, req *connect.Request[mainchainv1.GetChainTipRequest]) (*connect.Response[mainchainv1.GetChainTipResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetChainTip(ctx, req)
}

// GetCoinbasePSBT implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetCoinbasePSBT(ctx context.Context, req *connect.Request[mainchainv1.GetCoinbasePSBTRequest]) (*connect.Response[mainchainv1.GetCoinbasePSBTResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetCoinbasePSBT(ctx, req)
}

// GetCtip implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetCtip(ctx context.Context, req *connect.Request[mainchainv1.GetCtipRequest]) (*connect.Response[mainchainv1.GetCtipResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetCtip(ctx, req)
}

// GetSidechainProposals implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetSidechainProposals(ctx context.Context, req *connect.Request[mainchainv1.GetSidechainProposalsRequest]) (*connect.Response[mainchainv1.GetSidechainProposalsResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetSidechainProposals(ctx, req)
}

// GetSidechains implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetSidechains(ctx context.Context, req *connect.Request[mainchainv1.GetSidechainsRequest]) (*connect.Response[mainchainv1.GetSidechainsResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetSidechains(ctx, req)
}

// GetTwoWayPegData implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetTwoWayPegData(ctx context.Context, req *connect.Request[mainchainv1.GetTwoWayPegDataRequest]) (*connect.Response[mainchainv1.GetTwoWayPegDataResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetTwoWayPegData(ctx, req)
}

// SubscribeEvents implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) SubscribeEvents(ctx context.Context, req *connect.Request[mainchainv1.SubscribeEventsRequest], stream *connect.ServerStream[mainchainv1.SubscribeEventsResponse]) error {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := validator.SubscribeEvents(ctx, req)
	if err != nil {
		return err
	}
	for clientStream.Receive() {
		if err := stream.Send(clientStream.Msg()); err != nil {
			return err
		}
	}
	return clientStream.Err()
}

// SubscribeHeaderSyncProgress implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) SubscribeHeaderSyncProgress(ctx context.Context, req *connect.Request[mainchainv1.SubscribeHeaderSyncProgressRequest], stream *connect.ServerStream[mainchainv1.SubscribeHeaderSyncProgressResponse]) error {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := validator.SubscribeHeaderSyncProgress(ctx, req)
	if err != nil {
		return err
	}
	for clientStream.Receive() {
		if err := stream.Send(clientStream.Msg()); err != nil {
			return err
		}
	}
	return clientStream.Err()
}

// Stop implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) Stop(ctx context.Context, req *connect.Request[mainchainv1.StopRequest]) (*connect.Response[mainchainv1.StopResponse], error) {
	return nil, connect.NewError(connect.CodePermissionDenied, errors.New("this is not your enforcer, you cannot shut it down. piss off, as the brits say"))
}
