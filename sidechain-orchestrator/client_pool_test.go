package orchestrator

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// coreConfWithCookie builds a conf manager pointed at a datadir holding the
// cookie Core would have written, so credential resolution succeeds.
func coreConfWithCookie(t *testing.T, network config.Network) *config.BitcoinConfManager {
	t.Helper()
	datadir := t.TempDir()
	cfg := config.NewBitcoinConfig()
	cfg.SetSetting("datadir", datadir)
	// DataDir() reads DetectedDataDir, not the setting; without it the cookie
	// resolves to the real ~/.bitcoin and the test clobbers a live cookie.
	m := &config.BitcoinConfManager{Network: network, Config: cfg, DetectedDataDir: datadir}

	cookie := m.GetRPCCookiePath()
	require.NoError(t, os.MkdirAll(filepath.Dir(cookie), 0o755))
	require.NoError(t, os.WriteFile(cookie, []byte("__cookie__:secret"), 0o600))
	return m
}

// The orchestrator's chatty pollers (CoreStatusClient + GetSyncStatus) used
// to construct a fresh *http.Client per RPC call, throwing away the
// connection pool every time and churning hundreds of TCP sockets per
// second. These tests pin the singleton behaviour for the clients that
// still need explicit pooling (enforcer h2c, public explorer).

func TestCoreStatusClient_ReusedAcrossCalls(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = coreConfWithCookie(t, config.Network("signet"))

	first, err := o.CoreStatusClient()
	require.NoError(t, err)
	second, err := o.CoreStatusClient()
	require.NoError(t, err)

	assert.Same(t, first, second, "CoreStatusClient should return the same instance for unchanged config")
}

func TestCoreStatusClient_RebuiltOnConfigChange(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = coreConfWithCookie(t, config.Network("signet"))

	first, err := o.CoreStatusClient()
	require.NoError(t, err)

	o.BitcoinConf = coreConfWithCookie(t, config.Network("mainnet"))
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

func TestExplorerHTTPClient_Singleton(t *testing.T) {
	o := newTestOrchestrator(t)

	first := o.explorerHTTP()
	second := o.explorerHTTP()

	require.NotNil(t, first)
	assert.Same(t, first, second, "explorer http.Client must be a singleton — re-dialling the public explorer per poll is silly")
}
