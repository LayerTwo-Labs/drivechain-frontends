package engines

import (
	"bytes"
	"context"
	"database/sql"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bitdrive"
	"github.com/btcsuite/btcd/chaincfg"
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

// newEncryptTestEngine builds a BitDriveEngine backed by an on-disk unencrypted
// wallet.json holding a single enforcer wallet, so Encrypt/Decrypt can derive
// their keys via WalletEngine.GetEnforcerSeed.
func newEncryptTestEngine(t *testing.T) *BitDriveEngine {
	t.Helper()

	walletDir := t.TempDir()
	walletJSON := `{
		"version": 1,
		"activeWalletId": "test-enforcer",
		"wallets": [
			{
				"id": "test-enforcer",
				"name": "enforcer",
				"wallet_type": "enforcer",
				"master": {
					"seed_hex": "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
				}
			}
		]
	}`
	if err := os.WriteFile(filepath.Join(walletDir, "wallet.json"), []byte(walletJSON), 0644); err != nil {
		t.Fatalf("write wallet.json: %v", err)
	}

	walletEngine := &WalletEngine{
		walletDir:   walletDir,
		chainParams: &chaincfg.SigNetParams,
	}
	return &BitDriveEngine{
		walletEngine: walletEngine,
		chainParams:  &chaincfg.SigNetParams,
	}
}

// TestEncrypt_SameTimestampSameFileType_NoKeystreamReuse verifies that two files
// encrypted under an identical (timestamp, fileType) tuple derive distinct
// keystreams, so the ciphertext is not a two-time pad, while still round-tripping
// through Decrypt.
func TestEncrypt_SameTimestampSameFileType_NoKeystreamReuse(t *testing.T) {
	ctx := context.Background()
	engine := newEncryptTestEngine(t)

	const timestamp = uint32(1800000000)
	const fileType = "txt"

	plainA := []byte("BitDrive keystream reuse probe payload block AAAA")
	plainB := []byte("BitDrive keystream reuse probe payload block BBBB")

	cipherA, err := engine.Encrypt(ctx, plainA, timestamp, fileType)
	if err != nil {
		t.Fatalf("encrypt A: %v", err)
	}
	cipherB, err := engine.Encrypt(ctx, plainB, timestamp, fileType)
	if err != nil {
		t.Fatalf("encrypt B: %v", err)
	}

	// Strip the nonce prefix and auth tag suffix to isolate the XOR bodies.
	bodyA := cipherA[NonceSize : len(cipherA)-AuthTagSize]
	bodyB := cipherB[NonceSize : len(cipherB)-AuthTagSize]
	if len(bodyA) != len(plainA) || len(bodyB) != len(plainB) {
		t.Fatalf("unexpected body lengths: %d, %d", len(bodyA), len(bodyB))
	}

	// Two-time-pad refutation: with a per-file nonce the two encryptions use
	// distinct keystreams, so bodyA XOR bodyB must NOT equal plainA XOR plainB.
	twoTimePad := true
	for i := range bodyA {
		if bodyA[i]^bodyB[i] != plainA[i]^plainB[i] {
			twoTimePad = false
			break
		}
	}
	if twoTimePad {
		t.Fatal("keystream reused: bodyA XOR bodyB == plainA XOR plainB (two-time pad)")
	}

	// Encrypting the SAME plaintext twice must also yield distinct ciphertext
	// bodies, proving the keystream is randomized per file rather than derived
	// solely from (timestamp, fileType).
	cipherA2, err := engine.Encrypt(ctx, plainA, timestamp, fileType)
	if err != nil {
		t.Fatalf("encrypt A again: %v", err)
	}
	bodyA2 := cipherA2[NonceSize : len(cipherA2)-AuthTagSize]
	if bytes.Equal(bodyA, bodyA2) {
		t.Fatal("identical plaintext produced identical ciphertext body: keystream not randomized")
	}

	// Both ciphertexts must still round-trip through Decrypt.
	gotA, err := engine.Decrypt(ctx, cipherA, timestamp, fileType)
	if err != nil {
		t.Fatalf("decrypt A: %v", err)
	}
	if !bytes.Equal(gotA, plainA) {
		t.Fatalf("decrypt A mismatch: got %q want %q", gotA, plainA)
	}
	gotB, err := engine.Decrypt(ctx, cipherB, timestamp, fileType)
	if err != nil {
		t.Fatalf("decrypt B: %v", err)
	}
	if !bytes.Equal(gotB, plainB) {
		t.Fatalf("decrypt B mismatch: got %q want %q", gotB, plainB)
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
