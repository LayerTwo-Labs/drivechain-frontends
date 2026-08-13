package orchestrator

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func releaseTestConfig(baseURL string) BinaryConfig {
	return BinaryConfig{
		Name:         "thunder",
		BinaryName:   "thunder",
		DownloadURLs: map[string]string{"default": baseURL},
		Files:        map[string]string{currentPlatform(): "L2-S9-Thunder-latest.zip"},
	}
}

// The published archives keep one fixed name per platform, so Last-Modified is
// the only thing that separates one release from the next.
func TestReleaseCheckerComparesLastModified(t *testing.T) {
	published := time.Date(2026, 8, 6, 17, 44, 0, 0, time.UTC)

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		require.Equal(t, http.MethodHead, r.Method, "a release check must not download the archive")
		w.Header().Set("Last-Modified", published.Format(http.TimeFormat))
	}))
	defer server.Close()

	dataDir := t.TempDir()
	config := releaseTestConfig(server.URL + "/")
	binPath := BinaryPath(dataDir, config.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(binPath), 0o755))
	require.NoError(t, os.WriteFile(binPath, []byte("binary"), 0o755))

	checker := NewReleaseChecker(NewDownloadManager(dataDir, "", zerolog.Nop()), zerolog.Nop())

	// Downloaded after the release: nothing to update.
	require.NoError(t, os.Chtimes(binPath, published.Add(time.Hour), published.Add(time.Hour)))
	checker.Refresh(context.Background(), config, "signet")
	check, ok := checker.Check(config, "signet")
	require.True(t, ok)
	assert.False(t, check.UpdateAvailable())
	assert.Equal(t, published, check.Remote.UTC())

	// Downloaded before the release: an update is waiting.
	require.NoError(t, os.Chtimes(binPath, published.Add(-time.Hour), published.Add(-time.Hour)))
	checker.Refresh(context.Background(), config, "signet")
	check, ok = checker.Check(config, "signet")
	require.True(t, ok)
	assert.True(t, check.UpdateAvailable())
}

// A server that cannot answer must not claim an update, because the button it
// draws would download the same build the user already runs.
func TestReleaseCheckerStaysQuietWhenTheProbeFails(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNotFound)
	}))
	defer server.Close()

	dataDir := t.TempDir()
	config := releaseTestConfig(server.URL + "/")
	binPath := BinaryPath(dataDir, config.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(binPath), 0o755))
	require.NoError(t, os.WriteFile(binPath, []byte("binary"), 0o755))

	checker := NewReleaseChecker(NewDownloadManager(dataDir, "", zerolog.Nop()), zerolog.Nop())
	checker.Refresh(context.Background(), config, "signet")

	check, ok := checker.Check(config, "signet")
	require.True(t, ok)
	assert.False(t, check.UpdateAvailable())
	assert.True(t, check.Remote.IsZero())
	assert.False(t, check.Local.IsZero(), "the local time still reads off disk")
}

// A binary that was never downloaded has nothing to compare against.
func TestReleaseCheckerNeedsALocalBinary(t *testing.T) {
	published := time.Date(2026, 8, 6, 17, 44, 0, 0, time.UTC)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Last-Modified", published.Format(http.TimeFormat))
	}))
	defer server.Close()

	checker := NewReleaseChecker(NewDownloadManager(t.TempDir(), "", zerolog.Nop()), zerolog.Nop())
	config := releaseTestConfig(server.URL + "/")
	checker.Refresh(context.Background(), config, "signet")

	check, ok := checker.Check(config, "signet")
	require.True(t, ok)
	assert.False(t, check.UpdateAvailable())
	assert.True(t, check.Local.IsZero())
}

// Bitcoin Core defines its downloads through variants only, so its own Files
// are empty. A check that reads the plain config would skip it entirely.
func TestReleaseCheckerFollowsTheCoreVariant(t *testing.T) {
	published := time.Date(2026, 8, 6, 17, 44, 0, 0, time.UTC)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Last-Modified", published.Format(http.TimeFormat))
	}))
	defer server.Close()

	dataDir := t.TempDir()
	downloads := NewDownloadManager(dataDir, "", zerolog.Nop())
	variant := CoreVariantSpec{
		ID:      "patched",
		BaseURL: server.URL + "/",
		Files:   map[string]string{currentPlatform(): "L1-bitcoin-patched-latest.zip"},
	}
	downloads.CoreVariant = func() (CoreVariantSpec, bool) { return variant, true }

	// A variant-only config: no Files of its own, which is what ships today.
	config := BinaryConfig{Name: "bitcoind", BinaryName: "bitcoind", IsBitcoinCore: true, ChainLayer: 1}
	binPath := CoreBinaryPath(dataDir, variant, config.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(binPath), 0o755))
	require.NoError(t, os.WriteFile(binPath, []byte("core"), 0o755))
	require.NoError(t, os.Chtimes(binPath, published.Add(-time.Hour), published.Add(-time.Hour)))

	checker := NewReleaseChecker(downloads, zerolog.Nop())
	checker.Refresh(context.Background(), config, "signet")

	check, ok := checker.Check(config, "signet")
	require.True(t, ok)
	assert.True(t, check.UpdateAvailable(), "the variant download decides, not the empty config")
}

// A GitHub config carries an asset pattern, not a path. Joining it onto the API
// URL would probe something that does not exist.
func TestReleaseCheckerResolvesAGitHubAsset(t *testing.T) {
	published := time.Date(2026, 8, 6, 17, 44, 0, 0, time.UTC)

	var assetPath string
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/releases/latest" {
			w.Header().Set("Content-Type", "application/json")
			_, _ = w.Write([]byte(`{"assets":[{"name":"zside-1.2.3-x86_64.zip","browser_download_url":"` +
				"http://" + r.Host + `/assets/zside.zip"}]}`))
			return
		}
		assetPath = r.URL.Path
		w.Header().Set("Last-Modified", published.Format(http.TimeFormat))
	}))
	defer server.Close()

	dataDir := t.TempDir()
	config := BinaryConfig{
		Name:           "zside",
		BinaryName:     "zside",
		DownloadSource: DownloadSourceGitHub,
		DownloadURLs:   map[string]string{"default": server.URL + "/releases/latest"},
		Files:          map[string]string{currentPlatform(): `zside-.*-x86_64\.zip`},
	}
	binPath := BinaryPath(dataDir, config.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(binPath), 0o755))
	require.NoError(t, os.WriteFile(binPath, []byte("zside"), 0o755))
	require.NoError(t, os.Chtimes(binPath, published.Add(-time.Hour), published.Add(-time.Hour)))

	checker := NewReleaseChecker(NewDownloadManager(dataDir, "", zerolog.Nop()), zerolog.Nop())
	checker.Refresh(context.Background(), config, "signet")

	check, ok := checker.Check(config, "signet")
	require.True(t, ok)
	assert.Equal(t, "/assets/zside.zip", assetPath, "the probe must hit the resolved asset")
	assert.True(t, check.UpdateAvailable())
}

// A Core variant change resolves a different binary. The previous variant's
// timestamps describe a file the user no longer runs, so Status must show
// nothing until the next probe rather than the old variant's answer.
func TestReleaseCheckerDropsTheCheckWhenTheVariantChanges(t *testing.T) {
	published := time.Date(2026, 8, 6, 17, 44, 0, 0, time.UTC)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Last-Modified", published.Format(http.TimeFormat))
	}))
	defer server.Close()

	dataDir := t.TempDir()
	downloads := NewDownloadManager(dataDir, "", zerolog.Nop())
	config := BinaryConfig{Name: "bitcoind", BinaryName: "bitcoind", IsBitcoinCore: true, ChainLayer: 1}

	newVariant := func(id string) CoreVariantSpec {
		return CoreVariantSpec{
			ID:      id,
			BaseURL: server.URL + "/",
			Files:   map[string]string{currentPlatform(): "L1-bitcoin-" + id + "-latest.zip"},
		}
	}

	patched := newVariant("patched")
	downloads.CoreVariant = func() (CoreVariantSpec, bool) { return patched, true }

	binPath := CoreBinaryPath(dataDir, patched, config.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(binPath), 0o755))
	require.NoError(t, os.WriteFile(binPath, []byte("core"), 0o755))
	require.NoError(t, os.Chtimes(binPath, published.Add(-time.Hour), published.Add(-time.Hour)))

	checker := NewReleaseChecker(downloads, zerolog.Nop())
	checker.Refresh(context.Background(), config, "signet")

	check, ok := checker.Check(config, "signet")
	require.True(t, ok)
	require.True(t, check.UpdateAvailable())

	// The user picks another variant. Nothing probed it yet.
	knots := newVariant("knots")
	downloads.CoreVariant = func() (CoreVariantSpec, bool) { return knots, true }

	_, ok = checker.Check(config, "signet")
	assert.False(t, ok, "the patched variant's check must not describe knots")
}

// Run reads the network on every tick. A swap must reach the next probe, and a
// snapshot taken at startup would keep the daemon on the old network's URL
// until a restart.
func TestReleaseCheckerRunFollowsANetworkSwap(t *testing.T) {
	var mu sync.Mutex
	var probed []string
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		probed = append(probed, r.URL.Path)
		mu.Unlock()
		w.Header().Set("Last-Modified", time.Now().UTC().Format(http.TimeFormat))
	}))
	defer server.Close()

	dataDir := t.TempDir()
	downloads := NewDownloadManager(dataDir, "", zerolog.Nop())
	config := releaseTestConfig(server.URL + "/")

	network := "signet"
	networkOf := func() string { return network }

	checker := NewReleaseChecker(downloads, zerolog.Nop())
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Run probes one time before it waits on the ticker, so a single call is
	// one full pass over the configs.
	go checker.Run(ctx, func() []BinaryConfig { return []BinaryConfig{config} }, networkOf)

	require.Eventually(t, func() bool {
		mu.Lock()
		defer mu.Unlock()
		return len(probed) > 0
	}, 2*time.Second, 10*time.Millisecond)

	network = "regtest"
	checker.Refresh(ctx, config, networkOf())

	check, ok := checker.Check(config, "regtest")
	require.True(t, ok, "a refresh after the swap must answer for the new network")
	assert.False(t, check.Remote.IsZero())
}
