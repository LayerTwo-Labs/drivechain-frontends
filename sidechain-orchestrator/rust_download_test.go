package orchestrator

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"
)

// Truthcoin comes from the upstream zips on releases.drivechain.info, which
// hold the daemon and its CLI.
func TestTruthcoinDownloadsTheUpstreamZip(t *testing.T) {
	var cfg BinaryConfig
	for _, c := range AllDefaults() {
		if c.Name == "truthcoin" {
			cfg = c
		}
	}
	require.Equal(t, "https://releases.drivechain.info/", cfg.DownloadURLs["default"])
	for platform, target := range map[string]string{
		"linux-x86_64":   "x86_64-unknown-linux-gnu",
		"macos-x86_64":   "x86_64-apple-darwin",
		"macos-arm64":    "aarch64-apple-darwin",
		"windows-x86_64": "x86_64-pc-windows-gnu",
	} {
		require.Equal(t, "L2-S13-Truthcoin-latest-"+target+".zip", cfg.Files[platform], platform)
	}
	require.Equal(t, "truthcoin", StripPlatformSuffix("truthcoin-latest-aarch64-apple-darwin"))
	require.Equal(t, "truthcoin-cli", StripPlatformSuffix("truthcoin-cli-latest-aarch64-apple-darwin"))
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
