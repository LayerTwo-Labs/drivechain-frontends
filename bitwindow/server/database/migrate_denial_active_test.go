package database

import (
	"database/sql"
	"io/fs"
	"path/filepath"
	"testing"
	"testing/fstest"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/sqlitemigrate"
)

func TestUpgradeAcceptsOldDenials(t *testing.T) {
	for _, count := range []int{1, 2} {
		name := "one plan"
		if count == 2 {
			name = "two active plans for one coin"
		}
		t.Run(name, func(t *testing.T) {
			dir := t.TempDir()
			db, err := sql.Open("sqlite3", filepath.Join(dir, "bitwindow.db"))
			require.NoError(t, err)
			t.Cleanup(func() { require.NoError(t, db.Close()) })

			old := fstest.MapFS{}
			entries, err := fs.ReadDir(migrations, "migrations")
			require.NoError(t, err)
			for _, entry := range entries {
				if entry.Name() >= "040" {
					continue
				}
				path := "migrations/" + entry.Name()
				body, err := fs.ReadFile(migrations, path)
				require.NoError(t, err)
				old[path] = &fstest.MapFile{Data: body, Mode: 0o600}
			}
			_, err = sqlitemigrate.Run(t.Context(), db, old, "migrations")
			require.NoError(t, err)

			for range count {
				_, err = db.ExecContext(t.Context(), `
					INSERT INTO denials
					(wallet_id, initial_txid, initial_vout, delay_duration, num_hops, created_at)
					VALUES ('wallet-a', 'receipt', 0, 3600000000000, 2, '2026-01-01 00:00:00')`)
				require.NoError(t, err)
			}
			require.NoError(t, db.Close())

			restored, err := New(t.Context(), config.Config{Datadir: dir})
			if restored != nil {
				t.Cleanup(func() { require.NoError(t, restored.Close()) })
			}
			require.NoError(t, err, "the old schema accepts these active plans")
			var stored int
			require.NoError(t, restored.QueryRowContext(t.Context(), `SELECT COUNT(*) FROM denials WHERE cancelled_at IS NULL`).Scan(&stored))
			require.Equal(t, count, stored)

			require.NoError(t, restored.Close())
			restored, err = New(t.Context(), config.Config{Datadir: dir})
			require.NoError(t, err, "a second start keeps the old plans")
			var again int
			require.NoError(t, restored.QueryRowContext(t.Context(), `SELECT COUNT(*) FROM denials WHERE cancelled_at IS NULL AND initial_txid = 'receipt'`).Scan(&again))
			require.Equal(t, count, again)
			_, err = restored.ExecContext(t.Context(), `INSERT INTO denials
				(wallet_id, initial_txid, initial_vout, delay_duration, num_hops, created_at)
				VALUES ('wallet-a', 'receipt', 0, 3600000000000, 2, CURRENT_TIMESTAMP)`)
			require.ErrorContains(t, err, "an active denial already uses this outpoint")
			_, err = restored.ExecContext(t.Context(), `UPDATE denials SET cancelled_at = datetime('now', '+' || id || ' seconds'), cancelled_reason = 'test'`)
			require.NoError(t, err)
			_, err = restored.ExecContext(t.Context(), `INSERT INTO denials
				(wallet_id, initial_txid, initial_vout, delay_duration, num_hops, created_at)
				VALUES ('wallet-a', 'receipt', 0, 3600000000000, 2, CURRENT_TIMESTAMP)`)
			require.NoError(t, err)

		})
	}
}

func TestUpgradeReplacesTheUniqueDenialIndex(t *testing.T) {
	dir := t.TempDir()
	db, err := sql.Open("sqlite3", filepath.Join(dir, "bitwindow.db"))
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, db.Close()) })

	old := fstest.MapFS{}
	entries, err := fs.ReadDir(migrations, "migrations")
	require.NoError(t, err)
	for _, entry := range entries {
		if entry.Name() >= "056" {
			continue
		}
		path := "migrations/" + entry.Name()
		body, err := fs.ReadFile(migrations, path)
		require.NoError(t, err)
		old[path] = &fstest.MapFile{Data: body, Mode: 0o600}
	}
	_, err = sqlitemigrate.Run(t.Context(), db, old, "migrations")
	require.NoError(t, err)
	_, err = db.ExecContext(t.Context(), `
		DROP INDEX denials_active_outpoints;
		CREATE UNIQUE INDEX denials_active_unique ON denials (initial_txid, initial_vout) WHERE cancelled_at IS NULL;
		INSERT INTO denials (wallet_id, initial_txid, initial_vout, delay_duration, num_hops, created_at)
		VALUES ('wallet-a', 'receipt', 0, 3600000000000, 2, '2026-01-01 00:00:00')`)
	require.NoError(t, err)
	require.NoError(t, db.Close())

	for range 2 {
		restored, err := New(t.Context(), config.Config{Datadir: dir})
		require.NoError(t, err)
		var wallet string
		require.NoError(t, restored.QueryRowContext(t.Context(), `SELECT wallet_id FROM denials WHERE initial_txid = 'receipt' AND cancelled_at IS NULL`).Scan(&wallet))
		require.Equal(t, "wallet-a", wallet)
		var unique int
		require.NoError(t, restored.QueryRowContext(t.Context(), `SELECT COUNT(*) FROM sqlite_master WHERE name = 'denials_active_unique'`).Scan(&unique))
		require.Zero(t, unique)
		require.NoError(t, restored.Close())
	}
}
