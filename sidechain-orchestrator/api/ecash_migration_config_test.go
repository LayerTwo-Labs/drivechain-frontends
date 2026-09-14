package api

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestECashMigrationBlocksConfigEdits(t *testing.T) {
	for _, name := range []string{"data directory", "config content", "network selection", "wallet data directory"} {
		t.Run(name, func(t *testing.T) {
			entered, release := make(chan struct{}), make(chan struct{})
			var enterOnce, releaseOnce sync.Once
			download := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				enterOnce.Do(func() { close(entered) })
				<-release
				http.Error(w, "fixture download stopped", http.StatusBadGateway)
			}))
			t.Cleanup(download.Close)
			t.Cleanup(func() { releaseOnce.Do(func() { close(release) }) })
			o := orchestrator.New(t.TempDir(), "ecash", t.TempDir(), nil, zerolog.New(io.Discard))
			picked := t.TempDir()
			root := filepath.Join(picked, "ecash")
			require.NoError(t, o.BitcoinConf.UpdateDataDir(picked, config.NetworkECash))
			require.NoError(t, o.SwapNetwork(t.Context(), config.NetworkECash))
			require.Equal(t, "ecash", o.CurrentNetwork())
			require.Equal(t, root, o.BitcoinConf.RootDataDir())
			var core orchestrator.BinaryConfig
			for _, cfg := range orchestrator.AllDefaults() {
				if cfg.Name == "bitcoind" {
					core = cfg
				}
			}
			for id, variant := range core.Variants {
				variant.BaseURL = download.URL + "/"
				core.Variants[id] = variant
			}
			data, err := json.Marshal(map[string]any{
				"status":   orchestrator.ECashMigrationStatus{JobID: "config-edit", FromID: "alphanet", ToID: "betanet", DataDir: root},
				"root_dir": root, "blocks_dir": filepath.Join(root, "blocks"), "from_config": core, "to_config": core,
			})
			require.NoError(t, err)
			require.NoError(t, os.WriteFile(filepath.Join(o.BitwindowDir, "ecash-migration.json"), data, 0o600))
			_, err = o.StartECashMigration(t.Context(), "alphanet", "betanet")
			require.NoError(t, err)
			t.Cleanup(func() {
				releaseOnce.Do(func() { close(release) })
				require.Eventually(t, func() bool {
					status, err := o.ECashMigrationStatus()
					return err == nil && !status.Running
				}, 10*time.Second, 10*time.Millisecond)
			})
			select {
			case <-entered:
			case <-time.After(10 * time.Second):
				status, err := o.ECashMigrationStatus()
				t.Fatalf("the migration did not reach the download: %+v, %v", status, err)
			}
			before, err := os.ReadFile(o.BitcoinConf.GetConfFilePath())
			require.NoError(t, err)
			handler := NewBitcoinConfHandler(o)
			edit := func() error {
				if name == "wallet data directory" {
					return o.SetDatadirForCurrentNetwork(t.TempDir())
				}
				if name == "config content" {
					_, err := handler.WriteBitcoinConfig(t.Context(), connect.NewRequest(&pb.WriteBitcoinConfigRequest{ConfigContent: string(before) + "\nmaxconnections=17\n"}))
					return err
				}
				if name == "network selection" {
					_, err := handler.SetBitcoinConfigNetwork(t.Context(), connect.NewRequest(&pb.SetBitcoinConfigNetworkRequest{DataDir: t.TempDir(), Network: "ecash"}))
					return err
				}
				_, err := handler.SetBitcoinConfigDataDir(t.Context(), connect.NewRequest(&pb.SetBitcoinConfigDataDirRequest{DataDir: t.TempDir(), Network: "ecash"}))
				return err
			}
			err = edit()
			t.Logf("config edit during migration: %v; root: %s", err, o.BitcoinConf.RootDataDir())
			require.ErrorContains(t, err, "ECX migration is active")
			after, err := os.ReadFile(o.BitcoinConf.GetConfFilePath())
			require.NoError(t, err)
			require.Equal(t, before, after)
			require.Equal(t, root, o.BitcoinConf.RootDataDir())
			releaseOnce.Do(func() { close(release) })
			require.Eventually(t, func() bool {
				status, err := o.ECashMigrationStatus()
				return err == nil && !status.Running
			}, 10*time.Second, 10*time.Millisecond)
			if name == "network selection" {
				err := edit()
				require.ErrorContains(t, err, "resume ECX migration")
				require.NotEqual(t, root, o.BitcoinConf.RootDataDir())
			} else {
				require.NoError(t, edit())
			}
		})
	}
}
