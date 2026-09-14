package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

func TestECashMigrationKeepsExternalCore(t *testing.T) {
	for _, orphan := range []bool{false, true} {
		name := "other launcher"
		if orphan {
			name = "orphan without owner lock"
		}
		t.Run(name, func(t *testing.T) {
			ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
			defer cancel()
			o, fixture, launcher, block, _, wallet := prepareAdoptedMigrationCore(t, ctx, orphan)
			if orphan {
				o.SetOwnerLock(nil)
			}
			require.False(t, o.mayStopAdopted("bitcoind"))
			cfg, err := o.getConfig("bitcoind")
			require.NoError(t, err)
			pid := launcher.Get("bitcoind").Pid

			entry := config.ECashEndpoints()
			entry.Backends = []netcatalog.Backend{{Kind: netcatalog.KindEsplora, URL: "http://" + fixture.Address}}
			config.SetECashEndpoints(entry)
			require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
			err = o.SetNodeMode(ctx, NodeModeLight)
			require.ErrorContains(t, err, "its own launcher")
			require.True(t, launcher.IsRunning("bitcoind"))
			progress, err := o.ShutdownAll(ctx, false)
			require.NoError(t, err)
			for item := range progress {
				require.NoError(t, item.Error)
			}
			require.True(t, launcher.IsRunning("bitcoind"))
			require.Nil(t, o.process.Get("bitcoind"))
			o.process.AdoptProcess(cfg, pid)
			require.False(t, o.mayStopAdopted("bitcoind"))

			_, err = o.StartECashMigration(ctx, "alphanet", "betanet")
			require.NoError(t, err)
			status := waitMigrationEngineTest(t, o)
			t.Logf("migration complete: %t; external Core active: %t; error: %s", status.Complete, launcher.IsRunning("bitcoind"), status.Error)
			require.False(t, status.Complete)
			require.Contains(t, status.Error, "external")
			require.True(t, launcher.IsRunning("bitcoind"))
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			for path, original := range map[string][]byte{"blocks/blk00000.dat": block, "wallets/migration/wallet.dat": wallet} {
				data, err := os.ReadFile(filepath.Join(fixture.DataDir, filepath.FromSlash(path)))
				require.NoError(t, err)
				require.Equal(t, original, data)
			}
		})
	}
}

func TestECashMigrationStopsOwnedCoreOrphan(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	o, fixture, launcher, block, undo, wallet := prepareAdoptedMigrationCore(t, ctx, true)
	_, err := o.StartECashMigration(ctx, "alphanet", "betanet")
	require.NoError(t, err)
	status := waitMigrationEngineTest(t, o)
	requireMigrationEngineResult(t, o, fixture, status, block, undo, wallet)
	require.False(t, launcher.IsRunning("bitcoind"))
}

func prepareAdoptedMigrationCore(t *testing.T, ctx context.Context, orphan bool) (*Orchestrator, migrationCoreFixture, *ProcessManager, []byte, []byte, []byte) {
	t.Helper()
	o, fixture, block, undo, wallet := prepareMigrationEngineTest(t, "", false)
	require.NoError(t, o.stopMigrationCore(ctx))
	lock, held, err := TakeOwnerLock(o.DataDir)
	require.NoError(t, err)
	require.True(t, held)
	o.SetOwnerLock(lock)
	t.Cleanup(func() { require.NoError(t, lock.Release()) })

	launcher := NewProcessManager(o.DataDir, NewPidFileManager(t.TempDir(), testLogger(t)), testLogger(t))
	launcher.CoreVariant = o.process.CoreVariant
	cfg, err := o.getConfig("bitcoind")
	require.NoError(t, err)
	pid, err := launcher.Start(ctx, cfg, []string{"-datadir=" + fixture.DataDir, "-networkactive=1"}, nil)
	require.NoError(t, err)
	child := launcher.Get("bitcoind")
	t.Cleanup(func() {
		if process := o.process.Get("bitcoind"); process != nil && process.Pid == pid {
			o.process.Remove("bitcoind")
		}
		require.NoError(t, launcher.StopAll(context.Background(), true))
		select {
		case <-child.ExitCh():
		case <-time.After(5 * time.Second):
			t.Fatal("the Core fixture did not exit")
		}
	})
	require.Eventually(t, o.coreRPCReachable, 5*time.Second, 25*time.Millisecond)
	if orphan {
		require.NoError(t, o.pidManager.WritePidFile(child.PidName, pid))
	}
	o.process.AdoptProcess(cfg, pid)
	require.True(t, o.process.IsAdopted("bitcoind"))
	require.Equal(t, orphan, o.process.IsOrphan("bitcoind"))
	require.Equal(t, orphan, o.mayStopAdopted("bitcoind"))
	return o, fixture, launcher, block, undo, wallet
}
