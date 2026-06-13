package datasource

import "context"

// Provider selects the DataSource for the current request. Today it always
// returns the local (Core + enforcer) source. A future PR branches on the
// active wallet type — electrum wallets, which run no local Core or enforcer,
// get a remote source instead — without touching any handler.
type Provider struct {
	local DataSource
}

// NewProvider returns a Provider that serves the given local DataSource.
func NewProvider(local DataSource) *Provider {
	return &Provider{local: local}
}

// Active returns the DataSource to read from for this request.
func (p *Provider) Active(_ context.Context) DataSource {
	return p.local
}
