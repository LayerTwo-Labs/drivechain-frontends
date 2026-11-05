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

func TestMigration048SeedsChequeIndexCounters(t *testing.T) {
	ctx := t.Context()
	db := Test(t)

	_, err := db.ExecContext(ctx, `DROP TABLE cheque_index_counters`)
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, `INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address) VALUES
		('w1', 0, 1000, 'a0'), ('w1', 3, 1000, 'a3'), ('w2', 0, 1000, 'b0')`)
	require.NoError(t, err)

	body, err := fs.ReadFile(migrations, "migrations/048_cheque_index_counters.sql")
	require.NoError(t, err)
	for range 2 {
		_, err = db.ExecContext(ctx, string(body))
		require.NoError(t, err)
	}

	next := func(walletID string) int {
		var n int
		require.NoError(t, db.QueryRowContext(ctx, `SELECT next_index FROM cheque_index_counters WHERE wallet_id = ?`, walletID).Scan(&n))
		return n
	}
	require.Equal(t, 4, next("w1"))
	require.Equal(t, 1, next("w2"))
}

func TestChequeUpgradeKeepsIssuedKeys(t *testing.T) {
	ctx := t.Context()
	dir := t.TempDir()
	db, err := sql.Open("sqlite3", filepath.Join(dir, "bitwindow.db"))
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, db.Close()) })

	old := fstest.MapFS{}
	entries, err := fs.ReadDir(migrations, "migrations")
	require.NoError(t, err)
	for _, entry := range entries {
		if entry.Name() >= "041" {
			continue
		}
		path := "migrations/" + entry.Name()
		body, err := fs.ReadFile(migrations, path)
		require.NoError(t, err)
		old[path] = &fstest.MapFile{Data: body, Mode: 0o600}
	}
	_, err = sqlitemigrate.Run(ctx, db, old, "migrations")
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, `
		INSERT INTO cheques (
			wallet_id, derivation_index, expected_amount_sats, address, funded_txid,
			actual_amount_sats, funded_at, swept_txid, swept_at
		) VALUES
			('w1', 0, 1000, 'a0', 'receipt-a', 1000, '2026-01-01 00:00:00', 'spent', '2026-01-02 00:00:00'),
			('w2', 25, 2000, 'b25', 'receipt-b', 2000, '2026-01-01 00:00:00', NULL, NULL)`)
	require.NoError(t, err)
	require.NoError(t, db.Close())

	for range 2 {
		current, err := New(ctx, config.Config{Datadir: dir})
		require.NoError(t, err)
		for walletID, want := range map[string]int{"w1": 1, "w2": 26} {
			var next int
			require.NoError(t, current.QueryRowContext(ctx,
				`SELECT next_index FROM cheque_index_counters WHERE wallet_id = ?`, walletID).Scan(&next))
			require.Equal(t, want, next)
		}
		var receipt, spent string
		var amount int
		require.NoError(t, current.QueryRowContext(ctx,
			`SELECT funded_txid, swept_txid, actual_amount_sats FROM cheques WHERE address = 'a0'`,
		).Scan(&receipt, &spent, &amount))
		require.Equal(t, "receipt-a", receipt)
		require.Equal(t, "spent", spent)
		require.Equal(t, 1000, amount)
		var count int
		require.NoError(t, current.QueryRowContext(ctx, `SELECT COUNT(*) FROM cheques`).Scan(&count))
		require.Equal(t, 2, count)
		require.NoError(t, current.Close())
	}
}
