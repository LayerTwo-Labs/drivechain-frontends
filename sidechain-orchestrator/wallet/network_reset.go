package wallet

// NetworkResettable is a backend that caches state derived from the network it
// reads. Implement it and the reset reaches you without editing a list.
type NetworkResettable interface {
	ResetNetworkState()
}

var (
	_ NetworkResettable = (*ElectrumBackend)(nil)
	_ NetworkResettable = (*CoreBackend)(nil)
	_ NetworkResettable = (*BackendRouter)(nil)
)

// ResetNetworkState fans out to every configured backend.
func (r *BackendRouter) ResetNetworkState() {
	for _, b := range []Backend{r.enforcer, r.chain, r.electrum} {
		if nr, ok := b.(NetworkResettable); ok {
			nr.ResetNetworkState()
		}
	}
}

// OnNetworkReset registers state that lives outside the wallet package but in
// the per-network directory. Called with the new directory on every swap.
func (e *WalletEngine) OnNetworkReset(fn func(networkDir string)) {
	e.resetMu.Lock()
	defer e.resetMu.Unlock()
	e.onReset = append(e.onReset, fn)
}

// ResetForNetwork repoints wallet state at another network and drops everything
// derived from the previous one. Nothing else may reset wallet state piecemeal.
func (e *WalletEngine) ResetForNetwork(network string) error {
	// Invalidate before the database moves: a read still in flight must fail its
	// generation check rather than write the outgoing network's chain data.
	if nr, ok := e.backend.(NetworkResettable); ok {
		nr.ResetNetworkState()
	}
	if err := e.svc.RebindNetwork(network); err != nil {
		return err
	}

	dir := e.svc.NetworkDir()
	e.resetMu.Lock()
	hooks := append([]func(string){}, e.onReset...)
	e.resetMu.Unlock()
	for _, fn := range hooks {
		fn(dir)
	}

	e.svc.notifyChanged()
	return nil
}
