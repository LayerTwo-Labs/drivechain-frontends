package api_bitcoind

import (
	"cmp"
	"context"
	"fmt"
	"slices"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/bitcoind/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/bitcoind/v1/bitcoindv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/samber/lo"
	"github.com/sourcegraph/conc/pool"
	"google.golang.org/protobuf/types/known/emptypb"
)

var _ rpc.BitcoindServiceHandler = new(Server)

// New creates a new Server
func New(
	bitcoind *coreproxy.Bitcoind,
) *Server {
	s := &Server{
		bitcoind: bitcoind,
	}
	return s
}

type Server struct {
	bitcoind *coreproxy.Bitcoind
}

// EstimateSmartFee implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) EstimateSmartFee(ctx context.Context, req *connect.Request[pb.EstimateSmartFeeRequest]) (*connect.Response[pb.EstimateSmartFeeResponse], error) {
	estimate, err := s.bitcoind.EstimateSmartFee(ctx, connect.NewRequest(&corepb.EstimateSmartFeeRequest{
		ConfTarget: req.Msg.ConfTarget,
	}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.EstimateSmartFeeResponse{
		FeeRate: estimate.Msg.FeeRate,
		Errors:  estimate.Msg.Errors,
	}), nil
}

// ListRecentBlocks implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListRecentBlocks(ctx context.Context, c *connect.Request[pb.ListRecentBlocksRequest]) (*connect.Response[pb.ListRecentBlocksResponse], error) {
	info, err := s.bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, err
	}

	p := pool.NewWithResults[*pb.ListRecentBlocksResponse_RecentBlock]().
		WithContext(ctx).
		WithCancelOnError().
		WithFirstError()

	if c.Msg.Count == 0 {
		c.Msg.Count = 10
	}

	for i := range c.Msg.Count {
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

// ListUnconfirmedTransactions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListUnconfirmedTransactions(ctx context.Context, c *connect.Request[pb.ListUnconfirmedTransactionsRequest]) (*connect.Response[pb.ListUnconfirmedTransactionsResponse], error) {
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
		})
	}

	slices.SortFunc(out, func(a, b *pb.UnconfirmedTransaction) int {
		return cmp.Compare(b.Time.AsTime().Unix(), a.Time.AsTime().Unix())
	})

	if c.Msg.Count > 0 {
		if c.Msg.Count > int64(len(out)) {
			c.Msg.Count = int64(len(out))
		}
		out = out[:c.Msg.Count]
	}

	return connect.NewResponse(&pb.ListUnconfirmedTransactionsResponse{
		UnconfirmedTransactions: out,
	}), nil
}

// GetBlockchainInfo implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetBlockchainInfo(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetBlockchainInfoResponse], error) {
	info, err := s.bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.GetBlockchainInfoResponse{
		Chain:                info.Msg.Chain,
		Blocks:               info.Msg.Blocks,
		Headers:              info.Msg.Headers,
		BestBlockHash:        info.Msg.BestBlockHash,
		InitialBlockDownload: info.Msg.InitialBlockDownload,
	}), nil
}

// ListPeers implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListPeers(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListPeersResponse], error) {
	info, err := s.bitcoind.GetPeerInfo(ctx, connect.NewRequest(&corepb.GetPeerInfoRequest{}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.ListPeersResponse{
		Peers: lo.Map(info.Msg.Peers, func(item *corepb.Peer, index int) *pb.Peer {
			return &pb.Peer{
				Id:           item.Id,
				Addr:         item.Addr,
				SyncedBlocks: item.SyncedBlocks,
			}

		}),
	}), nil
}
