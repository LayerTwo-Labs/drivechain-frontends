package timestamps

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	sq "github.com/Masterminds/squirrel"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

type Status string

const (
	StatusPending    Status = "pending"
	StatusConfirming Status = "confirming"
	StatusConfirmed  Status = "confirmed"
	StatusFailed     Status = "failed"
)

type FileTimestamp struct {
	ID          int64      `db:"id"`
	Filename    string     `db:"filename"`
	FileHash    string     `db:"file_hash"`
	TxID        *string    `db:"txid"`
	BlockHeight *int64     `db:"block_height"`
	Status      Status     `db:"status"`
	CreatedAt   time.Time  `db:"created_at"`
	ConfirmedAt *time.Time `db:"confirmed_at"`
}

func Create(ctx context.Context, db *sql.DB, timestamp FileTimestamp) (int64, error) {
	builder := sq.
		Insert("file_timestamps").
		Columns("filename", "file_hash", "txid", "block_height", "status", "created_at", "confirmed_at").
		Values(
			timestamp.Filename,
			timestamp.FileHash,
			timestamp.TxID,
			timestamp.BlockHeight,
			timestamp.Status,
			timestamp.CreatedAt,
			timestamp.ConfirmedAt,
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
	Statuses []Status
}

func List(ctx context.Context, db *sql.DB, opts ...func(*ListOpts)) ([]FileTimestamp, error) {
	conf := &ListOpts{}
	for _, opt := range opts {
		opt(conf)
	}

	query := selectTimestamp.OrderBy("created_at DESC")

	if len(conf.Statuses) > 0 {
		query = query.Where(sq.Eq{"status": conf.Statuses})
	}

	sql, args := query.MustSql()
	timestamps, err := database.Select[FileTimestamp](ctx, db, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("list file timestamps: %w", err)
	}
	return timestamps, nil
}

func WithStatus(statuses ...Status) func(*ListOpts) {
	return func(opts *ListOpts) {
		opts.Statuses = statuses
	}
}

func Get(ctx context.Context, db *sql.DB, id int64) (*FileTimestamp, error) {
	timestamp, err := getTimestampWhere(ctx, db, sq.Eq{"id": id})
	if err != nil {
		return nil, fmt.Errorf("get file timestamp: %w", err)
	}
	return timestamp, nil
}

func GetByHash(ctx context.Context, db *sql.DB, fileHash string) (*FileTimestamp, error) {
	timestamp, err := getTimestampWhere(ctx, db, sq.Eq{"file_hash": fileHash})
	if err != nil {
		return nil, fmt.Errorf("get file timestamp by hash: %w", err)
	}
	return timestamp, nil
}

var selectTimestamp = sq.
	Select("id", "filename", "file_hash", "txid", "block_height", "status", "created_at", "confirmed_at").
	From("file_timestamps").
	PlaceholderFormat(sq.Question)

func getTimestampWhere(ctx context.Context, db *sql.DB, where sq.Eq) (*FileTimestamp, error) {
	query, args := selectTimestamp.Where(where).MustSql()
	timestamp, err := database.Get[FileTimestamp](ctx, db, query, args...)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return nil, nil
	case err != nil:
		return nil, err
	}
	return &timestamp, nil
}

// Retry points a failed timestamp at a fresh broadcast, restarting it as confirming.
func Retry(ctx context.Context, db *sql.DB, id int64, txid string, createdAt time.Time) error {
	_, err := db.ExecContext(ctx, `
		UPDATE file_timestamps
		SET txid = ?, status = ?, created_at = ?, block_height = NULL, confirmed_at = NULL
		WHERE id = ?
	`, txid, StatusConfirming, createdAt, id)
	if err != nil {
		return fmt.Errorf("retry file timestamp: %w", err)
	}

	zerolog.Ctx(ctx).Info().
		Int64("id", id).
		Str("txid", txid).
		Msg("retried file timestamp")

	return nil
}

func UpdateFilename(ctx context.Context, db *sql.DB, id int64, filename string) error {
	_, err := db.ExecContext(ctx, `
		UPDATE file_timestamps
		SET filename = ?
		WHERE id = ?
	`, filename, id)
	if err != nil {
		return fmt.Errorf("update filename: %w", err)
	}

	zerolog.Ctx(ctx).Debug().
		Int64("id", id).
		Str("filename", filename).
		Msg("updated timestamp filename")

	return nil
}
