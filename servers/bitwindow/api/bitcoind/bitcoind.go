package api_bitcoind

import (
	"cmp"
	"context"
	"fmt"
	"slices"

	"encoding/hex"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitcoind/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitcoind/v1/bitcoindv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/service"
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
	bitcoind *service.Service[*coreproxy.Bitcoind],
) *Server {
	s := &Server{
		bitcoind: bitcoind,
	}
	return s
}

type Server struct {
	bitcoind *service.Service[*coreproxy.Bitcoind]
}

// EstimateSmartFee implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) EstimateSmartFee(ctx context.Context, req *connect.Request[pb.EstimateSmartFeeRequest]) (*connect.Response[pb.EstimateSmartFeeResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("bitcoin service unavailable: %w", err))
	}

	estimate, err := bitcoind.EstimateSmartFee(ctx, connect.NewRequest(&corepb.EstimateSmartFeeRequest{
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

// ListBlocks implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListBlocks(ctx context.Context, c *connect.Request[pb.ListBlocksRequest]) (*connect.Response[pb.ListBlocksResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	info, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, err
	}

	// Default to most recent blocks if no pagination
	startHeight := info.Msg.Blocks
	if c.Msg.StartHeight > 0 {
		startHeight = c.Msg.StartHeight
	}

	// Default page size
	pageSize := uint32(50)
	if c.Msg.PageSize > 0 {
		pageSize = c.Msg.PageSize
	}

	p := pool.NewWithResults[*pb.Block]().
		WithContext(ctx).
		WithCancelOnError().
		WithFirstError()

	for i := uint32(0); i < pageSize; i++ {
		p.Go(func(ctx context.Context) (*pb.Block, error) {
			height := int(startHeight) - int(i)
			// Stop if we hit genesis block
			if height < 0 {
				return nil, nil
			}
			hash, err := bitcoind.GetBlockHash(ctx, connect.NewRequest(&corepb.GetBlockHashRequest{
				Height: uint32(height),
			}))
			if err != nil {
				return nil, fmt.Errorf("get block hash %d: %w", height, err)
			}

			block, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
				Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
				Hash:      hash.Msg.Hash,
			}))
			if err != nil {
				return nil, fmt.Errorf("get block %s: %w", hash.Msg.Hash, err)
			}

			return &pb.Block{
				BlockTime:         block.Msg.Time,
				Height:            block.Msg.Height,
				Hash:              block.Msg.Hash,
				Confirmations:     block.Msg.Confirmations,
				Version:           block.Msg.Version,
				VersionHex:        block.Msg.VersionHex,
				MerkleRoot:        block.Msg.MerkleRoot,
				Nonce:             block.Msg.Nonce,
				Bits:              block.Msg.Bits,
				Difficulty:        block.Msg.Difficulty,
				PreviousBlockHash: block.Msg.PreviousBlockHash,
				NextBlockHash:     block.Msg.NextBlockHash,
				StrippedSize:      block.Msg.StrippedSize,
				Size:              block.Msg.Size,
				Weight:            block.Msg.Weight,
				Txids:             block.Msg.Txids,
			}, nil
		})
	}

	blocks, err := p.Wait()
	if err != nil {
		return nil, err
	}

	// Filter out nil blocks (from hitting genesis)
	blocks = lo.Filter(blocks, func(b *pb.Block, _ int) bool {
		return b != nil
	})

	slices.SortFunc(blocks, func(a, b *pb.Block) int {
		return -cmp.Compare(a.Height, b.Height)
	})

	return connect.NewResponse(&pb.ListBlocksResponse{
		RecentBlocks: blocks,
		HasMore:      startHeight > uint32(len(blocks)),
	}), nil
}

// ListRecentTransactions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListRecentTransactions(ctx context.Context, c *connect.Request[pb.ListRecentTransactionsRequest]) (*connect.Response[pb.ListRecentTransactionsResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	// First get mempool transactions
	mempoolRes, err := bitcoind.GetRawMempool(ctx, connect.NewRequest(&corepb.GetRawMempoolRequest{
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
			FeeSats:          uint64(fee),
			ConfirmedInBlock: nil,
		})
	}
	info, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("could not get blockchain info: %w", err)
	}

	// Get block at latest height
	blockHashRes, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
		Hash:      info.Msg.BestBlockHash,
		Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	}))
	if err != nil {
		return nil, fmt.Errorf("could not get block at height %d: %w", info.Msg.Blocks, err)
	}

	// Extract transactions from the 100 most recent blocks
	currentHash := blockHashRes.Msg.Hash
	for i := 0; i < 100 && currentHash != ""; i++ {
		blockRes, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
			Hash:      currentHash,
			Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO, // Get full transaction details
		}))
		if err != nil {
			return nil, fmt.Errorf("could not get block: %w", err)
		}
		for _, txid := range blockRes.Msg.Txids {
			// Get full transaction details
			txRes, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
				Txid: txid,
			}))
			if err != nil {
				return nil, fmt.Errorf("could not get transaction %s: %w", txid, err)
			}

			recentTx, isCoinbase, err := s.recentTransactionFromRaw(ctx, bitcoind, txRes.Msg.Tx.Data)
			if err != nil {
				return nil, fmt.Errorf("could not get recent transaction: %w", err)
			}

			if isCoinbase {
				continue
			}

			transactions = append(transactions, &pb.RecentTransaction{
				VirtualSize: recentTx.VirtualSize,
				Time:        blockRes.Msg.Time,
				Txid:        txid,
				FeeSats:     recentTx.FeeSats,
				ConfirmedInBlock: &pb.Block{
					BlockTime:         blockRes.Msg.Time,
					Height:            blockRes.Msg.Height,
					Hash:              currentHash,
					Confirmations:     blockRes.Msg.Confirmations,
					Version:           blockRes.Msg.Version,
					VersionHex:        blockRes.Msg.VersionHex,
					MerkleRoot:        blockRes.Msg.MerkleRoot,
					Nonce:             blockRes.Msg.Nonce,
					Bits:              blockRes.Msg.Bits,
					Difficulty:        blockRes.Msg.Difficulty,
					PreviousBlockHash: blockRes.Msg.PreviousBlockHash,
					NextBlockHash:     blockRes.Msg.NextBlockHash,
					StrippedSize:      blockRes.Msg.StrippedSize,
					Size:              blockRes.Msg.Size,
					Weight:            blockRes.Msg.Weight,
					Txids:             blockRes.Msg.Txids,
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
func (s *Server) recentTransactionFromRaw(ctx context.Context, bitcoind *coreproxy.Bitcoind, data []byte) (*pb.RecentTransaction, bool, error) {
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
			prevTxRes, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
				Txid:    txIn.PreviousOutPoint.Hash.String(),
				Verbose: true,
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
		FeeSats:     uint64(fee),
	}, isCoinbase, nil
}

// GetBlockchainInfo implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetBlockchainInfo(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetBlockchainInfoResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	info, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
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
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	info, err := bitcoind.GetPeerInfo(ctx, connect.NewRequest(&corepb.GetPeerInfoRequest{}))
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

// GetRawTransaction implements bitcoindv1connect.BitcoindServiceHandler
func (s *Server) GetRawTransaction(ctx context.Context, req *connect.Request[pb.GetRawTransactionRequest]) (*connect.Response[pb.GetRawTransactionResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("bitcoin service unavailable: %w", err))
	}

	// Get the raw transaction from bitcoind
	txRes, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
		Txid:    req.Msg.Txid,
		Verbose: true,
	}))
	if err != nil {
		return nil, fmt.Errorf("could not get transaction: %w", err)
	}

	// Convert inputs
	inputs := make([]*pb.Input, len(txRes.Msg.Inputs))
	for _, txIn := range txRes.Msg.Inputs {
		input := &pb.Input{
			Txid:      txIn.Txid,
			Vout:      uint32(txIn.Vout),
			Coinbase:  txIn.Coinbase,
			ScriptSig: &pb.ScriptSig{}, // Always include empty ScriptSig
			Sequence:  txIn.Sequence,
			Witness:   txIn.Witness,
		}
		if txIn.ScriptSig != nil {
			input.ScriptSig.Asm = txIn.ScriptSig.Asm
			input.ScriptSig.Hex = txIn.ScriptSig.Hex
		}
		inputs[txIn.Vout] = input
	}

	// Convert outputs
	outputs := make([]*pb.Output, len(txRes.Msg.Outputs))
	for _, txOut := range txRes.Msg.Outputs {
		output := &pb.Output{
			Amount:       txOut.Amount,
			Vout:         uint32(txOut.Vout),
			ScriptPubKey: &pb.ScriptPubKey{Type: txOut.ScriptPubKey.Type, Address: txOut.ScriptPubKey.Address},
			ScriptSig:    &pb.ScriptSig{}, // Always include empty ScriptSig
		}
		if txOut.ScriptSig != nil {
			output.ScriptSig.Asm = txOut.ScriptSig.Asm
			output.ScriptSig.Hex = txOut.ScriptSig.Hex
		}
		outputs[txOut.Vout] = output
	}

	return connect.NewResponse(&pb.GetRawTransactionResponse{
		Tx:            &pb.RawTransaction{Data: txRes.Msg.Tx.Data, Hex: hex.EncodeToString(txRes.Msg.Tx.Data)},
		Txid:          txRes.Msg.Txid,
		Hash:          txRes.Msg.Hash,
		Size:          int32(txRes.Msg.Size),
		Vsize:         int32(txRes.Msg.Vsize),
		Weight:        int32(txRes.Msg.Weight),
		Version:       uint32(txRes.Msg.Version),
		Locktime:      txRes.Msg.Locktime,
		Inputs:        inputs,
		Outputs:       outputs,
		Blockhash:     txRes.Msg.Blockhash,
		Confirmations: txRes.Msg.Confirmations,
		Time:          txRes.Msg.Time,
		Blocktime:     txRes.Msg.Blocktime,
	}), nil
}

// GetBlock implements bitcoindv1connect.BitcoindServiceHandler
func (s *Server) GetBlock(ctx context.Context, c *connect.Request[pb.GetBlockRequest]) (*connect.Response[pb.GetBlockResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	var hash string
	if c.Msg.Identifier != nil {
		switch v := c.Msg.Identifier.(type) {
		case *pb.GetBlockRequest_Hash:
			hash = v.Hash
		case *pb.GetBlockRequest_Height:
			// Get block hash for this height first
			hashRes, err := bitcoind.GetBlockHash(ctx, connect.NewRequest(&corepb.GetBlockHashRequest{
				Height: v.Height,
			}))
			if err != nil {
				return nil, fmt.Errorf("get block hash for height %d: %w", v.Height, err)
			}
			hash = hashRes.Msg.Hash
		}
	}

	// Get block details
	block, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
		Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
		Hash:      hash,
	}))
	if err != nil {
		return nil, fmt.Errorf("get block %s: %w", hash, err)
	}

	return connect.NewResponse(&pb.GetBlockResponse{
		Block: &pb.Block{
			BlockTime:         block.Msg.Time,
			Height:            block.Msg.Height,
			Hash:              block.Msg.Hash,
			Confirmations:     block.Msg.Confirmations,
			Version:           block.Msg.Version,
			VersionHex:        block.Msg.VersionHex,
			MerkleRoot:        block.Msg.MerkleRoot,
			Nonce:             block.Msg.Nonce,
			Bits:              block.Msg.Bits,
			Difficulty:        block.Msg.Difficulty,
			PreviousBlockHash: block.Msg.PreviousBlockHash,
			NextBlockHash:     block.Msg.NextBlockHash,
			StrippedSize:      block.Msg.StrippedSize,
			Size:              block.Msg.Size,
			Weight:            block.Msg.Weight,
			Txids:             block.Msg.Txids,
		},
	}), nil
}
