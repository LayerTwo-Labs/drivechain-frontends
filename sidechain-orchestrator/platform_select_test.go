package orchestrator

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFileForPlatform_PicksArchKey(t *testing.T) {
	files := map[string]string{
		"linux-x86_64":   "lin-x86.zip",
		"macos-x86_64":   "mac-x86.zip",
		"macos-arm64":    "mac-arm.zip",
		"windows-x86_64": "win-x86.zip",
	}
	got := fileForPlatform(files)
	assert.Equal(t, files[currentPlatform()], got)
	assert.NotEmpty(t, got, "current platform %s must resolve", currentPlatform())
}

// On Apple Silicon a binary with no native arm64 entry falls back to the
// macOS x86_64 build (Rosetta) rather than failing the download.
func TestFileForPlatform_MacArmFallsBackToX86(t *testing.T) {
	if currentPlatform() != "macos-arm64" {
		t.Skipf("fallback path only exercised on macos-arm64, got %s", currentPlatform())
	}
	files := map[string]string{"macos-x86_64": "mac-x86.zip"}
	assert.Equal(t, "mac-x86.zip", fileForPlatform(files))
}

func TestFileForPlatform_MissingIsEmpty(t *testing.T) {
	assert.Empty(t, fileForPlatform(map[string]string{"some-other-plat": "x.zip"}))
}

// Every downloadable binary in the embedded config must resolve a file for the
// current platform — guards against a re-keying typo silently breaking lookup.
func TestEmbeddedConfig_ResolvesEveryDownloadable(t *testing.T) {
	for _, c := range AllDefaults() {
		if !c.Downloadable() {
			continue
		}
		f, err := c.FileForPlatform()
		assert.NoErrorf(t, err, "%s should resolve a file on %s", c.Name, currentPlatform())
		assert.NotEmptyf(t, f, "%s resolved empty file on %s", c.Name, currentPlatform())
	}
}
