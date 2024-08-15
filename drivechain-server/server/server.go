package server

import (
	"context"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/bdk"
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1/drivechainv1connect"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var _ rpc.DrivechainServiceHandler = new(Server)

func New(wallet *bdk.Wallet) *Server {
	return &Server{wallet}
}

type Server struct {
	wallet *bdk.Wallet
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
