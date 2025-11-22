package engines_test

import (
	"context"
	"database/sql"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
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

func TestTimestampEngine_CheckConfirmations(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	defer db.Close()

	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	bitcoindSvc := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	})

	// Create engine
	log := zerolog.Nop()
	engine := engines.NewTimestampEngine(db, log, &mockWallet{}, bitcoindSvc)

	// Create test timestamps
	txid1 := "txid-unconfirmed"
	txid2 := "txid-confirmed"

	ts1 := timestamps.FileTimestamp{
		Filename:  "unconfirmed.txt",
		FileHash:  "hash1",
		TxID:      &txid1,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	}
	ts2 := timestamps.FileTimestamp{
		Filename:  "confirmed.txt",
		FileHash:  "hash2",
		TxID:      &txid2,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	}

	id1, err := timestamps.Create(ctx, db, ts1)
	require.NoError(t, err)
	id2, err := timestamps.Create(ctx, db, ts2)
	require.NoError(t, err)

	blockhash := "block-hash-123"
	blockHeight := uint32(100)

	// Mock responses
	mockBitcoind.EXPECT().
		GetRawTransaction(gomock.Any(), gomock.Any()).
		DoAndReturn(func(ctx context.Context, req *connect.Request[corepb.GetRawTransactionRequest]) (*connect.Response[corepb.GetRawTransactionResponse], error) {
			if req.Msg.Txid == txid1 {
				// Unconfirmed transaction
				return &connect.Response[corepb.GetRawTransactionResponse]{
					Msg: &corepb.GetRawTransactionResponse{
						Confirmations: 0,
					},
				}, nil
			}
			// Confirmed transaction
			return &connect.Response[corepb.GetRawTransactionResponse]{
				Msg: &corepb.GetRawTransactionResponse{
					Confirmations: 2,
					Blockhash:     blockhash,
				},
			}, nil
		}).
		Times(2)

	// Mock GetBlock for confirmed transaction
	mockBitcoind.EXPECT().
		GetBlock(gomock.Any(), gomock.Any()).
		DoAndReturn(func(ctx context.Context, req *connect.Request[corepb.GetBlockRequest]) (*connect.Response[corepb.GetBlockResponse], error) {
			require.Equal(t, blockhash, req.Msg.Hash)
			return &connect.Response[corepb.GetBlockResponse]{
				Msg: &corepb.GetBlockResponse{
					Height: blockHeight,
				},
			}, nil
		}).
		Times(1)

	// Run confirmation check (simulate one tick)
	// We need to access the private method for testing, so we'll test through the public interface
	// by running the check once
	confirmingList, err := timestamps.List(ctx, db, timestamps.WithStatus(timestamps.StatusConfirming))
	require.NoError(t, err)
	require.Len(t, confirmingList, 2)

	// Manually trigger the check by calling UpgradeTimestamp for each
	upgraded1, blockHeight1, msg1, err := engine.UpgradeTimestamp(ctx, id1)
	require.NoError(t, err)
	require.False(t, upgraded1)
	require.Nil(t, blockHeight1)
	require.Contains(t, msg1, "waiting for confirmations")

	upgraded2, blockHeight2, msg2, err := engine.UpgradeTimestamp(ctx, id2)
	require.NoError(t, err)
	require.True(t, upgraded2)
	require.NotNil(t, blockHeight2)
	require.Equal(t, int64(blockHeight), *blockHeight2)
	require.Contains(t, msg2, "confirmed")

	// Verify database state
	result1, err := timestamps.Get(ctx, db, id1)
	require.NoError(t, err)
	require.Equal(t, timestamps.StatusConfirming, result1.Status)
	require.Nil(t, result1.BlockHeight)

	result2, err := timestamps.Get(ctx, db, id2)
	require.NoError(t, err)
	require.Equal(t, timestamps.StatusConfirmed, result2.Status)
	require.NotNil(t, result2.BlockHeight)
	require.Equal(t, int64(blockHeight), *result2.BlockHeight)
}

func TestTimestampEngine_UpgradeTimestamp(t *testing.T) {
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

	t.Run("upgrade already confirmed timestamp", func(t *testing.T) {
		txid := "already-confirmed"
		blockHeight := int64(50)
		confirmedAt := time.Now()

		ts := timestamps.FileTimestamp{
			Filename:    "confirmed.txt",
			FileHash:    "hash-confirmed",
			TxID:        &txid,
			Status:      timestamps.StatusConfirmed,
			BlockHeight: &blockHeight,
			CreatedAt:   time.Now(),
			ConfirmedAt: &confirmedAt,
		}

		id, err := timestamps.Create(ctx, db, ts)
		require.NoError(t, err)

		// Update to confirmed status
		err = timestamps.Update(ctx, db, id, &txid, &blockHeight, timestamps.StatusConfirmed, &confirmedAt)
		require.NoError(t, err)

		upgraded, height, msg, err := engine.UpgradeTimestamp(ctx, id)
		require.NoError(t, err)
		require.False(t, upgraded)
		require.NotNil(t, height)
		require.Equal(t, blockHeight, *height)
		require.Contains(t, msg, "already confirmed")
	})

	t.Run("upgrade timestamp without txid", func(t *testing.T) {
		ts := timestamps.FileTimestamp{
			Filename:  "no-txid.txt",
			FileHash:  "hash-no-txid",
			Status:    timestamps.StatusPending,
			CreatedAt: time.Now(),
		}

		id, err := timestamps.Create(ctx, db, ts)
		require.NoError(t, err)

		upgraded, height, msg, err := engine.UpgradeTimestamp(ctx, id)
		require.NoError(t, err)
		require.False(t, upgraded)
		require.Nil(t, height)
		require.Equal(t, "no transaction ID", msg)
	})

	t.Run("upgrade confirming timestamp", func(t *testing.T) {
		txid := "confirming-txid"
		blockhash := "block-hash-456"
		blockHeight := uint32(200)

		ts := timestamps.FileTimestamp{
			Filename:  "confirming.txt",
			FileHash:  "hash-confirming",
			TxID:      &txid,
			Status:    timestamps.StatusConfirming,
			CreatedAt: time.Now(),
		}

		id, err := timestamps.Create(ctx, db, ts)
		require.NoError(t, err)

		mockBitcoind.EXPECT().
			GetRawTransaction(gomock.Any(), gomock.Any()).
			DoAndReturn(func(ctx context.Context, req *connect.Request[corepb.GetRawTransactionRequest]) (*connect.Response[corepb.GetRawTransactionResponse], error) {
				require.Equal(t, txid, req.Msg.Txid)
				return &connect.Response[corepb.GetRawTransactionResponse]{
					Msg: &corepb.GetRawTransactionResponse{
						Confirmations: 3,
						Blockhash:     blockhash,
					},
				}, nil
			}).
			Times(1)

		mockBitcoind.EXPECT().
			GetBlock(gomock.Any(), gomock.Any()).
			DoAndReturn(func(ctx context.Context, req *connect.Request[corepb.GetBlockRequest]) (*connect.Response[corepb.GetBlockResponse], error) {
				require.Equal(t, blockhash, req.Msg.Hash)
				return &connect.Response[corepb.GetBlockResponse]{
					Msg: &corepb.GetBlockResponse{
						Height: blockHeight,
					},
				}, nil
			}).
			Times(1)

		upgraded, height, msg, err := engine.UpgradeTimestamp(ctx, id)
		require.NoError(t, err)
		require.True(t, upgraded)
		require.NotNil(t, height)
		require.Equal(t, int64(blockHeight), *height)
		require.Contains(t, msg, "confirmed at block")

		// Verify database state
		result, err := timestamps.Get(ctx, db, id)
		require.NoError(t, err)
		require.Equal(t, timestamps.StatusConfirmed, result.Status)
		require.NotNil(t, result.BlockHeight)
		require.Equal(t, int64(blockHeight), *result.BlockHeight)
		require.NotNil(t, result.ConfirmedAt)
	})
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
