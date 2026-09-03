package bitdrive

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	sq "github.com/Masterminds/squirrel"
	"github.com/rs/zerolog"
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

	// Block the file's OP_RETURN was mined in. Nil while it is unconfirmed.
	BlockHeight *int64
}

func Create(ctx context.Context, db *sql.DB, file File) (int64, error) {
	encrypted := 0
	if file.Encrypted {
		encrypted = 1
	}

	builder := sq.
		Insert("bitdrive_files").
		Columns("txid", "filename", "file_type", "size_bytes", "encrypted", "timestamp", "created_at").
		Values(
			file.TxID,
			file.Filename,
			file.FileType,
			file.SizeBytes,
			encrypted,
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

func List(ctx context.Context, db *sql.DB) ([]File, error) {
	query := sq.
		Select("id", "txid", "filename", "file_type", "size_bytes", "encrypted", "timestamp", "created_at", "block_height").
		From("bitdrive_files").
		OrderBy("created_at DESC")

	sqlStr, args := query.MustSql()
	rows, err := db.QueryContext(ctx, sqlStr, args...)
	if err != nil {
		return nil, fmt.Errorf("list bitdrive files: query: %w", err)
	}
	defer rows.Close()

	var files []File
	for rows.Next() {
		var file File
		var encrypted int64
		var createdAt int64
		var blockHeight sql.NullInt64

		err := rows.Scan(
			&file.ID,
			&file.TxID,
			&file.Filename,
			&file.FileType,
			&file.SizeBytes,
			&encrypted,
			&file.Timestamp,
			&createdAt,
			&blockHeight,
		)
		if err != nil {
			return nil, fmt.Errorf("scan bitdrive file: %w", err)
		}

		file.Encrypted = encrypted == 1
		file.CreatedAt = time.Unix(createdAt, 0)
		if blockHeight.Valid {
			file.BlockHeight = &blockHeight.Int64
		}
		files = append(files, file)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate bitdrive files: %w", err)
	}

	return files, nil
}

func GetByID(ctx context.Context, db *sql.DB, id int64) (*File, error) {
	var file File
	var encrypted int64
	var createdAt int64
	var blockHeight sql.NullInt64

	err := db.QueryRowContext(ctx, `
		SELECT id, txid, filename, file_type, size_bytes, encrypted, timestamp, created_at, block_height
		FROM bitdrive_files
		WHERE id = ?
	`, id).Scan(
		&file.ID,
		&file.TxID,
		&file.Filename,
		&file.FileType,
		&file.SizeBytes,
		&encrypted,
		&file.Timestamp,
		&createdAt,
		&blockHeight,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get bitdrive file by id: %w", err)
	}

	file.Encrypted = encrypted == 1
	file.CreatedAt = time.Unix(createdAt, 0)
	if blockHeight.Valid {
		file.BlockHeight = &blockHeight.Int64
	}
	return &file, nil
}

func GetByTxID(ctx context.Context, db *sql.DB, txid string) (*File, error) {
	var file File
	var encrypted int64
	var createdAt int64
	var blockHeight sql.NullInt64

	err := db.QueryRowContext(ctx, `
		SELECT id, txid, filename, file_type, size_bytes, encrypted, timestamp, created_at, block_height
		FROM bitdrive_files
		WHERE txid = ?
	`, txid).Scan(
		&file.ID,
		&file.TxID,
		&file.Filename,
		&file.FileType,
		&file.SizeBytes,
		&encrypted,
		&file.Timestamp,
		&createdAt,
		&blockHeight,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get bitdrive file by txid: %w", err)
	}

	file.Encrypted = encrypted == 1
	file.CreatedAt = time.Unix(createdAt, 0)
	if blockHeight.Valid {
		file.BlockHeight = &blockHeight.Int64
	}
	return &file, nil
}

// MarkConfirmed stamps the block a stored file's OP_RETURN was mined in, so the
// fork purge can tell the file apart from one an orphaned branch carried. A
// txid with no stored file is a no-op.
func MarkConfirmed(ctx context.Context, db *sql.DB, txid string, height int64) error {
	_, err := db.ExecContext(ctx, `
		UPDATE bitdrive_files
		SET block_height = ?
		WHERE txid = ?
	`, height, txid)
	if err != nil {
		return fmt.Errorf("mark bitdrive file confirmed: %w", err)
	}

	return nil
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
	var count int
	err := db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM bitdrive_files WHERE txid = ?
	`, txid).Scan(&count)
	if err != nil {
		return false, fmt.Errorf("check bitdrive file exists: %w", err)
	}
	return count > 0, nil
}
