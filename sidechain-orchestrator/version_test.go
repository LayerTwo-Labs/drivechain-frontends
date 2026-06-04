package orchestrator

import (
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestParseBinaryVersion(t *testing.T) {
	enforcer := BinaryConfig{BinaryName: "bip300301-enforcer"}
	thunder := BinaryConfig{BinaryName: "thunder"}

	tests := []struct {
		name   string
		config BinaryConfig
		output string
		want   string
	}{
		{
			name:   "generic semver triple",
			config: thunder,
			output: "thunder 0.12.3\n",
			want:   "0.12.3",
		},
		{
			name:   "generic with v prefix",
			config: thunder,
			output: "thunder v1.2.0",
			want:   "1.2.0",
		},
		{
			name:   "generic no semver falls back to first line",
			config: thunder,
			output: "some-build-id-abcdef\nsecond line",
			want:   "some-build-id-abcdef",
		},
		{
			name:   "empty output",
			config: thunder,
			output: "   \n  ",
			want:   "Unknown",
		},
		{
			name:   "enforcer version + commit",
			config: enforcer,
			output: "bip300301_enforcer_lib 0.9.1\ncommit: a1b2c3d4\nother: noise",
			want:   "0.9.1 (a1b2c3d4)",
		},
		{
			name:   "enforcer version only, no commit line",
			config: enforcer,
			output: "bip300301_enforcer_lib v0.9.1",
			want:   "0.9.1",
		},
		{
			name:   "enforcer banner without lib line falls back to first line",
			config: enforcer,
			output: "unexpected banner\ncommit: dead",
			want:   "unexpected banner",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Equal(t, tt.want, parseBinaryVersion(tt.config, tt.output))
		})
	}
}

// writeVersionScript drops an executable shell script that prints version to
// stdout when invoked with --version, into the bin dir under binaryName.
func writeVersionScript(t *testing.T, dataDir, binaryName, versionOutput string) {
	t.Helper()
	binDir := BinDir(dataDir)
	require.NoError(t, os.MkdirAll(binDir, 0o755))
	script := "#!/bin/sh\nif [ \"$1\" = \"--version\" ]; then printf '%s' \"" + versionOutput + "\"; fi\n"
	require.NoError(t, os.WriteFile(filepath.Join(binDir, binaryName), []byte(script), 0o755))
}

func TestBinaryVersion_ResolvesAndRunsProd(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("uses a shell script as the fake binary")
	}

	dataDir := t.TempDir()
	log := testLogger(t)
	cfg := makeSidechainConfig("http://example.invalid/")
	writeVersionScript(t, dataDir, "thunder", "thunder 3.4.5")

	o := New(dataDir, "signet", t.TempDir(), []BinaryConfig{cfg}, log)
	_, err := o.Settings.SetUseTestSidechains(true)
	require.NoError(t, err)

	// forceBackend=true must bypass the test-build resolver and run the prod
	// binary at bin/thunder — even though test sidechains is enabled.
	version, binPath, isTest, err := o.BinaryVersion("thunder", true)
	require.NoError(t, err)
	assert.False(t, isTest)
	assert.Equal(t, "3.4.5", version)
	assert.Equal(t, BinaryPath(dataDir, "thunder"), binPath)
}

func TestBinaryVersion_TestBuildShortCircuits(t *testing.T) {
	dataDir := t.TempDir()
	log := testLogger(t)
	cfg := makeSidechainConfig("http://example.invalid/")

	o := New(dataDir, "signet", t.TempDir(), []BinaryConfig{cfg}, log)
	_, err := o.Settings.SetUseTestSidechains(true)
	require.NoError(t, err)

	// forceBackend=false with test sidechains on resolves the Flutter test
	// build: no --version is attempted, is_test_build is reported, and the
	// path points into the test subfolder.
	version, binPath, isTest, err := o.BinaryVersion("thunder", false)
	require.NoError(t, err)
	assert.True(t, isTest)
	assert.Empty(t, version)
	assert.Equal(t, TestSidechainBinaryPath(dataDir, "thunder"), binPath)
}

func TestBinaryVersion_NotDownloadedReturnsStatError(t *testing.T) {
	dataDir := t.TempDir()
	log := testLogger(t)
	cfg := makeSidechainConfig("http://example.invalid/")

	o := New(dataDir, "signet", t.TempDir(), []BinaryConfig{cfg}, log)

	// Nothing on disk: prod resolve hits a stat miss, surfaced as an error
	// (the handler turns this into an "Error: ..." display string).
	_, binPath, isTest, err := o.BinaryVersion("thunder", true)
	require.Error(t, err)
	assert.True(t, os.IsNotExist(err))
	assert.False(t, isTest)
	assert.Equal(t, BinaryPath(dataDir, "thunder"), binPath)
}

func TestBinaryVersion_UnknownBinary(t *testing.T) {
	o := newTestOrchestrator(t)
	_, _, _, err := o.BinaryVersion("does-not-exist", true)
	require.Error(t, err)
}
