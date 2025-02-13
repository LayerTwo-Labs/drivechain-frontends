package api_wallet

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/drivechain"
	bitwindowdv1 "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitwindowd/v1"
	commonv1 "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/common/v1"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/crypto/v1/cryptov1connect"
	validatorpb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1/mainchainv1connect"
	drivechainrpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/drivechain/v1/drivechainv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/wallet/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/models/addressbook"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/service"
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
	ctx context.Context,
	database *sql.DB,
	bitcoind *service.Service[*coreproxy.Bitcoind],
	wallet *service.Service[validatorrpc.WalletServiceClient],
	drivechain drivechainrpc.DrivechainServiceHandler,
	crypto *service.Service[cryptorpc.CryptoServiceClient],
) *Server {
	s := &Server{
		database:   database,
		bitcoind:   bitcoind,
		wallet:     wallet,
		drivechain: drivechain,
		crypto:     crypto,
	}
	return s
}

type Server struct {
	database   *sql.DB
	bitcoind   *service.Service[*coreproxy.Bitcoind]
	wallet     *service.Service[validatorrpc.WalletServiceClient]
	drivechain drivechainrpc.DrivechainServiceHandler
	crypto     *service.Service[cryptorpc.CryptoServiceClient]
}

// SendTransaction implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) SendTransaction(ctx context.Context, c *connect.Request[pb.SendTransactionRequest]) (*connect.Response[pb.SendTransactionResponse], error) {
	if s.wallet == nil {
		return nil, errors.New("wallet not connected")
	}

	if c.Msg.Destination == "" {
		err := errors.New("must provide a destination")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if c.Msg.FeeRate < 0 {
		err := errors.New("fee rate cannot be negative")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	const dustLimit = 546
	if c.Msg.Amount < dustLimit {
		err := fmt.Errorf(
			"amount to %s is below dust limit (%s): %s",
			c.Msg.Destination, btcutil.Amount(dustLimit), btcutil.Amount(c.Msg.Amount),
		)
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	log := zerolog.Ctx(ctx)

	destinations := make(map[string]uint64)
	destinations[c.Msg.Destination] = uint64(c.Msg.Amount)

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

	// Add OP_RETURN message if provided
	var opReturnMessage *commonv1.Hex
	if c.Msg.OpReturnMessage != "" {
		opReturnMessage = &commonv1.Hex{
			Hex: &wrapperspb.StringValue{
				Value: hex.EncodeToString([]byte(c.Msg.OpReturnMessage)),
			},
		}
	}

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("could not get wallet: %w", err)
	}
	created, err := wallet.SendTransaction(ctx, connect.NewRequest(&validatorpb.SendTransactionRequest{
		Destinations:    destinations,
		FeeRate:         feeRate,
		OpReturnMessage: opReturnMessage,
	}))
	if err != nil {
		return nil, fmt.Errorf("could not send transaction: %w", err)
	}

	if c.Msg.Label != "" {
		direction, err := addressbook.DirectionFromProto(bitwindowdv1.Direction_DIRECTION_SEND)
		if err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}

		err = addressbook.Create(ctx, s.database, c.Msg.Label, c.Msg.Destination, direction)
		if err != nil {
			if err.Error() == "UNIQUE constraint failed: address_book.address" {
				// that's fine! Don't do anything
			} else {
				return nil, fmt.Errorf("could not create address book entry: %w", err)
			}
		}
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

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("could not get wallet: %w", err)
	}
	address, err := wallet.CreateNewAddress(ctx, connect.NewRequest(&validatorpb.CreateNewAddressRequest{}))
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

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("could not get wallet: %w", err)
	}
	balance, err := wallet.GetBalance(ctx, connect.NewRequest(&validatorpb.GetBalanceRequest{}))
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

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("could not get wallet: %w", err)
	}
	txs, err := wallet.ListTransactions(ctx, connect.NewRequest(&validatorpb.ListTransactionsRequest{}))
	if err != nil {
		return nil, err
	}

	res := &pb.ListTransactionsResponse{
		Transactions: lo.Map(txs.Msg.Transactions, func(tx *validatorpb.WalletTransaction, idx int) *pb.WalletTransaction {
			var confirmation *pb.Confirmation
			if tx.ConfirmationInfo != nil {
				var timestamp *timestamppb.Timestamp
				if tx.ConfirmationInfo.Timestamp != nil {
					timestamp = &timestamppb.Timestamp{Seconds: tx.ConfirmationInfo.Timestamp.Seconds}
				}

				confirmation = &pb.Confirmation{
					Height:    uint32(tx.ConfirmationInfo.Height),
					Timestamp: timestamp,
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

		bitcoind, err := s.bitcoind.Get(ctx)
		if err != nil {
			return nil, fmt.Errorf("could not get bitcoind: %w", err)
		}
		rawTxResponse, err := bitcoind.GetRawTransaction(ctx, &connect.Request[corepb.GetRawTransactionRequest]{
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
	if slot == nil && c.Msg.Slot == 0 {
		return nil, fmt.Errorf("address is not a sidechain deposit address, expected slot or format: s<slot>_<address> or s9_<address>_<checksum>")
	} else if slot == nil {
		slot = &c.Msg.Slot
	}

	amount, err := btcutil.NewAmount(c.Msg.Amount)
	if err != nil || amount < 0 {
		return nil, fmt.Errorf("invalid amount, must be a BTC-amount greater than zero")
	}

	fee, err := btcutil.NewAmount(c.Msg.Fee)
	if err != nil || fee < 0 {
		return nil, fmt.Errorf("invalid fee, must be a BTC-amount greater than zero")
	}

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("could not get wallet: %w", err)
	}
	created, err := wallet.CreateDepositTransaction(ctx, connect.NewRequest(&validatorpb.CreateDepositTransactionRequest{
		SidechainId: &wrapperspb.UInt32Value{Value: uint32(*slot)},
		Address:     &wrapperspb.StringValue{Value: depositAddress},
		ValueSats:   &wrapperspb.UInt64Value{Value: uint64(amount)},
		FeeSats:     &wrapperspb.UInt64Value{Value: uint64(fee)},
	}))
	if err != nil {
		return nil, err
	}

	zerolog.Ctx(ctx).Info().Msgf("create deposit tx: broadcast transaction: %s", created.Msg.Txid)

	return connect.NewResponse(&pb.CreateSidechainDepositResponse{
		Txid: created.Msg.Txid.Hex.Value,
	}), nil
}

// SignMessage implements walletv1connect.WalletServiceHandler.
func (s *Server) SignMessage(ctx context.Context, c *connect.Request[pb.SignMessageRequest]) (*connect.Response[pb.SignMessageResponse], error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("could not get crypto: %w", err)
	}

	res, err := crypto.Secp256K1Sign(ctx, connect.NewRequest(&cryptov1.Secp256K1SignRequest{
		Message: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{Value: c.Msg.Message},
		},
	}))
	if err != nil {
		return nil, fmt.Errorf("could not sign message: %w", err)
	}

	return connect.NewResponse(&pb.SignMessageResponse{
		Signature: res.Msg.Signature.Hex.Value,
	}), nil
}

// VerifyMessage implements walletv1connect.WalletServiceHandler.
func (s *Server) VerifyMessage(ctx context.Context, c *connect.Request[pb.VerifyMessageRequest]) (*connect.Response[pb.VerifyMessageResponse], error) {
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("could not get crypto: %w", err)
	}

	res, err := crypto.Secp256K1Verify(ctx, connect.NewRequest(&cryptov1.Secp256K1VerifyRequest{
		Message: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{Value: c.Msg.Message},
		},
		Signature: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{Value: c.Msg.Signature},
		},
		PublicKey: &commonv1.ConsensusHex{
			Hex: &wrapperspb.StringValue{Value: c.Msg.PublicKey},
		},
	}))
	if err != nil {
		return nil, fmt.Errorf("could not verify message: %w", err)
	}

	return connect.NewResponse(&pb.VerifyMessageResponse{
		Valid: res.Msg.Valid,
	}), nil
}
