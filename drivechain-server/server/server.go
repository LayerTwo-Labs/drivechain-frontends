package server

import (
	"cmp"
	"context"
	"fmt"
	"slices"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/bdk"
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1/drivechainv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/samber/lo"
	"github.com/sourcegraph/conc/pool"
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

// ListRecentBlocks implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListRecentBlocks(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListRecentBlocksResponse], error) {
	info, err := s.bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, err
	}

	p := pool.NewWithResults[*pb.ListRecentBlocksResponse_RecentBlock]().
		WithContext(ctx).
		WithCancelOnError().
		WithFirstError()

	const numBlocks = 10
	for i := range numBlocks {
		p.Go(func(ctx context.Context) (*pb.ListRecentBlocksResponse_RecentBlock, error) {

			height := info.Msg.Blocks - uint32(i)
			hash, err := s.bitcoind.GetBlockHash(ctx, connect.NewRequest(&corepb.GetBlockHashRequest{
				Height: height,
			}))
			if err != nil {
				return nil, fmt.Errorf("get block hash %d: %w", height, err)
			}

			block, err := s.bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
				Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
				Hash:      hash.Msg.Hash,
			}))
			if err != nil {
				return nil, fmt.Errorf("get block %s: %w", hash.Msg.Hash, err)
			}

			return &pb.ListRecentBlocksResponse_RecentBlock{
				BlockTime:   block.Msg.Time,
				BlockHeight: block.Msg.Height,
				Hash:        block.Msg.Hash,
			}, nil
		})
	}

	blocks, err := p.Wait()
	if err != nil {
		return nil, err
	}

	slices.SortFunc(blocks, func(a, b *pb.ListRecentBlocksResponse_RecentBlock) int {
		return -cmp.Compare(a.BlockHeight, b.BlockHeight)
	})

	return connect.NewResponse(&pb.ListRecentBlocksResponse{
		RecentBlocks: blocks,
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
	res, err := s.wallet.GetBalance(ctx)
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.GetBalanceResponse{
		ConfirmedSatoshi: uint64(res.Confirmed),
		PendingSatoshi:   uint64(res.Immature) + uint64(res.TrustedPending) + uint64(res.UntrustedPending),
	}), nil
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
