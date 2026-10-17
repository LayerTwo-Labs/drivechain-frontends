package deniability

import (
	"testing"
	"time"

	"github.com/brianvoe/gofakeit/v7"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

func TestDeniability(t *testing.T) {

	ctx := t.Context()

	t.Run("create denial", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		txid := gofakeit.UUID()
		vout := gofakeit.Int32()
		delayDuration := time.Duration(gofakeit.IntRange(1, 24)) * time.Hour
		numHops := gofakeit.Int32()

		denial, err := Create(ctx, db, "test-wallet", txid, vout, delayDuration, numHops, nil)
		require.NoError(t, err)
		require.NotNil(t, denial)

		require.Equal(t, txid, denial.TipTXID)
		require.Equal(t, vout, denial.TipVout)
		require.Equal(t, delayDuration, denial.DelayDuration)
		require.Equal(t, numHops, denial.NumHops)
	})

	t.Run("Get missing id", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		_, err := Get(t.Context(), db, 42)
		require.ErrorIs(t, err, ErrNotFound)
	})

	t.Run("GetByTip with a cancelled denial on the same tip", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		cancelled, err := Create(t.Context(), db, "test-wallet", "txid", 0, time.Hour, 2, nil)
		require.NoError(t, err)
		require.NoError(t, Cancel(t.Context(), db, cancelled.ID, "test"))
		_, err = Create(t.Context(), db, "test-wallet", "txid", 0, time.Hour, 2, nil)
		require.NoError(t, err)

		got, err := GetByTip(t.Context(), db, "txid", lo.ToPtr(int32(0)))
		require.NoError(t, err)
		assert.NotNil(t, got)
	})

	t.Run("RecordExecution", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		// First create a denial
		denial, err := Create(ctx, db, "test-wallet", "initial-txid", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)
		require.NotNil(t, denial)

		// Record an execution
		err = RecordExecution(ctx, db, denial.ID, "from-txid", 0, "to-txid", 0)
		require.NoError(t, err)

		// Verify the execution was recorded
		var count int
		err = db.QueryRow("SELECT COUNT(*) FROM executed_denials").Scan(&count)
		require.NoError(t, err)
		require.Equal(t, 1, count)

		// Verify the execution details
		var execution ExecutedDenial
		err = db.QueryRow(`
			SELECT id, denial_id, from_txid, from_vout, to_txid, created_at
			FROM executed_denials
		`).Scan(
			&execution.ID,
			&execution.DenialID,
			&execution.FromTxID,
			&execution.FromVout,
			&execution.ToTxID,
			&execution.CreatedAt,
		)
		require.NoError(t, err)
		require.Equal(t, denial.ID, execution.DenialID)
		require.Equal(t, "from-txid", execution.FromTxID)
		require.Equal(t, int32(0), execution.FromVout)
		require.Equal(t, "to-txid", execution.ToTxID)
	})

	t.Run("List", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		// Create multiple denials
		denial1, err := Create(ctx, db, "test-wallet", "txid1", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)
		require.NotNil(t, denial1)
		denial2, err := Create(ctx, db, "test-wallet", "txid2", 1, 2*time.Hour, 4, nil)
		require.NoError(t, err)
		require.NotNil(t, denial2)

		// List all denials
		denials, err := List(ctx, db)
		require.NoError(t, err)
		require.Len(t, denials, 2)

		// Verify the first denial
		require.Equal(t, "txid1", denials[0].TipTXID)
		require.Equal(t, int32(0), denials[0].TipVout)
		require.Equal(t, 1*time.Hour, denials[0].DelayDuration)
		require.Equal(t, int32(3), denials[0].NumHops)

		// Verify the second denial
		require.Equal(t, "txid2", denials[1].TipTXID)
		require.Equal(t, int32(1), denials[1].TipVout)
		require.Equal(t, 2*time.Hour, denials[1].DelayDuration)
		require.Equal(t, int32(4), denials[1].NumHops)
	})

	t.Run("List excludes cancelled and reads target sizes", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		kept, err := Create(t.Context(), db, "test-wallet", "txid1", 0, time.Hour, 2, []int64{1000, 2000})
		require.NoError(t, err)
		cancelled, err := Create(t.Context(), db, "test-wallet", "txid2", 0, time.Hour, 2, nil)
		require.NoError(t, err)
		require.NoError(t, Cancel(t.Context(), db, cancelled.ID, "test"))

		all, err := List(t.Context(), db)
		require.NoError(t, err)
		require.Len(t, all, 2)

		active, err := List(t.Context(), db, WithExcludeCancelled())
		require.NoError(t, err)
		require.Len(t, active, 1)
		require.Equal(t, kept.ID, active[0].ID)
		require.Equal(t, TargetSizes{1000, 2000}, active[0].TargetUTXOSizes)
	})

	t.Run("Cancel", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		// Create a denial
		denial, err := Create(ctx, db, "test-wallet", "txid", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)
		require.NotNil(t, denial)

		// Get the denial ID
		var denialID int64
		err = db.QueryRow("SELECT id FROM denials").Scan(&denialID)
		require.NoError(t, err)

		// Cancel the denial
		reason := "test cancellation"
		err = Cancel(ctx, db, denialID, reason)
		require.NoError(t, err)

		// Verify the cancellation
		var delaySeconds float64
		err = db.QueryRow(`
			SELECT id, delay_duration, num_hops, created_at, cancelled_at, cancelled_reason
			FROM denials
		`).Scan(
			&denial.ID,
			&delaySeconds,
			&denial.NumHops,
			&denial.CreatedAt,
			&denial.CancelledAt,
			&denial.CancelReason,
		)
		require.NoError(t, err)
		require.NotNil(t, denial.CancelledAt)
		require.Equal(t, reason, *denial.CancelReason)
	})

	t.Run("Cancel, Pause, Resume and Update of an unknown ID return ErrNotFound", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		require.ErrorIs(t, Cancel(t.Context(), db, 999, "reason"), ErrNotFound)
		require.ErrorIs(t, Pause(t.Context(), db, 999), ErrNotFound)
		require.ErrorIs(t, Resume(t.Context(), db, 999), ErrNotFound)
		require.ErrorIs(t, Update(t.Context(), db, 999, time.Second, 1, nil, "txid", 0), ErrNotFound)
	})

	t.Run("Pause of a paused denial and Resume of an active denial return ErrNotFound", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		denial, err := Create(t.Context(), db, "test-wallet", "txid", 0, time.Hour, 3, nil)
		require.NoError(t, err)

		require.ErrorIs(t, Resume(t.Context(), db, denial.ID), ErrNotFound)
		require.NoError(t, Pause(t.Context(), db, denial.ID))
		require.ErrorIs(t, Pause(t.Context(), db, denial.ID), ErrNotFound)
		require.NoError(t, Resume(t.Context(), db, denial.ID))
	})

	t.Run("NextExecution", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		// Create a denial
		delayDuration := time.Duration(gofakeit.IntRange(1, 24)) * time.Hour
		denial, err := Create(ctx, db, "test-wallet", "txid", 0, delayDuration, 3, nil)
		require.NoError(t, err)
		require.NotNil(t, denial)

		// Test next execution before any executions
		require.Equal(t, denial.CreatedAt.Add(delayDuration), *denial.NextExecution)

		// Record an execution
		err = RecordExecution(ctx, db, denial.ID, "from-txid", 0, "to-txid", uint32(0))
		require.NoError(t, err)

		denial, err = Get(ctx, db, denial.ID)
		require.NoError(t, err)
		require.NotNil(t, denial)
		// Test next execution after one execution
		require.True(t, denial.NextExecution.After(time.Now()))
	})

	t.Run("GetByTip", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		// Create a denial
		_, err := Create(ctx, db, "test-wallet", "txid", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)

		// Get the denial by tip
		denial, err := GetByTip(ctx, db, "txid", ptr(int32(0)))
		require.NoError(t, err)
		require.NotNil(t, denial)
		require.Equal(t, "txid", denial.TipTXID)
		require.Equal(t, int32(0), denial.TipVout)
		require.Equal(t, 1*time.Hour, denial.DelayDuration)
		require.Equal(t, int32(3), denial.NumHops)

		// Test non-existent tip
		denial, err = GetByTip(ctx, db, "non-existent", ptr(int32(0)))
		require.NoError(t, err)
		require.Nil(t, denial)
	})

	t.Run("GetByTip does not match the pre-hop vout", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		denial, err := Create(ctx, db, "test-wallet", "initial-txid", 7, 1*time.Hour, 3, nil)
		require.NoError(t, err)

		// After a hop the tip is (hop-txid, 3), not (hop-txid, 7).
		require.NoError(t, RecordExecution(ctx, db, denial.ID, "initial-txid", 7, "hop-txid", 3))

		found, err := GetByTip(ctx, db, "hop-txid", ptr(int32(3)))
		require.NoError(t, err)
		require.NotNil(t, found)
		require.Equal(t, denial.ID, found.ID)
		require.Equal(t, "hop-txid", found.TipTXID)
		require.Equal(t, int32(3), found.TipVout)

		// The stale initial vout must not satisfy the lookup.
		found, err = GetByTip(ctx, db, "hop-txid", ptr(int32(7)))
		require.NoError(t, err)
		require.Nil(t, found)
	})

	t.Run("Update", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		// Create a denial
		denial, err := Create(ctx, db, "test-wallet", "txid", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)
		require.NotNil(t, denial)

		// Update the denial
		err = Update(ctx, db, denial.ID, 2*time.Second, 1, TargetSizes{500}, "txid", 0)
		require.NoError(t, err)

		// Verify the update
		denial, err = Get(ctx, db, denial.ID)
		require.NoError(t, err)
		require.Equal(t, 2*time.Second, denial.DelayDuration)
		require.Equal(t, int32(4), denial.NumHops) // 3 + 1
		require.Equal(t, TargetSizes{500}, denial.TargetUTXOSizes)
	})

	t.Run("Get", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		// Create a denial
		denialReturn, err := Create(ctx, db, "test-wallet", "txid", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)

		// Get the denial by ID
		denial, err := Get(ctx, db, denialReturn.ID)
		require.NoError(t, err)
		require.NotNil(t, denial)
		require.Equal(t, "txid", denial.TipTXID)
		require.Equal(t, int32(0), denial.TipVout)
		require.Equal(t, 1*time.Hour, denial.DelayDuration)
		require.Equal(t, int32(3), denial.NumHops)

		assert.Equal(t, denialReturn.ID, denial.ID)
		assert.Equal(t, denialReturn.TipTXID, denial.TipTXID)
		assert.Equal(t, denialReturn.TipVout, denial.TipVout)
		assert.Equal(t, denialReturn.DelayDuration, denial.DelayDuration)
		assert.Equal(t, denialReturn.NumHops, denial.NumHops)
	})
}

// Helper function to create a pointer to an int32
func ptr(i int32) *int32 {
	return &i
}
