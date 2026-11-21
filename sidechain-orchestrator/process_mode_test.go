package orchestrator

import (
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func writeTestScript(t *testing.T, dataDir, name, body string, mode os.FileMode) string {
	t.Helper()
	if runtime.GOOS == "windows" {
		t.Skip("shell scripts need a unix shell")
	}
	require.NoError(t, os.MkdirAll(BinDir(dataDir), 0o755))
	path := BinaryPath(dataDir, name)
	require.NoError(t, os.WriteFile(path, []byte("#!/bin/sh\n"+body+"\n"), mode))
	require.NoError(t, os.Chmod(path, mode))
	return path
}

func TestStartKeepsTheModeOfAnExecutable(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	path := writeTestScript(t, dir, "readonly", "sleep 5", 0o555)

	_, err := pm.StartWithOptions(t.Context(), BinaryConfig{Name: "readonly", BinaryName: "readonly"}, nil, nil, ProcessStartOptions{})
	require.NoError(t, err)
	info, err := os.Stat(path)
	require.NoError(t, err)
	assert.Equal(t, os.FileMode(0o555), info.Mode().Perm())
}

func TestStartMakesABinaryExecutable(t *testing.T) {
	pm, dir := newTestProcessManager(t)
	path := writeTestScript(t, dir, "plain", "sleep 5", 0o644)

	_, err := pm.StartWithOptions(t.Context(), BinaryConfig{Name: "plain", BinaryName: "plain"}, nil, nil, ProcessStartOptions{})
	require.NoError(t, err)
	info, err := os.Stat(filepath.Clean(path))
	require.NoError(t, err)
	assert.Equal(t, os.FileMode(0o755), info.Mode().Perm())
}
