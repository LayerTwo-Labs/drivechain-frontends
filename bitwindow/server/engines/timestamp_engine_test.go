package engines_test

import (
	"bytes"
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"testing"
	"time"

	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	_ "github.com/mattn/go-sqlite3"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
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

// timestampWallet is a wallet engine whose orchestrator broadcasts give txids in order.
func timestampWallet(t *testing.T, txids ...string) *engines.WalletEngine {
	t.Helper()
	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	orch.EXPECT().SetFrozenCoins(gomock.Any(), gomock.Any()).
		Return(&emptypb.Empty{}, nil).
		AnyTimes()
	sent := 0
	orch.EXPECT().SendTransaction(gomock.Any(), gomock.Any()).
		DoAndReturn(func(context.Context, *orchpb.SendTransactionRequest) (*orchpb.SendTransactionResponse, error) {
			txid := txids[sent]
			sent++
			return &orchpb.SendTransactionResponse{Txid: txid}, nil
		}).
		AnyTimes()
	return engines.NewWalletEngine(nil, apitests.OpenWallet(orch, &orchpb.WalletMetadata{Id: "a"}), &chaincfg.SigNetParams,
		func(context.Context) ([]string, error) { return nil, nil })
}

// The file hash is unique, so a failed record that is never replaced makes the
// file impossible to timestamp again.
func TestTimestampEngine_TimestampFailedFileAgain(t *testing.T) {
	ctx := t.Context()
	db := setupTestDB(t)
	defer db.Close()

	engine := engines.NewTimestampEngine(db, timestampWallet(t, "first-txid", "second-txid"), nil, nil)

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
	ctx := t.Context()
	db := setupTestDB(t)
	defer db.Close()

	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	bitcoindSvc := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	})

	engine := engines.NewTimestampEngine(db, timestampWallet(t, "mock-txid"), bitcoindSvc, nil)

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
	t.Run("logs through the context logger", func(t *testing.T) {
		var buf bytes.Buffer
		ctx := zerolog.New(&buf).With().Str("request_id", "req-1").Logger().WithContext(ctx)

		_, err := engine.TimestampFile(ctx, filename, fileData)
		require.NoError(t, err)
		assert.Contains(t, buf.String(), `"request_id":"req-1"`)
		assert.NotContains(t, buf.String(), `"component"`)
	})
}

func TestTimestampEngine_VerifyTimestamp(t *testing.T) {
	fileData := []byte("discovered file content")
	hash := sha256.Sum256(fileData)

	discovered := func(t *testing.T) *sql.DB {
		t.Helper()
		db := setupTestDB(t)
		t.Cleanup(func() { require.NoError(t, db.Close()) })
		_, err := timestamps.Create(t.Context(), db, timestamps.FileTimestamp{
			FileHash:  hex.EncodeToString(hash[:]),
			TxID:      lo.ToPtr("discovered-txid"),
			Status:    timestamps.StatusConfirmed,
			CreatedAt: time.Now(),
		})
		require.NoError(t, err)
		return db
	}

	t.Run("names a discovered timestamp", func(t *testing.T) {
		db := discovered(t)
		engine := engines.NewTimestampEngine(db, nil, nil, nil)

		result, err := engine.VerifyTimestamp(t.Context(), fileData, "found.txt")
		require.NoError(t, err)
		assert.Equal(t, "found.txt", result.Filename)
	})

	t.Run("a failed filename write fails the call", func(t *testing.T) {
		db := discovered(t)
		_, err := db.ExecContext(t.Context(), `
			CREATE TRIGGER no_update BEFORE UPDATE ON file_timestamps
			BEGIN SELECT RAISE(ABORT, 'no update'); END`)
		require.NoError(t, err)
		engine := engines.NewTimestampEngine(db, nil, nil, nil)

		_, err = engine.VerifyTimestamp(t.Context(), fileData, "found.txt")
		require.ErrorContains(t, err, "no update")
	})
}
