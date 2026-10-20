package validator

import (
	"context"
	"errors"
	"io"

	"connectrpc.com/connect/v2"

	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/connector"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/cusf/mainchain/v1"
	mainchainv1connect "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/cusf/mainchain/v1/mainchainv1connect"
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
func (s *Server) GetBlockHeaderInfo(ctx context.Context, req *mainchainv1.GetBlockHeaderInfoRequest) (*mainchainv1.GetBlockHeaderInfoResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetBlockHeaderInfo)
}

// GetBlockInfo implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetBlockInfo(ctx context.Context, req *mainchainv1.GetBlockInfoRequest) (*mainchainv1.GetBlockInfoResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetBlockInfo)
}

// GetBmmHStarCommitment implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetBmmHStarCommitment(ctx context.Context, req *mainchainv1.GetBmmHStarCommitmentRequest) (*mainchainv1.GetBmmHStarCommitmentResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetBmmHStarCommitment)
}

// GetChainInfo implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetChainInfo(ctx context.Context, req *mainchainv1.GetChainInfoRequest) (*mainchainv1.GetChainInfoResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetChainInfo)
}

// GetChainTip implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetChainTip(ctx context.Context, req *mainchainv1.GetChainTipRequest) (*mainchainv1.GetChainTipResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetChainTip)
}

// GetCoinbasePSBT implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetCoinbasePSBT(ctx context.Context, req *mainchainv1.GetCoinbasePSBTRequest) (*mainchainv1.GetCoinbasePSBTResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetCoinbasePSBT)
}

// GetCtip implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetCtip(ctx context.Context, req *mainchainv1.GetCtipRequest) (*mainchainv1.GetCtipResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetCtip)
}

// GetSidechainProposals implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetSidechainProposals(ctx context.Context, req *mainchainv1.GetSidechainProposalsRequest) (*mainchainv1.GetSidechainProposalsResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetSidechainProposals)
}

// GetSidechains implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetSidechains(ctx context.Context, req *mainchainv1.GetSidechainsRequest) (*mainchainv1.GetSidechainsResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetSidechains)
}

// GetTwoWayPegData implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) GetTwoWayPegData(ctx context.Context, req *mainchainv1.GetTwoWayPegDataRequest) (*mainchainv1.GetTwoWayPegDataResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, req, validator.GetTwoWayPegData)
}

// SubscribeEvents implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) SubscribeEvents(ctx context.Context, req *mainchainv1.SubscribeEventsRequest, stream mainchainv1connect.ValidatorServiceSubscribeEventsServerStream) error {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return err
	}
	callCtx, info := clientContext(ctx)
	clientStream, err := validator.SubscribeEvents(callCtx, req)
	if err != nil {
		copyResponseMetadata(ctx, info)
		return connector.ForwardError(err)
	}
	return forwardStream(ctx, info, clientStream, stream)
}

// SubscribeHeaderSyncProgress implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) SubscribeHeaderSyncProgress(ctx context.Context, req *mainchainv1.SubscribeHeaderSyncProgressRequest, stream mainchainv1connect.ValidatorServiceSubscribeHeaderSyncProgressServerStream) error {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return err
	}
	callCtx, info := clientContext(ctx)
	clientStream, err := validator.SubscribeHeaderSyncProgress(callCtx, req)
	if err != nil {
		copyResponseMetadata(ctx, info)
		return connector.ForwardError(err)
	}
	return forwardStream(ctx, info, clientStream, stream)
}

// Stop implements mainchainv1connect.ValidatorServiceHandler
func (s *Server) Stop(ctx context.Context, req *mainchainv1.StopRequest) (*mainchainv1.StopResponse, error) {
	return nil, connect.NewError(connect.CodePermissionDenied, "this is not your enforcer, you cannot shut it down. piss off, as the brits say")
}

func clientContext(ctx context.Context) (context.Context, *connect.CallInfo) {
	callCtx, info := connect.NewClientContext(ctx)
	if request, ok := connect.CallInfoForServerContext(ctx); ok {
		for key, values := range request.RequestHeader().All() {
			info.RequestHeader().SetValues(key, values)
		}
	}
	return callCtx, info
}

func copyResponseHeader(ctx context.Context, info *connect.CallInfo) {
	if result, ok := connect.CallInfoForServerContext(ctx); ok {
		for key, values := range info.ResponseHeader().All() {
			result.ResponseHeader().SetValues(key, values)
		}
	}
}

func copyResponseTrailer(ctx context.Context, info *connect.CallInfo) {
	if result, ok := connect.CallInfoForServerContext(ctx); ok {
		for key, values := range info.ResponseTrailer().All() {
			result.ResponseTrailer().SetValues(key, values)
		}
	}
}

func copyResponseMetadata(ctx context.Context, info *connect.CallInfo) {
	copyResponseHeader(ctx, info)
	copyResponseTrailer(ctx, info)
}

func proxyCall[Request, Response any](ctx context.Context, req *Request, call func(context.Context, *Request) (*Response, error)) (*Response, error) {
	callCtx, info := clientContext(ctx)
	response, err := call(callCtx, req)
	copyResponseMetadata(ctx, info)
	return response, connector.ForwardError(err)
}

type streamReader[Res any] interface {
	Receive() (*Res, error)
	Close() error
}

type streamWriter[Res any] interface {
	Send(*Res) error
}

// forwardStream copies the upstream header before the first message and the trailer at the end.
func forwardStream[Res any](ctx context.Context, info *connect.CallInfo, in streamReader[Res], out streamWriter[Res]) (err error) {
	defer func() {
		err = errors.Join(err, in.Close())
		copyResponseTrailer(ctx, info)
	}()
	for first := true; ; first = false {
		msg, err := in.Receive()
		if first {
			copyResponseHeader(ctx, info)
		}
		if errors.Is(err, io.EOF) {
			return nil
		}
		if err != nil {
			return connector.ForwardError(err)
		}
		if err := out.Send(msg); err != nil {
			return err
		}
	}
}
