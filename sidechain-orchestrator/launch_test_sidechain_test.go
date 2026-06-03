package orchestrator

import (
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Regression for "Linux: test sidechains stuck on initializing". The launcher
// used to only handle the macOS .app bundle, so on Linux/Windows nothing was
// started and the monitor sat at "initializing" forever. launchTestSidechainGUI
// now resolves a launch target on every OS and must actually attempt a launch —
// surfacing an error when the build is missing rather than silently no-op'ing
// (the old non-darwin behaviour).
func TestLaunchTestSidechainGUI_ErrorsWhenNotDownloaded(t *testing.T) {
	err := launchTestSidechainGUI(t.TempDir(), "thunder")
	require.Error(t, err)
}

// TestSidechainBinaryPath must point at a launch target inside the sidechain's
// build dir on every OS — never empty, which would leave the launcher with
// nothing to run (the root of the Linux "initializing" hang).
func TestSidechainBinaryPath_ResolvesLaunchTarget(t *testing.T) {
	dir := t.TempDir()
	p := TestSidechainBinaryPath(dir, "thunder")
	assert.NotEmpty(t, p)
	assert.True(t, filepath.IsAbs(p), "path should be absolute, got %q", p)
	assert.True(t, strings.Contains(p, "thunder"), "path should target the thunder build, got %q", p)
}
