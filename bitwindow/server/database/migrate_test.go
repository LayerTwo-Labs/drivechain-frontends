package database

import (
	"context"
	"database/sql"
	"io/fs"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

// Migration 013 recreates denials, which resets its AUTOINCREMENT sequence. Any
// execution left behind is adopted by whichever new denial reuses its denial_id.
func TestMigration013ClearsExecutedDenials(t *testing.T) {
	ctx := context.Background()
	db := migrateUpTo(t, "012_remadd_to_vout.sql")

	_, err := db.ExecContext(ctx, `INSERT INTO denials (id, initial_txid, initial_vout, delay_duration, num_hops, created_at)
		VALUES (1, 'old-initial-txid', 0, 3600, 1, CURRENT_TIMESTAMP)`)
	require.NoError(t, err)

	_, err = db.ExecContext(ctx, `INSERT INTO executed_denials (denial_id, from_txid, from_vout, to_txid, to_vout, created_at)
		VALUES (1, 'old-from-txid', 0, 'old-to-txid', 0, CURRENT_TIMESTAMP)`)
	require.NoError(t, err)

	require.NoError(t, runMigrations(ctx, db))

	var orphans int
	require.NoError(t, db.QueryRowContext(ctx, `SELECT COUNT(*) FROM executed_denials
		WHERE denial_id NOT IN (SELECT id FROM denials)`).Scan(&orphans))
	require.Zero(t, orphans, "dropping denials must not leave executions behind")
}

// migrateUpTo applies every migration up to and including latest, and records it
// so runMigrations continues from there.
func migrateUpTo(t *testing.T, latest string) *sql.DB {
	db, err := sql.Open("sqlite3", filepath.Join(t.TempDir(), "bitwindow.db"))
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	entries, err := fs.ReadDir(migrations, "migrations")
	require.NoError(t, err)

	for _, entry := range entries {
		if !strings.HasSuffix(entry.Name(), ".sql") || entry.Name() > latest {
			continue
		}
		body, err := fs.ReadFile(migrations, "migrations/"+entry.Name())
		require.NoError(t, err)
		_, err = db.Exec(string(body))
		require.NoError(t, err, "apply migration %s", entry.Name())
	}

	_, err = db.Exec(`CREATE TABLE migrations (
		id INTEGER PRIMARY KEY CHECK (id = 1),
		latest_version TEXT NOT NULL
	)`)
	require.NoError(t, err)
	_, err = db.Exec(`INSERT INTO migrations (id, latest_version) VALUES (1, ?)`, latest)
	require.NoError(t, err)

	return db
}
