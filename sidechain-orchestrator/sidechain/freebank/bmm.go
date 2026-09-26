package freebank

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"slices"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/corenode"
)

var _ sidechain.BMMNode = (*Client)(nil)

// tooOld names the FreeBank release that first answers the BMM engine. Older
// nodes bid only through their own refreshbmm, so the engine gets this instead
// of a bare "method not found".
const tooOld = "this FreeBank node is too old for bidding from BitWindow (it needs v0.2.16 or later)"

// call sends one BMM method, and turns an older node's "method not found" into
// a sentence a user can act on.
func call[T any](ctx context.Context, c *Client, method string, params any) (T, error) {
	result, err := corenode.Decode[T](ctx, c.Client, method, params)
	if corenode.IsMethodNotFound(err) {
		var zero T
		return zero, fmt.Errorf("%s: %w", tooOld, err)
	}
	return result, err
}

// GetBlockTemplate returns the block the node builds next. Its critical hash is
// the block's merkle root, in internal byte order.
func (c *Client) GetBlockTemplate(ctx context.Context) (*sidechain.BlockTemplate, error) {
	template, err := call[sidechain.BlockTemplate](ctx, c, "get_block_template", nil)
	if err != nil {
		return nil, err
	}
	return &template, nil
}

// ConnectBlock hands a won block back to the node, with the mainchain block that
// carried the bid.
func (c *Client) ConnectBlock(ctx context.Context, block json.RawMessage, mainBlockHash string) (bool, error) {
	return call[bool](ctx, c, "connect_block", []any{block, mainBlockHash})
}

// GetBmmInclusions returns the mainchain blocks that carry a critical hash.
func (c *Client) GetBmmInclusions(ctx context.Context, criticalHash string) ([]string, error) {
	return call[[]string](ctx, c, "get_bmm_inclusions", []any{criticalHash})
}

// ChainHolds reports whether one of the depth blocks nearest the tip carries a
// critical hash. FreeBank bids with a block's merkle root, not its hash: the
// hash is fixed only once the winning mainchain block is written into the
// header. So the walk compares merkle roots.
func (c *Client) ChainHolds(ctx context.Context, criticalHash string, depth int) (bool, error) {
	raw, err := hex.DecodeString(criticalHash)
	if err != nil {
		return false, fmt.Errorf("decode critical hash: %w", err)
	}
	// critical_hash is in internal byte order, and Core prints a merkle root in display order.
	slices.Reverse(raw)
	want := hex.EncodeToString(raw)

	next, err := corenode.Decode[string](ctx, c.Client, "getbestblockhash", nil)
	if err != nil {
		return false, err
	}
	for range depth {
		header, err := corenode.Decode[struct {
			MerkleRoot        string `json:"merkleroot"`
			PreviousBlockHash string `json:"previousblockhash"`
		}](ctx, c.Client, "getblockheader", []any{next})
		if err != nil {
			return false, err
		}
		if header.MerkleRoot == want {
			return true, nil
		}
		if header.PreviousBlockHash == "" {
			return false, nil
		}
		next = header.PreviousBlockHash
	}
	return false, nil
}

// TemplateOnTip reports whether a block from GetBlockTemplate still builds on
// the chain tip.
func (c *Client) TemplateOnTip(ctx context.Context, block json.RawMessage) (bool, error) {
	var template struct {
		Hex string `json:"hex"`
	}
	if err := json.Unmarshal(block, &template); err != nil {
		return false, fmt.Errorf("decode block: %w", err)
	}
	raw, err := hex.DecodeString(template.Hex)
	if err != nil {
		return false, fmt.Errorf("decode block hex: %w", err)
	}
	// The header opens with a 4-byte version, then the parent hash.
	if len(raw) < 36 {
		return false, fmt.Errorf("block of %d bytes has no parent hash", len(raw))
	}
	parent := slices.Clone(raw[4:36])
	// The header holds internal byte order, and Core names a block in display order.
	slices.Reverse(parent)

	tip, err := corenode.Decode[string](ctx, c.Client, "getbestblockhash", nil)
	if err != nil {
		return false, err
	}
	return hex.EncodeToString(parent) == tip, nil
}
