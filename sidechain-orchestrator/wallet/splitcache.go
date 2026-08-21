package wallet

import (
	"context"
	"fmt"
	"time"
)

// SplitStatuses returns the cached BTC-side split status per outpoint.
func (s *Service) SplitStatuses(ctx context.Context) (map[string]bool, error) {
	db := s.db()
	if db == nil {
		return nil, fmt.Errorf("split statuses: database not open")
	}
	rows, err := db.QueryContext(ctx, `SELECT outpoint, splittable FROM split_utxos`)
	if err != nil {
		return nil, fmt.Errorf("query split_utxos: %w", err)
	}
	defer func() { _ = rows.Close() }()

	out := map[string]bool{}
	for rows.Next() {
		var outpoint string
		var splittable bool
		if err := rows.Scan(&outpoint, &splittable); err != nil {
			return nil, fmt.Errorf("scan split_utxos: %w", err)
		}
		out[outpoint] = splittable
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read split_utxos: %w", err)
	}
	return out, nil
}

// SaveSplitStatus records the BTC-side split status of one outpoint.
func (s *Service) SaveSplitStatus(ctx context.Context, outpoint string, splittable bool) error {
	db := s.db()
	if db == nil {
		return fmt.Errorf("save split status: database not open")
	}
	_, err := db.ExecContext(ctx,
		`INSERT INTO split_utxos (outpoint, splittable, checked_at) VALUES (?,?,?)
		 ON CONFLICT (outpoint) DO UPDATE SET
		  splittable = excluded.splittable, checked_at = excluded.checked_at`,
		outpoint, splittable, time.Now().Unix())
	if err != nil {
		return fmt.Errorf("save split status: %w", err)
	}
	return nil
}
