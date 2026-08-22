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
	// No live Core answers in a test, so the drop waits for the next boot. The
	// blocks stay either way: both networks keep everything below the fork.
	_, err := os.Stat(filepath.Join(datadir, "blocks", "data"))
	require.NoError(t, err, "the blocks below the fork must survive the switch")
	require.NotNil(t, o.Settings.PendingRewind(), "the drop must be recorded")
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

// A selection that goes back where it started leaves the recorded drop pointed
// at the fork now on disk. Making it would bar that fork's own first block.
func TestDeferredRewindIsDroppedWhenTheSelectionReverses(t *testing.T) {
	o := ecashInstall(t)
	o.adoptCatalog(ecashCatalog(), "drynet4")
	require.NoError(t, o.Settings.SetPendingRewind(
		&PendingRewind{FromID: "drynet4", ToID: "alphanet", Height: 961631}))

	require.NoError(t, o.ApplyPendingECashRewind(context.Background()))

	require.Nil(t, o.Settings.PendingRewind(), "a drop for a network we no longer run must go")
}

// The drop still runs when the selection stands.
func TestDeferredRewindRunsForTheSelectedNetwork(t *testing.T) {
	o := ecashInstall(t)
	o.adoptCatalog(ecashCatalog(), "alphanet")
	require.NoError(t, o.Settings.SetPendingRewind(
		&PendingRewind{FromID: "drynet4", ToID: "alphanet", Height: 961631}))

	// No Core answers, so the drop cannot be made and the record must survive
	// for the next boot.
	require.Error(t, o.ApplyPendingECashRewind(context.Background()))
	require.NotNil(t, o.Settings.PendingRewind(), "an unmade drop must outlive the boot")
}

// Two switches with no Core between them: A -> B, then B -> A. The blocks are
// still A's, so the record must go. Taking the source from the last pick would
// aim the drop at A's own first fork block.
func TestTwoDeferredSwitchesBackToTheChainOnDiskClearTheRecord(t *testing.T) {
	o := ecashInstall(t)
	o.adoptCatalog(ecashCatalog(), "drynet4")

	require.NoError(t, o.recordPendingRewind("drynet4", "alphanet"))
	require.Equal(t,
		&PendingRewind{FromID: "drynet4", ToID: "alphanet", Height: 961631},
		o.Settings.PendingRewind())

	require.NoError(t, o.recordPendingRewind("alphanet", "drynet4"))

	require.Nil(t, o.Settings.PendingRewind(), "back on the chain on disk, so nothing to drop")
}

// A third network keeps the original source: the blocks never moved.
func TestDeferredSwitchesKeepTheNetworkTheBlocksBelongTo(t *testing.T) {
	o := ecashInstall(t)
	o.adoptCatalog(ecashCatalog(), "drynet4")

	require.NoError(t, o.recordPendingRewind("drynet4", "alphanet"))
	require.NoError(t, o.recordPendingRewind("alphanet", "alphanet2"))

	record := o.Settings.PendingRewind()
	require.NotNil(t, record)
	require.Equal(t, "drynet4", record.FromID, "the source is what is on disk, not the last pick")
	require.Equal(t, "alphanet2", record.ToID)
}

// The pick is durable before the drop is. Leaving it while the drop went
// unrecorded lets a later boot serve the target over the source fork with
// nothing to invalidate it.
func TestSelectECashNetworkPutsThePickBackWhenTheDropCannotBeRecorded(t *testing.T) {
	o := ecashInstall(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkSignet))
	// No fork height tells the two apart, so the drop cannot be recorded; and
	// with no bitcoin config the delete that would replace it cannot run.
	o.adoptCatalog(catalogWithECash(t, "alphanet"), "drynet4")
	o.Catalog.Networks = append(o.Catalog.Networks, netcatalog.Network{
		ID: "drynet4", Family: netcatalog.FamilyECash,
	})
	for i := range o.Catalog.Networks {
		if o.Catalog.Networks[i].Family == netcatalog.FamilyECash {
			o.Catalog.Networks[i].ForkHeight = 0
		}
	}
	o.BitcoinConf = nil
	_, err := o.Settings.SetECashNetworkID("drynet4")
	require.NoError(t, err)

	require.Error(t, o.SelectECashNetwork("alphanet"))

	require.Equal(t, "drynet4", o.Settings.ECashNetworkID(),
		"an unrecorded drop must leave the pick where it was")
}

// A rewind that committed records its outcome and clears the drop in one write. Two writes
// leave a crash window where the next boot retries, and a retry reconsiders the
// block it just barred.
func TestRecordingARewindClearsThePendingDropInOneWrite(t *testing.T) {
	o := ecashInstall(t)
	require.NoError(t, o.Settings.SetPendingRewind(
		&PendingRewind{FromID: "drynet4", ToID: "alphanet", Height: 961631}))

	require.NoError(t, o.Settings.CommitRewind("00deadbeef"))

	require.Nil(t, o.Settings.PendingRewind(), "the drop must go with the outcome")
	require.Equal(t, "00deadbeef", o.Settings.RewoundBlockHash())
}

// A chain already below the fork bars nothing, so the rewind reports an empty
// hash. That write still has to clear the drop, or Core syncs past the fork and
// the next boot bars the target's own first block.
func TestRecordingAnEmptyRewindStillClearsThePendingDrop(t *testing.T) {
	o := ecashInstall(t)
	require.NoError(t, o.Settings.SetPendingRewind(
		&PendingRewind{FromID: "drynet4", ToID: "alphanet", Height: 961631}))

	require.NoError(t, o.Settings.CommitRewind(""))

	require.Nil(t, o.Settings.PendingRewind())
}

// No published fork height leaves nothing to rewind to, but the switch is still
// journalled: a crash before the delete would leave the target's conf over the
// source fork with nothing to clear it.
func TestASwitchWithNoForkHeightJournalsAWipe(t *testing.T) {
	o := ecashInstall(t)
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}, "drynet4")

	require.NoError(t, o.recordPendingRewind("drynet4", "alphanet"))

	record := o.Settings.PendingRewind()
	require.NotNil(t, record)
	require.True(t, record.Wipe, "with no fork height the old chain cannot stay")
	require.Zero(t, record.Height)
}

// The journalled wipe runs before Core opens the datadir, and clears itself.
func TestStartupMakesAJournalledWipe(t *testing.T) {
	o := ecashInstall(t)
	o.adoptCatalog(ecashCatalog(), "alphanet")
	datadir := o.ecashDatadir()
	require.NotEmpty(t, datadir)
	seedCoreChainData(t, datadir)
	require.NoError(t, o.Settings.SetPendingRewind(
		&PendingRewind{FromID: "drynet4", ToID: "alphanet", Wipe: true}))

	require.NoError(t, o.ApplyPendingECashWipe(context.Background()))

	require.NoDirExists(t, filepath.Join(datadir, "blocks"), "the retired chain must go")
	require.Nil(t, o.Settings.PendingRewind(), "a wipe that ran must not run again")
}

// A selection that moved on makes the journalled wipe moot. Making it anyway
// would delete the chain the install now runs.
func TestAJournalledWipeIsDroppedWhenTheSelectionMovesOn(t *testing.T) {
	o := ecashInstall(t)
	o.adoptCatalog(ecashCatalog(), "drynet4")
	datadir := o.ecashDatadir()
	seedCoreChainData(t, datadir)
	require.NoError(t, o.Settings.SetPendingRewind(
		&PendingRewind{FromID: "drynet4", ToID: "alphanet", Wipe: true}))

	require.NoError(t, o.ApplyPendingECashWipe(context.Background()))

	require.DirExists(t, filepath.Join(datadir, "blocks"), "the chain we run must survive")
	require.Nil(t, o.Settings.PendingRewind())
}

// A wipe that fails leaves the target committed, so a retry reads FromID ==
// ToID and skips the switch. The journal is what carries the work across.
func TestAMandatorySwitchJournalsItsWipeBeforeCommitting(t *testing.T) {
	o := ecashInstall(t)
	datadir := o.ecashDatadir()
	require.NotEmpty(t, datadir)
	seedCoreChainData(t, datadir)
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}, "drynet4")

	require.NoError(t, o.ApplyECashSwitch(context.Background(), "alphanet"))

	// The switch made the wipe itself, so the journal is spent.
	require.NoDirExists(t, filepath.Join(datadir, "blocks"))
	require.Nil(t, o.Settings.PendingRewind(), "a wipe that ran clears its journal")
	require.Equal(t, "alphanet", o.installedECashNetwork())
}

// The failure the journal exists for: the wipe cannot run, the target is
// already committed, and a retry reads FromID == ToID and skips the switch.
// Only the record carries the work to the next start.
func TestAFailedMandatoryWipeLeavesItsJournal(t *testing.T) {
	o := ecashInstall(t)
	datadir := o.ecashDatadir()
	require.NotEmpty(t, datadir)
	seedCoreChainData(t, datadir)
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}, "drynet4")

	// An unreadable datadir makes the wipe refuse rather than report success.
	require.NoError(t, os.Chmod(datadir, 0o000))
	t.Cleanup(func() { _ = os.Chmod(datadir, 0o755) })

	err := o.ApplyECashSwitch(context.Background(), "alphanet")
	if err == nil {
		t.Skip("this filesystem reads the datadir anyway, so the failure cannot be staged")
	}

	record := o.Settings.PendingRewind()
	require.NotNil(t, record, "a wipe that never ran must leave its journal")
	require.True(t, record.Wipe)
	require.Equal(t, "alphanet", record.ToID)
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

// The cold path with no fork height wipes Core, so the enforcer chain has to go
// too — and off eCash that work is journalled rather than made.
func TestAColdMandatoryWipeJournalsTheEnforcerCleanup(t *testing.T) {
	o := ecashInstall(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkSignet))
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}, "drynet4")

	require.True(t, o.wipeOnECashNetworkChange(context.Background(), "drynet4", "alphanet"))

	require.Equal(t, "alphanet", o.Settings.PendingEnforcerWipe(),
		"a wiped Core leaves an enforcer chain that has to go with it")
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

// A switch that died between its journal and its Core stop leaves a live Core
// on the retired fork under a conf naming the target. Only startup reaches it,
// and it has to before the listener binds.
func TestStartupMakesTheDropAgainstAnAdoptedCore(t *testing.T) {
	o := ecashInstall(t)
	o.adoptCatalog(ecashCatalog(), "alphanet")
	require.NoError(t, o.Settings.SetPendingRewind(
		&PendingRewind{FromID: "drynet4", ToID: "alphanet", Height: 961631}))

	// No Core answers, so there is nothing adopted and nothing to drop yet.
	o.coreReachable = func() bool { return false }
	require.NoError(t, o.ApplyPendingRewindToAdoptedCore(context.Background()))
	require.NotNil(t, o.Settings.PendingRewind(), "the drop waits for a Core that answers")

	// One that answers but refuses the RPC must not leave the boot running.
	o.coreReachable = func() bool { return true }
	require.Error(t, o.ApplyPendingRewindToAdoptedCore(context.Background()))
	require.NotNil(t, o.Settings.PendingRewind(), "an unmade drop must outlive the start")
}
