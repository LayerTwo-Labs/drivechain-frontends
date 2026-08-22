package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// ecashInstall puts a test orchestrator on eCash with both datadir slots set.
func ecashInstall(t *testing.T) *Orchestrator {
	t.Helper()
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.coreReachable = func() bool { return false }
	o.log = zerolog.Nop()
	return o
}

// seedCoreChainData writes the block store an eCash install carries.
func seedCoreChainData(t *testing.T, datadir string) {
	t.Helper()
	for _, d := range []string{"blocks", "chainstate"} {
		require.NoError(t, os.MkdirAll(filepath.Join(datadir, d), 0o755))
		require.NoError(t, os.WriteFile(filepath.Join(datadir, d, "data"), []byte("chain"), 0o644))
	}
}

// An app update must never resync the chain. drynet4 -> alphanet is an offer,
// so startup serves the network the blocks belong to and leaves the move to
// the user.
func TestStartupKeepsTheChainWhenTheCatalogMovesOn(t *testing.T) {
	o := ecashInstall(t)
	datadir := o.ecashDatadir()
	require.NotEmpty(t, datadir)
	seedCoreChainData(t, datadir)

	// The install the user updated: blocks from drynet4, catalog on alphanet.
	o.BitcoinConf.Config.SetSetting("uacomment", config.ECashUAComment("drynet4"), "main")
	require.Equal(t, "drynet4", o.installedECashNetwork())
	require.NoError(t, netcatalog.Save(o.BitwindowDir, catalogWithECash(t, "alphanet")))

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet4", config.ECashNetworkID(), "startup must serve the network the blocks belong to")
	for _, d := range []string{"blocks", "chainstate"} {
		_, err := os.Stat(filepath.Join(datadir, d, "data"))
		require.NoErrorf(t, err, "%s must survive a start that sees a newer eCash network", d)
	}
	require.Equal(t, "alphanet", o.Catalog.ECashID(), "the offer still reaches the user")
}

// No blocks on disk, nothing to hold back: a fresh install takes what the
// catalog publishes.
func TestStartupTakesThePublishedNetworkWithNoChainOnDisk(t *testing.T) {
	o := ecashInstall(t)
	o.BitcoinConf.Config.SetSetting("uacomment", config.ECashUAComment("drynet4"), "main")
	require.NoError(t, netcatalog.Save(o.BitwindowDir, catalogWithECash(t, "alphanet")))

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "alphanet", config.ECashNetworkID())
}

// A network the user picked is not an offer. Startup applies it.
func TestStartupAppliesTheNetworkTheUserPicked(t *testing.T) {
	o := ecashInstall(t)
	seedCoreChainData(t, o.ecashDatadir())
	o.BitcoinConf.Config.SetSetting("uacomment", config.ECashUAComment("drynet4"), "main")
	require.NoError(t, netcatalog.Save(o.BitwindowDir, catalogWithECash(t, "alphanet")))
	_, err := o.Settings.SetECashNetworkID("alphanet")
	require.NoError(t, err)

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "alphanet", config.ECashNetworkID())
}

// A confirmed upgrade must leave the chain matching the network the conf names.
// Recording the pick alone would park Core on the retired fork for good.
func TestConfirmMovesTheChainToMatchTheConf(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.ResolveNetworkCatalog(context.Background())
	datadir := o.ecashDatadir()
	require.NotEmpty(t, datadir)
	seedCoreChainData(t, datadir)

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	require.Equal(t, "drynet3", config.ECashNetworkID())
	// No live Core answers in a test, so no rewind runs. The blocks stay either
	// way: both networks keep everything below the fork.
	_, err := os.Stat(filepath.Join(datadir, "blocks", "data"))
	require.NoError(t, err, "the blocks below the fork must survive the switch")
}

// The published network lives only in the pending document until a confirm
// promotes it. A plan that reads the served catalog alone cannot price the
// move, and the dialog then names a resync the switch never does.
func TestPlanReadsANetworkFromThePendingCatalog(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.ResolveNetworkCatalog(context.Background())

	_, served := o.Catalog.ByID("drynet3")
	require.False(t, served, "drynet3 must still be pending only")

	plan, err := o.PlanECashSwitch("drynet3")
	require.NoError(t, err)
	require.Equal(t, "drynet2", plan.FromID)
	require.Equal(t, "drynet3", plan.ToID)
}

// The rule the whole switch obeys: chain data is never deleted. A switch with
// no shared block stops, and the blocks stay where they are.
func TestASwitchWithNoForkHeightKeepsTheBlocks(t *testing.T) {
	o := ecashInstall(t)
	datadir := o.ecashDatadir()
	require.NotEmpty(t, datadir)
	seedCoreChainData(t, datadir)
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}, "drynet4")

	err := o.ApplyECashSwitch(context.Background(), "alphanet")

	require.Error(t, err)
	require.DirExists(t, filepath.Join(datadir, "blocks"), "the chain must survive a refused switch")
	require.Equal(t, "drynet4", o.installedECashNetwork(), "a refused switch moves nothing")
}

// The enforcer keeps one validator chain per network, not per fork, so every
// switch clears it. That work is journalled too: past the commit a retry reads
// FromID == ToID and skips the switch entirely.
func TestASwitchJournalsItsEnforcerCleanup(t *testing.T) {
	o := ecashInstall(t)
	o.adoptCatalog(ecashCatalog(), "drynet4")
	require.NoError(t, o.Settings.SetPendingEnforcerWipe("alphanet"))

	require.NoError(t, o.ApplyPendingEnforcerWipe())

	require.Empty(t, o.Settings.PendingEnforcerWipe(), "cleanup that ran clears its journal")
}

// A cleanup that cannot run keeps its record, so the next enforcer start
// retries rather than serving the retired generation's validator chain.
func TestAFailedEnforcerCleanupKeepsItsJournal(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)
	o := ecashInstall(t)
	require.NoError(t, o.Settings.SetPendingEnforcerWipe("alphanet"))

	validator := filepath.Join(config.EnforcerDirs.RootDir(), "validator")
	require.NoError(t, os.MkdirAll(filepath.Join(validator, "bitcoin"), 0o755))
	require.NoError(t, os.Chmod(validator, 0o000))
	t.Cleanup(func() { _ = os.Chmod(validator, 0o755) })

	if err := o.ApplyPendingEnforcerWipe(); err == nil {
		t.Skip("this filesystem reads the path anyway, so the failure cannot be staged")
	}

	require.Equal(t, "alphanet", o.Settings.PendingEnforcerWipe(),
		"cleanup that never ran must leave its journal")
}

// The record goes in before the switch commits, so an abort leaves one for a
// move that never happened. Applying it would delete the validator chain of the
// generation this install still runs.
func TestAnEnforcerCleanupForAnAbortedSwitchIsDropped(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)
	o := ecashInstall(t)
	// The install still runs drynet4: the switch to alphanet never committed.
	o.adoptCatalog(ecashCatalog(), "drynet4")
	require.NoError(t, o.Settings.SetPendingEnforcerWipe("alphanet"))

	chain := filepath.Join(config.EnforcerDirs.RootDir(), "validator", "bitcoin")
	require.NoError(t, os.MkdirAll(chain, 0o755))

	require.NoError(t, o.ApplyPendingEnforcerWipe())

	require.DirExists(t, chain, "the running generation's validator chain must survive")
	require.Empty(t, o.Settings.PendingEnforcerWipe(),
		"a cleanup for a network we never moved to must go")
}

// A pick made from another network reaches eCash through SwapNetwork, not
// ApplyECashSwitch, so the cold path has to record the enforcer cleanup itself.
func TestAColdPickRecordsTheEnforcerCleanup(t *testing.T) {
	o := ecashInstall(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkSignet))
	o.adoptCatalog(ecashCatalog(), "drynet4")

	require.NoError(t, o.SelectECashNetwork("alphanet"))

	require.Equal(t, "alphanet", o.Settings.PendingEnforcerWipe(),
		"the enforcer chain must be cleared before the new generation runs")
}

// eCash shares validator/bitcoin with mainnet and forknet. Off eCash the
// cleanup has to wait, or it deletes the chain the active network is using.
func TestTheEnforcerCleanupWaitsUntilECashIsActive(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)
	o := ecashInstall(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	o.adoptCatalog(ecashCatalog(), "alphanet")
	require.NoError(t, o.Settings.SetPendingEnforcerWipe("alphanet"))

	chain := filepath.Join(config.EnforcerDirs.RootDir(), "validator", "bitcoin")
	require.NoError(t, os.MkdirAll(chain, 0o755))

	require.NoError(t, o.ApplyPendingEnforcerWipe())

	require.DirExists(t, chain, "mainnet shares this chain, so it must survive")
	require.Equal(t, "alphanet", o.Settings.PendingEnforcerWipe(),
		"the cleanup waits for the swap that brings eCash back")
}

// With no fork height there is no shared block to reach, so the catalog stays
// where it is and nothing on disk moves.
func TestAChangeWithNoForkHeightHoldsTheCatalogBack(t *testing.T) {
	o := ecashInstall(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkSignet))
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}, "drynet4")

	require.False(t, o.ecashChangeHasASharedBlock("drynet4", "alphanet"))

	require.Empty(t, o.Settings.PendingEnforcerWipe(), "a change that cannot run journals nothing")
}

// An empty datadir override means Core's platform default, which is a
// supported setup. Reading it as "nothing on disk" lets a start adopt the
// published fork over blocks that are still there.
func TestTheDefaultDatadirCountsAsChainOnDisk(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)
	o := newTestOrchestrator(t)
	// No datadir slot and no datadir= line: Core falls back to its own default.
	o.setNetwork(string(config.NetworkECash))
	require.Empty(t, o.ecashDatadir(), "this install runs on the platform default")

	defaultDir := config.BitcoinCoreDirs.DatadirNetwork(config.NetworkECash, "")
	require.NoError(t, os.MkdirAll(filepath.Join(defaultDir, "blocks"), 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(defaultDir, "blocks", "blk00000.dat"), []byte("chain"), 0o644))

	require.True(t, o.ecashChainDataOnDisk(), "the default datadir holds the chain too")
}

// Only "not there" says the chain is gone. Any other refusal leaves blocks that
// may exist, and adopting the published fork over them needs the user first.
func TestAnUnreadableBlocksDirCountsAsChainOnDisk(t *testing.T) {
	o := ecashInstall(t)
	datadir := o.ecashDatadir()
	require.NotEmpty(t, datadir)
	seedCoreChainData(t, datadir)

	require.NoError(t, os.Chmod(filepath.Join(datadir, "blocks"), 0o000))
	t.Cleanup(func() { _ = os.Chmod(filepath.Join(datadir, "blocks"), 0o755) })

	if entries, err := os.ReadDir(filepath.Join(datadir, "blocks")); err == nil {
		_ = entries
		t.Skip("this filesystem reads the directory anyway, so the failure cannot be staged")
	}

	require.True(t, o.ecashChainDataOnDisk(), "a chain we cannot read is still a chain")
}

// The enforcer keeps one validator chain per network, so a pick that cannot
// record the cleanup must not stand: the new generation would run on the
// retired one's validator state.
func TestAPickPutsItselfBackWhenTheEnforcerCleanupCannotBeRecorded(t *testing.T) {
	o := ecashInstall(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkSignet))
	o.adoptCatalog(ecashCatalog(), "drynet4")
	require.NoError(t, o.SelectECashNetwork("drynet4"))

	// A settings file nothing can write makes the record fail.
	require.NoError(t, os.Chmod(o.BitwindowDir, 0o500))
	t.Cleanup(func() { _ = os.Chmod(o.BitwindowDir, 0o755) })

	err := o.SelectECashNetwork("alphanet")
	if err == nil {
		t.Skip("this filesystem writes the settings anyway, so the failure cannot be staged")
	}

	require.Equal(t, "drynet4", o.Settings.ECashNetworkID(), "a pick that cannot be finished must not stand")
}
