package wallet

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const swapMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

// swapEnforcerWallet runs the prepare/commit pair the orchestrator drives.
func swapEnforcerWallet(t *testing.T, svc *Service, name string) *WalletData {
	t.Helper()
	prepared, err := svc.PrepareEnforcerWalletSwap(name, swapMnemonic, testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.CommitEnforcerWalletSwap(prepared))
	return prepared.Replacement
}

func TestSwapEnforcerWallet(t *testing.T) {
	svc := newTestService(t)

	original, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)
	other, err := svc.GenerateWallet("Core Wallet", "", "", testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.SwitchWallet(original.ID))

	swapped := swapEnforcerWallet(t, svc, "")

	assert.Equal(t, WalletTypeEnforcer, swapped.WalletType)
	assert.Equal(t, "Enforcer Wallet", swapped.Name, "an empty name keeps the current one")
	assert.Equal(t, swapMnemonic, swapped.Master.Mnemonic)
	assert.Equal(t, swapMnemonic, swapped.L1.Mnemonic)
	assert.True(t, swapped.Imported)
	assert.NotEqual(t, original.ID, swapped.ID)
	assert.Len(t, swapped.Sidechains, len(testSlots))

	assert.Equal(t, swapMnemonic, svc.GetL1Mnemonic())
	assert.Equal(t, swapped.ID, svc.ActiveWalletID(), "active follows the swapped wallet")

	require.Len(t, svc.GetAllWallets(), 2)
	assert.NotNil(t, svc.GetWalletByID(other.ID), "other wallets survive the swap")
	assert.Nil(t, svc.GetWalletByID(original.ID), "the old enforcer entry is gone")

	// The swap must survive a reload — it is only real once wallet.json holds it.
	reloaded := NewService(svc.bitwindowDir, svc.log)
	require.NoError(t, reloaded.Init())
	t.Cleanup(func() { reloaded.Close() })
	assert.Equal(t, swapMnemonic, reloaded.GetL1Mnemonic())
}

func TestSwapEnforcerWalletKeepsInactiveWalletActive(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)
	other, err := svc.GenerateWallet("Core Wallet", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, other.ID, svc.ActiveWalletID())

	swapEnforcerWallet(t, svc, "Swapped")

	assert.Equal(t, other.ID, svc.ActiveWalletID())
	assert.Equal(t, "Swapped", svc.EnforcerWallet().Name)
}

// Preparing must reject every unusable request, since the orchestrator stops the
// enforcer and moves its wallet on the strength of a prepared wallet.
func TestPrepareEnforcerWalletSwapRejects(t *testing.T) {
	t.Run("no enforcer wallet", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.PrepareEnforcerWalletSwap("", swapMnemonic, testSlots)
		assert.ErrorContains(t, err, "no enforcer wallet")
	})

	t.Run("empty mnemonic", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.PrepareEnforcerWalletSwap("", "", testSlots)
		assert.ErrorContains(t, err, "mnemonic is required")
	})

	t.Run("invalid mnemonic", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.PrepareEnforcerWalletSwap("", "not a real mnemonic", testSlots)
		assert.ErrorContains(t, err, "invalid mnemonic")
	})

	t.Run("locked wallet", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
		require.NoError(t, err)
		require.NoError(t, svc.EncryptWallet("hunter2"))
		svc.LockWallet()

		_, err = svc.PrepareEnforcerWalletSwap("", swapMnemonic, testSlots)
		assert.ErrorContains(t, err, "locked")
	})
}

// Only the enforcer is stopped and backed up by a swap, so re-deriving sidechain
// starters would strand every sidechain daemon on keys nothing records.
func TestSwapEnforcerWalletKeepsSidechainStarters(t *testing.T) {
	svc := newTestService(t)
	original, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)
	require.NotEmpty(t, original.Sidechains)

	swapped := swapEnforcerWallet(t, svc, "")

	assert.Equal(t, original.Sidechains, swapped.Sidechains)
	for _, slot := range testSlots {
		assert.Equal(t, svc.GetSidechainMnemonic(slot.Slot), starterFor(original.Sidechains, slot.Slot))
	}
	assert.NotEqual(t, original.Master.Mnemonic, swapped.Master.Mnemonic, "only the enforcer seed changes")
}

func starterFor(sidechains []SidechainWallet, slot int) string {
	for _, sc := range sidechains {
		if sc.Slot == slot {
			return sc.Mnemonic
		}
	}
	return ""
}

func TestPrepareEnforcerWalletSwapChangesNothing(t *testing.T) {
	svc := newTestService(t)
	original, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)

	_, err = svc.PrepareEnforcerWalletSwap("Swapped", swapMnemonic, testSlots)
	require.NoError(t, err)

	assert.Equal(t, original.Master.Mnemonic, svc.GetL1Mnemonic())
	assert.Equal(t, original.ID, svc.ActiveWalletID())
	assert.Equal(t, "Enforcer Wallet", svc.EnforcerWallet().Name)
}

// A commit that cannot persist must leave the process serving the wallet that is
// still on disk, or a restart would silently undo what callers were told landed.
func TestCommitEnforcerWalletSwapRollsBackOnSaveFailure(t *testing.T) {
	svc := newTestService(t)
	original, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)

	prepared, err := svc.PrepareEnforcerWalletSwap("Swapped", swapMnemonic, testSlots)
	require.NoError(t, err)

	// A directory where wallet.json belongs makes the atomic write fail.
	require.NoError(t, os.Remove(svc.walletFilePath()))
	require.NoError(t, os.Mkdir(svc.walletFilePath(), 0o700))

	require.Error(t, svc.CommitEnforcerWalletSwap(prepared))
	assert.Equal(t, original.Master.Mnemonic, svc.GetL1Mnemonic())
	assert.Equal(t, original.ID, svc.ActiveWalletID())
}

// A restore landing between prepare and commit replaces the wallet the swap was
// derived from; committing anyway would silently overwrite it with a wallet
// carrying the old one's name and sidechain starters.
func TestCommitEnforcerWalletSwapRejectsStalePreparation(t *testing.T) {
	svc := newTestService(t)
	original, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)

	prepared, err := svc.PrepareEnforcerWalletSwap("Swapped", swapMnemonic, testSlots)
	require.NoError(t, err)

	// Stand in for any whole-wallet mutation racing the swap.
	require.NoError(t, svc.DeleteWallet(original.ID))
	replacementEnforcer, err := svc.GenerateWallet("Restored Enforcer", "", "", testSlots)
	require.NoError(t, err)

	assert.ErrorContains(t, svc.CommitEnforcerWalletSwap(prepared), "changed while the swap was in progress")
	assert.Equal(t, replacementEnforcer.ID, svc.EnforcerWallet().ID, "the wallet that arrived in between survives")
}

// The prepared wallet is a snapshot of everything except the seed, so anything
// that changed the live wallet in between must not be rolled back with it.
func TestCommitEnforcerWalletSwapKeepsLaterMetadataChanges(t *testing.T) {
	svc := newTestService(t)
	original, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)

	prepared, err := svc.PrepareEnforcerWalletSwap("", swapMnemonic, testSlots)
	require.NoError(t, err)

	require.NoError(t, svc.UpdateWalletMetadata(original.ID, "Renamed Later", json.RawMessage(`{"background_svg":"later"}`)))
	require.NoError(t, svc.CommitEnforcerWalletSwap(prepared))

	swapped := svc.EnforcerWallet()
	assert.Equal(t, "Renamed Later", swapped.Name, "a rename that landed after preparation survives")
	assert.JSONEq(t, `{"background_svg":"later"}`, string(swapped.Gradient))
	assert.Equal(t, swapMnemonic, swapped.Master.Mnemonic, "and the seed is still the swapped-in one")
}

func TestCommitEnforcerWalletSwapPrefersTheRequestedName(t *testing.T) {
	svc := newTestService(t)
	original, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)

	prepared, err := svc.PrepareEnforcerWalletSwap("Chosen", swapMnemonic, testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.UpdateWalletMetadata(original.ID, "Renamed Later", nil))

	require.NoError(t, svc.CommitEnforcerWalletSwap(prepared))
	assert.Equal(t, "Chosen", svc.EnforcerWallet().Name)
}

func TestCopyMasterWalletFilesToBackup(t *testing.T) {
	svc := newTestService(t)

	original, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)

	dir, err := svc.CopyMasterWalletFilesToBackup()
	require.NoError(t, err)
	assert.FileExists(t, filepath.Join(dir, "wallet.json"))
	assert.FileExists(t, svc.walletFilePath(), "the live wallet file stays in place")

	swapEnforcerWallet(t, svc, "")

	backups, err := svc.ListWalletBackups()
	require.NoError(t, err)
	require.Len(t, backups, 1)
	require.Len(t, backups[0].Wallets, 1)
	assert.Equal(t, original.ID, backups[0].Wallets[0].ID, "the pre-swap wallet is restorable")

	require.NoError(t, svc.RestoreWalletBackup(backups[0].ID, ""))
	assert.Equal(t, original.Master.Mnemonic, svc.GetL1Mnemonic())
}

// A half-written snapshot would list as a valid plaintext backup — only
// wallet.json has to be present — so it must not survive a failed copy.
func TestCopyMasterWalletFilesToBackupRemovesPartialSnapshots(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)

	// A directory where wallet_encryption.json belongs fails the copy after
	// wallet.json has already landed in the snapshot. Unreadable file modes
	// would not do: Windows has no way to take read permission away.
	require.NoError(t, os.Mkdir(svc.metadataFilePath(), 0o700))

	_, err = svc.CopyMasterWalletFilesToBackup()
	require.Error(t, err)

	backups, err := svc.ListWalletBackups()
	require.NoError(t, err)
	assert.Empty(t, backups, "a partial snapshot is not offered for restore")
}

// Restoring a snapshot from before a swap brings back the old seed; the live
// enforcer state belongs to the new one and must not be paired with it.
func TestRestoreClearsEnforcerStateWhenSeedChanges(t *testing.T) {
	svc := newTestService(t)
	enforcerDir := t.TempDir()
	walletDir := filepath.Join(enforcerDir, "wallet", "signet")
	require.NoError(t, os.MkdirAll(walletDir, 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet.sqlite"), []byte("bdk"), 0o600))
	svc.GetEnforcerWalletPaths = func() []string { return []string{walletDir} }

	_, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)
	_, err = svc.CopyMasterWalletFilesToBackup()
	require.NoError(t, err)

	swapEnforcerWallet(t, svc, "")

	backups, err := svc.ListWalletBackups()
	require.NoError(t, err)
	require.Len(t, backups, 1)
	require.NoError(t, svc.RestoreWalletBackup(backups[0].ID, ""))

	assert.NoDirExists(t, walletDir, "state built from the swapped-in seed is moved aside")
	assert.NotEmpty(t, findBackup(t, filepath.Join(enforcerDir, "wallet", "wallet_backups"), "signet"))
}

func TestRestoreKeepsEnforcerStateWhenSeedIsUnchanged(t *testing.T) {
	svc := newTestService(t)
	enforcerDir := t.TempDir()
	walletDir := filepath.Join(enforcerDir, "wallet", "signet")
	require.NoError(t, os.MkdirAll(walletDir, 0o700))
	svc.GetEnforcerWalletPaths = func() []string { return []string{walletDir} }

	_, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)
	_, err = svc.CopyMasterWalletFilesToBackup()
	require.NoError(t, err)

	backups, err := svc.ListWalletBackups()
	require.NoError(t, err)
	require.Len(t, backups, 1)
	require.NoError(t, svc.RestoreWalletBackup(backups[0].ID, ""))

	assert.DirExists(t, walletDir, "an unchanged seed keeps its synced state")
}

// wallet.json alone makes a directory read as a valid plaintext backup, so a
// snapshot must not be listable until every file has landed.
func TestCopyMasterWalletFilesToBackupPublishesOnlyWhenComplete(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.EncryptWallet("hunter2"))

	dir, err := svc.CopyMasterWalletFilesToBackup()
	require.NoError(t, err)
	assert.NotContains(t, filepath.Base(dir), "incomplete", "the published name is the plain timestamp")

	backups, err := svc.ListWalletBackups()
	require.NoError(t, err)
	require.Len(t, backups, 1)
	assert.True(t, backups[0].Encrypted, "an encrypted wallet is never listed as plaintext")

	// A staging directory left behind by a crash stays invisible.
	require.NoError(t, os.Mkdir(filepath.Join(svc.bitwindowDir, "wallet_backups", ".20240102-030405.incomplete"), 0o700))
	backups, err = svc.ListWalletBackups()
	require.NoError(t, err)
	assert.Len(t, backups, 1)
}

// Timestamps resolve to the second, so two backups in the same second must not
// land in one directory and overwrite each other's wallet.json.
func TestCopyMasterWalletFilesToBackupNeverCollides(t *testing.T) {
	svc := newTestService(t)
	original, err := svc.GenerateWallet("Enforcer Wallet", "", "", testSlots)
	require.NoError(t, err)

	first, err := svc.CopyMasterWalletFilesToBackup()
	require.NoError(t, err)

	swapEnforcerWallet(t, svc, "")

	second, err := svc.CopyMasterWalletFilesToBackup()
	require.NoError(t, err)
	require.NotEqual(t, first, second)

	summaries, _, err := readPlainWalletSummary(filepath.Join(first, "wallet.json"))
	require.NoError(t, err)
	require.Len(t, summaries, 1)
	assert.Equal(t, original.ID, summaries[0].ID, "the older snapshot still holds the pre-swap wallet")
}
