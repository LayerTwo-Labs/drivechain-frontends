package mempooltx

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/stretchr/testify/require"
)

func pending(txid string, feeRate float64, height uint32) Tx {
	return Tx{
		Txid:            txid,
		FeeSats:         uint64(feeRate * 100),
		Vsize:           100,
		FeeRate:         feeRate,
		FirstSeenAt:     time.Unix(1_700_000_000, 0),
		FirstSeenHeight: height,
	}
}

func status(s Status) *Status { return &s }

func TestMempoolTx(t *testing.T) {
	ctx := context.Background()

	t.Run("mine keeps first seen and records the resolving height", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		require.NoError(t, UpsertPending(ctx, db, []Tx{pending("a", 10, 100)}))
		require.NoError(t, MarkMined(ctx, db, []string{"a", "missing"}, 105))

		txs, total, err := List(ctx, db, Filter{})
		require.NoError(t, err)
		require.EqualValues(t, 1, total)
		require.Equal(t, StatusMined, txs[0].Status)
		require.EqualValues(t, 100, txs[0].FirstSeenHeight)
		require.EqualValues(t, 105, *txs[0].ResolvedHeight)

		// Re-adding after a reorg resets to pending, first seen unchanged.
		require.NoError(t, UpsertPending(ctx, db, []Tx{pending("a", 99, 999)}))
		txs, _, err = List(ctx, db, Filter{})
		require.NoError(t, err)
		require.Equal(t, StatusPending, txs[0].Status)
		require.EqualValues(t, 100, txs[0].FirstSeenHeight)
		require.Nil(t, txs[0].ResolvedAt)
	})

	t.Run("remove and unmine", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		require.NoError(t, UpsertPending(ctx, db, []Tx{pending("a", 1, 100), pending("b", 1, 100)}))
		require.NoError(t, MarkRemoved(ctx, db, "a", 103))
		require.NoError(t, MarkMined(ctx, db, []string{"b"}, 104))
		require.NoError(t, Unmine(ctx, db, 104))

		counts, err := Counts(ctx, db)
		require.NoError(t, err)
		require.EqualValues(t, 1, counts[StatusRemoved])
		require.EqualValues(t, 1, counts[StatusPending])
	})

	t.Run("delete pending not in snapshot", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		require.NoError(t, UpsertPending(ctx, db, []Tx{pending("a", 1, 1), pending("b", 1, 1), pending("c", 1, 1)}))
		require.NoError(t, MarkMined(ctx, db, []string{"c"}, 5))
		require.NoError(t, DeletePendingNotIn(ctx, db, []string{"a"}))

		counts, err := Counts(ctx, db)
		require.NoError(t, err)
		require.EqualValues(t, 1, counts[StatusPending])
		require.EqualValues(t, 1, counts[StatusMined])
	})

	t.Run("list filters sorts and paginates", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		require.NoError(t, UpsertPending(ctx, db, []Tx{
			pending("low", 1, 100),
			pending("mid", 5, 104),
			pending("high", 50, 90),
		}))
		require.NoError(t, MarkMined(ctx, db, []string{"mid"}, 105))

		txs, total, err := List(ctx, db, Filter{SortBy: SortFeeRate, Desc: true})
		require.NoError(t, err)
		require.EqualValues(t, 3, total)
		require.Equal(t, []string{"high", "mid", "low"}, txids(txs))

		txs, total, err = List(ctx, db, Filter{Status: status(StatusPending), MinFeeRate: 5})
		require.NoError(t, err)
		require.EqualValues(t, 1, total)
		require.Equal(t, "high", txs[0].Txid)

		txs, _, err = List(ctx, db, Filter{SortBy: SortFirstSeen, Limit: 1, Offset: 1})
		require.NoError(t, err)
		require.Equal(t, []string{"mid"}, txids(txs))

		txs, total, err = List(ctx, db, Filter{TxidPrefix: "hi"})
		require.NoError(t, err)
		require.EqualValues(t, 1, total)
		require.Equal(t, []string{"high"}, txids(txs))
	})

	t.Run("seen rows gain details lazily and take core's first seen", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		require.NoError(t, UpsertSeen(ctx, db, []string{"a", "b"}, 100, time.Unix(1_700_000_100, 0)))
		txs, _, err := List(ctx, db, Filter{})
		require.NoError(t, err)
		require.False(t, txs[0].HasDetails)

		queue, err := PendingWithoutDetails(ctx, db, 103, 2, 10)
		require.NoError(t, err)
		require.Equal(t, []string{"a", "b"}, queue)
		queue, err = PendingWithoutDetails(ctx, db, 101, 2, 10)
		require.NoError(t, err)
		require.Empty(t, queue)

		require.NoError(t, SetDetails(ctx, db, pending("a", 7, 98)))
		queue, err = PendingWithoutDetails(ctx, db, 103, 2, 10)
		require.NoError(t, err)
		require.Equal(t, []string{"b"}, queue)

		txs, _, err = List(ctx, db, Filter{TxidPrefix: "a"})
		require.NoError(t, err)
		require.True(t, txs[0].HasDetails)
		require.EqualValues(t, 7, txs[0].FeeRate)
		require.EqualValues(t, 98, txs[0].FirstSeenHeight)

		// Removal drops the detail-less row and resolves the detailed one.
		require.NoError(t, MarkRemoved(ctx, db, "b", 103))
		require.NoError(t, MarkRemoved(ctx, db, "a", 103))
		counts, err := Counts(ctx, db)
		require.NoError(t, err)
		require.EqualValues(t, 1, counts[StatusRemoved])
		require.EqualValues(t, 0, counts[StatusPending])
	})

	t.Run("block stats list by range and roll back on reorg", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		for height, floor := range map[uint32]float64{100: 1, 101: 5, 102: 3, 103: 20} {
			require.NoError(t, PutBlockStats(ctx, db, height, floor, uint64(height)*1000))
		}
		require.NoError(t, PutBlockStats(ctx, db, 103, 2, 7))

		blocks, err := ListBlockStats(ctx, db, 101, 103)
		require.NoError(t, err)
		require.Equal(t, []BlockStats{
			{Height: 101, MinFeeRate: 5, TotalFeeSats: 101_000},
			{Height: 102, MinFeeRate: 3, TotalFeeSats: 102_000},
			{Height: 103, MinFeeRate: 2, TotalFeeSats: 7},
		}, blocks)

		require.NoError(t, DeleteBlockStatsAbove(ctx, db, 101))
		blocks, err = ListBlockStats(ctx, db, 0, 200)
		require.NoError(t, err)
		heights := []uint32{}
		for _, b := range blocks {
			heights = append(heights, b.Height)
		}
		require.Equal(t, []uint32{100, 101}, heights)
	})

	t.Run("prune keeps pending and stuck history", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)

		require.NoError(t, UpsertPending(ctx, db, []Tx{
			pending("pending", 1, 100),
			pending("quick", 1, 100),
			pending("stuck", 1, 100),
			pending("old", 1, 100),
		}))
		require.NoError(t, UpsertSeen(ctx, db, []string{"blind"}, 100, time.Now()))
		require.NoError(t, MarkMined(ctx, db, []string{"quick"}, 101))
		require.NoError(t, MarkMined(ctx, db, []string{"stuck", "old", "blind"}, 110))
		require.NoError(t, Prune(ctx, db, time.Now()))

		txs, _, err := List(ctx, db, Filter{SortBy: SortFirstSeen})
		require.NoError(t, err)
		require.ElementsMatch(t, []string{"pending", "stuck", "old"}, txids(txs))

		require.NoError(t, Prune(ctx, db, time.Now().Add(8*24*time.Hour)))
		txs, _, err = List(ctx, db, Filter{})
		require.NoError(t, err)
		require.Equal(t, []string{"pending"}, txids(txs))
	})
}

func txids(txs []Tx) []string {
	out := make([]string, len(txs))
	for i, t := range txs {
		out[i] = t.Txid
	}
	return out
}
