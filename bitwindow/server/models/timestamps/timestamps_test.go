package timestamps_test

import (
	"context"
	"database/sql"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	_ "github.com/mattn/go-sqlite3"
	"github.com/stretchr/testify/require"
)

func setupTestDB(t *testing.T) *sql.DB {
	t.Helper()

	db, err := sql.Open("sqlite3", ":memory:")
	require.NoError(t, err)

	// Create table
	_, err = db.Exec(`
		CREATE TABLE file_timestamps (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			filename TEXT NOT NULL,
			file_hash TEXT NOT NULL UNIQUE,
			txid TEXT,
			block_height INTEGER,
			status TEXT NOT NULL,
			created_at TIMESTAMP NOT NULL,
			confirmed_at TIMESTAMP
		)
	`)
	require.NoError(t, err)

	return db
}

func TestCreate(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	defer db.Close()

	txid := "abc123"
	ts := timestamps.FileTimestamp{
		Filename:  "test.txt",
		FileHash:  "hash123",
		TxID:      &txid,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	}

	id, err := timestamps.Create(ctx, db, ts)
	require.NoError(t, err)
	require.Greater(t, id, int64(0))

	// Verify it was created
	result, err := timestamps.Get(ctx, db, id)
	require.NoError(t, err)
	require.NotNil(t, result)
	require.Equal(t, "test.txt", result.Filename)
	require.Equal(t, "hash123", result.FileHash)
	require.Equal(t, timestamps.StatusConfirming, result.Status)
}

func TestList(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	defer db.Close()

	// Create test data with different statuses
	txid1 := "txid1"
	txid2 := "txid2"
	txid3 := "txid3"

	ts1 := timestamps.FileTimestamp{
		Filename:  "file1.txt",
		FileHash:  "hash1",
		TxID:      &txid1,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now().Add(-2 * time.Hour),
	}
	ts2 := timestamps.FileTimestamp{
		Filename:  "file2.txt",
		FileHash:  "hash2",
		TxID:      &txid2,
		Status:    timestamps.StatusConfirmed,
		CreatedAt: time.Now().Add(-1 * time.Hour),
	}
	ts3 := timestamps.FileTimestamp{
		Filename:  "file3.txt",
		FileHash:  "hash3",
		TxID:      &txid3,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	}

	_, err := timestamps.Create(ctx, db, ts1)
	require.NoError(t, err)
	_, err = timestamps.Create(ctx, db, ts2)
	require.NoError(t, err)
	_, err = timestamps.Create(ctx, db, ts3)
	require.NoError(t, err)

	t.Run("list all timestamps", func(t *testing.T) {
		results, err := timestamps.List(ctx, db)
		require.NoError(t, err)
		require.Len(t, results, 3)

		// Should be ordered by created_at DESC
		require.Equal(t, "file3.txt", results[0].Filename)
		require.Equal(t, "file2.txt", results[1].Filename)
		require.Equal(t, "file1.txt", results[2].Filename)
	})

	t.Run("list only confirming timestamps", func(t *testing.T) {
		results, err := timestamps.List(ctx, db, timestamps.WithStatus(timestamps.StatusConfirming))
		require.NoError(t, err)
		require.Len(t, results, 2)

		// Should only have confirming timestamps
		for _, ts := range results {
			require.Equal(t, timestamps.StatusConfirming, ts.Status)
		}

		// Should be ordered by created_at DESC
		require.Equal(t, "file3.txt", results[0].Filename)
		require.Equal(t, "file1.txt", results[1].Filename)
	})

	t.Run("list only confirmed timestamps", func(t *testing.T) {
		results, err := timestamps.List(ctx, db, timestamps.WithStatus(timestamps.StatusConfirmed))
		require.NoError(t, err)
		require.Len(t, results, 1)
		require.Equal(t, "file2.txt", results[0].Filename)
		require.Equal(t, timestamps.StatusConfirmed, results[0].Status)
	})

	t.Run("list pending timestamps", func(t *testing.T) {
		results, err := timestamps.List(ctx, db, timestamps.WithStatus(timestamps.StatusPending))
		require.NoError(t, err)
		require.Len(t, results, 0)
	})
}

func TestGet(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	defer db.Close()

	txid := "txid123"
	ts := timestamps.FileTimestamp{
		Filename:  "test.txt",
		FileHash:  "hash123",
		TxID:      &txid,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	}

	id, err := timestamps.Create(ctx, db, ts)
	require.NoError(t, err)

	t.Run("get existing timestamp", func(t *testing.T) {
		result, err := timestamps.Get(ctx, db, id)
		require.NoError(t, err)
		require.NotNil(t, result)
		require.Equal(t, id, result.ID)
		require.Equal(t, "test.txt", result.Filename)
	})

	t.Run("get non-existent timestamp", func(t *testing.T) {
		result, err := timestamps.Get(ctx, db, 9999)
		require.NoError(t, err)
		require.Nil(t, result)
	})
}

func TestGetByHash(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	defer db.Close()

	txid := "txid123"
	ts := timestamps.FileTimestamp{
		Filename:  "test.txt",
		FileHash:  "hash123",
		TxID:      &txid,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	}

	_, err := timestamps.Create(ctx, db, ts)
	require.NoError(t, err)

	t.Run("get by existing hash", func(t *testing.T) {
		result, err := timestamps.GetByHash(ctx, db, "hash123")
		require.NoError(t, err)
		require.NotNil(t, result)
		require.Equal(t, "test.txt", result.Filename)
		require.Equal(t, "hash123", result.FileHash)
	})

	t.Run("get by non-existent hash", func(t *testing.T) {
		result, err := timestamps.GetByHash(ctx, db, "nonexistent")
		require.NoError(t, err)
		require.Nil(t, result)
	})
}

func TestUpdate(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	defer db.Close()

	txid := "txid123"
	ts := timestamps.FileTimestamp{
		Filename:  "test.txt",
		FileHash:  "hash123",
		TxID:      &txid,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	}

	id, err := timestamps.Create(ctx, db, ts)
	require.NoError(t, err)

	// Update to confirmed with block height
	blockHeight := int64(100)
	confirmedAt := time.Now()
	err = timestamps.Update(ctx, db, id, &txid, &blockHeight, timestamps.StatusConfirmed, &confirmedAt)
	require.NoError(t, err)

	// Verify update
	result, err := timestamps.Get(ctx, db, id)
	require.NoError(t, err)
	require.NotNil(t, result)
	require.Equal(t, timestamps.StatusConfirmed, result.Status)
	require.NotNil(t, result.BlockHeight)
	require.Equal(t, int64(100), *result.BlockHeight)
	require.NotNil(t, result.ConfirmedAt)
}
