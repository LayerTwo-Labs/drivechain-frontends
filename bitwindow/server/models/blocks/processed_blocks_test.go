package blocks_test

import (
	"database/sql"
	"testing"
	"time"

	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
)

func block(height uint32, txids ...chainhash.Hash) blocks.ProcessedBlock {
	return blocks.ProcessedBlock{
		Height:    height,
		Hash:      chainhash.Hash{byte(height)},
		BlockTime: time.Unix(1700000000+int64(height), 0).UTC(),
		Txids:     txids,
	}
}

func TestProcessedBlocks(t *testing.T) {
	db := database.Test(t)
	txA := chainhash.Hash{0xaa}
	txB := chainhash.Hash{0xbb}

	t.Run("no tip on an empty table", func(t *testing.T) {
		tip, err := blocks.GetProcessedTip(t.Context(), db)
		require.NoError(t, err)
		assert.Nil(t, tip)
	})

	require.NoError(t, blocks.MarkBlocksProcessed(t.Context(), db, []blocks.ProcessedBlock{
		block(1, txA),
		block(2, txA, txB),
		block(3),
	}))

	t.Run("tip is the highest block", func(t *testing.T) {
		tip, err := blocks.GetProcessedTip(t.Context(), db)
		require.NoError(t, err)
		require.NotNil(t, tip)
		assert.EqualValues(t, 3, tip.Height)
		assert.Equal(t, chainhash.Hash{3}, tip.Hash)
		assert.Empty(t, tip.Txids)
	})

	t.Run("block round trip", func(t *testing.T) {
		got, err := blocks.GetProcessedBlock(t.Context(), db, 2)
		require.NoError(t, err)
		want := block(2, txA, txB)
		assert.Equal(t, want.Hash, got.Hash)
		assert.Equal(t, want.Txids, got.Txids)
		assert.True(t, want.BlockTime.Equal(got.BlockTime))
	})

	t.Run("missing block", func(t *testing.T) {
		_, err := blocks.GetProcessedBlock(t.Context(), db, 99)
		require.ErrorIs(t, err, sql.ErrNoRows)
	})

	t.Run("delete at or above a height", func(t *testing.T) {
		tx, err := db.BeginTx(t.Context(), nil)
		require.NoError(t, err)
		require.NoError(t, blocks.DeleteProcessedBlocksAtOrAboveTx(t.Context(), tx, 2))
		require.NoError(t, tx.Commit())

		tip, err := blocks.GetProcessedTip(t.Context(), db)
		require.NoError(t, err)
		require.NotNil(t, tip)
		assert.EqualValues(t, 1, tip.Height)
		assert.Equal(t, []chainhash.Hash{txA}, tip.Txids)
	})
}

func TestCountSince(t *testing.T) {
	t.Parallel()
	db := database.Test(t)
	now := time.Now()
	since := now.Add(-24 * time.Hour)

	count, err := blocks.CountSince(t.Context(), db, since)
	require.NoError(t, err)
	require.Zero(t, count)

	txCount, err := blocks.TxCountSince(t.Context(), db, since)
	require.NoError(t, err)
	require.Zero(t, txCount)

	require.NoError(t, blocks.MarkBlocksProcessed(t.Context(), db, []blocks.ProcessedBlock{
		{Height: 1, Hash: chainhash.Hash{1}, BlockTime: now.Add(-48 * time.Hour), Txids: []chainhash.Hash{{1}, {2}, {3}}},
		{Height: 2, Hash: chainhash.Hash{2}, BlockTime: now.Add(-time.Hour), Txids: []chainhash.Hash{{4}, {5}}},
		{Height: 3, Hash: chainhash.Hash{3}, BlockTime: now, Txids: []chainhash.Hash{{6}}},
	}))

	t.Run("CountSince skips older blocks", func(t *testing.T) {
		count, err := blocks.CountSince(t.Context(), db, since)
		require.NoError(t, err)
		require.Equal(t, int64(2), count)
	})

	t.Run("TxCountSince skips coinbases and older blocks", func(t *testing.T) {
		count, err := blocks.TxCountSince(t.Context(), db, since)
		require.NoError(t, err)
		require.Equal(t, int64(1), count)
	})

	t.Run("compares across a time zone offset", func(t *testing.T) {
		db := database.Test(t)
		oslo := time.FixedZone("CEST", 2*60*60)
		at := time.Date(2026, 7, 1, 12, 0, 0, 0, time.UTC)
		require.NoError(t, blocks.MarkBlocksProcessed(t.Context(), db, []blocks.ProcessedBlock{
			{Height: 1, Hash: chainhash.Hash{1}, BlockTime: at.In(oslo), Txids: []chainhash.Hash{{1}, {2}}},
			{Height: 2, Hash: chainhash.Hash{2}, BlockTime: at.Add(time.Hour), Txids: []chainhash.Hash{{3}, {4}}},
		}))

		count, err := blocks.CountSince(t.Context(), db, at.Add(30*time.Minute))
		require.NoError(t, err)
		assert.Equal(t, int64(1), count)

		txCount, err := blocks.TxCountSince(t.Context(), db, at.Add(30*time.Minute))
		require.NoError(t, err)
		assert.Equal(t, int64(1), txCount)

		count, err = blocks.CountSince(t.Context(), db, at.Add(30*time.Minute).In(oslo))
		require.NoError(t, err)
		assert.Equal(t, int64(1), count)
	})
}
