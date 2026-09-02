package thunder

import (
	"context"
	"encoding/json"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// WalletBackend does the wallet work of one mode. A thunder node answers in
// full mode, and a Go wallet over an index answers in light mode.
//
// Every RPC above this seam runs the same code either way.
type WalletBackend interface {
	// Balance is what the wallet holds, and what it can spend now.
	Balance(ctx context.Context) (total, available int64, err error)
	// NewAddress hands out an address to receive on.
	NewAddress(ctx context.Context) (string, error)
	// UTXOs lists the coins the wallet holds, as get_wallet_utxos writes them.
	UTXOs(ctx context.Context) (json.RawMessage, error)
	// Transfer pays one address and returns the txid.
	Transfer(ctx context.Context, address string, amountSats, feeSats int64) (string, error)
	// Withdraw asks for coins to leave the sidechain and returns the txid.
	Withdraw(
		ctx context.Context, address string, amountSats, sideFeeSats, mainFeeSats int64,
	) (string, error)
}

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

var _ WalletBackend = (*nodeBackend)(nil)
