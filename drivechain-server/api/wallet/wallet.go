package api_wallet

import (
	"context"
	"errors"
	"fmt"
	"sync/atomic"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/bdk"
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/wallet/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/wallet/v1/walletv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	drivechainpb "github.com/barebitcoin/btc-buf/gen/bitcoin/drivechaind/v1"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var _ rpc.WalletServiceHandler = new(Server)

// New creates a new Server and starts the balance update loop
func New(ctx context.Context, wallet *bdk.Wallet, bitcoind *coreproxy.Bitcoind) *Server {
	s := &Server{wallet: wallet, bitcoind: bitcoind}
	go s.startBalanceUpdateLoop(ctx)
	return s
}

type Server struct {
	wallet   *bdk.Wallet
	bitcoind *coreproxy.Bitcoind
	balance  atomic.Value
}

func (s *Server) startBalanceUpdateLoop(ctx context.Context) {
	ticker := time.NewTicker(time.Second * 5)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := s.updateBalance(ctx); err != nil {
				zerolog.Ctx(ctx).Err(err).Msg("failed to update balance")
			}
		}
	}
}

func (s *Server) updateBalance(ctx context.Context) error {
	if err := s.wallet.Sync(ctx); err != nil {
		return fmt.Errorf("unable to sync: %w", err)
	}

	balance, err := s.wallet.GetBalance(ctx)
	if err != nil {
		return fmt.Errorf("unable to get balance: %w", err)
	}

	prevBalance, ok := s.balance.Load().(bdk.Balance)
	if ok && (balance.Confirmed == prevBalance.Confirmed &&
		balance.Immature == prevBalance.Immature &&
		balance.TrustedPending == prevBalance.TrustedPending &&
		balance.UntrustedPending == prevBalance.UntrustedPending) {
		return nil
	}

	zerolog.Ctx(ctx).Info().
		Msgf("balance changed: %+v -> %+v", prevBalance, balance)

	s.balance.Store(*balance)
	return nil
}

// SendTransaction implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) SendTransaction(ctx context.Context, c *connect.Request[pb.SendTransactionRequest]) (*connect.Response[pb.SendTransactionResponse], error) {
	if len(c.Msg.Destinations) == 0 {
		err := errors.New("must provide at least one destination")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if c.Msg.FeeRate < 0 {
		err := errors.New("fee rate cannot be negative")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	log := zerolog.Ctx(ctx)

	if c.Msg.FeeRate == 0 {
		log.Debug().Msgf("send tx: received no fee rate, querying bitcoin core")

		estimate, err := s.bitcoind.EstimateSmartFee(ctx, connect.NewRequest(&corepb.EstimateSmartFeeRequest{
			ConfTarget:   2,
			EstimateMode: corepb.EstimateSmartFeeRequest_ESTIMATE_MODE_ECONOMICAL,
		}))
		if err != nil {
			return nil, err
		}

		c.Msg.FeeRate = estimate.Msg.FeeRate
		log.Info().Msgf("send tx: determined fee rate: %f", c.Msg.FeeRate)
	}

	destinations := make(map[string]btcutil.Amount)
	for address, amount := range c.Msg.Destinations {
		const dustLimit = 546
		if amount < dustLimit {
			err := fmt.Errorf(
				"amount to %s is below dust limit (%s): %s",
				address, btcutil.Amount(dustLimit), btcutil.Amount(amount),
			)
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
		destinations[address] = btcutil.Amount(amount)
	}

	btcPerByte, err := btcutil.NewAmount(c.Msg.FeeRate / 1000)
	if err != nil {
		return nil, err
	}
	satoshiPerVByte := btcPerByte.ToUnit(btcutil.AmountSatoshi)

	created, err := s.wallet.CreateTransaction(ctx, destinations, satoshiPerVByte, c.Msg.Rbf)
	if err != nil {
		return nil, err
	}

	log.Info().Msg("send tx: created transaction")

	signed, err := s.wallet.SignTransaction(ctx, created)
	if err != nil {
		return nil, err
	}

	log.Info().Msg("send tx: signed transaction")

	txid, err := s.wallet.BroadcastTransaction(ctx, signed)
	if err != nil {
		return nil, err
	}

	log.Info().Msgf("send tx: broadcast transaction: %s", txid)

	return connect.NewResponse(&pb.SendTransactionResponse{
		Txid: txid,
	}), nil

}

// GetNewAddress implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetNewAddress(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetNewAddressResponse], error) {
	address, index, err := s.wallet.GetNewAddress(ctx)
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.GetNewAddressResponse{
		Address: address,
		Index:   uint32(index),
	}), nil
}

// GetBalance implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetBalance(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetBalanceResponse], error) {
	balanceValue := s.balance.Load()
	if balanceValue == nil {
		// If balance hasn't been fetched yet, do it now
		if err := s.updateBalance(ctx); err != nil {
			return nil, err
		}
		balanceValue = s.balance.Load()
	}

	balance, ok := balanceValue.(bdk.Balance)
	if !ok && balance != (bdk.Balance{}) {
		// If the balance is still nil or not of the expected type, return an error
		return nil, connect.NewError(connect.CodeInternal, errors.New("balance not available"))
	}

	return connect.NewResponse(&pb.GetBalanceResponse{
		ConfirmedSatoshi: uint64(balance.Confirmed),
		PendingSatoshi:   uint64(balance.Immature) + uint64(balance.TrustedPending) + uint64(balance.UntrustedPending),
	}), nil
}

// ListTransactions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListTransactions(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListTransactionsResponse], error) {
	txs, err := s.wallet.ListTransactions(ctx)
	if err != nil {
		return nil, err
	}

	res := &pb.ListTransactionsResponse{
		Transactions: lo.Map(txs, func(tx bdk.Transaction, idx int) *pb.Transaction {
			var confirmation *pb.Confirmation
			if tx.ConfirmationTime != nil {
				confirmation = &pb.Confirmation{
					Height:    uint32(tx.ConfirmationTime.Height),
					Timestamp: &timestamppb.Timestamp{Seconds: int64(tx.ConfirmationTime.Timestamp)},
				}
			}
			return &pb.Transaction{
				Txid:             tx.TXID,
				FeeSatoshi:       uint64(tx.Fee),
				ReceivedSatoshi:  uint64(tx.Received),
				SentSatoshi:      uint64(tx.Sent),
				ConfirmationTime: confirmation,
			}
		}),
	}

	return connect.NewResponse(res), nil
}

// ListSidechainDeposits implements walletv1connect.WalletServiceHandler.
func (s *Server) ListSidechainDeposits(ctx context.Context, c *connect.Request[pb.ListSidechainDepositsRequest]) (*connect.Response[pb.ListSidechainDepositsResponse], error) {

	deposits, err := s.bitcoind.ListSidechainDeposits(ctx, &connect.Request[drivechainpb.ListSidechainDepositsRequest]{
		Msg: &drivechainpb.ListSidechainDepositsRequest{
			Slot: c.Msg.Slot,
		},
	})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to list all sidechain deposits: %w", err))
	}

	transactions, err := s.bitcoind.ListTransactions(ctx, &connect.Request[corepb.ListTransactionsRequest]{
		Msg: &corepb.ListTransactionsRequest{},
	})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to list transactions: %w", err))
	}

	var response pb.ListSidechainDepositsResponse
	for _, tx := range transactions.Msg.Transactions {
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

		for _, deposit := range deposits.Msg.Deposits {
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
