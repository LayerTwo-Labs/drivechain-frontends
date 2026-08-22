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
	for _, b := range []Backend{r.chain, r.electrum} {
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
	// Invalidate on both sides of the rebind: a read in flight, or one starting
	// mid-rebind, must fail its generation check instead of storing chain data.
	nr, resettable := e.backend.(NetworkResettable)
	if resettable {
		nr.ResetNetworkState()
	}
	if err := e.svc.RebindNetwork(network); err != nil {
		return err
	}
	if resettable {
		nr.ResetNetworkState()
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
