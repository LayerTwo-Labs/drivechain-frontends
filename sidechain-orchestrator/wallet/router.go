package wallet

import (
	"context"
	"errors"
)

// BackendRouter dispatches each call by the wallet's backend type: the
// enforcer wallet is served by the enforcer daemon, electrum wallets by the
// Esplora-backed backend, bitcoinCore wallets by the chain wallet backend.
// Watch-only is an orthogonal capability handled within each backend. Any
// side may be absent — calls for its wallets then fail with a clear error.
type BackendRouter struct {
	svc      *Service
	enforcer Backend
	chain    Backend
	electrum Backend
}

var _ Backend = (*BackendRouter)(nil)

// NewBackendRouter wires the per-type backends. Pass nil for a side
// that isn't configured.
func NewBackendRouter(svc *Service, enforcer, chain, electrum Backend) *BackendRouter {
	return &BackendRouter{svc: svc, enforcer: enforcer, chain: chain, electrum: electrum}
}

// ElectrumConfigured reports whether an electrum (Esplora-backed) backend is
// wired. Networks without an Esplora backend leave it nil; callers use this to
// refuse creating electrum wallets that could never sync.
func (r *BackendRouter) ElectrumConfigured() bool {
	return r.electrum != nil
}

// ElectrumBackend returns the configured electrum backend, if any. PSBT
// operations are electrum-specific and dispatch through it.
func (r *BackendRouter) ElectrumBackend() (*ElectrumBackend, bool) {
	eb, ok := r.electrum.(*ElectrumBackend)
	return eb, ok
}

// Bip47BackendFor returns the wallet's backend as a Bip47Backend when it is
// BIP47-capable (Core and electrum are; the enforcer is not). ok is false for a
// non-capable or unconfigured backend, so the caller skips BIP47 for it.
func (r *BackendRouter) Bip47BackendFor(walletID string) (Bip47Backend, bool) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, false
	}
	b, ok := p.(Bip47Backend)
	return b, ok
}

func (r *BackendRouter) pick(walletID string) (Backend, error) {
	w := r.svc.GetWalletByID(walletID)
	if w == nil {
		return nil, errors.New("wallet " + walletID + " not found")
	}
	if w.WalletType == WalletTypeEnforcer {
		if r.enforcer == nil {
			return nil, errors.New("enforcer wallet client not connected")
		}
		return r.enforcer, nil
	}
	if w.WalletType == WalletTypeElectrum {
		if r.electrum == nil {
			return nil, errors.New("electrum wallet backend not configured")
		}
		return r.electrum, nil
	}
	if r.chain == nil {
		return nil, errors.New("bitcoin Core RPC not configured")
	}
	return r.chain, nil
}

func (r *BackendRouter) Ensure(ctx context.Context, walletID string) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.Ensure(ctx, walletID)
}

func (r *BackendRouter) EnsureAll(ctx context.Context) (int, error) {
	if r.chain == nil {
		return 0, nil
	}
	return r.chain.EnsureAll(ctx)
}

func (r *BackendRouter) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return 0, 0, err
	}
	return p.Balance(ctx, walletID)
}

func (r *BackendRouter) ListUnspent(ctx context.Context, walletID string) ([]UTXO, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.ListUnspent(ctx, walletID)
}

func (r *BackendRouter) ListTransactions(ctx context.Context, walletID string, count int) ([]WalletTransaction, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.ListTransactions(ctx, walletID, count)
}

func (r *BackendRouter) ListTransactionsRange(ctx context.Context, walletID string, count, skip int) ([]WalletTransaction, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.ListTransactionsRange(ctx, walletID, count, skip)
}

func (r *BackendRouter) ListReceivedByAddress(ctx context.Context, walletID string) ([]ReceivedByAddress, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.ListReceivedByAddress(ctx, walletID)
}

func (r *BackendRouter) GetWalletTransaction(ctx context.Context, walletID, txid string) (*WalletTx, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.GetWalletTransaction(ctx, walletID, txid)
}

func (r *BackendRouter) AddressHDPath(ctx context.Context, walletID, address string) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.AddressHDPath(ctx, walletID, address)
}

func (r *BackendRouter) NextReceiveAddress(ctx context.Context, walletID string) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.NextReceiveAddress(ctx, walletID)
}

func (r *BackendRouter) NextChangeAddress(ctx context.Context, walletID string) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.NextChangeAddress(ctx, walletID)
}

func (r *BackendRouter) WatchKeys(ctx context.Context, walletID string, keys []WatchKey) error {
	p, err := r.pick(walletID)
	if err != nil {
		return err
	}
	return p.WatchKeys(ctx, walletID, keys)
}

func (r *BackendRouter) Send(ctx context.Context, walletID string, req SendRequest) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.Send(ctx, walletID, req)
}

func (r *BackendRouter) SignTransaction(ctx context.Context, walletID, rawHex string) (*SignRawTransactionResult, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return nil, err
	}
	return p.SignTransaction(ctx, walletID, rawHex)
}

func (r *BackendRouter) BumpFee(ctx context.Context, walletID, txid string, newFeeRate int64) (string, error) {
	p, err := r.pick(walletID)
	if err != nil {
		return "", err
	}
	return p.BumpFee(ctx, walletID, txid, newFeeRate)
}

// Chain returns a chain source without a wallet context, preferring Core and
// falling back to electrum (Esplora) so electrum-only deployments still work.
// Prefer ChainForWallet when a wallet ID is available.
func (r *BackendRouter) Chain() ChainSource {
	if r.chain != nil {
		return r.chain.Chain()
	}
	if r.electrum != nil {
		return r.electrum.Chain()
	}
	return unavailableChain{reason: "no chain source configured"}
}

// ChainForWallet returns the chain source for a specific wallet's backend, so
// electrum wallets read/broadcast over Esplora even when Core is configured.
func (r *BackendRouter) ChainForWallet(walletID string) ChainSource {
	b, err := r.pick(walletID)
	if err != nil {
		return unavailableChain{reason: err.Error()}
	}
	return b.Chain()
}
