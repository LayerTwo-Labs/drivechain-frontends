// Package sqlitemigrate applies embedded .sql migration files to a SQLite
// database, in filename order, recording the highest-applied filename in a
// single-row `migrations` table. It is stdlib-only so any module can depend on
// it without pulling in a driver or logger.
//
// The bookkeeping table layout matches what bitwindowd has shipped, so it reads
// existing databases correctly:
//
//	CREATE TABLE migrations (
//	    id             INTEGER PRIMARY KEY CHECK (id = 1),
//	    latest_version TEXT NOT NULL
//	)
package sqlitemigrate

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"io/fs"
	"sort"
	"strings"
)

// Run applies every *.sql file in dir of fsys whose name sorts after the last
// applied migration, in ascending filename order, and records progress in the
// `migrations` table. Already-applied files are skipped, so it is safe to call
// on every startup, and each file is applied in one transaction with its version
// bump, so a failed migration is retried from a clean slate. It returns the
// filenames applied this call (empty when the schema was already up to date) so
// the caller can log as it sees fit.
func Run(ctx context.Context, db *sql.DB, fsys fs.FS, dir string) ([]string, error) {
	if _, err := db.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS migrations (
		id INTEGER PRIMARY KEY CHECK (id = 1), -- hard-coded id so REPLACE INTO updates the single row
		latest_version TEXT NOT NULL
	)`); err != nil {
		return nil, fmt.Errorf("create migrations table: %w", err)
	}

	var latest string
	if err := db.QueryRowContext(ctx, `SELECT latest_version FROM migrations`).Scan(&latest); err != nil &&
		!errors.Is(err, sql.ErrNoRows) {
		return nil, fmt.Errorf("read latest migration: %w", err)
	}

	entries, err := fs.ReadDir(fsys, dir)
	if err != nil {
		return nil, fmt.Errorf("read migrations dir %q: %w", dir, err)
	}
	names := make([]string, 0, len(entries))
	for _, e := range entries {
		if strings.HasSuffix(e.Name(), ".sql") {
			names = append(names, e.Name())
		}
	}
	sort.Strings(names)

	var applied []string
	for _, name := range names {
		if name <= latest {
			continue
		}
		body, err := fs.ReadFile(fsys, dir+"/"+name)
		if err != nil {
			return applied, fmt.Errorf("read migration %s: %w", name, err)
		}
		// The file body and its version bump share one transaction, so a failure
		// part-way through a file leaves nothing behind for the retry to trip on.
		tx, err := db.BeginTx(ctx, nil)
		if err != nil {
			return applied, fmt.Errorf("begin migration %s: %w", name, err)
		}
		if _, err := tx.ExecContext(ctx, string(body)); err != nil {
			_ = tx.Rollback()
			return applied, fmt.Errorf("apply migration %s: %w", name, err)
		}
		if _, err := tx.ExecContext(ctx, `REPLACE INTO migrations (id, latest_version) VALUES (1, ?)`, name); err != nil {
			_ = tx.Rollback()
			return applied, fmt.Errorf("record migration %s: %w", name, err)
		}
		if err := tx.Commit(); err != nil {
			return applied, fmt.Errorf("commit migration %s: %w", name, err)
		}
		applied = append(applied, name)
	}
	return applied, nil
}
