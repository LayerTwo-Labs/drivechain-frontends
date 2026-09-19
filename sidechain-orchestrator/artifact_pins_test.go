package orchestrator

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/require"
)

func sha256Hex(data []byte) string {
	sum := sha256.Sum256(data)
	return hex.EncodeToString(sum[:])
}

func TestPinnedArchiveInstallAndCache(t *testing.T) {
	for _, extension := range []string{".zip", ".tar.gz"} {
		t.Run(extension, func(t *testing.T) {
			dm, dir := newTestDownloadManager(t)
			name := "pinned"
			if runtime.GOOS == "windows" {
				name += ".exe"
			}
			payload := []byte("pinned payload")
			archivePath := filepath.Join(t.TempDir(), "pinned"+extension)
			files := map[string][]byte{"release/bin/" + name: payload}
			if extension == ".zip" {
				makeZipFile(t, archivePath, files)
			} else {
				makeTarGzFile(t, archivePath, files)
			}
			archive, err := os.ReadFile(archivePath)
			require.NoError(t, err)
			var requests atomic.Int32
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if r.Method == http.MethodGet {
					requests.Add(1)
				}
				_, _ = w.Write(archive)
			}))
			defer server.Close()
			cfg := BinaryConfig{Name: "pinned", BinaryName: "pinned",
				DownloadURLs: map[string]string{"default": server.URL + "/"},
				Files:        map[string]string{currentPlatform(): "pinned" + extension},
				ArtifactPins: map[string]ArtifactPin{currentPlatform(): {
					ArchiveSHA256: sha256Hex(archive), ExecutableSHA256: sha256Hex(payload),
				}},
			}
			for range 2 {
				ch, err := dm.Download(context.Background(), cfg, "ecash", false)
				require.NoError(t, err)
				done := false
				for progress := range ch {
					require.NoError(t, progress.Error)
					done = done || progress.Done
				}
				require.True(t, done)
				require.NoError(t, verifyArtifactPin(cfg, BinaryPath(dir, cfg.BinaryName), false))
			}
			require.EqualValues(t, 1, requests.Load(), "a second download reuses the verified binary")

			require.NoError(t, os.WriteFile(BinaryPath(dir, cfg.BinaryName), []byte("tampered"), 0o700))
			ch, err := dm.Download(context.Background(), cfg, "ecash", false)
			require.ErrorContains(t, err, "checksum mismatch")
			require.Nil(t, ch)
			require.EqualValues(t, 1, requests.Load())
		})
	}
}

func TestVerifyArtifactPin(t *testing.T) {
	payload := []byte("pinned artifact")
	hash := sha256Hex(payload)
	cfg := BinaryConfig{Name: "pinned", ArtifactPins: map[string]ArtifactPin{
		currentPlatform(): {ArchiveSHA256: hash, ExecutableSHA256: hash},
	}}
	path := filepath.Join(t.TempDir(), "artifact")
	require.NoError(t, os.WriteFile(path, payload, 0o600))
	for _, archive := range []bool{false, true} {
		require.NoError(t, verifyArtifactPin(cfg, path, archive))
	}
	link := path + ".link"
	require.NoError(t, os.Symlink(path, link))
	require.ErrorContains(t, verifyArtifactPin(cfg, link, false), "regular file")
	require.ErrorContains(t, verifyArtifactPin(cfg, filepath.Join(t.TempDir(), "absent"), false), "no such file")
	require.NoError(t, os.WriteFile(path, []byte("changed"), 0o600))
	require.ErrorContains(t, verifyArtifactPin(cfg, path, false), "checksum mismatch")

	cfg.ArtifactPins = map[string]ArtifactPin{"another-platform": {ArchiveSHA256: hash, ExecutableSHA256: hash}}
	require.ErrorContains(t, verifyArtifactPin(cfg, path, false), "no artifact pin")
	cfg.ArtifactPins = nil
	require.NoError(t, verifyArtifactPin(cfg, path, false), "an unpinned binary has nothing to compare")
}

func TestDownloadVerifiesTheArchiveBeforeExtraction(t *testing.T) {
	payload := []byte("archive")
	cfg := BinaryConfig{Name: "pinned", ArtifactPins: map[string]ArtifactPin{
		currentPlatform(): {ArchiveSHA256: sha256Hex(payload)},
	}}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = w.Write(payload) }))
	defer server.Close()
	dm, dir := newTestDownloadManager(t)
	target := DownloadTarget{Source: DownloadSourceDirect, BaseURL: server.URL + "/", FileName: "artifact.zip"}
	send := func(DownloadProgress) bool { return true }
	_, err := dm.fetchArchive(context.Background(), cfg, target, dir, send)
	require.NoError(t, err)

	cfg.ArtifactPins[currentPlatform()] = ArtifactPin{ArchiveSHA256: hex.EncodeToString(make([]byte, 32))}
	_, err = dm.fetchArchive(context.Background(), cfg, target, dir, send)
	require.ErrorContains(t, err, "checksum mismatch")
	entries, err := os.ReadDir(BinDir(dir))
	require.NoError(t, err)
	require.Empty(t, entries)
}

func TestDownloadRefusesAPlatformWithoutAPin(t *testing.T) {
	dm, _ := newTestDownloadManager(t)
	hash := sha256Hex([]byte("x"))
	cfg := BinaryConfig{Name: "pinned", BinaryName: "pinned",
		Files:        map[string]string{currentPlatform(): "pinned.zip"},
		ArtifactPins: map[string]ArtifactPin{"another-platform": {ArchiveSHA256: hash, ExecutableSHA256: hash}},
	}
	ch, err := dm.Download(context.Background(), cfg, "ecash", false)
	require.ErrorContains(t, err, "no pinned release")
	require.Nil(t, ch)
}

func TestProcessStartRefusesAChangedExecutable(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	cfg := BinaryConfig{Name: "pinned", BinaryName: "pinned", ArtifactPins: map[string]ArtifactPin{
		currentPlatform(): {ArchiveSHA256: sha256Hex([]byte("a")), ExecutableSHA256: sha256Hex([]byte("original"))},
	}}
	require.NoError(t, os.MkdirAll(BinDir(dir), 0o700))
	require.NoError(t, os.WriteFile(BinaryPath(dir, cfg.BinaryName), []byte("changed"), 0o700))
	pid, err := pm.Start(context.Background(), cfg, nil, nil)
	require.ErrorContains(t, err, "checksum mismatch")
	require.Zero(t, pid)
}

func TestElementsHasAPinnedReleasePerPlatform(t *testing.T) {
	cfg, ok := BinaryConfigByName("liquid-signet")
	require.True(t, ok)
	for _, platform := range []string{"macos-arm64", "linux-x86_64", "windows-x86_64"} {
		require.NoError(t, checkArtifactPins(cfg, platform), platform)
	}
	for _, platform := range []string{"macos-x86_64", "linux-arm64", "windows-arm64"} {
		require.Error(t, checkArtifactPins(cfg, platform), platform)
	}
}
