package blocks

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

func GetProcessedTip(ctx context.Context, db *sql.DB) (*ProcessedBlock, error) {
	var pb ProcessedBlock
	err := db.QueryRowContext(ctx, `
	SELECT height, block_hash, processed_at
	FROM processed_blocks 
	ORDER BY height DESC 
	LIMIT 1
	`).Scan(&pb.Height, &pb.Hash, &pb.ProcessedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	} else if err != nil {
		return nil, fmt.Errorf("latest processed height: %w", err)
	}

	return &pb, nil

}

// MarkBlocksProcessed marks multiple blocks as processed in a single transaction
func MarkBlocksProcessed(ctx context.Context, db *sql.DB, blocks []ProcessedBlock) error {
	if len(blocks) == 0 {
		return nil
	}

	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin transaction: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	stmt, err := tx.PrepareContext(ctx, `
		REPLACE INTO processed_blocks (height, block_hash) 
		VALUES (?, ?)
	`)
	if err != nil {
		return fmt.Errorf("prepare statement: %w", err)
	}
	defer database.SafeDefer(ctx, stmt.Close)

	for _, block := range blocks {
		_, err = stmt.ExecContext(ctx, block.Height, block.Hash)
		if err != nil {
			return fmt.Errorf("mark block processed: %w", err)
		}
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit transaction: %w", err)
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
