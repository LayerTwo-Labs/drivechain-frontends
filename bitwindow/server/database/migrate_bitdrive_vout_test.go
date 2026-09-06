package database

import (
	"context"
	"io/fs"
	"testing"

	"github.com/stretchr/testify/require"
)

// bitdrive_files was unique on txid alone, so a transaction carrying two
// BitDrive OP_RETURNs lost the second payload. Already-downloaded files must
// survive the rekeying.
func TestMigration047BitdriveFilesKeyedOnOutpoint(t *testing.T) {
	ctx := context.Background()
	db := Test(t)

	// Put the pre-047 table back, holding one downloaded file.
	_, err := db.ExecContext(ctx, `
		DROP TABLE bitdrive_files;
		CREATE TABLE bitdrive_files (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			txid TEXT NOT NULL UNIQUE,
			filename TEXT NOT NULL,
			file_type TEXT NOT NULL,
			size_bytes INTEGER NOT NULL,
			encrypted INTEGER NOT NULL DEFAULT 0,
			timestamp INTEGER NOT NULL,
			created_at INTEGER NOT NULL
		);
		INSERT INTO bitdrive_files (id, txid, filename, file_type, size_bytes, encrypted, timestamp, created_at)
			VALUES (7, 'old-txid', '1700000000_old-txid.txt', 'txt', 4, 0, 1700000000, 1700000000);
	`)
	require.NoError(t, err)

	body, err := fs.ReadFile(migrations, "migrations/047_bitdrive_vout.sql")
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, string(body))
	require.NoError(t, err)

	// The existing row keeps its id and its file on disk, and takes vout 0.
	var (
		id       int64
		vout     int64
		filename string
	)
	require.NoError(t, db.QueryRowContext(ctx, `
		SELECT id, vout, filename FROM bitdrive_files WHERE txid = 'old-txid'
	`).Scan(&id, &vout, &filename))
	require.Equal(t, int64(7), id)
	require.Equal(t, int64(0), vout)
	require.Equal(t, "1700000000_old-txid.txt", filename)

	// A second payload of the same transaction now fits.
	_, err = db.ExecContext(ctx, `
		INSERT INTO bitdrive_files (txid, vout, filename, file_type, size_bytes, encrypted, timestamp, created_at)
		VALUES ('old-txid', 1, '1700000000_old-txid_1.txt', 'txt', 4, 0, 1700000000, 1700000000)
	`)
	require.NoError(t, err)
}
