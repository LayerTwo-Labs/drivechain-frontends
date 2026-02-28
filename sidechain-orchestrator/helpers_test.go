package orchestrator

import (
	"archive/tar"
	"archive/zip"
	"bytes"
	"compress/gzip"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func testLogger(t *testing.T) zerolog.Logger {
	t.Helper()
	return zerolog.New(zerolog.NewTestWriter(t))
}

func newTestPidManager(t *testing.T) *PidFileManager {
	t.Helper()
	return NewPidFileManager(t.TempDir(), testLogger(t))
}

func newTestOrchestrator(t *testing.T) *Orchestrator {
	t.Helper()
	return New(t.TempDir(), "signet", AllDefaults(), testLogger(t))
}

func newTestProcessManager(t *testing.T) (*ProcessManager, string) {
	t.Helper()
	dir := t.TempDir()
	log := testLogger(t)
	pm := NewProcessManager(dir, NewPidFileManager(dir, log), log)
	return pm, dir
}

func newTestDownloadManager(t *testing.T) (*DownloadManager, string) {
	t.Helper()
	dir := t.TempDir()
	return NewDownloadManager(dir, testLogger(t)), dir
}

// symlinkSystemBinary makes a system binary available in the test data dir.
func symlinkSystemBinary(t *testing.T, dataDir, binary string) {
	t.Helper()
	if runtime.GOOS == "windows" {
		t.Skipf("symlinkSystemBinary not supported on windows")
	}
	binDir := BinDir(dataDir)
	require.NoError(t, os.MkdirAll(binDir, 0o755))
	sysPath, err := exec.LookPath(binary)
	require.NoError(t, err)
	require.NoError(t, os.Symlink(sysPath, filepath.Join(binDir, binary)))
}

// makeZipBytes creates an in-memory zip archive.
func makeZipBytes(t *testing.T, files map[string][]byte) []byte {
	t.Helper()
	var buf bytes.Buffer
	w := zip.NewWriter(&buf)
	for name, content := range files {
		f, err := w.Create(name)
		require.NoError(t, err)
		_, err = f.Write(content)
		require.NoError(t, err)
	}
	require.NoError(t, w.Close())
	return buf.Bytes()
}

// makeZipFile writes a zip archive to disk.
func makeZipFile(t *testing.T, path string, files map[string][]byte) {
	t.Helper()
	require.NoError(t, os.WriteFile(path, makeZipBytes(t, files), 0o644))
}

// makeTarGzFile writes a tar.gz archive to disk.
func makeTarGzFile(t *testing.T, path string, files map[string][]byte) {
	t.Helper()
	f, err := os.Create(path)
	require.NoError(t, err)
	defer f.Close()

	gz := gzip.NewWriter(f)
	tw := tar.NewWriter(gz)

	for name, content := range files {
		require.NoError(t, tw.WriteHeader(&tar.Header{
			Name: name,
			Mode: 0o755,
			Size: int64(len(content)),
		}))
		_, err := tw.Write(content)
		require.NoError(t, err)
	}

	require.NoError(t, tw.Close())
	require.NoError(t, gz.Close())
}
