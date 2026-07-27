package sqliteguard

import (
	"context"
	"database/sql"
	"database/sql/driver"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Windows locks an open file, so the deletion this guard defends against
// cannot happen there.
func skipIfWindows(t *testing.T) {
	t.Helper()
	if runtime.GOOS == "windows" {
		t.Skip("windows locks open database files")
	}
}

func migrate(ctx context.Context, db *sql.DB) error {
	_, err := db.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY, name TEXT)`)
	return err
}

func openGuarded(t *testing.T) (*sql.DB, string) {
	t.Helper()

	path := filepath.Join(t.TempDir(), "test.db")
	db, err := Open(context.Background(), Config{Path: path, Migrate: migrate})
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	db.SetMaxOpenConns(1)
	return db, path
}

func TestExecSurvivesDeletion(t *testing.T) {
	skipIfWindows(t)
	ctx := context.Background()
	db, path := openGuarded(t)

	_, err := db.ExecContext(ctx, `INSERT INTO items (name) VALUES ('before')`)
	require.NoError(t, err)

	require.NoError(t, os.Remove(path))

	_, err = db.ExecContext(ctx, `INSERT INTO items (name) VALUES ('after')`)
	require.NoError(t, err)
	require.FileExists(t, path)
}

func TestTransactionSurvivesDeletion(t *testing.T) {
	skipIfWindows(t)
	ctx := context.Background()
	db, path := openGuarded(t)

	require.NoError(t, os.Remove(path))

	tx, err := db.BeginTx(ctx, nil)
	require.NoError(t, err, "BeginTx must land on a restored file")
	defer func() { _ = tx.Rollback() }()

	stmt, err := tx.PrepareContext(ctx, `INSERT INTO items (name) VALUES (?)`)
	require.NoError(t, err)
	defer func() { _ = stmt.Close() }()

	_, err = stmt.ExecContext(ctx, "in-tx")
	require.NoError(t, err)
	require.NoError(t, tx.Commit())
}

func TestQueryDoesNotServeGhostRows(t *testing.T) {
	skipIfWindows(t)
	ctx := context.Background()
	db, path := openGuarded(t)

	_, err := db.ExecContext(ctx, `INSERT INTO items (name) VALUES ('ghost')`)
	require.NoError(t, err)

	require.NoError(t, os.Remove(path))

	var count int
	require.NoError(t, db.QueryRowContext(ctx, `SELECT count(*) FROM items`).Scan(&count))
	assert.Equal(t, 0, count, "reads must come from the restored file, not the unlinked inode")
}

func TestPreparedStatementSurvivesDeletion(t *testing.T) {
	skipIfWindows(t)
	ctx := context.Background()
	db, path := openGuarded(t)

	stmt, err := db.PrepareContext(ctx, `INSERT INTO items (name) VALUES (?)`)
	require.NoError(t, err)
	defer func() { _ = stmt.Close() }()

	require.NoError(t, os.Remove(path))

	_, err = stmt.ExecContext(ctx, "after")
	require.NoError(t, err)
	require.FileExists(t, path)
}

func TestPingSurvivesDeletion(t *testing.T) {
	skipIfWindows(t)
	db, path := openGuarded(t)

	require.NoError(t, os.Remove(path))
	require.NoError(t, db.PingContext(context.Background()))
}

// Every entry point has to refuse on its own: a deletion landing between
// checkout and the call slips past ResetSession.
func TestEveryEntryPointRefusesStaleConnection(t *testing.T) {
	skipIfWindows(t)
	ctx := context.Background()
	path := filepath.Join(t.TempDir(), "test.db")

	db, err := Open(ctx, Config{Path: path, Migrate: migrate})
	require.NoError(t, err)
	defer func() { _ = db.Close() }()

	connector := &connector{cfg: Config{Path: path, Migrate: migrate}}
	raw, err := connector.Connect(ctx)
	require.NoError(t, err)
	guarded := raw.(*conn)
	require.True(t, guarded.IsValid())

	prepared, err := guarded.PrepareContext(ctx, `INSERT INTO items (name) VALUES (?)`)
	require.NoError(t, err)
	preparedStmt := prepared.(*stmt)

	require.NoError(t, os.Remove(path))
	require.False(t, guarded.IsValid())

	t.Run("BeginTx", func(t *testing.T) {
		_, err := guarded.BeginTx(ctx, driver.TxOptions{})
		require.ErrorIs(t, err, driver.ErrBadConn)
	})
	t.Run("Begin", func(t *testing.T) {
		_, err := guarded.Begin()
		require.ErrorIs(t, err, driver.ErrBadConn)
	})
	t.Run("ExecContext", func(t *testing.T) {
		_, err := guarded.ExecContext(ctx, `INSERT INTO items (name) VALUES ('x')`, nil)
		require.ErrorIs(t, err, driver.ErrBadConn)
	})
	t.Run("QueryContext", func(t *testing.T) {
		_, err := guarded.QueryContext(ctx, `SELECT count(*) FROM items`, nil)
		require.ErrorIs(t, err, driver.ErrBadConn)
	})
	t.Run("PrepareContext", func(t *testing.T) {
		_, err := guarded.PrepareContext(ctx, `SELECT 1`)
		require.ErrorIs(t, err, driver.ErrBadConn)
	})
	t.Run("Prepare", func(t *testing.T) {
		_, err := guarded.Prepare(`SELECT 1`)
		require.ErrorIs(t, err, driver.ErrBadConn)
	})
	t.Run("Ping", func(t *testing.T) {
		require.ErrorIs(t, guarded.Ping(ctx), driver.ErrBadConn)
	})
	t.Run("ResetSession", func(t *testing.T) {
		require.ErrorIs(t, guarded.ResetSession(ctx), driver.ErrBadConn)
	})
	t.Run("StmtExecContext", func(t *testing.T) {
		_, err := preparedStmt.ExecContext(ctx, []driver.NamedValue{{Ordinal: 1, Value: "x"}})
		require.ErrorIs(t, err, driver.ErrBadConn)
	})
	t.Run("StmtQueryContext", func(t *testing.T) {
		_, err := preparedStmt.QueryContext(ctx, []driver.NamedValue{{Ordinal: 1, Value: "x"}})
		require.ErrorIs(t, err, driver.ErrBadConn)
	})

	require.FileExists(t, path, "refusing must also restore the file for the retry")
}

func TestOpenRejectsIncompleteConfig(t *testing.T) {
	ctx := context.Background()

	_, err := Open(ctx, Config{Migrate: migrate})
	require.Error(t, err)

	_, err = Open(ctx, Config{Path: filepath.Join(t.TempDir(), "x.db")})
	require.Error(t, err)
}
