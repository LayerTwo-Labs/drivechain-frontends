package database

import (
	"context"
	"database/sql"
	"fmt"
	"path/filepath"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sqliteguard"
	"github.com/rs/zerolog"
)

// New creates a new SQLite database and runs all migrations
func New(ctx context.Context, conf config.Config) (*sql.DB, error) {
	dbpath := filepath.Join(conf.Datadir, "bitwindow.db")

	zerolog.Ctx(ctx).Debug().
		Str("path", dbpath).
		Msg("opening database")

	db, err := sqliteguard.Open(ctx, sqliteguard.Config{
		Path:    dbpath,
		Migrate: runMigrations,
		Log:     *zerolog.Ctx(ctx),
	})
	if err != nil {
		return nil, fmt.Errorf("open database: %w", err)
	}

	// When running this against realistic amounts of data we run into DB locking
	// issues if running with multiple connections.
	db.SetMaxOpenConns(1)

	return db, nil
}

// SafeDefer calls the given function (typically a close/rollback) and logs if it returns an error.
// Designed to be used in defer statements.
func SafeDefer(ctx context.Context, fn func() error) {
	// we just dont care about the error here
	_ = fn()
}
