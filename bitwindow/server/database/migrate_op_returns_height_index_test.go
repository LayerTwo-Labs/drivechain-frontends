package database

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestOpReturnPurgeUsesTheHeightIndex(t *testing.T) {
	db := Test(t)

	var id, parent, unused int
	var detail string
	require.NoError(t, db.QueryRowContext(t.Context(),
		`EXPLAIN QUERY PLAN DELETE FROM op_returns WHERE height >= ?`, 100,
	).Scan(&id, &parent, &unused, &detail))
	require.Contains(t, detail, "idx_op_returns_height")
}

func TestOpReturnListUsesTheCreatedAtIndex(t *testing.T) {
	db := Test(t)

	var id, parent, unused int
	var detail string
	require.NoError(t, db.QueryRowContext(t.Context(),
		`EXPLAIN QUERY PLAN SELECT id FROM op_returns ORDER BY created_at DESC LIMIT 1000`,
	).Scan(&id, &parent, &unused, &detail))
	require.Contains(t, detail, "idx_op_returns_created_at")
}
