package database

import (
	"context"
	"io/fs"
	"testing"

	"github.com/stretchr/testify/require"
)

// Migration 013 recreated `denials` and reset its AUTOINCREMENT counter, so an
// execution of a dropped denial can point at a new denial that reused its id.
func TestMigration044DropsOrphanExecutedDenials(t *testing.T) {
	ctx := context.Background()
	db := Test(t)

	_, err := db.ExecContext(ctx, `INSERT INTO denials (id, wallet_id, initial_txid, initial_vout, delay_duration, num_hops, created_at)
		VALUES (1, 'w', 'new-initial-txid', 0, 3600, 1, '2026-08-18 10:00:00')`)
	require.NoError(t, err)

	// Left behind by the dropped denial: it predates the denial it points at.
	_, err = db.ExecContext(ctx, `INSERT INTO executed_denials (denial_id, from_txid, from_vout, to_txid, to_vout, created_at)
		VALUES (1, 'stale-from', 0, 'stale-to', 0, '2026-01-01 10:00:00')`)
	require.NoError(t, err)
	// A real execution of that denial.
	_, err = db.ExecContext(ctx, `INSERT INTO executed_denials (denial_id, from_txid, from_vout, to_txid, to_vout, created_at)
		VALUES (1, 'live-from', 0, 'live-to', 0, '2026-08-18 11:00:00')`)
	require.NoError(t, err)
	// An execution whose denial is gone entirely.
	_, err = db.ExecContext(ctx, `INSERT INTO executed_denials (denial_id, from_txid, from_vout, to_txid, to_vout, created_at)
		VALUES (99, 'gone-from', 0, 'gone-to', 0, '2026-08-18 11:00:00')`)
	require.NoError(t, err)

	body, err := fs.ReadFile(migrations, "migrations/044_drop_orphan_executed_denials.sql")
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, string(body))
	require.NoError(t, err)

	rows, err := db.QueryContext(ctx, `SELECT from_txid FROM executed_denials`)
	require.NoError(t, err)
	defer rows.Close()

	var kept []string
	for rows.Next() {
		var s string
		require.NoError(t, rows.Scan(&s))
		kept = append(kept, s)
	}
	require.NoError(t, rows.Err())
	require.Equal(t, []string{"live-from"}, kept)
}
