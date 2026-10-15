package database

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"path/filepath"
	"reflect"
	"time"

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

// Querier runs a query on a *sql.DB or a *sql.Tx.
type Querier interface {
	QueryContext(ctx context.Context, query string, args ...any) (*sql.Rows, error)
}

var (
	_ Querier = (*sql.DB)(nil)
	_ Querier = (*sql.Tx)(nil)
)

// Get runs the query and scans exactly one row into T. Zero rows returns an
// error that wraps sql.ErrNoRows.
func Get[T any](ctx context.Context, q Querier, query string, args ...any) (T, error) {
	var t T
	res, err := queryRows[T](ctx, q, 2, query, args...)
	if err != nil {
		return t, fmt.Errorf("get %T: %w", t, err)
	}
	switch len(res) {
	case 0:
		return t, fmt.Errorf("get %T: %w", t, sql.ErrNoRows)
	case 1:
		return res[0], nil
	default:
		return t, fmt.Errorf("get %T: query returned more than one row", t)
	}
}

// Select runs the query and scans each row into T.
func Select[T any](ctx context.Context, q Querier, query string, args ...any) ([]T, error) {
	res, err := queryRows[T](ctx, q, 0, query, args...)
	if err != nil {
		var t T
		return nil, fmt.Errorf("select %T: %w", t, err)
	}
	return res, nil
}

// queryRows reads at most limit rows, or all rows when limit is 0.
func queryRows[T any](ctx context.Context, q Querier, limit int, query string, args ...any) (res []T, err error) {
	rows, err := q.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer func() {
		if closeErr := rows.Close(); closeErr != nil && err == nil {
			err = closeErr
		}
	}()

	cols, err := rows.Columns()
	if err != nil {
		return nil, err
	}
	dest, err := scanPlan[T](cols)
	if err != nil {
		return nil, err
	}

	for rows.Next() {
		var t T
		if err := rows.Scan(dest(&t)...); err != nil {
			return nil, err
		}
		res = append(res, t)
		if limit > 0 && len(res) == limit {
			break
		}
	}
	return res, rows.Err()
}

var (
	scannerType = reflect.TypeFor[sql.Scanner]()
	timeType    = reflect.TypeFor[time.Time]()
)

// scanPlan returns the scan destinations of a T for the given columns.
func scanPlan[T any](cols []string) (func(*T) []any, error) {
	typ := reflect.TypeFor[T]()
	if typ.Kind() != reflect.Struct || typ == timeType || reflect.PointerTo(typ).Implements(scannerType) {
		if len(cols) != 1 {
			return nil, fmt.Errorf("scan %d columns into scalar %s", len(cols), typ)
		}
		return func(t *T) []any { return []any{t} }, nil
	}

	fields := make(map[string]int, typ.NumField())
	for i := range typ.NumField() {
		if tag := typ.Field(i).Tag.Get("db"); tag != "" && tag != "-" {
			fields[tag] = i
		}
	}
	idx := make([]int, len(cols))
	for i, col := range cols {
		f, ok := fields[col]
		if !ok {
			return nil, fmt.Errorf("column %q has no field in %s", col, typ)
		}
		idx[i] = f
	}
	return func(t *T) []any {
		v := reflect.ValueOf(t).Elem()
		dest := make([]any, len(idx))
		for i, f := range idx {
			dest[i] = v.Field(f).Addr().Interface()
		}
		return dest
	}, nil
}

// CheckOne returns an error unless the statement affected exactly one row.
// Zero rows returns an error that wraps sql.ErrNoRows.
func CheckOne(res sql.Result, err error) error {
	if err != nil {
		return err
	}
	got, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("rows affected: %w", err)
	}
	if got == 1 {
		return nil
	}
	if got == 0 {
		return fmt.Errorf("affected 0 rows, want 1: %w", sql.ErrNoRows)
	}
	return fmt.Errorf("affected %d rows, want 1", got)
}
