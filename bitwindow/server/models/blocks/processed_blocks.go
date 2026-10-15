package blocks

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	sq "github.com/Masterminds/squirrel"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

func GetProcessedTip(ctx context.Context, db *sql.DB) (*ProcessedBlock, error) {
	query, args := selectProcessedBlock.OrderBy("height DESC").Limit(1).MustSql()
	pb, err := scanProcessedBlock(db.QueryRowContext(ctx, query, args...))
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return nil, nil
	case err != nil:
		return nil, fmt.Errorf("query processed tip: %w", err)
	}
	return &pb, nil
}

var selectProcessedBlock = sq.
	Select("height", "block_hash", "txids", "block_time", "processed_at").
	From("processed_blocks").
	PlaceholderFormat(sq.Question)

func scanProcessedBlock(scanner interface{ Scan(dest ...any) error }) (ProcessedBlock, error) {
	var (
		pb           ProcessedBlock
		rawBlockHash string
		txidsJSON    string
	)
	if err := scanner.Scan(&pb.Height, &rawBlockHash, &txidsJSON, &pb.BlockTime, &pb.ProcessedAt); err != nil {
		return ProcessedBlock{}, err
	}

	hash, err := chainhash.NewHashFromStr(rawBlockHash)
	if err != nil {
		return ProcessedBlock{}, fmt.Errorf("parse block hash: %w", err)
	}
	pb.Hash = *hash

	if err := json.Unmarshal([]byte(txidsJSON), &pb.Txids); err != nil {
		return ProcessedBlock{}, fmt.Errorf("unmarshal txids: %w", err)
	}

	return pb, nil
}

// MarkBlocksProcessed marks multiple blocks as processed in a single transaction.
func MarkBlocksProcessed(ctx context.Context, db *sql.DB, blocks []ProcessedBlock) error {
	if len(blocks) == 0 {
		return nil
	}

	start := time.Now()

	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	stmt, err := tx.PrepareContext(ctx, `
		INSERT INTO processed_blocks (height, block_hash, txids, block_time, processed_at)
		VALUES (?, ?, ?, ?, ?)
		ON CONFLICT(height) DO UPDATE SET block_hash=excluded.block_hash, txids=excluded.txids, block_time=excluded.block_time, processed_at=excluded.processed_at
	`)
	if err != nil {
		return fmt.Errorf("prepare stmt: %w", err)
	}
	defer database.SafeDefer(ctx, stmt.Close)

	var bestBlockHeight uint32
	for _, block := range blocks {
		bestBlockHeight = max(bestBlockHeight, block.Height)

		txidsJSON, err := json.Marshal(block.Txids)
		if err != nil {
			return fmt.Errorf("marshal txids: %w", err)
		}
		_, err = stmt.ExecContext(
			ctx, block.Height, block.Hash.String(),
			string(txidsJSON), block.BlockTime, time.Now(),
		)
		if err != nil {
			return fmt.Errorf("exec stmt: %w", err)
		}
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit tx: %w", err)
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("blocks: marked %d as processed in %s, best block height: %d", len(blocks), time.Since(start), bestBlockHeight)

	return nil
}

// DeleteProcessedBlocksAtOrAboveTx drops every processed block from height up,
// so a chain that forked below it is re-scanned from the last common block.
func DeleteProcessedBlocksAtOrAboveTx(ctx context.Context, tx *sql.Tx, height uint32) error {
	if _, err := tx.ExecContext(ctx, `DELETE FROM processed_blocks WHERE height >= ?`, height); err != nil {
		return fmt.Errorf("delete processed blocks at or above %d: %w", height, err)
	}
	return nil
}

type ProcessedBlock struct {
	Height      uint32
	Hash        chainhash.Hash
	BlockTime   time.Time
	ProcessedAt time.Time
	Txids       []chainhash.Hash
}

func GetProcessedBlock(ctx context.Context, db *sql.DB, height uint32) (ProcessedBlock, error) {
	query, args := selectProcessedBlock.Where(sq.Eq{"height": height}).MustSql()
	pb, err := scanProcessedBlock(db.QueryRowContext(ctx, query, args...))
	if err != nil {
		return ProcessedBlock{}, fmt.Errorf("get processed block: %w", err)
	}
	return pb, nil
}

// CountSince returns the number of processed blocks with a block time at or after since.
func CountSince(ctx context.Context, db *sql.DB, since time.Time) (int64, error) {
	count, err := database.Get[int64](ctx, db, `
		SELECT COUNT(*)
		FROM processed_blocks
		WHERE block_time >= ?
	`, since)
	if err != nil {
		return 0, fmt.Errorf("count blocks since %s: %w", since, err)
	}
	return count, nil
}

// TxCountSince returns the number of non-coinbase transactions in the processed
// blocks with a block time at or after since.
func TxCountSince(ctx context.Context, db *sql.DB, since time.Time) (int64, error) {
	count, err := database.Get[int64](ctx, db, `
		SELECT COALESCE(SUM(json_array_length(txids)) - COUNT(*), 0)
		FROM processed_blocks
		WHERE block_time >= ?
	`, since)
	if err != nil {
		return 0, fmt.Errorf("count transactions since %s: %w", since, err)
	}
	return count, nil
}
