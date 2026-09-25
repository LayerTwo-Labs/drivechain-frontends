package orchestrator

import (
	"context"
	"encoding/hex"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

// writeBlockFile puts one record of a network magic into a blocks directory.
func writeBlockFile(t *testing.T, root, magic string) {
	t.Helper()
	writeBlockFileAs(t, root, "blk00000.dat", magic)
}

func writeBlockFileAs(t *testing.T, root, name, magic string) {
	t.Helper()
	blocks := filepath.Join(root, "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o700))
	header, err := hex.DecodeString(magic)
	require.NoError(t, err)
	record := append(header, 80, 0, 0, 0)
	record = append(record, make([]byte, 80)...)
	require.NoError(t, os.WriteFile(filepath.Join(blocks, name), record, 0o600))
}

// The blocks name the chain, so a datadir from another network says so before a
// rollback throws the balance away.
func TestReadDatadirNetworkNamesTheBlocks(t *testing.T) {
	cat := netcatalog.Embedded()
	alphanet, ok := cat.ByID("alphanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), alphanet.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, alphanet.NetworkMagic, out.Magic)
	require.Equal(t, "alphanet", out.DetectedID)
	require.Equal(t, "betanet", out.SelectedID)
	require.True(t, out.Mismatch)
}

// The blocks of the network the app runs report no mismatch.
func TestReadDatadirNetworkAgreesWithThePick(t *testing.T) {
	cat := netcatalog.Embedded()
	betanet, ok := cat.ByID("betanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), betanet.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.False(t, out.Mismatch)
	require.Equal(t, "betanet", out.DetectedID)
}

// The slot and its catalog row carry different names. A mainnet install must
// not read its own blocks as another network.
func TestReadDatadirNetworkAcceptsMainnetBlocks(t *testing.T) {
	cat := netcatalog.Embedded()
	bitcoin, ok := cat.ByID("bitcoin")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkMainnet))
	o.BitcoinConf.Network = config.NetworkMainnet
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), bitcoin.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "bitcoin", out.DetectedID)
	require.False(t, out.Mismatch, "mainnet blocks under a mainnet pick agree")
}

// Core keeps the blocks of every other network under that network's directory.
func TestReadDatadirNetworkReadsTheNetworkDirectory(t *testing.T) {
	cat := netcatalog.Embedded()
	bitcoin, ok := cat.ByID("bitcoin")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkSignet))
	o.BitcoinConf.Network = config.NetworkSignet
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), bitcoin.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "bitcoin", out.DetectedID, "the walk must read <root>/signet/blocks")
	require.True(t, out.Mismatch, "mainnet blocks under a signet pick disagree")
}

// Core adds the network subdirectory under an explicit blocksdir, so the walk
// must read <blocksdir>/signet/blocks.
func TestReadDatadirNetworkObeysBlocksdir(t *testing.T) {
	cat := netcatalog.Embedded()
	bitcoin, ok := cat.ByID("bitcoin")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkSignet))
	o.BitcoinConf.Network = config.NetworkSignet
	o.Catalog = cat
	blocksdir := t.TempDir()
	o.BitcoinConf.Config.SetSetting("blocksdir", blocksdir, "signet")
	writeBlockFile(t, filepath.Join(blocksdir, "signet"), bitcoin.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "bitcoin", out.DetectedID)
}

// A datadir with no blocks names no network, so the answer carries no mismatch
// and the app clears whatever it said before.
func TestReadDatadirNetworkReportsAnEmptyDatadir(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = netcatalog.Embedded()
	require.NoError(t, os.MkdirAll(filepath.Join(o.BitcoinConf.DataDir(), "blocks"), 0o700))

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Empty(t, out.Magic)
	require.Empty(t, out.DetectedID)
	require.False(t, out.Mismatch)
}

// A switch to the network the block files already carry adopts the chain on
// disk. The files hold that network's magic, so nothing converts them, and a
// rewind would drop blocks the chain keeps.
func TestDiskHoldsECashReadsTheBlocks(t *testing.T) {
	cat := netcatalog.Embedded()
	betanet, ok := cat.ByID("betanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), betanet.NetworkMagic)

	adopt, err := o.diskHoldsECash(context.Background(), "betanet")
	require.NoError(t, err)
	require.True(t, adopt, "the blocks already carry the betanet magic")

	adopt, err = o.diskHoldsECash(context.Background(), "alphanet")
	require.NoError(t, err)
	require.False(t, adopt, "alphanet blocks are not on disk, so the switch converts them")
}

// The catalog lists no regtest row, because nothing is deployed for it. The
// picker offers regtest, so its blocks name it.
func TestReadDatadirNetworkNamesRegtestBlocks(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkSignet))
	o.BitcoinConf.Network = config.NetworkSignet
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.BitcoinConf.DataDir(), regtestMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "regtest", out.DetectedID)
	require.Equal(t, "Regtest", out.DetectedName)
	require.True(t, out.Mismatch)
}

// A regtest install reads its own blocks, so it gets no warning.
func TestReadDatadirNetworkAgreesWithRegtest(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkRegtest))
	o.BitcoinConf.Network = config.NetworkRegtest
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.BitcoinConf.DataDir(), regtestMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "regtest", out.SelectedID)
	require.False(t, out.Mismatch)
}

// A datadir that two networks wrote holds the older one first. Core reads the
// older records with the magic it runs, so the conversion runs over them.
func TestDiskHoldsECashReadsBothEnds(t *testing.T) {
	cat := netcatalog.Embedded()
	alphanet, ok := cat.ByID("alphanet")
	require.True(t, ok)
	betanet, ok := cat.ByID("betanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = cat
	blocks := o.BitcoinConf.DataDir()
	writeBlockFile(t, blocks, alphanet.NetworkMagic)
	writeBlockFileAs(t, blocks, "blk00001.dat", betanet.NetworkMagic)

	adopt, err := o.diskHoldsECash(context.Background(), "betanet")
	require.NoError(t, err)
	require.False(t, adopt, "the oldest file still holds the alphanet magic")
}

// A half-run conversion writes the target magic to the newest file alone, so
// the rest still holds the source. The conversion finishes first.
func TestDiskHoldsECashWaitsForAConversion(t *testing.T) {
	cat := netcatalog.Embedded()
	betanet, ok := cat.ByID("betanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), betanet.NetworkMagic)
	o.migrationState = &ecashMigration{
		Status: ECashMigrationStatus{JobID: "job1", FromID: "alphanet", ToID: "betanet"},
		Step:   2,
	}

	adopt, err := o.diskHoldsECash(context.Background(), "betanet")
	require.NoError(t, err)
	require.False(t, adopt)
}

// An empty datadir names no network, so the ordinary switch runs.
func TestDiskHoldsECashAnswersForAnEmptyDatadir(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = netcatalog.Embedded()

	adopt, err := o.diskHoldsECash(context.Background(), "betanet")
	require.NoError(t, err)
	require.False(t, adopt)
}

// A datadir with no blocks directory names no network, so the app shows no
// warning and the caller reads an empty answer.
func TestReadDatadirNetworkAcceptsAnAbsentBlocksDir(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = netcatalog.Embedded()

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.False(t, out.Mismatch)
	require.Empty(t, out.DetectedID)
}
