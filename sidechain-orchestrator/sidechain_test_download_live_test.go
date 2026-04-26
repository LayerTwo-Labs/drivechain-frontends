//go:build integration_live

package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"runtime"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestIntegrationLive_TestSidechains_DownloadAlt downloads every layer-2
// sidechain's alt build from releases.drivechain.info and asserts the
// extracted artifact is launchable. Run with:
//
//	go test -tags integration_live -run TestIntegrationLive_TestSidechains_DownloadAlt ./...
//
// The default test path is broken: archives ship as Flutter app bundles
// (`.app` on macOS, `<name>/` directory on Linux with sibling lib/+data/),
// not flat binaries. extractBinary's flatten-by-basename logic destroys the
// bundle structure, so the binary either isn't recognisable on disk or is
// missing its runtime dependencies. This test surfaces that failure
// against the real archives served by releases.drivechain.info.
func TestIntegrationLive_TestSidechains_DownloadAlt(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping live download in short mode")
	}

	dataDir := t.TempDir()
	bwDir := t.TempDir()
	cfgs := AllDefaults()
	o := New(dataDir, "signet", bwDir, cfgs, testLogger(t))

	require.NoError(t, o.SetTestSidechains(context.Background(), true))
	require.True(t, o.UseTestSidechains())

	for _, cfg := range cfgs {
		cfg := cfg
		if cfg.ChainLayer != 2 || cfg.AltBinaryName == "" {
			continue
		}
		if cfg.AltFiles[currentOS()] == "" {
			t.Logf("skip %s: no alt file for %s", cfg.Name, currentOS())
			continue
		}
		t.Run(cfg.Name, func(t *testing.T) {
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
			defer cancel()

			progress, err := o.Download(ctx, cfg.Name, true)
			require.NoError(t, err, "Download(%s)", cfg.Name)

			var last DownloadProgress
			for p := range progress {
				if p.Error != nil {
					t.Fatalf("download error for %s: %v", cfg.Name, p.Error)
				}
				last = p
			}
			require.True(t, last.Done, "download for %s never completed", cfg.Name)

			binPath := TestSidechainBinaryPath(dataDir, cfg.AltBinaryName)
			info, err := os.Stat(binPath)
			require.NoError(t, err, "expected %s binary at %s", cfg.AltBinaryName, binPath)
			require.False(t, info.IsDir(), "%s should be a regular file, got dir at %s", cfg.AltBinaryName, binPath)
			require.NotZero(t, info.Size(), "%s at %s is empty", cfg.AltBinaryName, binPath)

			// Flutter app bundles ship as either:
			//   - macOS: `Foo.app/Contents/MacOS/Foo` — bundle layout must
			//     stay intact (Frameworks dir + symlinks + plist) for
			//     macOS to load the binary.
			//   - Linux: `<name>` binary with `lib/`+`data/` siblings.
			//
			// Resolution returning a sane path is necessary but not
			// sufficient — also confirm the surrounding structure survived.
			scDir := TestSidechainDir(dataDir, cfg.AltBinaryName)
			switch runtime.GOOS {
			case "darwin":
				entries, err := os.ReadDir(scDir)
				require.NoError(t, err)
				var app string
				for _, e := range entries {
					if e.IsDir() && filepathHasSuffix(e.Name(), ".app") {
						app = filepath.Join(scDir, e.Name())
						break
					}
				}
				require.NotEmpty(t, app, "macOS test build for %s must extract an .app bundle in %s", cfg.Name, scDir)
				_, err = os.Stat(filepath.Join(app, "Contents", "Info.plist"))
				assert.NoError(t, err, "%s missing bundle Info.plist", app)
				_, err = os.Stat(filepath.Join(app, "Contents", "Frameworks"))
				assert.NoError(t, err, "%s missing Frameworks/ — extraction flattened the bundle", app)
			case "linux":
				_, err := os.Stat(filepath.Join(scDir, "lib"))
				assert.NoError(t, err, "linux test build for %s missing sibling lib/", cfg.Name)
				_, err = os.Stat(filepath.Join(scDir, "data"))
				assert.NoError(t, err, "linux test build for %s missing sibling data/", cfg.Name)
			}
		})
	}
}

func filepathHasSuffix(name, suffix string) bool {
	if len(name) < len(suffix) {
		return false
	}
	return name[len(name)-len(suffix):] == suffix
}
