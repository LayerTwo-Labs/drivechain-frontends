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

// SidechainRPCProxy defines the common operations shared by all sidechain binaries.
// Each sidechain handler embeds a proxy implementation and adds sidechain-specific methods.
type SidechainRPCProxy interface {
	// Wallet
	GetBalance(ctx context.Context) (totalSats, availableSats int64, err error)
	GetNewAddress(ctx context.Context) (string, error)
	GetWalletUtxos(ctx context.Context) (json.RawMessage, error)

	// Chain
	GetBlockCount(ctx context.Context) (int64, error)
	ListUtxos(ctx context.Context) (json.RawMessage, error)

	// Transfers
	Transfer(ctx context.Context, address string, amountSats, feeSats int64) (txid string, err error)
	Withdraw(ctx context.Context, address string, amountSats, sideFeeSats, mainFeeSats int64) (txid string, err error)

	// Mining
	Mine(ctx context.Context, feeSats int64) (json.RawMessage, error)
	GetBlockTemplate(ctx context.Context) (*BlockTemplate, error)
	ConnectBlock(ctx context.Context, block json.RawMessage, mainBlockHash string) (bool, error)
	GetBmmInclusions(ctx context.Context, criticalHash string) ([]string, error)

	// Withdrawal bundles
	GetPendingWithdrawalBundle(ctx context.Context) (json.RawMessage, error)
	GetLatestFailedWithdrawalBundleHeight(ctx context.Context) (int64, error)

	// Lifecycle
	Stop(ctx context.Context) error

	// Raw passthrough for debug console
	CallRaw(ctx context.Context, method string, params any) (json.RawMessage, error)
}
