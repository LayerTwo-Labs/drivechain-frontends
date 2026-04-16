package engines

import (
	"context"
	"os"
	"path/filepath"
	"testing"
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
