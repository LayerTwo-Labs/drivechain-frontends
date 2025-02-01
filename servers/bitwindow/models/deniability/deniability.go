package deniability

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

// Denial represents a deniability plan
type Denial struct {
	ID            int64
	DelayDuration time.Duration
	NumHops       int32
	CreatedAt     time.Time
	CancelledAt   *time.Time
}

// ExecutedDenial represents a completed denial transaction
type ExecutedDenial struct {
	ID            int64
	DenialID      int64
	TransactionID string
	CreatedAt     time.Time
}

// Create creates a new deniability plan
func Create(ctx context.Context, db *sql.DB, delayDuration time.Duration, numHops int) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO denials (delay_duration, num_hops, created_at)
		VALUES (?, ?, ?)
	`, int(delayDuration.Seconds()), numHops, time.Now())
	return err
}

// RecordExecution records a completed denial transaction
func RecordExecution(ctx context.Context, db *sql.DB, denialID int64, txID string) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO executed_denials (denial_id, transaction_id, created_at)
		VALUES (?, ?, ?)
	`, denialID, txID, time.Now())
	return err
}

// List returns all denial plans
func List(ctx context.Context, db *sql.DB) ([]Denial, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, delay_duration, num_hops, created_at, cancelled_at
		FROM denials
		ORDER BY created_at DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("could not query deniabilities: %w", err)
	}
	defer rows.Close()

	var deniabilities []Denial
	for rows.Next() {
		var deniability Denial
		var delaySeconds float64
		err := rows.Scan(&deniability.ID, &delaySeconds, &deniability.NumHops, &deniability.CreatedAt, &deniability.CancelledAt)
		if err != nil {
			return nil, fmt.Errorf("could not scan deniability: %w", err)
		}
		deniability.DelayDuration = time.Duration(delaySeconds * float64(time.Second))
		deniabilities = append(deniabilities, deniability)
	}
	return deniabilities, nil
}

// ListExecutions returns all executed denials for a given deniability plan
func ListExecutions(ctx context.Context, db *sql.DB, denialID int64) ([]ExecutedDenial, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, denial_id, transaction_id, created_at
		FROM executed_denials
		WHERE denial_id = ?
		ORDER BY created_at DESC
	`, denialID)
	if err != nil {
		return nil, fmt.Errorf("could not query executed denials: %w", err)
	}
	defer rows.Close()

	var executions []ExecutedDenial
	for rows.Next() {
		var execution ExecutedDenial
		err := rows.Scan(
			&execution.ID,
			&execution.DenialID,
			&execution.TransactionID,
			&execution.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("could not scan executed denial: %w", err)
		}
		executions = append(executions, execution)
	}
	return executions, nil
}

// Cancel marks a deniability plan as cancelled
func Cancel(ctx context.Context, db *sql.DB, id int64) error {
	_, err := db.ExecContext(ctx, `
		UPDATE denials
		SET cancelled_at = ?
		WHERE id = ?
	`, time.Now(), id)
	return err
}

// NextExecution calculates when the next execution should occur for a deniability plan
// Returns nil if all hops have been completed
func NextExecution(ctx context.Context, db *sql.DB, id int64) (*time.Time, error) {

	// First get the deniability plan to check number of hops
	var numHops int32
	var delaySeconds float64
	var cancelledAt *time.Time
	var createdAt time.Time
	err := db.QueryRowContext(ctx, `
		SELECT num_hops, delay_duration, cancelled_at, created_at
		FROM denials
		WHERE id = ?
	`, id).Scan(&numHops, &delaySeconds, &cancelledAt, &createdAt)
	if err != nil {
		return nil, fmt.Errorf("could not get deniability: %w", err)
	}

	// If cancelled, no more executions
	if cancelledAt != nil {
		return nil, nil
	}

	// Count number of executions
	var executionCount int
	err = db.QueryRowContext(ctx, `
		SELECT COUNT(*)
		FROM executed_denials
		WHERE denial_id = ?
	`, id).Scan(&executionCount)
	if err != nil {
		return nil, fmt.Errorf("could not count executions: %w", err)
	}

	// If we've done all hops, return nil
	if int32(executionCount) >= numHops {
		return nil, nil
	}

	// Get the latest execution time
	var lastExecution time.Time
	if executionCount == 0 {
		lastExecution = createdAt
	} else {
		var timeStr string
		// Otherwise get the latest execution time
		err = db.QueryRowContext(ctx, `
			SELECT strftime('%Y-%m-%d %H:%M:%S', MAX(created_at))
			FROM executed_denials
			WHERE denial_id = ?
		`, id).Scan(&timeStr)
		if err != nil {
			return nil, fmt.Errorf("could not get last execution: %w", err)
		}

		// Parse the time string
		lastExecution, err = time.Parse("2006-01-02 15:04:05", timeStr)
		if err != nil {
			return nil, fmt.Errorf("could not parse execution time: %w", err)
		}
	}

	// Calculate next execution time
	next := lastExecution.Add(time.Duration(delaySeconds * float64(time.Second)))
	return &next, nil
}
