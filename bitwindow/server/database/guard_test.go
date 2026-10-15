package database

import (
	"bytes"
	"context"
	"database/sql"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
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

func TestSafeDefer(t *testing.T) {
	cases := []struct {
		name    string
		err     error
		wantLog bool
	}{
		{name: "no error", err: nil, wantLog: false},
		{name: "transaction done", err: fmt.Errorf("rollback: %w", sql.ErrTxDone), wantLog: false},
		{name: "close error", err: errors.New("disk I/O error"), wantLog: true},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var buf bytes.Buffer
			ctx := zerolog.New(&buf).WithContext(t.Context())

			SafeDefer(ctx, func() error { return tc.err })

			if tc.wantLog {
				require.Contains(t, buf.String(), "disk I/O error")
			} else {
				require.Empty(t, buf.String())
			}
		})
	}
}

type hexID string

func (h *hexID) Scan(src any) error {
	s, ok := src.(string)
	if !ok {
		return fmt.Errorf("hexID: unexpected %T", src)
	}
	*h = hexID("0x" + s)
	return nil
}

type getRow struct {
	ID    int64          `db:"id"`
	Name  string         `db:"name"`
	Note  sql.NullString `db:"note"`
	Hex   hexID          `db:"hex"`
	Extra bool           `db:"extra"`
}

func helperDB(t *testing.T) *sql.DB {
	t.Helper()
	db, err := New(t.Context(), config.Config{Datadir: t.TempDir()})
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, db.Close()) })

	_, err = db.ExecContext(t.Context(), `CREATE TABLE helper_rows (id INTEGER PRIMARY KEY, name TEXT NOT NULL)`)
	require.NoError(t, err)
	_, err = db.ExecContext(t.Context(), `INSERT INTO helper_rows (id, name) VALUES (1, 'a'), (2, 'b'), (3, 'b')`)
	require.NoError(t, err)
	return db
}

func TestGet(t *testing.T) {
	db := helperDB(t)

	t.Run("scalar", func(t *testing.T) {
		name, err := Get[string](t.Context(), db, `SELECT name FROM helper_rows WHERE id = ?`, 2)
		require.NoError(t, err)
		require.Equal(t, "b", name)

		n, err := Get[int64](t.Context(), db, `SELECT COUNT(*) FROM helper_rows`)
		require.NoError(t, err)
		require.EqualValues(t, 3, n)

		ok, err := Get[bool](t.Context(), db, `SELECT 1`)
		require.NoError(t, err)
		require.True(t, ok)

		raw, err := Get[[]byte](t.Context(), db, `SELECT X'ABCD'`)
		require.NoError(t, err)
		require.Equal(t, []byte{0xab, 0xcd}, raw)
	})

	t.Run("scalar scanner", func(t *testing.T) {
		got, err := Get[sql.NullString](t.Context(), db, `SELECT NULL`)
		require.NoError(t, err)
		require.False(t, got.Valid)
	})

	t.Run("struct", func(t *testing.T) {
		got, err := Get[getRow](t.Context(), db,
			`SELECT id, name, NULL AS note, 'ff' AS hex FROM helper_rows WHERE id = ?`, 1)
		require.NoError(t, err)
		require.Equal(t, getRow{ID: 1, Name: "a", Hex: "0xff"}, got)
	})

	t.Run("struct in transaction", func(t *testing.T) {
		tx, err := db.BeginTx(t.Context(), nil)
		require.NoError(t, err)
		defer func() { require.NoError(t, tx.Rollback()) }()

		got, err := Get[getRow](t.Context(), tx, `SELECT id, name FROM helper_rows WHERE id = 3`)
		require.NoError(t, err)
		require.Equal(t, getRow{ID: 3, Name: "b"}, got)
	})

	t.Run("missing column", func(t *testing.T) {
		_, err := Get[getRow](t.Context(), db, `SELECT id, name, 1 AS unknown FROM helper_rows WHERE id = 1`)
		require.ErrorContains(t, err, `column "unknown" has no field`)
	})

	t.Run("two columns into scalar", func(t *testing.T) {
		_, err := Get[string](t.Context(), db, `SELECT id, name FROM helper_rows WHERE id = 1`)
		require.ErrorContains(t, err, "scan 2 columns into scalar")
	})

	t.Run("zero rows", func(t *testing.T) {
		_, err := Get[getRow](t.Context(), db, `SELECT id, name FROM helper_rows WHERE id = 99`)
		require.ErrorIs(t, err, sql.ErrNoRows)
	})

	t.Run("two rows", func(t *testing.T) {
		_, err := Get[string](t.Context(), db, `SELECT name FROM helper_rows WHERE name = 'b'`)
		require.ErrorContains(t, err, "more than one row")
	})
}

func TestSelect(t *testing.T) {
	db := helperDB(t)

	t.Run("scalar", func(t *testing.T) {
		got, err := Select[int64](t.Context(), db, `SELECT id FROM helper_rows ORDER BY id`)
		require.NoError(t, err)
		require.Equal(t, []int64{1, 2, 3}, got)
	})

	t.Run("struct", func(t *testing.T) {
		got, err := Select[getRow](t.Context(), db, `SELECT id, name FROM helper_rows WHERE name = 'b' ORDER BY id`)
		require.NoError(t, err)
		require.Equal(t, []getRow{{ID: 2, Name: "b"}, {ID: 3, Name: "b"}}, got)
	})

	t.Run("zero rows", func(t *testing.T) {
		got, err := Select[getRow](t.Context(), db, `SELECT id, name FROM helper_rows WHERE id = 99`)
		require.NoError(t, err)
		require.Empty(t, got)
	})

	t.Run("missing column", func(t *testing.T) {
		_, err := Select[getRow](t.Context(), db, `SELECT id, 1 AS unknown FROM helper_rows`)
		require.ErrorContains(t, err, `column "unknown" has no field`)
	})
}

func TestCheckOne(t *testing.T) {
	db := helperDB(t)

	t.Run("zero rows", func(t *testing.T) {
		err := CheckOne(db.ExecContext(t.Context(), `UPDATE helper_rows SET name = 'c' WHERE id = 99`))
		require.ErrorIs(t, err, sql.ErrNoRows)
	})

	t.Run("one row", func(t *testing.T) {
		require.NoError(t, CheckOne(db.ExecContext(t.Context(), `UPDATE helper_rows SET name = 'c' WHERE id = 1`)))
	})

	t.Run("two rows", func(t *testing.T) {
		err := CheckOne(db.ExecContext(t.Context(), `UPDATE helper_rows SET name = 'd' WHERE name = 'b'`))
		require.ErrorContains(t, err, "affected 2 rows, want 1")
		require.NotErrorIs(t, err, sql.ErrNoRows)
	})

	t.Run("exec error", func(t *testing.T) {
		err := CheckOne(db.ExecContext(t.Context(), `UPDATE no_such_table SET x = 1`))
		require.ErrorContains(t, err, "no such table")
	})
}
