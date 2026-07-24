package wallet

import (
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"os"
	"path/filepath"
	"strconv"
	"testing"

	orchestratorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/btcsuite/btcd/chaincfg"
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
	assert.Equal(t, WalletTypeEnforcer, w.WalletType) // first wallet should be enforcer
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
	assert.Equal(t, WalletTypeEnforcer, w1.WalletType)

	w2, err := svc.GenerateWallet("Second", "", "", testSlots)
	require.NoError(t, err)
	assert.Equal(t, WalletTypeBitcoinCore, w2.WalletType)

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

	require.NoError(t, svc.DeleteAllWallets(nil, nil))
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
	assert.Equal(t, WalletTypeEnforcer, wallet.WalletType)
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
		slots[i] = SidechainSlot{Slot: i, Name: "SC" + strconv.Itoa(i)}
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

func TestServiceCreateWatchOnlyWalletWithXpub(t *testing.T) {
	svc := newTestService(t)

	xpub := "xpub6CUGRUonZSQ4TWtTMmzXdrXDtypWKiKrhko4egpiMZbpiaQL2jkwSB1icqYh2cfDfVxdx4df189oLKnC5fSwqPfgyP3hooxujYzAu3fDVmz"
	gradientJSON := `{"background_svg":"test"}`

	err := svc.CreateWatchOnlyWallet("Watch Only Test", xpub, gradientJSON)
	require.NoError(t, err)

	assert.True(t, svc.HasWallet())
	assert.True(t, svc.IsUnlocked())

	wallets := svc.ListWallets()
	require.Len(t, wallets, 1)
	assert.Equal(t, "Watch Only Test", wallets[0].Name)
	assert.Equal(t, WalletTypeBitcoinCore, wallets[0].WalletType)

	// Verify active wallet is set
	assert.NotEmpty(t, svc.ActiveWalletID())
	assert.Equal(t, "Watch Only Test", svc.ActiveWalletName())

	// Verify wallet.json was written with correct structure
	data, err := os.ReadFile(filepath.Join(svc.bitwindowDir, "wallet.json"))
	require.NoError(t, err)

	var wf WalletFile
	require.NoError(t, json.Unmarshal(data, &wf))
	require.Len(t, wf.Wallets, 1)

	wallet := wf.Wallets[0]
	assert.Equal(t, WalletTypeBitcoinCore, wallet.WalletType)
	assert.True(t, wallet.IsWatchOnly(), "watch-only payload should be set")
	assert.Equal(t, 1, wallet.Version)
	assert.Empty(t, wallet.Master.SeedHex)
	assert.Empty(t, wallet.L1.Mnemonic)
	assert.Empty(t, wallet.Sidechains)
	assert.False(t, wallet.CreatedAt.IsZero())
	assert.JSONEq(t, gradientJSON, string(wallet.Gradient))

	// Verify watch_only contains xpub (not descriptor)
	var watchOnly map[string]string
	require.NoError(t, json.Unmarshal(wallet.WatchOnly, &watchOnly))
	assert.Equal(t, xpub, watchOnly["xpub"])
	assert.Empty(t, watchOnly["descriptor"])
}

func TestServiceCreateWatchOnlyWalletWithDescriptor(t *testing.T) {
	svc := newTestService(t)

	descriptor := "wpkh(xpub6CUGRUonZSQ4TWtTMmzXdrXDtypWKiKrhko4egpiMZbpiaQL2jkwSB1icqYh2cfDfVxdx4df189oLKnC5fSwqPfgyP3hooxujYzAu3fDVmz/0/*)"
	gradientJSON := `{"background_svg":"desc_test"}`

	err := svc.CreateWatchOnlyWallet("Descriptor Wallet", descriptor, gradientJSON)
	require.NoError(t, err)

	// Verify watch_only contains descriptor (not xpub)
	data, err := os.ReadFile(filepath.Join(svc.bitwindowDir, "wallet.json"))
	require.NoError(t, err)

	var wf WalletFile
	require.NoError(t, json.Unmarshal(data, &wf))
	require.Len(t, wf.Wallets, 1)

	var watchOnly map[string]string
	require.NoError(t, json.Unmarshal(wf.Wallets[0].WatchOnly, &watchOnly))
	assert.Equal(t, descriptor, watchOnly["descriptor"])
	assert.Empty(t, watchOnly["xpub"])
}

// TestServiceCreateElectrumWatchOnlyRejectsPrivateKey: importing a descriptor
// that carries a private extended key must fail so a watch-only wallet can
// never store or sign with private material.
func TestServiceCreateElectrumWatchOnlyRejectsPrivateKey(t *testing.T) {
	svc := newTestService(t)

	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	acct, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.True(t, acct.IsPrivate())

	desc := "wpkh(" + acct.String() + "/0/*)"
	_, err = svc.CreateElectrumWallet("Leaky", nil, nil, "", "", desc, "", 0, "")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "private key")
}

func TestServiceCreateWatchOnlyWalletAlongsideRegular(t *testing.T) {
	svc := newTestService(t)

	// Create a regular wallet first
	w1, err := svc.GenerateWallet("Regular Wallet", "", "", testSlots)
	require.NoError(t, err)
	assert.Equal(t, WalletTypeEnforcer, w1.WalletType)

	// Create a watch-only wallet
	xpub := "xpub6CUGRUonZSQ4TWtTMmzXdrXDtypWKiKrhko4egpiMZbpiaQL2jkwSB1icqYh2cfDfVxdx4df189oLKnC5fSwqPfgyP3hooxujYzAu3fDVmz"
	err = svc.CreateWatchOnlyWallet("Watch Only", xpub, `{"background_svg":""}`)
	require.NoError(t, err)

	wallets := svc.ListWallets()
	require.Len(t, wallets, 2)
	assert.Equal(t, WalletTypeEnforcer, wallets[0].WalletType)
	assert.Equal(t, WalletTypeBitcoinCore, wallets[1].WalletType)

	// Watch-only should now be active
	assert.Equal(t, wallets[1].ID, svc.ActiveWalletID())
}

func TestServiceCreateWatchOnlyWalletPersistence(t *testing.T) {
	dir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()

	xpub := "xpub6CUGRUonZSQ4TWtTMmzXdrXDtypWKiKrhko4egpiMZbpiaQL2jkwSB1icqYh2cfDfVxdx4df189oLKnC5fSwqPfgyP3hooxujYzAu3fDVmz"

	// Create watch-only wallet, then close
	svc1 := NewService(dir, log)
	require.NoError(t, svc1.Init())
	require.NoError(t, svc1.CreateWatchOnlyWallet("Persist WO", xpub, `{"background_svg":""}`))
	walletID := svc1.ActiveWalletID()
	svc1.Close()

	// Reload from disk
	svc2 := NewService(dir, log)
	require.NoError(t, svc2.Init())
	defer svc2.Close()

	assert.True(t, svc2.HasWallet())
	assert.Equal(t, walletID, svc2.ActiveWalletID())
	assert.Equal(t, "Persist WO", svc2.ActiveWalletName())

	wallets := svc2.ListWallets()
	require.Len(t, wallets, 1)
	assert.Equal(t, WalletTypeBitcoinCore, wallets[0].WalletType)
}

func TestServiceDeleteWatchOnlyWallet(t *testing.T) {
	svc := newTestService(t)

	// Create regular + watch-only
	w1, err := svc.GenerateWallet("Regular", "", "", testSlots)
	require.NoError(t, err)

	xpub := "xpub6CUGRUonZSQ4TWtTMmzXdrXDtypWKiKrhko4egpiMZbpiaQL2jkwSB1icqYh2cfDfVxdx4df189oLKnC5fSwqPfgyP3hooxujYzAu3fDVmz"
	require.NoError(t, svc.CreateWatchOnlyWallet("Watch Only", xpub, `{"background_svg":""}`))
	woID := svc.ActiveWalletID()

	// Delete watch-only
	require.NoError(t, svc.DeleteWallet(woID))

	wallets := svc.ListWallets()
	require.Len(t, wallets, 1)
	assert.Equal(t, w1.ID, wallets[0].ID)
	assert.Equal(t, w1.ID, svc.ActiveWalletID())
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

func TestServiceLegacyWalletTypeBackfill(t *testing.T) {
	dir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()

	// Hand-write a wallet.json that omits wallet_type — mirrors what users
	// generated before the field existed. Both shapes need a fix-up on load:
	// a wallet with a master mnemonic should land as "enforcer", a wallet
	// without one as "bitcoinCore". Without the backfill, the receive-tab
	// BIP47 spinner and the Starters tab both stay blank for these legacy
	// installs because every code path that branches on wallet_type defaults
	// to "not enforcer".
	legacyJSON := []byte(`{
		"version": 1,
		"activeWalletId": "LEGACY1",
		"wallets": [
			{
				"version": 1,
				"id": "LEGACY1",
				"name": "Legacy Hot",
				"createdAt": "2025-01-01T00:00:00Z",
				"master": {"mnemonic": "abandon abandon abandon", "seed_hex": ""},
				"l1": {"mnemonic": ""},
				"sidechains": []
			},
			{
				"version": 1,
				"id": "LEGACY2",
				"name": "Legacy Watch",
				"createdAt": "2025-01-01T00:00:00Z",
				"master": {"mnemonic": "", "seed_hex": ""},
				"l1": {"mnemonic": ""},
				"sidechains": []
			}
		]
	}`)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), legacyJSON, 0o600))

	svc := NewService(dir, log)
	require.NoError(t, svc.Init())
	defer svc.Close()

	wallets := svc.ListWallets()
	require.Len(t, wallets, 2)

	byID := map[string]WalletType{}
	for _, w := range wallets {
		byID[w.ID] = w.WalletType
	}
	assert.Equal(t, WalletTypeEnforcer, byID["LEGACY1"], "wallet with mnemonic should backfill to enforcer")
	assert.Equal(t, WalletTypeBitcoinCore, byID["LEGACY2"], "wallet without mnemonic should backfill to bitcoinCore")

	// Reload to confirm the backfill persisted to disk — otherwise the
	// receive-tab spinner would come back next launch.
	svc.Close()
	svc2 := NewService(dir, log)
	require.NoError(t, svc2.Init())
	defer svc2.Close()
	for _, w := range svc2.ListWallets() {
		require.NotEmpty(t, w.WalletType, "wallet_type must persist after backfill")
	}
}

func TestServiceDeleteAllWallets_SoftDeletesByMoving(t *testing.T) {
	dir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()
	svc := NewService(dir, log)
	require.NoError(t, svc.Init())
	defer svc.Close()

	w, err := svc.GenerateWallet("Soft", "", "", testSlots)
	require.NoError(t, err)
	require.NotEmpty(t, w.ID)
	require.NoError(t, svc.SyncBalance(orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND, w.ID, 11, 2, "Bitcoin"))

	walletPath := filepath.Join(dir, "wallet.json")
	originalBytes, err := os.ReadFile(walletPath)
	require.NoError(t, err)
	require.NotEmpty(t, originalBytes, "fixture: wallet.json must exist before reset")
	metadataBytes, err := os.ReadFile(svc.WalletMetadataFilePath())
	require.NoError(t, err)
	require.NotEmpty(t, metadataBytes, "fixture: metadata.json must exist before reset")

	// Hand the service a fake "binary wallet" so we can prove the same
	// soft-delete contract applies to per-binary paths (bitcoind wallets,
	// enforcer wallets, sidechain LMDBs). It lives outside `dir` to mirror
	// real installs where each binary has its own root.
	binDir := t.TempDir()
	fakeBinaryWallet := filepath.Join(binDir, "wallets")
	require.NoError(t, os.MkdirAll(fakeBinaryWallet, 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(fakeBinaryWallet, "wallet.dat"), []byte("priv-keys"), 0o600))
	svc.GetBinaryWalletPaths = func() []string { return []string{fakeBinaryWallet} }

	require.NoError(t, svc.DeleteAllWallets(nil, nil))

	// Original locations are GONE (moved, not lingering at the source).
	_, err = os.Stat(walletPath)
	assert.True(t, os.IsNotExist(err), "wallet.json must be moved off the original path")
	_, err = os.Stat(fakeBinaryWallet)
	assert.True(t, os.IsNotExist(err), "binary wallet path must be moved off the original path")

	// Backups land next to each source under wallet_backups/<ts>/<base>.
	bitwindowBackup := findBackup(t, filepath.Join(dir, "wallet_backups"), "wallet.json")
	require.NotEmpty(t, bitwindowBackup, "wallet.json must be soft-deleted under wallet_backups/")
	gotBytes, err := os.ReadFile(bitwindowBackup)
	require.NoError(t, err)
	assert.Equal(t, originalBytes, gotBytes, "soft-delete must preserve wallet bytes verbatim")
	gotMetadataBytes, err := os.ReadFile(filepath.Join(filepath.Dir(bitwindowBackup), "metadata.json"))
	require.NoError(t, err)
	assert.Equal(t, metadataBytes, gotMetadataBytes, "wallet metadata must stay with wallet.json in the same backup")

	binaryBackup := findBackup(t, filepath.Join(binDir, "wallet_backups"), "wallets")
	require.NotEmpty(t, binaryBackup, "binary wallet must be soft-deleted next to its source")
	keys, err := os.ReadFile(filepath.Join(binaryBackup, "wallet.dat"))
	require.NoError(t, err)
	assert.Equal(t, []byte("priv-keys"), keys, "private keys must survive soft-delete intact")
}

func TestServiceSyncBalanceWritesLatestKnownBalanceAndSkipsEqual(t *testing.T) {
	svc := newTestService(t)
	w, err := svc.GenerateWallet("Metadata", "", "", testSlots)
	require.NoError(t, err)

	require.NoError(t, svc.SyncBalance(orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND, w.ID, 123, 4, "Bitcoin"))
	meta, err := svc.loadWalletMetadataFile()
	require.NoError(t, err)
	assert.Equal(t, walletMetadataVersion, meta.Version)
	assert.Equal(t, w.ID, meta.ActiveWalletID)
	require.Len(t, meta.Wallets, 1)
	snap, ok := meta.LatestKnownBalance["bitcoind"]
	require.True(t, ok)
	assert.Equal(t, orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND, snap.Binary)
	assert.Equal(t, uint64(123), snap.ConfirmedSats)
	assert.Equal(t, uint64(4), snap.PendingSats)

	firstBytes, err := os.ReadFile(svc.WalletMetadataFilePath())
	require.NoError(t, err)
	require.NoError(t, svc.SyncBalance(orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND, w.ID, 123, 4, "Bitcoin"))
	secondBytes, err := os.ReadFile(svc.WalletMetadataFilePath())
	require.NoError(t, err)
	assert.Equal(t, firstBytes, secondBytes, "unchanged balance metadata should not be rewritten")

	require.NoError(t, svc.SyncBalance(orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND, w.ID, 124, 4, "Bitcoin"))
	meta, err = svc.loadWalletMetadataFile()
	require.NoError(t, err)
	assert.Equal(t, uint64(124), meta.LatestKnownBalance["bitcoind"].ConfirmedSats)
}

func TestServiceListWalletBackupsReadsUnencryptedMetadataForEncryptedBackup(t *testing.T) {
	svc := newTestService(t)
	w, err := svc.GenerateWallet("Encrypted metadata", "", "", testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.SyncBalance(orchestratorpb.BinaryType_BINARY_TYPE_THUNDER, w.ID, 42, 7, "Thunder"))
	require.NoError(t, svc.EncryptWallet("correct horse"))

	backupDir := filepath.Join(svc.bitwindowDir, "wallet_backups", "20240102-030405")
	require.NoError(t, os.MkdirAll(backupDir, 0o700))
	copyTestFile(t, svc.walletFilePath(), filepath.Join(backupDir, "wallet.json"))
	copyTestFile(t, svc.metadataFilePath(), filepath.Join(backupDir, "wallet_encryption.json"))
	copyTestFile(t, svc.WalletMetadataFilePath(), filepath.Join(backupDir, "metadata.json"))

	backups, err := svc.ListWalletBackups()
	require.NoError(t, err)
	require.Len(t, backups, 1)
	backup := backups[0]
	assert.True(t, backup.Valid)
	assert.True(t, backup.Encrypted)
	assert.True(t, backup.HasMetadata)
	assert.Equal(t, w.ID, backup.ActiveWalletID)
	require.Len(t, backup.LatestKnownBalance, 1)
	assert.Equal(t, orchestratorpb.BinaryType_BINARY_TYPE_THUNDER, backup.LatestKnownBalance[0].Binary)
	assert.Equal(t, uint64(42), backup.LatestKnownBalance[0].ConfirmedSats)
	assert.Equal(t, uint64(7), backup.LatestKnownBalance[0].PendingSats)
}

func TestServiceRestoreWalletBackupRequiresPasswordBeforeMovingCurrentWallet(t *testing.T) {
	svc := newTestService(t)
	w, err := svc.GenerateWallet("Encrypted restore", "", "", testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.SyncBalance(orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND, w.ID, 555, 0, "Bitcoin"))
	require.NoError(t, svc.EncryptWallet("correct horse"))

	backupDir := filepath.Join(svc.bitwindowDir, "wallet_backups", "20240103-040506")
	require.NoError(t, os.MkdirAll(backupDir, 0o700))
	copyTestFile(t, svc.walletFilePath(), filepath.Join(backupDir, "wallet.json"))
	copyTestFile(t, svc.metadataFilePath(), filepath.Join(backupDir, "wallet_encryption.json"))
	copyTestFile(t, svc.WalletMetadataFilePath(), filepath.Join(backupDir, "metadata.json"))
	encryptedWalletBytes, err := os.ReadFile(svc.walletFilePath())
	require.NoError(t, err)

	require.NoError(t, svc.RemoveEncryption("correct horse"))
	currentWalletBytes, err := os.ReadFile(svc.walletFilePath())
	require.NoError(t, err)
	_, err = os.Stat(svc.metadataFilePath())
	require.True(t, os.IsNotExist(err), "fixture: current wallet should be unencrypted before restore")

	backups, err := svc.ListWalletBackups()
	require.NoError(t, err)
	require.Len(t, backups, 1)

	err = svc.RestoreWalletBackup(backups[0].ID, "wrong horse")
	require.Error(t, err)
	afterBadPasswordBytes, err := os.ReadFile(svc.walletFilePath())
	require.NoError(t, err)
	assert.Equal(t, currentWalletBytes, afterBadPasswordBytes, "bad password must not move or overwrite current wallet")
	_, err = os.Stat(svc.metadataFilePath())
	require.True(t, os.IsNotExist(err), "bad password must not restore wallet_encryption.json")

	require.NoError(t, svc.RestoreWalletBackup(backups[0].ID, "correct horse"))
	restoredBytes, err := os.ReadFile(svc.walletFilePath())
	require.NoError(t, err)
	assert.Equal(t, encryptedWalletBytes, restoredBytes)
	assert.True(t, svc.IsEncrypted())
	meta, err := svc.loadWalletMetadataFile()
	require.NoError(t, err)
	assert.Equal(t, w.ID, meta.ActiveWalletID)
}

func TestServiceRestoreWalletBackupWithProgressReportsPlanAndStepStatuses(t *testing.T) {
	svc := newTestService(t)
	w, err := svc.GenerateWallet("Progress restore", "", "", testSlots)
	require.NoError(t, err)
	require.NoError(t, svc.SyncBalance(orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND, w.ID, 777, 0, "Bitcoin"))

	backupDir := filepath.Join(svc.bitwindowDir, "wallet_backups", "20240104-050607")
	require.NoError(t, os.MkdirAll(backupDir, 0o700))
	copyTestFile(t, svc.walletFilePath(), filepath.Join(backupDir, "wallet.json"))
	copyTestFile(t, svc.WalletMetadataFilePath(), filepath.Join(backupDir, "metadata.json"))

	backups, err := svc.ListWalletBackups()
	require.NoError(t, err)
	require.Len(t, backups, 1)

	plan, err := svc.RestoreWalletBackupPlan(backups[0].ID)
	require.NoError(t, err)
	require.Equal(t, []RestoreWalletBackupStep{
		{ID: restoreStepValidate, Name: "Validating wallet backup"},
		{ID: restoreStepBackupCurrent, Name: "Backing up current wallet"},
		{ID: restoreStepRestoreFiles, Name: "Restoring wallet files"},
		{ID: restoreStepLoadWallet, Name: "Loading restored wallet"},
		{ID: restoreStepComplete, Name: "Restore complete"},
	}, plan)

	var events []string
	err = svc.RestoreWalletBackupWithProgress(backups[0].ID, "", func(stepID string, status RestoreWalletBackupStepStatus, stepErr error) {
		require.NoError(t, stepErr)
		events = append(events, string(status)+":"+stepID)
	})
	require.NoError(t, err)
	require.Equal(t, []string{
		string(RestoreWalletBackupStepStarted) + ":" + restoreStepValidate,
		string(RestoreWalletBackupStepCompleted) + ":" + restoreStepValidate,
		string(RestoreWalletBackupStepStarted) + ":" + restoreStepBackupCurrent,
		string(RestoreWalletBackupStepCompleted) + ":" + restoreStepBackupCurrent,
		string(RestoreWalletBackupStepStarted) + ":" + restoreStepRestoreFiles,
		string(RestoreWalletBackupStepCompleted) + ":" + restoreStepRestoreFiles,
		string(RestoreWalletBackupStepStarted) + ":" + restoreStepLoadWallet,
		string(RestoreWalletBackupStepCompleted) + ":" + restoreStepLoadWallet,
		string(RestoreWalletBackupStepStarted) + ":" + restoreStepComplete,
		string(RestoreWalletBackupStepCompleted) + ":" + restoreStepComplete,
	}, events)
}

// findBackup walks `root/<ts>/` looking for an entry whose basename is `name`
// and returns its absolute path. Empty string if nothing matches — used by
// soft-delete tests to assert the backup landed in the expected per-source
// wallet_backups dir.
func findBackup(t *testing.T, root, name string) string {
	t.Helper()
	entries, err := os.ReadDir(root)
	if err != nil {
		return ""
	}
	for _, ts := range entries {
		if !ts.IsDir() {
			continue
		}
		candidate := filepath.Join(root, ts.Name(), name)
		if _, err := os.Stat(candidate); err == nil {
			return candidate
		}
	}
	return ""
}

func copyTestFile(t *testing.T, src, dst string) {
	t.Helper()
	data, err := os.ReadFile(src)
	require.NoError(t, err)
	info, err := os.Stat(src)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(dst, data, info.Mode().Perm()))
}
