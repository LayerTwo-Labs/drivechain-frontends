// Package solana is the client of the Solana sidechain node. The node runs
// outside the orchestrator, so this client only drives its BMM.
package solana

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ sidechain.BMMNode = (*Client)(nil)

// notReadyCode is the answer with which the node says "not on this tip yet,
// ask again".
const notReadyCode = -32001

// Client speaks the JSON-RPC of the Solana sidechain node.
type Client struct {
	rpc *rpc.Client
}

// NewClient returns a client for the node at host:port.
func NewClient(host string, port int) *Client {
	return &Client{rpc: rpc.New(host, port)}
}

func (c *Client) call(ctx context.Context, method string, params, out any) error {
	err := c.rpc.Call(ctx, method, params, out)
	if code, ok := rpc.ErrorCode(err); ok && code == notReadyCode {
		return fmt.Errorf("%w: %w", sidechain.ErrNotReady, err)
	}
	return err
}

// GetBalance reports zero: the node keeps no wallet the orchestrator reads.
func (c *Client) GetBalance(context.Context) (int64, int64, error) {
	return 0, 0, nil
}

// GetNewAddress fails: the node keeps no wallet the orchestrator reads.
func (c *Client) GetNewAddress(context.Context) (string, error) {
	return "", errors.New("the Solana sidechain keeps no wallet in the orchestrator")
}

// GetBlockCount returns the height of the chain tip.
func (c *Client) GetBlockCount(ctx context.Context) (int64, error) {
	var count uint64
	if err := c.call(ctx, "getblockcount", nil, &count); err != nil {
		return 0, err
	}
	return int64(count), nil
}

// Stop does nothing: the node runs outside the orchestrator.
func (c *Client) Stop(context.Context) error {
	return nil
}

// CallRaw sends one JSON-RPC call and returns the undecoded result.
func (c *Client) CallRaw(ctx context.Context, method string, params any) (json.RawMessage, error) {
	return c.rpc.CallRaw(ctx, method, params)
}

// Args returns no arguments: the orchestrator never starts the node.
func (c *Client) Args(context.Context, sidechain.Host) ([]string, error) {
	return nil, nil
}

// GetBlockTemplate returns the block the node builds next. Its critical hash
// is in the byte order the M8 carries.
func (c *Client) GetBlockTemplate(ctx context.Context) (*sidechain.BlockTemplate, error) {
	var template sidechain.BlockTemplate
	if err := c.call(ctx, "get_block_template", nil, &template); err != nil {
		return nil, err
	}
	return &template, nil
}

// ConnectBlock hands a won block back to the node, with the mainchain block
// that carried the bid.
func (c *Client) ConnectBlock(ctx context.Context, block json.RawMessage, mainBlockHash string) (bool, error) {
	var connected bool
	if err := c.call(ctx, "connect_block", []any{block, mainBlockHash}, &connected); err != nil {
		return false, err
	}
	return connected, nil
}

// GetBmmInclusions returns the mainchain blocks that carry a critical hash.
func (c *Client) GetBmmInclusions(ctx context.Context, criticalHash string) ([]string, error) {
	var inclusions []string
	if err := c.call(ctx, "get_bmm_inclusions", []any{criticalHash}, &inclusions); err != nil {
		return nil, err
	}
	return inclusions, nil
}

// ChainHolds reports false: the node serves no walk back from its tip, so a
// refused block reads as refused.
func (c *Client) ChainHolds(context.Context, string, int) (bool, error) {
	return false, nil
}

// TemplateOnTip reports whether a block from GetBlockTemplate still builds on
// the chain tip.
func (c *Client) TemplateOnTip(ctx context.Context, block json.RawMessage) (bool, error) {
	var valid bool
	if err := c.call(ctx, "template_valid", []any{block}, &valid); err != nil {
		return false, err
	}
	return valid, nil
}
