package orchestrator

import (
	"testing"

	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestFileFor_LinuxArm64HasNoEnforcerOrSidechain(t *testing.T) {
	configs := AllDefaults()
	for _, name := range []string{"enforcer", "thunder"} {
		cfg, ok := lo.Find(configs, func(c BinaryConfig) bool { return c.Name == name })
		require.Truef(t, ok, "%s must be in the embedded config", name)
		_, err := cfg.fileFor("linux-arm64")
		assert.ErrorContains(t, err, name+" is not available on linux-arm64")
	}
}

func TestFullModeBuildErr_LinuxArm64HasNoFullMode(t *testing.T) {
	assert.ErrorContains(t, fullModeBuildErr("linux-arm64"), "enforcer is not available on linux-arm64")
	assert.NoError(t, fullModeBuildErr("linux-x86_64"))
}

func TestFileFor_LinuxArm64PicksItsOwnEntry(t *testing.T) {
	cfg := BinaryConfig{Name: "tool", Files: map[string]string{
		"linux-x86_64": "tool-x86_64.zip",
		"linux-arm64":  "tool-aarch64.zip",
	}}
	got, err := cfg.fileFor("linux-arm64")
	require.NoError(t, err)
	assert.Equal(t, "tool-aarch64.zip", got)

	for _, c := range AllDefaults() {
		got, err := c.fileFor("linux-arm64")
		if want := c.Files["linux-arm64"]; want != "" {
			assert.NoErrorf(t, err, "%s has a linux-arm64 entry", c.Name)
			assert.Equal(t, want, got)
			continue
		}
		assert.Errorf(t, err, "%s has no linux-arm64 entry", c.Name)
	}
}

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
