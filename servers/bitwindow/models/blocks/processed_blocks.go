package blocks

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"
)

func LatestProcessedHeight(ctx context.Context, db *sql.DB) (int32, string, error) {
	var height int32
	var blockHash string
	err := db.QueryRowContext(ctx, `
		SELECT height, block_hash 
		FROM processed_blocks 
		ORDER BY height DESC 
		LIMIT 1
	`).Scan(&height, &blockHash)
	if errors.Is(err, sql.ErrNoRows) {
		return -1, "", nil
	} else if err != nil {
		return 0, "", fmt.Errorf("latest processed height: %w", err)
	}

	return height, blockHash, nil
}

func MarkBlockProcessed(ctx context.Context, db *sql.DB, height int32, hash string) error {
	_, err := db.ExecContext(ctx, `
		REPLACE INTO processed_blocks (height, block_hash) 
		VALUES (?, ?)
	`, height, hash)
	if err != nil {
		return fmt.Errorf("mark block processed: %w", err)
	}
	return nil
}

func WipeProcessedBlocks(ctx context.Context, db *sql.DB) error {
	_, err := db.ExecContext(ctx, `DELETE FROM processed_blocks`)
	if err != nil {
		return fmt.Errorf("wipe processed blocks: %w", err)
	}
	return nil
}

type ProcessedBlock struct {
	Height      int32
	Hash        string
	ProcessedAt time.Time
}

func GetProcessedBlock(ctx context.Context, db *sql.DB, height int32) (ProcessedBlock, error) {
	var pb ProcessedBlock
	err := db.QueryRowContext(ctx, `SELECT height, block_hash, processed_at FROM processed_blocks WHERE height = ?`, height).Scan(&pb.Height, &pb.Hash, &pb.ProcessedAt)
	if err != nil {
		return ProcessedBlock{}, fmt.Errorf("get processed block: %w", err)
	}
	return pb, nil

}
