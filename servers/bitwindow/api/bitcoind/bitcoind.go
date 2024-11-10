package api_bitcoind

import (
	"cmp"
	"context"
	"fmt"
	"slices"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitcoind/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitcoind/v1/bitcoindv1connect"
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

	p := pool.NewWithResults[*pb.Block]().
		WithContext(ctx).
		WithCancelOnError().
		WithFirstError()

	if c.Msg.Count == 0 {
		c.Msg.Count = 10
	}

	for i := range c.Msg.Count {
		p.Go(func(ctx context.Context) (*pb.Block, error) {
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

			return &pb.Block{
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

	slices.SortFunc(blocks, func(a, b *pb.Block) int {
		return -cmp.Compare(a.BlockHeight, b.BlockHeight)
	})

	return connect.NewResponse(&pb.ListRecentBlocksResponse{
		RecentBlocks: blocks,
	}), nil
}

// ListRecentTransactions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListRecentTransactions(ctx context.Context, c *connect.Request[pb.ListRecentTransactionsRequest]) (*connect.Response[pb.ListRecentTransactionsResponse], error) {
	// First get mempool transactions
	mempoolRes, err := s.bitcoind.GetRawMempool(ctx, connect.NewRequest(&corepb.GetRawMempoolRequest{
		Verbose: true,
	}))
	if err != nil {
		return nil, fmt.Errorf("could not get mempool: %w", err)
	}

	var transactions []*pb.RecentTransaction

	// Add mempool transactions
	for txid, tx := range mempoolRes.Msg.Transactions {
		fee, err := btcutil.NewAmount(tx.Fees.Base)
		if err != nil {
			return nil, fmt.Errorf("could not parse fee: %w", err)
		}

		transactions = append(transactions, &pb.RecentTransaction{
			VirtualSize:      tx.VirtualSize,
			Time:             tx.Time,
			Txid:             txid,
			FeeSatoshi:       uint64(fee),
			ConfirmedInBlock: nil,
		})
	}
	info, err := s.bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("could not get blockchain info: %w", err)
	}

	// Get block at latest height
	blockHashRes, err := s.bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
		Hash:      info.Msg.BestBlockHash,
		Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	}))
	if err != nil {
		return nil, fmt.Errorf("could not get block at height %d: %w", info.Msg.Blocks, err)
	}

	// Extract transactions from the 100 most recent blocks
	currentHash := blockHashRes.Msg.Hash
	for i := 0; i < 100 && currentHash != ""; i++ {
		blockRes, err := s.bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
			Hash:      currentHash,
			Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO, // Get full transaction details
		}))
		if err != nil {
			return nil, fmt.Errorf("could not get block: %w", err)
		}
		for _, txid := range blockRes.Msg.Txids {
			// Get full transaction details
			txRes, err := s.bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
				Txid: txid,
			}))
			if err != nil {
				return nil, fmt.Errorf("could not get transaction %s: %w", txid, err)
			}

			recentTx, isCoinbase, err := s.recentTransactionFromRaw(ctx, txRes.Msg.Tx.Data)
			if err != nil {
				return nil, fmt.Errorf("could not get recent transaction: %w", err)
			}

			if isCoinbase {
				continue
			}

			transactions = append(transactions, &pb.RecentTransaction{
				Time:        blockRes.Msg.Time,
				Txid:        txid,
				FeeSatoshi:  recentTx.FeeSatoshi,
				VirtualSize: recentTx.VirtualSize,
				ConfirmedInBlock: &pb.Block{
					BlockTime:   blockRes.Msg.Time,
					BlockHeight: blockRes.Msg.Height,
					Hash:        currentHash,
				},
			})
		}

		currentHash = blockRes.Msg.PreviousBlockHash
	}

	// Sort by time, newest first
	slices.SortFunc(transactions, func(a, b *pb.RecentTransaction) int {
		return cmp.Compare(b.Time.AsTime().Unix(), a.Time.AsTime().Unix())
	})

	// Limit to requested count
	count := int64(100)
	if c.Msg.Count > 0 {
		count = c.Msg.Count
	}
	if count > int64(len(transactions)) {
		count = int64(len(transactions))
	}
	transactions = transactions[:count]

	return connect.NewResponse(&pb.ListRecentTransactionsResponse{
		Transactions: transactions,
	}), nil
}
func (s *Server) recentTransactionFromRaw(ctx context.Context, data []byte) (*pb.RecentTransaction, bool, error) {
	tx, err := btcutil.NewTxFromBytes(data)
	if err != nil {
		return nil, false, fmt.Errorf("could not decode transaction hex: %w", err)
	}

	// Check if coinbase, and skip input calculation if so
	isCoinbase := len(tx.MsgTx().TxIn) > 0 && tx.MsgTx().TxIn[0].PreviousOutPoint.Hash.String() == "0000000000000000000000000000000000000000000000000000000000000000"
	var fee int64
	if !isCoinbase {
		// Calculate total input value by looking up value of each input transaction
		var totalIn int64
		for _, txIn := range tx.MsgTx().TxIn {
			prevTxRes, err := s.bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
				Txid: txIn.PreviousOutPoint.Hash.String(),
			}))
			if err != nil {
				return nil, false, fmt.Errorf("could not get input transaction %s: %w", txIn.PreviousOutPoint.Hash.String(), err)
			}

			prevTx, err := btcutil.NewTxFromBytes(prevTxRes.Msg.Tx.Data)
			if err != nil {
				return nil, false, fmt.Errorf("could not decode input transaction: %w", err)
			}

			totalIn += prevTx.MsgTx().TxOut[txIn.PreviousOutPoint.Index].Value
		}

		// Calculate total output value
		var totalOut int64
		for _, txOut := range tx.MsgTx().TxOut {
			totalOut += txOut.Value
		}

		// Calculate fee as the difference between inputs and outputs
		fee = totalIn - totalOut
		if fee < 0 {
			return nil, false, fmt.Errorf("could not calculate fee: negative fee %d", fee)
		}
	}

	return &pb.RecentTransaction{
		VirtualSize: uint32(tx.MsgTx().SerializeSize()),
		Txid:        tx.Hash().String(),
		FeeSatoshi:  uint64(fee),
	}, isCoinbase, nil
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
