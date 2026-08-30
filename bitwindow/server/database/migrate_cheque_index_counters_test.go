package database

import (
	"context"
	"io/fs"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMigration048SeedsChequeIndexCounters(t *testing.T) {
	ctx := context.Background()
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
