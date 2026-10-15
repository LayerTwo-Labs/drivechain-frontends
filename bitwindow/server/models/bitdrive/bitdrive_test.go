package bitdrive_test

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bitdrive"
)

func TestFiles(t *testing.T) {
	db := database.Test(t)

	older := bitdrive.File{
		TxID:      "txid-old",
		Filename:  "old.txt",
		FileType:  "text/plain",
		SizeBytes: 10,
		Encrypted: true,
		Timestamp: 1700000000,
		CreatedAt: time.Unix(1700000000, 0),
	}
	newer := bitdrive.File{
		TxID:      "txid-new",
		Filename:  "new.png",
		FileType:  "image/png",
		SizeBytes: 20,
		Timestamp: 1700000100,
		CreatedAt: time.Unix(1700000100, 0),
	}
	olderID, err := bitdrive.Create(t.Context(), db, older)
	require.NoError(t, err)
	older.ID = olderID
	newerID, err := bitdrive.Create(t.Context(), db, newer)
	require.NoError(t, err)
	newer.ID = newerID

	t.Run("list newest first", func(t *testing.T) {
		files, err := bitdrive.List(t.Context(), db)
		require.NoError(t, err)
		assert.Equal(t, []bitdrive.File{newer, older}, files)
	})

	t.Run("get by id", func(t *testing.T) {
		got, err := bitdrive.GetByID(t.Context(), db, olderID)
		require.NoError(t, err)
		require.NotNil(t, got)
		assert.Equal(t, older, *got)

		missing, err := bitdrive.GetByID(t.Context(), db, 9999)
		require.NoError(t, err)
		assert.Nil(t, missing)
	})

	t.Run("get by txid", func(t *testing.T) {
		got, err := bitdrive.GetByTxID(t.Context(), db, "txid-new")
		require.NoError(t, err)
		require.NotNil(t, got)
		assert.Equal(t, newer, *got)

		missing, err := bitdrive.GetByTxID(t.Context(), db, "nope")
		require.NoError(t, err)
		assert.Nil(t, missing)
	})

	t.Run("exists and delete", func(t *testing.T) {
		ok, err := bitdrive.Exists(t.Context(), db, "txid-old")
		require.NoError(t, err)
		assert.True(t, ok)

		require.NoError(t, bitdrive.Delete(t.Context(), db, olderID))

		ok, err = bitdrive.Exists(t.Context(), db, "txid-old")
		require.NoError(t, err)
		assert.False(t, ok)
	})
}
