package engines

import (
	"archive/zip"
	"bytes"
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
)

func TestValidateBackup_JSON_Valid(t *testing.T) {
	e := &BackupEngine{}
	wallet := map[string]interface{}{
		"master": "seed",
		"l1":     "key",
	}
	data, _ := json.Marshal(wallet)

	contents, err := e.ValidateBackup(context.TODO(), data, "wallet.json")
	require.NoError(t, err)
	require.True(t, contents.HasWallet)
}

func TestValidateBackup_JSON_NewFormat(t *testing.T) {
	e := &BackupEngine{}
	wallet := map[string]interface{}{
		"wallets": []map[string]interface{}{
			{"master": "seed", "l1": "key"},
		},
	}
	data, _ := json.Marshal(wallet)

	contents, err := e.ValidateBackup(context.TODO(), data, "backup.json")
	require.NoError(t, err)
	require.True(t, contents.HasWallet)
}

func TestValidateBackup_JSON_Invalid(t *testing.T) {
	e := &BackupEngine{}
	wallet := map[string]interface{}{
		"foo": "bar",
	}
	data, _ := json.Marshal(wallet)

	_, err := e.ValidateBackup(context.TODO(), data, "wallet.json")
	require.ErrorContains(t, err, "invalid wallet.json")
}

func TestValidateBackup_ZIP_Valid(t *testing.T) {
	e := &BackupEngine{}

	wallet := map[string]interface{}{"master": "seed", "l1": "key"}
	walletData, _ := json.Marshal(wallet)

	multisig := map[string]interface{}{"groups": []interface{}{}}
	msData, _ := json.Marshal(multisig)

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	w, _ := zw.Create("wallet.json")
	_, _ = w.Write(walletData)
	w, _ = zw.Create("multisig/multisig.json")
	_, _ = w.Write(msData)
	_ = zw.Close()

	contents, err := e.ValidateBackup(context.TODO(), buf.Bytes(), "backup.zip")
	require.NoError(t, err)
	require.True(t, contents.HasWallet)
	require.True(t, contents.HasMultisig)
}

func TestValidateBackup_ZIP_MissingWallet(t *testing.T) {
	e := &BackupEngine{}

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	w, _ := zw.Create("README.txt")
	_, _ = w.Write([]byte("hello"))
	_ = zw.Close()

	_, err := e.ValidateBackup(context.TODO(), buf.Bytes(), "backup.zip")
	require.ErrorContains(t, err, "backup is missing wallet.json")
}

func TestValidateBackup_UnsupportedExtension(t *testing.T) {
	e := &BackupEngine{}

	_, err := e.ValidateBackup(context.TODO(), []byte("data"), "backup.tar.gz")
	require.ErrorContains(t, err, "unsupported file type")
}

func testCtx() context.Context {
	logger := zerolog.Nop()
	return logger.WithContext(context.Background())
}

func TestCreateBackup(t *testing.T) {
	db := database.Test(t)

	t.Run("missing wallet.json returns an error and no zip", func(t *testing.T) {
		e := &BackupEngine{db: db, walletDir: t.TempDir(), multisigStore: multisig.NewStore(db)}

		data, filename, err := e.CreateBackup(t.Context())
		require.ErrorIs(t, err, os.ErrNotExist)
		require.Nil(t, data)
		require.Empty(t, filename)
	})

	t.Run("unreadable wallet.json returns an error and no zip", func(t *testing.T) {
		dir := t.TempDir()
		require.NoError(t, os.Mkdir(filepath.Join(dir, "wallet.json"), 0700))
		e := &BackupEngine{db: db, walletDir: dir, multisigStore: multisig.NewStore(db)}

		data, _, err := e.CreateBackup(t.Context())
		require.ErrorContains(t, err, "read wallet.json")
		require.Nil(t, data)
	})

	t.Run("zip holds the wallet", func(t *testing.T) {
		dir := t.TempDir()
		walletJSON := []byte(`{"master":"seed","l1":"key"}`)
		require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), walletJSON, 0600))
		e := &BackupEngine{db: db, walletDir: dir, multisigStore: multisig.NewStore(db)}

		data, _, err := e.CreateBackup(t.Context())
		require.NoError(t, err)
		gotWallet, _, _, _, _, err := extractZIP(data)
		require.NoError(t, err)
		require.Equal(t, walletJSON, gotWallet)
	})
}

func TestRestoreBackup_JSON(t *testing.T) {
	tmpDir := t.TempDir()

	e := &BackupEngine{
		walletDir: tmpDir,
	}

	wallet := map[string]interface{}{"master": "seed", "l1": "key"}
	data, _ := json.Marshal(wallet)

	err := e.RestoreBackup(testCtx(), data, "wallet.json")
	require.NoError(t, err)

	// Verify wallet.json was written
	content, err := os.ReadFile(filepath.Join(tmpDir, "wallet.json"))
	require.NoError(t, err)
	var restored map[string]interface{}
	_ = json.Unmarshal(content, &restored)
	require.Equal(t, "seed", restored["master"])
}

func TestRestoreBackup_ReplacesExistingWallet(t *testing.T) {
	resident := []byte(`{"wallets":[{"id":"old","master":"old-seed","l1":"old-key"}]}`)
	backup := []byte(`{"wallets":[{"id":"new","master":"new-seed","l1":"new-key"}]}`)

	for _, tc := range []struct {
		name    string
		current []byte
	}{
		{"valid", resident},
		{"corrupt", []byte("not json")},
		{"empty", nil},
	} {
		t.Run(tc.name, func(t *testing.T) {
			tmpDir := t.TempDir()
			e := &BackupEngine{walletDir: tmpDir}

			walletPath := filepath.Join(tmpDir, "wallet.json")
			require.NoError(t, os.WriteFile(walletPath, tc.current, 0600))

			require.NoError(t, e.RestoreBackup(testCtx(), backup, "wallet.json"))

			content, err := os.ReadFile(walletPath)
			require.NoError(t, err)
			require.Equal(t, backup, content)
		})
	}
}

func TestHasCurrentWallet(t *testing.T) {
	tmpDir := t.TempDir()
	e := &BackupEngine{walletDir: tmpDir}

	require.False(t, e.HasCurrentWallet())

	_ = os.WriteFile(filepath.Join(tmpDir, "wallet.json"), []byte(`{"master":"s","l1":"k"}`), 0600)
	require.True(t, e.HasCurrentWallet())
}

func TestRestoreBackup_KeepsCurrentWallet(t *testing.T) {
	db := database.Test(t)
	plainWallet := []byte(`{"master":"seed","l1":"key"}`)
	oldMetadata := []byte(`{"active_wallet_id":"old"}`)

	newEngine := func(t *testing.T) (*BackupEngine, string) {
		dir := t.TempDir()
		return &BackupEngine{db: db, walletDir: dir, multisigStore: multisig.NewStore(db)}, dir
	}

	onlySnapshot := func(t *testing.T, dir string) string {
		entries, err := os.ReadDir(filepath.Join(dir, "wallet_backups"))
		require.NoError(t, err)
		require.Len(t, entries, 1)
		require.False(t, strings.HasPrefix(entries[0].Name(), "."))
		return filepath.Join(dir, "wallet_backups", entries[0].Name())
	}

	readFile := func(t *testing.T, path string) []byte {
		data, err := os.ReadFile(path)
		require.NoError(t, err)
		return data
	}

	t.Run("plaintext json over an encrypted wallet", func(t *testing.T) {
		e, dir := newEngine(t)
		require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), testEncryptedWallet, 0600))
		require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet_encryption.json"), testEncryptionMeta, 0600))
		require.NoError(t, os.WriteFile(filepath.Join(dir, "metadata.json"), oldMetadata, 0600))

		require.NoError(t, e.RestoreBackup(t.Context(), plainWallet, "wallet.json"))

		snapshot := onlySnapshot(t, dir)
		require.Equal(t, testEncryptedWallet, readFile(t, filepath.Join(snapshot, "wallet.json")))
		require.Equal(t, testEncryptionMeta, readFile(t, filepath.Join(snapshot, "wallet_encryption.json")))
		require.Equal(t, oldMetadata, readFile(t, filepath.Join(snapshot, "metadata.json")))
		require.Equal(t, plainWallet, readFile(t, filepath.Join(dir, "wallet.json")))
	})

	t.Run("encrypted zip over a plaintext wallet", func(t *testing.T) {
		e, dir := newEngine(t)
		require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), plainWallet, 0600))

		var buf bytes.Buffer
		zw := zip.NewWriter(&buf)
		require.NoError(t, addToZip(zw, "wallet.json", testEncryptedWallet))
		require.NoError(t, addToZip(zw, "wallet_encryption.json", testEncryptionMeta))
		require.NoError(t, zw.Close())

		require.NoError(t, e.RestoreBackup(t.Context(), buf.Bytes(), "backup.zip"))

		snapshot := onlySnapshot(t, dir)
		require.Equal(t, plainWallet, readFile(t, filepath.Join(snapshot, "wallet.json")))
		require.NoFileExists(t, filepath.Join(snapshot, "wallet_encryption.json"))
		require.Equal(t, testEncryptedWallet, readFile(t, filepath.Join(dir, "wallet.json")))
	})

	t.Run("no current wallet makes no snapshot", func(t *testing.T) {
		e, dir := newEngine(t)

		require.NoError(t, e.RestoreBackup(t.Context(), plainWallet, "wallet.json"))

		require.NoDirExists(t, filepath.Join(dir, "wallet_backups"))
		require.Equal(t, plainWallet, readFile(t, filepath.Join(dir, "wallet.json")))
	})

	t.Run("failed encryption write puts the old wallet back", func(t *testing.T) {
		e, dir := newEngine(t)
		require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), plainWallet, 0600))
		require.NoError(t, os.Mkdir(filepath.Join(dir, "wallet_encryption.json.tmp"), 0o700))

		var buf bytes.Buffer
		zw := zip.NewWriter(&buf)
		require.NoError(t, addToZip(zw, "wallet.json", testEncryptedWallet))
		require.NoError(t, addToZip(zw, "wallet_encryption.json", testEncryptionMeta))
		require.NoError(t, zw.Close())

		err := e.RestoreBackup(t.Context(), buf.Bytes(), "backup.zip")
		require.ErrorContains(t, err, "write wallet_encryption.json")
		require.Equal(t, plainWallet, readFile(t, filepath.Join(dir, "wallet.json")))
	})
}
