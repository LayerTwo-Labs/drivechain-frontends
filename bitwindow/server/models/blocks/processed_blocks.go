package blocks

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

func GetProcessedTip(ctx context.Context, db *sql.DB) (*ProcessedBlock, error) {
	var pb ProcessedBlock
	var txidsJSON string
	err := db.QueryRowContext(ctx, `
	SELECT height, block_hash, txids, block_time, processed_at
	FROM processed_blocks 
	ORDER BY height DESC 
	LIMIT 1
	`).Scan(&pb.Height, &pb.Hash, &txidsJSON, &pb.BlockTime, &pb.ProcessedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	} else if err != nil {
		return nil, fmt.Errorf("query processed tip: %w", err)
	}

	if err := json.Unmarshal([]byte(txidsJSON), &pb.Txids); err != nil {
		return nil, fmt.Errorf("unmarshal txids: %w", err)
	}

	return &pb, nil
}

// MarkBlocksProcessed marks multiple blocks as processed in a single transaction (safe, no string concatenation)
func MarkBlocksProcessed(ctx context.Context, db *sql.DB, blocks []ProcessedBlock) error {
	if len(blocks) == 0 {
		return nil
	}

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
	defer stmt.Close()

	for _, block := range blocks {
		txidsJSON, err := json.Marshal(block.Txids)
		if err != nil {
			return fmt.Errorf("marshal txids: %w", err)
		}
		_, err = stmt.ExecContext(ctx, block.Height, block.Hash, string(txidsJSON), block.BlockTime, time.Now())
		if err != nil {
			return fmt.Errorf("exec stmt: %w", err)
		}
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit tx: %w", err)
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
	BlockTime   time.Time
	ProcessedAt time.Time
	Txids       []string
}

func GetProcessedBlock(ctx context.Context, db *sql.DB, height int32) (ProcessedBlock, error) {
	var pb ProcessedBlock
	var txidsJSON string
	err := db.QueryRowContext(ctx, `SELECT height, block_hash, txids, block_time, processed_at FROM processed_blocks WHERE height = ?`, height).Scan(&pb.Height, &pb.Hash, &txidsJSON, &pb.BlockTime, &pb.ProcessedAt)
	if err != nil {
		return ProcessedBlock{}, fmt.Errorf("get processed block: %w", err)
	}

	if err := json.Unmarshal([]byte(txidsJSON), &pb.Txids); err != nil {
		return ProcessedBlock{}, fmt.Errorf("unmarshal txids: %w", err)
	}

	return pb, nil
}
