package wallet

import (
	"context"
	"errors"
	"fmt"
	"sync"

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
	params  ParamsFunc

	resetMu sync.Mutex
	onReset []func(networkDir string)
}

// NewWalletEngine wires a Backend to the wallet service.
func NewWalletEngine(svc *Service, backend Backend, params ParamsFunc, log zerolog.Logger) *WalletEngine {
	return &WalletEngine{
		svc:     svc,
		backend: backend,
		log:     log.With().Str("component", "wallet-engine").Logger(),
		params:  params,
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

// Bip47BackendFor returns the wallet's backend as a Bip47Backend when it is
// BIP47-capable. ok is false for non-capable wallets (the enforcer), so the
// BIP47 engine and send path skip them without a wallet-type switch.
func (e *WalletEngine) Bip47BackendFor(walletID string) (Bip47Backend, bool) {
	if r, ok := e.backend.(*BackendRouter); ok {
		return r.Bip47BackendFor(walletID)
	}
	b, ok := e.backend.(Bip47Backend)
	return b, ok
}

// ForgetWallet drops the backend state a deleted wallet held: Core unloads its
// wallet. Call it after the wallet is out of wallet.json. No-op otherwise.
func (e *WalletEngine) ForgetWallet(ctx context.Context, walletID string) error {
	f, ok := e.backend.(ForgetBackend)
	if !ok {
		return nil
	}
	return f.Forget(ctx, walletID)
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

// SignPSBT adds an electrum wallet's signatures to a base64 PSBT.
func (e *WalletEngine) SignPSBT(ctx context.Context, walletID, psbtBase64 string) (string, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return "", err
	}
	return eb.SignPSBT(ctx, walletID, psbtBase64)
}

// SignPSBTWithCosigner adds a single multisig cosigner's signature to a PSBT.
func (e *WalletEngine) SignPSBTWithCosigner(ctx context.Context, walletID, psbtBase64, cosignerXpub string) (string, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return "", err
	}
	return eb.SignPSBTWithCosigner(ctx, walletID, psbtBase64, cosignerXpub)
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

func (e *WalletEngine) EstimateFeeRate(ctx context.Context, confTarget int) (float64, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return 0, err
	}
	return eb.FeeRateForTarget(ctx, confTarget), nil
}

// SyncElectrumWallet brings a wallet's cached scan up to the chain tip, serving
// the existing cache untouched when it is already current.
func (e *WalletEngine) SyncElectrumWallet(ctx context.Context, walletID string) error {
	eb, err := e.electrumBackend()
	if err != nil {
		return err
	}
	_, err = eb.scan(ctx, walletID, true)
	return err
}

// ElectrumAvailable reports whether the current network has a wallet chain
// source, so a background sync skips networks that cannot serve one.
func (e *WalletEngine) ElectrumAvailable() bool {
	eb, err := e.electrumBackend()
	if err != nil {
		return false
	}
	return eb.Available()
}

func (e *WalletEngine) RefreshElectrumScan(ctx context.Context, walletID string) error {
	eb, err := e.electrumBackend()
	if err != nil {
		return nil
	}
	_, err = eb.scan(ctx, walletID, false)
	return err
}

// ElectrumServerURL returns the electrum wallet's current Esplora endpoint.
func (e *WalletEngine) ElectrumServerURL() (string, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return "", err
	}
	return eb.ServerURL(), nil
}

// SetElectrumServerURL switches the electrum wallet's Esplora endpoint at
// runtime, returning the new chain tip on success. See ElectrumBackend.SetServerURL.
func (e *WalletEngine) SetElectrumServerURL(ctx context.Context, url string) (int, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return 0, err
	}
	return eb.SetServerURL(ctx, url)
}

// DetectScriptKind probes the chain for the script kind a bare extended key
// actually uses. See ElectrumBackend.DetectScriptKind.
func (e *WalletEngine) DetectScriptKind(ctx context.Context, xpubOrDescriptor string) (ScriptKind, bool) {
	eb, err := e.electrumBackend()
	if err != nil {
		return ScriptUnknown, false
	}
	return eb.DetectScriptKind(ctx, xpubOrDescriptor)
}

// TorConfig reports whether the electrum wallet routes chain connections
// through a SOCKS5 proxy and the proxy address.
func (e *WalletEngine) TorConfig() (bool, string, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return false, "", err
	}
	enabled, proxyAddr := eb.TorConfig()
	return enabled, proxyAddr, nil
}

// SetTorConfig switches the electrum wallet's SOCKS5 routing at runtime,
// returning the chain tip reached through the new route. See
// ElectrumBackend.SetTorConfig.
func (e *WalletEngine) SetTorConfig(ctx context.Context, enabled bool, proxyAddr string) (int, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return 0, err
	}
	return eb.SetTorConfig(ctx, enabled, proxyAddr)
}

// Network returns the chain parameters of the network in use right now.
func (e *WalletEngine) Network() *chaincfg.Params {
	return e.params.Resolve()
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
