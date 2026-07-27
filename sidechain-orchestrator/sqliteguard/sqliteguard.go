// Package sqliteguard opens SQLite databases that survive their file being
// deleted underneath a running process.
package sqliteguard

import (
	"context"
	"database/sql"
	"database/sql/driver"
	"errors"
	"fmt"
	"os"
	"sync"

	sqlite3 "github.com/mattn/go-sqlite3"
	"github.com/rs/zerolog"
)

// Config describes a guarded database.
type Config struct {
	// Path is the database file. Staleness is checked against it, so DSN query
	// parameters belong in Params instead.
	Path string

	// Params is an optional DSN suffix, e.g. "?_busy_timeout=5000".
	Params string

	// Migrate applies the schema. Runs on open and on every recreation, so it
	// must be idempotent.
	Migrate func(context.Context, *sql.DB) error

	Log zerolog.Logger
}

// Open returns a database handle that recreates and re-migrates its file if the
// file is deleted while the process is running.
func Open(ctx context.Context, cfg Config) (*sql.DB, error) {
	if cfg.Path == "" {
		return nil, errors.New("sqliteguard: path is required")
	}
	if cfg.Migrate == nil {
		return nil, errors.New("sqliteguard: migrate is required")
	}

	db := sql.OpenDB(&connector{cfg: cfg})
	if err := cfg.Migrate(ctx, db); err != nil {
		_ = db.Close()
		return nil, fmt.Errorf("migrate %s: %w", cfg.Path, err)
	}
	return db, nil
}

type connector struct {
	cfg Config
	mu  sync.Mutex
}

func (c *connector) dsn() string { return c.cfg.Path + c.cfg.Params }

func (c *connector) Connect(context.Context) (driver.Conn, error) {
	if err := c.ensureFile(); err != nil {
		return nil, err
	}
	inner, err := (&sqlite3.SQLiteDriver{}).Open(c.dsn())
	if err != nil {
		return nil, err
	}
	info, _ := c.stat()
	return &conn{Conn: inner, connector: c, file: info}, nil
}

func (c *connector) Driver() driver.Driver { return &sqlite3.SQLiteDriver{} }

// stat describes the file currently at the path, if any.
func (c *connector) stat() (os.FileInfo, bool) {
	info, err := os.Stat(c.cfg.Path)
	return info, err == nil
}

// ensureFile recreates the database and its schema when the file has been
// deleted, so the next connection opens against a usable file.
func (c *connector) ensureFile() error {
	c.mu.Lock()
	defer c.mu.Unlock()

	if _, ok := c.stat(); ok {
		return nil
	}

	c.cfg.Log.Warn().Str("path", c.cfg.Path).Msg("database file is missing, recreating")

	db, err := sql.Open("sqlite3", c.dsn())
	if err != nil {
		return err
	}
	defer func() { _ = db.Close() }()

	ctx := c.cfg.Log.WithContext(context.Background())
	if err := c.cfg.Migrate(ctx, db); err != nil {
		return err
	}

	c.cfg.Log.Info().Str("path", c.cfg.Path).Msg("database recreated")
	return nil
}

func isReadonly(err error) bool {
	var sqlErr sqlite3.Error
	return errors.As(err, &sqlErr) && sqlErr.Code == sqlite3.ErrReadonly
}

type conn struct {
	driver.Conn
	connector *connector
	file      os.FileInfo
}

// IsValid retires a connection whose file was deleted before database/sql hands
// it out again.
func (c *conn) IsValid() bool {
	if c.file == nil {
		return false
	}
	current, ok := c.connector.stat()
	return ok && os.SameFile(c.file, current)
}

// refuseIfStale rejects a dead connection before it does any work, restoring the
// file so database/sql's retry lands on a usable one.
func (c *conn) refuseIfStale() error {
	if c.IsValid() {
		return nil
	}
	if err := c.connector.ensureFile(); err != nil {
		return err
	}
	return driver.ErrBadConn
}

// check swaps a readonly failure for ErrBadConn so database/sql discards this
// connection and retries on one opened against the restored file.
func (c *conn) check(err error) error {
	if err == nil || !isReadonly(err) {
		return err
	}
	if ensureErr := c.connector.ensureFile(); ensureErr != nil {
		c.connector.cfg.Log.Error().Err(ensureErr).Msg("recreating database failed")
		return err
	}
	return driver.ErrBadConn
}

func (c *conn) ResetSession(ctx context.Context) error {
	if err := c.refuseIfStale(); err != nil {
		return err
	}
	if resetter, ok := c.Conn.(driver.SessionResetter); ok {
		return resetter.ResetSession(ctx)
	}
	return nil
}

func (c *conn) Prepare(query string) (driver.Stmt, error) {
	if err := c.refuseIfStale(); err != nil {
		return nil, err
	}
	inner, err := c.Conn.Prepare(query)
	if err != nil {
		return nil, c.check(err)
	}
	return &stmt{Stmt: inner, conn: c}, nil
}

func (c *conn) PrepareContext(ctx context.Context, query string) (driver.Stmt, error) {
	preparer, ok := c.Conn.(driver.ConnPrepareContext)
	if !ok {
		return c.Prepare(query)
	}
	if err := c.refuseIfStale(); err != nil {
		return nil, err
	}
	inner, err := preparer.PrepareContext(ctx, query)
	if err != nil {
		return nil, c.check(err)
	}
	return &stmt{Stmt: inner, conn: c}, nil
}

func (c *conn) ExecContext(ctx context.Context, query string, args []driver.NamedValue) (driver.Result, error) {
	execer, ok := c.Conn.(driver.ExecerContext)
	if !ok {
		return nil, driver.ErrSkip
	}
	if err := c.refuseIfStale(); err != nil {
		return nil, err
	}
	res, err := execer.ExecContext(ctx, query, args)
	if err != nil {
		return nil, c.check(err)
	}
	return res, nil
}

func (c *conn) QueryContext(ctx context.Context, query string, args []driver.NamedValue) (driver.Rows, error) {
	queryer, ok := c.Conn.(driver.QueryerContext)
	if !ok {
		return nil, driver.ErrSkip
	}
	if err := c.refuseIfStale(); err != nil {
		return nil, err
	}
	rows, err := queryer.QueryContext(ctx, query, args)
	if err != nil {
		return nil, c.check(err)
	}
	return rows, nil
}

func (c *conn) Begin() (driver.Tx, error) {
	if err := c.refuseIfStale(); err != nil {
		return nil, err
	}
	inner, err := c.Conn.Begin() //nolint:staticcheck // driver.Conn fallback path
	if err != nil {
		return nil, c.check(err)
	}
	return &tx{Tx: inner, conn: c}, nil
}

func (c *conn) BeginTx(ctx context.Context, opts driver.TxOptions) (driver.Tx, error) {
	beginner, ok := c.Conn.(driver.ConnBeginTx)
	if !ok {
		return c.Begin()
	}
	if err := c.refuseIfStale(); err != nil {
		return nil, err
	}
	inner, err := beginner.BeginTx(ctx, opts)
	if err != nil {
		return nil, c.check(err)
	}
	return &tx{Tx: inner, conn: c}, nil
}

func (c *conn) Ping(ctx context.Context) error {
	pinger, ok := c.Conn.(driver.Pinger)
	if !ok {
		return nil
	}
	if err := c.refuseIfStale(); err != nil {
		return err
	}
	return c.check(pinger.Ping(ctx))
}

type stmt struct {
	driver.Stmt
	conn *conn
}

func (s *stmt) Exec(args []driver.Value) (driver.Result, error) {
	if err := s.conn.refuseIfStale(); err != nil {
		return nil, err
	}
	res, err := s.Stmt.Exec(args) //nolint:staticcheck // driver.Stmt fallback path
	if err != nil {
		return nil, s.conn.check(err)
	}
	return res, nil
}

func (s *stmt) Query(args []driver.Value) (driver.Rows, error) {
	if err := s.conn.refuseIfStale(); err != nil {
		return nil, err
	}
	rows, err := s.Stmt.Query(args) //nolint:staticcheck // driver.Stmt fallback path
	if err != nil {
		return nil, s.conn.check(err)
	}
	return rows, nil
}

func (s *stmt) ExecContext(ctx context.Context, args []driver.NamedValue) (driver.Result, error) {
	execer, ok := s.Stmt.(driver.StmtExecContext)
	if !ok {
		return nil, driver.ErrSkip
	}
	if err := s.conn.refuseIfStale(); err != nil {
		return nil, err
	}
	res, err := execer.ExecContext(ctx, args)
	if err != nil {
		return nil, s.conn.check(err)
	}
	return res, nil
}

func (s *stmt) QueryContext(ctx context.Context, args []driver.NamedValue) (driver.Rows, error) {
	queryer, ok := s.Stmt.(driver.StmtQueryContext)
	if !ok {
		return nil, driver.ErrSkip
	}
	if err := s.conn.refuseIfStale(); err != nil {
		return nil, err
	}
	rows, err := queryer.QueryContext(ctx, args)
	if err != nil {
		return nil, s.conn.check(err)
	}
	return rows, nil
}

type tx struct {
	driver.Tx
	conn *conn
}

func (t *tx) Commit() error { return t.conn.check(t.Tx.Commit()) }

func (t *tx) Rollback() error { return t.conn.check(t.Tx.Rollback()) }
