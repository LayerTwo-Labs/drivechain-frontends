package engines

import (
	"archive/zip"
	"bytes"
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"
)

func TestValidateBackup_JSON_Valid(t *testing.T) {
	e := &BackupEngine{}
	wallet := map[string]interface{}{
		"master": "seed",
		"l1":     "key",
	}
	data, _ := json.Marshal(wallet)

	contents, err := e.ValidateBackup(context.TODO(), data, "wallet.json")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if !contents.HasWallet {
		t.Fatal("expected HasWallet true")
	}
}

func TestValidateBackup_JSON_NewFormat(t *testing.T) {
	e := &BackupEngine{}
	wallet := map[string]interface{}{
		"wallets": []map[string]interface{}{
			{"master": "seed", "l1": "key"},
		},
	}
	data, _ := json.Marshal(wallet)

	contents, err := e.ValidateBackup(context.TODO(), data, "backup.json")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if !contents.HasWallet {
		t.Fatal("expected HasWallet true")
	}
}

func TestValidateBackup_JSON_Invalid(t *testing.T) {
	e := &BackupEngine{}
	wallet := map[string]interface{}{
		"foo": "bar",
	}
	data, _ := json.Marshal(wallet)

	_, err := e.ValidateBackup(context.TODO(), data, "wallet.json")
	if err == nil {
		t.Fatal("expected error for invalid wallet JSON")
	}
}

func TestValidateBackup_ZIP_Valid(t *testing.T) {
	e := &BackupEngine{}

	wallet := map[string]interface{}{"master": "seed", "l1": "key"}
	walletData, _ := json.Marshal(wallet)

	multisig := map[string]interface{}{"groups": []interface{}{}}
	msData, _ := json.Marshal(multisig)

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	w, _ := zw.Create("wallet.json")
	_, _ = w.Write(walletData)
	w, _ = zw.Create("multisig/multisig.json")
	_, _ = w.Write(msData)
	_ = zw.Close()

	contents, err := e.ValidateBackup(context.TODO(), buf.Bytes(), "backup.zip")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if !contents.HasWallet {
		t.Fatal("expected HasWallet true")
	}
	if !contents.HasMultisig {
		t.Fatal("expected HasMultisig true")
	}
}

func TestValidateBackup_ZIP_MissingWallet(t *testing.T) {
	e := &BackupEngine{}

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	w, _ := zw.Create("README.txt")
	_, _ = w.Write([]byte("hello"))
	_ = zw.Close()

	_, err := e.ValidateBackup(context.TODO(), buf.Bytes(), "backup.zip")
	if err == nil {
		t.Fatal("expected error for missing wallet.json")
	}
}

func TestValidateBackup_UnsupportedExtension(t *testing.T) {
	e := &BackupEngine{}

	_, err := e.ValidateBackup(context.TODO(), []byte("data"), "backup.tar.gz")
	if err == nil {
		t.Fatal("expected error for unsupported extension")
	}
}

func testCtx() context.Context {
	logger := zerolog.Nop()
	return logger.WithContext(context.Background())
}

func TestRestoreBackup_JSON(t *testing.T) {
	tmpDir := t.TempDir()

	e := &BackupEngine{
		walletDir: tmpDir,
	}

	wallet := map[string]interface{}{"master": "seed", "l1": "key"}
	data, _ := json.Marshal(wallet)

	err := e.RestoreBackup(testCtx(), data, "wallet.json")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}

	// Verify wallet.json was written
	content, err := os.ReadFile(filepath.Join(tmpDir, "wallet.json"))
	if err != nil {
		t.Fatalf("wallet.json not found: %v", err)
	}
	var restored map[string]interface{}
	_ = json.Unmarshal(content, &restored)
	if restored["master"] != "seed" {
		t.Fatal("wallet.json content mismatch")
	}
}

func TestHasCurrentWallet(t *testing.T) {
	tmpDir := t.TempDir()
	e := &BackupEngine{walletDir: tmpDir}

	if e.HasCurrentWallet() {
		t.Fatal("expected no wallet initially")
	}

	_ = os.WriteFile(filepath.Join(tmpDir, "wallet.json"), []byte(`{"master":"s","l1":"k"}`), 0600)
	if !e.HasCurrentWallet() {
		t.Fatal("expected wallet to exist after writing")
	}
}
