package config

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

// The retired forknet conf says chain=main, so an unmigrated install would
// read as mainnet and run Core over a fork's chain directory.
func TestMigrationMovesAForknetConfigOffMainnet(t *testing.T) {
	config := ParseBitcoinConfig(`# bitwindow-bitcoin-conf-version=11
chain=main
datadir=/vol/forknet-chain

[main]
port=8300
rpcport=18301
drivechain=1
`)

	migrated, wipe := RunBitcoinConfMigrations(config)

	require.True(t, migrated)
	require.Empty(t, wipe, "the migration keeps the chain the user already synced")
	require.Equal(t, NetworkSignet, NetworkFromConfig(config, NetworkSignet))
	require.Empty(t, config.GetSetting("datadir"), "mainnet must not inherit the forknet directory")
	require.Equal(t, BitcoinConfMigrationsVersion, config.ConfigVersion)
}

// The predicate reads forknet's own RPC port, so every other chain=main
// config keeps its network and its directory.
func TestMigrationLeavesEveryOtherChainMainConfigAlone(t *testing.T) {
	for name, conf := range map[string]string{
		"mainnet": "chain=main\ndatadir=/vol/bitcoin\n",
		"ecash":   "chain=main\ndatadir=/vol/ecash\n\n[main]\nport=8301\nrpcport=18302\ndrivechain=1\nuacomment=ecash-alphanet\n",
	} {
		t.Run(name, func(t *testing.T) {
			config := ParseBitcoinConfig(conf)
			before := NetworkFromConfig(config, NetworkSignet)

			RunBitcoinConfMigrations(config)

			require.Equal(t, before, NetworkFromConfig(config, NetworkSignet))
			require.NotEmpty(t, config.GetSetting("datadir"))
		})
	}
}

// A config already at the current version carries no forknet install, and a
// second run must not move a network the user chose since.
func TestForknetMigrationRunsOneTime(t *testing.T) {
	config := ParseBitcoinConfig("chain=main\ndatadir=/vol/forknet-chain\n\n[main]\nrpcport=18301\n")

	RunBitcoinConfMigrations(config)
	config.SetSetting("chain", "main")
	config.SetSetting("datadir", "/vol/bitcoin")

	RunBitcoinConfMigrations(config)

	require.Equal(t, "main", config.GetSetting("chain"))
	require.Equal(t, "/vol/bitcoin", config.GetSetting("datadir"))
}

// A forknet user who changed the RPC port, or who wrote the longer chain
// spelling, still runs forknet. The migration reads what the network meant,
// not the ports the default template happened to write.
func TestMigrationReadsAForknetConfigTheUserEdited(t *testing.T) {
	for name, conf := range map[string]string{
		"another rpc port": "# bitwindow-bitcoin-conf-version=11\nchain=main\ndatadir=/vol/fork\n\n[main]\nrpcport=19999\ndrivechain=1\n",
		"long chain name":  "# bitwindow-bitcoin-conf-version=11\nchain=mainnet\ndatadir=/vol/fork\n\n[main]\nrpcport=18301\ndrivechain=1\n",
	} {
		t.Run(name, func(t *testing.T) {
			config := ParseBitcoinConfig(conf)

			RunBitcoinConfMigrations(config)

			require.Equal(t, NetworkSignet, NetworkFromConfig(config, NetworkSignet))
			require.Empty(t, config.GetSetting("datadir"))
		})
	}
}

// A private bitcoin.conf skips the migrations, because the file belongs to the
// user. The load path must still refuse to read a retired network as mainnet.
func TestPrivateForknetConfIsNotAdopted(t *testing.T) {
	tmpDir := t.TempDir()
	SetHomeDir(tmpDir)
	t.Cleanup(func() { SetHomeDir("") })

	m := newTestManager(tmpDir)
	m.Network = NetworkECash

	confDir := BitcoinCoreDirs.RootDirNetwork(m.Network)
	require.NoError(t, os.MkdirAll(confDir, 0o755))
	private := filepath.Join(confDir, "bitcoin.conf")
	require.NoError(t, os.WriteFile(private, []byte("chain=main\ndatadir=/vol/fork\n\n[main]\ndrivechain=1\n"), 0o644))

	require.False(t, m.tryLoadPrivateConfig(), "a forknet conf must not become the source of truth")
	require.False(t, m.HasPrivateConf)
	require.NotEqual(t, private, m.GetConfFilePath(), "bitcoind must not get the forknet conf")
}

// A private conf for a network the app still runs stays the source of truth.
func TestPrivateECashConfIsAdopted(t *testing.T) {
	tmpDir := t.TempDir()
	SetHomeDir(tmpDir)
	t.Cleanup(func() { SetHomeDir("") })

	m := newTestManager(tmpDir)
	m.Network = NetworkECash

	confDir := BitcoinCoreDirs.RootDirNetwork(m.Network)
	require.NoError(t, os.MkdirAll(confDir, 0o755))
	private := filepath.Join(confDir, "bitcoin.conf")
	conf := "chain=main\ndatadir=/vol/ecash\n\n[main]\ndrivechain=1\nuacomment=" + ECashUAComment("alphanet") + "\n"
	require.NoError(t, os.WriteFile(private, []byte(conf), 0o644))

	require.True(t, m.tryLoadPrivateConfig())
	require.True(t, m.HasPrivateConf)
	require.Equal(t, private, m.GetConfFilePath())
}

// A forknet install that once ran signet recorded a directory for the default
// group. Signet must land back in it, rather than start an empty node in the
// platform default and sync the chain again.
func TestMigrationGivesBackTheSavedDefaultDatadir(t *testing.T) {
	config := ParseBitcoinConfig(`# bitwindow-bitcoin-conf-version=11
# bitwindow-datadir-default=/chosen/path
chain=main
datadir=/vol/forknet-chain

[main]
drivechain=1
`)

	RunBitcoinConfMigrations(config)

	require.Equal(t, NetworkSignet, NetworkFromConfig(config, NetworkSignet))
	require.Equal(t, "/chosen/path", config.GetSetting("datadir"))
}
