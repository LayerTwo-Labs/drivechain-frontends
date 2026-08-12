package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// enforcerReadyTimeout bounds how long a swap waits for the restarted enforcer
// to answer RPC before reporting that it is up but unreachable.
const enforcerReadyTimeout = 2 * time.Minute

const (
	SwapEnforcerStepValidate = "validate-seed"
	SwapEnforcerStepStop     = "stop-enforcer"
	SwapEnforcerStepBackup   = "backup-enforcer-wallet"
	SwapEnforcerStepApply    = "apply-seed"
	SwapEnforcerStepRestart  = "restart-enforcer"
)

// SwapEnforcerWalletStep is one unit of the swap, announced up front so a
// client can render the whole plan before the first step runs.
type SwapEnforcerWalletStep struct {
	ID   string
	Name string
}

type SwapEnforcerWalletStepStatus string

const (
	SwapEnforcerWalletStepStarted   SwapEnforcerWalletStepStatus = "started"
	SwapEnforcerWalletStepCompleted SwapEnforcerWalletStepStatus = "completed"
	SwapEnforcerWalletStepFailed    SwapEnforcerWalletStepStatus = "failed"
)

// SwapEnforcerWalletProgressFunc receives every step transition. detail carries
// step-specific context (a backup path, a restart stage) and is often empty.
type SwapEnforcerWalletProgressFunc func(stepID string, status SwapEnforcerWalletStepStatus, detail string, err error)

// SwapEnforcerWalletRequest is the input to SwapEnforcerWallet.
type SwapEnforcerWalletRequest struct {
	Mnemonic string
	// Name is optional; empty keeps the current enforcer wallet's name.
	Name string
}

// SwapEnforcerWalletPlan returns the steps SwapEnforcerWallet will run.
func SwapEnforcerWalletPlan() []SwapEnforcerWalletStep {
	return []SwapEnforcerWalletStep{
		{ID: SwapEnforcerStepValidate, Name: "Validating seed"},
		{ID: SwapEnforcerStepStop, Name: "Stopping enforcer"},
		{ID: SwapEnforcerStepBackup, Name: "Backing up enforcer wallet"},
		{ID: SwapEnforcerStepApply, Name: "Loading new seed"},
		{ID: SwapEnforcerStepRestart, Name: "Restarting enforcer"},
	}
}

// SwapEnforcerWallet points the enforcer at a different seed. The enforcer is
// stopped, its on-disk wallet is moved to wallet_backups/, the enforcer entry
// in wallet.json is rewritten from the supplied mnemonic, and the daemon is
// restarted so it boots against the new seed. Nothing is deleted: both the
// daemon's wallet directory and the pre-swap wallet.json survive under
// wallet_backups/. Sidechain starters are carried over untouched — this swaps
// the enforcer, not every chain derived from the old seed.
//
// Any failure before the new wallet is committed puts the enforcer back the way
// it was found, running on its original wallet.
//
// Returns the ID of the swapped-in wallet.
func (o *Orchestrator) SwapEnforcerWallet(ctx context.Context, req SwapEnforcerWalletRequest, progress SwapEnforcerWalletProgressFunc) (string, error) {
	// One swap at a time: two of them would interleave daemon restarts and
	// directory moves, and both would report success for a seed only one of
	// them left running.
	if !o.swapEnforcerMu.TryLock() {
		return "", errors.New("an enforcer wallet swap is already in progress")
	}
	o.swapEnforcerActive.Store(true)
	o.swapPendingBoot = nil
	defer func() {
		// A boot that outlived this request still has a starter file to write
		// and a daemon to start; a retry stopping and committing another seed
		// underneath it would interleave. Stay marked in progress until it ends.
		pending := o.swapPendingBoot
		o.swapPendingBoot = nil
		if pending == nil {
			o.swapEnforcerActive.Store(false)
			o.swapEnforcerMu.Unlock()
			return
		}
		go func() {
			<-pending
			o.swapEnforcerActive.Store(false)
			o.swapEnforcerMu.Unlock()
		}()
	}()

	emit := func(stepID string, status SwapEnforcerWalletStepStatus, detail string, err error) {
		if progress != nil {
			progress(stepID, status, detail, err)
		}
	}
	var prepared *wallet.EnforcerWalletSwap
	var moved []enforcerWalletMove
	var wasRunning bool
	steps := []struct {
		id string
		fn func() (string, error)
	}{
		{SwapEnforcerStepValidate, func() (string, error) {
			var err error
			prepared, err = o.prepareEnforcerWalletSwap(req)
			return "", err
		}},
		{SwapEnforcerStepStop, func() (string, error) {
			var detail string
			var err error
			wasRunning, detail, err = o.stopEnforcerForSwap(ctx)
			return detail, err
		}},
		{SwapEnforcerStepBackup, func() (string, error) {
			// Snapshot first: while nothing has moved yet, a failure here is
			// undone by starting the enforcer back up on its untouched wallet.
			snapshot, err := o.WalletSvc.CopyMasterWalletFilesToBackup()
			if err != nil {
				return "", o.rollbackEnforcerSwap(ctx, err, wasRunning, nil, prepared.PreviousID)
			}
			moved, err = o.backupEnforcerWalletPaths()
			if err != nil {
				return snapshot, o.rollbackEnforcerSwap(ctx, err, wasRunning, nil, prepared.PreviousID)
			}
			if len(moved) == 0 {
				return "no enforcer wallet on disk", nil
			}
			return moved[0].to, nil
		}},
		{SwapEnforcerStepApply, func() (string, error) {
			// A boot racing this swap — another client's StartWithL1 or
			// RestartDaemon — can recreate a wallet directory from the old seed
			// after the backup step enumerated them. Clear anything that came
			// back before the new seed takes effect.
			late, err := o.backupEnforcerWalletPaths()
			if err != nil {
				return "", o.rollbackEnforcerSwap(ctx, err, wasRunning, moved, prepared.PreviousID)
			}
			moved = append(moved, late...)

			if err := o.WalletSvc.CommitEnforcerWalletSwap(prepared); err != nil {
				return "", o.rollbackEnforcerSwap(ctx, err, wasRunning, moved, prepared.PreviousID)
			}
			return prepared.Replacement.ID, nil
		}},
		{SwapEnforcerStepRestart, func() (string, error) {
			return "", o.restartEnforcerAfterSwap(ctx)
		}},
	}

	var walletID string
	for _, step := range steps {
		emit(step.id, SwapEnforcerWalletStepStarted, "", nil)
		detail, err := step.fn()
		if err != nil {
			emit(step.id, SwapEnforcerWalletStepFailed, detail, err)
			return walletID, err
		}
		if step.id == SwapEnforcerStepApply {
			walletID = prepared.Replacement.ID
		}
		emit(step.id, SwapEnforcerWalletStepCompleted, detail, nil)
	}

	return walletID, nil
}

func (o *Orchestrator) prepareEnforcerWalletSwap(req SwapEnforcerWalletRequest) (*wallet.EnforcerWalletSwap, error) {
	if o.WalletSvc == nil {
		return nil, errors.New("wallet service is not available")
	}
	return o.WalletSvc.PrepareEnforcerWalletSwap(req.Name, req.Mnemonic, WalletSidechainSlots())
}

// stopEnforcerForSwap stops the enforcer we own, reporting whether it had been
// running so a failed swap can put it back. An enforcer that answers RPC but was
// started outside this process can't be stopped here, and swapping the seed
// underneath a live daemon would leave it running on the old wallet.
func (o *Orchestrator) stopEnforcerForSwap(ctx context.Context) (bool, string, error) {
	if !o.process.IsRunning("enforcer") {
		if o.enforcerReachable() {
			return false, "", errors.New("enforcer is running outside orchestrator control; stop it before swapping the wallet")
		}
		return false, "enforcer already stopped", nil
	}

	if err := o.Stop(ctx, "enforcer", false); err != nil {
		o.log.Warn().Err(err).Msg("graceful enforcer stop failed during wallet swap, escalating to SIGKILL")
		if killErr := o.Stop(ctx, "enforcer", true); killErr != nil {
			return true, "", fmt.Errorf("stop enforcer: %w", killErr)
		}
	}
	return true, "", nil
}

// rollbackEnforcerSwap undoes a swap that failed before the new wallet was
// committed: moved wallet paths go back, and an enforcer that was running when
// the swap started is brought back up on its original wallet. The original
// failure is returned, annotated with what the rollback managed to do.
//
// The moved state only goes back if the wallet it belongs to is still the
// enforcer wallet. If something replaced it while the swap was in flight — the
// case CommitEnforcerWalletSwap rejects — restoring would hand the new wallet
// the old seed's BDK state, which is the mismatch the swap exists to avoid. It
// stays under wallet_backups/ instead, and the enforcer rescans.
func (o *Orchestrator) rollbackEnforcerSwap(ctx context.Context, cause error, wasRunning bool, moved []enforcerWalletMove, preparedAgainstID string) error {
	if o.enforcerWalletStillIs(preparedAgainstID) {
		o.restoreEnforcerWalletPaths(moved)
	} else if len(moved) > 0 {
		o.log.Warn().Str("prepared_against", preparedAgainstID).
			Msg("enforcer wallet changed during the swap; leaving its old state under wallet_backups/ rather than pairing it with the new wallet")
	}

	if !wasRunning {
		return cause
	}

	if err := o.restartEnforcerAfterSwap(ctx); err != nil {
		o.log.Error().Err(err).Msg("could not restart the enforcer after rolling back a failed wallet swap")
		return fmt.Errorf("%w (rolled back, but the enforcer could not be restarted: %v)", cause, err)
	}
	return fmt.Errorf("%w (rolled back, enforcer restarted on its previous wallet)", cause)
}

// enforcerWalletStillIs reports whether the enforcer wallet is the one a swap
// was prepared against.
func (o *Orchestrator) enforcerWalletStillIs(walletID string) bool {
	if o.WalletSvc == nil || walletID == "" {
		return false
	}
	current := o.WalletSvc.EnforcerWallet()
	return current != nil && current.ID == walletID
}

// enforcerWalletMove records a wallet path that was moved aside, so a failed
// swap can put it back where the daemon expects it.
type enforcerWalletMove struct {
	from string
	to   string
}

// backupEnforcerWalletPaths moves every network's enforcer wallet directory
// under wallet_backups/, leaving validator state alone: only the wallet is
// seed-derived. The seed in wallet.json is global, so a directory left behind
// for an inactive network would pair old BDK state with the new seed the next
// time the user switches to it — the checkpoint-sync wedge the startup guard
// exists to prevent.
func (o *Orchestrator) backupEnforcerWalletPaths() ([]enforcerWalletMove, error) {
	paths, err := enforcerWalletDirs()
	if err != nil {
		return nil, err
	}

	var moved []enforcerWalletMove
	for _, path := range paths {
		dest, err := o.WalletSvc.BackupPath(path)
		if err != nil {
			o.restoreEnforcerWalletPaths(moved)
			return nil, fmt.Errorf("back up enforcer wallet %s: %w", path, err)
		}
		if dest != "" {
			moved = append(moved, enforcerWalletMove{from: path, to: dest})
		}
	}
	return moved, nil
}

// EnforcerWalletPaths returns the enforcer's per-network wallet directories, for
// flows that must move seed-derived daemon state out of the way.
func (o *Orchestrator) EnforcerWalletPaths() []string {
	dirs, err := enforcerWalletDirs()
	if err != nil {
		o.log.Warn().Err(err).Msg("could not enumerate enforcer wallet directories")
		return nil
	}
	return dirs
}

// enforcerWalletDirs lists the per-network wallet directories the enforcer has
// created, in the <enforcer root>/wallet/<network> layout GetWalletPaths reads.
func enforcerWalletDirs() ([]string, error) {
	dirConfig, ok := config.DirConfigByName("enforcer")
	if !ok {
		return nil, errors.New("no directory layout configured for the enforcer")
	}

	root := filepath.Join(dirConfig.RootDir(), "wallet")
	entries, err := os.ReadDir(root)
	if os.IsNotExist(err) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("read enforcer wallet dir: %w", err)
	}

	var dirs []string
	for _, entry := range entries {
		if !entry.IsDir() || entry.Name() == "wallet_backups" {
			continue
		}
		dirs = append(dirs, filepath.Join(root, entry.Name()))
	}
	return dirs, nil
}

// restoreEnforcerWalletPaths puts moved-aside wallet directories back, so an
// aborted swap leaves the enforcer's wallet where the daemon looks for it.
func (o *Orchestrator) restoreEnforcerWalletPaths(moved []enforcerWalletMove) {
	for _, move := range moved {
		if err := os.Rename(move.to, move.from); err != nil {
			o.log.Error().Err(err).Str("from", move.to).Str("to", move.from).
				Msg("could not restore enforcer wallet after a failed swap; it is still under wallet_backups/")
			continue
		}
		o.log.Info().Str("path", move.from).Msg("enforcer wallet restored after a failed swap")
	}
}

// restartEnforcerAfterSwap boots the enforcer again. startEnforcerWhenReady
// rewrites the L1 starter file from wallet.json, so the daemon comes up on the
// seed that was just loaded.
//
// That routine reports its failures — a missing seed, an unreachable ZMQ
// socket, a failed download — to the connection monitor and returns, and
// RestartDaemon closes the channel either way. A live process is therefore the
// only trustworthy evidence that the restart took.
//
// The boot itself runs on context.Background(): it owns the enforcer's
// connection and automatic-restart timers, which must outlive the swap request
// that triggered them. Only the readiness wait below is tied to ctx, so a
// disconnecting client stops us waiting without stopping the daemon.
func (o *Orchestrator) restartEnforcerAfterSwap(ctx context.Context) error {
	ch, err := o.RestartDaemon(context.Background(), "enforcer", StopOptions{swapHeld: true})
	if err != nil {
		return fmt.Errorf("restart enforcer: %w", err)
	}

	booted := drainEnforcerBoot(ch)
	err = awaitEnforcerBoot(ctx, booted, enforcerReadyTimeout)
	if err != nil {
		// The boot is still running; the swap stays marked in progress until it
		// settles. See the deferred release in SwapEnforcerWallet.
		if !errors.Is(err, errEnforcerBootFailed) {
			o.swapPendingBoot = booted
		}
		return err
	}
	return o.enforcerStartOutcome(ctx)
}

// errEnforcerBootFailed marks a boot that finished and failed, as opposed to one
// this request stopped waiting for.
var errEnforcerBootFailed = errors.New("enforcer boot failed")

// drainEnforcerBoot consumes the restart progress channel in its own goroutine
// and reports the first error it carried. Draining independently of the waiter
// is what lets a caller give up without blocking the boot on a full channel.
func drainEnforcerBoot(ch <-chan StartupProgress) <-chan error {
	booted := make(chan error, 1)
	go func() {
		var bootErr error
		for update := range ch {
			if update.Error != nil && bootErr == nil {
				bootErr = update.Error
			}
		}
		booted <- bootErr
	}()
	return booted
}

// awaitEnforcerBoot waits for a drained boot to finish. startEnforcerWhenReady
// waits on Bitcoin Core's header sync using the detached context, so an
// unavailable Core would otherwise never close the channel — hanging the request
// and holding the swap lock against every later swap.
func awaitEnforcerBoot(ctx context.Context, booted <-chan error, timeout time.Duration) error {
	select {
	case err := <-booted:
		if err != nil {
			return fmt.Errorf("%w: %w", errEnforcerBootFailed, err)
		}
		return nil
	case <-ctx.Done():
		return ctx.Err()
	case <-time.After(timeout):
		return fmt.Errorf("enforcer restart did not complete within %s; it is still booting in the background", timeout)
	}
}

// enforcerStartOutcome reports whether the enforcer came up. A spawned process
// is not evidence on its own — the daemon can exit seconds after cmd.Start — so
// this waits for it to answer RPC or exit, and names what the monitor recorded
// when neither happens.
func (o *Orchestrator) enforcerStartOutcome(ctx context.Context) error {
	o.monitorsMu.Lock()
	mon, hasMonitor := o.monitors["enforcer"]
	o.monitorsMu.Unlock()

	if proc := o.process.Get("enforcer"); proc != nil && hasMonitor {
		waitCtx, cancel := context.WithTimeout(ctx, enforcerReadyTimeout)
		defer cancel()

		err := waitForConnectedOrExit(waitCtx, mon, proc)
		switch {
		case err == nil:
			return nil
		case errors.Is(err, context.DeadlineExceeded):
			return fmt.Errorf("enforcer started on the new seed but is not answering RPC after %s", enforcerReadyTimeout)
		default:
			return fmt.Errorf("enforcer did not start on the new seed: %w", err)
		}
	}

	if o.enforcerReachable() {
		return nil
	}
	if hasMonitor {
		if reason := mon.ConnectionError(); reason != "" {
			return fmt.Errorf("enforcer did not start on the new seed: %s", reason)
		}
	}
	return errors.New("enforcer did not start on the new seed; check the enforcer logs")
}

// WalletSidechainSlots lists every configured sidechain, so a generated or
// swapped-in seed derives a starter for each one up front.
func WalletSidechainSlots() []wallet.SidechainSlot {
	var slots []wallet.SidechainSlot
	for _, c := range AllSidechains() {
		name := c.DisplayName
		if name == "" {
			name = c.Name
		}
		slots = append(slots, wallet.SidechainSlot{Slot: c.Slot, Name: name})
	}
	return slots
}
