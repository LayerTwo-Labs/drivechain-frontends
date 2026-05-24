package orchestrator

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// roundTripperFunc lets a test swap an http.Client's transport with a
// per-request function — used to intercept the hardcoded explorer URL
// (https://node.<network>.drivechain.info/...) without refactoring prod
// code to take an injectable base URL.
type roundTripperFunc func(*http.Request) (*http.Response, error)

func (f roundTripperFunc) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }

// jsonResponse builds a 200 OK response carrying the JSON-serialised body.
func jsonResponse(body interface{}) *http.Response {
	b, _ := json.Marshal(body)
	return &http.Response{
		StatusCode: http.StatusOK,
		Body:       io.NopCloser(strings.NewReader(string(b))),
		Header:     http.Header{"Content-Type": []string{"application/json"}},
	}
}

// statusResponse builds a non-200 response with an empty body.
func statusResponse(code int) *http.Response {
	return &http.Response{
		StatusCode: code,
		Body:       io.NopCloser(strings.NewReader("")),
		Header:     make(http.Header),
	}
}

// setSidechainPort overwrites the cached BinaryConfig.Port for `name` to
// point at the httptest server's local port. The orchestrator's GetSyncStatus
// reads cfg.Port via o.Configs() at probe time so the override is picked up
// on the next call.
func setSidechainPort(t *testing.T, o *Orchestrator, name string, serverURL string) {
	t.Helper()
	u, err := url.Parse(serverURL)
	require.NoError(t, err)
	port, err := strconv.Atoi(u.Port())
	require.NoError(t, err)

	cfg, err := o.getConfig(name)
	require.NoError(t, err)
	cfg.Port = port
	o.UpdateConfigs([]BinaryConfig{cfg})
}

// adoptSidechain flips o.process.IsRunning(name) to true so GetSyncStatus
// reaches the RPC probe instead of short-circuiting with "not running".
func adoptSidechain(t *testing.T, o *Orchestrator, name string) {
	t.Helper()
	cfg, err := o.getConfig(name)
	require.NoError(t, err)
	o.process.AdoptProcess(cfg, 99999)
}

// sidechainCountServer spins up an httptest.Server that answers the JSON-RPC
// `getblockcount` call with <count> when status==200, or the supplied non-200
// status (empty body).
func sidechainCountServer(t *testing.T, status int, count int64) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if status != http.StatusOK {
			w.WriteHeader(status)
			return
		}
		writeJSONRPCCount(w, r, count)
	}))
	t.Cleanup(srv.Close)
	return srv
}

// writeJSONRPCCount echoes a JSON-RPC 2.0 success envelope with `count` as
// the result. The id is mirrored from the request body when present.
func writeJSONRPCCount(w http.ResponseWriter, r *http.Request, count int64) {
	var req struct {
		ID int64 `json:"id"`
	}
	body, _ := io.ReadAll(r.Body)
	_ = json.Unmarshal(body, &req)
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]any{
		"jsonrpc": "2.0",
		"result":  count,
		"id":      req.ID,
	})
}

func TestGetSyncStatus_LeavesHeadersZeroWhenExplorerDown(t *testing.T) {
	o := newTestOrchestrator(t)

	o.explorerHTTPClient = &http.Client{
		Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
			return statusResponse(http.StatusServiceUnavailable), nil
		}),
	}

	srv := sidechainCountServer(t, http.StatusOK, 50)
	setSidechainPort(t, o, "thunder", srv.URL)
	adoptSidechain(t, o, "thunder")

	out, err := o.GetSyncStatus(context.Background())
	require.NoError(t, err)
	require.NotNil(t, out.Sidechains["thunder"])

	slot := out.Sidechains["thunder"]
	assert.Equal(t, int64(50), slot.Blocks)
	// The public explorer is a UX extra — only signet has one today, so on
	// mainnet/testnet/regtest/forknet the fetch always fails. Headers must
	// stay zero so the UI renders an unknown/zero-progress state instead of
	// the previous Headers=Blocks fallback that made every running sidechain
	// look fully synced mid-IBD.
	assert.Equal(t, int64(0), slot.Headers, "headers must stay 0 when the explorer is unreachable, never fall back to Blocks")
	assert.Equal(t, "", slot.Error)
}

func TestGetSyncStatus_UsesExplorerHeightsWhenAvailable(t *testing.T) {
	t.Run("string height (current explorer shape)", func(t *testing.T) {
		o := newTestOrchestrator(t)
		o.explorerHTTPClient = &http.Client{
			Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
				return jsonResponse(map[string]map[string]interface{}{
					"thunder": {"height": "100"},
				}), nil
			}),
		}

		srv := sidechainCountServer(t, http.StatusOK, 50)
		setSidechainPort(t, o, "thunder", srv.URL)
		adoptSidechain(t, o, "thunder")

		out, err := o.GetSyncStatus(context.Background())
		require.NoError(t, err)
		slot := out.Sidechains["thunder"]
		require.NotNil(t, slot)
		assert.Equal(t, int64(50), slot.Blocks)
		assert.Equal(t, int64(100), slot.Headers)
		assert.Equal(t, "", slot.Error)
	})

	t.Run("numeric height (legacy explorer shape)", func(t *testing.T) {
		o := newTestOrchestrator(t)
		o.explorerHTTPClient = &http.Client{
			Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
				return jsonResponse(map[string]map[string]interface{}{
					"thunder": {"height": float64(100)},
				}), nil
			}),
		}

		srv := sidechainCountServer(t, http.StatusOK, 50)
		setSidechainPort(t, o, "thunder", srv.URL)
		adoptSidechain(t, o, "thunder")

		out, err := o.GetSyncStatus(context.Background())
		require.NoError(t, err)
		slot := out.Sidechains["thunder"]
		require.NotNil(t, slot)
		assert.Equal(t, int64(50), slot.Blocks)
		assert.Equal(t, int64(100), slot.Headers, "code at orchestrator.go:2206-2213 must tolerate float64 heights")
	})
}

func TestFetchExplorerHeights_CachesWithinTTL(t *testing.T) {
	o := newTestOrchestrator(t)
	var hits int32
	o.explorerHTTPClient = &http.Client{
		Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
			atomic.AddInt32(&hits, 1)
			return jsonResponse(map[string]map[string]interface{}{
				"thunder": {"height": "100"},
			}), nil
		}),
	}

	ctx := context.Background()
	first := o.fetchExplorerHeights(ctx)
	second := o.fetchExplorerHeights(ctx)

	assert.Equal(t, int32(1), atomic.LoadInt32(&hits), "second call within TTL must be served from cache")
	assert.Equal(t, int64(100), first["thunder"])
	assert.Equal(t, int64(100), second["thunder"])
}

func TestFetchExplorerHeights_ServesStaleOnFailure(t *testing.T) {
	o := newTestOrchestrator(t)
	var hits int32
	o.explorerHTTPClient = &http.Client{
		Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
			n := atomic.AddInt32(&hits, 1)
			if n == 1 {
				return jsonResponse(map[string]map[string]interface{}{
					"thunder": {"height": "100"},
				}), nil
			}
			return statusResponse(http.StatusInternalServerError), nil
		}),
	}

	ctx := context.Background()
	first := o.fetchExplorerHeights(ctx)
	require.Equal(t, int64(100), first["thunder"])

	// Invalidate the TTL window so the next call hits the network again,
	// where it will fail. CachedConnection's last-good-on-error must still
	// hand back the previously fetched map.
	cc := o.explorerHeightsCached()
	cc.mu.Lock()
	cc.fetched = time.Now().Add(-time.Hour)
	cc.mu.Unlock()

	second := o.fetchExplorerHeights(ctx)
	assert.Equal(t, int32(2), atomic.LoadInt32(&hits), "second call must hit the network after TTL expiry")
	require.NotNil(t, second)
	assert.Equal(t, int64(100), second["thunder"], "stale cache must be served on explorer failure rather than dropping headers")
}

func TestGetSyncStatus_PerSidechainErrorsAreIsolated(t *testing.T) {
	o := newTestOrchestrator(t)
	o.explorerHTTPClient = &http.Client{
		Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
			return jsonResponse(map[string]map[string]interface{}{
				"thunder":  {"height": "100"},
				"bitnames": {"height": "200"},
			}), nil
		}),
	}

	thunderSrv := sidechainCountServer(t, http.StatusOK, 50)
	bitnamesSrv := sidechainCountServer(t, http.StatusInternalServerError, 0)
	setSidechainPort(t, o, "thunder", thunderSrv.URL)
	setSidechainPort(t, o, "bitnames", bitnamesSrv.URL)
	adoptSidechain(t, o, "thunder")
	adoptSidechain(t, o, "bitnames")

	out, err := o.GetSyncStatus(context.Background())
	require.NoError(t, err)

	thunder := out.Sidechains["thunder"]
	require.NotNil(t, thunder)
	assert.Equal(t, int64(50), thunder.Blocks)
	assert.Equal(t, int64(100), thunder.Headers)
	assert.Equal(t, "", thunder.Error, "thunder must be unaffected by bitnames' 500")

	bitnames := out.Sidechains["bitnames"]
	require.NotNil(t, bitnames)
	assert.NotEmpty(t, bitnames.Error, "bitnames slot must surface the upstream HTTP failure")
	assert.Equal(t, int64(0), bitnames.Blocks)

	// Every other registered sidechain must show "not running" without
	// leaking into thunder's slot.
	for name, slot := range out.Sidechains {
		if name == "thunder" || name == "bitnames" {
			continue
		}
		assert.Equal(t, "not running", slot.Error, "uninstalled sidechain %q should be not running", name)
		assert.Equal(t, int64(0), slot.Blocks, "uninstalled sidechain %q should report zero blocks", name)
	}
}

func TestGetSyncStatus_NotRunningSidechainCarriesError(t *testing.T) {
	o := newTestOrchestrator(t)
	o.explorerHTTPClient = &http.Client{
		Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
			return jsonResponse(map[string]map[string]interface{}{
				"thunder": {"height": "100"},
			}), nil
		}),
	}

	out, err := o.GetSyncStatus(context.Background())
	require.NoError(t, err)

	// All L2 sidechain slots must exist (pre-populated at orchestrator.go:2038-2042)
	// even though none were adopted.
	var l2 int
	for _, cfg := range o.Configs() {
		if cfg.ChainLayer == 2 {
			l2++
		}
	}
	require.Equal(t, l2, len(out.Sidechains))

	for name, slot := range out.Sidechains {
		assert.Equal(t, "not running", slot.Error, "sidechain %q should carry not-running error", name)
		assert.Equal(t, int64(0), slot.Blocks, "sidechain %q blocks must remain zero", name)
	}
}

func TestGetSyncStatus_EveryL2SidechainHasAPort(t *testing.T) {
	// Invariant: every L2 sidechain registered in chains_config.json has a
	// non-zero Port. GetSyncStatus dials the sidechain's JSON-RPC endpoint at
	// 127.0.0.1:<Port>, so a missing port silently breaks the height probe.
	for _, cfg := range AllDefaults() {
		if cfg.ChainLayer != 2 {
			continue
		}
		assert.NotZerof(t, cfg.Port, "sidechain %q has ChainLayer=2 but no Port set in chains_config.json", cfg.Name)
	}

	for key, dc := range config.AllDirConfigs() {
		if dc.ChainLayer != 2 {
			continue
		}
		assert.NotZerof(t, dc.Port, "sidechain JSON key %q (chain_layer=2) has no Port in config.AllDirConfigs", key)
	}
}

// countingSidechainServer returns an httptest.Server that records every hit
// and replies with the JSON-RPC `getblockcount` success envelope for <count>.
func countingSidechainServer(t *testing.T, count int64) (*httptest.Server, *int32) {
	t.Helper()
	var hits int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		atomic.AddInt32(&hits, 1)
		writeJSONRPCCount(w, r, count)
	}))
	t.Cleanup(srv.Close)
	return srv, &hits
}

func TestSidechainConnection_CachesWithinTTL(t *testing.T) {
	o := newTestOrchestrator(t)
	srv, hits := countingSidechainServer(t, 100)
	setSidechainPort(t, o, "thunder", srv.URL)
	adoptSidechain(t, o, "thunder")

	first, err := o.syncConnectionFor("thunder").Fetch(context.Background())
	require.NoError(t, err)
	second, err := o.syncConnectionFor("thunder").Fetch(context.Background())
	require.NoError(t, err)

	assert.Equal(t, int64(100), first.Blocks)
	assert.Equal(t, int64(100), second.Blocks)
	assert.Equal(t, int32(1), atomic.LoadInt32(hits),
		"two calls within chainSyncCacheTTL must share one RPC — the cache is what stops UI flicker")
}

// Regression for "thunder block count doesn't update during sync": with the
// old code, every transient RPC error reset slot.Blocks to 0 in the response
// and the UI saw alternating 0/N values. The fix routes every chain through
// CachedConnection's last-good machinery — failed fetches preserve the
// previous count.
func TestSidechainConnection_PreservesLastGoodOnError(t *testing.T) {
	o := newTestOrchestrator(t)

	var hits int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		n := atomic.AddInt32(&hits, 1)
		if n == 1 {
			writeJSONRPCCount(w, r, 1500)
			return
		}
		w.WriteHeader(http.StatusInternalServerError)
	}))
	t.Cleanup(srv.Close)
	setSidechainPort(t, o, "thunder", srv.URL)
	adoptSidechain(t, o, "thunder")

	first, err := o.syncConnectionFor("thunder").Fetch(context.Background())
	require.NoError(t, err)
	require.Equal(t, int64(1500), first.Blocks)

	// Bust the TTL so the next call hits the network (and fails).
	o.invalidateSyncConnectionCacheForTest("thunder")

	second, err := o.syncConnectionFor("thunder").Fetch(context.Background())
	require.Error(t, err, "the leader still surfaces the underlying RPC error")
	require.NotNil(t, second)
	assert.Equal(t, int64(1500), second.Blocks,
		"last-good blocks must survive a transient failure")
}

// The full UI flow: GetSyncStatus must report the cached count (and no
// error) on the second call even when the sidechain RPC has started
// timing out, otherwise the bottom-nav card flickers 0 → real → 0 → real.
func TestGetSyncStatus_KeepsLastGoodBlocksAcrossTransientFailures(t *testing.T) {
	o := newTestOrchestrator(t)
	o.explorerHTTPClient = &http.Client{
		Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
			return jsonResponse(map[string]map[string]interface{}{
				"thunder": {"height": "200"},
			}), nil
		}),
	}

	var hits int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		n := atomic.AddInt32(&hits, 1)
		if n == 1 {
			writeJSONRPCCount(w, r, 1500)
			return
		}
		w.WriteHeader(http.StatusInternalServerError)
	}))
	t.Cleanup(srv.Close)
	setSidechainPort(t, o, "thunder", srv.URL)
	adoptSidechain(t, o, "thunder")

	// First poll: succeeds, populates cache.
	out, err := o.GetSyncStatus(context.Background())
	require.NoError(t, err)
	require.Equal(t, int64(1500), out.Sidechains["thunder"].Blocks)
	require.Empty(t, out.Sidechains["thunder"].Error)

	// Invalidate the TTL window so the next GetSyncStatus must re-fetch
	// (and the upstream RPC will fail). Without the last-good cache the
	// slot would come back Blocks=0, Error="HTTP 500..." — exactly the
	// flicker the user reported.
	o.invalidateSyncConnectionCacheForTest("thunder")

	out2, err := o.GetSyncStatus(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int64(1500), out2.Sidechains["thunder"].Blocks,
		"second poll must show the last-good 1500, not snap to zero")
	assert.Equal(t, "", out2.Sidechains["thunder"].Error,
		"transient RPC failure must not leak as a slot.Error — the cache hides it")
}
