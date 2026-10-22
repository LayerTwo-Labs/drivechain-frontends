package database

import (
	"database/sql"
	"io/fs"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMigration049ReappliesEveryM4(t *testing.T) {
	ctx := t.Context()
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
	require.Zero(t, applied)
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

func TestMigration053RestartsTheBundleReplay(t *testing.T) {
	ctx := t.Context()
	db := Test(t)
	_, err := db.ExecContext(ctx, `ALTER TABLE m3_messages DROP COLUMN vote_height`)
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, `
		INSERT INTO m3_messages (block_height, block_hash, block_time, sidechain_slot, bundle_hash)
		VALUES (100, 'h100', CURRENT_TIMESTAMP, 0, 'first'),
		       (111, 'h111', CURRENT_TIMESTAMP, 0, 'second');
		INSERT INTO m4_messages (id, block_height, block_hash, block_time, raw_bytes, version, applied)
		VALUES (1, 111, 'h111', CURRENT_TIMESTAMP, x'0100', 1, 1);
		INSERT INTO m4_votes (m4_message_id, sidechain_slot, vote_type, bundle_index)
		VALUES (1, 0, 'upvote', 0);
		INSERT INTO withdrawal_bundles (sidechain_slot, bundle_hash, work_score, blocks_left, max_age,
			first_seen_height, last_updated_height, status, status_stamped)
		VALUES (0, 'bundle', 1, 0, 10, 100, 110, 'failed', 1)`)
	require.NoError(t, err)

	body, err := fs.ReadFile(migrations, "migrations/053_m4_bundle_replay.sql")
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, string(body))
	require.NoError(t, err)

	var applied, votes int
	require.NoError(t, db.QueryRowContext(ctx, `SELECT applied FROM m4_messages WHERE id = 1`).Scan(&applied))
	require.Zero(t, applied)
	require.NoError(t, db.QueryRowContext(ctx, `SELECT COUNT(*) FROM m4_votes`).Scan(&votes))
	require.Zero(t, votes)

	var score, left, height, stamped int
	var status string
	require.NoError(t, db.QueryRowContext(ctx, `
		SELECT work_score, blocks_left, last_updated_height, status_stamped, status
		FROM withdrawal_bundles`).Scan(&score, &left, &height, &stamped, &status))
	require.Equal(t, 1, score)
	require.Equal(t, 10, left)
	require.Equal(t, 99, height)
	require.Zero(t, stamped)
	require.Equal(t, "pending", status)
	var firstVote, secondVote sql.NullInt64
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT vote_height FROM m3_messages WHERE bundle_hash = 'first'`).Scan(&firstVote))
	require.Equal(t, sql.NullInt64{Int64: 100, Valid: true}, firstVote)
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT vote_height FROM m3_messages WHERE bundle_hash = 'second'`).Scan(&secondVote))
	require.False(t, secondVote.Valid)
}
