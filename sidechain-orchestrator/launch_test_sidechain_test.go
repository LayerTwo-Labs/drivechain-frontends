package orchestrator

import (
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

// Regression for "Linux: test sidechains stuck on initializing". The fix
// launches the test sidechain's Flutter GUI detached and tracks it under its
// own "-gui" process name, so it never occupies the rust daemon's process slot
// (which left the chain stuck at "initializing").
func TestSidechainGUIProcessName(t *testing.T) {
	assert.Equal(t, "thunder-gui", sidechainGUIProcessName("thunder"))
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
