package orchestrator

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A caller waits for a backend another caller downloads, then fetches the
// app. It holds no claim while it waits, so two callers cannot deadlock.
func TestDownload_WaitsForABusyBackend(t *testing.T) {
	binName := "thunder"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	archive := makeZipBytes(t, map[string][]byte{binName: []byte("test-bin")})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write(archive)
	}))
	defer srv.Close()

	dm, _ := newTestDownloadManager(t)
	dm.httpClient = srv.Client()
	cfg := makeSidechainConfig(srv.URL + "/")
	dm.SidechainVariant = testSidechainResolver

	targets := dm.Targets(cfg, "default", DownloadOptions{})
	require.Len(t, targets, 2)
	app, backend := targets[0], targets[1]

	backendClaim := &inFlightClaim{target: backend, done: make(chan struct{})}
	dm.inFlight.Store(backend.InFlightKey, backendClaim)

	ch, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)

	require.Never(t, func() bool {
		_, held := dm.inFlight.Load(app.InFlightKey)
		return held
	}, 200*time.Millisecond, 10*time.Millisecond, "a caller holds no claim while it waits")

	writeBinary(t, backend.BinPath, "prod-bin")
	dm.inFlight.Delete(backend.InFlightKey)
	close(backendClaim.done)

	last := drainProgress(t, ch)
	assert.True(t, last.Done)
}

// A sidechain update installs the app and the backend together. When one
// download fails, both installed parts stay as they were.
func TestDownload_KeepsBothPartsWhenOneDownloadFails(t *testing.T) {
	binName := "thunder"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	archive := makeZipBytes(t, map[string][]byte{binName: []byte("new-bin")})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/thunder-prod.zip" {
			http.NotFound(w, r)
			return
		}
		_, _ = w.Write(archive)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()
	cfg := makeSidechainConfig(srv.URL + "/")
	dm.SidechainVariant = testSidechainResolver

	appPath := TestSidechainBinaryPath(dir, "thunder")
	backendPath := BinaryPath(dir, "thunder")
	writeBinary(t, appPath, "old-app")
	writeBinary(t, backendPath, "old-backend")

	ch, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	require.Error(t, finalProgress(ch).Error)

	assertBinary(t, appPath, "old-app")
	assertBinary(t, backendPath, "old-backend")
}

// A caller that waits on a part the owner never downloaded gets the owner's
// failure, not the old binary on disk.
func TestDownload_WaiterGetsTheOwnersFailure(t *testing.T) {
	binName := "thunder"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	archive := makeZipBytes(t, map[string][]byte{binName: []byte("new-bin")})
	gate := make(chan struct{})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/thunder-test.zip" {
			<-gate
			http.NotFound(w, r)
			return
		}
		_, _ = w.Write(archive)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()
	cfg := makeSidechainConfig(srv.URL + "/")
	dm.SidechainVariant = testSidechainResolver
	writeBinary(t, BinaryPath(dir, "thunder"), "old-backend")

	owner, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	waiter, err := dm.DownloadWithOptions(context.Background(), cfg, "default", true, DownloadOptions{ForceBackend: true})
	require.NoError(t, err)
	close(gate)

	require.Error(t, finalProgress(owner).Error)
	require.Error(t, finalProgress(waiter).Error, "the old backend is not a finished download")
}

// A waiter checks its own binary path, not the path of the owner it waited on.
func TestDownload_WaiterChecksItsOwnPath(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	cfg := BinaryConfig{
		Name:           "waittest",
		BinaryName:     "waittest",
		DownloadSource: DownloadSourceDirect,
		Files:          map[string]string{currentPlatform(): "waittest.zip"},
		DownloadURLs:   map[string]string{"default": "http://example.invalid/"},
	}

	ownerPath := filepath.Join(dir, "owner-binary")
	writeBinary(t, ownerPath, "owner")
	owner := &inFlightClaim{target: DownloadTarget{InFlightKey: cfg.Name, BinPath: ownerPath}, done: make(chan struct{})}
	close(owner.done)
	dm.inFlight.Store(cfg.Name, owner)

	ch, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	require.Error(t, finalProgress(ch).Error, "the waiter's own binary is missing")
}

func testSidechainResolver(c BinaryConfig) (sidechainVariantSpec, bool) {
	return sidechainVariantSpec{
		BinaryName: c.AltBinaryName,
		BaseURL:    c.AltBaseURL("default"),
		FileName:   fileForPlatform(c.AltFiles),
	}, true
}

func writeBinary(t *testing.T, path, content string) {
	t.Helper()
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, []byte(content), 0o755))
}

func assertBinary(t *testing.T, path, content string) {
	t.Helper()
	got, err := os.ReadFile(path)
	require.NoError(t, err)
	assert.Equal(t, content, string(got))
}

// finalProgress reads the channel to its end and returns the last event.
func finalProgress(ch <-chan DownloadProgress) DownloadProgress {
	var last DownloadProgress
	for p := range ch {
		last = p
	}
	return last
}

// A part that could not land is a failed update, not a finished one. The old
// warning let the caller record a version the disk never got.
func TestMoveExtractedBinaries_FailsWhenAPartCannotLand(t *testing.T) {
	dm, dataDir := newTestDownloadManager(t)
	tmpDir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(tmpDir, "thunder"), []byte("new"), 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(tmpDir, "thunder-cli"), []byte("new"), 0o755))

	destDir := BinDir(dataDir)
	require.NoError(t, os.MkdirAll(filepath.Join(destDir, "thunder", "held"), 0o755))

	_, err := dm.moveExtractedBinaries(tmpDir, destDir, "thunder")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "thunder")
}
