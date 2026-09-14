//go:build !windows

package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestECashAdoptedCoreProcess(t *testing.T) {
	if os.Getenv("ECASH_ADOPT_CORE_TEST") == "1" {
		time.Sleep(time.Minute)
	}
}

func TestECashMigrationAdoptsTheSavedCorePhase(t *testing.T) {
	for _, step := range []int{1, 4} {
		name := "source rewind"
		if step == 4 {
			name = "target check"
		}
		t.Run(name, func(t *testing.T) {
			o := migrationTestNode(t)
			from := expandECashPlaceholder(o.rawConfigs["bitcoind"], "drynet4")
			to := expandECashPlaceholder(o.rawConfigs["bitcoind"], "alphanet")
			cfg := from
			if step == 4 {
				cfg = to
			}
			variant, ok := ResolveCoreVariant(cfg, "ecash", "ecash")
			require.True(t, ok)
			path := CoreBinaryPath(o.DataDir, variant, cfg.BinaryName)
			executable, err := os.Executable()
			require.NoError(t, err)
			body, err := os.ReadFile(executable)
			require.NoError(t, err)
			require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o700))
			require.NoError(t, os.WriteFile(path, body, 0o700))
			pid, err := o.process.Start(t.Context(), cfg, []string{"-test.run=^TestECashAdoptedCoreProcess$"}, map[string]string{"ECASH_ADOPT_CORE_TEST": "1"})
			require.NoError(t, err)
			t.Cleanup(func() {
				require.NoError(t, o.process.Stop(context.Background(), "bitcoind", true))
				require.True(t, o.process.WaitForExit("bitcoind", 5*time.Second))
			})
			require.True(t, o.pidManager.ValidatePid(pid, "bitcoind"))
			require.NoError(t, o.Settings.SetECashChainID("drynet4"))
			_, err = o.Settings.SetECashNetworkID("alphanet")
			require.NoError(t, err)
			require.NoError(t, o.saveMigration(&ecashMigration{
				Status: ECashMigrationStatus{JobID: "source-adoption", FromID: "drynet4", ToID: "alphanet"},
				Step:   step, FromConfig: from, ToConfig: to,
			}))
			next := New(o.DataDir, "ecash", o.BitwindowDir, AllDefaults(), testLogger(t))
			t.Cleanup(func() { next.process.Remove("bitcoind") })
			require.NoError(t, next.AdoptOrphans(t.Context()))
			adopted := next.process.Get("bitcoind")
			require.NotNil(t, adopted)
			require.Equal(t, pid, adopted.Pid)
			t.Logf("saved step %d: expected path %s; adopted path %s", step, path, adopted.BinPath)
			require.Equal(t, path, adopted.BinPath)
		})
	}
}
