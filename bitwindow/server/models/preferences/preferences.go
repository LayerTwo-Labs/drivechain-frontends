package preferences

import (
	"context"
	"database/sql"
	"time"
)

const (
	KeyCoinSelectionStrategy = "coin_selection_strategy"
)

// Set stores a preference value
func Set(ctx context.Context, db *sql.DB, key, value string) error {
	now := time.Now().Unix()

	_, err := db.ExecContext(ctx,
		`INSERT INTO preferences (key, value, updated_at) VALUES (?, ?, ?)
		 ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at`,
		key, value, now,
	)
	return err
}

// Get retrieves a preference value, returning empty string if not found
func Get(ctx context.Context, db *sql.DB, key string) (string, error) {
	var value string
	err := db.QueryRowContext(ctx,
		`SELECT value FROM preferences WHERE key = ?`,
		key,
	).Scan(&value)

	if err == sql.ErrNoRows {
		return "", nil
	}
	return value, err
}
