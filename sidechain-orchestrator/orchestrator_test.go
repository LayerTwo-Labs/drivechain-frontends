package orchestrator

import (
	"archive/tar"
	"archive/zip"
	"bytes"
	"compress/gzip"
	"context"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
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

func TestNew(t *testing.T) {
	o := newTestOrchestrator(t)
	assert.NotEmpty(t, o.DataDir)
	assert.Equal(t, "signet", o.Network)
	assert.Greater(t, len(o.configs), 0)
}

func TestOrchestrator_StatusUnknown(t *testing.T) {
	o := newTestOrchestrator(t)
	status := o.Status("nonexistent")
	assert.Equal(t, "nonexistent", status.Name)
	assert.NotEmpty(t, status.Error)
}

func TestOrchestrator_StatusNotRunning(t *testing.T) {
	o := newTestOrchestrator(t)
	status := o.Status("thunder")
	assert.Equal(t, "thunder", status.Name)
	assert.False(t, status.Running)
	assert.Equal(t, 6009, status.Port)
}

func TestOrchestrator_ListAll(t *testing.T) {
	o := newTestOrchestrator(t)
	assert.Equal(t, len(AllDefaults()), len(o.ListAll()))
}

func TestOrchestrator_LogsNotRunning(t *testing.T) {
	o := newTestOrchestrator(t)
	_, _, err := o.Logs("thunder")
	assert.Error(t, err)
}

func TestOrchestrator_AdoptOrphans(t *testing.T) {
	o := newTestOrchestrator(t)

	require.NoError(t, o.pidManager.WritePidFile("thunder", 99999))
	require.NoError(t, o.AdoptOrphans(context.Background()))

	_, err := o.pidManager.ReadPidFile("thunder")
	assert.Error(t, err)
}

func TestOrderForShutdown(t *testing.T) {
	assert.Equal(t,
		[]string{"thunder", "enforcer", "bitcoind"},
		orderForShutdown([]string{"bitcoind", "enforcer", "thunder"}),
	)
}

func TestOrderForShutdown_Empty(t *testing.T) {
	assert.Empty(t, orderForShutdown(nil))
}
