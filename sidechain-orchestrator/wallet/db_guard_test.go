package wallet

import (
	"context"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/stretchr/testify/require"
)

// The electrum db sits in the same datadir a reset wipes, so it needs the same
// recovery as bitwindowd's.
func TestElectrumDBRecoversFromDeletedFile(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("windows locks open database files")
	}
	ctx := context.Background()
	path := filepath.Join(t.TempDir(), "electrum.db")

	db, err := OpenElectrumDB(ctx, path)
	require.NoError(t, err)
	defer func() { _ = db.Close() }()

	require.NoError(t, os.Remove(path))

	tx, err := db.BeginTx(ctx, nil)
	require.NoError(t, err, "BeginTx must land on a restored file")
	require.NoError(t, tx.Rollback())

	var name string
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT name FROM sqlite_master WHERE type='table' AND name='migrations'`).Scan(&name))
	require.Equal(t, "migrations", name, "the restored file must carry the schema")
	require.FileExists(t, path)
}
