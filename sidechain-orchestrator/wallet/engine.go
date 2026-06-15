package wallet

import (
	"context"
	"errors"
	"fmt"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
)

// WalletEngine is the mode-agnostic façade consumers hold: it resolves
// wallet IDs and hands out the active Backend. All chain/wallet data flows
// through the Backend so backends are swappable at the wiring site.
type WalletEngine struct {
	svc     *Service
	backend Backend
	log     zerolog.Logger
	network *chaincfg.Params
}

// NewWalletEngine wires a Backend to the wallet service. Callers convert
// the CLI network string via bip47send.NetworkParams (or equivalent) before
// passing — the engine never sees the network name as a free-form string.
func NewWalletEngine(svc *Service, backend Backend, network *chaincfg.Params, log zerolog.Logger) *WalletEngine {
	return &WalletEngine{
		svc:     svc,
		backend: backend,
		log:     log.With().Str("component", "wallet-engine").Logger(),
		network: network,
	}
}

// Backend returns the active wallet backend.
func (e *WalletEngine) Backend() Backend {
	return e.backend
}

// ElectrumConfigured reports whether an electrum (Esplora) backend is wired,
// so callers can refuse to create electrum wallets that could never sync.
func (e *WalletEngine) ElectrumConfigured() bool {
	r, ok := e.backend.(*BackendRouter)
	return ok && r.ElectrumConfigured()
}

// ChainForWallet returns the chain source for a wallet's backend, dispatching
// by wallet type so electrum wallets read/broadcast over Esplora.
func (e *WalletEngine) ChainForWallet(walletID string) ChainSource {
	if r, ok := e.backend.(*BackendRouter); ok {
		return r.ChainForWallet(walletID)
	}
	return e.backend.Chain()
}

func (e *WalletEngine) electrumBackend() (*ElectrumBackend, error) {
	r, ok := e.backend.(*BackendRouter)
	if !ok {
		return nil, errors.New("backend router unavailable")
	}
	eb, ok := r.ElectrumBackend()
	if !ok {
		return nil, errors.New("electrum backend not configured")
	}
	return eb, nil
}

// CreatePSBT builds an unsigned PSBT for a send from an electrum wallet.
func (e *WalletEngine) CreatePSBT(ctx context.Context, walletID string, req SendRequest) (string, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return "", err
	}
	return eb.CreatePSBT(ctx, walletID, req)
}

// WatchSync subscribes to an electrum wallet's scan progress; the returned func
// cancels the subscription.
func (e *WalletEngine) WatchSync(walletID string) (<-chan SyncProgress, func(), error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return nil, nil, err
	}
	ch, cancel := eb.WatchSync(walletID)
	return ch, cancel, nil
}

// SyncSnapshot returns an electrum wallet's latest scan progress.
func (e *WalletEngine) SyncSnapshot(walletID string) (SyncProgress, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return SyncProgress{}, err
	}
	return eb.SyncSnapshot(walletID), nil
}

// SignPSBT adds an electrum wallet's signatures to a base64 PSBT.
func (e *WalletEngine) SignPSBT(ctx context.Context, walletID, psbtBase64 string) (string, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return "", err
	}
	return eb.SignPSBT(ctx, walletID, psbtBase64)
}

// CombinePSBT merges cosigner PSBTs of the same transaction.
func (e *WalletEngine) CombinePSBT(psbtsBase64 []string) (string, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return "", err
	}
	return eb.CombinePSBT(psbtsBase64)
}

// FinalizePSBT extracts the raw transaction from a fully-signed PSBT.
func (e *WalletEngine) FinalizePSBT(psbtBase64 string) (string, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return "", err
	}
	return eb.FinalizePSBT(psbtBase64)
}

// Network returns the chain parameters this engine was constructed against.
func (e *WalletEngine) Network() *chaincfg.Params {
	return e.network
}

// ResolveWalletID returns the wallet ID to use. If empty, returns active wallet ID.
func (e *WalletEngine) ResolveWalletID(walletID string) (string, error) {
	if walletID != "" {
		return walletID, nil
	}
	active := e.svc.ActiveWalletID()
	if active == "" {
		return "", fmt.Errorf("no active wallet")
	}
	return active, nil
}
