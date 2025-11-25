package notifications

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	sq "github.com/Masterminds/squirrel"
)

const (
	EventTypeTransaction     = "transaction"
	EventTypeTimestamp       = "timestamp"
	EventTypeTransactionConf = "transaction_confirmed"
)

// HasBeenNotified checks if an event has already been notified
func HasBeenNotified(ctx context.Context, db *sql.DB, eventType, eventID string) (bool, error) {
	query, args := sq.
		Select("1").
		From("notified_events").
		Where(sq.Eq{"event_type": eventType, "event_id": eventID}).
		MustSql()

	var exists int
	err := db.QueryRowContext(ctx, query, args...).Scan(&exists)
	if err == sql.ErrNoRows {
		return false, nil
	}
	if err != nil {
		return false, fmt.Errorf("check notified event: %w", err)
	}
	return true, nil
}

// MarkNotified marks an event as notified
func MarkNotified(ctx context.Context, db *sql.DB, eventType, eventID string) error {
	query, args := sq.
		Insert("notified_events").
		Columns("event_type", "event_id", "notified_at").
		Values(eventType, eventID, time.Now().UTC().Format(time.RFC3339)).
		MustSql()

	_, err := db.ExecContext(ctx, query, args...)
	if err != nil {
		return fmt.Errorf("mark event notified: %w", err)
	}
	return nil
}
