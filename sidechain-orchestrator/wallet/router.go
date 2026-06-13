package wallet

import (
	"context"
	"errors"
	"fmt"
)

// RoutingProvider dispatches each call by the wallet's type: the enforcer
// wallet is served by the enforcer daemon, bitcoinCore/watchOnly wallets by
// the chain wallet provider (Core today, electrum later). Either side may
// be absent — calls for its wallets then fail with a clear error.
type RoutingProvider struct {
	svc      *Service
	enforcer Provider
	chain    Provider
}

var _ Provider = (*RoutingProvider)(nil)

// NewRoutingProvider wires the per-type providers. Pass nil for a side
// that isn't configured.
func NewRoutingProvider(svc *Service, enforcer, chain Provider) *RoutingProvider {
	return &RoutingProvider{svc: svc, enforcer: enforcer, chain: chain}
}

func (r *RoutingProvider) pick(walletID string) (Provider, error) {
	w := r.svc.GetWalletByID(walletID)
	if w == nil {
		return nil, errors.New("wallet " + walletID + " not found")
	}
	if w.WalletType == "enforcer" {
		if r.enforcer == nil {
			return nil, errors.New("enforcer wallet client not connected")
		}
		return r.enforcer, nil
	}
	// Electrum wallets run no local Core or enforcer. Their read data flows
	// through the bitwindow datasource layer, not this provider, so there is
	// no local wallet-RPC backend to dispatch to yet.
	if w.WalletType == "electrum" {
		return nil, fmt.Errorf("electrum wallets are not yet supported via wallet RPC")
	}
	if r.chain == nil {
		return nil, errors.New("bitcoin Core RPC not configured")
	}
	return r.chain, nil
}

func (r *RoutingProvider) Ensure(ctx context.Context, walletID string) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.Ensure(ctx, walletID)
}

func (r *RoutingProvider) EnsureAll(ctx context.Context) (int, error) {
	if r.chain == nil {
		return 0, nil
	}
	return r.chain.EnsureAll(ctx)
}

func (r *RoutingProvider) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return 0, 0, err
	}
	return p.Balance(ctx, walletID)
}

func (r *RoutingProvider) ListUnspent(ctx context.Context, walletID string) ([]UTXO, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.ListUnspent(ctx, walletID)
}

func (r *RoutingProvider) ListTransactions(ctx context.Context, walletID string, count int) ([]WalletTransaction, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.ListTransactions(ctx, walletID, count)
}

func (r *RoutingProvider) ListTransactionsRange(ctx context.Context, walletID string, count, skip int) ([]WalletTransaction, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.ListTransactionsRange(ctx, walletID, count, skip)
}

func (r *RoutingProvider) ListReceivedByAddress(ctx context.Context, walletID string) ([]ReceivedByAddress, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.ListReceivedByAddress(ctx, walletID)
}

func (r *RoutingProvider) GetWalletTransaction(ctx context.Context, walletID, txid string) (*WalletTx, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.GetWalletTransaction(ctx, walletID, txid)
}

func (r *RoutingProvider) AddressHDPath(ctx context.Context, walletID, address string) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.AddressHDPath(ctx, walletID, address)
}

func (r *RoutingProvider) NextReceiveAddress(ctx context.Context, walletID string) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.NextReceiveAddress(ctx, walletID)
}

func (r *RoutingProvider) NextChangeAddress(ctx context.Context, walletID string) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.NextChangeAddress(ctx, walletID)
}

func (r *RoutingProvider) WatchKeys(ctx context.Context, walletID string, keys []WatchKey) error {
	p, err := r.pick(walletID)
	if err != nil {
		return err
	}
	return p.WatchKeys(ctx, walletID, keys)
}

func (r *RoutingProvider) Send(ctx context.Context, walletID string, req SendRequest) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.Send(ctx, walletID, req)
}

func (r *RoutingProvider) SignTransaction(ctx context.Context, walletID, rawHex string) (*SignRawTransactionResult, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.SignTransaction(ctx, walletID, rawHex)
}

func (r *RoutingProvider) BumpFee(ctx context.Context, walletID, txid string, newFeeRate int64) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.BumpFee(ctx, walletID, txid, newFeeRate)
}

// Chain returns the chain wallet provider's chain source — chain lookups
// are wallet-agnostic, so they don't dispatch per wallet.
func (r *RoutingProvider) Chain() ChainSource {
	if r.chain == nil {
		return unavailableChain{reason: "bitcoin Core RPC not configured"}
	}
	return r.chain.Chain()
}
