package deniability

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"connectrpc.com/connect"
	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/samber/lo"
)

// Denial represents a deniability plan
type Denial struct {
	ID              int64
	TipTXID         string
	TipVout         int32
	DelayDuration   time.Duration
	NumHops         int32
	CreatedAt       time.Time
	UpdatedAt       time.Time
	CancelledAt     *time.Time
	CancelReason    *string
	NextExecution   *time.Time
	ExecutedDenials []ExecutedDenial
}

// ExecutedDenial represents a completed denial transaction
type ExecutedDenial struct {
	ID        int64
	DenialID  int64
	FromTxID  string
	FromVout  int32
	ToTxID    string
	ToVout    *string
	CreatedAt time.Time
}

// Create creates a new denial plan
func Create(ctx context.Context, db *sql.DB, txid string, vout int32, delayDuration time.Duration, numHops int32) (Denial, error) {
	var id int64
	err := db.QueryRowContext(ctx, `
		INSERT INTO denials (
			initial_txid,
			initial_vout,
			delay_duration,
			num_hops,
			created_at
		) VALUES (?, ?, ?, ?, ?)
		RETURNING id
	`, txid, vout, delayDuration, numHops, time.Now()).Scan(&id)
	if err != nil {
		return Denial{}, err
	}

	// Get the created deniability plan
	denial, err := Get(ctx, db, id)
	if err != nil {
		return Denial{}, fmt.Errorf("could not get created deniability: %w", err)
	}

	return denial, nil
}

// RecordExecution records a completed denial transaction
func RecordExecution(ctx context.Context, db *sql.DB, denialID int64, fromTxID string, fromVout int32, toTxID string, toVout uint32) error {
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

// selectDenialQuery returns the common SELECT part of denial queries
func selectDenialQuery() string {
	return `
		SELECT
			d.id,
			d.delay_duration,
			d.num_hops,
			d.created_at,
			d.updated_at,
			d.cancelled_at,
			d.cancelled_reason,
			COALESCE(e.to_txid, d.initial_txid) as tip_txid,
			CASE
				WHEN e.to_txid IS NULL THEN d.initial_vout
				ELSE e.to_vout
			END as tip_vout
		FROM denials d
		LEFT JOIN (
			SELECT * FROM executed_denials ed
			WHERE ed.id = (
				SELECT MAX(id) FROM executed_denials
				WHERE denial_id = ed.denial_id
			)
		) e ON e.denial_id = d.id`
}

type config struct {
	excludeCancelled bool
}

type Option func(c *config)

func WithExcludeCancelled() Option {
	return func(c *config) {
		c.excludeCancelled = true
	}
}

func newConfig(opts []Option) config {
	var conf config
	for _, fn := range opts {
		fn(&conf)
	}

	return conf
}

// List returns all denial plans
func List(ctx context.Context, db *sql.DB, opts ...Option) ([]Denial, error) {
	conf := newConfig(opts)

	query := selectDenialQuery()
	if conf.excludeCancelled {
		query += ` WHERE d.cancelled_at IS NULL`
	}
	query += ` ORDER BY d.updated_at ASC`

	rows, err := db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("could not query deniabilities: %w", err)
	}
	defer database.SafeDefer(ctx, rows.Close)

	var deniabilities []Denial
	for rows.Next() {
		var denial Denial
		err := rows.Scan(
			&denial.ID,
			&denial.DelayDuration,
			&denial.NumHops,
			&denial.CreatedAt,
			&denial.UpdatedAt,
			&denial.CancelledAt,
			&denial.CancelReason,
			&denial.TipTXID,
			&denial.TipVout,
		)
		if err != nil {
			return nil, fmt.Errorf("could not scan deniability: %w", err)
		}
		denial, err = denial.addExecutionData(ctx, db)
		if err != nil {
			return nil, fmt.Errorf("could not add execution data to deniability: %w", err)
		}

		deniabilities = append(deniabilities, denial)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("could not iterate over deniabilities: %w", err)
	}

	return deniabilities, nil
}

// listExecutions returns all executed denials for a given deniability plan
func listExecutions(ctx context.Context, db *sql.DB, denialID int64) ([]ExecutedDenial, error) {
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
	rows, err := db.ExecContext(ctx, `
		UPDATE denials
			SET cancelled_at = ?,
			cancelled_reason = ?
		WHERE id = ?
	`, time.Now(), reason, id)
	if err != nil {
		return fmt.Errorf("could not cancel deniability: %w", err)
	}

	if rows, _ := rows.RowsAffected(); rows == 0 {
		return connect.NewError(connect.CodeNotFound, fmt.Errorf("denial not found"))
	}

	return nil
}

// nextExecution calculates when the next execution should occur for a deniability plan
// Returns nil if all hops have been completed
func nextExecution(denial Denial, executions []ExecutedDenial) *time.Time {
	lastExecution := lastExecution(denial, executions)

	if lastExecution == nil {
		return nil
	}

	// Calculate next execution time
	next := lastExecution.Add(denial.DelayDuration)
	return &next
}

// LastExecution figures out when the previous execution was
// Returns nil if no execution has been made
func lastExecution(denial Denial, executions []ExecutedDenial) *time.Time {

	if denial.CancelledAt != nil {
		// If cancelled, next hop is never
		return nil
	}

	executionCount := lo.UniqBy(executions, func(execution ExecutedDenial) string {
		return execution.ToTxID
	})

	// If we've done all hops, next hop is never
	if int32(len(executionCount)) >= denial.NumHops {
		return nil
	}

	if len(executionCount) == 0 {
		// no executions whatsoever!
		return &denial.CreatedAt
	}

	// Find the latest execution from the executions array
	latestExecution := lo.MaxBy(executions, func(a, b ExecutedDenial) bool {
		return a.CreatedAt.After(b.CreatedAt)
	})

	return &latestExecution.CreatedAt
}

// GetByTip retrieves a deniability plan by its tip txid+vout
func GetByTip(ctx context.Context, db *sql.DB, tipTxID string, tipVout *int32) (*Denial, error) {
	query := selectDenialQuery() + `
		WHERE COALESCE(e.to_txid, d.initial_txid) = ? `
	args := []any{tipTxID}

	if tipVout != nil {
		query += ` AND (e.to_vout = ? OR d.initial_vout = ?) `
		args = append(args, tipVout)
		args = append(args, tipVout)
	}
	row := db.QueryRowContext(ctx, query, args...)

	var denial Denial
	err := row.Scan(
		&denial.ID,
		&denial.DelayDuration,
		&denial.NumHops,
		&denial.CreatedAt,
		&denial.UpdatedAt,
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

	d, err := denial.addExecutionData(ctx, db)
	if err != nil {
		return nil, fmt.Errorf("could not add execution data to deniability: %w", err)
	}

	return &d, nil
}

// Update updates the number of hops and delay duration for a given deniability plan
func Update(ctx context.Context, db *sql.DB, id int64, delay time.Duration, numHops int32) error {
	_, err := db.ExecContext(ctx, `
		UPDATE denials
		SET delay_duration = ?, num_hops = num_hops + ?, cancelled_at = NULL, cancelled_reason = NULL, updated_at = ?
		WHERE id = ?
	`, delay, numHops, time.Now(), id)
	if err != nil {
		return fmt.Errorf("could not update deniability: %w", err)
	}
	return nil
}

// Get retrieves a deniability plan by its ID
func Get(ctx context.Context, db *sql.DB, id int64) (Denial, error) {
	row := db.QueryRowContext(ctx,
		selectDenialQuery()+` WHERE d.id = ?`,
		id)

	var denial Denial
	err := row.Scan(
		&denial.ID,
		&denial.DelayDuration,
		&denial.NumHops,
		&denial.CreatedAt,
		&denial.UpdatedAt,
		&denial.CancelledAt,
		&denial.CancelReason,
		&denial.TipTXID,
		&denial.TipVout,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return Denial{}, nil // No matching record found, but that's okay
		}
		return Denial{}, fmt.Errorf("could not get deniability: %w", err)
	}

	return denial.addExecutionData(ctx, db)
}

func (d Denial) addExecutionData(ctx context.Context, db *sql.DB) (Denial, error) {
	executions, err := listExecutions(ctx, db, d.ID)
	if err != nil {
		return Denial{}, fmt.Errorf("could not get executed denials: %w", err)
	}
	d.ExecutedDenials = executions
	d.NextExecution = nextExecution(d, executions)

	return d, nil
}
