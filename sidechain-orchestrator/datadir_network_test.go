package orchestrator

import (
	"context"
	"encoding/hex"
	"os"
	"path/filepath"
	"runtime"
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

// A user can point two datadir groups at one place through a link, and the
// names then differ although Core reads the same blocks.
func TestSameDirReadsThroughALink(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("a link needs a privilege on windows")
	}
	real := t.TempDir()
	link := filepath.Join(t.TempDir(), "blocks")
	require.NoError(t, os.Symlink(real, link))

	require.True(t, sameDir(real, link))
	require.True(t, sameDir(real, real))
	require.False(t, sameDir(real, t.TempDir()))
	require.False(t, sameDir(real, filepath.Join(real, "nothing")), "a path that is absent stays apart")
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

// Core keeps one blocks directory per chain, so a switch to another chain
// reads another one and leaves these blocks where they are.
func TestReadDatadirNetworkReportsAnUnreadableSwitch(t *testing.T) {
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
	require.True(t, out.Mismatch)
	require.False(t, out.SwitchReadsBlocks, "bitcoin reads <root>/blocks, and these sit under signet")
}

// The eCash networks share one directory, so a switch between them reads these
// same blocks.
func TestReadDatadirNetworkReportsAReadableSwitch(t *testing.T) {
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
	require.True(t, out.Mismatch)
	require.True(t, out.SwitchReadsBlocks)
}

// The switch adopts a chain the records already name: it converts no block,
// and a rewind would bar a block that chain holds.
func TestChainAtTargetReadsTheRecord(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.ecashDatadir(), netcatalog.Embedded().Networks[0].NetworkMagic)
	require.NoError(t, o.Settings.SetECashChainID("betanet"))

	require.True(t, o.chainAtTarget("betanet"))
	require.False(t, o.chainAtTarget("alphanet"), "an alphanet switch converts the betanet files")
}

// A datadir with no ECX files takes the ordinary switch, which reads the chain
// from Core itself.
func TestChainAtTargetAnswersForAnEmptyDatadir(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = netcatalog.Embedded()

	require.False(t, o.chainAtTarget("betanet"))
}

// A job that stopped part way owes work, and the saved id can already name the
// target. The conversion finishes first.
func TestChainAtTargetWaitsForAConversion(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.ecashDatadir(), netcatalog.Embedded().Networks[0].NetworkMagic)
	require.NoError(t, o.Settings.SetECashChainID("betanet"))
	o.migrationState = &ecashMigration{
		Status: ECashMigrationStatus{JobID: "job1", FromID: "alphanet", ToID: "betanet"},
		Step:   2,
	}

	require.False(t, o.chainAtTarget("betanet"))
}

// Files that no record names take the conversion, which reads them itself.
func TestChainAtTargetRefusesUnnamedFiles(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.ecashDatadir(), netcatalog.Embedded().Networks[0].NetworkMagic)
	o.BitcoinConf.Config.RemoveSetting("uacomment", "main")
	o.BitcoinConf.Config.RemoveSetting("uacomment")

	require.False(t, o.chainAtTarget("betanet"))
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
