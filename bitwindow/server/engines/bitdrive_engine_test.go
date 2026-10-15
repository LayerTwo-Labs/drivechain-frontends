package engines

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/base64"
	"encoding/binary"
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bitdrive"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/btcsuite/btcd/chaincfg"
	_ "github.com/mattn/go-sqlite3"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
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

func TestOpenDir_OpenerOutlivesRequestContext(t *testing.T) {
	dir := t.TempDir()
	marker := filepath.Join(dir, "opened")

	original := dirOpenCommand
	dirOpenCommand = func(dir string) (string, []string) {
		return "sh", []string{"-c", `sleep 0.3 && touch "$1"`, "sh", marker}
	}
	t.Cleanup(func() { dirOpenCommand = original })

	engine := &BitDriveEngine{bitdriveDir: dir}

	ctx, cancel := context.WithCancel(context.Background())
	if err := engine.OpenDir(ctx); err != nil {
		t.Fatalf("OpenDir: %v", err)
	}
	cancel()

	deadline := time.Now().Add(5 * time.Second)
	for {
		if _, err := os.Stat(marker); err == nil {
			return
		}
		if time.Now().After(deadline) {
			t.Fatal("the opener stopped when the request context ended")
		}
		time.Sleep(50 * time.Millisecond)
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

// newEncryptTestEngine builds a BitDriveEngine whose orchestrator names one
// starter wallet, so Encrypt/Decrypt can derive their keys via
// WalletEngine.GetStarterSeed.
func newEncryptTestEngine(t *testing.T) *BitDriveEngine {
	t.Helper()

	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	orch.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&orchpb.ListWalletsResponse{
			Wallets: []*orchpb.WalletMetadata{{Id: "test-enforcer", IsStarter: true}},
		}), nil).
		AnyTimes()
	orch.EXPECT().
		GetWalletSeed(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&orchpb.GetWalletSeedResponse{
			SeedHex: "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f",
		}), nil).
		AnyTimes()

	return &BitDriveEngine{
		walletEngine: NewWalletEngine(nil, orch, t.TempDir(), &chaincfg.SigNetParams),
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
	metadata := EncodeMetadataBytes(true, false, timestamp, fileType)

	plainA := []byte("BitDrive keystream reuse probe payload block AAAA")
	plainB := []byte("BitDrive keystream reuse probe payload block BBBB")

	cipherA, err := engine.Encrypt(ctx, plainA, timestamp, fileType, metadata)
	if err != nil {
		t.Fatalf("encrypt A: %v", err)
	}
	cipherB, err := engine.Encrypt(ctx, plainB, timestamp, fileType, metadata)
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
	cipherA2, err := engine.Encrypt(ctx, plainA, timestamp, fileType, metadata)
	if err != nil {
		t.Fatalf("encrypt A again: %v", err)
	}
	bodyA2 := cipherA2[NonceSize : len(cipherA2)-AuthTagSize]
	if bytes.Equal(bodyA, bodyA2) {
		t.Fatal("identical plaintext produced identical ciphertext body: keystream not randomized")
	}

	// Both ciphertexts must still round-trip through Decrypt.
	gotA, err := engine.Decrypt(ctx, cipherA, timestamp, fileType, metadata)
	if err != nil {
		t.Fatalf("decrypt A: %v", err)
	}
	if !bytes.Equal(gotA, plainA) {
		t.Fatalf("decrypt A mismatch: got %q want %q", gotA, plainA)
	}
	gotB, err := engine.Decrypt(ctx, cipherB, timestamp, fileType, metadata)
	if err != nil {
		t.Fatalf("decrypt B: %v", err)
	}
	if !bytes.Equal(gotB, plainB) {
		t.Fatalf("decrypt B mismatch: got %q want %q", gotB, plainB)
	}
}

// TestDecodeOPReturnData_MetadataTamperRejected verifies that the auth tag covers
// the 9-byte metadata prefix. The keystream seed mixes in the timestamp and file
// type carried by that prefix, so a tag over nonce||ciphertext alone let an
// attacker flip a metadata byte and have Decrypt return garbage with a nil error.
func TestDecodeOPReturnData_MetadataTamperRejected(t *testing.T) {
	ctx := context.Background()
	engine := newEncryptTestEngine(t)

	plain := []byte("BitDrive metadata binding probe payload")

	metadataB64, contentStr, timestamp, err := engine.EncodeOPReturnData(ctx, plain, true)
	if err != nil {
		t.Fatalf("encode: %v", err)
	}

	// The untampered message must still round-trip.
	decoded, _, err := engine.DecodeOPReturnData(ctx, FormatOPReturnData(metadataB64, contentStr))
	if err != nil {
		t.Fatalf("decode untampered: %v", err)
	}
	if !bytes.Equal(decoded, plain) {
		t.Fatalf("round trip mismatch: got %q want %q", decoded, plain)
	}

	metadataBytes, err := base64.StdEncoding.DecodeString(metadataB64)
	if err != nil {
		t.Fatalf("decode metadata base64: %v", err)
	}

	tampers := []struct {
		name   string
		mutate func(metadata []byte)
	}{
		{"timestamp", func(m []byte) { binary.BigEndian.PutUint32(m[1:5], timestamp+1) }},
		{"file type", func(m []byte) { copy(m[5:9], []byte("bin ")) }},
		{"multisig flag", func(m []byte) { m[0] |= FlagMultisig }},
	}

	for _, tt := range tampers {
		t.Run(tt.name, func(t *testing.T) {
			tampered := append([]byte(nil), metadataBytes...)
			tt.mutate(tampered)
			if bytes.Equal(tampered, metadataBytes) {
				t.Fatal("tamper did not change the metadata")
			}

			opReturnData := FormatOPReturnData(base64.StdEncoding.EncodeToString(tampered), contentStr)
			if _, _, err := engine.DecodeOPReturnData(ctx, opReturnData); err == nil {
				t.Fatal("tampered metadata decrypted without error")
			}
		})
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

// TestDetectFileType_NonASCIIIsBinary verifies that any byte above 0x7E makes
// content classify as "bin" rather than "txt". Classifying it as text sends it
// down the raw-storage path, which cannot survive retrieval.
func TestDetectFileType_NonASCIIIsBinary(t *testing.T) {
	tests := []struct {
		name    string
		content []byte
		want    string
	}{
		{"plain ascii", []byte("hello world\n\tand tabs"), "txt"},
		{"utf-8 multi-byte", []byte("café"), "bin"},
		{"high byte", []byte("prefix\xFFsuffix"), "bin"},
		{"continuation byte only", []byte("prefix\xBFsuffix"), "bin"},
		{"delete char", []byte("prefix\x7Fsuffix"), "bin"},
		{"nul byte", []byte("prefix\x00suffix"), "bin"},
		{"high byte past the first 1024", append(bytes.Repeat([]byte("a"), 2048), "ø"...), "bin"},
		{"long pure ascii", bytes.Repeat([]byte("a"), 2048), "txt"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := DetectFileType(tt.content); got != tt.want {
				t.Fatalf("DetectFileType(%q) = %q, want %q", tt.content, got, tt.want)
			}
		})
	}
}

// TestEncodeOPReturnData_NonASCIIRoundTrip walks a payload containing a byte
// above 0x7F through the full store/retrieve chain:
// EncodeOPReturnData -> FormatOPReturnData -> OPReturnToReadable ->
// DecodeOPReturnData. Storing such content as "txt" put raw high bytes on
// chain, which OPReturnToReadable then hex-encoded, hiding the "|" separator
// and making DecodeOPReturnData fail with "invalid format".
func TestEncodeOPReturnData_NonASCIIRoundTrip(t *testing.T) {
	ctx := context.Background()
	engine := &BitDriveEngine{}

	contents := [][]byte{
		[]byte("café ☕ unicode text"),
		[]byte("ascii with one high byte: \xFE"),
		{0x00, 0x01, 0x80, 0xFF, 0x7C, 0x41},
	}

	for _, content := range contents {
		metadataB64, contentStr, _, err := engine.EncodeOPReturnData(ctx, content, false)
		if err != nil {
			t.Fatalf("encode %q: %v", content, err)
		}

		opReturnData := FormatOPReturnData(metadataB64, contentStr)
		readable := opreturns.OPReturnToReadable([]byte(opReturnData))

		decoded, metadata, err := engine.DecodeOPReturnData(ctx, readable)
		if err != nil {
			t.Fatalf("decode %q: %v", content, err)
		}
		if metadata.FileType != "bin" {
			t.Fatalf("expected file type bin for %q, got %q", content, metadata.FileType)
		}
		if !bytes.Equal(decoded, content) {
			t.Fatalf("round trip mismatch: got %q, want %q", decoded, content)
		}
	}
}

func TestScanAndDownloadPendingFiles(t *testing.T) {
	db := database.Test(t)
	engine := &BitDriveEngine{db: db, bitdriveDir: t.TempDir()}

	metadataB64, contentStr, _, err := engine.EncodeOPReturnData(t.Context(), []byte("hello"), false)
	require.NoError(t, err)
	now := time.Now()
	require.NoError(t, opreturns.Persist(t.Context(), db, []opreturns.OPReturn{
		{TxID: "tx-file", Vout: 0, Data: []byte(FormatOPReturnData(metadataB64, contentStr)), CreatedAt: &now},
		{TxID: "tx-other", Vout: 0, Data: []byte("not bitdrive"), CreatedAt: &now},
	}))

	pending, scanned, err := engine.ScanForFiles(t.Context())
	require.NoError(t, err)
	require.Equal(t, 1, scanned)
	require.Len(t, pending, 1)
	require.Equal(t, "tx-file", pending[0].OPReturn.TxID)
	require.Equal(t, "txt", pending[0].Metadata.FileType)

	downloaded, failed, err := engine.DownloadPendingFiles(t.Context())
	require.NoError(t, err)
	require.Equal(t, uint32(1), downloaded)
	require.Equal(t, uint32(0), failed)

	file, err := bitdrive.GetByTxID(t.Context(), db, "tx-file")
	require.NoError(t, err)
	require.NotNil(t, file)
	content, err := engine.GetFileContent(t.Context(), file.Filename)
	require.NoError(t, err)
	require.Equal(t, []byte("hello"), content)

	pending, _, err = engine.ScanForFiles(t.Context())
	require.NoError(t, err)
	require.Empty(t, pending)

	_, err = db.ExecContext(t.Context(), "DROP TABLE bitdrive_files")
	require.NoError(t, err)
	_, _, err = engine.ScanForFiles(t.Context())
	require.ErrorContains(t, err, "check file tx-file")
}

// The fixtures are encrypted messages from an earlier build. A change to the
// encoder must still decode them.
func TestDecodeOPReturnData_EncryptedFixtures(t *testing.T) {
	cases := []struct {
		name         string
		message      string
		want         string
		wantMultisig bool
	}{
		{
			name:         "multisig group",
			message:      "A2rQ4HBqc29u|Syysu01BzpR+GNKcPU0eRqKQSFMxeeTOgNV9UDeCD+bfvIDikF3CTA==",
			want:         `{"name":"group"}`,
			wantMultisig: true,
		},
		{
			name:    "text file",
			message: "AWrQ4HB0eHQg|kn59tk+ayYN4Q4r1Cnsv8vig7KNKuYyNYkJD9B9L72P6lO/VRPgG0+d/tjW4",
			want:    "bitdrive fixture text",
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			engine := newEncryptTestEngine(t)
			require.True(t, IsBitDriveTransaction(tc.message))

			content, metadata, err := engine.DecodeOPReturnData(t.Context(), tc.message)
			require.NoError(t, err)
			require.Equal(t, tc.want, string(content))
			require.True(t, metadata.Encrypted)
			require.Equal(t, tc.wantMultisig, metadata.IsMultisig)
		})
	}
}

func TestEncodeMultisigData_RoundTrip(t *testing.T) {
	for _, encrypt := range []bool{false, true} {
		t.Run(fmt.Sprintf("encrypt=%t", encrypt), func(t *testing.T) {
			engine := newEncryptTestEngine(t)
			message, err := engine.EncodeMultisigData(t.Context(), []byte(`{"m":2}`), encrypt)
			require.NoError(t, err)
			require.True(t, IsBitDriveTransaction(message))

			content, err := engine.DecodeMultisigData(t.Context(), message)
			require.NoError(t, err)
			require.Equal(t, `{"m":2}`, string(content))
		})
	}
}

func TestIsBitDriveTransaction(t *testing.T) {
	metadata := EncodeMetadata(false, false, 1800000000, "txt")
	cases := []struct {
		name    string
		message string
		want    bool
	}{
		{"metadata and content", metadata + "|hello", true},
		{"no separator", metadata, false},
		{"bad base64", "!!!|hello", false},
		{"short metadata", base64.StdEncoding.EncodeToString([]byte{1, 2}) + "|hello", false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			require.Equal(t, tc.want, IsBitDriveTransaction(tc.message))
		})
	}
}

func TestNewBitDriveEngine(t *testing.T) {
	t.Run("creates the bitdrive dir", func(t *testing.T) {
		dataDir := t.TempDir()
		engine, err := NewBitDriveEngine(nil, nil, dataDir, &chaincfg.SigNetParams)
		require.NoError(t, err)
		require.DirExists(t, engine.GetDir())
	})

	t.Run("fails when the datadir is a file", func(t *testing.T) {
		dataDir := filepath.Join(t.TempDir(), "file")
		require.NoError(t, os.WriteFile(dataDir, nil, 0o600))

		_, err := NewBitDriveEngine(nil, nil, dataDir, &chaincfg.SigNetParams)
		require.ErrorContains(t, err, "create bitdrive dir")
	})
}
