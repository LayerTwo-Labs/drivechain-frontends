package database

import (
	"io/fs"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMigration054DropsVotesAndTheirReplies(t *testing.T) {
	ctx := t.Context()
	db := Test(t)

	_, err := db.ExecContext(ctx, `
		CREATE TABLE cn_votes (target_id BLOB NOT NULL, author_xpk BLOB NOT NULL);
		INSERT INTO cn_items (item_id, txid, vout, block_height, tx_index, vout_index, type_tag, block_time) VALUES
			(x'01', 'story', 0, 100, 0, 0, 2, '2026-10-01'),
			(x'02', 'vote', 0, 101, 0, 0, 4, '2026-10-01'),
			(x'03', 'reply-to-vote', 0, 102, 0, 0, 3, '2026-10-01'),
			(x'04', 'nested-reply', 0, 103, 0, 0, 3, '2026-10-01'),
			(x'05', 'reply-to-story', 0, 104, 0, 0, 3, '2026-10-01');
		INSERT INTO cn_comments (item_id, parent_id, author_xpk) VALUES
			(x'03', x'02', x'aa'),
			(x'04', x'03', x'aa'),
			(x'05', x'01', x'aa');
		INSERT INTO cn_continuations (head_id, seq, chunk, block_height) VALUES (x'03', 1, x'ff', 102)`)
	require.NoError(t, err)

	body, err := fs.ReadFile(migrations, "migrations/054_drop_coinnews_votes.sql")
	require.NoError(t, err)
	for range 2 {
		_, err = db.ExecContext(ctx, string(body))
		require.NoError(t, err)
	}

	ids := func(query string) []string {
		rows, err := db.QueryContext(ctx, query)
		require.NoError(t, err)
		defer rows.Close() //nolint:errcheck
		var out []string
		for rows.Next() {
			var id string
			require.NoError(t, rows.Scan(&id))
			out = append(out, id)
		}
		require.NoError(t, rows.Err())
		return out
	}
	require.Equal(t, []string{"01", "05"}, ids(`SELECT hex(item_id) FROM cn_items ORDER BY item_id`))
	require.Equal(t, []string{"05"}, ids(`SELECT hex(item_id) FROM cn_comments`))
	require.Empty(t, ids(`SELECT hex(head_id) FROM cn_continuations`))
	require.Empty(t, ids(`SELECT name FROM sqlite_master WHERE name = 'cn_votes'`))
}
