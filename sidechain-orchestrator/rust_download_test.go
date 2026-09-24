package orchestrator

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"
)

// Every rust sidechain reads its own LayerTwo-Labs release, which publishes a
// bare daemon and a bare CLI beside it. The pattern must select the daemon.
func TestRustSidechainsDownloadTheUpstreamBinary(t *testing.T) {
	repos := map[string]string{
		"thunder":   "thunder-rust",
		"bitnames":  "plain-bitnames",
		"bitassets": "plain-bitassets",
		"truthcoin": "truthcoin-dc",
		"photon":    "photon",
	}
	platforms := map[string]string{
		"linux-x86_64":   "x86_64-unknown-linux-gnu",
		"macos-x86_64":   "x86_64-apple-darwin",
		"macos-arm64":    "aarch64-apple-darwin",
		"windows-x86_64": "x86_64-pc-windows-gnu.exe",
	}

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
			}
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

func TestRustDownloadsSelectForkArchives(t *testing.T) {
	for _, cfg := range AllDefaults() {
		if cfg.Name != "zside" {
			continue
		}
		t.Run(cfg.Name, func(t *testing.T) {
			repo, version := "thunder-orchard", "0.17.3"
			require.Empty(t, cfg.Files["windows-x86_64"])
			require.Equal(t, "https://api.github.com/repos/octobocto/"+repo+"/releases/latest", cfg.DownloadURLs["default"])
			platforms := map[string]string{
				"linux-x86_64": "x86_64-unknown-linux-gnu",
				"macos-x86_64": "x86_64-apple-darwin",
				"macos-arm64":  "aarch64-apple-darwin",
			}
			var assets []map[string]string
			for _, target := range platforms {
				name := cfg.BinaryName + "-" + version + "-" + target
				for _, suffix := range []string{"", ".zip"} {
					assets = append(assets, map[string]string{
						"name": name + suffix, "browser_download_url": "https://example.invalid/" + name + suffix,
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
				require.NoError(t, err)
				require.Equal(t, "https://example.invalid/"+cfg.BinaryName+"-"+version+"-"+target+".zip", got)
			}
		})
	}
}
