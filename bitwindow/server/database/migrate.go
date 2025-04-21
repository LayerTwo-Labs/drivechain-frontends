package database

import (
	"context"
	"database/sql"
	"embed"
	"errors"
	"fmt"
	"sort"

	"github.com/rs/zerolog"
)

//go:embed migrations/*.sql
var migrations embed.FS

func runMigrations(ctx context.Context, db *sql.DB) error {
	if _, err := db.Exec(`CREATE TABLE IF NOT EXISTS migrations (
		id INTEGER PRIMARY KEY CHECK (id = 1), -- hard-coded id to force conflict when we later REPLACE INTO
		latest_version TEXT NOT NULL
	)`); err != nil {
		return fmt.Errorf("could not create migrations table: %v", err)
	}

	// Fetch the latest applied migration
	var latestVersion string
	err := db.QueryRowContext(ctx, `SELECT latest_version FROM migrations`).Scan(&latestVersion)
	if errors.Is(err, sql.ErrNoRows) {
		// no migrations have been applied yet
	} else if err != nil {
		return fmt.Errorf("could not get latest migration: %v", err)
	}

	files, err := migrations.ReadDir("migrations")
	if err != nil {
		return fmt.Errorf("could not read migrations directory: %v", err)
	}
	sort.Slice(files, func(i, j int) bool {
		return files[i].Name() < files[j].Name()
	})

	if len(files) > 0 && latestVersion == files[len(files)-1].Name() {
		zerolog.Ctx(ctx).Info().Msg("database schema is up to date")
		return nil
	}

	zerolog.Ctx(ctx).Debug().
		Str("latest_version", latestVersion).
		Msg("applying migrations")

	// apply each migration in order
	for _, file := range files {
		filename := file.Name()
		if filename <= latestVersion {
			continue
		}
		zerolog.Ctx(ctx).Debug().
			Str("filename", filename).
			Str("latest_version", latestVersion).
			Msg("applying migration")

		content, err := migrations.ReadFile("migrations/" + filename)
		if err != nil {
			return fmt.Errorf("could not read migration %s: %v", filename, err)
		}

		if _, err := db.Exec(string(content)); err != nil {
			return fmt.Errorf("could not execute migration %s: %v", filename, err)
		}

		// Hard-coded id to force conflict, and replace the row
		if _, err := db.Exec(`REPLACE INTO migrations (id, latest_version) VALUES (1, ?)`, filename); err != nil {
			return fmt.Errorf("could not update latest migration: %v", err)
		}

		zerolog.Ctx(ctx).Info().Msgf("applied migration %s", filename)
	}

	zerolog.Ctx(ctx).Info().Msg("successfully applied all migrations")

	return nil
}
