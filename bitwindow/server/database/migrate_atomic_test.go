package database

import (
	"context"
	"database/sql"
	"path/filepath"
	"testing"
	"testing/fstest"

	"github.com/LayerTwo-Labs/sidesail/sqlitemigrate"
	"github.com/stretchr/testify/require"
)

// A migration that dies part-way through must leave nothing behind, or every
// later boot retries it and fails on the half-applied schema.
func TestMigrationsAreAtomic(t *testing.T) {
	ctx := context.Background()

	db, err := sql.Open("sqlite3", filepath.Join(t.TempDir(), "atomic.db"))
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	const name = "001_topics.sql"
	const good = `CREATE TABLE topics (topic TEXT);
ALTER TABLE topics ADD COLUMN confirmed BOOLEAN NOT NULL DEFAULT FALSE;
`
	fsys := fstest.MapFS{
		"migrations/" + name: &fstest.MapFile{Data: []byte(good + "NOT VALID SQL;")},
	}

	applied, err := sqlitemigrate.Run(ctx, db, fsys, "migrations")
	require.Error(t, err)
	require.Empty(t, applied)

	var tables int
	require.NoError(t, db.QueryRowContext(ctx, `SELECT count(*) FROM sqlite_master WHERE name = 'topics'`).Scan(&tables))
	require.Zero(t, tables)

	var versions int
	require.NoError(t, db.QueryRowContext(ctx, `SELECT count(*) FROM migrations`).Scan(&versions))
	require.Zero(t, versions)

	// The corrected file applies cleanly on the retry.
	fsys["migrations/"+name] = &fstest.MapFile{Data: []byte(good)}

	applied, err = sqlitemigrate.Run(ctx, db, fsys, "migrations")
	require.NoError(t, err)
	require.Equal(t, []string{name}, applied)

	var columns int
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT count(*) FROM pragma_table_info('topics') WHERE name = 'confirmed'`).Scan(&columns))
	require.Equal(t, 1, columns)
}
