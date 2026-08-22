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
	// MustWipe means the old chain has to go: it belongs to another eCash fork,
	// and no published fork height says where the two part.
	MustWipe bool
}

// PlanECashSwitch works out how to reach another eCash network from the one
// this install runs. Both networks fork mainnet, so every block below the lower
// fork height is shared history: a rewind to that height keeps it and drops
// only what the retired fork added. MustWipe says no published fork height
// tells the two apart, so the old blocks cannot stay.
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
		// The blocks on disk belong to another fork and nothing says where the
		// chains part, so they cannot stay.
		plan.MustWipe = true
		return plan, nil
	}
	shared := from.ForkHeight
	if to.ForkHeight < shared {
		shared = to.ForkHeight
	}
	// The fork height is the first block of the fork, so the chain ends one
	// below it.
	if shared <= 1 {
		plan.MustWipe = true
		return plan, nil
	}
	plan.RewindHeight = uint32(shared - 1)
	plan.NeedsRollback = true
	return plan, nil
}

// ecashEntry finds a published eCash network by id: the catalog this process
// serves, then the pending document a refresh left. A confirmed upgrade targets
// a network the served catalog does not list yet.
func (o *Orchestrator) ecashEntry(id string) (netcatalog.Network, bool) {
	o.mu.RLock()
	cat := o.Catalog
	o.mu.RUnlock()
	if n, ok := cat.ByID(id); ok {
		return n, true
	}
	if pending, ok := netcatalog.LoadPending(o.BitwindowDir); ok {
		return pending.ByID(id)
	}
	return netcatalog.Network{}, false
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

	plan, err := o.PlanECashSwitch(toID)
	if err != nil {
		return err
	}
	if plan.FromID == toID {
		return nil
	}

	bitcoindWasRunning := o.process.IsRunning("bitcoind")
	enforcerWasRunning := o.process.IsRunning("enforcer")
	restartL1 := bitcoindWasRunning || enforcerWasRunning

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

	// The rewind needs the live Core that the stop below takes away. A Core
	// already down leaves nothing to talk to, so the old blocks go instead —
	// correct, and slower.
	wipe := plan.MustWipe
	dropped := ""
	if plan.NeedsRollback {
		hash, err := o.rewindBelowTheFork(ctx, plan.RewindHeight)
		switch {
		case err == nil:
			dropped = hash
		case errors.Is(err, errNoLiveCore):
			// Deleting here would cost every block below the fork, which both
			// networks still agree on. Leave the drop for the first boot that
			// has a Core to make it with.
			if o.Settings == nil {
				o.restartAfterAbort(ctx, restartL1, stoppedL2)
				return fmt.Errorf("no bitcoin core to rewind to block %d and nowhere to record it", plan.RewindHeight)
			}
			if err := o.recordPendingRewind(plan.FromID, toID); err != nil {
				o.restartAfterAbort(ctx, restartL1, stoppedL2)
				return fmt.Errorf("record the deferred rewind to block %d: %w", plan.RewindHeight, err)
			}
			o.log.Warn().Uint32("rewind_height", plan.RewindHeight).
				Msg("no live bitcoin core to rewind, the next boot drops the retired branch")
		default:
			o.restartAfterAbort(ctx, restartL1, stoppedL2)
			return fmt.Errorf("rewind to block %d: %w", plan.RewindHeight, err)
		}
	}

	// A mandatory wipe is journalled before the target is committed. Past that
	// point a retry reads FromID == ToID, skips this call, and would start Core
	// over the retired chain with the work forgotten.
	if o.Settings != nil {
		if wipe {
			if err := o.recordPendingRewind(plan.FromID, toID); err != nil {
				o.restartAfterAbort(ctx, restartL1, stoppedL2)
				return fmt.Errorf("journal the wipe for %s: %w", toID, err)
			}
		}
		// The enforcer chain goes on every switch, rewind or wipe. Journalled
		// for the same reason: past the commit below a retry reads
		// FromID == ToID and skips this call.
		if err := o.Settings.SetPendingEnforcerWipe(toID); err != nil {
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
	// Installed before the pick, so a pick that cannot be written still leaves
	// the ordinary same-network retry a tail to resume. Without it that retry
	// reads FromID == ToID, takes the no-op path, and the stack stays stopped.
	o.pendingSwap = &pendingNetworkSwap{network: config.NetworkECash, restartL1: restartL1}

	// Last, and only once the chain and the conf both moved. A pick recorded
	// ahead of a failed switch would make the next boot read the old sentinel as
	// stale and clear a chain this run still holds.
	if err := o.SelectECashNetwork(toID); err != nil {
		return fmt.Errorf("record the network pick: %w", err)
	}
	if o.EnforcerConf != nil {
		if _, err := o.EnforcerConf.RetargetECashNetwork(plan.FromID, toID); err != nil {
			o.log.Warn().Err(err).Msg("could not rewrite bitwindow-enforcer.conf for the new eCash network")
		}
	}
	// The wallet keys its cached scan on the network, and that key does not move
	// between two eCash forks. A cold read would serve the retired fork's
	// balances, transactions and UTXOs with no chain call to correct them.
	if o.WalletSvc != nil {
		o.WalletSvc.ClearNetworkScans(string(config.NetworkECash))
	}
	if wipe {
		// Both failures below stop the switch before the stack comes back up.
		// A Core started over the retired chain is what the wipe exists to
		// stop, and a journal left behind makes the next start wipe the chain
		// this one downloads. The record survives either way, so a retry or the
		// next start finishes the job.
		if err := config.WipeNetworkScopedChainDataSync(config.NetworkECash, o.ecashDatadir(), o.log); err != nil {
			return fmt.Errorf("clear the retired %s chain: %w", plan.FromID, err)
		}
		if o.Settings != nil {
			if err := o.Settings.SetPendingRewind(nil); err != nil {
				return fmt.Errorf("clear the journalled eCash wipe: %w", err)
			}
		}
	}
	if err := o.ApplyPendingEnforcerWipe(); err != nil {
		return err
	}
	o.clearNetworkSwapCaches()

	o.log.Info().
		Str("previous", plan.FromID).
		Str("current", toID).
		Uint32("rewind_height", plan.RewindHeight).
		Msg("switched eCash network")

	return o.finishNetworkSwap(config.NetworkECash, restartL1)
}

// recordPendingRewind stores a drop for the next live Core, or clears one that
// the move makes moot.
//
// FromID always names the network the blocks on disk belong to, which the first
// record fixes. A later switch changes only the target: the chain has not moved
// while no Core ran, so a record that took its source from the last pick would
// aim the drop at the very fork it lands on.
func (o *Orchestrator) recordPendingRewind(fromID, toID string) error {
	if existing := o.Settings.PendingRewind(); existing != nil && existing.FromID != "" {
		fromID = existing.FromID
	}
	// Back to the chain on disk: nothing to drop.
	if fromID == toID {
		return o.Settings.SetPendingRewind(nil)
	}
	height, ok := o.sharedECashHeight(fromID, toID)
	if !ok {
		// Nothing says where the two forks part, so the old chain cannot stay.
		// It is still journalled: a crash before the delete would otherwise
		// leave the target's conf over the source fork.
		return o.Settings.SetPendingRewind(&PendingRewind{FromID: fromID, ToID: toID, Wipe: true})
	}
	return o.Settings.SetPendingRewind(&PendingRewind{FromID: fromID, ToID: toID, Height: height})
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

// ApplyPendingRewindToAdoptedCore makes a journalled drop against a Core that
// outlived the previous run, and stops that Core when it cannot.
//
// A switch that died between its journal and its Core stop leaves exactly that:
// a live Core on the retired fork under a conf naming the target. Nothing else
// reaches it, because the deferred hook only rides a start this process makes.
func (o *Orchestrator) ApplyPendingRewindToAdoptedCore(ctx context.Context) error {
	if o.Settings == nil {
		return nil
	}
	record := o.Settings.PendingRewind()
	if record == nil || record.Wipe || record.Height == 0 {
		return nil
	}
	if !o.process.IsRunning("bitcoind") && !o.coreRPCReachable() {
		return nil
	}
	if err := o.ApplyPendingECashRewind(ctx); err != nil {
		if stopErr := o.process.Stop(ctx, "bitcoind", true); stopErr != nil {
			o.log.Error().Err(stopErr).Msg("could not stop the adopted bitcoind after the rewind failed")
		}
		return err
	}
	return nil
}

// ApplyPendingECashWipe deletes a chain a switch journalled but never got to.
// It runs before any binary starts: the delete renames Core's blocks aside, and
// a live Core over that is a corrupt datadir.
func (o *Orchestrator) ApplyPendingECashWipe(ctx context.Context) error {
	if o.Settings == nil {
		return nil
	}
	record := o.Settings.PendingRewind()
	if record == nil || !record.Wipe {
		return nil
	}
	if config.NetworkFromString(o.Network) != config.NetworkECash {
		return nil
	}
	o.mu.RLock()
	running := o.ecashID
	o.mu.RUnlock()
	if running != record.ToID {
		o.log.Info().
			Str("recorded_for", record.ToID).
			Str("running", running).
			Msg("the eCash selection moved on, dropping the wipe a switch left behind")
		return o.Settings.SetPendingRewind(nil)
	}
	if o.coreRPCReachable() {
		return fmt.Errorf("a bitcoin core is running over the retired %s chain — stop it first", record.FromID)
	}
	if err := config.WipeNetworkScopedChainDataSync(config.NetworkECash, o.ecashDatadir(), o.log); err != nil {
		// Keep the record and stop the boot. Clearing it would let Core open
		// the retired chain under the target's conf with nothing left to retry.
		return fmt.Errorf("clear the retired %s chain: %w", record.FromID, err)
	}
	if err := o.ApplyPendingEnforcerWipe(); err != nil {
		return err
	}
	if err := o.Settings.SetPendingRewind(nil); err != nil {
		return fmt.Errorf("clear the journalled eCash wipe: %w", err)
	}
	o.log.Info().Str("previous", record.FromID).Str("current", record.ToID).
		Msg("cleared the eCash chain a switch left behind")
	return nil
}

// ApplyPendingECashRewind makes the drop a switch could not make itself.// ApplyPendingECashRewind makes the drop a switch could not make itself. It runs
// once Core answers and before the enforcer starts, so nothing indexes the
// branch this leaves.
func (o *Orchestrator) ApplyPendingECashRewind(ctx context.Context) error {
	if o.Settings == nil {
		return nil
	}
	record := o.Settings.PendingRewind()
	// A journalled wipe belongs to ApplyPendingECashWipe, which runs before
	// Core does. By here Core holds the datadir open.
	if record == nil || record.Wipe || record.Height == 0 {
		return nil
	}
	if config.NetworkFromString(o.Network) != config.NetworkECash {
		return nil
	}
	o.mu.RLock()
	running := o.ecashID
	o.mu.RUnlock()

	// A selection that went back to where it started leaves this drop pointed
	// at the fork now on disk. Making it would bar that fork's own first block
	// and park Core below it for good.
	if running != record.ToID {
		o.log.Info().
			Str("recorded_for", record.ToID).
			Str("running", running).
			Msg("the eCash selection moved on, dropping the rewind a switch left behind")
		return o.Settings.SetPendingRewind(nil)
	}

	if _, err := o.rewindBelowTheFork(ctx, record.Height); err != nil {
		// Keep the record: the next boot tries again rather than opening the
		// retired branch as the network the conf names.
		return fmt.Errorf("apply the deferred rewind to block %d: %w", record.Height, err)
	}
	// The rewind cleared the record in the same write that recorded its outcome,
	// so a crash here leaves nothing to retry.
	o.log.Info().Uint32("height", record.Height).Str("network", record.ToID).
		Msg("applied the eCash rewind a switch left behind")
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
	// this branch too — leaving Core under the fork with neither to follow.
	//
	// It runs for an empty hash too. A chain already below the fork bars
	// nothing, and this write is what clears the drop waiting on it; without it
	// Core syncs past the fork and the next boot bars the target's own block.
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
