package server

import (
	"context"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/bdk"
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1/drivechainv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var _ rpc.DrivechainServiceHandler = new(Server)

func New(wallet *bdk.Wallet, bitcoind *coreproxy.Bitcoind) *Server {
	return &Server{wallet, bitcoind}
}

type Server struct {
	wallet   *bdk.Wallet
	bitcoind *coreproxy.Bitcoind
}

// ListUnconfirmedTransactions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListUnconfirmedTransactions(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListUnconfirmedTransactionsResponse], error) {
	res, err := s.bitcoind.GetRawMempool(ctx, connect.NewRequest(&corepb.GetRawMempoolRequest{
		Verbose: true,
	}))
	if err != nil {
		return nil, err
	}

	var out []*pb.UnconfirmedTransaction
	for txid, tx := range res.Msg.Transactions {
		fee, err := btcutil.NewAmount(tx.Fees.Base)
		if err != nil {
			return nil, err
		}

		out = append(out, &pb.UnconfirmedTransaction{
			VirtualSize: tx.VirtualSize,
			Weight:      tx.Weight,
			Time:        tx.Time,
			Txid:        txid,
			FeeSatoshi:  uint64(fee),
			// IsBmmRequest:          false,
			// IsCriticalDataRequest: false,
		})
	}
	return connect.NewResponse(&pb.ListUnconfirmedTransactionsResponse{
		UnconfirmedTransactions: out,
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
