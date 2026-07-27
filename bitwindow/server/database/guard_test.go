package database

import (
	"context"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/stretchr/testify/require"
)

// A reset wiping the datadir out from under a live bitwindowd is what put the
// backend into a permanent "attempt to write a readonly database" loop.
func TestRecoversFromDeletedDatabaseFile(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("windows locks open database files")
	}
	dir := t.TempDir()
	ctx := context.Background()

	db, err := New(ctx, config.Config{Datadir: dir})
	require.NoError(t, err)
	defer func() { _ = db.Close() }()

	_, err = db.ExecContext(ctx, `INSERT INTO processed_blocks (height, block_hash, txids, block_time)
		VALUES (1, 'hash-1', '[]', 0)`)
	require.NoError(t, err)

	require.NoError(t, os.Remove(filepath.Join(dir, "bitwindow.db")))

	_, err = db.ExecContext(ctx, `INSERT INTO processed_blocks (height, block_hash, txids, block_time)
		VALUES (2, 'hash-2', '[]', 0)`)
	require.NoError(t, err, "write must succeed after the database file is deleted")

	require.FileExists(t, filepath.Join(dir, "bitwindow.db"))

	var height int
	require.NoError(t, db.QueryRowContext(ctx, `SELECT height FROM processed_blocks`).Scan(&height))
	require.Equal(t, 2, height)
}

// MarkBlocksProcessed — the write that was failing every 2s — runs inside a
// transaction, which database/sql never retries.
func TestRecoversTransactionAfterDeletedDatabaseFile(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("windows locks open database files")
	}
	dir := t.TempDir()
	ctx := context.Background()

	db, err := New(ctx, config.Config{Datadir: dir})
	require.NoError(t, err)
	defer func() { _ = db.Close() }()

	require.NoError(t, os.Remove(filepath.Join(dir, "bitwindow.db")))

	tx, err := db.BeginTx(ctx, nil)
	require.NoError(t, err)
	defer func() { _ = tx.Rollback() }()

	stmt, err := tx.PrepareContext(ctx, `INSERT INTO processed_blocks (height, block_hash, txids, block_time) VALUES (?, ?, '[]', 0)`)
	require.NoError(t, err)
	defer func() { _ = stmt.Close() }()

	_, err = stmt.ExecContext(ctx, 1, "hash-1")
	require.NoError(t, err)
	require.NoError(t, tx.Commit(), "a transaction must survive the database file being deleted")

	require.FileExists(t, filepath.Join(dir, "bitwindow.db"))
}
