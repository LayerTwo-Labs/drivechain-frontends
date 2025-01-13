package api_wallet

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/drivechain"
	commonv1 "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/common/v1"
	validatorpb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1/mainchainv1connect"
	drivechainrpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/drivechain/v1/drivechainv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/wallet/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/wallet/v1/walletv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.WalletServiceHandler = new(Server)

// New creates a new Server and starts the balance update loop
func New(
	ctx context.Context, bitcoind *coreproxy.Bitcoind, wallet validatorrpc.WalletServiceClient,
	drivechain drivechainrpc.DrivechainServiceClient,

) *Server {
	s := &Server{
		bitcoind:   bitcoind,
		wallet:     wallet,
		drivechain: drivechain,
	}
	return s
}

type Server struct {
	bitcoind   *coreproxy.Bitcoind
	wallet     validatorrpc.WalletServiceClient
	drivechain drivechainrpc.DrivechainServiceClient
}

// SendTransaction implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) SendTransaction(ctx context.Context, c *connect.Request[pb.SendTransactionRequest]) (*connect.Response[pb.SendTransactionResponse], error) {
	if s.wallet == nil {
		return nil, errors.New("wallet not connected")
	}

	if len(c.Msg.Destinations) == 0 {
		err := errors.New("must provide at least one destination")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if c.Msg.FeeRate < 0 {
		err := errors.New("fee rate cannot be negative")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	log := zerolog.Ctx(ctx)

	destinations := make(map[string]uint64)
	for address, amount := range c.Msg.Destinations {
		const dustLimit = 546
		if amount < dustLimit {
			err := fmt.Errorf(
				"amount to %s is below dust limit (%s): %s",
				address, btcutil.Amount(dustLimit), btcutil.Amount(amount),
			)
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
		destinations[address] = uint64(amount)
	}

	var feeRate *validatorpb.SendTransactionRequest_FeeRate
	if c.Msg.FeeRate != 0 {
		btcPerByte, err := btcutil.NewAmount(c.Msg.FeeRate / 1000)
		if err != nil {
			return nil, err
		}
		satoshiPerVByte := uint64(btcPerByte.ToUnit(btcutil.AmountSatoshi))
		feeRate = &validatorpb.SendTransactionRequest_FeeRate{
			Fee: &validatorpb.SendTransactionRequest_FeeRate_SatPerVbyte{SatPerVbyte: satoshiPerVByte},
		}
	}

	// Prepare OP_RETURN message if provided
	var opReturnMessage *commonv1.Hex
	if c.Msg.OpReturnMessage != nil {
		opReturnMessage = &commonv1.Hex{
			Hex: &wrapperspb.StringValue{
				Value: hex.EncodeToString([]byte(*c.Msg.OpReturnMessage)),
			},
		}
	}

	created, err := s.wallet.SendTransaction(ctx, connect.NewRequest(&validatorpb.SendTransactionRequest{
		Destinations:    destinations,
		FeeRate:         feeRate,
		OpReturnMessage: opReturnMessage,
	}))
	if err != nil {
		return nil, fmt.Errorf("could not send transaction: %w", err)
	}

	log.Info().Msgf("send tx: broadcast transaction: %s", created.Msg.Txid)

	return connect.NewResponse(&pb.SendTransactionResponse{
		Txid: created.Msg.Txid.Hex.Value,
	}), nil
}

// GetNewAddress implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetNewAddress(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetNewAddressResponse], error) {
	if s.wallet == nil {
		return nil, errors.New("wallet not connected")
	}

	address, err := s.wallet.CreateNewAddress(ctx, connect.NewRequest(&validatorpb.CreateNewAddressRequest{}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.GetNewAddressResponse{
		Address: address.Msg.Address,
	}), nil
}

// GetBalance implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetBalance(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetBalanceResponse], error) {
	if s.wallet == nil {
		return nil, errors.New("wallet not connected")
	}

	balance, err := s.wallet.GetBalance(ctx, connect.NewRequest(&validatorpb.GetBalanceRequest{}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.GetBalanceResponse{
		ConfirmedSatoshi: balance.Msg.ConfirmedSats,
		PendingSatoshi:   balance.Msg.PendingSats,
	}), nil
}

// ListTransactions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListTransactions(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListTransactionsResponse], error) {
	if s.wallet == nil {
		return nil, errors.New("wallet not connected")
	}

	txs, err := s.wallet.ListTransactions(ctx, connect.NewRequest(&validatorpb.ListTransactionsRequest{}))
	if err != nil {
		return nil, err
	}

	res := &pb.ListTransactionsResponse{
		Transactions: lo.Map(txs.Msg.Transactions, func(tx *validatorpb.WalletTransaction, idx int) *pb.WalletTransaction {
			var confirmation *pb.Confirmation
			if tx.ConfirmationInfo != nil {
				confirmation = &pb.Confirmation{
					Height:    uint32(tx.ConfirmationInfo.Height),
					Timestamp: &timestamppb.Timestamp{Seconds: tx.ConfirmationInfo.Timestamp.Seconds},
				}
			}
			return &pb.WalletTransaction{
				Txid:             tx.Txid.Hex.Value,
				FeeSats:          tx.FeeSats,
				ReceivedSatoshi:  tx.ReceivedSats,
				SentSatoshi:      tx.SentSats,
				ConfirmationTime: confirmation,
			}
		}),
	}

	return connect.NewResponse(res), nil
}

// ListSidechainDeposits implements walletv1connect.WalletServiceHandler.
func (s *Server) ListSidechainDeposits(ctx context.Context, c *connect.Request[pb.ListSidechainDepositsRequest]) (*connect.Response[pb.ListSidechainDepositsResponse], error) {
	if s.wallet == nil {
		return nil, errors.New("wallet not connected")
	}

	// TODO: Call ListSidechainDeposits with the CUSF-wallet here
	type Deposit struct {
		Txhex   string
		Strdest string
	}
	deposits := []Deposit{}

	var transactions corepb.ListTransactionsResponse
	var response pb.ListSidechainDepositsResponse
	for _, tx := range transactions.Transactions {
		if tx.Amount != 0 {
			continue
		}

		rawTxResponse, err := s.bitcoind.GetRawTransaction(ctx, &connect.Request[corepb.GetRawTransactionRequest]{
			Msg: &corepb.GetRawTransactionRequest{
				Txid: tx.Txid,
			},
		})
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get raw transaction: %w", err))
		}

		for _, deposit := range deposits {
			if deposit.Txhex == rawTxResponse.Msg.Tx.Hex {
				response.Deposits = append(response.Deposits, &pb.ListSidechainDepositsResponse_SidechainDeposit{
					Txid:          tx.Txid,
					Address:       deposit.Strdest,
					Amount:        tx.Amount,
					Fee:           tx.Fee,
					Confirmations: tx.Confirmations,
				})
				break
			}
		}
	}

	return connect.NewResponse(&response), nil
}

// CreateSidechainDeposit implements walletv1connect.WalletServiceHandler.
func (s *Server) CreateSidechainDeposit(ctx context.Context, c *connect.Request[pb.CreateSidechainDepositRequest]) (*connect.Response[pb.CreateSidechainDepositResponse], error) {
	if s.wallet == nil {
		return nil, errors.New("wallet not connected")
	}

	slot, depositAddress, _, err := drivechain.DecodeDepositAddress(c.Msg.Destination)
	if err != nil {
		return nil, fmt.Errorf("invalid deposit address: %w", err)
	}

	amount, err := btcutil.NewAmount(c.Msg.Amount)
	if err != nil || amount < 0 {
		return nil, fmt.Errorf("invalid amount, must be a BTC-amount greater than zero")
	}

	fee, err := btcutil.NewAmount(c.Msg.Fee)
	if err != nil || fee < 0 {
		return nil, fmt.Errorf("invalid fee, must be a BTC-amount greater than zero")
	}

	created, err := s.wallet.CreateDepositTransaction(ctx, connect.NewRequest(&validatorpb.CreateDepositTransactionRequest{
		SidechainId: &wrapperspb.UInt32Value{Value: uint32(slot)},
		Address:     &commonv1.Hex{Hex: &wrapperspb.StringValue{Value: depositAddress}},
		ValueSats:   &wrapperspb.UInt64Value{Value: uint64(amount)},
		FeeSats:     &wrapperspb.UInt64Value{Value: uint64(fee)},
	}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.CreateSidechainDepositResponse{
		Txid: created.Msg.Txid.Hex.Value,
	}), nil
}
