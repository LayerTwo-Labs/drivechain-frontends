package orchestrator

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// makeSidechainConfig returns a synthetic layer-2 BinaryConfig with both prod
// and alternative download fields populated, served from baseURL.
func makeSidechainConfig(baseURL string) BinaryConfig {
	binName := "thunder"
	prodFile := "thunder-prod.zip"
	altFile := "thunder-test.zip"
	return BinaryConfig{
		Name:            "thunder",
		BinaryName:      binName,
		ChainLayer:      2,
		Slot:            9,
		DownloadSource:  DownloadSourceDirect,
		DownloadURLs:    map[string]string{"default": baseURL},
		Files:           map[string]string{currentOS(): prodFile},
		AltBinaryName:   binName,
		AltDownloadURLs: map[string]string{"default": baseURL},
		AltFiles:        map[string]string{currentOS(): altFile},
	}
}

func TestDownload_SidechainVariant_HitsAltURL(t *testing.T) {
	binName := "thunder"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	prodArchive := makeZipBytes(t, map[string][]byte{binName: []byte("prod-bin")})
	testArchive := makeZipBytes(t, map[string][]byte{binName: []byte("test-bin")})

	var requested string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requested = r.URL.Path
		switch r.URL.Path {
		case "/thunder-test.zip":
			w.Header().Set("Content-Length", fmt.Sprintf("%d", len(testArchive)))
			_, _ = w.Write(testArchive)
		case "/thunder-prod.zip":
			w.Header().Set("Content-Length", fmt.Sprintf("%d", len(prodArchive)))
			_, _ = w.Write(prodArchive)
		default:
			http.NotFound(w, r)
		}
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	cfg := makeSidechainConfig(srv.URL + "/")
	dm.SidechainVariant = func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{
			BinaryName: c.AltBinaryName,
			BaseURL:    c.AltBaseURL("default"),
			FileName:   c.AltFiles[currentOS()],
		}, true
	}

	ch, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	last := drainProgress(t, ch)
	assert.True(t, last.Done)
	assert.Equal(t, "/thunder-test.zip", requested)

	// Test build lands under bin/test/, prod path stays empty.
	expected := filepath.Join(BinDir(dir), "test", binName)
	got, err := os.ReadFile(expected)
	require.NoError(t, err)
	assert.Equal(t, "test-bin", string(got))

	_, err = os.Stat(filepath.Join(BinDir(dir), binName))
	assert.True(t, os.IsNotExist(err), "must not write thunder to BinDir root when test variant is active")
}

func TestDownload_SidechainVariant_FallsBackToProd(t *testing.T) {
	binName := "thunder"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	prodArchive := makeZipBytes(t, map[string][]byte{binName: []byte("prod-bin")})

	var requested string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requested = r.URL.Path
		_, _ = w.Write(prodArchive)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	cfg := makeSidechainConfig(srv.URL + "/")
	// No SidechainVariant resolver set: must hit prod URL and land in BinDir root.

	ch, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	last := drainProgress(t, ch)
	assert.True(t, last.Done)
	assert.Equal(t, "/thunder-prod.zip", requested)

	expected := filepath.Join(BinDir(dir), binName)
	got, err := os.ReadFile(expected)
	require.NoError(t, err)
	assert.Equal(t, "prod-bin", string(got))

	_, err = os.Stat(filepath.Join(BinDir(dir), "test", binName))
	assert.True(t, os.IsNotExist(err))
}

func TestDownload_SidechainVariant_CoexistsWithProd(t *testing.T) {
	binName := "thunder"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	prodArchive := makeZipBytes(t, map[string][]byte{binName: []byte("prod-bin")})
	testArchive := makeZipBytes(t, map[string][]byte{binName: []byte("test-bin")})

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/thunder-test.zip":
			_, _ = w.Write(testArchive)
		case "/thunder-prod.zip":
			_, _ = w.Write(prodArchive)
		default:
			http.NotFound(w, r)
		}
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()
	cfg := makeSidechainConfig(srv.URL + "/")

	// First fetch prod (no resolver).
	ch, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	drainProgress(t, ch)

	// Now flip on the resolver and fetch the test build.
	dm.SidechainVariant = func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{
			BinaryName: c.AltBinaryName,
			BaseURL:    c.AltBaseURL("default"),
			FileName:   c.AltFiles[currentOS()],
		}, true
	}
	ch2, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	drainProgress(t, ch2)

	// Both binaries on disk.
	prod, err := os.ReadFile(filepath.Join(BinDir(dir), binName))
	require.NoError(t, err)
	assert.Equal(t, "prod-bin", string(prod))

	test, err := os.ReadFile(filepath.Join(BinDir(dir), "test", binName))
	require.NoError(t, err)
	assert.Equal(t, "test-bin", string(test))
}

func TestOrchestrator_SetTestSidechains_PersistsAndWipes(t *testing.T) {
	dataDir := t.TempDir()
	bwDir := t.TempDir()
	o := New(dataDir, "signet", bwDir, AllDefaults(), testLogger(t))

	// Drop a stub binary in the prod path for every layer-2 chain so we can
	// prove the wipe ran. Also stub a test-path binary for the same reason.
	var l2 []BinaryConfig
	for _, c := range o.Configs() {
		if c.ChainLayer == 2 {
			l2 = append(l2, c)
		}
	}
	require.NotEmpty(t, l2, "embedded config must declare layer-2 binaries")

	for _, c := range l2 {
		prod := BinaryPath(dataDir, c.BinaryName)
		require.NoError(t, os.MkdirAll(filepath.Dir(prod), 0o755))
		require.NoError(t, os.WriteFile(prod, []byte("stub-prod"), 0o755))

		if c.AltBinaryName != "" {
			test := TestSidechainBinaryPath(dataDir, c.AltBinaryName)
			require.NoError(t, os.MkdirAll(filepath.Dir(test), 0o755))
			require.NoError(t, os.WriteFile(test, []byte("stub-test"), 0o755))
		}
	}

	require.NoError(t, o.SetTestSidechains(context.Background(), true))

	// Setting flipped + persisted to disk.
	assert.True(t, o.UseTestSidechains())
	persisted, err := LoadSettings(bwDir)
	require.NoError(t, err)
	assert.True(t, persisted.UseTestSidechains)

	// Both prod and test stubs gone.
	for _, c := range l2 {
		_, err := os.Stat(BinaryPath(dataDir, c.BinaryName))
		assert.True(t, os.IsNotExist(err), "prod path for %s must be wiped", c.Name)
		if c.AltBinaryName != "" {
			_, err := os.Stat(TestSidechainBinaryPath(dataDir, c.AltBinaryName))
			assert.True(t, os.IsNotExist(err), "test path for %s must be wiped", c.Name)
		}
	}
}

func TestOrchestrator_SetTestSidechains_NoOpWhenSame(t *testing.T) {
	dataDir := t.TempDir()
	bwDir := t.TempDir()
	o := New(dataDir, "signet", bwDir, AllDefaults(), testLogger(t))

	// Drop a stub in a layer-2 prod path. A no-op SetTestSidechains(false)
	// must NOT wipe it.
	var sample BinaryConfig
	for _, c := range o.Configs() {
		if c.ChainLayer == 2 {
			sample = c
			break
		}
	}
	prod := BinaryPath(dataDir, sample.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(prod), 0o755))
	require.NoError(t, os.WriteFile(prod, []byte("untouched"), 0o755))

	require.NoError(t, o.SetTestSidechains(context.Background(), false))
	assert.False(t, o.UseTestSidechains())

	got, err := os.ReadFile(prod)
	require.NoError(t, err, "no-op flip must leave existing binaries intact")
	assert.Equal(t, "untouched", string(got))
}

// End-to-end coverage of the test-sidechains toggle: spin up a fake release
// server, drive Download through the orchestrator's resolver, and assert the
// alt URL is hit and the binary lands in the per-test subfolder. Mirrors the
// Core variant fresh-switch integration test for layer-2 binaries.
func TestIntegration_TestSidechains_FreshSwitchHitsAltURL(t *testing.T) {
	binName := "thunder"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	prodArchive := makeZipBytes(t, map[string][]byte{binName: []byte("prod-bin")})
	testArchive := makeZipBytes(t, map[string][]byte{binName: []byte("test-bin")})

	var requested []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requested = append(requested, r.URL.Path)
		switch r.URL.Path {
		case "/test/thunder.zip":
			_, _ = w.Write(testArchive)
		case "/prod/thunder.zip":
			_, _ = w.Write(prodArchive)
		default:
			http.NotFound(w, r)
		}
	}))
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()

	cfg := BinaryConfig{
		Name:            "thunder",
		BinaryName:      "thunder",
		ChainLayer:      2,
		Slot:            9,
		DownloadSource:  DownloadSourceDirect,
		DownloadURLs:    map[string]string{"default": srv.URL + "/prod/"},
		Files:           map[string]string{currentOS(): "thunder.zip"},
		AltBinaryName:   "thunder",
		AltDownloadURLs: map[string]string{"default": srv.URL + "/test/"},
		AltFiles:        map[string]string{currentOS(): "thunder.zip"},
	}
	o := New(dataDir, "signet", bwDir, []BinaryConfig{cfg}, testLogger(t))

	require.NoError(t, o.SetTestSidechains(context.Background(), true))
	assert.True(t, o.UseTestSidechains())

	progress, err := o.Download(context.Background(), "thunder", true)
	require.NoError(t, err)
	last := drainProgress(t, progress)
	assert.True(t, last.Done)

	assert.Contains(t, requested, "/test/thunder.zip", "must hit alt URL when toggle is on")
	assert.NotContains(t, requested, "/prod/thunder.zip")

	// Test build lives under bin/test/.
	got, err := os.ReadFile(TestSidechainBinaryPath(dataDir, "thunder"))
	require.NoError(t, err)
	assert.Equal(t, "test-bin", string(got))

	// Status reports Downloaded=true via the test path.
	status := o.Status("thunder")
	assert.True(t, status.Downloaded)

	// Flip back: prod download must hit the prod URL and land in BinDir root.
	require.NoError(t, o.SetTestSidechains(context.Background(), false))
	progress, err = o.Download(context.Background(), "thunder", true)
	require.NoError(t, err)
	drainProgress(t, progress)

	assert.Contains(t, requested, "/prod/thunder.zip", "must hit prod URL when toggle is off")
	prodGot, err := os.ReadFile(BinaryPath(dataDir, "thunder"))
	require.NoError(t, err)
	assert.Equal(t, "prod-bin", string(prodGot))
}

func TestOrchestrator_SidechainVariantResolver_ReturnsAltOnlyWhenEnabled(t *testing.T) {
	dataDir := t.TempDir()
	bwDir := t.TempDir()
	o := New(dataDir, "signet", bwDir, AllDefaults(), testLogger(t))

	// Pick the first layer-2 chain that has alt fields.
	var sample BinaryConfig
	for _, c := range o.Configs() {
		if c.ChainLayer == 2 && c.AltBinaryName != "" && c.AltFiles[currentOS()] != "" {
			sample = c
			break
		}
	}
	require.NotEmpty(t, sample.Name)

	// Toggle off => resolver returns ok=false (production path).
	_, ok := o.process.SidechainVariant(sample)
	assert.False(t, ok)

	// Toggle on => resolver returns the alt fields.
	require.NoError(t, o.SetTestSidechains(context.Background(), true))
	spec, ok := o.process.SidechainVariant(sample)
	require.True(t, ok)
	assert.Equal(t, sample.AltBinaryName, spec.BinaryName)
	assert.Equal(t, sample.AltFiles[currentOS()], spec.FileName)
	assert.Equal(t, sample.AltBaseURL(o.Network), spec.BaseURL)

	// Toggle on, but bitcoind (layer 1) must still be ineligible.
	core, ok := o.Configs()["bitcoind"]
	require.True(t, ok)
	_, ok = o.process.SidechainVariant(core)
	assert.False(t, ok, "layer-1 configs must never resolve to a sidechain variant")
}
