package deniability

import (
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

func TestPendingCompletionKeepsAllOutputsTogether(t *testing.T) {
	db := database.Test(t)
	denial, err := Create(t.Context(), db, "wallet", "old", 0, time.Hour, 3, nil)
	require.NoError(t, err)
	require.NoError(t, SavePending(t.Context(), db, denial.ID, "old", 0, "new", map[string]uint64{"first": 1000, "second": 2000}))
	_, err = db.ExecContext(t.Context(), `CREATE TRIGGER reject_second_output BEFORE INSERT ON executed_denials
		WHEN NEW.to_vout = 1 BEGIN SELECT RAISE(ABORT, 'second output failed'); END`)
	require.NoError(t, err)
	err = CompletePending(t.Context(), db, denial.ID, []uint32{0, 1})
	require.ErrorContains(t, err, "second output failed")
	stored, err := Get(t.Context(), db, denial.ID)
	require.NoError(t, err)
	require.Empty(t, stored.ExecutedDenials)
	require.NotNil(t, stored.Pending)
	_, err = db.ExecContext(t.Context(), `DROP TRIGGER reject_second_output`)
	require.NoError(t, err)
	require.NoError(t, CompletePending(t.Context(), db, denial.ID, []uint32{0, 1}))
	stored, err = Get(t.Context(), db, denial.ID)
	require.NoError(t, err)
	require.Len(t, stored.ExecutedDenials, 2)
	require.Nil(t, stored.Pending)
}
