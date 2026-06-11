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
		Files:           map[string]string{currentPlatform(): prodFile},
		AltBinaryName:   binName,
		AltDownloadURLs: map[string]string{"default": baseURL},
		AltFiles:        map[string]string{currentPlatform(): altFile},
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
			FileName:   fileForPlatform(c.AltFiles),
		}, true
	}

	ch, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	last := drainProgress(t, ch)
	assert.True(t, last.Done)
	assert.Equal(t, "/thunder-test.zip", requested)

	// Test build lands under bin/test/<binary>/<binary> — Flutter app
	// archives need a per-binary namespace for their lib/data trees, so
	// every test sidechain extracts into its own subdirectory and the
	// resolver finds the binary inside.
	expected := TestSidechainBinaryPath(dir, "thunder")
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
			FileName:   fileForPlatform(c.AltFiles),
		}, true
	}
	ch2, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	drainProgress(t, ch2)

	// Both binaries on disk.
	prod, err := os.ReadFile(filepath.Join(BinDir(dir), binName))
	require.NoError(t, err)
	assert.Equal(t, "prod-bin", string(prod))

	test, err := os.ReadFile(TestSidechainBinaryPath(dir, "thunder"))
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
		Files:           map[string]string{currentPlatform(): "thunder.zip"},
		AltBinaryName:   "thunder",
		AltDownloadURLs: map[string]string{"default": srv.URL + "/test/"},
		AltFiles:        map[string]string{currentPlatform(): "thunder.zip"},
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

	// Test build lives under bin/test/<binary>/<binary>.
	got, err := os.ReadFile(TestSidechainBinaryPath(dataDir, "thunder"))
	require.NoError(t, err)
	assert.Equal(t, "test-bin", string(got))
	// Per-binary directory exists.
	scDir, err := os.Stat(TestSidechainDir(dataDir, "thunder"))
	require.NoError(t, err)
	assert.True(t, scDir.IsDir())

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

// TestDownload_ForceBackend_BypassesVariant proves that DownloadOptions.ForceBackend
// overrides an active SidechainVariant resolver: the prod URL is hit and the
// binary lands in the BinDir root, exactly as if the resolver were absent.
// This is the path used by sidechain Flutter frontends self-booting their
// backend — they don't want UseTestSidechains to swap in a Flutter bundle.
func TestDownload_ForceBackend_BypassesVariant(t *testing.T) {
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
	// Resolver active (mimics UseTestSidechains=true).
	dm.SidechainVariant = func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{
			BinaryName: c.AltBinaryName,
			BaseURL:    c.AltBaseURL("default"),
			FileName:   fileForPlatform(c.AltFiles),
		}, true
	}

	ch, err := dm.DownloadWithOptions(context.Background(), cfg, "default", true, DownloadOptions{ForceBackend: true})
	require.NoError(t, err)
	last := drainProgress(t, ch)
	assert.True(t, last.Done)
	assert.Equal(t, "/thunder-prod.zip", requested, "ForceBackend must hit prod URL even with resolver active")

	// Prod binary lands in BinDir root, NOT under bin/test/.
	prod, err := os.ReadFile(filepath.Join(BinDir(dir), binName))
	require.NoError(t, err)
	assert.Equal(t, "prod-bin", string(prod))

	_, err = os.Stat(TestSidechainBinaryPath(dir, "thunder"))
	assert.True(t, os.IsNotExist(err), "ForceBackend must not extract into the test subfolder")
}

// TestProcess_ForceBackend_BypassesVariant proves the same bypass on the
// process side: resolvePaths must return the BinDir-root path (and no
// "-test" PID suffix) when forceBackend=true, even with the resolver active.
func TestProcess_ForceBackend_BypassesVariant(t *testing.T) {
	dataDir := t.TempDir()
	pm := NewProcessManager(dataDir, nil, testLogger(t))
	cfg := makeSidechainConfig("http://example.invalid/")

	pm.SidechainVariant = func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{BinaryName: c.AltBinaryName}, true
	}

	// Default: resolver wins → test path + "-test" PID name.
	binPath, pidName := pm.resolvePaths(cfg, false)
	assert.Equal(t, TestSidechainBinaryPath(dataDir, "thunder"), binPath)
	assert.Equal(t, "thunder-test", pidName)

	// ForceBackend: resolver skipped → prod path + plain PID name.
	binPath, pidName = pm.resolvePaths(cfg, true)
	assert.Equal(t, BinaryPath(dataDir, "thunder"), binPath)
	assert.Equal(t, "thunder", pidName)
}

func TestOrchestrator_ForceBackend_AdoptsProdPidWhenTestSidechainsEnabled(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("uses symlinked system sleep binary")
	}

	dataDir := t.TempDir()
	bwDir := t.TempDir()
	log := testLogger(t)

	symlinkSystemBinary(t, dataDir, "sleep")
	cfg := makeSidechainConfig("http://example.invalid/")
	cfg.BinaryName = "sleep"
	cfg.AltBinaryName = "sleep"

	pm := NewProcessManager(dataDir, NewPidFileManager(dataDir, log), log)
	pid, err := pm.StartWithOptions(context.Background(), cfg, []string{"30"}, nil, ProcessStartOptions{ForceBackend: true})
	require.NoError(t, err)
	require.NotZero(t, pid)
	t.Cleanup(func() { _ = pm.Stop(context.Background(), cfg.Name, true) })

	o := New(dataDir, "signet", bwDir, []BinaryConfig{cfg}, log)
	_, err = o.Settings.SetUseTestSidechains(true)
	require.NoError(t, err)
	require.True(t, o.UseTestSidechains())

	require.NoError(t, o.AdoptOrphans(context.Background()))
	require.True(t, o.process.IsRunning(cfg.Name), "prod PID should be adopted as force-backend fallback while test sidechains are enabled")

	status := o.Status(cfg.Name)
	assert.True(t, status.Running)
	assert.True(t, status.Downloaded)
	assert.Equal(t, BinaryPath(dataDir, "sleep"), status.BinaryPath)
}

func TestOrchestrator_StopStopsManagedSidechainGUICompanion(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("uses symlinked system sleep binary")
	}

	dataDir := t.TempDir()
	bwDir := t.TempDir()
	log := testLogger(t)

	symlinkSystemBinary(t, dataDir, "sleep")
	cfg := makeSidechainConfig("http://example.invalid/")
	cfg.BinaryName = "sleep"
	cfg.AltBinaryName = "sleep"

	o := New(dataDir, "signet", bwDir, []BinaryConfig{cfg}, log)
	guiName := sidechainGUIProcessName(cfg.Name)

	_, err := o.process.StartWithOptions(
		context.Background(),
		cfg,
		[]string{"30"},
		nil,
		ProcessStartOptions{
			ForceBackend: true,
			ProcessName:  guiName,
			PidName:      guiName,
			WorkDir:      dataDir,
		},
	)
	require.NoError(t, err)
	t.Cleanup(func() { _ = o.process.Stop(context.Background(), guiName, true) })

	assert.True(t, o.process.IsRunning(guiName))
	assert.False(t, o.process.IsRunning(cfg.Name), "GUI companion must not occupy the backend daemon slot")

	_, err = o.process.StartWithOptions(
		context.Background(),
		cfg,
		[]string{"30"},
		nil,
		ProcessStartOptions{ForceBackend: true},
	)
	require.NoError(t, err)
	t.Cleanup(func() { _ = o.process.Stop(context.Background(), cfg.Name, true) })

	require.NoError(t, o.Stop(context.Background(), cfg.Name, false))
	assert.False(t, o.process.IsRunning(guiName), "Stop(sidechain) must stop the managed GUI companion")
	assert.False(t, o.process.IsRunning(cfg.Name), "Stop(sidechain) must stop the backend daemon")
}

func TestOrchestrator_AdoptsGUICompanionUnderGUISlot(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("uses symlinked system sleep binary")
	}

	dataDir := t.TempDir()
	log := testLogger(t)

	symlinkSystemBinary(t, dataDir, "sleep")
	cfg := makeSidechainConfig("http://example.invalid/")
	cfg.Name = "sleep"
	cfg.BinaryName = "sleep"
	cfg.AltBinaryName = "sleep"
	guiName := sidechainGUIProcessName(cfg.Name)

	origin := New(dataDir, "signet", t.TempDir(), []BinaryConfig{cfg}, log)
	_, err := origin.process.StartWithOptions(
		context.Background(),
		cfg,
		[]string{"30"},
		nil,
		ProcessStartOptions{
			ForceBackend: true,
			ProcessName:  guiName,
			PidName:      guiName,
			WorkDir:      dataDir,
		},
	)
	require.NoError(t, err)
	t.Cleanup(func() { _ = origin.process.Stop(context.Background(), guiName, true) })

	next := New(dataDir, "signet", t.TempDir(), []BinaryConfig{cfg}, log)
	require.NoError(t, next.AdoptOrphans(context.Background()))

	assert.True(t, next.process.IsRunning(guiName), "GUI PID must be adopted under the GUI companion slot")
	assert.False(t, next.process.IsRunning(cfg.Name), "adopted GUI must not occupy the backend daemon slot")

	require.NoError(t, next.Stop(context.Background(), cfg.Name, false))
	assert.False(t, next.process.IsRunning(guiName))
	_, err = next.pidManager.ReadPidFile(guiName)
	assert.True(t, os.IsNotExist(err), "stopping adopted GUI companion must remove its PID file")
}

func TestOrchestrator_SidechainVariantResolver_ReturnsAltOnlyWhenEnabled(t *testing.T) {
	dataDir := t.TempDir()
	bwDir := t.TempDir()
	o := New(dataDir, "signet", bwDir, AllDefaults(), testLogger(t))

	// Pick the first layer-2 chain that has alt fields.
	var sample BinaryConfig
	for _, c := range o.Configs() {
		if c.ChainLayer == 2 && c.AltBinaryName != "" && fileForPlatform(c.AltFiles) != "" {
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
	assert.Equal(t, fileForPlatform(sample.AltFiles), spec.FileName)
	assert.Equal(t, sample.AltBaseURL(o.Network), spec.BaseURL)

	// Toggle on, but bitcoind (layer 1) must still be ineligible.
	core, ok := o.Configs()["bitcoind"]
	require.True(t, ok)
	_, ok = o.process.SidechainVariant(core)
	assert.False(t, ok, "layer-1 configs must never resolve to a sidechain variant")
}
