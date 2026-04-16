package api

import (
	"os"
	"path/filepath"
	"testing"
)

func TestValidateDirWritable(t *testing.T) {
	t.Run("writable directory succeeds", func(t *testing.T) {
		dir := t.TempDir()
		if err := validateDirWritable(dir); err != nil {
			t.Fatalf("expected nil, got %v", err)
		}
		// Probe file must be cleaned up.
		probe := filepath.Join(dir, ".bitwindow_test")
		if _, err := os.Stat(probe); !os.IsNotExist(err) {
			t.Fatal("probe file was not removed")
		}
	})

	t.Run("non-existent directory fails", func(t *testing.T) {
		dir := filepath.Join(t.TempDir(), "does-not-exist")
		if err := validateDirWritable(dir); err == nil {
			t.Fatal("expected error for non-existent directory")
		}
	})

	t.Run("read-only directory fails", func(t *testing.T) {
		dir := t.TempDir()
		if err := os.Chmod(dir, 0o555); err != nil {
			t.Skip("cannot change permissions")
		}
		defer os.Chmod(dir, 0o755) //nolint:errcheck

		if err := validateDirWritable(dir); err == nil {
			t.Fatal("expected error for read-only directory")
		}
	})
}
