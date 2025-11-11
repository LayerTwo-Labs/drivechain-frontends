package engines

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"time"

	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
)

type TimestampEngine struct {
	db     *sql.DB
	log    zerolog.Logger
	wallet WalletService
}

// WalletService interface for sending transactions
type WalletService interface {
	SendTransaction(ctx context.Context, opReturnData []byte) (string, error)
}

func NewTimestampEngine(db *sql.DB, log zerolog.Logger, wallet WalletService) *TimestampEngine {
	return &TimestampEngine{
		db:     db,
		log:    log.With().Str("component", "timestamp_engine").Logger(),
		wallet: wallet,
	}
}

func (e *TimestampEngine) TimestampFile(ctx context.Context, filename string, fileData []byte) (*timestamps.FileTimestamp, error) {
	hash := sha256.Sum256(fileData)
	fileHash := hex.EncodeToString(hash[:])

	e.log.Info().
		Str("filename", filename).
		Str("hash", fileHash).
		Int("size", len(fileData)).
		Msg("creating timestamp for file")

	// Check if already timestamped
	existing, err := timestamps.GetByHash(ctx, e.db, fileHash)
	if err != nil {
		return nil, fmt.Errorf("check existing timestamp: %w", err)
	}
	if existing != nil {
		e.log.Info().
			Str("filename", filename).
			Str("hash", fileHash).
			Int64("existing_id", existing.ID).
			Msg("file already timestamped")
		return existing, nil
	}

	// Create Bitcoin OP_RETURN transaction with file hash
	if e.wallet == nil {
		return nil, fmt.Errorf("wallet service not available")
	}

	txid, err := e.wallet.SendTransaction(ctx, hash[:])
	if err != nil {
		return nil, fmt.Errorf("send timestamp transaction: %w", err)
	}

	e.log.Info().
		Str("txid", txid).
		Str("hash", fileHash).
		Msg("created timestamp transaction on blockchain")

	// Store timestamp metadata in database
	timestamp := timestamps.FileTimestamp{
		Filename:  filename,
		FileHash:  fileHash,
		TxID:      &txid,
		Status:    timestamps.StatusConfirming,
		CreatedAt: time.Now(),
	}

	id, err := timestamps.Create(ctx, e.db, timestamp)
	if err != nil {
		return nil, fmt.Errorf("create timestamp record: %w", err)
	}

	timestamp.ID = id

	e.log.Info().
		Int64("id", id).
		Str("filename", filename).
		Str("hash", fileHash).
		Str("txid", txid).
		Msg("file timestamp created")

	return &timestamp, nil
}

func (e *TimestampEngine) ListTimestamps(ctx context.Context) ([]timestamps.FileTimestamp, error) {
	return timestamps.List(ctx, e.db)
}

func (e *TimestampEngine) GetTimestamp(ctx context.Context, id int64) (*timestamps.FileTimestamp, error) {
	timestamp, err := timestamps.Get(ctx, e.db, id)
	if err != nil {
		return nil, fmt.Errorf("get timestamp: %w", err)
	}
	if timestamp == nil {
		return nil, fmt.Errorf("timestamp not found")
	}

	return timestamp, nil
}

func (e *TimestampEngine) VerifyTimestamp(ctx context.Context, fileData []byte) (*timestamps.FileTimestamp, error) {
	hash := sha256.Sum256(fileData)
	fileHash := hex.EncodeToString(hash[:])

	// Look up timestamp by hash
	timestamp, err := timestamps.GetByHash(ctx, e.db, fileHash)
	if err != nil {
		return nil, fmt.Errorf("lookup timestamp: %w", err)
	}
	if timestamp == nil {
		return nil, fmt.Errorf("no timestamp found for this file")
	}

	e.log.Info().
		Str("hash", fileHash).
		Str("txid", *timestamp.TxID).
		Msg("file timestamp verified")

	return timestamp, nil
}

func (e *TimestampEngine) UpgradeTimestamp(ctx context.Context, id int64) (bool, *int64, string, error) {
	timestamp, err := e.GetTimestamp(ctx, id)
	if err != nil {
		return false, nil, "", err
	}

	// If already confirmed, nothing to do
	if timestamp.Status == timestamps.StatusConfirmed && timestamp.BlockHeight != nil {
		return false, timestamp.BlockHeight, fmt.Sprintf("already confirmed at block %d", *timestamp.BlockHeight), nil
	}

	if timestamp.TxID == nil {
		return false, nil, "no transaction ID", nil
	}

	// TODO: Query Bitcoin node to check if transaction is confirmed
	// For now, we'll just mark it as pending upgrade
	// This would need to be implemented with actual RPC calls to bitcoind

	e.log.Debug().
		Int64("id", id).
		Str("txid", *timestamp.TxID).
		Msg("checking transaction confirmation status")

	return false, nil, "confirmation check not yet implemented - check txid on block explorer", nil
}

func (e *TimestampEngine) UpgradeAllPending(ctx context.Context) error {
	allTimestamps, err := e.ListTimestamps(ctx)
	if err != nil {
		return fmt.Errorf("list timestamps: %w", err)
	}

	for _, ts := range allTimestamps {
		if ts.Status == timestamps.StatusConfirmed {
			continue
		}

		_, _, msg, err := e.UpgradeTimestamp(ctx, ts.ID)
		if err != nil {
			e.log.Warn().
				Err(err).
				Int64("id", ts.ID).
				Msg("upgrade timestamp")
			continue
		}

		e.log.Debug().
			Int64("id", ts.ID).
			Str("message", msg).
			Msg("checked timestamp")
	}

	return nil
}

func HashFile(path string) (string, error) {
	f, err := os.Open(path)
	if err != nil {
		return "", fmt.Errorf("open file: %w", err)
	}
	defer f.Close()

	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		return "", fmt.Errorf("hash file: %w", err)
	}

	return hex.EncodeToString(h.Sum(nil)), nil
}
