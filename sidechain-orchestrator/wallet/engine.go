package wallet

import (
	"fmt"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
)

// WalletEngine is the mode-agnostic façade consumers hold: it resolves
// wallet IDs and hands out the active Provider. All chain/wallet data flows
// through the Provider so backends are swappable at the wiring site.
type WalletEngine struct {
	svc      *Service
	provider Provider
	log      zerolog.Logger
	network  *chaincfg.Params
}

// NewWalletEngine wires a Provider to the wallet service. Callers convert
// the CLI network string via bip47send.NetworkParams (or equivalent) before
// passing — the engine never sees the network name as a free-form string.
func NewWalletEngine(svc *Service, provider Provider, network *chaincfg.Params, log zerolog.Logger) *WalletEngine {
	return &WalletEngine{
		svc:      svc,
		provider: provider,
		log:      log.With().Str("component", "wallet-engine").Logger(),
		network:  network,
	}
}

// Provider returns the active wallet backend.
func (e *WalletEngine) Provider() Provider {
	return e.provider
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
