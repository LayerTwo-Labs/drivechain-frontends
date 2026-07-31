package engines_test

import (
	"context"
	"database/sql"
	"testing"
	"time"

	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	_ "github.com/mattn/go-sqlite3"
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

type mockWallet struct{}

func (m *mockWallet) SendTransaction(ctx context.Context, opReturnData []byte) (string, error) {
	return "mock-txid", nil
}

type sequenceWallet struct {
	txids []string
	sent  int
}

func (w *sequenceWallet) SendTransaction(ctx context.Context, opReturnData []byte) (string, error) {
	txid := w.txids[w.sent]
	w.sent++
	return txid, nil
}

// The file hash is unique, so a failed record that is never replaced makes the
// file impossible to timestamp again.
func TestTimestampEngine_TimestampFailedFileAgain(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	defer db.Close()

	engine := engines.NewTimestampEngine(db, zerolog.Nop(), &sequenceWallet{txids: []string{"first-txid", "second-txid"}}, nil)

	fileData := []byte("test file content")
	first, err := engine.TimestampFile(ctx, "test.txt", fileData)
	require.NoError(t, err)

	_, err = db.ExecContext(ctx,
		`UPDATE file_timestamps SET status = ?, created_at = ? WHERE id = ?`,
		timestamps.StatusFailed, time.Now().Add(-30*24*time.Hour), first.ID,
	)
	require.NoError(t, err)

	second, err := engine.TimestampFile(ctx, "test.txt", fileData)
	require.NoError(t, err)
	require.Equal(t, first.ID, second.ID)
	require.Equal(t, "second-txid", *second.TxID)
	require.Equal(t, timestamps.StatusConfirming, second.Status)

	stored, err := timestamps.List(ctx, db)
	require.NoError(t, err)
	require.Len(t, stored, 1)
	require.Equal(t, timestamps.StatusConfirming, stored[0].Status)
	require.Equal(t, "second-txid", *stored[0].TxID)
	require.WithinDuration(t, time.Now(), stored[0].CreatedAt, time.Minute)
}

func TestTimestampEngine_TimestampFile(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	defer db.Close()

	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	bitcoindSvc := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	})

	log := zerolog.Nop()
	engine := engines.NewTimestampEngine(db, log, &mockWallet{}, bitcoindSvc)

	fileData := []byte("test file content")
	filename := "test.txt"

	t.Run("timestamp new file", func(t *testing.T) {
		result, err := engine.TimestampFile(ctx, filename, fileData)
		require.NoError(t, err)
		require.NotNil(t, result)
		require.Equal(t, filename, result.Filename)
		require.NotEmpty(t, result.FileHash)
		require.NotNil(t, result.TxID)
		require.Equal(t, "mock-txid", *result.TxID)
		require.Equal(t, timestamps.StatusConfirming, result.Status)
	})

	t.Run("timestamp already timestamped file", func(t *testing.T) {
		// Should return existing timestamp
		result, err := engine.TimestampFile(ctx, filename, fileData)
		require.NoError(t, err)
		require.NotNil(t, result)
		require.Equal(t, filename, result.Filename)

		// Verify it's the same one from the database
		allTimestamps, err := timestamps.List(ctx, db)
		require.NoError(t, err)
		require.Len(t, allTimestamps, 1)
	})
}
