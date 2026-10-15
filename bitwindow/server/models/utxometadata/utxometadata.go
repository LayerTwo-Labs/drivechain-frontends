package utxometadata

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	sq "github.com/Masterminds/squirrel"
	"github.com/samber/lo"

	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

type Entry struct {
	Outpoint string `db:"outpoint"`
	IsFrozen bool   `db:"is_frozen"`
	Label    string `db:"label"`
}

func Set(ctx context.Context, db *sql.DB, outpoint string, isFrozen *bool, label *string) error {
	now := time.Now().Unix()
	_, err := db.ExecContext(ctx, `
		INSERT INTO utxo_metadata (outpoint, is_frozen, label, created_at, updated_at)
		VALUES (?1, COALESCE(?2, 0), COALESCE(?3, ''), ?4, ?4)
		ON CONFLICT(outpoint) DO UPDATE SET
			is_frozen = COALESCE(?2, is_frozen),
			label = COALESCE(?3, label),
			updated_at = excluded.updated_at`,
		outpoint, isFrozen, label, now,
	)
	return err
}

// Get retrieves metadata for specific outpoints, or for all outpoints when outpoints is empty.
func Get(ctx context.Context, db *sql.DB, outpoints []string) (map[string]Entry, error) {
	builder := sq.
		Select("outpoint", "is_frozen", "label").
		From("utxo_metadata").
		PlaceholderFormat(sq.Question)
	if len(outpoints) > 0 {
		builder = builder.Where(sq.Eq{"outpoint": outpoints})
	}
	query, args := builder.MustSql()

	entries, err := database.Select[Entry](ctx, db, query, args...)
	if err != nil {
		return nil, fmt.Errorf("query utxo metadata: %w", err)
	}
	return lo.KeyBy(entries, func(e Entry) string { return e.Outpoint }), nil
}

// FrozenOutpoints names every outpoint the user froze, as txid:vout.
func FrozenOutpoints(ctx context.Context, db *sql.DB) ([]string, error) {
	return database.Select[string](ctx, db,
		`SELECT outpoint FROM utxo_metadata WHERE is_frozen = 1`,
	)
}
