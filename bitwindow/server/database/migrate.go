package database

import (
	"context"
	"database/sql"
	"embed"

	"github.com/LayerTwo-Labs/sidesail/sqlitemigrate"
	"github.com/rs/zerolog"
)

//go:embed migrations/*.sql
var migrations embed.FS

func runMigrations(ctx context.Context, db *sql.DB) error {
	applied, err := sqlitemigrate.Run(ctx, db, migrations, "migrations")
	if err != nil {
		return err
	}

	log := zerolog.Ctx(ctx)
	if len(applied) == 0 {
		log.Info().Msg("database schema is up to date")
		return nil
	}
	for _, filename := range applied {
		log.Info().Msgf("applied migration %s", filename)
	}
	log.Info().Msg("successfully applied all migrations")
	return nil
}
