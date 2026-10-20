package enforcer

import (
	"context"
	"errors"
	"fmt"
	"io"

	"connectrpc.com/connect/v2"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

var _ cryptorpc.CryptoServiceHandler = new(Server)
var _ validatorrpc.ValidatorServiceHandler = new(Server)
var _ validatorrpc.BlockProducerServiceHandler = new(Server)
var _ validatorrpc.MiningServiceHandler = new(Server)

func New(
	validator *service.Service[validatorrpc.ValidatorServiceClient],
	crypto *service.Service[cryptorpc.CryptoServiceClient],
	blockProducer *service.Service[validatorrpc.BlockProducerServiceClient],
	mining *service.Service[validatorrpc.MiningServiceClient],
	walletEngine *engines.WalletEngine,
) *Server {
	s := &Server{
		validator:     validator,
		crypto:        crypto,
		blockProducer: blockProducer,
		mining:        mining,
		walletEngine:  walletEngine,
	}

	return s
}

type Server struct {
	validator     *service.Service[validatorrpc.ValidatorServiceClient]
	crypto        *service.Service[cryptorpc.CryptoServiceClient]
	blockProducer *service.Service[validatorrpc.BlockProducerServiceClient]
	mining        *service.Service[validatorrpc.MiningServiceClient]
	walletEngine  *engines.WalletEngine
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
	return response, err
}

type streamReader[Res any] interface {
	Receive() (*Res, error)
	Close() error
}

type streamWriter[Res any] interface {
	Send(*Res) error
}

// forwardStream copies the upstream header before the first message and the trailer at the end.
func forwardStream[Res any](ctx context.Context, name string, info *connect.CallInfo, in streamReader[Res], out streamWriter[Res]) (err error) {
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
			return err
		}
		if err := out.Send(msg); err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Str("stream", name).Msg("send stream message")
			return fmt.Errorf("forward stream message: %w", err)
		}
	}
}

// Stop implements validatorrpc.ValidatorServiceHandler.
func (s *Server) Stop(ctx context.Context, c *mainchainv1.StopRequest) (*mainchainv1.StopResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.Stop)
}

// SubscribeHeaderSyncProgress implements validatorrpc.ValidatorServiceHandler.
func (s *Server) SubscribeHeaderSyncProgress(ctx context.Context, c *mainchainv1.SubscribeHeaderSyncProgressRequest, stream validatorrpc.ValidatorServiceSubscribeHeaderSyncProgressServerStream) error {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return err
	}
	callCtx, info := clientContext(ctx)
	clientStream, err := validator.SubscribeHeaderSyncProgress(callCtx, c)
	if err != nil {
		copyResponseMetadata(ctx, info)
		zerolog.Ctx(ctx).Error().Err(err).Msg("subscribe to header sync progress")
		return err
	}
	return forwardStream(ctx, "header sync progress", info, clientStream, stream)
}

// CreateSidechainProposal implements validatorrpc.BlockProducerServiceHandler.
func (s *Server) CreateSidechainProposal(ctx context.Context, c *mainchainv1.CreateSidechainProposalRequest, stream validatorrpc.BlockProducerServiceCreateSidechainProposalServerStream) error {
	if err := s.walletEngine.RequireFullNode(ctx, "creating a sidechain proposal"); err != nil {
		return err
	}
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return err
	}
	callCtx, info := clientContext(ctx)
	clientStream, err := producer.CreateSidechainProposal(callCtx, c)
	if err != nil {
		copyResponseMetadata(ctx, info)
		zerolog.Ctx(ctx).Error().Err(err).Msg("create sidechain proposal")
		return err
	}
	return forwardStream(ctx, "sidechain proposal", info, clientStream, stream)
}

// SubmitSidechainProposal implements validatorrpc.BlockProducerServiceHandler.
func (s *Server) SubmitSidechainProposal(ctx context.Context, c *mainchainv1.SubmitSidechainProposalRequest) (*mainchainv1.SubmitSidechainProposalResponse, error) {
	if err := s.walletEngine.RequireFullNode(ctx, "submitting a sidechain proposal"); err != nil {
		return nil, err
	}
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, producer.SubmitSidechainProposal)
}

// GenerateToAddress implements validatorrpc.MiningServiceHandler.
func (s *Server) GenerateToAddress(ctx context.Context, c *mainchainv1.GenerateToAddressRequest) (*mainchainv1.GenerateToAddressResponse, error) {
	mining, err := s.mining.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, mining.GenerateToAddress)
}

// SetSidechainAck implements validatorrpc.BlockProducerServiceHandler.
func (s *Server) SetSidechainAck(ctx context.Context, c *mainchainv1.SetSidechainAckRequest) (*mainchainv1.SetSidechainAckResponse, error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, producer.SetSidechainAck)
}

// SetAckAllProposals implements validatorrpc.BlockProducerServiceHandler.
func (s *Server) SetAckAllProposals(ctx context.Context, c *mainchainv1.SetAckAllProposalsRequest) (*mainchainv1.SetAckAllProposalsResponse, error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, producer.SetAckAllProposals)
}

// SetWithdrawalBundleAck implements validatorrpc.BlockProducerServiceHandler.
func (s *Server) SetWithdrawalBundleAck(ctx context.Context, c *mainchainv1.SetWithdrawalBundleAckRequest) (*mainchainv1.SetWithdrawalBundleAckResponse, error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, producer.SetWithdrawalBundleAck)
}

// SetWithdrawalBundlePolicy implements validatorrpc.BlockProducerServiceHandler.
func (s *Server) SetWithdrawalBundlePolicy(ctx context.Context, c *mainchainv1.SetWithdrawalBundlePolicyRequest) (*mainchainv1.SetWithdrawalBundlePolicyResponse, error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, producer.SetWithdrawalBundlePolicy)
}

// ProposeWithdrawalBundle implements validatorrpc.BlockProducerServiceHandler.
func (s *Server) ProposeWithdrawalBundle(ctx context.Context, c *mainchainv1.ProposeWithdrawalBundleRequest) (*mainchainv1.ProposeWithdrawalBundleResponse, error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, producer.ProposeWithdrawalBundle)
}

// GetBlockProducerState implements validatorrpc.BlockProducerServiceHandler.
func (s *Server) GetBlockProducerState(ctx context.Context, c *mainchainv1.GetBlockProducerStateRequest) (*mainchainv1.GetBlockProducerStateResponse, error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, producer.GetBlockProducerState)
}

// GetWithdrawalBundleProposals implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetWithdrawalBundleProposals(ctx context.Context, c *mainchainv1.GetWithdrawalBundleProposalsRequest) (*mainchainv1.GetWithdrawalBundleProposalsResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetWithdrawalBundleProposals)
}

// GetBlockHeaderInfo implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetBlockHeaderInfo(ctx context.Context, c *mainchainv1.GetBlockHeaderInfoRequest) (*mainchainv1.GetBlockHeaderInfoResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetBlockHeaderInfo)
}

// GetBlockInfo implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetBlockInfo(ctx context.Context, c *mainchainv1.GetBlockInfoRequest) (*mainchainv1.GetBlockInfoResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetBlockInfo)
}

// GetBmmHStarCommitment implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetBmmHStarCommitment(ctx context.Context, c *mainchainv1.GetBmmHStarCommitmentRequest) (*mainchainv1.GetBmmHStarCommitmentResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetBmmHStarCommitment)
}

// GetChainInfo implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetChainInfo(ctx context.Context, c *mainchainv1.GetChainInfoRequest) (*mainchainv1.GetChainInfoResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetChainInfo)
}

// GetChainTip implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetChainTip(ctx context.Context, c *mainchainv1.GetChainTipRequest) (*mainchainv1.GetChainTipResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetChainTip)
}

// GetCoinbasePSBT implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetCoinbasePSBT(ctx context.Context, c *mainchainv1.GetCoinbasePSBTRequest) (*mainchainv1.GetCoinbasePSBTResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetCoinbasePSBT)
}

// GetCtip implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetCtip(ctx context.Context, c *mainchainv1.GetCtipRequest) (*mainchainv1.GetCtipResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetCtip)
}

// GetSidechainProposals implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetSidechainProposals(ctx context.Context, c *mainchainv1.GetSidechainProposalsRequest) (*mainchainv1.GetSidechainProposalsResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetSidechainProposals)
}

// GetSeenBmmRequests implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetSeenBmmRequests(ctx context.Context, c *mainchainv1.GetSeenBmmRequestsRequest) (*mainchainv1.GetSeenBmmRequestsResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetSeenBmmRequests)
}

// GetSidechains implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetSidechains(ctx context.Context, c *mainchainv1.GetSidechainsRequest) (*mainchainv1.GetSidechainsResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetSidechains)
}

// GetTwoWayPegData implements validatorrpc.ValidatorServiceHandler.
func (s *Server) GetTwoWayPegData(ctx context.Context, c *mainchainv1.GetTwoWayPegDataRequest) (*mainchainv1.GetTwoWayPegDataResponse, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, validator.GetTwoWayPegData)
}

// SubscribeEvents implements validatorrpc.ValidatorServiceHandler.
func (s *Server) SubscribeEvents(ctx context.Context, c *mainchainv1.SubscribeEventsRequest, stream validatorrpc.ValidatorServiceSubscribeEventsServerStream) error {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return err
	}
	callCtx, info := clientContext(ctx)
	clientStream, err := validator.SubscribeEvents(callCtx, c)
	if err != nil {
		copyResponseMetadata(ctx, info)
		zerolog.Ctx(ctx).Error().Err(err).Msg("subscribe to events")
		return err
	}
	return forwardStream(ctx, "events", info, clientStream, stream)
}

// HmacSha512 implements cryptov1connect.CryptoServiceHandler.
func (s *Server) HmacSha512(ctx context.Context, c *cryptov1.HmacSha512Request) (*cryptov1.HmacSha512Response, error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, crypto.HmacSha512)
}

// Ripemd160 implements cryptov1connect.CryptoServiceHandler.
func (s *Server) Ripemd160(ctx context.Context, c *cryptov1.Ripemd160Request) (*cryptov1.Ripemd160Response, error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, crypto.Ripemd160)
}

// Secp256K1SecretKeyToPublicKey implements cryptov1connect.CryptoServiceHandler.
func (s *Server) Secp256K1SecretKeyToPublicKey(ctx context.Context, c *cryptov1.Secp256K1SecretKeyToPublicKeyRequest) (*cryptov1.Secp256K1SecretKeyToPublicKeyResponse, error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, crypto.Secp256K1SecretKeyToPublicKey)
}

// Secp256K1Sign implements cryptov1connect.CryptoServiceHandler.
func (s *Server) Secp256K1Sign(ctx context.Context, c *cryptov1.Secp256K1SignRequest) (*cryptov1.Secp256K1SignResponse, error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, crypto.Secp256K1Sign)
}

// Secp256K1Verify implements cryptov1connect.CryptoServiceHandler.
func (s *Server) Secp256K1Verify(ctx context.Context, c *cryptov1.Secp256K1VerifyRequest) (*cryptov1.Secp256K1VerifyResponse, error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return proxyCall(ctx, c, crypto.Secp256K1Verify)
}
