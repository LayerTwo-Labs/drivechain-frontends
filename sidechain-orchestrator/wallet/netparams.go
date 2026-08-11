package wallet

import "github.com/btcsuite/btcd/chaincfg"

// ParamsFunc reports the params of the network the orchestrator is on right
// now. Resolved per call, so a network swap applies without a restart.
type ParamsFunc func() *chaincfg.Params

// StaticParams is a ParamsFunc pinned to one network, for tests and for
// callers that genuinely cannot change network.
func StaticParams(p *chaincfg.Params) ParamsFunc {
	return func() *chaincfg.Params { return p }
}

// Resolve returns the params, nil when no resolver is wired.
func (f ParamsFunc) Resolve() *chaincfg.Params {
	if f == nil {
		return nil
	}
	return f()
}
