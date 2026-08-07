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

// OpenElectrumDB opens electrum wallet chain state at path, creating it and
// applying migrations as needed. One database holds every network's history.
func OpenElectrumDB(ctx context.Context, path string) (*sql.DB, error) {
	db, err := sqliteguard.Open(ctx, sqliteguard.Config{
		Path:   path,
		Params: "?_busy_timeout=5000&_journal_mode=WAL",
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
