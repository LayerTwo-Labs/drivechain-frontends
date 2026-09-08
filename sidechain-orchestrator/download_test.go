package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestExtractZip(t *testing.T) {
	dm, dir := newTestDownloadManager(t)

	zipPath := filepath.Join(dir, "test.zip")
	makeZipFile(t, zipPath, map[string][]byte{
		"test-binary-0.1.0-x86_64-unknown-linux-gnu": []byte("hello"),
	})

	hasCLI, err := dm.extractZip(zipPath, BinDir(dir), "test-binary")
	require.NoError(t, err)
	assert.False(t, hasCLI)

	got, err := os.ReadFile(filepath.Join(BinDir(dir), "test-binary"))
	require.NoError(t, err)
	assert.Equal(t, "hello", string(got))
}

func TestExtractZip_DetectsCLI(t *testing.T) {
	dm, dir := newTestDownloadManager(t)

	zipPath := filepath.Join(dir, "thunder-bundle.zip")
	makeZipFile(t, zipPath, map[string][]byte{
		"release/thunder-latest-x86_64-apple-darwin":     []byte("main"),
		"release/thunder-cli-latest-x86_64-apple-darwin": []byte("cli"),
	})

	hasCLI, err := dm.extractZip(zipPath, BinDir(dir), "thunder")
	require.NoError(t, err)
	assert.True(t, hasCLI)

	_, err = os.Stat(filepath.Join(BinDir(dir), "thunder"))
	require.NoError(t, err)
	_, err = os.Stat(filepath.Join(BinDir(dir), "thunder-cli"))
	require.NoError(t, err)
}

func TestExtractZip_RawBinaryNoCliCase(t *testing.T) {
	dm, dir := newTestDownloadManager(t)

	zipPath := filepath.Join(dir, "truthcoin-bundle.zip")
	makeZipFile(t, zipPath, map[string][]byte{
		"truthcoin-latest-x86_64-apple-darwin": []byte("main"),
	})

	hasCLI, err := dm.extractZip(zipPath, BinDir(dir), "truthcoin")
	require.NoError(t, err)
	assert.False(t, hasCLI)

	_, err = os.Stat(filepath.Join(BinDir(dir), "truthcoin"))
	require.NoError(t, err)
	_, err = os.Stat(filepath.Join(BinDir(dir), "truthcoin-cli"))
	assert.True(t, os.IsNotExist(err))
}

func TestExtractTarGz(t *testing.T) {
	dm, dir := newTestDownloadManager(t)

	archivePath := filepath.Join(dir, "test.tar.gz")
	makeTarGzFile(t, archivePath, map[string][]byte{
		"grpcurl_1.9.1_linux_x86_64/grpcurl": []byte("binary"),
		"grpcurl_1.9.1_linux_x86_64/LICENSE": []byte("MIT"),
	})

	hasCLI, err := dm.extractTarGz(archivePath, BinDir(dir), "grpcurl")
	require.NoError(t, err)
	assert.False(t, hasCLI)

	got, err := os.ReadFile(filepath.Join(BinDir(dir), "grpcurl"))
	require.NoError(t, err)
	assert.Equal(t, "binary", string(got))

	// LICENSE should be skipped
	_, err = os.Stat(filepath.Join(BinDir(dir), "LICENSE"))
	assert.True(t, os.IsNotExist(err))
}

func TestExtractZip_FlattensNestedDir(t *testing.T) {
	dm, dir := newTestDownloadManager(t)

	zipPath := filepath.Join(dir, "nested.zip")
	makeZipFile(t, zipPath, map[string][]byte{
		"release-v1.0/thunder": []byte("thunder-binary"),
	})

	hasCLI, err := dm.extractZip(zipPath, BinDir(dir), "thunder")
	require.NoError(t, err)
	assert.False(t, hasCLI)

	got, err := os.ReadFile(filepath.Join(BinDir(dir), "thunder"))
	require.NoError(t, err)
	assert.Equal(t, "thunder-binary", string(got))
}

func TestDownload_Direct(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	zipContent := makeZipBytes(t, map[string][]byte{"test-binary": []byte("data")})

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(zipContent)))
		_, _ = w.Write(zipContent)
	}))
	defer srv.Close()
	dm.httpClient = srv.Client()

	ch, err := dm.Download(context.Background(), BinaryConfig{
		Name:           "test",
		BinaryName:     "test-binary",
		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": srv.URL + "/"},
		Files:          map[string]string{currentPlatform(): "test-binary.zip"},
	}, "default", true)
	require.NoError(t, err)

	last := drainProgress(t, ch)
	assert.True(t, last.Done)
	_, err = os.Stat(BinaryPath(dir, "test-binary"))
	require.NoError(t, err)
}

func TestDownload_GitHub(t *testing.T) {
	dm, _ := newTestDownloadManager(t)
	zipContent := makeZipBytes(t, map[string][]byte{"grpcurl": []byte("binary")})

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/releases/latest":
			_ = json.NewEncoder(w).Encode(map[string]any{
				"assets": []map[string]any{
					{"name": "grpcurl_1.9.1_linux_x86_64.zip", "browser_download_url": "http://" + r.Host + "/dl/grpcurl.zip"},
					{"name": "grpcurl_1.9.1_osx_x86_64.zip", "browser_download_url": "http://" + r.Host + "/dl/grpcurl.zip"},
					{"name": "grpcurl_1.9.1_windows_x86_64.zip", "browser_download_url": "http://" + r.Host + "/dl/grpcurl.zip"},
				},
			})
		default:
			w.Header().Set("Content-Length", fmt.Sprintf("%d", len(zipContent)))
			_, _ = w.Write(zipContent)
		}
	}))
	defer srv.Close()
	dm.httpClient = srv.Client()

	osPattern := map[string]string{
		"linux": "linux", "macos": "osx", "windows": "windows",
	}[currentOS()]

	ch, err := dm.Download(context.Background(), BinaryConfig{
		Name:           "grpcurl",
		BinaryName:     "grpcurl",
		DownloadSource: DownloadSourceGitHub,
		DownloadURLs:   map[string]string{"default": srv.URL + "/releases/latest"},
		Files:          map[string]string{currentPlatform(): `grpcurl_\d+\.\d+\.\d+_` + osPattern + `_x86_64\.zip`},
	}, "default", true)
	require.NoError(t, err)

	last := drainProgress(t, ch)
	assert.True(t, last.Done)
}

func TestDownload_SkipsWhenExists(t *testing.T) {
	dm, dir := newTestDownloadManager(t)

	binPath := BinaryPath(dir, "thunder")
	require.NoError(t, os.MkdirAll(filepath.Dir(binPath), 0o755))
	require.NoError(t, os.WriteFile(binPath, []byte("existing"), 0o755))

	thunderCfg, ok := BinaryConfigByName("thunder")
	require.True(t, ok, "thunder config must exist")
	ch, err := dm.Download(context.Background(), thunderCfg, "default", false)
	require.NoError(t, err)

	last := drainProgress(t, ch)
	assert.True(t, last.Done)
	assert.Equal(t, binPath, last.Message)
}

// drainProgress reads all progress from a channel, failing on errors.
func drainProgress(t *testing.T, ch <-chan DownloadProgress) DownloadProgress {
	t.Helper()
	var last DownloadProgress
	for p := range ch {
		if p.Error != nil {
			t.Fatalf("download error: %v", p.Error)
		}
		last = p
	}
	return last
}

func TestStripPlatformSuffix(t *testing.T) {
	tests := []struct {
		input, want string
	}{
		// GitHub-style: version + platform
		{"thunder-orchard-0.1.0-x86_64-apple-darwin", "thunder-orchard"},
		{"thunder-orchard-0.1.0-x86_64-unknown-linux-gnu", "thunder-orchard"},

		// Underscore-separated (grpcurl)
		{"grpcurl_1.9.1_linux_x86_64", "grpcurl"},
		{"grpcurl_1.9.1_osx_x86_64", "grpcurl"},
		{"grpcurl_1.9.1_windows_x86_64", "grpcurl"},

		// Direct releases (no version, just platform) — "-latest" is stripped
		{"bip300301-enforcer-latest-x86_64-unknown-linux-gnu", "bip300301-enforcer"},
		{"L1-bitcoin-patched-latest-x86_64-apple-darwin", "L1-bitcoin-patched"},

		// Already clean
		{"bitcoind", "bitcoind"},
		{"thunder", "thunder"},

		// Extensions stripped
		{"grpcurl_1.9.1_linux_x86_64.tar.gz", "grpcurl"},
		{"thunder.exe", "thunder"},

		// Empty
		{"", ""},
	}
	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T) {
			assert.Equal(t, tt.want, StripPlatformSuffix(tt.input))
		})
	}
}

// ReleaseChecker probes every binary every 10 minutes, and seven of them read
// api.github.com. An unauthenticated caller gets 60 requests an hour per IP,
// so one release must answer many patterns from one fetch.
func TestResolveGitHubURLCachesOneRelease(t *testing.T) {
	var calls int
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		calls++
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"assets":[
			{"name":"photon-0.17.2-x86_64-unknown-linux-gnu.zip","browser_download_url":"https://example.invalid/linux.zip"},
			{"name":"photon-0.17.2-aarch64-apple-darwin.zip","browser_download_url":"https://example.invalid/arm.zip"}
		]}`))
	}))
	defer srv.Close()

	dm, _ := newTestDownloadManager(t)
	ctx := context.Background()

	linux, err := dm.resolveGitHubURL(ctx, srv.URL, `photon-\d+\.\d+\.\d+-x86_64-unknown-linux-gnu\.zip`)
	require.NoError(t, err)
	assert.Equal(t, "https://example.invalid/linux.zip", linux)

	arm, err := dm.resolveGitHubURL(ctx, srv.URL, `photon-\d+\.\d+\.\d+-aarch64-apple-darwin\.zip`)
	require.NoError(t, err)
	assert.Equal(t, "https://example.invalid/arm.zip", arm)

	assert.Equal(t, 1, calls, "the second pattern must read the cached release")
}

// A stale entry must not answer, or a new release never reaches the user.
func TestResolveGitHubURLRefetchesAStaleRelease(t *testing.T) {
	var calls int
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		calls++
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"assets":[
			{"name":"photon-0.17.2-x86_64-unknown-linux-gnu.zip","browser_download_url":"https://example.invalid/linux.zip"}
		]}`))
	}))
	defer srv.Close()

	dm, _ := newTestDownloadManager(t)
	pattern := `photon-\d+\.\d+\.\d+-x86_64-unknown-linux-gnu\.zip`

	_, err := dm.resolveGitHubURL(context.Background(), srv.URL, pattern)
	require.NoError(t, err)

	dm.releases.Store(srv.URL, githubRelease{
		assets:  []githubAsset{{Name: "stale.zip"}},
		fetched: time.Now().Add(-githubReleaseTTL - time.Minute),
	})

	_, err = dm.resolveGitHubURL(context.Background(), srv.URL, pattern)
	require.NoError(t, err)
	assert.Equal(t, 2, calls, "a stale release must be read again")
}

// A miss must not poison the cache into answering for a pattern no asset has.
func TestResolveGitHubURLReportsAPatternNoAssetMatches(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"assets":[{"name":"photon-0.17.2-x86_64-unknown-linux-gnu.zip"}]}`))
	}))
	defer srv.Close()

	dm, _ := newTestDownloadManager(t)
	_, err := dm.resolveGitHubURL(context.Background(), srv.URL, `nothing-matches\.zip`)
	require.Error(t, err)
}
