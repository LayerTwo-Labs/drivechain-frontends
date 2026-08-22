package api_enforcer

import (
	"context"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/datasource"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/rs/zerolog"
)

var _ cryptorpc.CryptoServiceHandler = new(Server)
var _ validatorrpc.ValidatorServiceHandler = new(Server)
var _ validatorrpc.BlockProducerServiceHandler = new(Server)
var _ validatorrpc.MiningServiceHandler = new(Server)

// New creates a new Server
func New(
	data datasource.DataSource,
	validator *service.Service[validatorrpc.ValidatorServiceClient],
	crypto *service.Service[cryptorpc.CryptoServiceClient],
	blockProducer *service.Service[validatorrpc.BlockProducerServiceClient],
	mining *service.Service[validatorrpc.MiningServiceClient],
	walletEngine *engines.WalletEngine,
) *Server {
	s := &Server{
		data:          data,
		validator:     validator,
		crypto:        crypto,
		blockProducer: blockProducer,
		mining:        mining,
		walletEngine:  walletEngine,
	}

	return s
}

type Server struct {
	data          datasource.DataSource
	validator     *service.Service[validatorrpc.ValidatorServiceClient]
	crypto        *service.Service[cryptorpc.CryptoServiceClient]
	blockProducer *service.Service[validatorrpc.BlockProducerServiceClient]
	mining        *service.Service[validatorrpc.MiningServiceClient]
	walletEngine  *engines.WalletEngine
}

// Stop implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) Stop(ctx context.Context, c *connect.Request[mainchainv1.StopRequest]) (*connect.Response[mainchainv1.StopResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.Stop(ctx, c)
}

// SubscribeHeaderSyncProgress implements mainchainv1connect.ValidatorServiceHandler.
// nolint:dupl
func (s *Server) SubscribeHeaderSyncProgress(ctx context.Context, c *connect.Request[mainchainv1.SubscribeHeaderSyncProgressRequest], stream *connect.ServerStream[mainchainv1.SubscribeHeaderSyncProgressResponse]) error {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := validator.SubscribeHeaderSyncProgress(ctx, c)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not subscribe to header sync progress")
		return err
	}
	for clientStream.Receive() {
		if err := stream.Send(clientStream.Msg()); err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not send header sync progress message")
			return err
		}
	}
	return clientStream.Err()
}

// CreateSidechainProposal implements mainchainv1connect.BlockProducerServiceHandler.
// nolint:dupl
func (s *Server) CreateSidechainProposal(ctx context.Context, c *connect.Request[mainchainv1.CreateSidechainProposalRequest], stream *connect.ServerStream[mainchainv1.CreateSidechainProposalResponse]) error {
	if err := s.walletEngine.RequireFullNode(ctx, "creating a sidechain proposal"); err != nil {
		return err
	}
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := producer.CreateSidechainProposal(ctx, c)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not create sidechain proposal")
		return err
	}
	for clientStream.Receive() {
		if err := stream.Send(clientStream.Msg()); err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not send sidechain proposal message")
			return err
		}
	}
	return clientStream.Err()
}

// SubmitSidechainProposal implements mainchainv1connect.BlockProducerServiceHandler.
func (s *Server) SubmitSidechainProposal(ctx context.Context, c *connect.Request[mainchainv1.SubmitSidechainProposalRequest]) (*connect.Response[mainchainv1.SubmitSidechainProposalResponse], error) {
	if err := s.walletEngine.RequireFullNode(ctx, "submitting a sidechain proposal"); err != nil {
		return nil, err
	}
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return producer.SubmitSidechainProposal(ctx, c)
}

// GenerateToAddress implements mainchainv1connect.MiningServiceHandler.
func (s *Server) GenerateToAddress(ctx context.Context, c *connect.Request[mainchainv1.GenerateToAddressRequest]) (*connect.Response[mainchainv1.GenerateToAddressResponse], error) {
	mining, err := s.mining.Get(ctx)
	if err != nil {
		return nil, err
	}
	return mining.GenerateToAddress(ctx, c)
}

// SetSidechainAck implements mainchainv1connect.BlockProducerServiceHandler.
func (s *Server) SetSidechainAck(ctx context.Context, c *connect.Request[mainchainv1.SetSidechainAckRequest]) (*connect.Response[mainchainv1.SetSidechainAckResponse], error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return producer.SetSidechainAck(ctx, c)
}

// SetAckAllProposals implements mainchainv1connect.BlockProducerServiceHandler.
func (s *Server) SetAckAllProposals(ctx context.Context, c *connect.Request[mainchainv1.SetAckAllProposalsRequest]) (*connect.Response[mainchainv1.SetAckAllProposalsResponse], error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return producer.SetAckAllProposals(ctx, c)
}

// GetBlockProducerState implements mainchainv1connect.BlockProducerServiceHandler.
func (s *Server) GetBlockProducerState(ctx context.Context, c *connect.Request[mainchainv1.GetBlockProducerStateRequest]) (*connect.Response[mainchainv1.GetBlockProducerStateResponse], error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, err
	}
	return producer.GetBlockProducerState(ctx, c)
}

// GetWithdrawalBundleProposals implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetWithdrawalBundleProposals(ctx context.Context, c *connect.Request[mainchainv1.GetWithdrawalBundleProposalsRequest]) (*connect.Response[mainchainv1.GetWithdrawalBundleProposalsResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetWithdrawalBundleProposals(ctx, c)
}

// GetBlockHeaderInfo implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetBlockHeaderInfo(ctx context.Context, c *connect.Request[mainchainv1.GetBlockHeaderInfoRequest]) (*connect.Response[mainchainv1.GetBlockHeaderInfoResponse], error) {
	resp, err := s.data.BlockHeaderInfo(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// GetBlockInfo implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetBlockInfo(ctx context.Context, c *connect.Request[mainchainv1.GetBlockInfoRequest]) (*connect.Response[mainchainv1.GetBlockInfoResponse], error) {
	resp, err := s.data.BlockInfo(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// GetBmmHStarCommitment implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetBmmHStarCommitment(ctx context.Context, c *connect.Request[mainchainv1.GetBmmHStarCommitmentRequest]) (*connect.Response[mainchainv1.GetBmmHStarCommitmentResponse], error) {
	resp, err := s.data.BmmHStarCommitment(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// GetChainInfo implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetChainInfo(ctx context.Context, c *connect.Request[mainchainv1.GetChainInfoRequest]) (*connect.Response[mainchainv1.GetChainInfoResponse], error) {
	resp, err := s.data.ChainInfo(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// GetChainTip implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetChainTip(ctx context.Context, c *connect.Request[mainchainv1.GetChainTipRequest]) (*connect.Response[mainchainv1.GetChainTipResponse], error) {
	resp, err := s.data.ChainTip(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// GetCoinbasePSBT implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetCoinbasePSBT(ctx context.Context, c *connect.Request[mainchainv1.GetCoinbasePSBTRequest]) (*connect.Response[mainchainv1.GetCoinbasePSBTResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetCoinbasePSBT(ctx, c)
}

// GetCtip implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetCtip(ctx context.Context, c *connect.Request[mainchainv1.GetCtipRequest]) (*connect.Response[mainchainv1.GetCtipResponse], error) {
	resp, err := s.data.Ctip(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// GetSidechainProposals implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetSidechainProposals(ctx context.Context, c *connect.Request[mainchainv1.GetSidechainProposalsRequest]) (*connect.Response[mainchainv1.GetSidechainProposalsResponse], error) {
	resp, err := s.data.SidechainProposals(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// GetSidechains implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetSidechains(ctx context.Context, c *connect.Request[mainchainv1.GetSidechainsRequest]) (*connect.Response[mainchainv1.GetSidechainsResponse], error) {
	resp, err := s.data.Sidechains(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// GetTwoWayPegData implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetTwoWayPegData(ctx context.Context, c *connect.Request[mainchainv1.GetTwoWayPegDataRequest]) (*connect.Response[mainchainv1.GetTwoWayPegDataResponse], error) {
	resp, err := s.data.TwoWayPegData(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// SubscribeEvents implements mainchainv1connect.ValidatorServiceHandler.
// nolint:dupl
func (s *Server) SubscribeEvents(ctx context.Context, c *connect.Request[mainchainv1.SubscribeEventsRequest], stream *connect.ServerStream[mainchainv1.SubscribeEventsResponse]) error {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := validator.SubscribeEvents(ctx, c)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not subscribe to events")
		return err
	}
	for clientStream.Receive() {
		if err := stream.Send(clientStream.Msg()); err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not send event message")
			return err
		}
	}
	return clientStream.Err()
}

// HmacSha512 implements cryptov1connect.CryptoServiceHandler.
func (s *Server) HmacSha512(ctx context.Context, c *connect.Request[cryptov1.HmacSha512Request]) (*connect.Response[cryptov1.HmacSha512Response], error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return crypto.HmacSha512(ctx, c)
}

// Ripemd160 implements cryptov1connect.CryptoServiceHandler.
func (s *Server) Ripemd160(ctx context.Context, c *connect.Request[cryptov1.Ripemd160Request]) (*connect.Response[cryptov1.Ripemd160Response], error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return crypto.Ripemd160(ctx, c)
}

// Secp256K1SecretKeyToPublicKey implements cryptov1connect.CryptoServiceHandler.
func (s *Server) Secp256K1SecretKeyToPublicKey(ctx context.Context, c *connect.Request[cryptov1.Secp256K1SecretKeyToPublicKeyRequest]) (*connect.Response[cryptov1.Secp256K1SecretKeyToPublicKeyResponse], error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return crypto.Secp256K1SecretKeyToPublicKey(ctx, c)
}

// Secp256K1Sign implements cryptov1connect.CryptoServiceHandler.
func (s *Server) Secp256K1Sign(ctx context.Context, c *connect.Request[cryptov1.Secp256K1SignRequest]) (*connect.Response[cryptov1.Secp256K1SignResponse], error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return crypto.Secp256K1Sign(ctx, c)
}

// Secp256K1Verify implements cryptov1connect.CryptoServiceHandler.
func (s *Server) Secp256K1Verify(ctx context.Context, c *connect.Request[cryptov1.Secp256K1VerifyRequest]) (*connect.Response[cryptov1.Secp256K1VerifyResponse], error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}
	return crypto.Secp256K1Verify(ctx, c)
}
