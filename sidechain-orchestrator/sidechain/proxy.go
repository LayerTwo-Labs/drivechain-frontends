package sidechain

import (
	"context"
	"encoding/json"
)

// BlockTemplate is a sidechain block that is ready to be blind merged mined.
// The caller bids for CriticalHash itself, then hands Block back to
// ConnectBlock once the bid is included in a mainchain block.
type BlockTemplate struct {
	CriticalHash string          `json:"critical_hash"`
	Block        json.RawMessage `json:"block"`
	FeesSats     int64           `json:"fees_sats"`
}

// Node is every operation the orchestrator asks of a sidechain, whatever the
// chain is built on. A new sidechain satisfies this and nothing more.
type Node interface {
	// GetBalance reports the wallet total and the part of it that is spendable.
	GetBalance(ctx context.Context) (totalSats, availableSats int64, err error)

	// GetNewAddress returns a fresh address on the sidechain.
	GetNewAddress(ctx context.Context) (string, error)

	// GetBlockCount returns the height of the chain tip.
	GetBlockCount(ctx context.Context) (int64, error)

	// Stop asks the node to shut down.
	Stop(ctx context.Context) error

	// CallRaw sends one JSON-RPC call and returns the undecoded result.
	CallRaw(ctx context.Context, method string, params any) (json.RawMessage, error)

	// Args are the command line arguments this chain adds when the
	// orchestrator starts its node.
	Args(ctx context.Context, host Host) ([]string, error)
}

// BMMNode is a sidechain whose blocks the orchestrator's BMM engine produces.
// A chain that mines its own blocks is a Node and not a BMMNode.
type BMMNode interface {
	Node

	// GetBlockTemplate returns the block the node builds next.
	GetBlockTemplate(ctx context.Context) (*BlockTemplate, error)

	// ConnectBlock hands a won block back to the node, with the mainchain block
	// that carried the bid.
	ConnectBlock(ctx context.Context, block json.RawMessage, mainBlockHash string) (bool, error)

	// GetBmmInclusions returns the mainchain blocks that carry a critical hash.
	GetBmmInclusions(ctx context.Context, criticalHash string) ([]string, error)
}

// WithdrawalNode is a sidechain that proposes withdrawal bundles. A chain that
// settles withdrawals elsewhere is a Node and not a WithdrawalNode.
type WithdrawalNode interface {
	Node

	// GetPendingWithdrawalBundle returns the bundle the node proposes, if any.
	GetPendingWithdrawalBundle(ctx context.Context) (json.RawMessage, error)

	// GetLatestFailedWithdrawalBundleHeight returns the height of the last
	// bundle the mainchain refused.
	GetLatestFailedWithdrawalBundleHeight(ctx context.Context) (int64, error)
}

// CoreWalletName is the wallet a Bitcoin Core derived sidechain loads. Core
// creates none on its own, so the orchestrator seeds this one from the chain's
// slot starter and every wallet RPC is scoped to it.
const CoreWalletName = "orchestrator"
