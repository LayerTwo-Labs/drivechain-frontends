package database

import (
	"context"
	"database/sql"
	"encoding/hex"
	"fmt"
	"path/filepath"

	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/dir"
	_ "github.com/mattn/go-sqlite3"
	"github.com/rs/zerolog"
)

// New creates a new SQLite database and runs all migrations
func New(ctx context.Context) (*sql.DB, error) {
	datadir, err := dir.GetDataDir("bitwindow")
	if err != nil {
		return nil, fmt.Errorf("could not get data directory: %v", err)
	}
	dbpath := filepath.Join(datadir, "bitwindow.db")

	zerolog.Ctx(ctx).Debug().
		Str("path", dbpath).
		Msg("opening database")

	db, err := sql.Open("sqlite3", dbpath)
	if err != nil {
		return nil, fmt.Errorf("could not open database: %v", err)
	}

	if err := runMigrations(ctx, db); err != nil {
		if err := db.Close(); err != nil {
			return nil, fmt.Errorf("could not close database nor run migrations: %v", err)
		}

		return nil, fmt.Errorf("could not run migrations: %v", err)
	}

	if err := readOPReturns(ctx, db); err != nil {
		return nil, fmt.Errorf("could not read op_returns: %v", err)
	}

	return db, nil
}
func readOPReturns(ctx context.Context, db *sql.DB) error {
	rows, err := db.QueryContext(ctx, `
		SELECT txid, vout, height, op_return_data 
		FROM op_returns
		ORDER BY created_at DESC
	`)
	if err != nil {
		return fmt.Errorf("could not query op_returns: %w", err)
	}
	defer rows.Close()

	log := zerolog.Ctx(ctx)
	log.Info().Msg("listing all op_returns:")

	for rows.Next() {
		var txid string
		var vout int32
		var data []byte

		if err := rows.Scan(&txid, &vout, &data); err != nil {
			return fmt.Errorf("could not scan row: %w", err)
		}

		log.Info().
			Str("txid", txid).
			Int32("vout", vout).
			Str("data", hex.EncodeToString(data)).
			Msg("found persisted op_return")
	}

	if err := rows.Err(); err != nil {
		return fmt.Errorf("could not iterate rows: %w", err)
	}

	return nil
}
