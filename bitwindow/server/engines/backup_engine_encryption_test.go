package engines

import (
	"archive/zip"
	"bytes"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/wallet"
	"github.com/stretchr/testify/require"
)

// An encrypted wallet.json is "base64(iv):base64(ciphertext)", not JSON.
var (
	testEncryptedWallet = []byte("AAAAAAAAAAAAAAAA:c2VjcmV0")
	testEncryptionMeta  = []byte(`{"salt":"c2FsdA==","iterations":100000,"encrypted":true,"version":"1"}`)
)

// Backing up an encrypted wallet without its encryption metadata restores a
// wallet that reads as plaintext, and the correct password never opens it again.
func TestBackupRoundTrip_CarriesEncryptionMetadata(t *testing.T) {
	ctx := testCtx()
	db := database.Test(t)
	srcDir := t.TempDir()
	e := &BackupEngine{db: db, walletDir: srcDir, multisigStore: multisig.NewStore(db)}

	require.NoError(t, os.WriteFile(filepath.Join(srcDir, "wallet.json"), testEncryptedWallet, 0600))
	require.NoError(t, os.WriteFile(filepath.Join(srcDir, "wallet_encryption.json"), testEncryptionMeta, 0600))

	data, _, err := e.CreateBackup(ctx)
	require.NoError(t, err)

	contents, err := e.ValidateBackup(ctx, data, "backup.zip")
	require.NoError(t, err, "an encrypted backup must validate")
	require.True(t, contents.HasEncryptionMetadata, "backup must carry wallet_encryption.json")

	restoreDir := t.TempDir()
	r := &BackupEngine{db: db, walletDir: restoreDir, multisigStore: multisig.NewStore(db)}
	require.NoError(t, r.RestoreBackup(ctx, data, "backup.zip"))

	require.True(t, wallet.IsWalletEncrypted(restoreDir), "the restored wallet must still read as encrypted")
	gotMeta, err := os.ReadFile(filepath.Join(restoreDir, "wallet_encryption.json"))
	require.NoError(t, err)
	require.JSONEq(t, string(testEncryptionMeta), string(gotMeta), "salt and iterations must survive the round trip")
	gotWallet, err := os.ReadFile(filepath.Join(restoreDir, "wallet.json"))
	require.NoError(t, err)
	require.Equal(t, testEncryptedWallet, gotWallet)
}

// A leftover marker would make the restored plaintext wallet read as encrypted.
func TestRestoreBackup_PlaintextDropsStaleEncryptionMetadata(t *testing.T) {
	ctx := testCtx()
	db := database.Test(t)
	dir := t.TempDir()
	e := &BackupEngine{db: db, walletDir: dir, multisigStore: multisig.NewStore(db)}

	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet_encryption.json"), testEncryptionMeta, 0600))

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	require.NoError(t, addToZip(zw, "wallet.json", []byte(`{"master":"seed","l1":"key"}`)))
	require.NoError(t, zw.Close())

	require.NoError(t, e.RestoreBackup(ctx, buf.Bytes(), "backup.zip"))
	require.False(t, wallet.IsWalletEncrypted(dir), "a plaintext wallet must not read as encrypted")
}

// Backups taken before the metadata was included carry ciphertext only, so the
// marker already on disk is the last thing that can decrypt them.
func TestRestoreBackup_EncryptedWithoutMetadata_KeepsExistingMarker(t *testing.T) {
	ctx := testCtx()
	db := database.Test(t)
	dir := t.TempDir()
	e := &BackupEngine{db: db, walletDir: dir, multisigStore: multisig.NewStore(db)}

	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet_encryption.json"), testEncryptionMeta, 0600))

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	require.NoError(t, addToZip(zw, "wallet.json", testEncryptedWallet))
	require.NoError(t, zw.Close())

	require.NoError(t, e.RestoreBackup(ctx, buf.Bytes(), "backup.zip"))
	require.True(t, wallet.IsWalletEncrypted(dir), "the existing marker must be kept")
}
