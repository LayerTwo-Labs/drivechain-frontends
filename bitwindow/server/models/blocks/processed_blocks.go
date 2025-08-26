package blocks

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"
)

func GetProcessedTip(ctx context.Context, db *sql.DB) (*ProcessedBlock, error) {
	var (
		pb           ProcessedBlock
		txidsJSON    string
		rawBlockHash string
	)

	err := db.QueryRowContext(ctx, `
	SELECT height, block_hash, txids, block_time, processed_at
	FROM processed_blocks 
	ORDER BY height DESC 
	LIMIT 1
	`).Scan(&pb.Height, &rawBlockHash, &txidsJSON, &pb.BlockTime, &pb.ProcessedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	} else if err != nil {
		return nil, fmt.Errorf("query processed tip: %w", err)
	}

	hash, err := chainhash.NewHashFromStr(rawBlockHash)
	if err != nil {
		return nil, err
	}
	pb.Hash = *hash

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
	defer stmt.Close()

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

func WipeProcessedBlocks(ctx context.Context, db *sql.DB) error {
	start := time.Now()
	tag, err := db.ExecContext(ctx, `DELETE FROM processed_blocks`)
	if err != nil {
		return fmt.Errorf("wipe processed blocks: %w", err)
	}

	if rows, _ := tag.RowsAffected(); rows > 0 {
		zerolog.Ctx(ctx).Debug().
			Msgf("blocks: wiped %d processed blocks in %s", rows, time.Since(start))
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
	var (
		pb           ProcessedBlock
		rawBlockHash string
		// JSON-encoded array of strings, nice
		rawJsonTxids string
	)
	const query = `
		SELECT height, block_hash, txids, block_time, processed_at 
		FROM processed_blocks 
		WHERE height = ?
	`
	err := db.
		QueryRowContext(ctx, query, height).
		Scan(&pb.Height, &rawBlockHash, &rawJsonTxids, &pb.BlockTime, &pb.ProcessedAt)
	if err != nil {
		return ProcessedBlock{}, fmt.Errorf("get processed block: %w", err)
	}

	hash, err := chainhash.NewHashFromStr(rawBlockHash)
	if err != nil {
		return ProcessedBlock{}, fmt.Errorf("parse block hash: %w", err)
	}
	pb.Hash = *hash

	var rawTxids []string
	if err := json.Unmarshal([]byte(rawJsonTxids), &rawTxids); err != nil {
		return ProcessedBlock{}, fmt.Errorf("unmarshal txids: %w", err)
	}

	var parsedTXIDs []chainhash.Hash
	for _, rawTXID := range rawTxids {
		txid, err := chainhash.NewHashFromStr(rawTXID)
		if err != nil {
			return ProcessedBlock{}, fmt.Errorf("parse txid: %w", err)
		}
		parsedTXIDs = append(parsedTXIDs, *txid)
	}
	pb.Txids = parsedTXIDs

	return pb, nil
}
