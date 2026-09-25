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
	blocks := filepath.Join(root, "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o700))
	header, err := hex.DecodeString(magic)
	require.NoError(t, err)
	record := append(header, 80, 0, 0, 0)
	record = append(record, make([]byte, 80)...)
	require.NoError(t, os.WriteFile(filepath.Join(blocks, "blk00000.dat"), record, 0o600))
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
