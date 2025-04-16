package api_enforcer

import (
	"context"

	"connectrpc.com/connect"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/crypto/v1/cryptov1connect"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/service"
)

var _ cryptorpc.CryptoServiceHandler = new(Server)
var _ validatorrpc.ValidatorServiceHandler = new(Server)
var _ validatorrpc.WalletServiceHandler = new(Server)

// New creates a new Server
func New(
	validator *service.Service[validatorrpc.ValidatorServiceClient],
	wallet *service.Service[validatorrpc.WalletServiceClient],
	crypto *service.Service[cryptorpc.CryptoServiceClient],
) *Server {
	s := &Server{
		validator: validator,
		wallet:    wallet,
		crypto:    crypto,
	}

	return s
}

type Server struct {
	validator *service.Service[validatorrpc.ValidatorServiceClient]
	wallet    *service.Service[validatorrpc.WalletServiceClient]
	crypto    *service.Service[cryptorpc.CryptoServiceClient]
}

// SubscribeHeaderSyncProgress implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) SubscribeHeaderSyncProgress(context.Context, *connect.Request[mainchainv1.SubscribeHeaderSyncProgressRequest], *connect.ServerStream[mainchainv1.SubscribeHeaderSyncProgressResponse]) error {
	panic("unimplemented")
}

// BroadcastWithdrawalBundle implements mainchainv1connect.WalletServiceHandler.
func (s *Server) BroadcastWithdrawalBundle(ctx context.Context, c *connect.Request[mainchainv1.BroadcastWithdrawalBundleRequest]) (*connect.Response[mainchainv1.BroadcastWithdrawalBundleResponse], error) {
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
func (s *Server) CreateSidechainProposal(ctx context.Context, c *connect.Request[mainchainv1.CreateSidechainProposalRequest], stream *connect.ServerStream[mainchainv1.CreateSidechainProposalResponse]) error {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := wallet.CreateSidechainProposal(ctx, c)
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

// CreateWallet implements mainchainv1connect.WalletServiceHandler.
func (s *Server) CreateWallet(ctx context.Context, c *connect.Request[mainchainv1.CreateWalletRequest]) (*connect.Response[mainchainv1.CreateWalletResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.CreateWallet(ctx, c)
}

// GenerateBlocks implements mainchainv1connect.WalletServiceHandler.
func (s *Server) GenerateBlocks(ctx context.Context, c *connect.Request[mainchainv1.GenerateBlocksRequest], stream *connect.ServerStream[mainchainv1.GenerateBlocksResponse]) error {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := wallet.GenerateBlocks(ctx, c)
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

// GetBalance implements mainchainv1connect.WalletServiceHandler.
func (s *Server) GetBalance(ctx context.Context, c *connect.Request[mainchainv1.GetBalanceRequest]) (*connect.Response[mainchainv1.GetBalanceResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.GetBalance(ctx, c)
}

// GetInfo implements mainchainv1connect.WalletServiceHandler.
func (s *Server) GetInfo(ctx context.Context, c *connect.Request[mainchainv1.GetInfoRequest]) (*connect.Response[mainchainv1.GetInfoResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.GetInfo(ctx, c)
}

// ListSidechainDepositTransactions implements mainchainv1connect.WalletServiceHandler.
func (s *Server) ListSidechainDepositTransactions(ctx context.Context, c *connect.Request[mainchainv1.ListSidechainDepositTransactionsRequest]) (*connect.Response[mainchainv1.ListSidechainDepositTransactionsResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.ListSidechainDepositTransactions(ctx, c)
}

// ListTransactions implements mainchainv1connect.WalletServiceHandler.
func (s *Server) ListTransactions(ctx context.Context, c *connect.Request[mainchainv1.ListTransactionsRequest]) (*connect.Response[mainchainv1.ListTransactionsResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.ListTransactions(ctx, c)
}

// ListUnspentOutputs implements mainchainv1connect.WalletServiceHandler.
func (s *Server) ListUnspentOutputs(ctx context.Context, c *connect.Request[mainchainv1.ListUnspentOutputsRequest]) (*connect.Response[mainchainv1.ListUnspentOutputsResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	return wallet.ListUnspentOutputs(ctx, c)
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
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetBlockHeaderInfo(ctx, c)
}

// GetBlockInfo implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetBlockInfo(ctx context.Context, c *connect.Request[mainchainv1.GetBlockInfoRequest]) (*connect.Response[mainchainv1.GetBlockInfoResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetBlockInfo(ctx, c)
}

// GetBmmHStarCommitment implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetBmmHStarCommitment(ctx context.Context, c *connect.Request[mainchainv1.GetBmmHStarCommitmentRequest]) (*connect.Response[mainchainv1.GetBmmHStarCommitmentResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetBmmHStarCommitment(ctx, c)
}

// GetChainInfo implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetChainInfo(ctx context.Context, c *connect.Request[mainchainv1.GetChainInfoRequest]) (*connect.Response[mainchainv1.GetChainInfoResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetChainInfo(ctx, c)
}

// GetChainTip implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetChainTip(ctx context.Context, c *connect.Request[mainchainv1.GetChainTipRequest]) (*connect.Response[mainchainv1.GetChainTipResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetChainTip(ctx, c)
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
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetCtip(ctx, c)
}

// GetSidechainProposals implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetSidechainProposals(ctx context.Context, c *connect.Request[mainchainv1.GetSidechainProposalsRequest]) (*connect.Response[mainchainv1.GetSidechainProposalsResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetSidechainProposals(ctx, c)
}

// GetSidechains implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetSidechains(ctx context.Context, c *connect.Request[mainchainv1.GetSidechainsRequest]) (*connect.Response[mainchainv1.GetSidechainsResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetSidechains(ctx, c)
}

// GetTwoWayPegData implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) GetTwoWayPegData(ctx context.Context, c *connect.Request[mainchainv1.GetTwoWayPegDataRequest]) (*connect.Response[mainchainv1.GetTwoWayPegDataResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, err
	}
	return validator.GetTwoWayPegData(ctx, c)
}

// SubscribeEvents implements mainchainv1connect.ValidatorServiceHandler.
func (s *Server) SubscribeEvents(ctx context.Context, c *connect.Request[mainchainv1.SubscribeEventsRequest], stream *connect.ServerStream[mainchainv1.SubscribeEventsResponse]) error {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return err
	}
	clientStream, err := validator.SubscribeEvents(ctx, c)
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
