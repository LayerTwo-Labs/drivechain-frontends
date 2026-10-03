package coinbases_test

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinbases"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func row(height uint32, hash string, at time.Time) coinbases.Coinbase {
	return coinbases.Coinbase{
		Height:    height,
		Hash:      hash,
		BlockTime: at,
		Bits:      0x1d00ffff,
		TxCount:   2,
		Script:    []byte{0x03, 0x01, 0x02, 0x03, 0xff, '/', 'p', '/'},
		Addresses: []string{"bc1qone", "bc1qtwo"},
	}
}

func TestCoinbases(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	start := time.Unix(1_800_000_000, 0)

	t.Run("a stored row reads back the same", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		want := row(100, "h100", start)
		require.NoError(t, coinbases.Put(ctx, db, []coinbases.Coinbase{want}))

		got, err := coinbases.ListRange(ctx, db, 100, 100)
		require.NoError(t, err)
		require.Len(t, got, 1)
		assert.Equal(t, want, got[0])
	})

	t.Run("a coinbase with no addresses reads back with none", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		bare := row(100, "h100", start)
		bare.Addresses = nil
		require.NoError(t, coinbases.Put(ctx, db, []coinbases.Coinbase{bare}))

		got, err := coinbases.ListRange(ctx, db, 0, 200)
		require.NoError(t, err)
		require.Len(t, got, 1)
		assert.Empty(t, got[0].Addresses)
	})

	t.Run("a row at the same height replaces the old one", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		require.NoError(t, coinbases.Put(ctx, db, []coinbases.Coinbase{row(100, "old", start)}))
		require.NoError(t, coinbases.Put(ctx, db, []coinbases.Coinbase{row(100, "new", start.Add(time.Minute))}))

		got, err := coinbases.ListRange(ctx, db, 0, 200)
		require.NoError(t, err)
		require.Len(t, got, 1)
		assert.Equal(t, "new", got[0].Hash)
	})

	t.Run("lists come back in height order and inside their bounds", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		require.NoError(t, coinbases.Put(ctx, db, []coinbases.Coinbase{
			row(103, "h103", start.Add(30*time.Minute)),
			row(101, "h101", start.Add(10*time.Minute)),
			row(102, "h102", start.Add(20*time.Minute)),
			row(100, "h100", start),
		}))

		byRange, err := coinbases.ListRange(ctx, db, 101, 102)
		require.NoError(t, err)
		assert.Equal(t, []string{"h101", "h102"}, hashes(byRange))

		byTime, err := coinbases.ListSince(ctx, db, start.Add(20*time.Minute))
		require.NoError(t, err)
		assert.Equal(t, []string{"h102", "h103"}, hashes(byTime))
	})

	t.Run("a fork purge forgets the rows at and above its height", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		require.NoError(t, coinbases.Put(ctx, db, []coinbases.Coinbase{
			row(100, "h100", start), row(101, "h101", start), row(102, "h102", start),
		}))

		tx, err := db.BeginTx(ctx, nil)
		require.NoError(t, err)
		require.NoError(t, coinbases.DeleteAtOrAboveTx(ctx, tx, 101))
		require.NoError(t, tx.Commit())

		got, err := coinbases.ListRange(ctx, db, 0, 200)
		require.NoError(t, err)
		assert.Equal(t, []string{"h100"}, hashes(got))
	})

	t.Run("an empty batch writes nothing", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		require.NoError(t, coinbases.Put(ctx, db, nil))

		got, err := coinbases.ListRange(ctx, db, 0, 200)
		require.NoError(t, err)
		assert.Empty(t, got)
	})
}

func hashes(rows []coinbases.Coinbase) []string {
	out := make([]string, len(rows))
	for i, r := range rows {
		out[i] = r.Hash
	}
	return out
}
