package database

import (
	"context"
	"database/sql"
	_ "embed"
	"fmt"
)

//go:embed cheque_key_versions.sql
var chequeKeyVersions string

func addLegacyChequeReceipt(ctx context.Context, db *sql.DB) error {
	var tableExists, columnExists bool
	err := db.QueryRowContext(ctx, `
		SELECT EXISTS (SELECT 1 FROM pragma_table_info('cheques')),
		       EXISTS (SELECT 1 FROM pragma_table_info('cheques') WHERE name = 'funded_txid')
	`).Scan(&tableExists, &columnExists)
	if err != nil {
		return fmt.Errorf("read cheque columns: %w", err)
	}
	if !tableExists || columnExists {
		return nil
	}
	if _, err := db.ExecContext(ctx, `ALTER TABLE cheques ADD COLUMN funded_txid TEXT`); err != nil {
		return fmt.Errorf("add legacy cheque receipt column: %w", err)
	}
	return nil
}

type chequeRowCounts struct {
	cheques, outputs, counters int
	maxID                      sql.NullInt64
}

func countChequeRows(ctx context.Context, tx *sql.Tx) (chequeRowCounts, error) {
	var counts chequeRowCounts
	err := tx.QueryRowContext(ctx, `
		SELECT (SELECT COUNT(*) FROM cheques), (SELECT COUNT(*) FROM cheque_funding_outputs),
		       (SELECT COUNT(*) FROM cheque_index_counters), (SELECT MAX(id) FROM cheques)
	`).Scan(&counts.cheques, &counts.outputs, &counts.counters, &counts.maxID)
	if err != nil {
		return counts, fmt.Errorf("count cheque rows: %w", err)
	}
	return counts, nil
}

// addChequeKeyVersions runs one time: it skips a table that has the key_version column.
func addChequeKeyVersions(ctx context.Context, db *sql.DB) error {
	var done bool
	if err := db.QueryRowContext(ctx, `
		SELECT EXISTS (SELECT 1 FROM pragma_table_info('cheques') WHERE name = 'key_version')
	`).Scan(&done); err != nil {
		return fmt.Errorf("read cheque key columns: %w", err)
	}
	if done {
		return nil
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin cheque key upgrade: %w", err)
	}
	defer SafeDefer(ctx, tx.Rollback)
	before, err := countChequeRows(ctx, tx)
	if err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, chequeKeyVersions); err != nil {
		return fmt.Errorf("add cheque key versions: %w", err)
	}
	after, err := countChequeRows(ctx, tx)
	if err != nil {
		return err
	}
	if before != after {
		return fmt.Errorf("cheque key upgrade changed the cheque rows: before %+v, after %+v", before, after)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit cheque key upgrade: %w", err)
	}
	return nil
}
