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

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestExtractZip(t *testing.T) {
	dm, dir := newTestDownloadManager(t)

	zipPath := filepath.Join(dir, "test.zip")
	makeZipFile(t, zipPath, map[string][]byte{
		"test-binary-0.1.0-x86_64-unknown-linux-gnu": []byte("hello"),
	})

	require.NoError(t, dm.extractZip(zipPath, BinDir(dir), "test-binary"))

	got, err := os.ReadFile(filepath.Join(BinDir(dir), "test-binary"))
	require.NoError(t, err)
	assert.Equal(t, "hello", string(got))
}

func TestExtractTarGz(t *testing.T) {
	dm, dir := newTestDownloadManager(t)

	archivePath := filepath.Join(dir, "test.tar.gz")
	makeTarGzFile(t, archivePath, map[string][]byte{
		"grpcurl_1.9.1_linux_x86_64/grpcurl": []byte("binary"),
		"grpcurl_1.9.1_linux_x86_64/LICENSE":  []byte("MIT"),
	})

	require.NoError(t, dm.extractTarGz(archivePath, BinDir(dir), "grpcurl"))

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

	require.NoError(t, dm.extractZip(zipPath, BinDir(dir), "thunder"))

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
		DownloadURL:    srv.URL + "/",
		Files:          map[string]string{currentOS(): "test-binary.zip"},
	}, true)
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
		DownloadURL:    srv.URL + "/releases/latest",
		Files:          map[string]string{currentOS(): `grpcurl_\d+\.\d+\.\d+_` + osPattern + `_x86_64\.zip`},
	}, true)
	require.NoError(t, err)

	last := drainProgress(t, ch)
	assert.True(t, last.Done)
}

func TestDownload_SkipsWhenExists(t *testing.T) {
	dm, dir := newTestDownloadManager(t)

	binPath := BinaryPath(dir, "thunder")
	require.NoError(t, os.MkdirAll(filepath.Dir(binPath), 0o755))
	require.NoError(t, os.WriteFile(binPath, []byte("existing"), 0o755))

	ch, err := dm.Download(context.Background(), DefaultThunder(), false)
	require.NoError(t, err)

	last := drainProgress(t, ch)
	assert.True(t, last.Done)
	assert.Equal(t, "already downloaded", last.Message)
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
