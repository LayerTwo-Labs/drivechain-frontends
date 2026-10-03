package mempooltx

import (
	"context"
	"database/sql"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

// Tx is a transaction still waiting in the mempool. A row lives exactly as
// long as the tx sits there: a block or a removal forgets it.
type Tx struct {
	Txid    string
	FeeSats uint64
	Vsize   uint32
	// FeeRate is the rate a block template weighs the tx at: its ancestor
	// package's fee over the package's vsize, in sat/vB.
	FeeRate         float64
	FirstSeenAt     time.Time
	FirstSeenHeight uint32
}

// BlockStats is what a connected block showed about the fee market.
type BlockStats struct {
	Height       uint32
	MinFeeRate   float64
	TotalFeeSats uint64
}

type Filter struct {
	TxidPrefix string
	Limit      int
	Offset     int
}

const MaxLimit = 2000

// Upsert inserts txs. An existing row keeps its first-seen values.
func Upsert(ctx context.Context, db *sql.DB, txs []Tx) error {
	if len(txs) == 0 {
		return nil
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	stmt, err := tx.PrepareContext(ctx, `
		INSERT INTO mempool_transactions
			(txid, fee_sats, vsize, fee_rate, first_seen_at, first_seen_height)
		VALUES (?, ?, ?, ?, ?, ?)
		ON CONFLICT(txid) DO NOTHING`)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, stmt.Close)

	for _, t := range txs {
		if _, err := stmt.ExecContext(ctx, t.Txid, t.FeeSats, t.Vsize, t.FeeRate, t.FirstSeenAt.Unix(), t.FirstSeenHeight); err != nil {
			return err
		}
	}
	return tx.Commit()
}

// Forget drops txids the mempool no longer holds, mined or not.
func Forget(ctx context.Context, db *sql.DB, txids []string) error {
	if len(txids) == 0 {
		return nil
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	stmt, err := tx.PrepareContext(ctx, `DELETE FROM mempool_transactions WHERE txid = ?`)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, stmt.Close)

	for _, txid := range txids {
		if _, err := stmt.ExecContext(ctx, txid); err != nil {
			return err
		}
	}
	return tx.Commit()
}

// PutBlockStats records the lowest fee rate a connected block included.
func PutBlockStats(ctx context.Context, db *sql.DB, height uint32, minFeeRate float64, totalFeeSats uint64) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO block_stats (height, min_fee_rate, total_fee_sats) VALUES (?, ?, ?)
		ON CONFLICT(height) DO UPDATE SET min_fee_rate = excluded.min_fee_rate,
		                                  total_fee_sats = excluded.total_fee_sats`,
		height, minFeeRate, totalFeeSats)
	return err
}

// ListBlockStats returns the recorded blocks with from <= height <= to.
func ListBlockStats(ctx context.Context, db *sql.DB, from, to uint32) ([]BlockStats, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT height, min_fee_rate, total_fee_sats FROM block_stats
		WHERE height >= ? AND height <= ? ORDER BY height`, from, to)
	if err != nil {
		return nil, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	var out []BlockStats
	for rows.Next() {
		var b BlockStats
		if err := rows.Scan(&b.Height, &b.MinFeeRate, &b.TotalFeeSats); err != nil {
			return nil, err
		}
		out = append(out, b)
	}
	return out, rows.Err()
}

// DeleteBlockStatsAbove forgets blocks above height after a reorg.
func DeleteBlockStatsAbove(ctx context.Context, db *sql.DB, height uint32) error {
	_, err := db.ExecContext(ctx, `DELETE FROM block_stats WHERE height > ?`, height)
	return err
}

// PruneBlockStats drops block stats below keep that no pending tx sat
// through either.
func PruneBlockStats(ctx context.Context, db *sql.DB, keep uint32) error {
	_, err := db.ExecContext(ctx, `
		DELETE FROM block_stats
		WHERE height < ? AND height < COALESCE((SELECT MIN(first_seen_height) FROM mempool_transactions), ?)`,
		keep, keep)
	return err
}

// DeleteNotIn drops rows whose txid is not in keep.
func DeleteNotIn(ctx context.Context, db *sql.DB, keep []string) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	if _, err := tx.ExecContext(ctx, `CREATE TEMP TABLE keep_txids (txid TEXT PRIMARY KEY)`); err != nil {
		return err
	}
	stmt, err := tx.PrepareContext(ctx, `INSERT OR IGNORE INTO keep_txids (txid) VALUES (?)`)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, stmt.Close)
	for _, txid := range keep {
		if _, err := stmt.ExecContext(ctx, txid); err != nil {
			return err
		}
	}
	if _, err := tx.ExecContext(ctx, `
		DELETE FROM mempool_transactions WHERE txid NOT IN (SELECT txid FROM keep_txids)`); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DROP TABLE keep_txids`); err != nil {
		return err
	}
	return tx.Commit()
}

// Clear forgets every tx and block stat recorded so far.
func Clear(ctx context.Context, db *sql.DB) error {
	if _, err := db.ExecContext(ctx, `DELETE FROM mempool_transactions`); err != nil {
		return err
	}
	_, err := db.ExecContext(ctx, `DELETE FROM block_stats`)
	return err
}

// Count returns how many txs are being watched.
func Count(ctx context.Context, db *sql.DB) (uint64, error) {
	var n uint64
	err := db.QueryRowContext(ctx, `SELECT COUNT(*) FROM mempool_transactions`).Scan(&n)
	return n, err
}

// List returns a page of txs matching f, oldest first, and the total match
// count.
func List(ctx context.Context, db *sql.DB, f Filter) ([]Tx, uint64, error) {
	where := "1=1"
	args := []any{}
	if f.TxidPrefix != "" {
		where = "txid >= ? AND txid < ?"
		args = append(args, f.TxidPrefix, f.TxidPrefix+"￿")
	}

	var total uint64
	if err := db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM mempool_transactions WHERE `+where, args...,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	limit := f.Limit
	if limit <= 0 || limit > MaxLimit {
		limit = MaxLimit
	}
	rows, err := db.QueryContext(ctx, `
		SELECT txid, fee_sats, vsize, fee_rate, first_seen_at, first_seen_height
		FROM mempool_transactions
		WHERE `+where+`
		ORDER BY first_seen_at ASC, txid ASC
		LIMIT ? OFFSET ?`, append(args, limit, f.Offset)...)
	if err != nil {
		return nil, 0, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	var txs []Tx
	for rows.Next() {
		var t Tx
		var firstSeen int64
		if err := rows.Scan(&t.Txid, &t.FeeSats, &t.Vsize, &t.FeeRate, &firstSeen, &t.FirstSeenHeight); err != nil {
			return nil, 0, err
		}
		t.FirstSeenAt = time.Unix(firstSeen, 0)
		txs = append(txs, t)
	}
	return txs, total, rows.Err()
}
