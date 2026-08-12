package orchestrator

import (
	"context"
	"errors"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

const swapTestMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

func TestSwapEnforcerWalletPlan(t *testing.T) {
	var ids []string
	for _, step := range SwapEnforcerWalletPlan() {
		ids = append(ids, step.ID)
		assert.NotEmpty(t, step.Name)
	}
	assert.Equal(t, []string{
		SwapEnforcerStepValidate,
		SwapEnforcerStepStop,
		SwapEnforcerStepBackup,
		SwapEnforcerStepApply,
		SwapEnforcerStepRestart,
	}, ids)
}

// A swap that fails validation must report the failure on the validate step and
// stop there: nothing may be moved or restarted on a bad request.
func TestSwapEnforcerWalletValidation(t *testing.T) {
	tests := []struct {
		name       string
		withWallet bool
		locked     bool
		mnemonic   string
		wantErr    string
	}{
		{name: "no wallet service", mnemonic: swapTestMnemonic, wantErr: "wallet service is not available"},
		{name: "empty mnemonic", withWallet: true, wantErr: "mnemonic is required"},
		{name: "invalid mnemonic", withWallet: true, mnemonic: "not a real mnemonic", wantErr: "invalid mnemonic"},
		{name: "no enforcer wallet", withWallet: true, mnemonic: swapTestMnemonic, wantErr: "no enforcer wallet"},
		{name: "locked wallet", withWallet: true, locked: true, mnemonic: swapTestMnemonic, wantErr: "locked"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			o := newTestOrchestrator(t)
			if tt.withWallet {
				o.WalletSvc = newSwapTestWalletService(t)
			}
			if tt.locked {
				_, err := o.WalletSvc.GenerateWallet("Enforcer Wallet", "", "", WalletSidechainSlots())
				require.NoError(t, err)
				require.NoError(t, o.WalletSvc.EncryptWallet("hunter2"))
				o.WalletSvc.LockWallet()
			}

			var failed []string
			_, err := o.SwapEnforcerWallet(context.Background(), SwapEnforcerWalletRequest{Mnemonic: tt.mnemonic},
				func(stepID string, status SwapEnforcerWalletStepStatus, _ string, _ error) {
					if status == SwapEnforcerWalletStepFailed {
						failed = append(failed, stepID)
					}
				})

			assert.ErrorContains(t, err, tt.wantErr)
			assert.Equal(t, []string{SwapEnforcerStepValidate}, failed)
		})
	}
}

func TestBackupEnforcerWalletPaths(t *testing.T) {
	home := redirectHome(t)
	o := newTestOrchestrator(t)
	o.WalletSvc = newSwapTestWalletService(t)

	walletDir := filepath.Join(enforcerRoot(home), "wallet", "signet")
	writeStub(t, filepath.Join(walletDir, "wallet.sqlite"))

	moved, err := o.backupEnforcerWalletPaths()
	require.NoError(t, err)
	require.Len(t, moved, 1)

	assert.NoDirExists(t, walletDir, "the live wallet directory is moved aside")
	assert.FileExists(t, filepath.Join(moved[0].to, "wallet.sqlite"), "its contents survive under wallet_backups/")
	assert.Contains(t, moved[0].to, filepath.Join("wallet", "wallet_backups"))

	// A swap that fails after the move must be able to undo it.
	o.restoreEnforcerWalletPaths(moved)
	assert.FileExists(t, filepath.Join(walletDir, "wallet.sqlite"), "the wallet is back where the daemon looks for it")
	assert.NoDirExists(t, moved[0].to)
}

// The seed in wallet.json is global, so a wallet directory left behind for an
// inactive network would pair old BDK state with the new seed on the next
// network switch.
func TestBackupEnforcerWalletPathsCoversEveryNetwork(t *testing.T) {
	home := redirectHome(t)
	o := newTestOrchestrator(t)
	o.WalletSvc = newSwapTestWalletService(t)

	networks := []string{"signet", "regtest", "bitcoin"}
	for _, network := range networks {
		writeStub(t, filepath.Join(enforcerRoot(home), "wallet", network, "wallet.sqlite"))
	}

	moved, err := o.backupEnforcerWalletPaths()
	require.NoError(t, err)
	require.Len(t, moved, len(networks), "every network's wallet is moved aside, not just the active one")

	for _, network := range networks {
		assert.NoDirExists(t, filepath.Join(enforcerRoot(home), "wallet", network))
	}
	o.restoreEnforcerWalletPaths(moved)
	for _, network := range networks {
		assert.FileExists(t, filepath.Join(enforcerRoot(home), "wallet", network, "wallet.sqlite"))
	}
}

// wallet_backups/ lives beside the network directories; moving it into itself
// would bury every earlier backup.
func TestEnforcerWalletDirsSkipsBackups(t *testing.T) {
	home := redirectHome(t)
	writeStub(t, filepath.Join(enforcerRoot(home), "wallet", "signet", "wallet.sqlite"))
	writeStub(t, filepath.Join(enforcerRoot(home), "wallet", "wallet_backups", "20240102-030405", "signet", "wallet.sqlite"))

	dirs, err := enforcerWalletDirs()
	require.NoError(t, err)
	assert.Equal(t, []string{filepath.Join(enforcerRoot(home), "wallet", "signet")}, dirs)
}

func TestSwapEnforcerWalletRejectsConcurrentSwaps(t *testing.T) {
	o := newTestOrchestrator(t)
	o.WalletSvc = newSwapTestWalletService(t)

	o.swapEnforcerMu.Lock()
	defer o.swapEnforcerMu.Unlock()

	_, err := o.SwapEnforcerWallet(context.Background(), SwapEnforcerWalletRequest{Mnemonic: swapTestMnemonic}, nil)
	assert.ErrorContains(t, err, "already in progress")
}

// Rolling back must not hand a wallet that arrived mid-swap the previous
// wallet's daemon state — that is the mismatch the swap exists to avoid.
func TestRollbackKeepsMovedStateWhenTheWalletChanged(t *testing.T) {
	home := redirectHome(t)
	o := newTestOrchestrator(t)
	o.WalletSvc = newSwapTestWalletService(t)

	walletDir := filepath.Join(enforcerRoot(home), "wallet", "signet")
	writeStub(t, filepath.Join(walletDir, "wallet.sqlite"))
	moved, err := o.backupEnforcerWalletPaths()
	require.NoError(t, err)
	require.Len(t, moved, 1)

	cause := errors.New("commit rejected")

	// "someone-else" stands in for the wallet a concurrent restore left behind.
	err = o.rollbackEnforcerSwap(context.Background(), cause, false, moved, "someone-else")
	require.ErrorIs(t, err, cause)
	assert.NoDirExists(t, walletDir, "the old seed's state stays under wallet_backups/")
	assert.FileExists(t, filepath.Join(moved[0].to, "wallet.sqlite"), "and is still recoverable")
}

func TestRollbackRestoresStateWhenTheWalletIsUnchanged(t *testing.T) {
	home := redirectHome(t)
	o := newTestOrchestrator(t)
	o.WalletSvc = newSwapTestWalletService(t)

	enforcerWallet, err := o.WalletSvc.GenerateWallet("Enforcer Wallet", "", "", WalletSidechainSlots())
	require.NoError(t, err)

	walletDir := filepath.Join(enforcerRoot(home), "wallet", "signet")
	writeStub(t, filepath.Join(walletDir, "wallet.sqlite"))
	moved, err := o.backupEnforcerWalletPaths()
	require.NoError(t, err)

	cause := errors.New("snapshot failed")
	err = o.rollbackEnforcerSwap(context.Background(), cause, false, moved, enforcerWallet.ID)
	require.ErrorIs(t, err, cause)
	assert.FileExists(t, filepath.Join(walletDir, "wallet.sqlite"), "the wallet it belongs to is still in charge")
}

// A boot issued while a swap owns the enforcer would write a starter file from
// the seed that is being replaced.
func TestStartEnforcerRefusedDuringSwap(t *testing.T) {
	o := newTestOrchestrator(t)
	o.swapEnforcerActive.Store(true)

	o.startEnforcerWhenReady(context.Background(), StartOpts{}, nil)

	mon := o.getOrCreateMonitor("enforcer", NewHealthChecker(o.configs["enforcer"]), enforcerStartupPatterns)
	assert.Contains(t, mon.ConnectionError(), "swap is in progress")
	assert.False(t, o.process.IsRunning("enforcer"), "no daemon is spawned")
}

func TestBackupEnforcerWalletPathsWithoutWalletOnDisk(t *testing.T) {
	redirectHome(t)
	o := newTestOrchestrator(t)
	o.WalletSvc = newSwapTestWalletService(t)

	moved, err := o.backupEnforcerWalletPaths()
	require.NoError(t, err)
	assert.Empty(t, moved)
}

func TestStopEnforcerForSwapWhenNotRunning(t *testing.T) {
	o := newTestOrchestrator(t)

	wasRunning, detail, err := o.stopEnforcerForSwap(context.Background())
	require.NoError(t, err)
	assert.False(t, wasRunning)
	assert.Equal(t, "enforcer already stopped", detail)
}

// startEnforcerWhenReady reports its failures to the monitor and returns, and
// RestartDaemon emits "done" regardless — so an enforcer that never came up must
// not read as a completed swap.
func TestEnforcerStartOutcome(t *testing.T) {
	t.Run("not running", func(t *testing.T) {
		o := newTestOrchestrator(t)
		assert.ErrorContains(t, o.enforcerStartOutcome(context.Background()), "did not start")
	})

	t.Run("surfaces the monitor error", func(t *testing.T) {
		o := newTestOrchestrator(t)
		mon := o.getOrCreateMonitor("enforcer", NewHealthChecker(o.configs["enforcer"]), enforcerStartupPatterns)
		mon.SetConnectionError("cannot start enforcer without L1 wallet seed")

		assert.ErrorContains(t, o.enforcerStartOutcome(context.Background()), "cannot start enforcer without L1 wallet seed")
	})
}

// The boot runs on a detached context so the enforcer's timers survive the
// request, which means a Core that never finishes header sync keeps the progress
// channel open forever. Waiting on it must still end, or the RPC hangs and the
// swap lock is never released.
func TestAwaitEnforcerBoot(t *testing.T) {
	t.Run("gives up on a cancelled request", func(t *testing.T) {
		ctx, cancel := context.WithCancel(context.Background())
		cancel()

		err := awaitEnforcerBoot(ctx, make(chan error), time.Minute)
		assert.ErrorIs(t, err, context.Canceled)
	})

	t.Run("gives up at the deadline", func(t *testing.T) {
		err := awaitEnforcerBoot(context.Background(), make(chan error), 10*time.Millisecond)
		assert.ErrorContains(t, err, "did not complete within")
	})

	t.Run("reports the boot error", func(t *testing.T) {
		ch := make(chan StartupProgress, 2)
		ch <- StartupProgress{Error: errors.New("zmq unreachable")}
		close(ch)

		err := awaitEnforcerBoot(context.Background(), drainEnforcerBoot(ch), time.Minute)
		assert.ErrorIs(t, err, errEnforcerBootFailed, "a finished-and-failed boot is not one we stopped waiting for")
		assert.ErrorContains(t, err, "zmq unreachable")
	})

	t.Run("succeeds on a clean boot", func(t *testing.T) {
		ch := make(chan StartupProgress, 1)
		ch <- StartupProgress{Stage: "done", Done: true}
		close(ch)

		assert.NoError(t, awaitEnforcerBoot(context.Background(), drainEnforcerBoot(ch), time.Minute))
	})
}

func TestWalletSidechainSlotsCoversEverySidechain(t *testing.T) {
	assert.Len(t, WalletSidechainSlots(), len(AllSidechains()))
}

func newSwapTestWalletService(t *testing.T) *wallet.Service {
	t.Helper()
	svc := wallet.NewService(t.TempDir(), testLogger(t))
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	return svc
}
