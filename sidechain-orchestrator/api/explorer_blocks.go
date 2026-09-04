package api

import (
	"context"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

// blockPageLimit bounds one page of headers, so a reader who scrolls far
// costs a bounded number of reads.
const blockPageLimit = 20

// ListBlocks reads a page of block headers, newest first.
func (h *ExplorerHandler) ListBlocks(
	ctx context.Context, req *connect.Request[pb.ListBlocksRequest],
) (*connect.Response[pb.ListBlocksResponse], error) {
	src, err := h.sourceFor(req.Msg.GetChain())
	if err != nil {
		return nil, err
	}
	limit := int(req.Msg.GetLimit())
	if limit <= 0 || limit > blockPageLimit {
		limit = blockPageLimit
	}

	out := &pb.ListBlocksResponse{}
	if src.index != nil {
		rows, err := src.index.BlocksBefore(ctx, req.Msg.GetBeforeHeight())
		if err != nil {
			return nil, connect.NewError(connect.CodeUnavailable, err)
		}
		out.Blocks = blockList(rows)
	} else {
		out.Blocks, err = nodeBlocksBefore(ctx, src, req.Msg.GetBeforeHeight(), limit)
		if err != nil {
			return nil, err
		}
	}
	if len(out.Blocks) > limit {
		out.Blocks = out.Blocks[:limit]
	}
	h.resolveMainchainHeights(ctx, out.GetBlocks())
	return connect.NewResponse(out), nil
}

// nodeBlocksBefore walks the chain down from one height. A node reads a block
// by hash only, so the walk follows prev_side_hash.
func nodeBlocksBefore(
	ctx context.Context, src source, before uint32, limit int,
) ([]*pb.Block, error) {
	count, err := src.node.GetBlockCount(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	if count <= 0 {
		return nil, nil
	}

	height := uint32(count - 1)
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
