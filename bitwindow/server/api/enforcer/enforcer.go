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
var _ validatorrpc.WalletServiceHandler = new(Server)

// New creates a new Server
func New(
	data datasource.DataSource,
	validator *service.Service[validatorrpc.ValidatorServiceClient],
	wallet *service.Service[validatorrpc.WalletServiceClient],
	crypto *service.Service[cryptorpc.CryptoServiceClient],
	walletEngine *engines.WalletEngine,
) *Server {
	s := &Server{
		data:         data,
		validator:    validator,
		wallet:       wallet,
		crypto:       crypto,
		walletEngine: walletEngine,
	}

	return s
}

type Server struct {
	data         datasource.DataSource
	validator    *service.Service[validatorrpc.ValidatorServiceClient]
	wallet       *service.Service[validatorrpc.WalletServiceClient]
	crypto       *service.Service[cryptorpc.CryptoServiceClient]
	walletEngine *engines.WalletEngine
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

// BroadcastWithdrawalBundle implements mainchainv1connect.WalletServiceHandler.
func (s *Server) BroadcastWithdrawalBundle(ctx context.Context, c *connect.Request[mainchainv1.BroadcastWithdrawalBundleRequest]) (*connect.Response[mainchainv1.BroadcastWithdrawalBundleResponse], error) {
	if err := s.walletEngine.RequireFullNode(ctx, "broadcasting a withdrawal bundle"); err != nil {
		return nil, err
	}
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

	return wallet.BroadcastWithdrawalBundle(ctx, c)
}

// CreateBmmCriticalDataTransaction implements mainchainv1connect.WalletServiceHandler.
func (s *Server) CreateBmmCriticalDataTransaction(ctx context.Context, c *connect.Request[mainchainv1.CreateBmmCriticalDataTransactionRequest]) (*connect.Response[mainchainv1.CreateBmmCriticalDataTransactionResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.CreateBmmCriticalDataTransaction(ctx, c)
}

// CreateDepositTransaction implements mainchainv1connect.WalletServiceHandler.
func (s *Server) CreateDepositTransaction(ctx context.Context, c *connect.Request[mainchainv1.CreateDepositTransactionRequest]) (*connect.Response[mainchainv1.CreateDepositTransactionResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.CreateDepositTransaction(ctx, c)
}

// CreateNewAddress implements mainchainv1connect.WalletServiceHandler.
func (s *Server) CreateNewAddress(ctx context.Context, c *connect.Request[mainchainv1.CreateNewAddressRequest]) (*connect.Response[mainchainv1.CreateNewAddressResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.CreateNewAddress(ctx, c)
}

// CreateSidechainProposal implements mainchainv1connect.WalletServiceHandler.
// nolint:dupl
func (s *Server) CreateSidechainProposal(ctx context.Context, c *connect.Request[mainchainv1.CreateSidechainProposalRequest], stream *connect.ServerStream[mainchainv1.CreateSidechainProposalResponse]) error {
	if err := s.walletEngine.RequireFullNode(ctx, "creating a sidechain proposal"); err != nil {
		return err
	}
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := wallet.CreateSidechainProposal(ctx, c)
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

// SubmitSidechainProposal implements mainchainv1connect.WalletServiceHandler.
func (s *Server) SubmitSidechainProposal(ctx context.Context, c *connect.Request[mainchainv1.SubmitSidechainProposalRequest]) (*connect.Response[mainchainv1.SubmitSidechainProposalResponse], error) {
	if err := s.walletEngine.RequireFullNode(ctx, "submitting a sidechain proposal"); err != nil {
		return nil, err
	}
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.SubmitSidechainProposal(ctx, c)
}

// CreateWallet implements mainchainv1connect.WalletServiceHandler.
func (s *Server) CreateWallet(ctx context.Context, c *connect.Request[mainchainv1.CreateWalletRequest]) (*connect.Response[mainchainv1.CreateWalletResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.CreateWallet(ctx, c)
}

// GenerateBlocks implements mainchainv1connect.WalletServiceHandler.
// nolint:dupl
func (s *Server) GenerateBlocks(ctx context.Context, c *connect.Request[mainchainv1.GenerateBlocksRequest], stream *connect.ServerStream[mainchainv1.GenerateBlocksResponse]) error {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := wallet.GenerateBlocks(ctx, c)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not generate blocks")
		return err
	}
	for clientStream.Receive() {
		if err := stream.Send(clientStream.Msg()); err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not send generated block message")
			return err
		}
	}
	return clientStream.Err()
}

// GetBalance implements mainchainv1connect.WalletServiceHandler.
func (s *Server) GetBalance(ctx context.Context, c *connect.Request[mainchainv1.GetBalanceRequest]) (*connect.Response[mainchainv1.GetBalanceResponse], error) {
	resp, err := s.data.Balance(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// GetInfo implements mainchainv1connect.WalletServiceHandler.
func (s *Server) GetInfo(ctx context.Context, c *connect.Request[mainchainv1.GetInfoRequest]) (*connect.Response[mainchainv1.GetInfoResponse], error) {
	resp, err := s.data.WalletInfo(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// ListSidechainDepositTransactions implements mainchainv1connect.WalletServiceHandler.
func (s *Server) ListSidechainDepositTransactions(ctx context.Context, c *connect.Request[mainchainv1.ListSidechainDepositTransactionsRequest]) (*connect.Response[mainchainv1.ListSidechainDepositTransactionsResponse], error) {
	resp, err := s.data.ListSidechainDeposits(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// ListTransactions implements mainchainv1connect.WalletServiceHandler.
func (s *Server) ListTransactions(ctx context.Context, c *connect.Request[mainchainv1.ListTransactionsRequest]) (*connect.Response[mainchainv1.ListTransactionsResponse], error) {
	resp, err := s.data.ListTransactions(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// ListUnspentOutputs implements mainchainv1connect.WalletServiceHandler.
func (s *Server) ListUnspentOutputs(ctx context.Context, c *connect.Request[mainchainv1.ListUnspentOutputsRequest]) (*connect.Response[mainchainv1.ListUnspentOutputsResponse], error) {
	resp, err := s.data.ListUnspentOutputs(ctx, c.Msg)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(resp), nil
}

// SendTransaction implements mainchainv1connect.WalletServiceHandler.
func (s *Server) SendTransaction(ctx context.Context, c *connect.Request[mainchainv1.SendTransactionRequest]) (*connect.Response[mainchainv1.SendTransactionResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.SendTransaction(ctx, c)
}

// UnlockWallet implements mainchainv1connect.WalletServiceHandler.
func (s *Server) UnlockWallet(ctx context.Context, c *connect.Request[mainchainv1.UnlockWalletRequest]) (*connect.Response[mainchainv1.UnlockWalletResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.UnlockWallet(ctx, c)
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
