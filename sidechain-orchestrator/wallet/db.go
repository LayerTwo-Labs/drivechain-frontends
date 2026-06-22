package wallet

import (
	"context"
	"database/sql"
	"embed"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sqlitemigrate"
	_ "github.com/mattn/go-sqlite3"
)

//go:embed migrations/*.sql
var electrumMigrations embed.FS

// OpenElectrumDB opens (creating if needed) the orchestrator-owned database of
// electrum wallet chain state at path and applies any pending migrations. The
// orchestrator is its sole reader and writer, so a single connection sidesteps
// SQLite lock contention (mirroring bitwindowd's MaxOpenConns(1)).
func OpenElectrumDB(ctx context.Context, path string) (*sql.DB, error) {
	db, err := sql.Open("sqlite3", path+"?_busy_timeout=5000")
	if err != nil {
		return nil, fmt.Errorf("open electrum db: %w", err)
	}
	db.SetMaxOpenConns(1)
	if _, err := sqlitemigrate.Run(ctx, db, electrumMigrations, "migrations"); err != nil {
		_ = db.Close()
		return nil, fmt.Errorf("migrate electrum db: %w", err)
	}
	return db, nil
}
