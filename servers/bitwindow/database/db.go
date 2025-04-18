package database

import (
	"context"
	"database/sql"
	"fmt"
	"path/filepath"

	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/dir"
	_ "github.com/mattn/go-sqlite3"
	"github.com/rs/zerolog"
)

// New creates a new SQLite database and runs all migrations
func New(ctx context.Context) (*sql.DB, error) {
	datadir, err := dir.GetDataDir()
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

	return db, nil
}

// SafeDefer calls the given function (typically a close/rollback) and logs if it returns an error.
// Designed to be used in defer statements.
func SafeDefer(ctx context.Context, fn func() error) {
	if err := fn(); err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msg("deferred cleanup failed")
	}
}
