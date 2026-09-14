package orchestrator

import (
	"context"
	"encoding/binary"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

func TestECashCatalogKeepsLegacyWalletIdentity(t *testing.T) {
	for _, name := range []string{"wallet.dat", "legacy.dat", "cold/wallet.dat"} {
		t.Run(name, func(t *testing.T) {
			o := migrationTestNode(t)
			path, before := writeLegacyMigrationWallet(t, o, name)
			catalog := o.Catalog
			o.Catalog = netcatalog.Catalog{}
			o.configs["bitcoind"] = o.rawConfigs["bitcoind"]

			o.adoptCatalog(catalog, "alphanet")

			require.Equal(t, catalog, o.Catalog)
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			plan, err := o.PlanECashSwitch("betanet")
			require.NoError(t, err)
			require.True(t, plan.HasChainData)
			require.Equal(t, "alphanet", plan.ChainID)
			cfg, err := o.getConfig("bitcoind")
			require.NoError(t, err)
			variant, ok := ResolveCoreVariant(cfg, "ecash", "ecash")
			require.True(t, ok)
			require.Contains(t, CoreBinaryPath(o.DataDir, variant, cfg.BinaryName), "alphanet")
			require.NoError(t, o.checkECashMigrationStart(context.Background(), cfg))
			after, err := os.ReadFile(path)
			require.NoError(t, err)
			require.Equal(t, before, after)
		})
	}
}

func TestECashMigrationRejectsLegacyWalletBeforeAJob(t *testing.T) {
	for _, chain := range []bool{false, true} {
		name := "wallet only"
		if chain {
			name = "retained blocks"
		}
		t.Run(name, func(t *testing.T) {
			o := migrationTestNode(t)
			path, before := writeLegacyMigrationWallet(t, o, "cold/wallet.dat")
			if chain {
				blocks := filepath.Join(o.BitcoinConf.DataDir(), "blocks")
				require.NoError(t, os.MkdirAll(blocks, 0o700))
				require.NoError(t, os.WriteFile(filepath.Join(blocks, "blk00000.dat"), []byte("retained blocks"), 0o600))
			}
			_, err := o.newMigration("alphanet", "betanet")
			require.ErrorContains(t, err, "SQLite")
			_, err = o.PreviewECashMigration(context.Background(), "alphanet", "betanet")
			require.ErrorContains(t, err, "SQLite")
			_, err = o.StartECashMigration(context.Background(), "alphanet", "betanet")
			require.ErrorContains(t, err, "SQLite")
			status, err := o.ECashMigrationStatus()
			require.NoError(t, err)
			require.Empty(t, status.JobID)
			_, err = os.Stat(o.migrationPath())
			require.ErrorIs(t, err, os.ErrNotExist)
			after, err := os.ReadFile(path)
			require.NoError(t, err)
			require.Equal(t, before, after)
		})
	}
}

func writeLegacyMigrationWallet(t *testing.T, o *Orchestrator, name string) (string, []byte) {
	t.Helper()
	path := filepath.Join(o.BitcoinConf.DataDir(), "wallets", filepath.FromSlash(name))
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o700))
	data := make([]byte, 4096)
	binary.BigEndian.PutUint32(data[12:16], 0x00053162)
	require.NoError(t, os.WriteFile(path, data, 0o600))
	return path, data
}
