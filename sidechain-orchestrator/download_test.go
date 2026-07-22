package orchestrator

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
	"context"
	"crypto/sha256"
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

func TestExtractZip_RejectsTraversal(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	archive := filepath.Join(dir, "traversal.zip")
	makeZipFile(t, archive, map[string][]byte{"../outside": []byte("nope")})

	_, err := dm.extractZip(archive, BinDir(dir), "bitnames-tor")
	require.Error(t, err)
	assert.ErrorContains(t, err, "path escapes extraction root")
}

func TestExtractZipPreservingTree_RejectsEscapingSymlink(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	archive := filepath.Join(dir, "symlink.zip")
	f, err := os.Create(archive)
	require.NoError(t, err)
	w := zip.NewWriter(f)
	header := &zip.FileHeader{Name: "bundle/link"}
	header.SetMode(os.ModeSymlink | 0o777)
	entry, err := w.CreateHeader(header)
	require.NoError(t, err)
	_, err = entry.Write([]byte("../../outside"))
	require.NoError(t, err)
	require.NoError(t, w.Close())
	require.NoError(t, f.Close())

	_, err = dm.extractZipPreservingTree(archive, BinDir(dir), "bundle")
	require.Error(t, err)
	assert.ErrorContains(t, err, "target escapes extraction root")
}

func TestValidateZipArchive_RejectsOversizedMetadata(t *testing.T) {
	err := validateZipArchive([]*zip.File{{FileHeader: zip.FileHeader{
		Name:               "bundle/large",
		UncompressedSize64: maxArchiveEntryBytes + 1,
	}}})
	require.Error(t, err)
	assert.ErrorContains(t, err, "expanded size exceeds limit")
}

func TestArchiveDestination_RejectsNonPortablePaths(t *testing.T) {
	for _, name := range []string{`..\outside`, `C:\outside`, `safe:name`, `bundle/NUL`, `bundle/com1.exe`} {
		_, err := archiveDestination(t.TempDir(), name)
		require.Error(t, err, name)
	}
}

func TestExtractTarGz_RejectsOversizedMetadata(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	archive := filepath.Join(dir, "large.tar.gz")
	f, err := os.Create(archive)
	require.NoError(t, err)
	gz := gzip.NewWriter(f)
	tw := tar.NewWriter(gz)
	require.NoError(t, tw.WriteHeader(&tar.Header{Name: "large", Mode: 0o755, Size: int64(maxArchiveEntryBytes) + 1}))
	_ = tw.Close()
	require.NoError(t, gz.Close())
	require.NoError(t, f.Close())

	_, err = dm.extractTarGz(archive, BinDir(dir), "large")
	require.Error(t, err)
	assert.ErrorContains(t, err, "expanded size exceeds limit")
}

func TestExtractBinary_PreservesSidecarBundle(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	archive := filepath.Join(dir, "sidecar.zip")
	makeZipFile(t, archive, map[string][]byte{
		"bitnames-tor/bitnames-tor": []byte("wrapper"),
		"bitnames-tor/tor/tor":      []byte("tor"),
	})
	_, err := dm.extractBinary(archive, BinaryConfig{PreserveArchiveTree: true,
		ExtractSubfolder: map[string]string{currentOS(): "bitnames-tor"}}, "bitnames-tor", "", dir, "default", false)
	require.NoError(t, err)
	for path, want := range map[string]string{"bitnames-tor": "wrapper", filepath.Join("tor", "tor"): "tor"} {
		got, err := os.ReadFile(filepath.Join(BinDir(dir), path))
		require.NoError(t, err)
		assert.Equal(t, want, string(got))
	}
}

func TestExtractBinary_RejectsIncompleteSidecarOverOldInstall(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	old := BinaryPath(dir, "bitnames-tor")
	require.NoError(t, os.MkdirAll(filepath.Dir(old), 0o755))
	require.NoError(t, os.WriteFile(old, []byte("old"), 0o755))
	archive := filepath.Join(dir, "incomplete.zip")
	makeZipFile(t, archive, map[string][]byte{"bitnames-tor/README": []byte("not an executable")})
	_, err := dm.extractBinary(archive, BinaryConfig{PreserveArchiveTree: true,
		ExtractSubfolder: map[string]string{currentOS(): "bitnames-tor"}}, "bitnames-tor", "", dir, "default", false)
	require.Error(t, err)
	assert.ErrorContains(t, err, "missing required executable")
	got, readErr := os.ReadFile(old)
	require.NoError(t, readErr)
	assert.Equal(t, "old", string(got))
}

func TestBitnamesTorConfigRequiresPinnedBundle(t *testing.T) {
	cfg, ok := BinaryConfigByName("bitnames-tor")
	require.True(t, ok)
	assert.True(t, cfg.RequireHash)
	assert.True(t, cfg.PreserveArchiveTree)
	assert.Equal(t, "bitnames-tor", cfg.ExtractSubfolder[currentOS()])
}

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

func TestDownload_RequiredHashFailsClosed(t *testing.T) {
	zipContent := makeZipBytes(t, map[string][]byte{"test-binary": []byte("data")})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write(zipContent)
	}))
	defer srv.Close()
	validHash := fmt.Sprintf("%x", sha256.Sum256(zipContent))

	for _, tc := range []struct {
		name, hash string
		size       int64
		wantDone   bool
	}{
		{name: "missing"},
		{name: "mismatch", hash: "00"},
		{name: "oversize", hash: validHash, size: 1},
		{name: "verified", hash: validHash, size: int64(len(zipContent)), wantDone: true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			dm, dir := newTestDownloadManager(t)
			dm.httpClient = srv.Client()
			hashes := map[string]ArchiveHash{}
			if tc.hash != "" {
				hashes[currentPlatform()] = ArchiveHash{SHA256: tc.hash, Size: tc.size}
			}
			ch, err := dm.Download(context.Background(), BinaryConfig{
				Name: "test", BinaryName: "test-binary", DownloadSource: DownloadSourceDirect,
				DownloadURLs:  map[string]string{"default": srv.URL + "/"},
				Files:         map[string]string{currentPlatform(): "test-binary.zip"},
				ArchiveHashes: hashes, RequireHash: true,
			}, "default", true)
			require.NoError(t, err)
			var last DownloadProgress
			for progress := range ch {
				last = progress
			}
			assert.Equal(t, tc.wantDone, last.Done)
			if !tc.wantDone {
				require.Error(t, last.Error)
				_, err = os.Stat(BinaryPath(dir, "test-binary"))
				assert.True(t, os.IsNotExist(err))
			}
		})
	}
}

func TestDownload_ObservedHashIsNotTrusted(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	zipContent := makeZipBytes(t, map[string][]byte{"test-binary": []byte("new")})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = w.Write(zipContent) }))
	defer srv.Close()
	dm.httpClient = srv.Client()
	path := BinaryPath(dir, "test-binary")
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, []byte("old"), 0o755))
	ch, err := dm.Download(context.Background(), BinaryConfig{
		Name: "test", BinaryName: "test-binary", DownloadSource: DownloadSourceDirect,
		DownloadURLs: map[string]string{"default": srv.URL + "/"}, Files: map[string]string{currentPlatform(): "test.zip"},
		ArchiveHashes: map[string]ArchiveHash{currentPlatform(): {SHA256: "stale", Size: 1}}, RequireHash: true,
	}, "default", false)
	require.NoError(t, err)
	var last DownloadProgress
	for progress := range ch {
		last = progress
	}
	require.Error(t, last.Error)
	got, err := os.ReadFile(path)
	require.NoError(t, err)
	assert.Equal(t, "old", string(got))

	ch, err = dm.Download(context.Background(), BinaryConfig{
		Name: "test", BinaryName: "test-binary", DownloadSource: DownloadSourceDirect,
		DownloadURLs: map[string]string{"default": srv.URL + "/"}, Files: map[string]string{currentPlatform(): "test.zip"},
		ArchiveHashes: map[string]ArchiveHash{currentPlatform(): {SHA256: "observed", Size: 1}},
	}, "default", true)
	require.NoError(t, err)
	assert.True(t, drainProgress(t, ch).Done)
	got, err = os.ReadFile(path)
	require.NoError(t, err)
	assert.Equal(t, "new", string(got))
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
