package bitdrive

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

type File struct {
	ID        int64
	TxID      string
	Filename  string
	FileType  string
	SizeBytes int64
	Encrypted bool
	Timestamp uint32
	CreatedAt time.Time
}

func Create(ctx context.Context, db *sql.DB, file File) (int64, error) {
	builder := sq.
		Insert("bitdrive_files").
		Columns("txid", "filename", "file_type", "size_bytes", "encrypted", "timestamp", "created_at").
		Values(
			file.TxID,
			file.Filename,
			file.FileType,
			file.SizeBytes,
			file.Encrypted,
			file.Timestamp,
			file.CreatedAt.Unix(),
		)

	sqlStr, args := builder.MustSql()
	result, err := db.ExecContext(ctx, sqlStr, args...)
	if err != nil {
		return 0, fmt.Errorf("create bitdrive file: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("get last insert ID: %w", err)
	}

	zerolog.Ctx(ctx).Info().
		Int64("id", id).
		Str("txid", file.TxID).
		Str("filename", file.Filename).
		Msg("created bitdrive file record")

	return id, nil
}

var selectFile = sq.
	Select("id", "txid", "filename", "file_type", "size_bytes", "encrypted", "timestamp", "created_at").
	From("bitdrive_files").
	PlaceholderFormat(sq.Question)

func scanFile(scanner interface{ Scan(dest ...any) error }) (File, error) {
	var file File
	var encrypted int64
	var createdAt int64
	if err := scanner.Scan(
		&file.ID,
		&file.TxID,
		&file.Filename,
		&file.FileType,
		&file.SizeBytes,
		&encrypted,
		&file.Timestamp,
		&createdAt,
	); err != nil {
		return File{}, err
	}
	file.Encrypted = encrypted == 1
	file.CreatedAt = time.Unix(createdAt, 0)
	return file, nil
}

func List(ctx context.Context, db *sql.DB) ([]File, error) {
	sqlStr, args := selectFile.OrderBy("created_at DESC").MustSql()
	rows, err := db.QueryContext(ctx, sqlStr, args...)
	if err != nil {
		return nil, fmt.Errorf("list bitdrive files: query: %w", err)
	}
	defer database.SafeDefer(ctx, rows.Close)

	var files []File
	for rows.Next() {
		file, err := scanFile(rows)
		if err != nil {
			return nil, fmt.Errorf("scan bitdrive file: %w", err)
		}
		files = append(files, file)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate bitdrive files: %w", err)
	}

	return files, nil
}

func GetByID(ctx context.Context, db *sql.DB, id int64) (*File, error) {
	file, err := getFileWhere(ctx, db, sq.Eq{"id": id})
	if err != nil {
		return nil, fmt.Errorf("get bitdrive file by id: %w", err)
	}
	return file, nil
}

func GetByTxID(ctx context.Context, db *sql.DB, txid string) (*File, error) {
	file, err := getFileWhere(ctx, db, sq.Eq{"txid": txid})
	if err != nil {
		return nil, fmt.Errorf("get bitdrive file by txid: %w", err)
	}
	return file, nil
}

func getFileWhere(ctx context.Context, db *sql.DB, where sq.Eq) (*File, error) {
	sqlStr, args := selectFile.Where(where).MustSql()
	file, err := scanFile(db.QueryRowContext(ctx, sqlStr, args...))
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return nil, nil
	case err != nil:
		return nil, err
	}
	return &file, nil
}

func Delete(ctx context.Context, db *sql.DB, id int64) error {
	_, err := db.ExecContext(ctx, `
		DELETE FROM bitdrive_files
		WHERE id = ?
	`, id)
	if err != nil {
		return fmt.Errorf("delete bitdrive file: %w", err)
	}

	zerolog.Ctx(ctx).Info().
		Int64("id", id).
		Msg("deleted bitdrive file record")

	return nil
}

func Exists(ctx context.Context, db *sql.DB, txid string) (bool, error) {
	count, err := database.Get[int64](ctx, db, `
		SELECT COUNT(*) FROM bitdrive_files WHERE txid = ?
	`, txid)
	if err != nil {
		return false, fmt.Errorf("check bitdrive file exists: %w", err)
	}
	return count > 0, nil
}
