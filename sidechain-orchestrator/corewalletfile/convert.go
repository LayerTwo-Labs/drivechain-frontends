package corewalletfile

import (
	"bytes"
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/url"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"sync"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/blockfile"
	_ "github.com/mattn/go-sqlite3"
)

// Options selects the stopped Core node and its wallet paths.
type Options struct {
	DataDir     string
	WalletDir   string
	WalletPaths []string
	JournalPath string
	From        blockfile.Magic
	To          blockfile.Magic
}

// Report describes the SQLite wallet conversion.
type Report struct {
	Wallets          int
	ConvertedWallets int
	Complete         bool
	JournalPath      string
}

type savedFile struct {
	Suffix string
	Name   string
	Hash   string
}

type wallet struct {
	Path     string
	Original blockfile.Magic
	RowsHash string
	Files    []savedFile
}

type journal struct {
	Version   int
	DataDir   string
	WalletDir string
	From      blockfile.Magic
	To        blockfile.Magic
	Wallets   []wallet
}

var convertMu sync.Mutex

// ErrLegacyWallet identifies a retained wallet that must use SQLite before migration.
var ErrLegacyWallet = errors.New("convert legacy wallets to SQLite before the ECX network change")

// FindWallets returns absolute SQLite wallet paths without network magic checks.
func FindWallets(dataDir, walletDir string) ([]string, error) {
	if dataDir != "" && walletDir == "" {
		if _, err := os.Stat(dataDir); os.IsNotExist(err) {
			return []string{}, nil
		} else if err != nil {
			return nil, err
		}
	}
	opts, err := preparePaths(Options{DataDir: dataDir, WalletDir: walletDir})
	if err != nil {
		return nil, err
	}
	return discover(opts)
}

// Preview reads wallet identities without changes to the node files.
func Preview(ctx context.Context, opts Options) (report Report, err error) {
	if err := ctx.Err(); err != nil {
		return report, err
	}
	opts, err = prepare(opts)
	if err != nil {
		return report, err
	}
	paths, err := discover(opts)
	if err != nil {
		return report, err
	}
	plan, err := loadJournal(opts)
	if err != nil {
		return report, err
	}
	if plan != nil {
		if err := checkPlan(opts, paths, plan); err != nil {
			return report, err
		}
	}
	report.JournalPath = opts.JournalPath
	for i, path := range paths {
		magic, hash, err := inspectCopy(ctx, path)
		if err != nil {
			return report, fmt.Errorf("read wallet %s: %w", path, err)
		}
		if !validMagic(magic, opts.From, opts.To, plan != nil) {
			return report, fmt.Errorf("wallet %s has another network magic", path)
		}
		if plan != nil && hash != plan.Wallets[i].RowsHash {
			return report, fmt.Errorf("wallet %s records differ from the migration journal", path)
		}
		report.Wallets++
		if magic == opts.To {
			report.ConvertedWallets++
		}
	}
	report.Complete = report.Wallets == report.ConvertedWallets
	return report, nil
}

// Convert changes wallet magic after Core stops and keeps original wallet bytes in the journal backup.
func Convert(ctx context.Context, opts Options) (report Report, err error) {
	if err := ctx.Err(); err != nil {
		return report, err
	}
	convertMu.Lock()
	defer convertMu.Unlock()
	opts, err = prepare(opts)
	if err != nil {
		return report, err
	}
	lock, err := os.OpenFile(filepath.Join(opts.DataDir, ".lock"), os.O_CREATE|os.O_RDWR, 0o600)
	if err != nil {
		return report, err
	}
	defer func() { err = errors.Join(err, lock.Close()) }()
	if err := takeLock(lock); err != nil {
		return report, fmt.Errorf("stop Core before the wallet conversion: %w", err)
	}
	paths, err := discover(opts)
	if err != nil {
		return report, err
	}
	plan, err := loadJournal(opts)
	if err != nil {
		return report, err
	}
	resume := plan != nil
	if plan == nil {
		plan, err = makeJournal(ctx, opts, paths)
		if err != nil {
			return report, err
		}
	} else {
		if err := checkPlan(opts, paths, plan); err != nil {
			return report, err
		}
	}
	report.Wallets = len(plan.Wallets)
	report.JournalPath = opts.JournalPath
	for _, item := range plan.Wallets {
		if err := ctx.Err(); err != nil {
			return report, err
		}
		if err := convertWallet(ctx, opts, item, resume); err != nil {
			return report, fmt.Errorf("convert wallet %s: %w", item.Path, err)
		}
		report.ConvertedWallets++
	}
	report.Complete = true
	return report, nil
}

func prepare(opts Options) (Options, error) {
	if opts.From == (blockfile.Magic{}) || opts.To == (blockfile.Magic{}) || opts.From == opts.To {
		return opts, errors.New("source and target magic must differ and cannot equal zero")
	}
	return preparePaths(opts)
}

func preparePaths(opts Options) (Options, error) {
	if opts.DataDir == "" {
		return opts, errors.New("the Core data directory is empty")
	}
	var err error
	opts.DataDir, err = directory(opts.DataDir)
	if err != nil {
		return opts, err
	}
	if opts.WalletDir == "" {
		opts.WalletDir = opts.DataDir
		path := filepath.Join(opts.DataDir, "wallets")
		info, err := os.Stat(path)
		if err != nil && !os.IsNotExist(err) {
			return opts, err
		}
		if err == nil && info.IsDir() {
			opts.WalletDir = path
		}
	}
	opts.WalletDir, err = directory(opts.WalletDir)
	if err != nil {
		return opts, err
	}
	if opts.JournalPath == "" {
		opts.JournalPath = filepath.Join(opts.DataDir, ".ecash-wallet-journal")
	}
	parent, err := directory(filepath.Dir(opts.JournalPath))
	if err != nil {
		return opts, err
	}
	name := filepath.Base(opts.JournalPath)
	if name == "wallet.dat" || name == ".lock" || strings.HasPrefix(name, "wallet.dat-") {
		return opts, errors.New("wallet journal path conflicts with a Core data file")
	}
	opts.JournalPath = filepath.Join(parent, name)
	return opts, nil
}

func directory(path string) (string, error) {
	path, err := filepath.Abs(path)
	if err != nil {
		return "", err
	}
	path, err = filepath.EvalSymlinks(path)
	if err != nil {
		return "", err
	}
	info, err := os.Stat(path)
	if err != nil {
		return "", err
	}
	if !info.IsDir() {
		return "", fmt.Errorf("%s is not a directory", path)
	}
	return path, nil
}

func discover(opts Options) ([]string, error) {
	paths := make(map[string]bool)
	add := func(path string) error {
		path, err := filepath.EvalSymlinks(path)
		if err != nil {
			return err
		}
		header, err := readHeader(path)
		if err != nil {
			return fmt.Errorf("read wallet %s: %w", path, err)
		}
		if !bytes.Equal(header[:16], []byte("SQLite format 3\x00")) {
			return fmt.Errorf("wallet %s is not SQLite: %w", path, ErrLegacyWallet)
		}
		paths[path] = true
		return nil
	}
	err := filepath.WalkDir(opts.WalletDir, func(path string, entry os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if entry.IsDir() {
			if path == opts.JournalPath+".d" {
				return filepath.SkipDir
			}
			return nil
		}
		if entry.Name() == "wallet.dat" {
			return add(path)
		}
		if entry.Type()&os.ModeSymlink != 0 {
			info, err := os.Stat(path)
			if err != nil {
				return err
			}
			if info.IsDir() {
				walletPath := filepath.Join(path, "wallet.dat")
				if _, err := os.Stat(walletPath); err == nil {
					return add(walletPath)
				} else if !os.IsNotExist(err) {
					return err
				}
			}
			return nil
		}
		if filepath.Dir(path) == opts.WalletDir && !strings.HasSuffix(path, ".bak") && entry.Type().IsRegular() {
			info, err := entry.Info()
			if err != nil {
				return err
			}
			if info.Size() >= 4096 {
				header, err := readHeader(path)
				if err != nil {
					return err
				}
				magic := binary.BigEndian.Uint32(header[12:16])
				if magic == 0x00053162 || magic == 0x62310500 {
					return fmt.Errorf("BDB wallet %s is unsupported: %w", path, ErrLegacyWallet)
				}
			}
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	for _, path := range opts.WalletPaths {
		if !filepath.IsAbs(path) {
			path = filepath.Join(opts.WalletDir, path)
		}
		info, err := os.Stat(path)
		if err != nil {
			return nil, fmt.Errorf("read configured wallet %s: %w", path, err)
		}
		if info.IsDir() {
			path = filepath.Join(path, "wallet.dat")
		}
		if err := add(path); err != nil {
			return nil, err
		}
	}
	result := make([]string, 0, len(paths))
	for path := range paths {
		result = append(result, path)
	}
	slices.Sort(result)
	return result, nil
}

func readHeader(path string) (header [100]byte, err error) {
	file, err := os.Open(path)
	if err != nil {
		return header, err
	}
	defer func() { err = errors.Join(err, file.Close()) }()
	info, err := file.Stat()
	if err != nil {
		return header, err
	}
	if !info.Mode().IsRegular() || info.Size() < 512 {
		return header, errors.New("wallet database is not a regular file of at least 512 bytes")
	}
	_, err = file.ReadAt(header[:], 0)
	return header, err
}

func openDatabase(path string, readOnly bool) (*sql.DB, error) {
	uri := url.URL{Scheme: "file", Path: filepath.ToSlash(path)}
	args := url.Values{"mode": {"rw"}, "_busy_timeout": {"0"}}
	if readOnly {
		args.Set("mode", "ro")
		args.Set("immutable", "1")
	}
	uri.RawQuery = args.Encode()
	db, err := sql.Open("sqlite3", uri.String())
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(1)
	return db, nil
}

func inspectCopy(ctx context.Context, path string) (magic blockfile.Magic, hash string, err error) {
	dir, err := os.MkdirTemp("", "ecash-wallet-check-")
	if err != nil {
		return magic, "", err
	}
	defer func() { err = errors.Join(err, os.RemoveAll(dir)) }()
	copyPath := filepath.Join(dir, "wallet.dat")
	for _, suffix := range []string{"", "-wal", "-journal"} {
		if _, err := os.Stat(path + suffix); os.IsNotExist(err) && suffix != "" {
			continue
		} else if err != nil {
			return magic, "", err
		}
		if _, err := copyFile(path+suffix, copyPath+suffix); err != nil {
			return magic, "", err
		}
	}
	db, err := openDatabase(copyPath, false)
	if err != nil {
		return magic, "", err
	}
	defer func() { err = errors.Join(err, db.Close()) }()
	return inspect(ctx, db)
}

func inspect(ctx context.Context, db *sql.DB) (magic blockfile.Magic, hash string, err error) {
	var appID int64
	if err := db.QueryRowContext(ctx, "PRAGMA application_id").Scan(&appID); err != nil {
		return magic, "", err
	}
	binary.BigEndian.PutUint32(magic[:], uint32(appID))
	var version int
	if err := db.QueryRowContext(ctx, "PRAGMA user_version").Scan(&version); err != nil {
		return magic, "", err
	}
	if version != 0 {
		return magic, "", fmt.Errorf("unsupported SQLite wallet schema version %d", version)
	}
	var integrity string
	if err := db.QueryRowContext(ctx, "PRAGMA integrity_check").Scan(&integrity); err != nil {
		return magic, "", err
	}
	if integrity != "ok" {
		return magic, "", errors.New("the SQLite wallet integrity check failed")
	}
	rows, err := db.QueryContext(ctx, "SELECT key, value FROM main ORDER BY key")
	if err != nil {
		return magic, "", err
	}
	defer func() { err = errors.Join(err, rows.Close()) }()
	digest := sha256.New()
	var size [8]byte
	for rows.Next() {
		var key, value []byte
		if err := rows.Scan(&key, &value); err != nil {
			return magic, "", err
		}
		for _, data := range [][]byte{key, value} {
			binary.BigEndian.PutUint64(size[:], uint64(len(data)))
			if _, err := digest.Write(size[:]); err != nil {
				return magic, "", err
			}
			if _, err := digest.Write(data); err != nil {
				return magic, "", err
			}
		}
	}
	if err := rows.Err(); err != nil {
		return magic, "", err
	}
	return magic, hex.EncodeToString(digest.Sum(nil)), nil
}

func convertWallet(ctx context.Context, opts Options, item wallet, resume bool) (err error) {
	db, err := openDatabase(item.Path, false)
	if err != nil {
		return err
	}
	closed := false
	defer func() {
		if !closed {
			err = errors.Join(err, db.Close())
		}
	}()
	for _, query := range []string{"PRAGMA locking_mode=EXCLUSIVE", "PRAGMA synchronous=FULL", "PRAGMA fullfsync=ON", "BEGIN EXCLUSIVE", "COMMIT"} {
		if _, err := db.ExecContext(ctx, query); err != nil {
			return err
		}
	}
	magic, hash, err := inspect(ctx, db)
	if err != nil {
		return err
	}
	if !validMagic(magic, opts.From, opts.To, resume) {
		return errors.New("wallet magic differs from the source and target")
	}
	if hash != item.RowsHash {
		return errors.New("wallet records differ from the migration journal")
	}
	var busy, log, done int
	if err := db.QueryRowContext(ctx, "PRAGMA wal_checkpoint(TRUNCATE)").Scan(&busy, &log, &done); err != nil {
		return err
	}
	if busy != 0 {
		return errors.New("the wallet WAL checkpoint is busy; stop all wallet users")
	}
	err = db.Close()
	closed = true
	if err != nil {
		return err
	}
	for _, suffix := range []string{"-wal", "-journal"} {
		info, err := os.Stat(item.Path + suffix)
		if os.IsNotExist(err) {
			continue
		}
		if err != nil {
			return err
		}
		if info.Size() != 0 {
			return fmt.Errorf("wallet %s is not empty after the checkpoint", suffix)
		}
	}
	header, err := readHeader(item.Path)
	if err != nil {
		return err
	}
	magic = blockfile.Magic(header[68:72])
	if !validMagic(magic, opts.From, opts.To, resume) {
		return errors.New("wallet header magic differs after the checkpoint")
	}
	file, err := os.OpenFile(item.Path, os.O_RDWR, 0)
	if err != nil {
		return err
	}
	defer func() { err = errors.Join(err, file.Close()) }()
	if _, err := file.WriteAt(opts.To[:], 68); err != nil {
		return err
	}
	if err := file.Sync(); err != nil {
		return err
	}
	var actual blockfile.Magic
	if _, err := file.ReadAt(actual[:], 68); err != nil {
		return err
	}
	if actual != opts.To {
		return errors.New("wallet magic differs after the write")
	}
	return nil
}

func validMagic(actual, from, to blockfile.Magic, resume bool) bool {
	if actual == from || actual == to {
		return true
	}
	if !resume {
		return false
	}
	for i := range actual {
		if actual[i] != from[i] && actual[i] != to[i] {
			return false
		}
	}
	return true
}

func makeJournal(ctx context.Context, opts Options, paths []string) (*journal, error) {
	plan := &journal{Version: 1, DataDir: opts.DataDir, WalletDir: opts.WalletDir, From: opts.From, To: opts.To}
	for _, path := range paths {
		if err := ctx.Err(); err != nil {
			return nil, err
		}
		magic, hash, err := inspectCopy(ctx, path)
		if err != nil {
			return nil, fmt.Errorf("read wallet %s: %w", path, err)
		}
		if magic != opts.From && magic != opts.To {
			return nil, fmt.Errorf("wallet %s has another network magic", path)
		}
		header, err := readHeader(path)
		if err != nil {
			return nil, err
		}
		plan.Wallets = append(plan.Wallets, wallet{Path: path, Original: blockfile.Magic(header[68:72]), RowsHash: hash})
	}
	backupDir := opts.JournalPath + ".d"
	if err := os.MkdirAll(backupDir, 0o700); err != nil {
		return nil, err
	}
	for i := range plan.Wallets {
		item := &plan.Wallets[i]
		for _, suffix := range []string{"", "-wal", "-shm", "-journal"} {
			if _, err := os.Stat(item.Path + suffix); os.IsNotExist(err) && suffix != "" {
				continue
			} else if err != nil {
				return nil, err
			}
			name := fmt.Sprintf("%06d-db%s", i, suffix)
			hash, err := copyFile(item.Path+suffix, filepath.Join(backupDir, name))
			if err != nil {
				return nil, err
			}
			item.Files = append(item.Files, savedFile{Suffix: suffix, Name: name, Hash: hash})
		}
	}
	data, err := json.MarshalIndent(plan, "", "  ")
	if err != nil {
		return nil, err
	}
	if err := saveFile(opts.JournalPath, data); err != nil {
		return nil, err
	}
	return plan, nil
}

func loadJournal(opts Options) (*journal, error) {
	data, err := os.ReadFile(opts.JournalPath)
	if os.IsNotExist(err) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var plan journal
	if err := json.Unmarshal(data, &plan); err != nil {
		return nil, fmt.Errorf("read wallet migration journal: %w", err)
	}
	if plan.Version != 1 || plan.DataDir != opts.DataDir || plan.WalletDir != opts.WalletDir || plan.From != opts.From || plan.To != opts.To {
		return nil, errors.New("wallet conversion identity differs from the saved journal")
	}
	return &plan, nil
}

func checkPlan(opts Options, paths []string, plan *journal) error {
	var savedPaths []string
	for _, item := range plan.Wallets {
		savedPaths = append(savedPaths, item.Path)
	}
	if !slices.Equal(paths, savedPaths) {
		return errors.New("wallet paths differ from the migration journal")
	}
	for _, item := range plan.Wallets {
		if len(item.Files) == 0 || item.Files[0].Suffix != "" {
			return errors.New("wallet journal has no original database backup")
		}
		for _, file := range item.Files {
			if file.Name == "" || filepath.Base(file.Name) != file.Name {
				return errors.New("wallet journal has an invalid backup path")
			}
			hash, err := fileHash(filepath.Join(opts.JournalPath+".d", file.Name))
			if err != nil {
				return err
			}
			if hash != file.Hash {
				return errors.New("wallet backup differs from the migration journal")
			}
		}
	}
	return nil
}

func fileHash(path string) (hash string, err error) {
	file, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer func() { err = errors.Join(err, file.Close()) }()
	digest := sha256.New()
	if _, err := io.Copy(digest, file); err != nil {
		return "", err
	}
	return hex.EncodeToString(digest.Sum(nil)), nil
}

func copyFile(from, to string) (hash string, err error) {
	source, err := os.Open(from)
	if err != nil {
		return "", err
	}
	defer func() { err = errors.Join(err, source.Close()) }()
	target, err := os.CreateTemp(filepath.Dir(to), ".wallet-copy-")
	if err != nil {
		return "", err
	}
	closed := false
	defer func() {
		if !closed {
			err = errors.Join(err, target.Close())
		}
	}()
	digest := sha256.New()
	if _, err := io.Copy(io.MultiWriter(target, digest), source); err != nil {
		return "", err
	}
	if err := target.Sync(); err != nil {
		return "", err
	}
	err = target.Close()
	closed = true
	if err != nil {
		return "", err
	}
	if err := moveFile(target.Name(), to); err != nil {
		return "", err
	}
	return hex.EncodeToString(digest.Sum(nil)), nil
}

func saveFile(path string, data []byte) (err error) {
	file, err := os.CreateTemp(filepath.Dir(path), ".wallet-journal-")
	if err != nil {
		return err
	}
	name := file.Name()
	if _, err := file.Write(data); err != nil {
		return errors.Join(err, file.Close())
	}
	if err := file.Sync(); err != nil {
		return errors.Join(err, file.Close())
	}
	if err := file.Close(); err != nil {
		return err
	}
	return moveFile(name, path)
}
