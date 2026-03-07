package wallet

import (
	"encoding/base64"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/tyler-smith/go-bip39"
)

func newTestService(t *testing.T) *Service {
	t.Helper()
	dir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()
	svc := NewService(dir, log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	return svc
}

var testSlots = []SidechainSlot{
	{Slot: 9, Name: "Thunder"},
	{Slot: 5, Name: "BitNames"},
}

func TestServiceGenerateWallet(t *testing.T) {
	svc := newTestService(t)

	assert.False(t, svc.HasWallet())
	assert.False(t, svc.IsUnlocked())
	assert.False(t, svc.IsEncrypted())

	w, err := svc.GenerateWallet("Test Wallet", "", "", testSlots)
	require.NoError(t, err)

	assert.NotEmpty(t, w.ID)
	assert.Equal(t, "Test Wallet", w.Name)
	assert.Equal(t, "enforcer", w.WalletType) // first wallet should be enforcer
	assert.NotEmpty(t, w.Master.Mnemonic)
	assert.NotEmpty(t, w.Master.SeedHex)
	assert.NotEmpty(t, w.Master.MasterKey)
	assert.NotEmpty(t, w.Master.ChainCode)
	assert.NotEmpty(t, w.L1.Mnemonic)
	assert.Len(t, w.Sidechains, 2)
	assert.Equal(t, 9, w.Sidechains[0].Slot)
	assert.NotEmpty(t, w.Sidechains[0].Mnemonic)

	assert.True(t, svc.HasWallet())
	assert.True(t, svc.IsUnlocked())
	assert.Equal(t, w.ID, svc.ActiveWalletID())
	assert.Equal(t, "Test Wallet", svc.ActiveWalletName())

	// Verify wallet.json was written
	data, err := os.ReadFile(filepath.Join(svc.bitwindowDir, "wallet.json"))
	require.NoError(t, err)
	assert.Contains(t, string(data), "Test Wallet")
}

func TestServiceGenerateSecondWalletIsBitcoinCore(t *testing.T) {
	svc := newTestService(t)

	w1, err := svc.GenerateWallet("First", "", "", testSlots)
	require.NoError(t, err)
	assert.Equal(t, "enforcer", w1.WalletType)

	w2, err := svc.GenerateWallet("Second", "", "", testSlots)
	require.NoError(t, err)
	assert.Equal(t, "bitcoinCore", w2.WalletType)

	wallets := svc.ListWallets()
	assert.Len(t, wallets, 2)
}

func TestServiceGenerateWithCustomMnemonic(t *testing.T) {
	svc := newTestService(t)

	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	w, err := svc.GenerateWallet("Custom", mnemonic, "", testSlots)
	require.NoError(t, err)
	assert.Equal(t, mnemonic, w.Master.Mnemonic)
}

func TestServiceGenerateWithInvalidMnemonic(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.GenerateWallet("Bad", "not a valid mnemonic phrase at all here", "", testSlots)
	assert.Error(t, err)
}

func TestServiceWalletFilePersistence(t *testing.T) {
	dir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()

	// Create a wallet in one service instance
	svc1 := NewService(dir, log)
	require.NoError(t, svc1.Init())
	w, err := svc1.GenerateWallet("Persist Test", "", "", testSlots)
	require.NoError(t, err)
	svc1.Close()

	// Load it in a fresh service instance
	svc2 := NewService(dir, log)
	require.NoError(t, svc2.Init())
	defer svc2.Close()

	assert.True(t, svc2.HasWallet())
	assert.True(t, svc2.IsUnlocked())
	assert.Equal(t, w.ID, svc2.ActiveWalletID())
	assert.Equal(t, "Persist Test", svc2.ActiveWalletName())

	wallets := svc2.ListWallets()
	require.Len(t, wallets, 1)
	assert.Equal(t, w.ID, wallets[0].ID)
}

func TestServiceEncryptDecryptCycle(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.GenerateWallet("Encrypt Test", "", "", testSlots)
	require.NoError(t, err)

	// Encrypt
	require.NoError(t, svc.EncryptWallet("mypassword"))
	assert.True(t, svc.IsEncrypted())
	assert.True(t, svc.IsUnlocked()) // stays unlocked after encrypting

	// Verify wallet.json is actually encrypted (not valid JSON)
	data, err := os.ReadFile(filepath.Join(svc.bitwindowDir, "wallet.json"))
	require.NoError(t, err)
	var check map[string]interface{}
	assert.Error(t, json.Unmarshal(data, &check), "wallet.json should not be valid JSON when encrypted")

	// Verify metadata file exists
	metaData, err := os.ReadFile(filepath.Join(svc.bitwindowDir, "wallet_encryption.json"))
	require.NoError(t, err)
	meta, err := UnmarshalEncryptionMetadata(metaData)
	require.NoError(t, err)
	assert.True(t, meta.Encrypted)
	assert.Equal(t, DefaultIterations, meta.Iterations)

	// Lock
	svc.LockWallet()
	assert.False(t, svc.IsUnlocked())
	assert.True(t, svc.IsEncrypted())

	// Unlock with wrong password
	err = svc.UnlockWallet("wrongpassword")
	assert.Error(t, err)
	assert.False(t, svc.IsUnlocked())

	// Unlock with correct password
	require.NoError(t, svc.UnlockWallet("mypassword"))
	assert.True(t, svc.IsUnlocked())

	wallets := svc.ListWallets()
	require.Len(t, wallets, 1)
	assert.Equal(t, "Encrypt Test", wallets[0].Name)
}

func TestServiceChangePassword(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.GenerateWallet("PW Change", "", "", testSlots)
	require.NoError(t, err)

	require.NoError(t, svc.EncryptWallet("oldpass"))

	// Change with wrong old password
	err = svc.ChangePassword("wrongold", "newpass")
	assert.Error(t, err)

	// Change with correct old password
	require.NoError(t, svc.ChangePassword("oldpass", "newpass"))

	// Lock and unlock with new password
	svc.LockWallet()
	require.NoError(t, svc.UnlockWallet("newpass"))
	assert.True(t, svc.IsUnlocked())

	// Old password should no longer work
	svc.LockWallet()
	err = svc.UnlockWallet("oldpass")
	assert.Error(t, err)
}

func TestServiceRemoveEncryption(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.GenerateWallet("Decrypt Test", "", "", testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.EncryptWallet("mypass"))
	assert.True(t, svc.IsEncrypted())

	// Remove with wrong password
	err = svc.RemoveEncryption("wrongpass")
	assert.Error(t, err)

	// Remove with correct password
	require.NoError(t, svc.RemoveEncryption("mypass"))
	assert.False(t, svc.IsEncrypted())

	// Wallet should still be readable
	assert.True(t, svc.IsUnlocked())
	wallets := svc.ListWallets()
	require.Len(t, wallets, 1)

	// wallet.json should now be valid JSON again
	data, err := os.ReadFile(filepath.Join(svc.bitwindowDir, "wallet.json"))
	require.NoError(t, err)
	var check map[string]interface{}
	assert.NoError(t, json.Unmarshal(data, &check), "wallet.json should be valid JSON after removing encryption")
}

func TestServiceSwitchWallet(t *testing.T) {
	svc := newTestService(t)

	w1, err := svc.GenerateWallet("Wallet A", "", "", testSlots)
	require.NoError(t, err)
	w2, err := svc.GenerateWallet("Wallet B", "", "", testSlots)
	require.NoError(t, err)

	assert.Equal(t, w2.ID, svc.ActiveWalletID()) // latest should be active

	require.NoError(t, svc.SwitchWallet(w1.ID))
	assert.Equal(t, w1.ID, svc.ActiveWalletID())

	// Switch to nonexistent
	err = svc.SwitchWallet("nonexistent")
	assert.Error(t, err)
}

func TestServiceDeleteWallet(t *testing.T) {
	svc := newTestService(t)

	w1, err := svc.GenerateWallet("To Keep", "", "", testSlots)
	require.NoError(t, err)
	w2, err := svc.GenerateWallet("To Delete", "", "", testSlots)
	require.NoError(t, err)

	require.NoError(t, svc.DeleteWallet(w2.ID))

	wallets := svc.ListWallets()
	require.Len(t, wallets, 1)
	assert.Equal(t, w1.ID, wallets[0].ID)

	// Delete nonexistent
	err = svc.DeleteWallet("nope")
	assert.Error(t, err)
}

func TestServiceDeleteAllWallets(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.GenerateWallet("A", "", "", testSlots)
	require.NoError(t, err)
	_, err = svc.GenerateWallet("B", "", "", testSlots)
	require.NoError(t, err)

	require.NoError(t, svc.DeleteAllWallets())
	assert.False(t, svc.HasWallet())
	assert.False(t, svc.IsUnlocked())
	assert.Empty(t, svc.ActiveWalletID())
}

func TestServiceUpdateMetadata(t *testing.T) {
	svc := newTestService(t)

	w, err := svc.GenerateWallet("Original", "", "", testSlots)
	require.NoError(t, err)

	gradient := json.RawMessage(`{"color":"blue"}`)
	require.NoError(t, svc.UpdateWalletMetadata(w.ID, "Renamed", gradient))

	assert.Equal(t, "Renamed", svc.ActiveWalletName())

	wallets := svc.ListWallets()
	require.Len(t, wallets, 1)
	assert.Equal(t, "Renamed", wallets[0].Name)
	assert.JSONEq(t, `{"color":"blue"}`, string(wallets[0].Gradient))
}

func TestServiceStarterFiles(t *testing.T) {
	svc := newTestService(t)

	w, err := svc.GenerateWallet("Starter Test", "", "", testSlots)
	require.NoError(t, err)

	// Write L1 starter
	l1Path, err := svc.WriteL1Starter()
	require.NoError(t, err)
	assert.FileExists(t, l1Path)

	l1Data, err := os.ReadFile(l1Path)
	require.NoError(t, err)
	assert.Equal(t, w.L1.Mnemonic, string(l1Data))

	// Write sidechain starter (slot 9)
	scPath, err := svc.WriteSidechainStarter(9)
	require.NoError(t, err)
	assert.FileExists(t, scPath)

	scData, err := os.ReadFile(scPath)
	require.NoError(t, err)
	assert.Equal(t, w.Sidechains[0].Mnemonic, string(scData))

	// Nonexistent slot
	_, err = svc.WriteSidechainStarter(99)
	assert.Error(t, err)

	// Cleanup
	svc.CleanupStarterFiles()
	assert.NoFileExists(t, l1Path)
	assert.NoFileExists(t, scPath)
}

func TestServiceWalletJSONFormat(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.GenerateWallet("JSON Format", "", "", testSlots)
	require.NoError(t, err)

	data, err := os.ReadFile(filepath.Join(svc.bitwindowDir, "wallet.json"))
	require.NoError(t, err)

	// Verify JSON structure matches expected format
	var wf WalletFile
	require.NoError(t, json.Unmarshal(data, &wf))

	assert.Equal(t, 1, wf.Version)
	assert.NotEmpty(t, wf.ActiveWalletID)
	require.Len(t, wf.Wallets, 1)

	wallet := wf.Wallets[0]
	assert.Equal(t, 1, wallet.Version)
	assert.NotEmpty(t, wallet.Master.Mnemonic)
	assert.NotEmpty(t, wallet.Master.SeedHex)
	assert.NotEmpty(t, wallet.Master.MasterKey)
	assert.NotEmpty(t, wallet.Master.ChainCode)
	assert.NotEmpty(t, wallet.Master.BIP39Binary)
	assert.NotEmpty(t, wallet.Master.BIP39Checksum)
	assert.NotEmpty(t, wallet.Master.BIP39ChecksumHex)
	assert.Equal(t, "Master", wallet.Master.Name)
	assert.NotEmpty(t, wallet.L1.Mnemonic)
	assert.Equal(t, "Bitcoin Core (Patched)", wallet.L1.Name)
	assert.Len(t, wallet.Sidechains, 2)
	assert.Equal(t, "enforcer", wallet.WalletType)
	assert.NotEmpty(t, wallet.ID)
	assert.NotEmpty(t, wallet.Name)
	assert.False(t, wallet.CreatedAt.IsZero())

	// Verify JSON key names match Dart format
	var raw map[string]interface{}
	require.NoError(t, json.Unmarshal(data, &raw))
	assert.Contains(t, raw, "activeWalletId") // camelCase to match Dart
	assert.Contains(t, raw, "wallets")

	walletsRaw := raw["wallets"].([]interface{})
	w0 := walletsRaw[0].(map[string]interface{})
	assert.Contains(t, w0, "wallet_type")
	assert.Contains(t, w0, "created_at")

	master := w0["master"].(map[string]interface{})
	assert.Contains(t, master, "seed_hex")
	assert.Contains(t, master, "master_key")
	assert.Contains(t, master, "chain_code")
	assert.Contains(t, master, "bip39_binary")
}

func TestServiceDeterministicDerivation(t *testing.T) {
	svc := newTestService(t)

	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

	w1, err := svc.GenerateWallet("Det1", mnemonic, "", testSlots)
	require.NoError(t, err)

	// Create another service, same mnemonic should produce same L1 and sidechain mnemonics
	svc2 := newTestService(t)
	w2, err := svc2.GenerateWallet("Det2", mnemonic, "", testSlots)
	require.NoError(t, err)

	// Same master mnemonic
	assert.Equal(t, w1.Master.Mnemonic, w2.Master.Mnemonic)
	assert.Equal(t, w1.Master.SeedHex, w2.Master.SeedHex)
	assert.Equal(t, w1.Master.MasterKey, w2.Master.MasterKey)
	assert.Equal(t, w1.Master.ChainCode, w2.Master.ChainCode)

	// Same L1 mnemonic (deterministic derivation)
	assert.Equal(t, w1.L1.Mnemonic, w2.L1.Mnemonic)

	// Same sidechain mnemonics
	require.Len(t, w1.Sidechains, 2)
	require.Len(t, w2.Sidechains, 2)
	assert.Equal(t, w1.Sidechains[0].Mnemonic, w2.Sidechains[0].Mnemonic)
	assert.Equal(t, w1.Sidechains[1].Mnemonic, w2.Sidechains[1].Mnemonic)

	// Different IDs (randomly generated)
	assert.NotEqual(t, w1.ID, w2.ID)
}

func TestServiceEncryptBeforeWalletExists(t *testing.T) {
	svc := newTestService(t)

	err := svc.EncryptWallet("password")
	assert.Error(t, err, "should fail to encrypt when no wallet exists")
}

func TestServiceUnlockWithoutEncryption(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Test", "", "", testSlots)
	require.NoError(t, err)

	err = svc.UnlockWallet("password")
	assert.Error(t, err, "should fail to unlock a non-encrypted wallet")
}

func TestServiceRemoveEncryptionWithoutEncryption(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Test", "", "", testSlots)
	require.NoError(t, err)

	err = svc.RemoveEncryption("password")
	assert.Error(t, err, "should fail to remove encryption when not encrypted")
}

func TestServiceDoubleEncrypt(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Test", "", "", testSlots)
	require.NoError(t, err)

	require.NoError(t, svc.EncryptWallet("pass1"))
	err = svc.EncryptWallet("pass2")
	assert.Error(t, err, "should fail to encrypt an already encrypted wallet")
}

func TestServiceDeleteActiveWalletSwitchesToNext(t *testing.T) {
	svc := newTestService(t)

	w1, err := svc.GenerateWallet("First", "", "", testSlots)
	require.NoError(t, err)
	w2, err := svc.GenerateWallet("Second", "", "", testSlots)
	require.NoError(t, err)

	// w2 is active, switch to w1
	require.NoError(t, svc.SwitchWallet(w1.ID))
	assert.Equal(t, w1.ID, svc.ActiveWalletID())

	// Delete w1 (active) - should switch to w2
	require.NoError(t, svc.DeleteWallet(w1.ID))
	assert.Equal(t, w2.ID, svc.ActiveWalletID())
}

func TestServiceDeleteLastWalletClearsActive(t *testing.T) {
	svc := newTestService(t)

	w, err := svc.GenerateWallet("Only", "", "", testSlots)
	require.NoError(t, err)

	require.NoError(t, svc.DeleteWallet(w.ID))
	assert.Empty(t, svc.ActiveWalletID())
	assert.Empty(t, svc.ListWallets())
}

func TestServiceStarterFilesRequireActiveWallet(t *testing.T) {
	svc := newTestService(t)

	// No wallet at all
	_, err := svc.WriteL1Starter()
	assert.Error(t, err)

	_, err = svc.WriteSidechainStarter(9)
	assert.Error(t, err)
}

func TestServiceStarterFilesRequireEnforcerForL1(t *testing.T) {
	svc := newTestService(t)

	// Generate first wallet (enforcer) then delete it, add non-enforcer
	w1, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)

	// L1 should work with enforcer wallet
	_, err = svc.WriteL1Starter()
	require.NoError(t, err)

	// Add second wallet and delete enforcer
	_, err = svc.GenerateWallet("Other", "", "", testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.DeleteWallet(w1.ID))

	// L1 should fail - no enforcer wallet
	_, err = svc.WriteL1Starter()
	assert.Error(t, err, "L1 starter should require enforcer wallet")
}

func TestServiceMultipleWalletsListOrder(t *testing.T) {
	svc := newTestService(t)

	names := []string{"Alpha", "Beta", "Gamma", "Delta"}
	ids := make([]string, 4)
	for i, name := range names {
		w, err := svc.GenerateWallet(name, "", "", testSlots)
		require.NoError(t, err)
		ids[i] = w.ID
	}

	wallets := svc.ListWallets()
	require.Len(t, wallets, 4)

	// Should be in insertion order
	for i, w := range wallets {
		assert.Equal(t, names[i], w.Name)
		assert.Equal(t, ids[i], w.ID)
	}
}

func TestServiceUpdateMetadataNonexistent(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Test", "", "", testSlots)
	require.NoError(t, err)

	err = svc.UpdateWalletMetadata("nonexistent-id", "Name", nil)
	assert.Error(t, err)
}

func TestServiceGenerateWalletWithManySlots(t *testing.T) {
	svc := newTestService(t)

	slots := make([]SidechainSlot, 10)
	for i := range slots {
		slots[i] = SidechainSlot{Slot: i, Name: "SC" + itoa(i)}
	}

	w, err := svc.GenerateWallet("Many Slots", "", "", slots)
	require.NoError(t, err)

	assert.Len(t, w.Sidechains, 10)
	for i, sc := range w.Sidechains {
		assert.Equal(t, i, sc.Slot)
		assert.NotEmpty(t, sc.Mnemonic)
		assert.True(t, bip39.IsMnemonicValid(sc.Mnemonic))
	}
}

func TestServiceLockCleansStarterFiles(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.GenerateWallet("Test", "", "", testSlots)
	require.NoError(t, err)

	l1Path, err := svc.WriteL1Starter()
	require.NoError(t, err)
	assert.FileExists(t, l1Path)

	scPath, err := svc.WriteSidechainStarter(9)
	require.NoError(t, err)
	assert.FileExists(t, scPath)

	// Lock should clean up starter files
	svc.LockWallet()
	assert.NoFileExists(t, l1Path)
	assert.NoFileExists(t, scPath)
}

func TestServiceEncryptDecryptPreservesAllData(t *testing.T) {
	dir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()

	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

	// Phase 1: Create and encrypt
	svc := NewService(dir, log)
	require.NoError(t, svc.Init())
	w, err := svc.GenerateWallet("Preserve", mnemonic, "", testSlots)
	require.NoError(t, err)

	masterMnemonic := w.Master.Mnemonic
	seedHex := w.Master.SeedHex
	masterKey := w.Master.MasterKey
	chainCode := w.Master.ChainCode
	l1Mnemonic := w.L1.Mnemonic
	sc0Mnemonic := w.Sidechains[0].Mnemonic
	sc1Mnemonic := w.Sidechains[1].Mnemonic

	require.NoError(t, svc.EncryptWallet("secure123"))
	svc.Close()

	// Phase 2: Reload from disk, unlock, verify all data preserved
	svc2 := NewService(dir, log)
	require.NoError(t, svc2.Init())
	require.NoError(t, svc2.UnlockWallet("secure123"))
	defer svc2.Close()

	wallets := svc2.ListWallets()
	require.Len(t, wallets, 1)

	// Read and decrypt manually to verify all fields
	data, err := os.ReadFile(filepath.Join(dir, "wallet.json"))
	require.NoError(t, err)

	meta, err := svc2.loadMetadata()
	require.NoError(t, err)
	salt, err := base64.StdEncoding.DecodeString(meta.Salt)
	require.NoError(t, err)
	key := DeriveKey("secure123", salt, meta.Iterations)
	decrypted, err := Decrypt(string(data), key)
	require.NoError(t, err)

	var wf WalletFile
	require.NoError(t, json.Unmarshal([]byte(decrypted), &wf))
	require.Len(t, wf.Wallets, 1)

	wallet := wf.Wallets[0]
	assert.Equal(t, masterMnemonic, wallet.Master.Mnemonic)
	assert.Equal(t, seedHex, wallet.Master.SeedHex)
	assert.Equal(t, masterKey, wallet.Master.MasterKey)
	assert.Equal(t, chainCode, wallet.Master.ChainCode)
	assert.Equal(t, l1Mnemonic, wallet.L1.Mnemonic)
	assert.Equal(t, sc0Mnemonic, wallet.Sidechains[0].Mnemonic)
	assert.Equal(t, sc1Mnemonic, wallet.Sidechains[1].Mnemonic)
}

func TestServiceEncryptedPersistence(t *testing.T) {
	dir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()

	// Create, encrypt, close
	svc1 := NewService(dir, log)
	require.NoError(t, svc1.Init())
	w, err := svc1.GenerateWallet("EncPersist", "", "", testSlots)
	require.NoError(t, err)
	require.NoError(t, svc1.EncryptWallet("pass123"))
	svc1.Close()

	// New service - should see encrypted wallet but not be unlocked
	svc2 := NewService(dir, log)
	require.NoError(t, svc2.Init())
	defer svc2.Close()

	assert.True(t, svc2.HasWallet())
	assert.True(t, svc2.IsEncrypted())
	assert.False(t, svc2.IsUnlocked())

	// Unlock
	require.NoError(t, svc2.UnlockWallet("pass123"))
	assert.True(t, svc2.IsUnlocked())
	assert.Equal(t, w.ID, svc2.ActiveWalletID())
	assert.Equal(t, "EncPersist", svc2.ActiveWalletName())
}
