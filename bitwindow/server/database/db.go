package database

import (
	"context"
	"database/sql"
	"fmt"
	"path/filepath"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	_ "github.com/mattn/go-sqlite3"
	"github.com/rs/zerolog"
)

// New creates a new SQLite database and runs all migrations
func New(ctx context.Context, conf config.Config) (*sql.DB, error) {
	dbpath := filepath.Join(conf.Datadir, "bitwindow.db")

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

		return nil, fmt.Errorf("run migrations: %v", err)
	}

	return db, nil
}

// SafeDefer calls the given function (typically a close/rollback) and logs if it returns an error.
// Designed to be used in defer statements.
func SafeDefer(ctx context.Context, fn func() error) {
	// we just dont care about the error here
	_ = fn()
}
