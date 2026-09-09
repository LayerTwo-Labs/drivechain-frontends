package thunder

import (
	"context"
	"encoding/json"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// nodeBackend runs the wallet inside the thunder node.
type nodeBackend struct {
	proxy *sidechain.JSONRPCProxy
}

func newNodeBackend(proxy *sidechain.JSONRPCProxy) *nodeBackend {
	return &nodeBackend{proxy: proxy}
}

func (b *nodeBackend) Balance(ctx context.Context) (int64, int64, error) {
	return b.proxy.GetBalance(ctx)
}

func (b *nodeBackend) NewAddress(ctx context.Context) (string, error) {
	return b.proxy.GetNewAddress(ctx)
}

func (b *nodeBackend) UTXOs(ctx context.Context) (json.RawMessage, error) {
	return b.proxy.GetWalletUtxos(ctx)
}

func (b *nodeBackend) Transfer(
	ctx context.Context, address string, amountSats, feeSats int64,
) (string, error) {
	var txid string
	params := []any{address, amountSats, feeSats}
	if err := b.proxy.Client.Call(ctx, "create_transfer", params, &txid); err != nil {
		return "", err
	}
	return txid, nil
}

func (b *nodeBackend) TransferMany(
	ctx context.Context, destinations map[string]int64, feeSats int64,
) (string, error) {
	var txid string
	params := []any{destinations, feeSats}
	if err := b.proxy.Client.Call(ctx, "create_transfer_many", params, &txid); err != nil {
		return "", err
	}
	return txid, nil
}

func (b *nodeBackend) Withdraw(
	ctx context.Context, address string, amountSats, sideFeeSats, mainFeeSats int64,
) (string, error) {
	var txid string
	params := []any{address, amountSats, sideFeeSats, mainFeeSats}
	if err := b.proxy.Client.Call(ctx, "create_withdrawal", params, &txid); err != nil {
		return "", err
	}
	return txid, nil
}
