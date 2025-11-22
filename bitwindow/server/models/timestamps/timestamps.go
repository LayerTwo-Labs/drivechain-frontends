package timestamps

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	sq "github.com/Masterminds/squirrel"
	"github.com/rs/zerolog"
)

type Status string

const (
	StatusPending    Status = "pending"
	StatusConfirming Status = "confirming"
	StatusConfirmed  Status = "confirmed"
	StatusFailed     Status = "failed"
)

type FileTimestamp struct {
	ID          int64
	Filename    string
	FileHash    string
	TxID        *string
	BlockHeight *int64
	Status      Status
	CreatedAt   time.Time
	ConfirmedAt *time.Time
}

func Create(ctx context.Context, db *sql.DB, timestamp FileTimestamp) (int64, error) {
	builder := sq.
		Insert("file_timestamps").
		Columns("filename", "file_hash", "txid", "status", "created_at").
		Values(
			timestamp.Filename,
			timestamp.FileHash,
			timestamp.TxID,
			timestamp.Status,
			timestamp.CreatedAt,
		)

	sql, args := builder.MustSql()
	result, err := db.ExecContext(ctx, sql, args...)
	if err != nil {
		return 0, fmt.Errorf("create file timestamp: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("get last insert ID: %w", err)
	}

	zerolog.Ctx(ctx).Info().
		Int64("id", id).
		Str("filename", timestamp.Filename).
		Str("hash", timestamp.FileHash).
		Msg("created file timestamp")

	return id, nil
}

func Update(ctx context.Context, db *sql.DB, id int64, txid *string, blockHeight *int64, status Status, confirmedAt *time.Time) error {
	builder := sq.
		Update("file_timestamps").
		Set("status", status).
		Where(sq.Eq{"id": id})

	if txid != nil {
		builder = builder.Set("txid", *txid)
	}
	if blockHeight != nil {
		builder = builder.Set("block_height", *blockHeight)
	}
	if confirmedAt != nil {
		builder = builder.Set("confirmed_at", *confirmedAt)
	}

	sql, args := builder.MustSql()
	_, err := db.ExecContext(ctx, sql, args...)
	if err != nil {
		return fmt.Errorf("update file timestamp: %w", err)
	}

	zerolog.Ctx(ctx).Debug().
		Int64("id", id).
		Str("status", string(status)).
		Msg("updated file timestamp")

	return nil
}

type ListOpts struct {
	Status *Status
}

func List(ctx context.Context, db *sql.DB, opts ...func(*ListOpts)) ([]FileTimestamp, error) {
	conf := &ListOpts{}
	for _, opt := range opts {
		opt(conf)
	}

	query := sq.
		Select("id", "filename", "file_hash", "txid", "block_height", "status", "created_at", "confirmed_at").
		From("file_timestamps").
		OrderBy("created_at DESC")

	if conf.Status != nil {
		query = query.Where(sq.Eq{"status": *conf.Status})
	}

	sql, args := query.MustSql()
	rows, err := db.QueryContext(ctx, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("list file timestamps: query: %w", err)
	}
	defer rows.Close()

	var timestamps []FileTimestamp
	for rows.Next() {
		var timestamp FileTimestamp
		err := rows.Scan(
			&timestamp.ID,
			&timestamp.Filename,
			&timestamp.FileHash,
			&timestamp.TxID,
			&timestamp.BlockHeight,
			&timestamp.Status,
			&timestamp.CreatedAt,
			&timestamp.ConfirmedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan file timestamp: %w", err)
		}

		timestamps = append(timestamps, timestamp)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate file timestamps: %w", err)
	}

	return timestamps, nil
}

func WithStatus(status Status) func(*ListOpts) {
	return func(opts *ListOpts) {
		opts.Status = &status
	}
}

func Get(ctx context.Context, db *sql.DB, id int64) (*FileTimestamp, error) {
	var timestamp FileTimestamp

	err := db.QueryRowContext(ctx, `
		SELECT id, filename, file_hash, txid, block_height,
		       status, created_at, confirmed_at
		FROM file_timestamps
		WHERE id = ?
	`, id).Scan(
		&timestamp.ID,
		&timestamp.Filename,
		&timestamp.FileHash,
		&timestamp.TxID,
		&timestamp.BlockHeight,
		&timestamp.Status,
		&timestamp.CreatedAt,
		&timestamp.ConfirmedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get file timestamp: %w", err)
	}

	return &timestamp, nil
}

func GetByHash(ctx context.Context, db *sql.DB, fileHash string) (*FileTimestamp, error) {
	var timestamp FileTimestamp

	err := db.QueryRowContext(ctx, `
		SELECT id, filename, file_hash, txid, block_height,
		       status, created_at, confirmed_at
		FROM file_timestamps
		WHERE file_hash = ?
	`, fileHash).Scan(
		&timestamp.ID,
		&timestamp.Filename,
		&timestamp.FileHash,
		&timestamp.TxID,
		&timestamp.BlockHeight,
		&timestamp.Status,
		&timestamp.CreatedAt,
		&timestamp.ConfirmedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get file timestamp by hash: %w", err)
	}

	return &timestamp, nil
}
