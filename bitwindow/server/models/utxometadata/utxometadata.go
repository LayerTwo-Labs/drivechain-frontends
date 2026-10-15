package utxometadata

import (
	"context"
	"database/sql"
	"time"

	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	sq "github.com/Masterminds/squirrel"
)

type Entry struct {
	Outpoint  string
	IsFrozen  bool
	Label     string
	CreatedAt time.Time
	UpdatedAt time.Time
}

// Set creates or updates UTXO metadata
func Set(ctx context.Context, db *sql.DB, outpoint string, isFrozen *bool, label *string) error {
	now := time.Now().Unix()

	// Check if entry exists
	var existing Entry
	err := db.QueryRowContext(ctx,
		`SELECT outpoint, is_frozen, label FROM utxo_metadata WHERE outpoint = ?`,
		outpoint,
	).Scan(&existing.Outpoint, &existing.IsFrozen, &existing.Label)

	if err == sql.ErrNoRows {
		// Insert new entry
		frozen := false
		if isFrozen != nil {
			frozen = *isFrozen
		}
		lbl := ""
		if label != nil {
			lbl = *label
		}
		_, err = db.ExecContext(ctx,
			`INSERT INTO utxo_metadata (outpoint, is_frozen, label, created_at, updated_at) VALUES (?, ?, ?, ?, ?)`,
			outpoint, frozen, lbl, now, now,
		)
		return err
	} else if err != nil {
		return err
	}

	// Update existing entry
	if isFrozen != nil {
		existing.IsFrozen = *isFrozen
	}
	if label != nil {
		existing.Label = *label
	}

	_, err = db.ExecContext(ctx,
		`UPDATE utxo_metadata SET is_frozen = ?, label = ?, updated_at = ? WHERE outpoint = ?`,
		existing.IsFrozen, existing.Label, now, outpoint,
	)
	return err
}

// Get retrieves metadata for specific outpoints, or for all outpoints when outpoints is empty.
func Get(ctx context.Context, db *sql.DB, outpoints []string) (map[string]*Entry, error) {
	builder := sq.
		Select("outpoint", "is_frozen", "label", "created_at", "updated_at").
		From("utxo_metadata").
		PlaceholderFormat(sq.Question)
	if len(outpoints) > 0 {
		builder = builder.Where(sq.Eq{"outpoint": outpoints})
	}
	query, args := builder.MustSql()

	rows, err := db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	result := make(map[string]*Entry)
	for rows.Next() {
		var entry Entry
		var createdAt, updatedAt int64
		if err := rows.Scan(&entry.Outpoint, &entry.IsFrozen, &entry.Label, &createdAt, &updatedAt); err != nil {
			return nil, err
		}
		entry.CreatedAt = time.Unix(createdAt, 0)
		entry.UpdatedAt = time.Unix(updatedAt, 0)
		result[entry.Outpoint] = &entry
	}
	return result, rows.Err()
}

// FrozenOutpoints names every outpoint the user froze, as txid:vout.
func FrozenOutpoints(ctx context.Context, db *sql.DB) ([]string, error) {
	rows, err := db.QueryContext(ctx,
		`SELECT outpoint FROM utxo_metadata WHERE is_frozen = 1`,
	)
	if err != nil {
		return nil, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	var outpoints []string
	for rows.Next() {
		var outpoint string
		if err := rows.Scan(&outpoint); err != nil {
			return nil, err
		}
		outpoints = append(outpoints, outpoint)
	}
	return outpoints, rows.Err()
}
