package deniability

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

// Denial represents a deniability plan
type Denial struct {
	ID            int64
	TipTXID       string
	TipVout       int32
	DelayDuration time.Duration
	NumHops       int32
	CreatedAt     time.Time
	CancelledAt   *time.Time
	CancelReason  *string
}

// ExecutedDenial represents a completed denial transaction
type ExecutedDenial struct {
	ID        int64
	DenialID  int64
	FromTxID  string
	FromVout  int32
	ToTxID    string
	ToVout    int32
	CreatedAt time.Time
}

// Create creates a new deniability plan
func Create(ctx context.Context, db *sql.DB, txid string, vout int32, delayDuration time.Duration, numHops int32) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO denials (
			initial_txid,
			initial_vout,
			delay_duration,
			num_hops,
			created_at
		) VALUES (?, ?, ?, ?, ?)
	`, txid, vout, int(delayDuration.Seconds()), numHops, time.Now())
	return err
}

// RecordExecution records a completed denial transaction
func RecordExecution(ctx context.Context, db *sql.DB, denialID int64, fromTxID string, fromVout int32, toTxID string, toVout int32) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO executed_denials (
			denial_id,
			from_txid,
			from_vout,
			to_txid,
			to_vout,
			created_at
		) VALUES (?, ?, ?, ?, ?, ?)
	`, denialID, fromTxID, fromVout, toTxID, toVout, time.Now())
	return err
}

// List returns all denial plans
func List(ctx context.Context, db *sql.DB) ([]Denial, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT
			d.id,
			d.delay_duration,
			d.num_hops,
			d.created_at,
			d.cancelled_at,
			d.cancelled_reason,
			COALESCE(e.to_txid, d.initial_txid) as tip_txid,
			COALESCE(e.to_vout, d.initial_vout) as tip_vout
		FROM denials d
		LEFT JOIN (
			SELECT * FROM executed_denials ed
			WHERE ed.id = (
				SELECT MAX(id) FROM executed_denials
				WHERE denial_id = ed.denial_id
			)
		) e ON e.denial_id = d.id
		ORDER BY d.created_at ASC
	`)
	if err != nil {
		return nil, fmt.Errorf("could not query deniabilities: %w", err)
	}
	defer database.SafeDefer(ctx, rows.Close)

	var deniabilities []Denial
	for rows.Next() {
		var deniability Denial
		var delaySeconds float64
		err := rows.Scan(
			&deniability.ID,
			&delaySeconds,
			&deniability.NumHops,
			&deniability.CreatedAt,
			&deniability.CancelledAt,
			&deniability.CancelReason,
			&deniability.TipTXID,
			&deniability.TipVout,
		)
		if err != nil {
			return nil, fmt.Errorf("could not scan deniability: %w", err)
		}
		deniability.DelayDuration = time.Duration(delaySeconds * float64(time.Second))
		deniabilities = append(deniabilities, deniability)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("could not iterate over deniabilities: %w", err)
	}

	return deniabilities, nil
}

// ListExecutions returns all executed denials for a given deniability plan
func ListExecutions(ctx context.Context, db *sql.DB, denialID int64) ([]ExecutedDenial, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, denial_id, from_txid, from_vout, to_txid, to_vout, created_at
		FROM executed_denials
		WHERE denial_id = ?
		ORDER BY created_at DESC
	`, denialID)
	if err != nil {
		return nil, fmt.Errorf("could not query executed denials: %w", err)
	}
	defer database.SafeDefer(ctx, rows.Close)

	var executions []ExecutedDenial
	for rows.Next() {
		var execution ExecutedDenial
		err := rows.Scan(
			&execution.ID,
			&execution.DenialID,
			&execution.FromTxID,
			&execution.FromVout,
			&execution.ToTxID,
			&execution.ToVout,
			&execution.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("could not scan executed denial: %w", err)
		}
		executions = append(executions, execution)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("could not iterate over executed denials: %w", err)
	}

	return executions, nil
}

// Cancel marks a deniability plan as cancelled
func Cancel(ctx context.Context, db *sql.DB, id int64, reason string) error {
	_, err := db.ExecContext(ctx, `
		UPDATE denials
			SET cancelled_at = ?,
			cancelled_reason = ?
		WHERE id = ?
	`, time.Now(), reason, id)
	return err
}

// NextExecution calculates when the next execution should occur for a deniability plan
// Returns nil if all hops have been completed
func NextExecution(ctx context.Context, db *sql.DB, denial Denial) (*time.Time, error) {
	lastExecution, err := LastExecution(ctx, db, denial.ID)
	if err != nil {
		return nil, fmt.Errorf("could not get last execution: %w", err)
	}

	if lastExecution == nil {
		return nil, nil
	}

	// Calculate next execution time
	next := lastExecution.Add(denial.DelayDuration)
	return &next, nil
}

// LastExecution figures out when the previous execution was
// Returns nil if no execution has been made
func LastExecution(ctx context.Context, db *sql.DB, id int64) (*time.Time, error) {

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

	return &lastExecution, nil
}

// GetByTip retrieves a deniability plan by its tip transaction ID and vout
func GetByTip(ctx context.Context, db *sql.DB, tipTxID string, tipVout uint32) (*Denial, error) {
	row := db.QueryRowContext(ctx, `
		SELECT
			d.id,
			d.delay_duration,
			d.num_hops,
			d.created_at,
			d.cancelled_at,
			d.cancelled_reason,
			COALESCE(e.to_txid, d.initial_txid) as tip_txid,
			COALESCE(e.to_vout, d.initial_vout) as tip_vout
		FROM denials d
		LEFT JOIN (
			SELECT * FROM executed_denials ed
			WHERE ed.id = (
				SELECT MAX(id) FROM executed_denials
				WHERE denial_id = ed.denial_id
			)
		) e ON e.denial_id = d.id
		WHERE COALESCE(e.to_txid, d.initial_txid) = ? AND COALESCE(e.to_vout, d.initial_vout) = ?
	`, tipTxID, tipVout)

	var denial Denial
	var delaySeconds float64
	err := row.Scan(
		&denial.ID,
		&delaySeconds,
		&denial.NumHops,
		&denial.CreatedAt,
		&denial.CancelledAt,
		&denial.CancelReason,
		&denial.TipTXID,
		&denial.TipVout,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil // No matching record found, but that's okay
		}
		return nil, fmt.Errorf("could not get deniability by tip: %w", err)
	}

	denial.DelayDuration = time.Duration(delaySeconds * float64(time.Second))
	return &denial, nil
}

// Update updates the number of hops and delay duration for a given deniability plan
func Update(ctx context.Context, db *sql.DB, id int64, delaySeconds int32, numHops int32) error {
	_, err := db.ExecContext(ctx, `
		UPDATE denials
		SET delay_duration = ?, num_hops = num_hops + ?
		WHERE id = ?
	`, int(delaySeconds), numHops, id)
	if err != nil {
		return fmt.Errorf("could not update deniability: %w", err)
	}
	return nil
}
