package api

import (
	"context"
	"encoding/json"
	"fmt"
	"math"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

// coreBlock is a block as Bitcoin Core writes it. A Core derived sidechain
// speaks Core's own method names, so it shares nothing with the CUSF shape.
type coreBlock struct {
	Hash              string   `json:"hash"`
	Height            uint32   `json:"height"`
	MerkleRoot        string   `json:"merkleroot"`
	PreviousBlockHash string   `json:"previousblockhash"`
	Time              int64    `json:"time"`
	Size              int64    `json:"size"`
	Tx                []string `json:"tx"`
}

// coreOverview reads the newest blocks from a Core derived node.
func coreOverview(ctx context.Context, src source) (*pb.GetOverviewResponse, error) {
	count, err := src.node.GetBlockCount(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	out := &pb.GetOverviewResponse{Source: "node", Mempool: &pb.Mempool{}}
	if count < 0 {
		return out, nil
	}
	out.TipHeight = uint32(count)

	for walked := 0; walked < activityScanDepth; walked++ {
		if len(out.Blocks) >= blockListSize && len(out.Recent) >= activityListSize {
			break
		}
		height := count - int64(walked)
		if height < 0 {
			break
		}
		block, activity, err := coreBlockAtHeight(ctx, src, uint32(height))
		if err != nil {
			return nil, err
		}
		if len(out.Blocks) < blockListSize {
			out.Blocks = append(out.Blocks, block)
		}
		for _, row := range activity {
			if len(out.Recent) >= activityListSize {
				break
			}
			out.Recent = append(out.Recent, row)
		}
	}
	return out, nil
}

// coreBlockAtHeight reads one block from a Core derived node.
func coreBlockAtHeight(ctx context.Context, src source, height uint32) (*pb.Block, []*pb.Activity, error) {
	raw, err := src.node.CallRaw(ctx, "getblockhash", []uint32{height})
	if err != nil {
		return nil, nil, connect.NewError(connect.CodeUnavailable, err)
	}
	var hash string
	if err := json.Unmarshal(raw, &hash); err != nil {
		return nil, nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("read the hash at height %d: %w", height, err))
	}
	return coreBlockByHash(ctx, src, hash)
}

// coreBlockByHash reads one block from a Core derived node by its hash.
func coreBlockByHash(ctx context.Context, src source, hash string) (*pb.Block, []*pb.Activity, error) {
	key := src.cacheKey(hash)
	if block, activity, _, ok := src.cache.get(key); ok {
		return block, activity, nil
	}
	block, activity, err := readCoreBlock(ctx, src, hash)
	if err != nil {
		return nil, nil, err
	}
	out, rows := src.cache.put(key, block, activity, true)
	return out, rows, nil
}

// readCoreBlock asks the node for one block and what it carried.
func readCoreBlock(ctx context.Context, src source, hash string) (*pb.Block, []*pb.Activity, error) {
	raw, err := src.node.CallRaw(ctx, "getblock", []any{hash, 1})
	if err != nil {
		return nil, nil, connect.NewError(connect.CodeUnavailable, err)
	}
	var block coreBlock
	if err := json.Unmarshal(raw, &block); err != nil {
		return nil, nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("read block %s: %w", hash, err))
	}

	out := &pb.Block{
		Height:     block.Height,
		Hash:       block.Hash,
		PrevHash:   block.PreviousBlockHash,
		MerkleRoot: block.MerkleRoot,
		BlockTime:  block.Time,
		TxCount:    uint32(len(block.Tx)),
		SizeBytes:  block.Size,
	}

	activity := make([]*pb.Activity, 0, len(block.Tx))
	for _, txid := range block.Tx {
		activity = append(activity, &pb.Activity{
			Kind:        pb.Kind_KIND_TRANSFER,
			Id:          txid,
			Confirmed:   true,
			BlockHeight: block.Height,
			BlockTime:   block.Time,
		})
	}
	return out, activity, nil
}

// nodeTxEnvelope is what get_transaction returns on thunder and photon: the
// transaction, and the block that carries it. Every other CUSF chain returns
// the transaction alone.
type nodeTxEnvelope struct {
	BlockHash *string          `json:"block_hash"`
	Tx        *json.RawMessage `json:"tx"`
}

// nodeTx is a transaction as a sidechain node writes it. A node holds no
// previous outputs, so an input names only the coin it spends.
type nodeTx struct {
	Inputs []struct {
		Regular *struct {
			Txid string `json:"txid"`
			Vout uint32 `json:"vout"`
		} `json:"Regular"`
		Deposit *struct {
			Txid string `json:"txid"`
			Vout uint32 `json:"vout"`
		} `json:"Deposit"`
		Coinbase *struct {
			MerkleRoot string `json:"merkle_root"`
			Vout       uint32 `json:"vout"`
		} `json:"Coinbase"`
	} `json:"inputs"`
	Outputs []struct {
		Address string          `json:"address"`
		Content json.RawMessage `json:"content"`
	} `json:"outputs"`
}

// nodeTxInfo is what get_transaction_info returns. The chains that send a
// bare transaction carry the confirmation and the fee here.
type nodeTxInfo struct {
	Confirmations *uint32 `json:"confirmations"`
	FeeSats       int64   `json:"fee_sats"`
}

// nodeTransaction reads one transaction from a node. A node keeps no
// transaction index, so it answers only for what it still holds.
func nodeTransaction(ctx context.Context, src source, txid string) (*pb.Transaction, error) {
	// The node reads its params as a list. A bare string answers
	// "Invalid params", whatever the schema declares.
	raw, err := src.node.CallRaw(ctx, "get_transaction", []string{txid})
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	if len(raw) == 0 || string(raw) == "null" {
		// A node answers only for what its wallet or its mempool holds. A
		// mined transaction comes back out of the block that carries it.
		return minedTransaction(ctx, src, txid)
	}

	// Unwrap the envelope when the node sends one, so both layouts read.
	body := raw
	var envelope nodeTxEnvelope
	if err := json.Unmarshal(raw, &envelope); err == nil && envelope.Tx != nil {
		body = *envelope.Tx
	}

	var tx nodeTx
	if err := json.Unmarshal(body, &tx); err != nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("read transaction %s: %w", txid, err))
	}

	out := &pb.Transaction{Txid: txid, Kind: pb.Kind_KIND_TRANSFER}
	if envelope.BlockHash != nil {
		out.Confirmed = true
		out.BlockHash = *envelope.BlockHash
		if height, err := nodeHeightOfHash(ctx, src, *envelope.BlockHash); err == nil {
			out.BlockHeight = height
		}
	} else if info, ok := nodeTransactionInfo(ctx, src, txid); ok {
		out.Confirmed = info.Confirmations != nil && *info.Confirmations > 0
		out.FeeSats = info.FeeSats
	}
	for _, in := range tx.Inputs {
		switch {
		case in.Deposit != nil:
			out.Inputs = append(out.Inputs, &pb.Coin{
				Txid: in.Deposit.Txid, Vout: in.Deposit.Vout, OutpointKind: "deposit",
			})
			out.Kind = pb.Kind_KIND_DEPOSIT
		case in.Regular != nil:
			out.Inputs = append(out.Inputs, &pb.Coin{
				Txid: in.Regular.Txid, Vout: in.Regular.Vout, OutpointKind: "regular",
			})
		case in.Coinbase != nil:
			out.Inputs = append(out.Inputs, &pb.Coin{
				Txid: in.Coinbase.MerkleRoot, Vout: in.Coinbase.Vout, OutpointKind: "coinbase",
			})
		}
	}
	for _, o := range tx.Outputs {
		coin := &pb.Coin{Address: o.Address, ContentType: "value"}
		if w, ok := readWithdrawal(o.Content); ok {
			coin.ContentType = "withdrawal"
			coin.ValueSats = w.GetValueSats()
			coin.MainAddress = w.GetMainAddress()
			coin.MainFeeSats = w.GetMainFeeSats()
			out.Kind = pb.Kind_KIND_WITHDRAWAL
		} else {
			coin.ValueSats = contentValue(o.Content)
		}
		out.Outputs = append(out.Outputs, coin)
	}
	return out, nil
}

// nodeTransactionInfo reads the confirmation and the fee a bare transaction
// does not carry. A node without the method answers false.
func nodeTransactionInfo(ctx context.Context, src source, txid string) (nodeTxInfo, bool) {
	raw, err := src.node.CallRaw(ctx, "get_transaction_info", []string{txid})
	if err != nil || len(raw) == 0 || string(raw) == "null" {
		return nodeTxInfo{}, false
	}
	var info nodeTxInfo
	if err := json.Unmarshal(raw, &info); err != nil {
		return nodeTxInfo{}, false
	}
	return info, true
}

// coreTransaction reads one transaction from a Core derived node.
func coreTransaction(ctx context.Context, src source, txid string) (*pb.Transaction, error) {
	raw, err := src.node.CallRaw(ctx, "getrawtransaction", []any{txid, true})
	if err != nil {
		// Core reads a mined transaction only from the block that carries
		// it, unless the node runs -txindex. So find that block first.
		hash, blockErr := coreBlockOf(ctx, src, txid)
		if blockErr != nil {
			return nil, blockErr
		}
		raw, err = src.node.CallRaw(ctx, "getrawtransaction", []any{txid, true, hash})
		if err != nil {
			return nil, connect.NewError(connect.CodeNotFound, err)
		}
	}
	var tx struct {
		Txid          string `json:"txid"`
		BlockHash     string `json:"blockhash"`
		Time          int64  `json:"time"`
		Confirmations int64  `json:"confirmations"`
		Size          int64  `json:"size"`
		Vin           []struct {
			Txid string `json:"txid"`
			Vout uint32 `json:"vout"`
		} `json:"vin"`
		Vout []struct {
			Value        float64 `json:"value"`
			ScriptPubKey struct {
				Address string `json:"address"`
			} `json:"scriptPubKey"`
		} `json:"vout"`
	}
	if err := json.Unmarshal(raw, &tx); err != nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("read transaction %s: %w", txid, err))
	}

	out := &pb.Transaction{
		Txid:      txid,
		Kind:      pb.Kind_KIND_TRANSFER,
		SizeBytes: tx.Size,
		Confirmed: tx.Confirmations > 0,
		BlockHash: tx.BlockHash,
		BlockTime: tx.Time,
	}
	for _, in := range tx.Vin {
		out.Inputs = append(out.Inputs, &pb.Coin{Txid: in.Txid, Vout: in.Vout, OutpointKind: "regular"})
	}
	if tx.BlockHash != "" {
		if block, _, err := coreBlockByHash(ctx, src, tx.BlockHash); err == nil {
			out.BlockHeight = block.GetHeight()
		}
	}
	for _, o := range tx.Vout {
		out.Outputs = append(out.Outputs, &pb.Coin{
			Address:     o.ScriptPubKey.Address,
			ValueSats:   int64(math.Round(o.Value * 1e8)),
			ContentType: "value",
		})
	}
	return out, nil
}

// searchBlockDepth bounds how far back a transaction search walks. An explorer
// reads the recent chain, and a deeper history needs an index.
const searchBlockDepth = 200

// minedTransaction finds one transaction in the blocks a node holds. The node
// keeps no transaction index, so the search walks back from the tip and reads
// each block's own index.
func minedTransaction(ctx context.Context, src source, txid string) (*pb.Transaction, error) {
	count, err := src.node.GetBlockCount(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	if count <= 0 {
		return nil, notFoundTransaction(src, txid)
	}
	raw, err := src.node.CallRaw(ctx, "get_best_sidechain_block_hash", nil)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	var hash string
	if err := json.Unmarshal(raw, &hash); err != nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("read the tip hash: %w", err))
	}

	for height := count - 1; height >= 0 && hash != ""; height-- {
		if count-1-height >= searchBlockDepth {
			break
		}
		block, activity, err := nodeBlock(ctx, src, hash, uint32(height))
		if err != nil {
			return nil, err
		}
		for i, row := range activity {
			if row.GetId() != txid {
				continue
			}
			return blockTransaction(ctx, src, block, uint32(i), row)
		}
		hash = block.GetPrevHash()
	}
	return nil, notFoundTransaction(src, txid)
}

// notFoundTransaction says a node holds no such transaction, and why the
// search is bounded.
func notFoundTransaction(src source, txid string) error {
	return connect.NewError(connect.CodeNotFound, fmt.Errorf(
		"%s holds no transaction %s in its newest %d blocks. A node keeps no transaction index",
		src.name, txid, searchBlockDepth))
}

// blockTransaction reads one transaction out of the block that carries it.
func blockTransaction(
	ctx context.Context, src source, block *pb.Block, index uint32, row *pb.Activity,
) (*pb.Transaction, error) {
	out := &pb.Transaction{
		Txid:        row.GetId(),
		Kind:        row.GetKind(),
		SizeBytes:   row.GetSizeBytes(),
		Confirmed:   true,
		BlockHeight: block.GetHeight(),
		BlockHash:   block.GetHash(),
		BlockTime:   block.GetBlockTime(),
	}

	header, err := nodeHeader(ctx, src, block.GetHash())
	if err != nil {
		return out, nil
	}
	body := header.transactions()
	if int(index) >= len(body) {
		return out, nil
	}
	for _, coin := range body[index].Outputs {
		out.Outputs = append(out.Outputs, coinFromContent(coin.Address, coin.Content, out))
	}
	return out, nil
}

// coinFromContent reads one output payload. A withdrawal names where the money
// goes on the mainchain, and it makes the transaction a withdrawal.
func coinFromContent(address string, content json.RawMessage, tx *pb.Transaction) *pb.Coin {
	coin := &pb.Coin{Address: address, ContentType: "value"}
	if w, ok := readWithdrawal(content); ok {
		coin.ContentType = "withdrawal"
		coin.ValueSats = w.GetValueSats()
		coin.MainAddress = w.GetMainAddress()
		coin.MainFeeSats = w.GetMainFeeSats()
		tx.Kind = pb.Kind_KIND_WITHDRAWAL
		return coin
	}
	coin.ValueSats = contentValue(content)
	return coin
}

// coreBlockOf finds the block that carries one transaction. A Core node
// without -txindex names a transaction only inside its block, so the search
// walks back from the tip.
func coreBlockOf(ctx context.Context, src source, txid string) (string, error) {
	count, err := src.node.GetBlockCount(ctx)
	if err != nil {
		return "", connect.NewError(connect.CodeUnavailable, err)
	}
	for height := count; height >= 0 && count-height < searchBlockDepth; height-- {
		block, activity, err := coreBlockAtHeight(ctx, src, uint32(height))
		if err != nil {
			return "", err
		}
		for _, row := range activity {
			if row.GetId() == txid {
				return block.GetHash(), nil
			}
		}
	}
	return "", notFoundTransaction(src, txid)
}
