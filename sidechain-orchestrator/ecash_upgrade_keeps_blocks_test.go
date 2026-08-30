package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"testing"
	"time"

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
	publish(t, o, catalogWithECash(t, "alphanet"))

	o.ResolveNetworkCatalog(context.Background())
	awaitRefresh(t, o, "alphanet")

	require.Equal(t, "drynet4", config.ECashNetworkID(), "startup must serve the network the blocks belong to")
	for _, d := range []string{"blocks", "chainstate"} {
		_, err := os.Stat(filepath.Join(datadir, d, "data"))
		require.NoErrorf(t, err, "%s must survive a start that sees a newer eCash network", d)
	}
	require.Equal(t, "alphanet", o.Catalog.ECashID(), "the offer still reaches the user")
}

// A network the user picked is not an offer. Startup applies it.
func TestStartupAppliesTheNetworkTheUserPicked(t *testing.T) {
	o := ecashInstall(t)
	seedCoreChainData(t, o.ecashDatadir())
	o.BitcoinConf.Config.SetSetting("uacomment", config.ECashUAComment("drynet4"), "main")
	publish(t, o, catalogWithECash(t, "alphanet"))
	_, err := o.Settings.SetECashNetworkID("alphanet")
	require.NoError(t, err)

	o.ResolveNetworkCatalog(context.Background())
	awaitRefresh(t, o, "alphanet")

	require.Equal(t, "alphanet", config.ECashNetworkID())
}

// A confirmed upgrade must leave the chain matching the network the conf names.
// Recording the pick alone would park Core on the retired fork for good.
func TestConfirmMovesTheChainToMatchTheConf(t *testing.T) {
	o := ecashOnPendingNetwork(t)
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

// The dialog states what the move costs, so the plan reads both networks out of
// the document this process serves.
func TestPlanPricesThePublishedNetwork(t *testing.T) {
	o := ecashOnPendingNetwork(t)

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

// A switch in flight is not an aborted one. An enforcer restart that lands
// between the record and the commit would read it as aborted and drop a cleanup
// that is still owed, leaving the retired generation's chain in place.
func TestAnEnforcerCleanupWaitsForTheSwitchThatJournalledIt(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)
	o := ecashInstall(t)
	o.adoptCatalog(ecashCatalog(), "drynet4")
	require.NoError(t, o.Settings.SetPendingEnforcerWipe("alphanet"))

	chain := filepath.Join(config.EnforcerDirs.RootDir(), "validator", "bitcoin")
	require.NoError(t, os.MkdirAll(chain, 0o755))

	// A switch to alphanet in flight: its record is written and the selection
	// still names the fork this install is leaving.
	o.swapNetworkMu.Lock()
	done := make(chan error, 1)
	go func() { done <- o.ApplyPendingEnforcerWipe() }()
	select {
	case <-done:
		t.Fatal("a restart must not consume the record of a switch in flight")
	case <-time.After(100 * time.Millisecond):
	}

	// The switch commits, so the cleanup now names the generation that runs.
	o.mu.Lock()
	o.ecashID = "alphanet"
	o.mu.Unlock()
	o.swapNetworkMu.Unlock()

	require.NoError(t, <-done)
	require.NoDirExists(t, chain, "the retired generation's validator chain must go")
	require.Empty(t, o.Settings.PendingEnforcerWipe(), "cleanup that ran clears its journal")
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
