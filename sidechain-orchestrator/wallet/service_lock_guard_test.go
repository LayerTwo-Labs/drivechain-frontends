package wallet

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

// generateAndEncrypt returns a service holding one encrypted wallet, plus that
// wallet's id and the raw wallet file contents.
func generateAndEncrypt(t *testing.T, password string) (*Service, string, []byte) {
	t.Helper()
	svc := newTestService(t)

	w, err := svc.GenerateWallet("Original", "", "", testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.EncryptWallet(password))

	data, err := os.ReadFile(svc.walletFilePath())
	require.NoError(t, err)
	return svc, w.ID, data
}

// Generating a wallet while locked must not overwrite the locked wallets.
func TestGenerateWallet_WhileLocked_DoesNotOverwrite(t *testing.T) {
	svc, originalID, before := generateAndEncrypt(t, "correct horse")
	svc.LockWallet()
	require.False(t, svc.IsUnlocked())

	_, err := svc.GenerateWallet("Clobber", "", "", testSlots)
	require.Error(t, err, "generating while locked must fail")
	require.Contains(t, err.Error(), "locked")

	after, err := os.ReadFile(svc.walletFilePath())
	require.NoError(t, err)
	require.Equal(t, before, after, "wallet file must be untouched")

	require.NoError(t, svc.UnlockWallet("correct horse"))
	wallets := svc.ListWallets()
	require.Len(t, wallets, 1)
	require.Equal(t, originalID, wallets[0].ID, "the original wallet must survive")
}

// The locked save must not fall back to writing the wallet file in plaintext.
func TestGenerateWallet_WhileLocked_DoesNotWritePlaintext(t *testing.T) {
	svc, _, _ := generateAndEncrypt(t, "correct horse")
	svc.LockWallet()

	_, err := svc.GenerateWallet("Clobber", "", "", testSlots)
	require.Error(t, err)

	data, err := os.ReadFile(svc.walletFilePath())
	require.NoError(t, err)
	require.NotContains(t, string(data), "mnemonic", "wallet file must not be plaintext")
	require.NotContains(t, string(data), "Clobber")
}

// Changing the password while locked must leave the service locked, so a
// following generate cannot overwrite the wallets.
func TestChangePassword_WhileLocked_LeavesServiceLocked(t *testing.T) {
	svc, originalID, before := generateAndEncrypt(t, "old pass")
	svc.LockWallet()

	require.NoError(t, svc.ChangePassword("old pass", "new pass"), "changing password on disk still works while locked")
	require.False(t, svc.IsUnlocked(), "must stay locked after changing password")

	_, err := svc.GenerateWallet("Clobber", "", "", testSlots)
	require.Error(t, err, "generating after a locked password change must fail")

	after, err := os.ReadFile(svc.walletFilePath())
	require.NoError(t, err)
	require.NotEqual(t, before, after, "file is re-encrypted under the new password")

	require.NoError(t, svc.UnlockWallet("new pass"), "new password must work")
	wallets := svc.ListWallets()
	require.Len(t, wallets, 1)
	require.Equal(t, originalID, wallets[0].ID, "the original wallet must survive")
}

// Changing the password while unlocked keeps the session usable.
func TestChangePassword_WhileUnlocked_KeepsSessionUsable(t *testing.T) {
	svc, _, _ := generateAndEncrypt(t, "old pass")
	require.True(t, svc.IsUnlocked())

	require.NoError(t, svc.ChangePassword("old pass", "new pass"))
	require.True(t, svc.IsUnlocked(), "must stay unlocked")

	_, err := svc.GenerateWallet("Second", "", "", testSlots)
	require.NoError(t, err, "generating while unlocked must still work")
	require.Len(t, svc.ListWallets(), 2)

	svc.LockWallet()
	require.NoError(t, svc.UnlockWallet("new pass"), "new password must work")
	require.Len(t, svc.ListWallets(), 2)
}

// A failed create while locked must not leave a wallet in memory, which would
// read as unlocked and later be saved over the real encrypted wallet.
func TestGenerateWallet_WhileLocked_LeavesNoTransientWallet(t *testing.T) {
	svc, originalID, before := generateAndEncrypt(t, "correct horse")
	svc.LockWallet()

	_, err := svc.GenerateWallet("Clobber", "", "", testSlots)
	require.Error(t, err)
	require.False(t, svc.IsUnlocked(), "a failed create must not leave the service looking unlocked")
	require.Empty(t, svc.ListWallets(), "a failed create must not leave a wallet in memory")

	// A later password change must not persist the transient wallet.
	require.NoError(t, svc.ChangePassword("correct horse", "new pass"))
	after, err := os.ReadFile(svc.walletFilePath())
	require.NoError(t, err)
	require.NotEqual(t, before, after, "file is re-encrypted under the new password")

	require.NoError(t, svc.UnlockWallet("new pass"))
	wallets := svc.ListWallets()
	require.Len(t, wallets, 1)
	require.Equal(t, originalID, wallets[0].ID, "the original wallet must survive")
}

// Changing the password while unlocked with no wallets must still adopt the new
// key, else the next save encrypts with a stale key under the new metadata.
func TestChangePassword_UnlockedWithNoWallets_AdoptsNewKey(t *testing.T) {
	svc, originalID, _ := generateAndEncrypt(t, "old pass")
	require.True(t, svc.IsUnlocked())

	require.NoError(t, svc.DeleteWallet(originalID))
	require.Empty(t, svc.ListWallets(), "no wallets left, but still holding the key")

	require.NoError(t, svc.ChangePassword("old pass", "new pass"))

	// Saving now must use the new key, so the file stays readable with it.
	_, err := svc.GenerateWallet("Replacement", "", "", testSlots)
	require.NoError(t, err, "generating a replacement wallet must work")

	svc.LockWallet()
	require.NoError(t, svc.UnlockWallet("new pass"), "wallet must be decryptable with the new password")
	require.Len(t, svc.ListWallets(), 1)
	require.Equal(t, "Replacement", svc.ListWallets()[0].Name)
}

// An unencrypted wallet is unaffected by the guard.
func TestGenerateWallet_Unencrypted_StillWorks(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.GenerateWallet("First", "", "", testSlots)
	require.NoError(t, err)
	_, err = svc.GenerateWallet("Second", "", "", testSlots)
	require.NoError(t, err)
	require.Len(t, svc.ListWallets(), 2)
}
