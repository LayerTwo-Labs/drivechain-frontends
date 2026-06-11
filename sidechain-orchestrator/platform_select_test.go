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

// Resolution is a direct lookup with no fallback: a map missing the current
// platform's key resolves empty even when a sibling-arch entry is present.
// (Binaries with no native arm build hardcode the x86_64 file under
// macos-arm64 in the config instead of relying on a runtime swap.)
func TestFileForPlatform_NoSiblingArchFallback(t *testing.T) {
	files := map[string]string{}
	for _, p := range []string{"linux-x86_64", "macos-x86_64", "macos-arm64", "windows-x86_64"} {
		if p != currentPlatform() {
			files[p] = p + ".zip"
		}
	}
	assert.Empty(t, fileForPlatform(files), "no key for %s must resolve empty, not swap", currentPlatform())
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
