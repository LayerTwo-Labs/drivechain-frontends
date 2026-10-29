package orchestrator

import (
	"context"
	"fmt"
	"slices"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

const strandedReleaseInterval = 30 * time.Second

// RunStrandedRelease calls ReleaseStrandedTxs until ctx stops. An eCash switch
// leaves the transactions of the old fork unconfirmed for good, and Core counts
// the coins they spend as spent until they are abandoned.
func (o *Orchestrator) RunStrandedRelease(ctx context.Context) {
	ticker := time.NewTicker(strandedReleaseInterval)
	defer ticker.Stop()
	for {
		if err := o.ReleaseStrandedTxs(ctx); err != nil {
			o.log.Error().Err(err).Msg("could not release the transactions an eCash switch stranded")
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
	}
}

// ReleaseStrandedTxs abandons the stranded transactions of every Core wallet
// one time for each eCash network this install runs, and records the network.
// It does nothing until Core is synced and the wallets are unlocked.
func (o *Orchestrator) ReleaseStrandedTxs(ctx context.Context) error {
	if o.Settings == nil || o.walletEngine == nil || o.WalletSvc == nil {
		return nil
	}
	releaser, ok := o.walletEngine.Backend().(wallet.StrandedReleaser)
	if !ok {
		return nil
	}
	if o.WalletSvc.State() != wallet.StateUnlocked {
		return nil
	}
	status, err := o.ECashMigrationStatus()
	if err != nil {
		return err
	}
	if status.Running || (status.JobID != "" && !status.Complete) {
		return nil
	}
	// A switch that starts during the release would move Core under it.
	if !o.swapNetworkMu.TryLock() {
		return nil
	}
	defer o.swapNetworkMu.Unlock()
	if o.pendingSwap != nil {
		return nil
	}
	if config.NetworkFromString(o.CurrentNetwork()) != config.NetworkECash || o.NodeMode() == NodeModeLight {
		return nil
	}
	o.mu.RLock()
	id := o.ecashID
	cat := o.Catalog
	o.mu.RUnlock()
	if id == "" || o.Settings.StrandedReleasedFor() == id {
		return nil
	}
	done, err := releaser.ReleaseStranded(ctx, retiredLockTimes(cat, id))
	if err != nil || !done {
		return err
	}
	if err := o.Settings.SetStrandedReleasedFor(id); err != nil {
		return fmt.Errorf("record the stranded release for %s: %w", id, err)
	}
	o.log.Info().Str("network", id).Msg("released the transactions an eCash switch stranded")
	return nil
}

// retiredLockTimes lists the replay locktimes of every eCash network but id.
// The default stays in, because a retired network can leave the catalog.
func retiredLockTimes(cat netcatalog.Catalog, id string) []uint32 {
	current, _ := cat.ByID(id)
	own := current.ReplayLockTimeOrDefault()
	locks := []uint32{netcatalog.DefaultReplayLockTime}
	for _, n := range cat.Networks {
		if n.Family == netcatalog.FamilyECash {
			locks = append(locks, n.ReplayLockTimeOrDefault())
		}
	}
	slices.Sort(locks)
	locks = slices.Compact(locks)
	return slices.DeleteFunc(locks, func(l uint32) bool { return l == own })
}
