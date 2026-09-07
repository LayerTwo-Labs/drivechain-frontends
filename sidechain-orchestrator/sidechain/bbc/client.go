// Package bbc is the RPC client for the Bbc sidechain, a Bitcoin Core fork
// carrying the covenant opcodes. It reads the shared Core client for everything
// Core answers, and adds the blind-merge-mining methods the BMM engine drives.
package bbc

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/corenode"
)

var _ sidechain.BMMNode = (*Client)(nil)

// Client talks to a Bbc node.
type Client struct {
	*corenode.Client
}

// NewClient creates a client pointed at host:port. cookiePath is the node's
// .cookie.
func NewClient(host string, port int, cookiePath string) *Client {
	return &Client{Client: corenode.New("bbc", host, port, cookiePath, corenode.Options{})}
}

// SidechainInfo is the node's view of its link to the mainchain.
type SidechainInfo struct {
	Synced       bool   `json:"synced"`
	MainchainTip string `json:"mainchaintip"`
	LastError    string `json:"lasterror"`
}

// GetSidechainInfo reports whether the node has caught up with the mainchain.
func (c *Client) GetSidechainInfo(ctx context.Context) (*SidechainInfo, error) {
	info, err := corenode.Decode[SidechainInfo](ctx, c.Client, "getsidechaininfo", nil)
	if err != nil {
		return nil, err
	}
	return &info, nil
}

// GetMainchainTip returns the mainchain block hash the node is following.
func (c *Client) GetMainchainTip(ctx context.Context) (string, error) {
	tip, err := corenode.Decode[struct {
		BlockHash string `json:"blockhash"`
	}](ctx, c.Client, "getmainchaintip", nil)
	if err != nil {
		return "", err
	}
	return tip.BlockHash, nil
}

// ---------------------------------------------------------------------------
// Mining
// ---------------------------------------------------------------------------

// GetBlockTemplate returns the block the node builds next.
func (c *Client) GetBlockTemplate(ctx context.Context) (*sidechain.BlockTemplate, error) {
	template, err := corenode.Decode[sidechain.BlockTemplate](ctx, c.Client, "get_block_template", nil)
	if err != nil {
		return nil, err
	}
	return &template, nil
}

// ConnectBlock hands a won block back to the node.
func (c *Client) ConnectBlock(ctx context.Context, block json.RawMessage, mainBlockHash string) (bool, error) {
	return corenode.Decode[bool](ctx, c.Client, "connect_block", []any{block, mainBlockHash})
}

// GetBmmInclusions returns the mainchain blocks that carry a critical hash.
func (c *Client) GetBmmInclusions(ctx context.Context, criticalHash string) ([]string, error) {
	return corenode.Decode[[]string](ctx, c.Client, "get_bmm_inclusions", []any{criticalHash})
}

// GetBmmCommitment returns the sidechain block hash committed to by a mainchain
// block, empty when that block carries no commitment.
func (c *Client) GetBmmCommitment(ctx context.Context, mainchainBlockHash string) (string, error) {
	raw, err := c.Call(ctx, "getbmmcommitment", []any{mainchainBlockHash})
	if err != nil {
		return "", err
	}
	if string(raw) == "null" {
		return "", nil
	}
	var commitment string
	if err := json.Unmarshal(raw, &commitment); err != nil {
		return "", fmt.Errorf("decode getbmmcommitment result: %w", err)
	}
	return commitment, nil
}
