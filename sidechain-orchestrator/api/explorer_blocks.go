package api

import (
	"context"

	"connectrpc.com/connect/v2"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

// blockPageLimit bounds one page of headers, so a reader who scrolls far
// costs a bounded number of reads.
const blockPageLimit = 20

// ListBlocks reads a page of block headers, newest first.
func (h *ExplorerHandler) ListBlocks(
	ctx context.Context, req *pb.ListBlocksRequest,
) (*pb.ListBlocksResponse, error) {
	src, err := h.sourceOf(req.GetChain())
	if err != nil {
		return nil, err
	}
	limit := int(req.GetLimit())
	if limit <= 0 || limit > blockPageLimit {
		limit = blockPageLimit
	}

	out := &pb.ListBlocksResponse{}
	if src.index != nil {
		rows, err := src.index.BlocksBefore(ctx, req.GetBeforeHeight())
		if err != nil {
			return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
		}
		out.Blocks = blockList(rows)
		if len(out.Blocks) > limit {
			out.Blocks = out.Blocks[:limit]
		}
		fillIndexBlockDeposits(ctx, src, out.Blocks)
	} else {
		out.Blocks, err = nodeBlocksBefore(ctx, src, req.GetBeforeHeight(), limit)
		if err != nil {
			return nil, err
		}
	}
	if len(out.Blocks) > limit {
		out.Blocks = out.Blocks[:limit]
	}
	h.resolveMainchain(ctx, out.GetBlocks()...)
	return out, nil
}

// nodeBlocksBefore walks the chain down from one height. A node reads a block
// by hash only, so the walk follows prev_side_hash.
func nodeBlocksBefore(
	ctx context.Context, src source, before uint32, limit int,
) ([]*pb.Block, error) {
	count, err := src.node.GetBlockCount(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}
	// Core reports the tip height, a sidechain node the block count.
	tip := count - 1
	if src.core {
		tip = count
	}
	if tip < 0 {
		return nil, nil
	}

	height := uint32(tip)
	if before > 0 && before < height {
		height = before
	}
	if src.core {
		var out []*pb.Block
		for at := int64(height); at >= 0 && len(out) < limit; at-- {
			block, _, err := coreBlockAtHeight(ctx, src, uint32(at))
			if err != nil {
				return nil, err
			}
			out = append(out, block)
		}
		return out, nil
	}

	hash, err := nodeHashAtHeight(ctx, src, height)
	if err != nil {
		return nil, err
	}
	var out []*pb.Block
	for at := int64(height); at >= 0 && hash != "" && len(out) < limit; at-- {
		block, _, err := nodeBlock(ctx, src, hash, uint32(at))
		if err != nil {
			return nil, err
		}
		out = append(out, block)
		hash = block.GetPrevHash()
	}
	return out, nil
}
