package engines

import (
	"context"
	"database/sql"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bitdrive"
	_ "github.com/mattn/go-sqlite3"
)

func TestOpenDir_CreatesDirectory(t *testing.T) {
	// Set up a temp dir that doesn't exist yet
	tmpDir := t.TempDir()
	targetDir := filepath.Join(tmpDir, "bitdrive-subdir")

	engine := &BitDriveEngine{
		bitdriveDir: targetDir,
	}

	// The directory shouldn't exist yet
	if _, err := os.Stat(targetDir); !os.IsNotExist(err) {
		t.Fatal("expected target dir to not exist before OpenDir")
	}

	// OpenDir will create the directory, then try to exec "open"/"xdg-open".
	// The exec will likely fail in CI, but the dir should be created.
	_ = engine.OpenDir(context.Background())

	// Verify directory was created
	info, err := os.Stat(targetDir)
	if err != nil {
		t.Fatalf("expected target dir to exist after OpenDir, got err: %v", err)
	}
	if !info.IsDir() {
		t.Fatal("expected target path to be a directory")
	}
}

func TestGetDir(t *testing.T) {
	engine := &BitDriveEngine{
		bitdriveDir: "/some/path",
	}
	if got := engine.GetDir(); got != "/some/path" {
		t.Fatalf("expected /some/path, got %s", got)
	}
}

// TestSaveFile_SameSecondNoCollision verifies that two distinct transactions
// sharing an identical timestamp and file type are written to distinct local
// paths, so neither overwrites the other on disk.
func TestSaveFile_SameSecondNoCollision(t *testing.T) {
	ctx := context.Background()

	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	defer db.Close()

	if _, err := db.Exec(`
		CREATE TABLE bitdrive_files (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			txid TEXT NOT NULL UNIQUE,
			filename TEXT NOT NULL,
			file_type TEXT NOT NULL,
			size_bytes INTEGER NOT NULL,
			encrypted INTEGER NOT NULL DEFAULT 0,
			timestamp INTEGER NOT NULL,
			created_at INTEGER NOT NULL
		)
	`); err != nil {
		t.Fatalf("create table: %v", err)
	}

	engine := &BitDriveEngine{
		db:          db,
		bitdriveDir: t.TempDir(),
	}

	meta := &ParsedMetadata{Timestamp: 1700000000, FileType: "txt"}

	if err := engine.SaveFile(ctx, "txid-first", []byte("first file"), meta); err != nil {
		t.Fatalf("save first file: %v", err)
	}
	if err := engine.SaveFile(ctx, "txid-second", []byte("second file"), meta); err != nil {
		t.Fatalf("save second file: %v", err)
	}

	first, err := bitdrive.GetByTxID(ctx, db, "txid-first")
	if err != nil || first == nil {
		t.Fatalf("get first record: %v", err)
	}
	second, err := bitdrive.GetByTxID(ctx, db, "txid-second")
	if err != nil || second == nil {
		t.Fatalf("get second record: %v", err)
	}

	if first.Filename == second.Filename {
		t.Fatalf("expected distinct filenames, both were %q", first.Filename)
	}

	firstContent, err := engine.GetFileContent(ctx, first.Filename)
	if err != nil {
		t.Fatalf("read first content: %v", err)
	}
	secondContent, err := engine.GetFileContent(ctx, second.Filename)
	if err != nil {
		t.Fatalf("read second content: %v", err)
	}

	if string(firstContent) != "first file" {
		t.Fatalf("first file was overwritten: got %q", firstContent)
	}
	if string(secondContent) != "second file" {
		t.Fatalf("second file content wrong: got %q", secondContent)
	}
}
