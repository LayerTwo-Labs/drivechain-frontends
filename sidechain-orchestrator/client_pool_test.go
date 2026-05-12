package orchestrator

import (
	"net/http"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// The orchestrator's chatty pollers (CoreStatusClient + GetSyncStatus) used
// to construct a fresh *http.Client per RPC call, throwing away the
// connection pool every time and churning hundreds of TCP sockets per
// second against bitcoind / enforcer / sidechains. These tests pin the
// singleton behaviour so a regression that reintroduces per-call clients
// fails loudly. Bitcoind RPCs route through CallBitcoindRPC's shared
// http.DefaultClient + concurrency gate; sidechain and enforcer traffic
// use the per-orchestrator pooled clients tested below.

func TestCoreStatusClient_ReusedAcrossCalls(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = &config.BitcoinConfManager{Network: config.Network("signet")}

	first, err := o.CoreStatusClient()
	require.NoError(t, err)
	second, err := o.CoreStatusClient()
	require.NoError(t, err)

	assert.Same(t, first, second, "CoreStatusClient should return the same instance for unchanged config")
}

func TestCoreStatusClient_RebuiltOnConfigChange(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = &config.BitcoinConfManager{Network: config.Network("signet")}

	first, err := o.CoreStatusClient()
	require.NoError(t, err)

	o.BitcoinConf = &config.BitcoinConfManager{Network: config.Network("mainnet")}
	second, err := o.CoreStatusClient()
	require.NoError(t, err)

	assert.NotSame(t, first, second, "switching networks (and therefore RPC port) must invalidate the cached client")
}

func TestEnforcerHTTPClient_Singleton(t *testing.T) {
	o := newTestOrchestrator(t)

	first := o.enforcerHTTP()
	second := o.enforcerHTTP()

	require.NotNil(t, first)
	assert.Same(t, first, second, "enforcer http.Client must be a singleton — a fresh transport per call leaks connections")
	assert.Same(t, first.Transport, second.Transport, "the http2 transport (and its conn pool) must be the same instance")
}

func TestSidechainHTTPClient_Singleton(t *testing.T) {
	o := newTestOrchestrator(t)

	first := o.sidechainHTTP()
	second := o.sidechainHTTP()

	require.NotNil(t, first)
	assert.Same(t, first, second, "sidechain http.Client must be a singleton")

	tr, ok := first.Transport.(*http.Transport)
	require.True(t, ok, "sidechain transport must be the standard *http.Transport (sidechain probes use HTTP/1)")
	assert.Equal(t, 1, tr.MaxConnsPerHost, "MaxConnsPerHost must be 1 — bitcoind/sidechains serialise behind their own locks anyway")
}

func TestExplorerHTTPClient_Singleton(t *testing.T) {
	o := newTestOrchestrator(t)

	first := o.explorerHTTP()
	second := o.explorerHTTP()

	require.NotNil(t, first)
	assert.Same(t, first, second, "explorer http.Client must be a singleton — re-dialling the public explorer per poll is silly")
}
