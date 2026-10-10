package orchestrator

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"sync"
	"testing"

	"github.com/stretchr/testify/require"
)

// rustTargets maps each platform to the target triple a rust release asset ends with.
var rustTargets = map[string]string{
	"linux-x86_64":   "x86_64-unknown-linux-gnu",
	"macos-x86_64":   "x86_64-apple-darwin",
	"macos-arm64":    "aarch64-apple-darwin",
	"windows-x86_64": "x86_64-pc-windows-gnu.exe",
}

// Every rust sidechain reads its own LayerTwo-Labs release, which publishes a
// bare daemon and a bare CLI beside it. Each pattern must select its own asset.
func TestRustSidechainsDownloadTheUpstreamBinary(t *testing.T) {
	repos := map[string]string{
		"thunder":   "thunder-rust",
		"bitnames":  "plain-bitnames",
		"bitassets": "plain-bitassets",
		"truthcoin": "truthcoin-dc",
		"photon":    "photon",
	}
	platforms := rustTargets

	for _, cfg := range AllDefaults() {
		repo, ok := repos[cfg.Name]
		if !ok {
			continue
		}
		t.Run(cfg.Name, func(t *testing.T) {
			require.Equal(t, "https://api.github.com/repos/LayerTwo-Labs/"+repo+"/releases/latest", cfg.DownloadURLs["default"])

			const version = "0.18.0"
			var assets []map[string]string
			for _, target := range platforms {
				for _, name := range []string{
					cfg.BinaryName + "-" + version + "-" + target,
					cfg.BinaryName + "-cli-" + version + "-" + target,
				} {
					assets = append(assets, map[string]string{
						"name": name, "browser_download_url": "https://example.invalid/" + name,
					})
				}
			}
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
				if err := json.NewEncoder(w).Encode(map[string]any{"assets": assets}); err != nil {
					t.Error(err)
				}
			}))
			defer server.Close()

			dm, _ := newTestDownloadManager(t)
			for platform, target := range platforms {
				got, err := dm.resolveGitHubURL(context.Background(), server.URL, cfg.Files[platform])
				require.NoError(t, err, platform)
				require.Equal(t, "https://example.invalid/"+cfg.BinaryName+"-"+version+"-"+target, got, platform)

				got, err = dm.resolveGitHubURL(context.Background(), server.URL, cfg.CLIFiles[platform])
				require.NoError(t, err, platform)
				require.Equal(t, "https://example.invalid/"+cfg.BinaryName+"-cli-"+version+"-"+target, got, platform)
			}
			require.Equal(t, cfg.BinaryName+"-cli", cfg.CLIBinaryName)
		})
	}
}

// A bare asset lands under the name the launcher looks for, which carries
// .exe on Windows.
func TestRawBinaryTakesTheLaunchName(t *testing.T) {
	require.Equal(t, "truthcoin.exe", rawBinaryName("truthcoin", "windows"))
	require.Equal(t, "truthcoin", rawBinaryName("truthcoin", "darwin"))
	require.Equal(t, "truthcoin", rawBinaryName("truthcoin", "linux"))
}

// The octobocto fork release has no betanet, so zSide reads the upstream
// release, which publishes a bare daemon and a bare CLI beside it.
func TestZSideDownloadsTheUpstreamBinary(t *testing.T) {
	var cfg BinaryConfig
	for _, c := range AllDefaults() {
		if c.Name == "zside" {
			cfg = c
		}
	}
	require.Equal(t, "https://api.github.com/repos/iwakura-rein/thunder-orchard/releases/latest", cfg.DownloadURLs["default"])
	require.Empty(t, cfg.Files["windows-x86_64"])
	require.Equal(t, "thunder-orchard-cli", cfg.CLIBinaryName)
	require.Empty(t, cfg.CLIFiles["windows-x86_64"])

	const version = "0.18.1"
	platforms := map[string]string{
		"linux-x86_64": "x86_64-unknown-linux-gnu",
		"macos-x86_64": "x86_64-apple-darwin",
		"macos-arm64":  "aarch64-apple-darwin",
	}
	var assets []map[string]string
	for _, target := range platforms {
		for _, name := range []string{
			cfg.BinaryName + "-" + version + "-" + target,
			cfg.BinaryName + "-cli-" + version + "-" + target,
		} {
			assets = append(assets, map[string]string{
				"name": name, "browser_download_url": "https://example.invalid/" + name,
			})
		}
	}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		if err := json.NewEncoder(w).Encode(map[string]any{"assets": assets}); err != nil {
			t.Error(err)
		}
	}))
	defer server.Close()

	dm, _ := newTestDownloadManager(t)
	for platform, target := range platforms {
		got, err := dm.resolveGitHubURL(context.Background(), server.URL, cfg.Files[platform])
		require.NoError(t, err, platform)
		require.Equal(t, "https://example.invalid/"+cfg.BinaryName+"-"+version+"-"+target, got, platform)

		gotCLI, err := dm.resolveGitHubURL(context.Background(), server.URL, cfg.CLIFiles[platform])
		require.NoError(t, err, platform)
		require.Equal(t, "https://example.invalid/"+cfg.CLIBinaryName+"-"+version+"-"+target, gotCLI, platform)
	}
}

// A sidechain download installs the CLI beside the daemon, and a later start
// fetches only the part that is missing.
func TestDownload_InstallsTheCLIBesideTheDaemon(t *testing.T) {
	target, ok := rustTargets[currentPlatform()]
	if !ok {
		t.Skipf("no rust release for %s", currentPlatform())
	}
	daemonAsset, cliAsset := "thunder-0.18.1-"+target, "thunder-cli-0.18.1-"+target

	var mu sync.Mutex
	var fetched []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/releases/latest" {
			assets := []map[string]string{}
			for _, name := range []string{daemonAsset, cliAsset} {
				assets = append(assets, map[string]string{"name": name, "browser_download_url": "http://" + r.Host + "/dl/" + name})
			}
			if err := json.NewEncoder(w).Encode(map[string]any{"assets": assets}); err != nil {
				t.Error(err)
			}
			return
		}
		if r.Method == http.MethodGet {
			mu.Lock()
			fetched = append(fetched, r.URL.Path)
			mu.Unlock()
		}
		_, _ = w.Write([]byte(r.URL.Path))
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()
	cfg, ok := BinaryConfigByName("thunder")
	require.True(t, ok)
	cfg.DownloadURLs = map[string]string{"default": srv.URL + "/releases/latest"}
	daemonPath, cliPath := BinaryPath(dir, "thunder"), BinaryPath(dir, "thunder-cli")

	download := func(force bool) []string {
		mu.Lock()
		fetched = nil
		mu.Unlock()
		ch, err := dm.Download(context.Background(), cfg, "default", force)
		require.NoError(t, err)
		require.True(t, drainProgress(t, ch).Done)
		mu.Lock()
		defer mu.Unlock()
		return fetched
	}

	t.Run("a fresh install gets both", func(t *testing.T) {
		require.ElementsMatch(t, []string{"/dl/" + daemonAsset, "/dl/" + cliAsset}, download(false))
		assertBinary(t, daemonPath, "/dl/"+daemonAsset)
		assertBinary(t, cliPath, "/dl/"+cliAsset)
	})

	t.Run("a complete install fetches nothing", func(t *testing.T) {
		require.Empty(t, download(false))
	})

	t.Run("a daemon with no CLI gets only the CLI", func(t *testing.T) {
		require.NoError(t, os.Remove(cliPath))
		writeBinary(t, daemonPath, "installed-daemon")

		require.Equal(t, []string{"/dl/" + cliAsset}, download(false))
		assertBinary(t, daemonPath, "installed-daemon")
		assertBinary(t, cliPath, "/dl/"+cliAsset)
	})
}
