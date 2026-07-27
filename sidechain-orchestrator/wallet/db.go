package wallet

import (
	"context"
	"database/sql"
	"embed"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sqliteguard"
	"github.com/LayerTwo-Labs/sidesail/sqlitemigrate"
	_ "github.com/mattn/go-sqlite3"
	"github.com/rs/zerolog"
)

//go:embed migrations/*.sql
var electrumMigrations embed.FS

// OpenElectrumDB opens (creating if needed) the orchestrator-owned database of
// electrum wallet chain state at path and applies any pending migrations. The
// orchestrator is its sole reader and writer, so a single connection sidesteps
// SQLite lock contention (mirroring bitwindowd's MaxOpenConns(1)).
func OpenElectrumDB(ctx context.Context, path string) (*sql.DB, error) {
	db, err := sqliteguard.Open(ctx, sqliteguard.Config{
		Path:   path,
		Params: "?_busy_timeout=5000",
		Migrate: func(ctx context.Context, db *sql.DB) error {
			_, err := sqlitemigrate.Run(ctx, db, electrumMigrations, "migrations")
			return err
		},
		Log: *zerolog.Ctx(ctx),
	})
	if err != nil {
		return nil, fmt.Errorf("open electrum db: %w", err)
	}
	db.SetMaxOpenConns(1)
	return db, nil
}
