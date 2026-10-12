package sqlitemigrate_test

import (
	"database/sql"
	"path/filepath"
	"testing"
	"testing/fstest"

	"github.com/LayerTwo-Labs/sidesail/sqlitemigrate"
	_ "github.com/mattn/go-sqlite3"
	"github.com/stretchr/testify/require"
)

func openDB(t *testing.T) *sql.DB {
	t.Helper()
	db, err := sql.Open("sqlite3", filepath.Join(t.TempDir(), "test.db"))
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, db.Close()) })
	return db
}

func file(body string) *fstest.MapFile {
	return &fstest.MapFile{Data: []byte(body)}
}

func latestVersion(t *testing.T, db *sql.DB) string {
	t.Helper()
	var latest string
	require.NoError(t, db.QueryRowContext(t.Context(), `SELECT latest_version FROM migrations`).Scan(&latest))
	return latest
}

func tableExists(t *testing.T, db *sql.DB, name string) bool {
	t.Helper()
	var n int
	require.NoError(t, db.QueryRowContext(t.Context(),
		`SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = ?`, name).Scan(&n))
	return n == 1
}

func TestRun(t *testing.T) {
	fsys := fstest.MapFS{
		"m/0002_b.sql":   file(`CREATE TABLE b (id INTEGER); INSERT INTO b VALUES (2);`),
		"m/0001_a.sql":   file(`CREATE TABLE a (id INTEGER);`),
		"m/0003_c.sql":   file(`CREATE TABLE c (id INTEGER);`),
		"m/README.md":    file(`not sql`),
		"other/0009.sql": file(`CREATE TABLE z (id INTEGER);`),
	}

	tests := []struct {
		name        string
		preLatest   string
		wantApplied []string
		wantTables  []string
		noTables    []string
	}{
		{
			name:        "fresh db applies all files in order",
			wantApplied: []string{"0001_a.sql", "0002_b.sql", "0003_c.sql"},
			wantTables:  []string{"a", "b", "c"},
			noTables:    []string{"z"},
		},
		{
			name:        "old db runs only newer files",
			preLatest:   "0002_b.sql",
			wantApplied: []string{"0003_c.sql"},
			wantTables:  []string{"c"},
			noTables:    []string{"a", "b"},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			db := openDB(t)
			if tt.preLatest != "" {
				_, err := db.ExecContext(t.Context(), `CREATE TABLE migrations (
					id INTEGER PRIMARY KEY CHECK (id = 1),
					latest_version TEXT NOT NULL
				)`)
				require.NoError(t, err)
				_, err = db.ExecContext(t.Context(), `INSERT INTO migrations (id, latest_version) VALUES (1, ?)`, tt.preLatest)
				require.NoError(t, err)
			}

			applied, err := sqlitemigrate.Run(t.Context(), db, fsys, "m")
			require.NoError(t, err)
			require.Equal(t, tt.wantApplied, applied)
			require.Equal(t, "0003_c.sql", latestVersion(t, db))
			for _, name := range tt.wantTables {
				require.True(t, tableExists(t, db, name), name)
			}
			for _, name := range tt.noTables {
				require.False(t, tableExists(t, db, name), name)
			}

			again, err := sqlitemigrate.Run(t.Context(), db, fsys, "m")
			require.NoError(t, err)
			require.Empty(t, again)
		})
	}

	t.Run("failed file leaves no partial schema", func(t *testing.T) {
		db := openDB(t)
		broken := fstest.MapFS{
			"m/0001_a.sql": file(`CREATE TABLE a (id INTEGER);`),
			"m/0002_b.sql": file(`CREATE TABLE b (id INTEGER); CREATE TABLE a (id INTEGER);`),
		}

		applied, err := sqlitemigrate.Run(t.Context(), db, broken, "m")
		require.ErrorContains(t, err, "apply migration 0002_b.sql")
		require.Equal(t, []string{"0001_a.sql"}, applied)
		require.False(t, tableExists(t, db, "b"))
		require.Equal(t, "0001_a.sql", latestVersion(t, db))

		broken["m/0002_b.sql"] = file(`CREATE TABLE b (id INTEGER); CREATE TABLE b2 (id INTEGER);`)
		applied, err = sqlitemigrate.Run(t.Context(), db, broken, "m")
		require.NoError(t, err)
		require.Equal(t, []string{"0002_b.sql"}, applied)
		require.True(t, tableExists(t, db, "b"))
		require.True(t, tableExists(t, db, "b2"))
		require.Equal(t, "0002_b.sql", latestVersion(t, db))
	})
}
