package orchestrator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// ECashSwitchPlan is what a move from one eCash network to another costs.
type ECashSwitchPlan struct {
	// FromID and ToID are the eCash networks the move goes between.
	FromID string
	ToID   string
	// RewindHeight is the height the chain ends at once the switch runs: one
	// below the lower fork height, the last block both networks share.
	RewindHeight uint32
	// NeedsRollback is false when nothing on disk belongs to the old network.
	NeedsRollback bool
	// Blocked means the switch cannot run: the blocks on disk belong to another
	// eCash fork and no published fork height says where the two part, so
	// nothing can roll back to shared history. Chain data is never deleted.
	Blocked bool
}

// PlanECashSwitch works out how to reach another eCash network from the one
// this install runs. Both networks fork mainnet, so every block below the lower
// fork height is shared history: a rewind to that height keeps it and drops
// only what the retired fork added. Blocked says no published fork height
// tells the two apart, so there is no shared block to roll back to.
//
// It prices the move from another network too. The chain is cold there and no
// Core answers, but the drop is recorded rather than made, so the blocks below
// the fork stay either way and the caller must not name a resync.
func (o *Orchestrator) PlanECashSwitch(toID string) (ECashSwitchPlan, error) {
	o.mu.RLock()
	fromID := o.ecashID
	o.mu.RUnlock()

	to, ok := o.ecashEntry(toID)
	if !ok {
		return ECashSwitchPlan{}, fmt.Errorf("no network %q in the catalog", toID)
	}
	if to.Family != netcatalog.FamilyECash {
		return ECashSwitchPlan{}, fmt.Errorf("%q is not an eCash network", toID)
	}
	plan := ECashSwitchPlan{FromID: fromID, ToID: toID}
	if fromID == "" || fromID == toID {
		return plan, nil
	}
	from, ok := o.ecashEntry(fromID)
	if !ok || from.ForkHeight <= 0 || to.ForkHeight <= 0 {
		// Nothing says where the chains part, so no rewind can reach shared
		// history. The switch stops rather than cost the user their blocks.
		plan.Blocked = true
		return plan, nil
	}
	shared := from.ForkHeight
	if to.ForkHeight < shared {
		shared = to.ForkHeight
	}
	// The fork height is the first block of the fork, so the chain ends one
	// below it.
	if shared <= 1 {
		plan.Blocked = true
		return plan, nil
	}
	plan.RewindHeight = uint32(shared - 1)
	plan.NeedsRollback = true
	return plan, nil
}

// ecashEntry finds a published eCash network by id in the catalog this process
// serves.
func (o *Orchestrator) ecashEntry(id string) (netcatalog.Network, bool) {
	o.mu.RLock()
	cat := o.Catalog
	o.mu.RUnlock()
	return cat.ByID(id)
}

// RetargetECashEnforcerConf moves a persisted enforcer preset onto the eCash
// network this install is about to run. The swap that brings eCash back writes
// bitcoin.conf but not this file, and GetCliArgs gives a persisted value
// precedence — so a preset left naming the retired fork boots the enforcer
// against it.
//
// Call it before the swap. The swap starts the L1 boot on a goroutine, and that
// boot reads this file at once: a rewrite after it wins the file and loses the
// race.
func (o *Orchestrator) RetargetECashEnforcerConf(previousID string) {
	if o.EnforcerConf == nil {
		return
	}
	o.mu.RLock()
	id := o.ecashID
	o.mu.RUnlock()
	switch changed, err := o.EnforcerConf.RetargetECashNetworkFor(config.NetworkECash, previousID, id); {
	case err != nil:
		o.log.Warn().Err(err).Msg("could not rewrite bitwindow-enforcer.conf for the new eCash network")
	case changed:
		o.log.Info().Str("network", id).Msg("rewrote bitwindow-enforcer.conf for the new eCash network")
	}
}

// AdoptECashID points this process at an eCash network without touching the
// chain. A pick made from another network takes this path: the slot swap that
// follows writes bitcoin.conf and starts binaries, and both read the id from
// here, so a stale one boots the network the user just left.
func (o *Orchestrator) AdoptECashID(id string) {
	// Logged, not returned: the swap that follows writes the conf sentinel, and
	// that sentinel names the network this install runs.
	if err := o.recordECashChain(id); err != nil {
		o.log.Warn().Err(err).Msg("could not record the eCash network this install runs")
	}

	o.mu.Lock()
	cat := o.Catalog
	o.ecashID = id
	for name, raw := range o.rawConfigs {
		o.configs[name] = expandECashPlaceholder(raw, id)
	}
	o.mu.Unlock()

	config.SetECashNetworkID(id)
	if entry, ok := cat.ByID(id); ok {
		config.SetForkHeight(config.NetworkECash, entry.ForkHeight)
		config.SetNetworkDisplayName(config.NetworkECash, entry.DisplayName)
		config.SetECashEndpoints(entry)
	}
	if o.BitcoinConf != nil {
		o.BitcoinConf.ECashID = id
	}
}

// resumeECashSwitch finishes a switch that moved the chain but stopped before
// its records or its restart. A request for the network this install already
// serves is that retry, and it does nothing when there is nothing left to do.
//
// Call it with swapNetworkMu held.
func (o *Orchestrator) resumeECashSwitch(toID string) error {
	if o.pendingSwap != nil && o.pendingSwap.network == config.NetworkECash {
		return o.finishECashSwitch(o.pendingSwap.fromECashID, toID, o.pendingSwap.restartL1)
	}
	// No tail, so the records are all an earlier run can still owe. Both skip an
	// unchanged value, which is what an ordinary same-target request finds.
	if err := o.recordECashChain(toID); err != nil {
		return err
	}
	if err := o.SelectECashNetwork(toID); err != nil {
		return fmt.Errorf("record the network pick: %w", err)
	}
	return nil
}

// finishECashSwitch runs everything a switch owes once the chain and the conf
// both moved, and then restarts the stack. A retry runs the same steps.
//
// Call it with swapNetworkMu held.
func (o *Orchestrator) finishECashSwitch(fromID, toID string, restartL1 bool) error {
	if err := o.recordECashSwitch(fromID, toID); err != nil {
		return err
	}
	o.log.Info().
		Str("previous", fromID).
		Str("current", toID).
		Msg("switched eCash network")

	return o.finishNetworkSwap(config.NetworkECash, restartL1)
}

// recordECashSwitch is everything a switch owes apart from the restart: the two
// records, the enforcer conf, the wallet scans, the enforcer chain and the
// caches. A swap to another network drains a tail through this, because that
// swap starts its own stack.
//
// Call it with swapNetworkMu held.
func (o *Orchestrator) recordECashSwitch(fromID, toID string) error {
	// The blocks are on the new fork from here, and a swap to another network
	// strips the conf sentinel that says so. A record that stays on the outgoing
	// fork sends a later start after blocks this switch already moved.
	if err := o.recordECashChain(toID); err != nil {
		return err
	}
	// Only once the chain and the conf both moved. A pick recorded ahead of a
	// failed switch would make the next boot read the old sentinel as stale and
	// clear a chain this run still holds.
	if err := o.SelectECashNetwork(toID); err != nil {
		return fmt.Errorf("record the network pick: %w", err)
	}
	if o.EnforcerConf != nil {
		if _, err := o.EnforcerConf.RetargetECashNetwork(fromID, toID); err != nil {
			o.log.Warn().Err(err).Msg("could not rewrite bitwindow-enforcer.conf for the new eCash network")
		}
	}
	// The wallet keys its cached scan on the network, and that key does not move
	// between two eCash forks. A cold read would serve the retired fork's
	// balances, transactions and UTXOs with no chain call to correct them.
	if o.WalletSvc != nil {
		o.WalletSvc.ClearNetworkScans(string(config.NetworkECash))
	}
	if err := o.ApplyPendingEnforcerWipe(); err != nil {
		return err
	}
	o.clearNetworkSwapCaches()
	return nil
}

// drainECashTail lands the records a previous eCash switch left. The note itself
// stays: it is what says the stack owes a restart.
//
// Call it with swapNetworkMu held.
func (o *Orchestrator) drainECashTail() error {
	if o.pendingSwap == nil || o.pendingSwap.fromECashID == "" {
		return nil
	}
	o.mu.RLock()
	toID := o.ecashID
	o.mu.RUnlock()
	return o.recordECashSwitch(o.pendingSwap.fromECashID, toID)
}

// pendingECashSwap reports whether a switch left work for a retry to finish.
func (o *Orchestrator) pendingECashSwap() bool {
	o.swapNetworkMu.Lock()
	defer o.swapNetworkMu.Unlock()
	return o.pendingSwap != nil && o.pendingSwap.network == config.NetworkECash
}

// ApplyECashSwitch moves this install onto another eCash network: it rewinds
// the chain to the last block the two share, stops the daemons, rewrites the
// confs and starts the stack again. The enforcer's validator chain is
// per-network and small, so it goes rather than replays.
func (o *Orchestrator) ApplyECashSwitch(ctx context.Context, toID string) error {
	// The lock comes before the plan. Two overlapping requests would otherwise
	// both read the same outgoing id, and the second would bar the branch the
	// first just moved to.
	o.swapNetworkMu.Lock()
	defer o.swapNetworkMu.Unlock()

	// A tail an earlier switch left lands first. Its records still name the fork
	// that switch moved from, and every path below can consume the note.
	if err := o.drainECashTail(); err != nil {
		return err
	}

	plan, err := o.PlanECashSwitch(toID)
	if err != nil {
		return err
	}
	if plan.FromID == toID {
		return o.resumeECashSwitch(toID)
	}
	if plan.Blocked {
		return fmt.Errorf(
			"cannot switch from %s to %s: neither publishes the fork height that says where the chains part, "+
				"so nothing can roll back to a block they share",
			plan.FromID, toID,
		)
	}

	// Read before the stops below, which make both daemons read as stopped.
	restartL1 := o.owedRestartL1()

	// Everything that can fail stops while Core still answers. A rewind before
	// these would leave Core parked under the fork with the old network still
	// selected, and a retry would ask for a block that no longer sits on the
	// chain Core follows.
	var stoppedL2 []string
	for _, c := range o.Configs() {
		if c.ChainLayer == 2 && o.process.IsRunning(c.Name) {
			if err := o.stopForNetworkSwap(ctx, c.Name); err != nil {
				o.restartStoppedL2(ctx, stoppedL2)
				return err
			}
			stoppedL2 = append(stoppedL2, c.Name)
		}
	}
	if o.process.IsRunning("enforcer") {
		if err := o.stopForNetworkSwap(ctx, "enforcer"); err != nil {
			o.restartStoppedL2(ctx, stoppedL2)
			return err
		}
	}

	dropped := ""
	if plan.NeedsRollback {
		hash, err := o.rewindBelowTheFork(ctx, plan.RewindHeight)
		switch {
		case err == nil:
			dropped = hash
		case errors.Is(err, errNoLiveCore):
			// The chain stays as it is. Core reorganises to the new network on
			// its own once it runs, and the blocks below the fork are shared.
			o.log.Warn().Uint32("rewind_height", plan.RewindHeight).
				Msg("no live bitcoin core, so the chain is not rewound")
		default:
			o.restartAfterAbort(ctx, restartL1, stoppedL2)
			return fmt.Errorf("rewind to block %d: %w", plan.RewindHeight, err)
		}
	}

	if o.Settings != nil {
		// The enforcer chain goes on every switch. Journalled because past the
		// commit below a retry reads FromID == ToID and skips this call.
		if err := o.Settings.SetPendingEnforcerWipe(toID); err != nil {
			// Core still answers, so the drop goes back. Left barred, the
			// branch on disk is one Core can no longer follow.
			o.restoreRewind(ctx, dropped)
			o.restartAfterAbort(ctx, restartL1, stoppedL2)
			return fmt.Errorf("journal the enforcer cleanup for %s: %w", toID, err)
		}
	}

	// The conf goes before Core stops. Every step that can fail runs while Core
	// still answers, so a failure can put the drop back — once Core is down
	// nothing can, and the retry would clear the chain this rewind saved.
	if o.BitcoinConf != nil {
		o.BitcoinConf.ECashID = toID
		if err := o.BitcoinConf.RefreshMainSectionDefaults(); err != nil {
			o.BitcoinConf.ECashID = plan.FromID
			o.restoreRewind(ctx, dropped)
			o.restartAfterAbort(ctx, restartL1, stoppedL2)
			return fmt.Errorf("rewrite bitcoin.conf for %s: %w", toID, err)
		}
	}

	if o.process.IsRunning("bitcoind") {
		if err := o.stopForNetworkSwap(ctx, "bitcoind"); err != nil {
			// Core keeps the old chain, so the mark has to come off or a retry
			// finds no block above the fork to drop.
			o.restoreRewind(ctx, dropped)
			o.revertConf(plan.FromID)
			o.restartAfterAbort(ctx, restartL1, stoppedL2)
			return err
		}
	}

	o.mu.Lock()
	o.ecashID = toID
	for name, raw := range o.rawConfigs {
		o.configs[name] = expandECashPlaceholder(raw, toID)
	}
	o.mu.Unlock()

	config.SetECashNetworkID(toID)
	if entry, ok := o.ecashEntry(toID); ok {
		config.SetForkHeight(config.NetworkECash, entry.ForkHeight)
		config.SetNetworkDisplayName(config.NetworkECash, entry.DisplayName)
		config.SetECashEndpoints(entry)
	}
	// Installed before both records below, so a write that fails still leaves
	// the ordinary same-network retry a tail to resume. Without it that retry
	// reads FromID == ToID, takes the no-op path, and the stack stays stopped.
	o.pendingSwap = &pendingNetworkSwap{
		network:     config.NetworkECash,
		restartL1:   restartL1,
		fromECashID: plan.FromID,
	}

	return o.finishECashSwitch(plan.FromID, toID, restartL1)
}

// applyPendingEnforcerWipe clears the enforcer chain a switch journalled, and
// keeps the record until it is gone. The enforcer keeps one validator chain per
// network, not per fork, so a leftover serves the retired generation.
func (o *Orchestrator) ApplyPendingEnforcerWipe() error {
	if o.Settings == nil {
		return nil
	}
	recorded := o.Settings.PendingEnforcerWipe()
	if recorded == "" {
		return nil
	}
	// eCash shares validator/bitcoin with mainnet and forknet, so off eCash
	// this would delete the active network's chain — possibly under a daemon
	// that holds it open. The record waits for the swap that brings eCash back.
	if config.NetworkFromString(o.Network) != config.NetworkECash {
		return nil
	}
	o.mu.RLock()
	running := o.ecashID
	o.mu.RUnlock()

	// The record goes in before the switch commits, so an abort leaves one for
	// a move that never happened. Applying that would delete the validator
	// chain of the generation this install still runs.
	if running != recorded {
		o.log.Info().
			Str("recorded_for", recorded).
			Str("running", running).
			Msg("the eCash selection never moved, dropping the enforcer cleanup")
		return o.Settings.SetPendingEnforcerWipe("")
	}
	if err := config.WipeEnforcerChainDataSync(config.NetworkECash, o.log); err != nil {
		return fmt.Errorf("clear the retired enforcer chain: %w", err)
	}
	if err := o.Settings.SetPendingEnforcerWipe(""); err != nil {
		return fmt.Errorf("clear the journalled enforcer cleanup: %w", err)
	}
	return nil
}

// errNoLiveCore says the rollback found no Bitcoin Core to talk to.
var errNoLiveCore = errors.New("no live bitcoin core")

// rewindBelowTheFork leaves the chain at height and drops what sits above it,
// so Core follows the new eCash network from there.
//
// It invalidates height+1, not height. invalidateblock bars the block AND every
// descendant, so marking the last shared block would bar the incoming chain too
// and Core could never move past it. height+1 is the old network's first block,
// which the new network never builds on.
//
// ResetToBlock is the wrong tool: it reconsiders the block it invalidates, so
// Core replays straight back onto the chain the switch leaves. Only the
// invalidate half belongs here.
//
// The blocks below stay on disk. Both networks fork mainnet, so Core replays
// nothing and downloads only what the new fork adds.
func (o *Orchestrator) rewindBelowTheFork(ctx context.Context, height uint32) (string, error) {
	if !o.process.IsRunning("bitcoind") && !o.coreRPCReachable() {
		return "", errNoLiveCore
	}
	client, err := o.CoreStatusClient()
	if err != nil {
		return "", errNoLiveCore
	}

	previous := ""
	if o.Settings != nil {
		previous = o.Settings.RewoundBlockHash()
	}
	hash, err := dropForkAbove(ctx, client, height, previous)
	if err != nil {
		return "", err
	}
	// The rollback has to know what this cleared: a branch left live outranks
	// the one the retry would bar, and Core stays on the chain the switch was
	// meant to leave.
	o.clearedMark = previous

	// A drop nobody recorded cannot be taken back, and the next switch would bar
	// this branch too — leaving Core under the fork with neither to follow. It
	// runs for an empty hash too, which records that nothing is barred.
	if o.Settings != nil {
		if err := o.Settings.CommitRewind(hash); err != nil {
			o.restoreRewind(ctx, hash)
			return "", fmt.Errorf("record the dropped block %s: %w", hash, err)
		}
	}
	if hash == "" {
		o.log.Info().Uint32("height", height).
			Msg("the chain sits below the fork, so nothing had to be dropped")
		return "", nil
	}
	o.log.Info().Str("block", hash).Uint32("height", height+1).
		Msg("dropped the retired eCash chain from this block up")
	return hash, nil
}

// restoreRewind takes a drop back when the switch cannot go on, so a retry
// starts from the chain this install had before it.
func (o *Orchestrator) restoreRewind(ctx context.Context, hash string) {
	previous := o.clearedMark
	o.clearedMark = ""
	if hash == "" && previous == "" {
		return
	}
	client, err := o.CoreStatusClient()
	if err != nil {
		return
	}
	if hash != "" {
		if _, err := client.call(ctx, "reconsiderblock", hash); err != nil {
			o.log.Warn().Err(err).Str("block", hash).Msg("could not take the rewind back")
			return
		}
	}
	// A reverse switch lifts the bar the switch before it put on the target
	// branch. Rolling back has to put that bar back, or the branch with more
	// work wins and Core stays on the chain the caller meant to leave.
	if previous != "" {
		if _, err := client.call(ctx, "invalidateblock", previous); err != nil && !isBlockNotFound(err) {
			o.log.Warn().Err(err).Str("block", previous).Msg("could not put the previous mark back")
		}
	}
	if o.Settings != nil {
		if err := o.Settings.SetRewoundBlockHash(previous); err != nil {
			o.log.Warn().Err(err).Msg("could not record the dropped block")
		}
	}
}

// dropForkAbove bars the retired fork from height+1 up and returns the block it
// barred. previousMark is the block an earlier switch barred, or empty.
//
// It reads the outgoing block before clearing previousMark. reconsiderblock
// revalidates the branch it clears, and a branch with more work becomes the
// active chain — a read after it would name the incoming fork and bar the very
// chain this switch moves to.
//
// It bars height+1, not height. invalidateblock bars the block AND every
// descendant, so barring the last shared block would bar the incoming chain too
// and Core could never move past it.
func dropForkAbove(ctx context.Context, client *CoreStatusClient, height uint32, previousMark string) (string, error) {
	// A node still below the fork holds no block either network disagrees on, so
	// there is nothing to drop and the switch goes on. Asking for the block
	// anyway fails the switch until the chain catches up.
	tip, _, err := coreTip(ctx, client)
	if err != nil {
		return "", fmt.Errorf("read the chain tip: %w", err)
	}
	if tip <= height {
		// The target's own first block may still be barred by an earlier switch
		// away from it. Leaving that mark parks Core under the fork for good.
		if err := clearMark(ctx, client, previousMark); err != nil {
			return "", err
		}
		return "", nil
	}

	divergent := height + 1
	var hash string
	raw, err := client.call(ctx, "getblockhash", divergent)
	if err != nil {
		return "", fmt.Errorf("get block hash at %d: %w", divergent, err)
	}
	if err := json.Unmarshal(raw, &hash); err != nil {
		return "", fmt.Errorf("decode block hash at %d: %w", divergent, err)
	}

	// A mark from an earlier switch bars that branch for good, so a move back to
	// the network it dropped would park forever. Clear it before the new one.
	if err := clearMark(ctx, client, previousMark); err != nil {
		return "", err
	}

	if _, err := client.call(ctx, "invalidateblock", hash); err != nil {
		return "", fmt.Errorf("drop block %s: %w", hash, err)
	}
	return hash, nil
}

// revertConf puts bitcoin.conf back on the network the switch started from, so
// a failed switch leaves the file naming the chain that is on disk.
func (o *Orchestrator) revertConf(id string) {
	if o.BitcoinConf == nil {
		return
	}
	o.BitcoinConf.ECashID = id
	if err := o.BitcoinConf.RefreshMainSectionDefaults(); err != nil {
		o.log.Warn().Err(err).Str("network", id).Msg("could not put bitcoin.conf back")
	}
}

// restartAfterAbort brings the stack back up on the network the switch failed to
// leave. Every abort path runs after the L2s and the enforcer stopped, and a
// transient fault must not take the wallet down with it.
func (o *Orchestrator) restartAfterAbort(ctx context.Context, restartL1 bool, stoppedL2 []string) {
	o.restartStoppedL2(ctx, stoppedL2)
	if !restartL1 {
		return
	}
	if err := o.finishNetworkSwap(config.NetworkECash, true); err != nil {
		o.log.Warn().Err(err).Msg("could not restart the stack after the switch aborted")
	}
}

// restartStoppedL2 brings back the sidechains an aborted switch stopped. They
// run on the network this install never left, so leaving them down costs the
// user their sidechains for a switch that did not happen.
func (o *Orchestrator) restartStoppedL2(ctx context.Context, names []string) {
	for _, name := range names {
		if o.process.IsRunning(name) {
			continue
		}
		if _, err := o.Start(ctx, name, nil, nil); err != nil {
			o.log.Warn().Err(err).Str("binary", name).
				Msg("could not restart a sidechain after the switch aborted")
		}
	}
}

// isBlockNotFound reports whether Core refused a call because it holds no such
// block. A hash from an earlier switch names a chain a wiped datadir no longer
// carries, which is not a reason to refuse the next one.
func isBlockNotFound(err error) bool {
	return err != nil && strings.Contains(err.Error(), "RPC error -5")
}

// clearMark lifts the bar an earlier switch put on a branch, so a move back to
// the network it dropped can follow that chain again. A hash Core does not hold
// names a chain a wiped datadir no longer carries, which stops nothing.
func clearMark(ctx context.Context, client *CoreStatusClient, hash string) error {
	if hash == "" {
		return nil
	}
	if _, err := client.call(ctx, "reconsiderblock", hash); err != nil && !isBlockNotFound(err) {
		// Going on would bar the outgoing branch while the incoming one is
		// still barred, and Core could follow neither.
		return fmt.Errorf("clear the mark on block %s: %w", hash, err)
	}
	return nil
}
