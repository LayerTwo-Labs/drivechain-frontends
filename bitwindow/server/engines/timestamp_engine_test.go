package engines_test

import (
	"context"
	"database/sql"
	"testing"

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
