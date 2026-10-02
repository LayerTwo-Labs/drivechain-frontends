package mempooltx

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

type Status string

const (
	StatusPending Status = "pending"
	StatusMined   Status = "mined"
	StatusRemoved Status = "removed"
)

type Tx struct {
	Txid    string
	FeeSats uint64
	Vsize   uint32
	// FeeRate is the rate a block template weighs the tx at: its ancestor
	// package's fee over the package's vsize, in sat/vB.
	FeeRate         float64
	FirstSeenAt     time.Time
	FirstSeenHeight uint32
	Status          Status
	ResolvedAt      *time.Time
	ResolvedHeight  *uint32
	// HasDetails is false until fee, vsize and fee rate were fetched from Core.
	HasDetails bool
}

// BlockStats is what a connected block showed about the fee market.
type BlockStats struct {
	Height       uint32
	MinFeeRate   float64
	TotalFeeSats uint64
}

type SortField string

const (
	SortFeeRate   SortField = "fee_rate"
	SortFee       SortField = "fee_sats"
	SortVsize     SortField = "vsize"
	SortFirstSeen SortField = "first_seen_at"
)

type Filter struct {
	Status     *Status
	TxidPrefix string
	MinFeeRate float64
	Limit      int
	Offset     int
	SortBy     SortField
	Desc       bool
}

const MaxLimit = 500

// Keep resolved rows only when they waited this many blocks or more.
const minInterestingWait = 2

const historyRetention = 7 * 24 * time.Hour

// UpsertPending inserts txs as pending. An existing row is reset to pending
// and keeps its first-seen values.
func UpsertPending(ctx context.Context, db *sql.DB, txs []Tx) error {
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
			(txid, fee_sats, vsize, fee_rate, first_seen_at, first_seen_height, status, resolved_at, resolved_height)
		VALUES (?, ?, ?, ?, ?, ?, 'pending', NULL, NULL)
		ON CONFLICT(txid) DO UPDATE SET status = 'pending', resolved_at = NULL, resolved_height = NULL`)
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

// UpsertSeen records txids first seen at tip with no fee details. An existing
// row is reset to pending and keeps its first-seen values.
func UpsertSeen(ctx context.Context, db *sql.DB, txids []string, tip uint32, at time.Time) error {
	if len(txids) == 0 {
		return nil
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	stmt, err := tx.PrepareContext(ctx, `
		INSERT INTO mempool_transactions
			(txid, fee_sats, vsize, fee_rate, first_seen_at, first_seen_height, status, resolved_at, resolved_height)
		VALUES (?, NULL, NULL, NULL, ?, ?, 'pending', NULL, NULL)
		ON CONFLICT(txid) DO UPDATE SET status = 'pending', resolved_at = NULL, resolved_height = NULL`)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, stmt.Close)

	for _, txid := range txids {
		if _, err := stmt.ExecContext(ctx, txid, at.Unix(), tip); err != nil {
			return err
		}
	}
	return tx.Commit()
}

// SetDetails fills in the fee details of a row and replaces its first-seen
// values with the ones Core recorded when the tx entered its mempool.
func SetDetails(ctx context.Context, db *sql.DB, t Tx) error {
	_, err := db.ExecContext(ctx, `
		UPDATE mempool_transactions
		SET fee_sats = ?, vsize = ?, fee_rate = ?, first_seen_at = ?, first_seen_height = ?
		WHERE txid = ?`,
		t.FeeSats, t.Vsize, t.FeeRate, t.FirstSeenAt.Unix(), t.FirstSeenHeight, t.Txid)
	return err
}

// PendingWithoutDetails lists the oldest pending txids that have waited at
// least minWait blocks at tip and still have no fee details.
func PendingWithoutDetails(ctx context.Context, db *sql.DB, tip, minWait uint32, limit int) ([]string, error) {
	if tip < minWait {
		return nil, nil
	}
	rows, err := db.QueryContext(ctx, `
		SELECT txid FROM mempool_transactions
		WHERE status = 'pending' AND fee_sats IS NULL AND first_seen_height <= ?
		ORDER BY first_seen_height ASC, txid ASC
		LIMIT ?`, tip-minWait, limit)
	if err != nil {
		return nil, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	var txids []string
	for rows.Next() {
		var txid string
		if err := rows.Scan(&txid); err != nil {
			return nil, err
		}
		txids = append(txids, txid)
	}
	return txids, rows.Err()
}

// Delete drops a row regardless of status.
func Delete(ctx context.Context, db *sql.DB, txid string) error {
	_, err := db.ExecContext(ctx, `DELETE FROM mempool_transactions WHERE txid = ?`, txid)
	return err
}

// MarkMined resolves pending txids as mined at height.
func MarkMined(ctx context.Context, db *sql.DB, txids []string, height uint32) error {
	if len(txids) == 0 {
		return nil
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	stmt, err := tx.PrepareContext(ctx, `
		UPDATE mempool_transactions SET status = 'mined', resolved_at = ?, resolved_height = ?
		WHERE txid = ? AND status = 'pending'`)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, stmt.Close)

	now := time.Now().Unix()
	for _, txid := range txids {
		if _, err := stmt.ExecContext(ctx, now, height, txid); err != nil {
			return err
		}
	}
	return tx.Commit()
}

// MarkRemoved resolves a pending txid as removed at tip. A row that never got
// its fee details was never interesting and is dropped instead.
func MarkRemoved(ctx context.Context, db *sql.DB, txid string, tip uint32) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	if _, err := tx.ExecContext(ctx, `
		DELETE FROM mempool_transactions WHERE txid = ? AND status = 'pending' AND fee_sats IS NULL`, txid); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `
		UPDATE mempool_transactions SET status = 'removed', resolved_at = ?, resolved_height = ?
		WHERE txid = ? AND status = 'pending'`,
		time.Now().Unix(), tip, txid); err != nil {
		return err
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

// Unmine returns txs mined at height to pending.
func Unmine(ctx context.Context, db *sql.DB, height uint32) error {
	_, err := db.ExecContext(ctx, `
		UPDATE mempool_transactions SET status = 'pending', resolved_at = NULL, resolved_height = NULL
		WHERE status = 'mined' AND resolved_height = ?`, height)
	return err
}

// DeletePendingNotIn drops pending rows whose txid is not in keep.
func DeletePendingNotIn(ctx context.Context, db *sql.DB, keep []string) error {
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
		DELETE FROM mempool_transactions
		WHERE status = 'pending' AND txid NOT IN (SELECT txid FROM keep_txids)`); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DROP TABLE keep_txids`); err != nil {
		return err
	}
	return tx.Commit()
}

// Counts returns row counts by status.
func Counts(ctx context.Context, db *sql.DB) (map[Status]uint64, error) {
	rows, err := db.QueryContext(ctx, `SELECT status, COUNT(*) FROM mempool_transactions GROUP BY status`)
	if err != nil {
		return nil, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	counts := map[Status]uint64{}
	for rows.Next() {
		var s Status
		var n uint64
		if err := rows.Scan(&s, &n); err != nil {
			return nil, err
		}
		counts[s] = n
	}
	return counts, rows.Err()
}

// Prune drops resolved rows that were not stuck, never got details, or are
// past retention, plus detail-less pending rows past retention and block
// stats older than retention could ever need.
func Prune(ctx context.Context, db *sql.DB, now time.Time) error {
	cutoff := now.Add(-historyRetention).Unix()
	if _, err := db.ExecContext(ctx, `
		DELETE FROM mempool_transactions
		WHERE status != 'pending'
		  AND (fee_sats IS NULL OR resolved_height - first_seen_height < ? OR resolved_at < ?)`,
		minInterestingWait, cutoff); err != nil {
		return err
	}
	if _, err := db.ExecContext(ctx, `
		DELETE FROM mempool_transactions
		WHERE status = 'pending' AND fee_sats IS NULL AND first_seen_at < ?`, cutoff); err != nil {
		return err
	}
	_, err := db.ExecContext(ctx, `
		DELETE FROM block_stats
		WHERE height < (SELECT COALESCE(MIN(first_seen_height), 0) FROM mempool_transactions)`)
	return err
}

var sortColumns = map[SortField]string{
	SortFeeRate:   "fee_rate",
	SortFee:       "fee_sats",
	SortVsize:     "vsize",
	SortFirstSeen: "first_seen_at",
}

// List returns a page of txs matching f and the total match count.
func List(ctx context.Context, db *sql.DB, f Filter) ([]Tx, uint64, error) {
	where := []string{"1=1"}
	args := []any{}
	if f.Status != nil {
		where = append(where, "status = ?")
		args = append(args, *f.Status)
	}
	if f.MinFeeRate > 0 {
		where = append(where, "fee_rate > ?")
		args = append(args, f.MinFeeRate)
	}
	if f.TxidPrefix != "" {
		where = append(where, "txid >= ? AND txid < ?")
		args = append(args, f.TxidPrefix, f.TxidPrefix+"\uffff")
	}
	whereSQL := strings.Join(where, " AND ")

	var total uint64
	if err := db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM mempool_transactions WHERE `+whereSQL, args...,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	col, ok := sortColumns[f.SortBy]
	if !ok {
		col = "fee_rate"
	}
	dir := "ASC"
	if f.Desc {
		dir = "DESC"
	}
	limit := f.Limit
	if limit <= 0 || limit > MaxLimit {
		limit = MaxLimit
	}

	query := fmt.Sprintf(`
		SELECT txid, fee_sats, vsize, fee_rate, first_seen_at, first_seen_height, status,
		       resolved_at, resolved_height
		FROM mempool_transactions
		WHERE %s
		ORDER BY %s %s, fee_rate DESC, txid ASC
		LIMIT ? OFFSET ?`, whereSQL, col, dir)
	rows, err := db.QueryContext(ctx, query, append(args, limit, f.Offset)...)
	if err != nil {
		return nil, 0, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	var txs []Tx
	for rows.Next() {
		var t Tx
		var feeSats, vsize sql.NullInt64
		var feeRate sql.NullFloat64
		var firstSeen int64
		var resolvedAt sql.NullInt64
		var resolvedHeight sql.NullInt64
		if err := rows.Scan(&t.Txid, &feeSats, &vsize, &feeRate, &firstSeen, &t.FirstSeenHeight,
			&t.Status, &resolvedAt, &resolvedHeight); err != nil {
			return nil, 0, err
		}
		if feeSats.Valid {
			t.HasDetails = true
			t.FeeSats = uint64(feeSats.Int64)
			t.Vsize = uint32(vsize.Int64)
			t.FeeRate = feeRate.Float64
		}
		t.FirstSeenAt = time.Unix(firstSeen, 0)
		if resolvedAt.Valid {
			at := time.Unix(resolvedAt.Int64, 0)
			t.ResolvedAt = &at
		}
		if resolvedHeight.Valid {
			h := uint32(resolvedHeight.Int64)
			t.ResolvedHeight = &h
		}
		txs = append(txs, t)
	}
	return txs, total, rows.Err()
}
