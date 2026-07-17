package engines

import (
	"archive/zip"
	"bytes"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
	"github.com/stretchr/testify/require"
)

// A backup whose multisig data cannot be imported must leave the current
// wallet files alone, rather than replacing them and then reporting failure.
func TestRestoreBackup_FailedImport_KeepsExistingWallet(t *testing.T) {
	ctx := testCtx()
	dir := t.TempDir()
	db := database.Test(t)
	e := &BackupEngine{db: db, walletDir: dir, multisigStore: multisig.NewStore(db)}

	walletPath := filepath.Join(dir, "wallet.json")
	existing := []byte(`{"master":"my real seed","l1":"my real key"}`)
	require.NoError(t, os.WriteFile(walletPath, existing, 0600))

	// multisig.json is valid JSON, so it passes validation, but is not the
	// shape the importer expects.
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	require.NoError(t, addToZip(zw, "wallet.json", []byte(`{"master":"backup seed","l1":"backup key"}`)))
	require.NoError(t, addToZip(zw, "multisig/multisig.json", []byte(`"not an object"`)))
	require.NoError(t, zw.Close())

	err := e.RestoreBackup(ctx, buf.Bytes(), "backup.zip")
	require.Error(t, err, "a backup that cannot be imported must fail")

	after, err := os.ReadFile(walletPath)
	require.NoError(t, err)
	require.Equal(t, existing, after, "the existing wallet must be untouched when restore fails")
}
