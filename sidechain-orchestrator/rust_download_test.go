package orchestrator

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestRustDownloadsSelectForkArchives(t *testing.T) {
	for _, cfg := range AllDefaults() {
		if cfg.Name != "truthcoin" && cfg.Name != "zside" {
			continue
		}
		t.Run(cfg.Name, func(t *testing.T) {
			repo, version := "truthcoin-dc", "0.17.1"
			if cfg.Name == "zside" {
				repo, version = "thunder-orchard", "0.17.3"
				require.Empty(t, cfg.Files["windows-x86_64"])
			}
			require.Equal(t, "https://api.github.com/repos/octobocto/"+repo+"/releases/latest", cfg.DownloadURLs["default"])
			platforms := map[string]string{
				"linux-x86_64":   "x86_64-unknown-linux-gnu",
				"macos-x86_64":   "x86_64-apple-darwin",
				"macos-arm64":    "aarch64-apple-darwin",
				"windows-x86_64": "x86_64-pc-windows-gnu",
			}
			var assets []map[string]string
			for platform, target := range platforms {
				if cfg.Name == "zside" && platform == "windows-x86_64" {
					continue
				}
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
				if cfg.Name == "zside" && platform == "windows-x86_64" {
					continue
				}
				got, err := dm.resolveGitHubURL(context.Background(), server.URL, cfg.Files[platform])
				require.NoError(t, err)
				require.Equal(t, "https://example.invalid/"+cfg.BinaryName+"-"+version+"-"+target+".zip", got)
			}
		})
	}
}
