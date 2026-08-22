package orchestrator

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

func ecashCatalog() netcatalog.Catalog {
	return netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash, DisplayName: "Alphanet", ForkHeight: 963648},
		{ID: "drynet4", Family: netcatalog.FamilyECash, DisplayName: "Drynet 4", ForkHeight: 961632},
		{ID: "alphanet2", Family: netcatalog.FamilyECash, DisplayName: "Alphanet 2", ForkHeight: 970000},
	}}
}

// Both networks fork mainnet, so every block below the lower fork height is
// shared. Resetting there replays a few thousand blocks; wiping would download
// the whole chain again.
func TestPlanECashSwitchTargetsTheSharedBlock(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashCatalog(), "drynet4")

	plan, err := o.PlanECashSwitch("alphanet")
	require.NoError(t, err)
	require.True(t, plan.NeedsRollback)
	require.Equal(t, "drynet4", plan.FromID)
	require.Equal(t, "alphanet", plan.ToID)
	// One below the lower of the two, not the target's own fork: drynet4 forks
	// at 961632, so 961632 up belongs to no chain alphanet follows, and the
	// block of margin rules out an off-by-one keeping a divergent block.
	require.EqualValues(t, 961631, plan.RewindHeight)
}

// Off eCash no Core answers, so the drop is recorded rather than made. The
// blocks below the fork stay either way, and a plan that reported none would
// make the dialog name a resync that never happens.
func TestPlanECashSwitchPricesTheColdChainRewind(t *testing.T) {
	o := newTestOrchestrator(t)
	o.adoptCatalog(ecashCatalog(), "drynet4")
	require.NotEqual(t, string(config.NetworkECash), o.Network)

	plan, err := o.PlanECashSwitch("alphanet")
	require.NoError(t, err)
	require.True(t, plan.NeedsRollback)
	require.False(t, plan.Blocked)
	require.EqualValues(t, 961631, plan.RewindHeight)
}

// Staying put costs nothing, so the plan must not ask for a reset.
func TestPlanECashSwitchToTheRunningNetworkIsANoOp(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashCatalog(), "alphanet")

	plan, err := o.PlanECashSwitch("alphanet")
	require.NoError(t, err)
	require.False(t, plan.NeedsRollback)
}

func TestPlanECashSwitchRejectsANetworkTheCatalogOmits(t *testing.T) {
	o := newTestOrchestrator(t)
	o.adoptCatalog(ecashCatalog(), "alphanet")

	_, err := o.PlanECashSwitch("betanet")
	require.Error(t, err)
}

// The conf sentinel is what the next boot compares against. Leaving it on the
// old network would make that boot wipe the chain the reset just saved.
func TestApplyECashSwitchRewritesTheConfSentinel(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashCatalog(), "drynet4")
	require.Equal(t, "drynet4", o.installedECashNetwork())

	require.NoError(t, o.ApplyECashSwitch(context.Background(), "alphanet"))

	require.Equal(t, "alphanet", o.installedECashNetwork())
	require.Equal(t, "alphanet", o.SelectedECashID(ecashCatalog()))
	require.Equal(t, "alphanet", config.ECashNetworkID())
}

// A Core that is down cannot rewind, and nothing is recorded for later. The
// chain stays as it is: every block below the fork is shared either way.
func TestApplyECashSwitchKeepsTheChainWhenNoCoreAnswers(t *testing.T) {
	o := newTestOrchestrator(t)
	datadir := t.TempDir()
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, datadir)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.coreReachable = func() bool { return false }
	o.adoptCatalog(ecashCatalog(), "drynet4")

	blocks := filepath.Join(datadir, "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o755))

	require.NoError(t, o.ApplyECashSwitch(context.Background(), "alphanet"))

	require.DirExists(t, blocks, "the blocks below the fork must survive the switch")
	require.Equal(t, "alphanet", o.installedECashNetwork())
}

// No published fork height leaves nothing to rewind to, so the switch refuses
// and the chain stays where it is.
func TestApplyECashSwitchKeepsTheChainWithNoPublishedForkHeight(t *testing.T) {
	o := newTestOrchestrator(t)
	datadir := t.TempDir()
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, datadir)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.coreReachable = func() bool { return false }
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}, "drynet4")

	blocks := filepath.Join(datadir, "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o755))

	require.Error(t, o.ApplyECashSwitch(context.Background(), "alphanet"))

	require.DirExists(t, blocks, "chain data is never deleted")
}

// A pick from an earlier session outlives the prompt. Confirming a newly
// published network must move the pick too, or the next start boots the old one
// with nothing left to ask.
func TestConfirmPendingECashNetworkRepinsTheSelection(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.ResolveNetworkCatalog(context.Background())
	require.NoError(t, o.SelectECashNetwork("drynet2"))

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	cached, _ := netcatalog.Load(o.BitwindowDir)
	require.Equal(t, "drynet3", cached.ECashID())
	require.Equal(t, "drynet3", o.SelectedECashID(cached), "the pick must move with the confirmation")
}

// The pending catalog is the one that names the confirmed network, and the
// catalog this process serves does not list it yet. A check against the stale
// document drops the pick and the next start boots the old network again.
func TestConfirmPendingECashNetworkRepinsAnUnlistedID(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.ResolveNetworkCatalog(context.Background())
	require.Equal(t, "drynet2", o.ecashID, "the process still serves the old catalog")

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	settings, err := LoadSettings(o.BitwindowDir)
	require.NoError(t, err)
	require.Equal(t, "drynet3", settings.ECashNetworkID)
}

const (
	forkBlock   = "0000000000000000000111111111111111111111111111111111111111111111"
	staleMark   = "0000000000000000000222222222222222222222222222222222222222222222"
	sharedBlock = "0000000000000000000333333333333333333333333333333333333333333333"
	tipBlock    = "0000000000000000000444444444444444444444444444444444444444444444"
)

// invalidateblock bars the block and every descendant. Barring the last shared
// block would bar the incoming chain too, and Core could never move past it.
func TestDropForkAboveBarsTheFirstDivergentBlock(t *testing.T) {
	core := &fakeCore{
		tips:   []int64{979000},
		hashes: map[int64]string{979000: tipBlock, 961631: sharedBlock, 961632: forkBlock},
	}

	got, err := dropForkAbove(context.Background(), core.start(t), 961631, "")
	require.NoError(t, err)
	require.Equal(t, forkBlock, got, "the block above the fork is the one that goes")
	require.Equal(t, []string{"invalidateblock"}, marks(core))
	require.Equal(t, forkBlock, markParams(core)[0], "the shared block must survive")
}

// reconsiderblock revalidates the branch it clears, and a branch with more work
// becomes the active chain. A read after it would name the incoming fork and
// bar the very chain this switch moves to.
func TestDropForkAboveReadsTheBlockBeforeClearingTheOldMark(t *testing.T) {
	core := &fakeCore{
		tips:   []int64{979000},
		hashes: map[int64]string{979000: tipBlock, 961632: forkBlock},
	}

	got, err := dropForkAbove(context.Background(), core.start(t), 961631, staleMark)
	require.NoError(t, err)
	require.Equal(t, forkBlock, got)
	require.Less(t, lastIndexOf(core.methods, "getblockhash"), indexOf(core.methods, "reconsiderblock"),
		"the read has to come first")
	require.Equal(t, []string{"reconsiderblock", "invalidateblock"}, marks(core))
	require.Equal(t, []string{staleMark, forkBlock}, markParams(core))
}

// The chains part at no published height, so the blocks on disk belong to a
// fork this install cannot rewind out of.
func TestPlanECashSwitchIsBlockedWithoutAForkHeight(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash, ForkHeight: 963648},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}, "drynet4")

	plan, err := o.PlanECashSwitch("alphanet")
	require.NoError(t, err)
	require.False(t, plan.NeedsRollback)
	require.True(t, plan.Blocked, "no fork height means no shared block to roll back to")
}

// The slot swap writes bitcoin.conf and starts binaries, and both read the id
// from memory. A pick that only reached the settings file boots the old fork.
func TestAdoptECashIDMovesTheInMemoryState(t *testing.T) {
	o := newTestOrchestrator(t)
	o.adoptCatalog(ecashCatalog(), "drynet4")
	require.Equal(t, "drynet4", config.ECashNetworkID())

	o.AdoptECashID("alphanet")

	require.Equal(t, "alphanet", o.ecashID)
	require.Equal(t, "alphanet", config.ECashNetworkID())
	require.Equal(t, "alphanet", o.BitcoinConf.ECashID)
	require.EqualValues(t, 963648, config.PublishedForkHeight(config.NetworkECash))
}

// attachFakeCore points the orchestrator's Core RPC at a stub and reports the
// calls it receives. The client is cached behind a key, so seeding both makes
// CoreStatusClient hand back the stub.
func attachFakeCore(t *testing.T, o *Orchestrator, core *fakeCore) {
	t.Helper()
	// The client is built from the conf, so the conf has to carry credentials.
	o.BitcoinConf.Config.SetSetting("rpcuser", "user")
	o.BitcoinConf.Config.SetSetting("rpcpassword", "pass")
	// Let the real path build a client so the cache key matches what it derives,
	// then put the stub behind that same key.
	if _, err := o.CoreStatusClient(); err != nil {
		t.Fatalf("build core client: %v", err)
	}
	o.httpClientsMu.Lock()
	defer o.httpClientsMu.Unlock()
	o.coreStatusClient = core.start(t)
}

// A stop that fails after the rewind leaves Core parked under the fork with the
// old network still selected. The next try would ask for a block that no longer
// sits on the chain Core follows, so the drop has to come back.
func TestApplyECashSwitchTakesTheRewindBackWhenCoreWillNotStop(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashCatalog(), "drynet4")

	core := &fakeCore{tips: []int64{979000}, hashes: map[int64]string{979000: tipBlock, 961632: forkBlock}}
	attachFakeCore(t, o, core)
	o.process.AdoptProcess(o.configs["bitcoind"], 1)
	o.stopBinary = func(_ context.Context, name string, _ bool, _ ...StopOptions) error {
		return fmt.Errorf("stop %s refused", name)
	}

	err := o.ApplyECashSwitch(context.Background(), "alphanet")
	require.Error(t, err)

	require.Equal(t, []string{"invalidateblock", "reconsiderblock"}, marks(core),
		"the drop has to come back when the switch cannot go on")
	require.Equal(t, []string{forkBlock, forkBlock}, markParams(core))
	require.Empty(t, o.Settings.RewoundBlockHash(), "a drop taken back names no block")
	require.Equal(t, "drynet4", o.ecashID, "the old network stays selected")
	require.Equal(t, "drynet4", o.installedECashNetwork(), "the conf keeps naming the old network")
}

// The rewind needs the live Core that stopping bitcoind takes away, and every
// other daemon can refuse to stop. Those go first, while Core still answers.
func TestApplyECashSwitchStopsTheEnforcerBeforeTheRewind(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashCatalog(), "drynet4")

	core := &fakeCore{tips: []int64{979000}, hashes: map[int64]string{979000: tipBlock, 961632: forkBlock}}
	attachFakeCore(t, o, core)
	o.process.AdoptProcess(o.configs["enforcer"], 1)
	o.stopBinary = func(_ context.Context, name string, _ bool, _ ...StopOptions) error {
		return fmt.Errorf("stop %s refused", name)
	}

	err := o.ApplyECashSwitch(context.Background(), "alphanet")
	require.Error(t, err)
	require.Contains(t, err.Error(), "enforcer")
	require.Empty(t, core.methods, "no block may go until every fallible stop is done")
	require.Equal(t, "drynet4", o.ecashID)
}

// A rewind that fails for a transient reason — neither a dead Core nor a
// missing fork height — must leave every piece of state where it was.
func TestApplyECashSwitchKeepsEverythingWhenTheRewindFails(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashCatalog(), "drynet4")

	// A Core that this process believes runs but that answers nothing: the
	// rewind fails for a reason that is neither a dead Core nor a missing fork
	// height, which is the branch that aborts the switch.
	o.BitcoinConf.Config.SetSetting("rpcuser", "user")
	o.BitcoinConf.Config.SetSetting("rpcpassword", "pass")
	if _, err := o.CoreStatusClient(); err != nil {
		t.Fatalf("build core client: %v", err)
	}
	o.httpClientsMu.Lock()
	o.coreStatusClient = &CoreStatusClient{url: "http://127.0.0.1:1"}
	o.httpClientsMu.Unlock()
	o.process.AdoptProcess(o.configs["bitcoind"], 1)
	o.stopBinary = func(_ context.Context, name string, _ bool, _ ...StopOptions) error {
		o.process.Remove(name)
		return nil
	}
	err := o.ApplyECashSwitch(context.Background(), "alphanet")
	require.Error(t, err)

	// The restart itself needs a real StartWithL1 and has no seam, so this
	// covers the abort, not the recovery: nothing may move on a failed rewind.
	require.Equal(t, "drynet4", o.ecashID, "the old network stays selected")
	require.Equal(t, "drynet4", o.installedECashNetwork(), "the conf keeps naming it")
	require.Empty(t, o.Settings.RewoundBlockHash(), "no block was dropped")
	require.Nil(t, o.pendingSwap, "an abort installs no tail")
}

// The whole switch, over a live Core: it rewinds the chain, stops the daemons,
// moves the conf sentinel and clears the pending tail.
//
// The failing-tail branch is not covered here. finishNetworkSwap only fails
// through *wallet.WalletEngine, a concrete type with no seam, so nothing in a
// test can make it return an error.
func TestApplyECashSwitchRewindsAndLandsTheTarget(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashCatalog(), "drynet4")

	core := &fakeCore{tips: []int64{979000}, hashes: map[int64]string{979000: tipBlock, 961632: forkBlock}}
	attachFakeCore(t, o, core)
	o.process.AdoptProcess(o.configs["bitcoind"], 1)
	var stopped []string
	o.stopBinary = func(_ context.Context, name string, _ bool, _ ...StopOptions) error {
		stopped = append(stopped, name)
		o.process.Remove(name)
		return nil
	}

	require.NoError(t, o.ApplyECashSwitch(context.Background(), "alphanet"))

	require.Equal(t, []string{"invalidateblock"}, marks(core))
	require.Equal(t, []string{"bitcoind"}, stopped, "core stops only after the rewind reads it")
	require.Equal(t, "alphanet", o.installedECashNetwork())
	require.Equal(t, "alphanet", o.SelectedECashID(ecashCatalog()))
	require.Equal(t, forkBlock, o.Settings.RewoundBlockHash())
	require.Nil(t, o.pendingSwap, "a tail that lands leaves nothing pending")
}

// The conf goes before Core stops, so a failure there can still put the drop
// back. Once Core is down nothing can, and the retry would clear the chain the
// rewind saved.
func TestApplyECashSwitchTakesTheRewindBackWhenTheConfWillNotWrite(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashCatalog(), "drynet4")

	core := &fakeCore{tips: []int64{979000}, hashes: map[int64]string{979000: tipBlock, 961632: forkBlock}}
	attachFakeCore(t, o, core)
	o.process.AdoptProcess(o.configs["bitcoind"], 1)
	o.stopBinary = func(_ context.Context, name string, _ bool, _ ...StopOptions) error {
		o.process.Remove(name)
		return nil
	}
	// A directory in place of the conf file makes every write fail.
	require.NoError(t, os.Remove(o.BitcoinConf.ConfigPath))
	require.NoError(t, os.MkdirAll(o.BitcoinConf.ConfigPath, 0o755))

	err := o.ApplyECashSwitch(context.Background(), "alphanet")
	require.Error(t, err)

	require.Equal(t, []string{"invalidateblock", "reconsiderblock"}, marks(core),
		"a conf that will not write must leave the chain as it was")
	require.Empty(t, o.Settings.RewoundBlockHash())
	require.Equal(t, "drynet4", o.ecashID)
}

// Barring the outgoing branch while the incoming one is still barred parks Core
// under the fork with no chain to follow. A failure to clear the old mark has
// to stop the switch.
func TestDropForkAboveStopsWhenTheOldMarkWillNotClear(t *testing.T) {
	core := &fakeCore{
		tips:         []int64{979000},
		hashes:       map[int64]string{979000: tipBlock, 961632: forkBlock},
		reconsiderNo: true,
	}

	_, err := dropForkAbove(context.Background(), core.start(t), 961631, staleMark)
	require.Error(t, err)
	require.NotContains(t, core.methods, "invalidateblock",
		"nothing may be barred while the target branch is still barred")
}

// A hash from an earlier switch names a chain a wiped datadir no longer holds.
// Core reports that as block-not-found, which must not stop the switch.
func TestDropForkAboveIgnoresAnUnknownOldMark(t *testing.T) {
	core := &fakeCore{
		tips:              []int64{979000},
		hashes:            map[int64]string{979000: tipBlock, 961632: forkBlock},
		reconsiderUnknown: true,
	}

	got, err := dropForkAbove(context.Background(), core.start(t), 961631, staleMark)
	require.NoError(t, err)
	require.Equal(t, forkBlock, got)
	require.Contains(t, core.methods, "invalidateblock")
}

// marks lists the calls that change what Core follows, dropping the reads that
// resolve the target.
func marks(c *fakeCore) []string {
	var out []string
	for _, m := range c.methods {
		if m == "invalidateblock" || m == "reconsiderblock" {
			out = append(out, m)
		}
	}
	return out
}

// markParams lists the block each mark named, in call order.
func markParams(c *fakeCore) []string {
	var out []string
	for i, m := range c.methods {
		if m == "invalidateblock" || m == "reconsiderblock" {
			out = append(out, c.params[i])
		}
	}
	return out
}

func indexOf(list []string, want string) int {
	for i, v := range list {
		if v == want {
			return i
		}
	}
	return -1
}

func lastIndexOf(list []string, want string) int {
	found := -1
	for i, v := range list {
		if v == want {
			found = i
		}
	}
	return found
}

// A node still syncing below the fork holds no block either network disagrees
// on. Asking for one fails the switch until the chain catches up.
func TestDropForkAboveSkipsAChainBelowTheFork(t *testing.T) {
	core := &fakeCore{
		tips:   []int64{900000},
		hashes: map[int64]string{900000: tipBlock},
	}

	got, err := dropForkAbove(context.Background(), core.start(t), 961631, "")
	require.NoError(t, err)
	require.Empty(t, got, "nothing was dropped, so nothing is named")
	require.Empty(t, marks(core), "a chain below the fork needs no mark")
}

// A move back to a fork an earlier switch barred has to lift that bar even when
// the chain sits below the fork. Leaving it parks Core there for good.
func TestDropForkAboveClearsTheOldMarkBelowTheFork(t *testing.T) {
	core := &fakeCore{
		tips:   []int64{900000},
		hashes: map[int64]string{900000: tipBlock},
	}

	got, err := dropForkAbove(context.Background(), core.start(t), 961631, staleMark)
	require.NoError(t, err)
	require.Empty(t, got, "nothing was dropped, so nothing is named")
	require.Equal(t, []string{"reconsiderblock"}, marks(core), "the old bar still has to lift")
	require.Equal(t, []string{staleMark}, markParams(core))
}

// A rollback puts back every bar the rewind moved. Lifting one and leaving it
// lifted hands the chain to whichever branch carries more work.
func TestRestoreRewindPutsThePreviousMarkBack(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashCatalog(), "drynet4")
	require.NoError(t, o.Settings.SetRewoundBlockHash(staleMark))

	core := &fakeCore{tips: []int64{979000}, hashes: map[int64]string{979000: tipBlock, 961632: forkBlock}}
	attachFakeCore(t, o, core)
	o.process.AdoptProcess(o.configs["bitcoind"], 1)
	o.stopBinary = func(_ context.Context, name string, _ bool, _ ...StopOptions) error {
		return fmt.Errorf("stop %s refused", name)
	}

	require.Error(t, o.ApplyECashSwitch(context.Background(), "alphanet"))

	require.Equal(t, []string{"reconsiderblock", "invalidateblock", "reconsiderblock", "invalidateblock"},
		marks(core), "every bar the rewind moved goes back")
	require.Equal(t, []string{staleMark, forkBlock, forkBlock, staleMark}, markParams(core))
	require.Equal(t, staleMark, o.Settings.RewoundBlockHash(), "the recorded block goes back too")
}

// A move to an older network reaches the same shared block as a move to a newer
// one. This is the case that cost a user their chain: the pick fell back a
// generation, the code read it as a network with nothing in common, and it
// deleted blocks both networks still agree on.
func TestPlanECashSwitchRewindsBothWays(t *testing.T) {
	o := newTestOrchestrator(t)
	o.adoptCatalog(ecashCatalog(), "alphanet")

	plan, err := o.PlanECashSwitch("drynet4")

	require.NoError(t, err)
	require.True(t, plan.NeedsRollback)
	require.False(t, plan.Blocked)
	// The lower of the two fork heights, whichever way the move goes.
	require.EqualValues(t, 961631, plan.RewindHeight)
}

// The rule the whole eCash switch obeys: it rewinds, and it never deletes.
func TestEveryECashSwitchInTheCatalogRewinds(t *testing.T) {
	ids := []string{"alphanet", "drynet4", "alphanet2"}
	for _, from := range ids {
		for _, to := range ids {
			if from == to {
				continue
			}
			o := newTestOrchestrator(t)
			o.adoptCatalog(ecashCatalog(), from)

			plan, err := o.PlanECashSwitch(to)

			require.NoError(t, err)
			require.False(t, plan.Blocked, "%s -> %s must not be blocked", from, to)
			require.True(t, plan.NeedsRollback, "%s -> %s must rewind", from, to)
			require.NotZero(t, plan.RewindHeight, "%s -> %s must name a block", from, to)
		}
	}
}
