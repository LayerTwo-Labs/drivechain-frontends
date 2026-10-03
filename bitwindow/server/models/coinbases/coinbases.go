package coinbases

import (
	"context"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

// Coinbase is what a block's coinbase shows about who mined it.
type Coinbase struct {
	Height    uint32
	Hash      string
	BlockTime time.Time
	Bits      uint32
	TxCount   uint32
	Script    []byte
	Addresses []string
}

// Put records the coinbases, replacing any row at the same height.
func Put(ctx context.Context, db *sql.DB, rows []Coinbase) error {
	if len(rows) == 0 {
		return nil
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	stmt, err := tx.PrepareContext(ctx, `
		INSERT INTO block_coinbases
			(height, hash, block_time, bits, tx_count, coinbase_script, coinbase_addresses)
		VALUES (?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT(height) DO UPDATE SET
			hash = excluded.hash,
			block_time = excluded.block_time,
			bits = excluded.bits,
			tx_count = excluded.tx_count,
			coinbase_script = excluded.coinbase_script,
			coinbase_addresses = excluded.coinbase_addresses`)
	if err != nil {
		return err
	}
	defer database.SafeDefer(ctx, stmt.Close)

	for _, r := range rows {
		addresses, err := json.Marshal(r.Addresses)
		if err != nil {
			return fmt.Errorf("encode addresses at %d: %w", r.Height, err)
		}
		if _, err := stmt.ExecContext(ctx,
			r.Height, r.Hash, r.BlockTime.Unix(), r.Bits, r.TxCount,
			hex.EncodeToString(r.Script), string(addresses),
		); err != nil {
			return err
		}
	}
	return tx.Commit()
}

// ListSince returns the coinbases of blocks timestamped at or after from.
func ListSince(ctx context.Context, db *sql.DB, from time.Time) ([]Coinbase, error) {
	return list(ctx, db, `WHERE block_time >= ?`, from.Unix())
}

// ListRange returns the coinbases with from <= height <= to.
func ListRange(ctx context.Context, db *sql.DB, from, to uint32) ([]Coinbase, error) {
	return list(ctx, db, `WHERE height >= ? AND height <= ?`, from, to)
}

func list(ctx context.Context, db *sql.DB, where string, args ...any) ([]Coinbase, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT height, hash, block_time, bits, tx_count, coinbase_script, coinbase_addresses
		FROM block_coinbases `+where+` ORDER BY height`, args...)
	if err != nil {
		return nil, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	var out []Coinbase
	for rows.Next() {
		var (
			c         Coinbase
			blockTime int64
			script    string
			addresses string
		)
		if err := rows.Scan(&c.Height, &c.Hash, &blockTime, &c.Bits, &c.TxCount, &script, &addresses); err != nil {
			return nil, err
		}
		c.BlockTime = time.Unix(blockTime, 0)
		if c.Script, err = hex.DecodeString(script); err != nil {
			return nil, fmt.Errorf("decode script at %d: %w", c.Height, err)
		}
		if err := json.Unmarshal([]byte(addresses), &c.Addresses); err != nil {
			return nil, fmt.Errorf("decode addresses at %d: %w", c.Height, err)
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

// DeleteAtOrAboveTx forgets the coinbases a fork purge replays.
func DeleteAtOrAboveTx(ctx context.Context, tx *sql.Tx, height uint32) error {
	_, err := tx.ExecContext(ctx, `DELETE FROM block_coinbases WHERE height >= ?`, height)
	return err
}
