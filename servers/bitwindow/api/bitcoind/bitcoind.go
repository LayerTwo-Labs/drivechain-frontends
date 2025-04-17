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

// AnalyzePsbt implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) AnalyzePsbt(ctx context.Context, req *connect.Request[pb.AnalyzePsbtRequest]) (*connect.Response[pb.AnalyzePsbtResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.AnalyzePsbt(ctx, connect.NewRequest(&corepb.AnalyzePsbtRequest{
		Psbt: req.Msg.Psbt,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not analyze PSBT: %w", err)
	}

	// Convert the core response to our API response
	inputs := make([]*pb.AnalyzePsbtResponse_Input, len(res.Msg.Inputs))
	for i, input := range res.Msg.Inputs {
		inputs[i] = &pb.AnalyzePsbtResponse_Input{
			HasUtxo: input.HasUtxo,
			IsFinal: input.IsFinal,
			Next:    input.Next,
		}

		// Convert missing data if present
		if input.Missing != nil {
			inputs[i].Missing = &pb.AnalyzePsbtResponse_Input_Missing{

				Pubkeys:       input.Missing.Pubkeys,
				Signatures:    input.Missing.Signatures,
				RedeemScript:  input.Missing.RedeemScript,
				WitnessScript: input.Missing.WitnessScript,
			}
		}
	}

	return connect.NewResponse(&pb.AnalyzePsbtResponse{
		Inputs:           inputs,
		EstimatedVsize:   res.Msg.EstimatedVsize,
		EstimatedFeerate: res.Msg.EstimatedFeerate,
		Fee:              res.Msg.Fee,
		Next:             res.Msg.Next,
		Error:            res.Msg.Error,
	}), nil
}

// CombinePsbt implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) CombinePsbt(ctx context.Context, req *connect.Request[pb.CombinePsbtRequest]) (*connect.Response[pb.CombinePsbtResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.CombinePsbt(ctx, connect.NewRequest(&corepb.CombinePsbtRequest{
		Psbts: req.Msg.Psbts,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not combine PSBT: %w", err)
	}

	return connect.NewResponse(&pb.CombinePsbtResponse{
		Psbt: res.Msg.Psbt,
	}), nil
}

// CreatePsbt implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) CreatePsbt(ctx context.Context, req *connect.Request[pb.CreatePsbtRequest]) (*connect.Response[pb.CreatePsbtResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	// Convert inputs to core format
	inputs := make([]*corepb.CreatePsbtRequest_Input, len(req.Msg.Inputs))
	for i, input := range req.Msg.Inputs {
		inputs[i] = &corepb.CreatePsbtRequest_Input{
			Txid:     input.Txid,
			Vout:     input.Vout,
			Sequence: input.Sequence,
		}
	}

	res, err := bitcoind.CreatePsbt(ctx, connect.NewRequest(&corepb.CreatePsbtRequest{
		Inputs:   inputs,
		Outputs:  req.Msg.Outputs,
		Locktime: req.Msg.Locktime,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not create PSBT: %w", err)
	}

	return connect.NewResponse(&pb.CreatePsbtResponse{
		Psbt: res.Msg.Psbt,
	}), nil
}

// CreateRawTransaction implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) CreateRawTransaction(ctx context.Context, req *connect.Request[pb.CreateRawTransactionRequest]) (*connect.Response[pb.CreateRawTransactionResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	// Convert inputs to core format
	inputs := make([]*corepb.CreateRawTransactionRequest_Input, len(req.Msg.Inputs))
	for i, input := range req.Msg.Inputs {
		inputs[i] = &corepb.CreateRawTransactionRequest_Input{
			Txid:     input.Txid,
			Vout:     input.Vout,
			Sequence: input.Sequence,
		}
	}

	// Call the core bitcoind createrawtransaction RPC
	res, err := bitcoind.CreateRawTransaction(ctx, connect.NewRequest(&corepb.CreateRawTransactionRequest{
		Inputs:   inputs,
		Outputs:  req.Msg.Outputs,
		Locktime: req.Msg.Locktime,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not create raw transaction: %w", err)
	}

	return connect.NewResponse(&pb.CreateRawTransactionResponse{
		Tx: &pb.RawTransaction{
			Data: res.Msg.Tx.Data,
			Hex:  hex.EncodeToString(res.Msg.Tx.Data),
		},
	}), nil
}

// DecodePsbt implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) DecodePsbt(ctx context.Context, req *connect.Request[pb.DecodePsbtRequest]) (*connect.Response[pb.DecodePsbtResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.DecodePsbt(ctx, connect.NewRequest(&corepb.DecodePsbtRequest{
		Psbt: req.Msg.Psbt,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not decode PSBT: %w", err)
	}

	// Convert inputs
	inputs := make([]*pb.DecodePsbtResponse_Input, len(res.Msg.Inputs))
	for i, input := range res.Msg.Inputs {
		inputs[i] = &pb.DecodePsbtResponse_Input{
			NonWitnessUtxo:    convertRawTransaction(input.NonWitnessUtxo),
			PartialSignatures: input.PartialSignatures,
			Sighash:           input.Sighash,
			FinalScriptsig: &pb.ScriptSig{
				Asm: input.FinalScriptsig.Asm,
				Hex: input.FinalScriptsig.Hex,
			},
			FinalScriptwitness: input.FinalScriptwitness,
			Unknown:            input.Unknown,
			WitnessUtxo: &pb.DecodePsbtResponse_WitnessUtxo{
				Amount: input.WitnessUtxo.Amount,
				ScriptPubKey: &pb.ScriptPubKey{
					Type:    input.WitnessUtxo.ScriptPubKey.Type,
					Address: input.WitnessUtxo.ScriptPubKey.Address,
				},
			},
			RedeemScript: &pb.DecodePsbtResponse_RedeemScript{
				Asm:  input.RedeemScript.Asm,
				Hex:  input.RedeemScript.Hex,
				Type: input.RedeemScript.Type,
			},
			WitnessScript: &pb.DecodePsbtResponse_RedeemScript{
				Asm:  input.WitnessScript.Asm,
				Hex:  input.WitnessScript.Hex,
				Type: input.WitnessScript.Type,
			},
			Bip32Derivs: convertBip32Derivs(input.Bip32Derivs),
		}
	}

	// Convert outputs
	outputs := make([]*pb.DecodePsbtResponse_Output, len(res.Msg.Outputs))
	for i, output := range res.Msg.Outputs {
		outputs[i] = &pb.DecodePsbtResponse_Output{
			Unknown: output.Unknown,
		}

		// Convert redeem script if present
		if output.RedeemScript != nil {
			outputs[i].RedeemScript = &pb.DecodePsbtResponse_RedeemScript{
				Asm:  output.RedeemScript.Asm,
				Hex:  output.RedeemScript.Hex,
				Type: output.RedeemScript.Type,
			}
		}

		// Convert witness script if present
		if output.WitnessScript != nil {
			outputs[i].WitnessScript = &pb.DecodePsbtResponse_RedeemScript{
				Asm:  output.WitnessScript.Asm,
				Hex:  output.WitnessScript.Hex,
				Type: output.WitnessScript.Type,
			}
		}

		// Convert BIP32 derivation paths
		if len(output.Bip32Derivs) > 0 {
			outputs[i].Bip32Derivs = make([]*pb.DecodePsbtResponse_Bip32Deriv, len(output.Bip32Derivs))
			for j, deriv := range output.Bip32Derivs {
				outputs[i].Bip32Derivs[j] = &pb.DecodePsbtResponse_Bip32Deriv{
					Pubkey:            deriv.Pubkey,
					MasterFingerprint: deriv.MasterFingerprint,
					Path:              deriv.Path,
				}
			}
		}
	}

	// Convert the transaction data
	txInputs := make([]*pb.Input, len(res.Msg.Tx.Inputs))
	for i, input := range res.Msg.Tx.Inputs {
		txInputs[i] = &pb.Input{
			Txid:     input.Txid,
			Vout:     uint32(input.Vout),
			Coinbase: input.Coinbase,
			Sequence: input.Sequence,
			Witness:  input.Witness,
		}
		if input.ScriptSig != nil {
			txInputs[i].ScriptSig.Asm = input.ScriptSig.Asm
			txInputs[i].ScriptSig.Hex = input.ScriptSig.Hex
		}
	}

	txOutputs := make([]*pb.Output, len(res.Msg.Tx.Outputs))
	for i, output := range res.Msg.Tx.Outputs {
		txOutputs[i] = &pb.Output{
			Amount: output.Amount,
			Vout:   uint32(output.Vout),
			ScriptPubKey: &pb.ScriptPubKey{
				Type:    output.ScriptPubKey.Type,
				Address: output.ScriptPubKey.Address,
			},
		}
	}

	tx := &pb.DecodeRawTransactionResponse{
		Txid:        res.Msg.Tx.Txid,
		Hash:        res.Msg.Tx.Hash,
		Size:        res.Msg.Tx.Size,
		VirtualSize: res.Msg.Tx.VirtualSize,
		Weight:      res.Msg.Tx.Weight,
		Version:     res.Msg.Tx.Version,
		Locktime:    res.Msg.Tx.Locktime,
		Inputs:      txInputs,
		Outputs:     txOutputs,
	}

	return connect.NewResponse(&pb.DecodePsbtResponse{
		Tx:      tx,
		Unknown: res.Msg.Unknown,
		Inputs:  inputs,
		Outputs: outputs,
		Fee:     res.Msg.Fee,
	}), nil
}

func convertRawTransaction(tx *corepb.DecodeRawTransactionResponse) *pb.DecodeRawTransactionResponse {
	if tx == nil {
		return nil
	}
	return &pb.DecodeRawTransactionResponse{
		Txid:        tx.Txid,
		Hash:        tx.Hash,
		Size:        tx.Size,
		VirtualSize: tx.VirtualSize,
		Weight:      tx.Weight,
		Version:     tx.Version,
		Locktime:    tx.Locktime,
	}
}

func convertBip32Derivs(derivs []*corepb.DecodePsbtResponse_Bip32Deriv) []*pb.DecodePsbtResponse_Bip32Deriv {
	if derivs == nil {
		return nil
	}
	result := make([]*pb.DecodePsbtResponse_Bip32Deriv, len(derivs))
	for i, deriv := range derivs {
		result[i] = &pb.DecodePsbtResponse_Bip32Deriv{
			Pubkey:            deriv.Pubkey,
			MasterFingerprint: deriv.MasterFingerprint,
			Path:              deriv.Path,
		}
	}
	return result
}

// JoinPsbts implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) JoinPsbts(ctx context.Context, req *connect.Request[pb.JoinPsbtsRequest]) (*connect.Response[pb.JoinPsbtsResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	// Call the core bitcoind createrawtransaction RPC
	res, err := bitcoind.JoinPsbts(ctx, connect.NewRequest(&corepb.JoinPsbtsRequest{
		Psbts: req.Msg.Psbts,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not join PSBTs: %w", err)
	}

	return connect.NewResponse(&pb.JoinPsbtsResponse{
		Psbt: res.Msg.Psbt,
	}), nil
}

// TestMempoolAccept implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) TestMempoolAccept(ctx context.Context, req *connect.Request[pb.TestMempoolAcceptRequest]) (*connect.Response[pb.TestMempoolAcceptResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	// Call the core bitcoind createrawtransaction RPC
	res, err := bitcoind.TestMempoolAccept(ctx, connect.NewRequest(&corepb.TestMempoolAcceptRequest{
		Rawtxs:     req.Msg.Rawtxs,
		MaxFeeRate: req.Msg.MaxFeeRate,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not test mempool accept: %w", err)
	}

	results := make([]*pb.TestMempoolAcceptResponse_Result, len(res.Msg.Results))
	for i, result := range res.Msg.Results {
		results[i] = &pb.TestMempoolAcceptResponse_Result{
			Txid:         result.Txid,
			Allowed:      result.Allowed,
			RejectReason: result.RejectReason,
			Vsize:        result.Vsize,
			Fees:         result.Fees,
		}
	}

	return connect.NewResponse(&pb.TestMempoolAcceptResponse{
		Results: results,
	}), nil
}

// UtxoUpdatePsbt implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) UtxoUpdatePsbt(ctx context.Context, req *connect.Request[pb.UtxoUpdatePsbtRequest]) (*connect.Response[pb.UtxoUpdatePsbtResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	// Call the core bitcoind createrawtransaction RPC
	res, err := bitcoind.UtxoUpdatePsbt(ctx, connect.NewRequest(&corepb.UtxoUpdatePsbtRequest{
		Psbt:        req.Msg.Psbt,
		Descriptors: []*corepb.Descriptor{},
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not test mempool accept: %w", err)
	}

	return connect.NewResponse(&pb.UtxoUpdatePsbtResponse{
		Psbt: res.Msg.Psbt,
	}), nil
}

// EstimateSmartFee implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) EstimateSmartFee(ctx context.Context, req *connect.Request[pb.EstimateSmartFeeRequest]) (*connect.Response[pb.EstimateSmartFeeResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	estimate, err := bitcoind.EstimateSmartFee(ctx, connect.NewRequest(&corepb.EstimateSmartFeeRequest{
		ConfTarget: req.Msg.ConfTarget,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not estimate smart fee: %w", err)
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
		return nil, fmt.Errorf("bitcoind: could not get blockchain info: %w", err)
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
				return nil, fmt.Errorf("bitcoind: could not get block hash %d: %w", height, err)
			}

			block, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
				Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
				Hash:      hash.Msg.Hash,
			}))
			if err != nil {
				return nil, fmt.Errorf("bitcoind: could not get block %s: %w", hash.Msg.Hash, err)
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
		return nil, fmt.Errorf("bitcoind: could not get mempool: %w", err)
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
		return nil, fmt.Errorf("bitcoind: could not get blockchain info: %w", err)
	}

	// Get block at latest height
	blockHashRes, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
		Hash:      info.Msg.BestBlockHash,
		Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get block at height %d: %w", info.Msg.Blocks, err)
	}

	// Extract transactions from the 100 most recent blocks
	currentHash := blockHashRes.Msg.Hash
	for i := 0; i < 100 && currentHash != ""; i++ {
		blockRes, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
			Hash:      currentHash,
			Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO, // Get full transaction details
		}))
		if err != nil {
			return nil, fmt.Errorf("bitcoind: could not get block: %w", err)
		}
		for _, txid := range blockRes.Msg.Txids {
			// Get full transaction details
			txRes, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
				Txid: txid,
			}))
			if err != nil {
				return nil, fmt.Errorf("bitcoind: could not get transaction %s: %w", txid, err)
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
				return nil, false, fmt.Errorf("bitcoind: could not get input transaction %s: %w", txIn.PreviousOutPoint.Hash.String(), err)
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
		return nil, fmt.Errorf("bitcoind: could not get blockchain info: %w", err)
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
		return nil, fmt.Errorf("bitcoind: could not get peer info: %w", err)
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
		return nil, err
	}

	// Get the raw transaction from bitcoind
	txRes, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
		Txid:    req.Msg.Txid,
		Verbose: true,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get transaction: %w", err)
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
				return nil, fmt.Errorf("bitcoind: could not get block hash for height %d: %w", v.Height, err)
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
		return nil, fmt.Errorf("bitcoind: could not get block %s: %w", hash, err)
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

// AddMultisigAddress implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) AddMultisigAddress(ctx context.Context, req *connect.Request[pb.AddMultisigAddressRequest]) (*connect.Response[pb.AddMultisigAddressResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.AddMultisigAddress(ctx, connect.NewRequest(&corepb.AddMultisigAddressRequest{
		RequiredSigs: req.Msg.RequiredSigs,
		Keys:         req.Msg.Keys,
		Label:        req.Msg.Label,
		Wallet:       req.Msg.Wallet,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not add multisig address: %w", err)
	}

	return connect.NewResponse(&pb.AddMultisigAddressResponse{
		Address: res.Msg.Address,
	}), nil
}

// BackupWallet implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) BackupWallet(ctx context.Context, req *connect.Request[pb.BackupWalletRequest]) (*connect.Response[pb.BackupWalletResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	_, err = bitcoind.BackupWallet(ctx, connect.NewRequest(&corepb.BackupWalletRequest{
		Destination: req.Msg.Destination,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not backup wallet: %w", err)
	}

	return connect.NewResponse(&pb.BackupWalletResponse{}), nil
}

// CreateMultisig implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) CreateMultisig(ctx context.Context, req *connect.Request[pb.CreateMultisigRequest]) (*connect.Response[pb.CreateMultisigResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.CreateMultisig(ctx, connect.NewRequest(&corepb.CreateMultisigRequest{
		RequiredSigs: req.Msg.RequiredSigs,
		Keys:         req.Msg.Keys,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not create multisig: %w", err)
	}

	return connect.NewResponse(&pb.CreateMultisigResponse{
		Address:      res.Msg.Address,
		RedeemScript: res.Msg.RedeemScript,
	}), nil
}

// CreateWallet implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) CreateWallet(ctx context.Context, req *connect.Request[pb.CreateWalletRequest]) (*connect.Response[pb.CreateWalletResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               req.Msg.Name,
		DisablePrivateKeys: req.Msg.DisablePrivateKeys,
		Blank:              req.Msg.Blank,
		Passphrase:         req.Msg.Passphrase,
		AvoidReuse:         req.Msg.AvoidReuse,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not create wallet: %w", err)
	}

	return connect.NewResponse(&pb.CreateWalletResponse{
		Name:    res.Msg.Name,
		Warning: res.Msg.Warning,
	}), nil
}

// DumpPrivKey implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) DumpPrivKey(ctx context.Context, req *connect.Request[pb.DumpPrivKeyRequest]) (*connect.Response[pb.DumpPrivKeyResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.DumpPrivKey(ctx, connect.NewRequest(&corepb.DumpPrivKeyRequest{
		Address: req.Msg.Address,
		Wallet:  req.Msg.Wallet,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not dump private key: %w", err)
	}

	return connect.NewResponse(&pb.DumpPrivKeyResponse{
		PrivateKey: res.Msg.PrivateKey,
	}), nil
}

// DumpWallet implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) DumpWallet(ctx context.Context, req *connect.Request[pb.DumpWalletRequest]) (*connect.Response[pb.DumpWalletResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.DumpWallet(ctx, connect.NewRequest(&corepb.DumpWalletRequest{
		Filename: req.Msg.Filename,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not dump wallet: %w", err)
	}

	return connect.NewResponse(&pb.DumpWalletResponse{
		Filename: res.Msg.Filename,
	}), nil
}

// GetAccount implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) GetAccount(ctx context.Context, req *connect.Request[pb.GetAccountRequest]) (*connect.Response[pb.GetAccountResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.GetAccount(ctx, connect.NewRequest(&corepb.GetAccountRequest{
		Address: req.Msg.Address,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get account: %w", err)
	}

	return connect.NewResponse(&pb.GetAccountResponse{
		Account: res.Msg.Account,
	}), nil
}

// GetAddressesByAccount implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) GetAddressesByAccount(ctx context.Context, req *connect.Request[pb.GetAddressesByAccountRequest]) (*connect.Response[pb.GetAddressesByAccountResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.GetAddressesByAccount(ctx, connect.NewRequest(&corepb.GetAddressesByAccountRequest{
		Account: req.Msg.Account,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get addresses: %w", err)
	}

	return connect.NewResponse(&pb.GetAddressesByAccountResponse{
		Addresses: res.Msg.Addresses,
	}), nil
}

// ImportAddress implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) ImportAddress(ctx context.Context, req *connect.Request[pb.ImportAddressRequest]) (*connect.Response[pb.ImportAddressResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	_, err = bitcoind.ImportAddress(ctx, connect.NewRequest(&corepb.ImportAddressRequest{
		Address: req.Msg.Address,
		Label:   req.Msg.Label,
		Rescan:  req.Msg.Rescan,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not import address: %w", err)
	}

	return connect.NewResponse(&pb.ImportAddressResponse{}), nil
}

// ImportPrivKey implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) ImportPrivKey(ctx context.Context, req *connect.Request[pb.ImportPrivKeyRequest]) (*connect.Response[pb.ImportPrivKeyResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	_, err = bitcoind.ImportPrivKey(ctx, connect.NewRequest(&corepb.ImportPrivKeyRequest{
		PrivateKey: req.Msg.PrivateKey,
		Label:      req.Msg.Label,
		Rescan:     req.Msg.Rescan,
		Wallet:     req.Msg.Wallet,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not import private key: %w", err)
	}

	return connect.NewResponse(&pb.ImportPrivKeyResponse{}), nil
}

// ImportPubKey implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) ImportPubKey(ctx context.Context, req *connect.Request[pb.ImportPubKeyRequest]) (*connect.Response[pb.ImportPubKeyResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	_, err = bitcoind.ImportPubKey(ctx, connect.NewRequest(&corepb.ImportPubKeyRequest{
		Pubkey: req.Msg.Pubkey,
		Rescan: req.Msg.Rescan,
		Wallet: req.Msg.Wallet,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not import public key: %w", err)
	}

	return connect.NewResponse(&pb.ImportPubKeyResponse{}), nil
}

// ImportWallet implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) ImportWallet(ctx context.Context, req *connect.Request[pb.ImportWalletRequest]) (*connect.Response[pb.ImportWalletResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	_, err = bitcoind.ImportWallet(ctx, connect.NewRequest(&corepb.ImportWalletRequest{
		Filename: req.Msg.Filename,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not import wallet: %w", err)
	}

	return connect.NewResponse(&pb.ImportWalletResponse{}), nil
}

// KeyPoolRefill implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) KeyPoolRefill(ctx context.Context, req *connect.Request[pb.KeyPoolRefillRequest]) (*connect.Response[pb.KeyPoolRefillResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	_, err = bitcoind.KeyPoolRefill(ctx, connect.NewRequest(&corepb.KeyPoolRefillRequest{
		NewSize: req.Msg.NewSize,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not refill keypool: %w", err)
	}

	return connect.NewResponse(&pb.KeyPoolRefillResponse{}), nil
}

// ListAccounts implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) ListAccounts(ctx context.Context, req *connect.Request[pb.ListAccountsRequest]) (*connect.Response[pb.ListAccountsResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := bitcoind.ListAccounts(ctx, connect.NewRequest(&corepb.ListAccountsRequest{
		MinConf: req.Msg.MinConf,
		Wallet:  req.Msg.Wallet,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not list accounts: %w", err)
	}

	return connect.NewResponse(&pb.ListAccountsResponse{
		Accounts: res.Msg.Accounts,
	}), nil
}

// SetAccount implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) SetAccount(ctx context.Context, req *connect.Request[pb.SetAccountRequest]) (*connect.Response[pb.SetAccountResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	_, err = bitcoind.SetAccount(ctx, connect.NewRequest(&corepb.SetAccountRequest{
		Address: req.Msg.Address,
		Account: req.Msg.Account,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not set account: %w", err)
	}

	return connect.NewResponse(&pb.SetAccountResponse{}), nil
}

// UnloadWallet implements bitcoindv1connect.BitcoindServiceHandler.
func (s *Server) UnloadWallet(ctx context.Context, req *connect.Request[pb.UnloadWalletRequest]) (*connect.Response[pb.UnloadWalletResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	_, err = bitcoind.UnloadWallet(ctx, connect.NewRequest(&corepb.UnloadWalletRequest{
		WalletName: req.Msg.WalletName,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not unload wallet: %w", err)
	}

	return connect.NewResponse(&pb.UnloadWalletResponse{}), nil
}
