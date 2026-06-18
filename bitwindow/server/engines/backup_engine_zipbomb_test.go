package engines

import (
	"archive/zip"
	"bytes"
	"testing"
)

func zipWith(t *testing.T, name string, data []byte) []byte {
	t.Helper()
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	if err := addToZip(zw, name, data); err != nil {
		t.Fatal(err)
	}
	if err := zw.Close(); err != nil {
		t.Fatal(err)
	}
	return buf.Bytes()
}

// an over-cap zip entry must be rejected, not read into memory
func TestBackupZipEntryCapped(t *testing.T) {
	orig := maxBackupEntrySize
	maxBackupEntrySize = 1 << 10
	defer func() { maxBackupEntrySize = orig }()

	bomb := zipWith(t, "wallet.json", bytes.Repeat([]byte("a"), 8<<10))
	if _, _, _, _, err := extractZIP(bomb); err == nil {
		t.Fatal("extractZIP accepted an over-cap entry")
	}
	e := &BackupEngine{}
	if _, err := e.validateZIP(bomb); err == nil {
		t.Fatal("validateZIP accepted an over-cap entry")
	}

	// a valid within-cap backup still works
	ok := zipWith(t, "wallet.json", []byte(`{"master":"x","l1":"y"}`))
	wallet, _, _, _, err := extractZIP(ok)
	if err != nil {
		t.Fatalf("extractZIP rejected a valid backup: %v", err)
	}
	if len(wallet) == 0 {
		t.Fatal("extractZIP did not return wallet.json")
	}
	if _, err := e.validateZIP(ok); err != nil {
		t.Fatalf("validateZIP rejected a valid backup: %v", err)
	}
}
