package sidechain

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
)

// JSONRPCProxy implements SidechainRPCProxy by forwarding calls to a sidechain
// binary's JSON-RPC endpoint. All sidechains share the same JSON-RPC protocol,
// so this single implementation works for thunder, bitassets, bitnames, etc.
type JSONRPCProxy struct {
	Client *rpc.Client
}

var _ SidechainRPCProxy = (*JSONRPCProxy)(nil)

// NewJSONRPCProxy creates a proxy targeting the given host:port.
func NewJSONRPCProxy(host string, port int) *JSONRPCProxy {
	return &JSONRPCProxy{
		Client: rpc.New(host, port),
	}
}

func (p *JSONRPCProxy) GetBalance(ctx context.Context) (int64, int64, error) {
	var result struct {
		TotalSats     int64 `json:"total_sats"`
		AvailableSats int64 `json:"available_sats"`
	}
	if err := p.Client.Call(ctx, "balance", nil, &result); err != nil {
		return 0, 0, err
	}
	return result.TotalSats, result.AvailableSats, nil
}

func (p *JSONRPCProxy) GetBlockCount(ctx context.Context) (int64, error) {
	var count int64
	if err := p.Client.Call(ctx, "getblockcount", nil, &count); err != nil {
		return 0, err
	}
	return count, nil
}

func (p *JSONRPCProxy) GetNewAddress(ctx context.Context) (string, error) {
	var address string
	if err := p.Client.Call(ctx, "get_new_address", nil, &address); err != nil {
		return "", err
	}
	return address, nil
}

func (p *JSONRPCProxy) Transfer(ctx context.Context, address string, amountSats, feeSats int64) (string, error) {
	var txid string
	params := []any{address, amountSats, feeSats}
	if err := p.Client.Call(ctx, "transfer", params, &txid); err != nil {
		return "", err
	}
	return txid, nil
}

func (p *JSONRPCProxy) Withdraw(ctx context.Context, address string, amountSats, sideFeeSats, mainFeeSats int64) (string, error) {
	var txid string
	params := []any{address, amountSats, sideFeeSats, mainFeeSats}
	if err := p.Client.Call(ctx, "withdraw", params, &txid); err != nil {
		return "", err
	}
	return txid, nil
}

func (p *JSONRPCProxy) Mine(ctx context.Context, feeSats int64) (json.RawMessage, error) {
	return p.Client.CallRaw(ctx, "mine", []any{feeSats})
}

func (p *JSONRPCProxy) GetPendingWithdrawalBundle(ctx context.Context) (json.RawMessage, error) {
	return p.Client.CallRaw(ctx, "pending_withdrawal_bundle", nil)
}

func (p *JSONRPCProxy) GetLatestFailedWithdrawalBundleHeight(ctx context.Context) (int64, error) {
	raw, err := p.Client.CallRaw(ctx, "latest_failed_withdrawal_bundle_height", nil)
	if err != nil {
		return 0, err
	}

	var height int64
	if raw != nil && string(raw) != "null" {
		if err := json.Unmarshal(raw, &height); err != nil {
			return 0, fmt.Errorf("unmarshal height: %w", err)
		}
	}
	return height, nil
}

func (p *JSONRPCProxy) GetWalletUtxos(ctx context.Context) (json.RawMessage, error) {
	return p.Client.CallRaw(ctx, "get_wallet_utxos", nil)
}

func (p *JSONRPCProxy) ListUtxos(ctx context.Context) (json.RawMessage, error) {
	return p.Client.CallRaw(ctx, "list_utxos", nil)
}

func (p *JSONRPCProxy) Stop(ctx context.Context) error {
	return p.Client.Call(ctx, "stop", nil, nil)
}

func (p *JSONRPCProxy) CallRaw(ctx context.Context, method string, params any) (json.RawMessage, error) {
	return p.Client.CallRaw(ctx, method, params)
}
