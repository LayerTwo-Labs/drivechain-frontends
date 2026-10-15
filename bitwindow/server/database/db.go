package database

import (
	"context"
	"database/sql"
	"errors"
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

// SafeDefer calls fn, such as a close or a rollback, in a defer statement and logs a returned error.
func SafeDefer(ctx context.Context, fn func() error) {
	if err := fn(); err != nil && !errors.Is(err, sql.ErrTxDone) {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("deferred close failed")
	}
}
