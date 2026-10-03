package mempooltx_test

import (
	"context"
	"database/sql"
	"fmt"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/mempooltx"
)

func newTx(txid string, firstSeen int64, height uint32) mempooltx.Tx {
	return mempooltx.Tx{
		Txid:            txid,
		FeeSats:         1000,
		Vsize:           200,
		FeeRate:         5,
		FirstSeenAt:     time.Unix(firstSeen, 0),
		FirstSeenHeight: height,
	}
}

func txids(txs []mempooltx.Tx) []string {
	out := make([]string, 0, len(txs))
	for _, t := range txs {
		out = append(out, t.Txid)
	}
	return out
}

func heights(stats []mempooltx.BlockStats) []uint32 {
	out := make([]uint32, 0, len(stats))
	for _, s := range stats {
		out = append(out, s.Height)
	}
	return out
}

func listAll(t *testing.T, db *sql.DB) []mempooltx.Tx {
	t.Helper()
	txs, _, err := mempooltx.List(context.Background(), db, mempooltx.Filter{})
	require.NoError(t, err)
	return txs
}

func TestMempoolTxUpsert(t *testing.T) {
	ctx := context.Background()

	t.Run("stores every field", func(t *testing.T) {
		db := database.Test(t)
		want := newTx("aa", 1000, 100)
		require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{want}))

		got := listAll(t, db)
		require.Len(t, got, 1)
		assert.Equal(t, want.Txid, got[0].Txid)
		assert.Equal(t, want.FeeSats, got[0].FeeSats)
		assert.Equal(t, want.Vsize, got[0].Vsize)
		assert.InDelta(t, want.FeeRate, got[0].FeeRate, 1e-9)
		assert.Equal(t, want.FirstSeenAt.Unix(), got[0].FirstSeenAt.Unix())
		assert.Equal(t, want.FirstSeenHeight, got[0].FirstSeenHeight)
	})

	t.Run("keeps the first-seen values of an existing row", func(t *testing.T) {
		db := database.Test(t)
		first := newTx("aa", 1000, 100)
		require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{first}))

		later := mempooltx.Tx{Txid: "aa", FeeSats: 9, Vsize: 9, FeeRate: 9, FirstSeenAt: time.Unix(5000, 0), FirstSeenHeight: 105}
		require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{later, newTx("bb", 2000, 101)}))

		got := listAll(t, db)
		require.Equal(t, []string{"aa", "bb"}, txids(got))
		assert.EqualValues(t, 1000, got[0].FeeSats)
		assert.EqualValues(t, 1000, got[0].FirstSeenAt.Unix())
		assert.EqualValues(t, 100, got[0].FirstSeenHeight)
	})

	t.Run("accepts an empty list", func(t *testing.T) {
		db := database.Test(t)
		require.NoError(t, mempooltx.Upsert(ctx, db, nil))
	})
}

func TestMempoolTxForget(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{newTx("aa", 1, 1), newTx("bb", 2, 1), newTx("cc", 3, 1)}))

	require.NoError(t, mempooltx.Forget(ctx, db, []string{"aa", "cc", "unknown"}))
	require.NoError(t, mempooltx.Forget(ctx, db, nil))

	assert.Equal(t, []string{"bb"}, txids(listAll(t, db)))
}

func TestMempoolTxBlockStats(t *testing.T) {
	ctx := context.Background()

	t.Run("put overwrites a height and list returns the range in order", func(t *testing.T) {
		db := database.Test(t)
		for _, h := range []uint32{103, 101, 102, 104} {
			require.NoError(t, mempooltx.PutBlockStats(ctx, db, h, float64(h), uint64(h)*10))
		}
		require.NoError(t, mempooltx.PutBlockStats(ctx, db, 102, 1.5, 7))

		got, err := mempooltx.ListBlockStats(ctx, db, 101, 103)
		require.NoError(t, err)
		require.Equal(t, []uint32{101, 102, 103}, heights(got))
		assert.InDelta(t, 1.5, got[1].MinFeeRate, 1e-9)
		assert.EqualValues(t, 7, got[1].TotalFeeSats)
	})

	t.Run("delete above drops only higher blocks", func(t *testing.T) {
		db := database.Test(t)
		for h := uint32(100); h <= 105; h++ {
			require.NoError(t, mempooltx.PutBlockStats(ctx, db, h, 1, 1))
		}
		require.NoError(t, mempooltx.DeleteBlockStatsAbove(ctx, db, 102))

		got, err := mempooltx.ListBlockStats(ctx, db, 0, 1000)
		require.NoError(t, err)
		assert.Equal(t, []uint32{100, 101, 102}, heights(got))
	})
}

func TestMempoolTxPruneBlockStats(t *testing.T) {
	ctx := context.Background()
	tests := []struct {
		name    string
		pending []mempooltx.Tx
		keep    uint32
		want    []uint32
	}{
		{
			name: "drops everything below keep with no pending tx",
			keep: 98,
			want: []uint32{98, 99, 100},
		},
		{
			name:    "keeps stats back to the oldest pending tx",
			pending: []mempooltx.Tx{newTx("aa", 1, 96), newTx("bb", 2, 99)},
			keep:    98,
			want:    []uint32{96, 97, 98, 99, 100},
		},
		{
			name:    "a pending tx newer than keep does not keep more",
			pending: []mempooltx.Tx{newTx("aa", 1, 100)},
			keep:    98,
			want:    []uint32{98, 99, 100},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			db := database.Test(t)
			for h := uint32(94); h <= 100; h++ {
				require.NoError(t, mempooltx.PutBlockStats(ctx, db, h, 1, 1))
			}
			require.NoError(t, mempooltx.Upsert(ctx, db, tt.pending))

			require.NoError(t, mempooltx.PruneBlockStats(ctx, db, tt.keep))

			got, err := mempooltx.ListBlockStats(ctx, db, 0, 1000)
			require.NoError(t, err)
			assert.Equal(t, tt.want, heights(got))
		})
	}
}

func TestMempoolTxDeleteNotIn(t *testing.T) {
	ctx := context.Background()

	t.Run("drops rows not in the list", func(t *testing.T) {
		db := database.Test(t)
		require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{newTx("aa", 1, 1), newTx("bb", 2, 1), newTx("cc", 3, 1)}))

		require.NoError(t, mempooltx.DeleteNotIn(ctx, db, []string{"bb", "bb", "zz"}))

		assert.Equal(t, []string{"bb"}, txids(listAll(t, db)))
	})

	t.Run("an empty list drops every row", func(t *testing.T) {
		db := database.Test(t)
		require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{newTx("aa", 1, 1)}))

		require.NoError(t, mempooltx.DeleteNotIn(ctx, db, nil))

		n, err := mempooltx.Count(ctx, db)
		require.NoError(t, err)
		assert.Zero(t, n)
	})

	t.Run("runs twice in a row", func(t *testing.T) {
		db := database.Test(t)
		require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{newTx("aa", 1, 1)}))
		require.NoError(t, mempooltx.DeleteNotIn(ctx, db, []string{"aa"}))
		require.NoError(t, mempooltx.DeleteNotIn(ctx, db, []string{"aa"}))
		assert.Equal(t, []string{"aa"}, txids(listAll(t, db)))
	})
}

func TestMempoolTxClearAndCount(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{newTx("aa", 1, 1), newTx("bb", 2, 1)}))
	require.NoError(t, mempooltx.PutBlockStats(ctx, db, 100, 1, 1))

	n, err := mempooltx.Count(ctx, db)
	require.NoError(t, err)
	assert.EqualValues(t, 2, n)

	require.NoError(t, mempooltx.Clear(ctx, db))

	n, err = mempooltx.Count(ctx, db)
	require.NoError(t, err)
	assert.Zero(t, n)
	stats, err := mempooltx.ListBlockStats(ctx, db, 0, 1000)
	require.NoError(t, err)
	assert.Empty(t, stats)
}

func TestMempoolTxList(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{
		newTx("ab02", 300, 1),
		newTx("ab01", 300, 1),
		newTx("ac00", 100, 1),
		newTx("aa99", 200, 1),
		newTx("abff", 400, 1),
	}))

	tests := []struct {
		name      string
		filter    mempooltx.Filter
		want      []string
		wantTotal uint64
	}{
		{
			name:      "returns oldest first with txid as tie break",
			filter:    mempooltx.Filter{},
			want:      []string{"ac00", "aa99", "ab01", "ab02", "abff"},
			wantTotal: 5,
		},
		{
			name:      "filters by txid prefix",
			filter:    mempooltx.Filter{TxidPrefix: "ab"},
			want:      []string{"ab01", "ab02", "abff"},
			wantTotal: 3,
		},
		{
			name:      "a full txid matches itself",
			filter:    mempooltx.Filter{TxidPrefix: "ab02"},
			want:      []string{"ab02"},
			wantTotal: 1,
		},
		{
			name:      "an unknown prefix matches nothing",
			filter:    mempooltx.Filter{TxidPrefix: "ff"},
			want:      nil,
			wantTotal: 0,
		},
		{
			name:      "limit and offset page the result but not the total",
			filter:    mempooltx.Filter{Limit: 2, Offset: 1},
			want:      []string{"aa99", "ab01"},
			wantTotal: 5,
		},
		{
			name:      "limit and offset apply after the prefix filter",
			filter:    mempooltx.Filter{TxidPrefix: "ab", Limit: 1, Offset: 2},
			want:      []string{"abff"},
			wantTotal: 3,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, total, err := mempooltx.List(ctx, db, tt.filter)
			require.NoError(t, err)
			assert.Equal(t, tt.want, txidsOrNil(got))
			assert.Equal(t, tt.wantTotal, total)
		})
	}
}

func TestMempoolTxListCapsTheLimit(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	txs := make([]mempooltx.Tx, 0, mempooltx.MaxLimit+5)
	for i := range mempooltx.MaxLimit + 5 {
		txs = append(txs, newTx(fmt.Sprintf("%064x", i), int64(i), 1))
	}
	require.NoError(t, mempooltx.Upsert(ctx, db, txs))

	for _, limit := range []int{0, -1, mempooltx.MaxLimit + 1} {
		t.Run(fmt.Sprintf("limit %d", limit), func(t *testing.T) {
			got, total, err := mempooltx.List(ctx, db, mempooltx.Filter{Limit: limit})
			require.NoError(t, err)
			assert.Len(t, got, mempooltx.MaxLimit)
			assert.EqualValues(t, mempooltx.MaxLimit+5, total)
		})
	}
}

func txidsOrNil(txs []mempooltx.Tx) []string {
	if len(txs) == 0 {
		return nil
	}
	return txids(txs)
}
