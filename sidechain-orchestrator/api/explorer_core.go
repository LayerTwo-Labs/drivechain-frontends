package api

import (
	"context"
	"encoding/json"
	"fmt"

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

	for height := count; height >= 0 && len(out.Blocks) < blockListSize; height-- {
		block, activity, err := coreBlockAtHeight(ctx, src, uint32(height))
		if err != nil {
			return nil, err
		}
		out.Blocks = append(out.Blocks, block)
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
