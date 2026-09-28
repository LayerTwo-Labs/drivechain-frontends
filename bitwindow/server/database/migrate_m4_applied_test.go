package database

import (
	"context"
	"io/fs"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMigration049ReappliesEveryM4(t *testing.T) {
	ctx := context.Background()
	db := Test(t)

	_, err := db.ExecContext(ctx, `ALTER TABLE m4_messages DROP COLUMN applied`)
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, `
		INSERT INTO m4_messages (id, block_height, block_hash, block_time, raw_bytes, version)
		VALUES (1, 101, 'h101', CURRENT_TIMESTAMP, x'01ff00', 1);
		INSERT INTO m4_votes (m4_message_id, sidechain_slot, vote_type, bundle_index) VALUES (1, 1, 'upvote', 0);
		INSERT INTO withdrawal_bundles (sidechain_slot, bundle_hash, work_score, blocks_left,
			first_seen_height, last_updated_height, status, status_stamped)
		VALUES (1, 'wrong-slot', 5, 0, 100, 26400, 'failed', 1)`)
	require.NoError(t, err)

	body, err := fs.ReadFile(migrations, "migrations/049_m4_applied.sql")
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, string(body))
	require.NoError(t, err)

	var applied, votes int
	require.NoError(t, db.QueryRowContext(ctx, `SELECT applied FROM m4_messages WHERE id = 1`).Scan(&applied))
	require.Zero(t, applied, "every stored M4 MUST apply again")
	require.NoError(t, db.QueryRowContext(ctx, `SELECT COUNT(*) FROM m4_votes`).Scan(&votes))
	require.Zero(t, votes)

	var workScore, blocksLeft, lastUpdated int
	var status string
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT work_score, blocks_left, last_updated_height, status FROM withdrawal_bundles`,
	).Scan(&workScore, &blocksLeft, &lastUpdated, &status))
	require.Equal(t, 1, workScore)
	require.Equal(t, 26300, blocksLeft)
	require.Equal(t, 100, lastUpdated)
	require.Equal(t, "pending", status)
}
